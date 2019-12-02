function outI = MatchAlgorithm(oriI, oriMask, goal, method, region, ss)
%% Input: 
% oriI, 0~1, 3 channel
% oriMask, 0~1, 1 channel

disp(sprintf('Match %s, %s, %s\n', goal, method, region));

%% Load Model
pos  = strfind(method, '_');
if isempty(pos)
    type = method;
    mthd = [];
else
    type = method(1:(pos-1));
    mthd = method((pos+1):end);
end

if strcmp(type, 'zero')
    ;
elseif strcmp(type, 'reg')
    if strcmp(mthd, 'RF'),
        addpath RF_Reg_C
    elseif strcmp(mthd, 'SVR'),
        addpath libsvm-3.1\windows
    end    
    fn = sprintf('model\\%s_%s_Offset_%s.mat', goal, region, mthd);   
    load( fn );  % 'minPerFeature',  'rangePerFeature', 'model'    
elseif strcmp(type, 'cls') 
    if strcmp(mthd, 'RF'),
        addpath RF_Class_C
    elseif strcmp(mthd, 'SVR'),
        addpath libsvm-3.1\windows
    end
    fn = sprintf('model\\%s_Class_%s.mat', goal, mthd);   
    load( fn );  % 'minPerFeature',  'rangePerFeature', 'model'
elseif strcmp(type, 'multiCls')
    if strcmp(mthd, 'RF'),
        addpath RF_Class_C
    elseif strcmp(mthd, 'SVR'),
        addpath libsvm-3.1\windows
    end
    fn = sprintf('model\\%s_MultiClass_ss=%.2f_%s.mat', goal, ss, mthd);   
    load( fn );  % 'minPerFeature',  'rangePerFeature', 'model'
end



%% Calculate fg/bg features of the input
[Mask, I_bright, I_lCntrst, I_cct, I_S, I_H] = prepImg_input(oriMask, oriI);

if sum(sum(Mask)) < 500 %added by Mia 1000 original
    disp('ERROR: Too Small Masked object (area<2500)!');
    outI = oriI;
    return;
end

fgbgFeatures = calcFeaturesAfterPrep(Mask, I_bright, I_lCntrst, I_cct, I_S, I_H);

assignFeatures;  

%% Feature for learning offset
selectFeatures;


%% Zero or Regression
if strcmp(type, 'zero') || strcmp(type, 'reg')
    setOffset;   % the input offset for input "region"
    if  sum( isnan([Features_Off, offset'])) > 0
       disp(sprintf('Warning: there is NaN in Features_Off or offset.\n'));
       %fprintf(fid, 'Warning: there is NaN in Features_Off or offset.\n');
       outI = oriI;
       return;
    end    
%% Classification    
elseif   strcmp(type, 'cls') 
    index = 1;      %index used by setLabel, though it is only 1 here.
    setLabel;       % d1(:)~d4(:) and d(:) and input minLabel
    if  sum( isnan([Features_Off, label'])) > 0
       disp(sprintf('Warning: there is NaN in Features_Off or label.\n'));
       %fprintf(fid, 'Warning: there is NaN in Features_Off or label.\n');
       outI=oriI;
       return;
    end
%% Multi-Classification    
elseif   strcmp(type, 'multiCls') 
    index = 1;      %index used by setMultiLabel, though it is only 1 here.
    setMultiLabel;       % d1(:)~d4(:) and d(:) and input minLabel
    if  sum( isnan([Features_Off, label'])) > 0
       disp(sprintf('Warning: there is NaN in Features_Off or label.\n'));
       %fprintf(fid, 'Warning: there is NaN in Features_Off or label.\n');
       outI=oriI;
       return;
    end
end


%% Test Data normalization
if strcmp(type, 'reg') || strcmp(type, 'cls') || strcmp(type, 'multiCls')
    X_test = Features_Off;
    minF = repmat(minPerFeature, size(X_test,1),1);  % N x P, N = # observation, P = # features
    X_test = (X_test - minF) * rangePerFeature;
end



%% %% Start Prediction

%% Zero matching
if  strcmp(type, 'zero')
    predicted = 0;
    
%% Regression
elseif   strcmp(type, 'reg') 
    if  ~isempty( strfind(goal, 'hue') ) %goal for hue
            switch mthd
                case 'GLM',
                    predicted_c = [1, X_test] * coef_c;
                    predicted_s = [1, X_test] * coef_s;
                case 'RF',
                    predicted_c = regRF_predict(X_test, model_c);
                    predicted_s = regRF_predict(X_test, model_s);
                case 'SVR',
                    [predicted_c, accuracy, decision_values] = svmpredict(-1, X_test, model_c);
                    [predicted_s, accuracy, decision_values] = svmpredict(-1, X_test, model_s);
            end
            
            predicted_c = max(min(predicted_c,1), -1);
            predicted_s = max(min(predicted_s,1), -1);

            predicted = cossin2hue(predicted_c, predicted_s);
            if predicted>0.5,
                    predicted = predicted -1;
            elseif predicted<-0.5,
                    predicted = predicted + 1;
            end;
    else
            switch mthd
                case 'GLM',
                    predicted = [1, X_test] * coef;
                case 'RF',
                    predicted = regRF_predict(X_test, model);
                case 'SVR',
                    predicted = svmpredict(-1, X_test, model);
            end
   end

%% Classification
elseif   strcmp(type, 'cls') 
    switch mthd
        case 'RF',
            pred_label = classRF_predict(X_test, model);   %predicted label
        case 'SVC',
            [pred_label, accuracy, decision_values] = svmpredict(-1, X_test, model);
    end
    disp(sprintf('Predicted Label = %d\n', pred_label));
    %fprintf(fid, 'Predicted Label = %d\n', pred_label);

    switch pred_label
        case 1, offset = d1(index);   %predicted input offset should be changed
        case 2, offset = d2(index);
        case 3, offset = d3(index);
        case 4, offset = d4(index);
    end
    predicted = 0;

%% multi-Classification
elseif   strcmp(type, 'multiCls') 
    switch mthd
        case 'RF',
           if ~isempty(d1),    
               predLabel_1 = classRF_predict(X_test, model_1);  
               disp(sprintf('Predicted Label 1 = %d\n', predLabel_1));
               %fprintf(fid, 'Predicted Label 1 = %d\n', predLabel_1);
           end
           if ~isempty(d2),    
               predLabel_2 = classRF_predict(X_test, model_2);  
               disp(sprintf('Predicted Label 2 = %d\n', predLabel_2));
               %fprintf(fid, 'Predicted Label 2 = %d\n', predLabel_2);
           end
           if ~isempty(d3),    
               predLabel_3 = classRF_predict(X_test, model_3);  
               disp(sprintf('Predicted Label 3 = %d\n', predLabel_3));
               %fprintf(fid, 'Predicted Label 3 = %d\n', predLabel_3);
           end
           if ~isempty(d4),    
               predLabel_4 = classRF_predict(X_test, model_4);  
               disp(sprintf('Predicted Label 4 = %d\n', predLabel_4));
               %fprintf(fid, 'Predicted Label 4 = %d\n', predLabel_4);
           end
    end

    findBestLabel;  % Output: bestOpt, minCost, bestOff, minMeanCost
    
    offset = bestOff;
    
    predicted = 0;
    
end


disp(sprintf('Input offset=%f, Predicted = %f\n', offset, predicted));
%fprintf(fid, 'Predicted Offset = %f\n', predicted);


%% Real Adjustment
% Prediction
shift_f = predicted - offset;   % dp is predicted minOffset
outI = manipulateFeature(goal, oriI, oriMask, shift_f, 0);


%% Clear up
if ~isempty( strfind(method, 'reg_RF') )
    rmpath RF_Reg_C;
elseif ~isempty( strfind(method, 'cls_RF') )
    rmpath RF_Class_C;
elseif ~isempty( strfind(method, 'SV') )    
    rmpath libsvm-3.1\windows
end
