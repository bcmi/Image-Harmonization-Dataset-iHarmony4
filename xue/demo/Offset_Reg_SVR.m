function Offset_Reg_SVR(goal, region)
close all; clc; 

%clear all;

load ('data\\cell_compositing_all.mat');   % load cell_compositing_all

nComp = length(cell_compositing_all);

%goal = 'lum';   % 'lum', 'cntrst', 'cct', 'sat', 'hue'

%region = 'mean';  % 'top', 'low', 'mean', 'median', 'high'

disp(sprintf('Reg SVR. Goal = %s, region = %s', goal, region));

%% Load data
loadData_reg;


%% Baseline
fn = sprintf('img\\%s_%s_Offset_Reg_SVR.txt', goal, region);
fid = fopen(fn,'wt');

error_zero = mean( abs(p) );
disp(sprintf('0-matching mean error = %f', error_zero));
fprintf(fid, '0-matching mean error = %f\n', error_zero);

%% Data normalization
% Scale the data into [0, 1]
minPerFeature   = min(X,[],1);      % 1 x P.   P = # features
rangePerFeature = spdiags(1./(max(X,[],1)-min(X,[],1))',0,size(X,2),size(X,2));   % diag( P )

X = (X - repmat(min(X,[],1),size(X,1),1)) * spdiags(1./(max(X,[],1)-min(X,[],1))',0,size(X,2),size(X,2));





%% %% SVR %% %%
addpath libsvm-3.1\windows

%% Parameter Selection
nFold = 10;

cvPara = true;   % if use cv to select paramters, e.g., c, g in RBF
if cvPara == true;
    minSqrError = 1e6;
    for log2c = -4:2:4,   %default c = 1
      for log2g = -6:2:2,      %default g = 1/ # features
            % -s 3 :  epsilon-SVR   -t 2 RBF kernel
            cmd = ['-s 3 -t 2 -c ', num2str(2^log2c), ' -g ', num2str(2^log2g), ' -v ',  num2str(nFold)];   % -v: cross-validation mode
            if  ~isempty( strfind(goal, 'hue') ) %goal for hue
                sqrError_c = svmtrain(p_c, X, cmd);
                sqrError_s = svmtrain(p_s, X, cmd);
                sqrError = sqrError_c + sqrError_s;
            else
                sqrError = svmtrain(p, X, cmd);
            end
            if(sqrError < minSqrError)
                bestc = 2^log2c;
                bestg = 2^log2g;
                minSqrError = sqrError;
            end
      end
    end
    fprintf('%d CV to choose parameters: (bestc=%f, bestg=%f, minSqrError=%f)\n', nFold, bestc, bestg, minSqrError);
    fprintf(fid, '%d CV to choose parameters: (bestc=%f, bestg=%f, minSqrError=%f)\n', nFold, bestc, bestg, minSqrError);
else
    bestc = 16;
    bestg = 1;
    fprintf('Preset parameters: (bestc=%f, bestg=%f)\n', bestc, bestg);
    fprintf(fid, 'Preset parameters: (bestc=%f, bestg=%f)\n', bestc, bestg);
end


%% K-Fold Cross-Validation to determine Kernel parameters
[N D] = size(X);
randvector = randperm(N);  % [1:N];   % 
predicted   = zeros(size(p));
for i=1:nFold
    s = floor( N/nFold * (i-1) );
    s = min(max(s,1), N);
    t = floor( N/nFold * i  );
    t = min(max(t,1), N);
    X_tst = X(randvector(s:t),:);       % 1/nFold
    p_tst = p(randvector(s:t),:);
    X_trn = X( [randvector(1:(s-1)), randvector((t+1):end)],:); % 1-1/nFold
    p_trn = p( [randvector(1:(s-1)), randvector((t+1):end)],:);

    cmd = ['-s 3 -t 2 -c ', num2str(bestc), ' -g ', num2str(bestg)];
    if  ~isempty( strfind(goal, 'hue') ) %goal for hue
        p_trn_c = p_c( [randvector(1:(s-1)), randvector((t+1):end)],:);
        model2_c = svmtrain(p_trn_c, X_trn, cmd);
        [predicted_c, accuracy, decision_values] = svmpredict(p_tst, X_tst, model2_c);
        predicted_c = max(min(predicted_c,1), -1);
        
        p_trn_s = p_s( [randvector(1:(s-1)), randvector((t+1):end)],:);
        model2_s = svmtrain(p_trn_s, X_trn, cmd);
        [predicted_s, accuracy, decision_values] = svmpredict(p_tst, X_tst, model2_s);
        predicted_s = max(min(predicted_s,1), -1);
                
        predicted(randvector(s:t)) = cossin2hue(predicted_c, predicted_s);
    else
        model2 = svmtrain(p_trn, X_trn, cmd);
        [predicted_tst, accuracy, decision_values] = svmpredict(p_tst, X_tst, model2);
        predicted(randvector(s:t)) = predicted_tst;
    end
end

if  ~isempty( strfind(goal, 'hue') ) %goal for hue
    error_predicted = mean( hueDist(p, predicted) );
else
    error_predicted = mean( abs(p-predicted) );
end
disp(sprintf('%d-CV mean error = %f', nFold, error_predicted));
fprintf(fid, '%d-CV mean error = %f\n', nFold, error_predicted);

%         res = predicted - p;
%         RSS  = sum(res.*res);
%         tss =  p - mean(p);
%         TSS  = sum(tss.*tss);
%         R_sqr = 1 - RSS/TSS;          % R square
%         disp(sprintf('CV R_sqr = %f', R_sqr));

% plot
h1 = figure; hold on;
plot(p, 'r.', 'MarkerSize', 10); 
plot(predicted, 'b.', 'MarkerSize', 10); 
xlim([1, length(p)]);
legend('Real Offset', 'BestPredicted by CV');
title('CV Offset');  %— Vector of residuals
saveas(h1, sprintf('img\\%s_%s_Offset_SVR_CV.jpg', goal, region) );



%% Fitting
cmd = ['-s 3 -t 2 -c ', num2str(bestc), ' -g ', num2str(bestg)];
if  ~isempty( strfind(goal, 'hue') ) %goal for hue
    model_c = svmtrain(p_c, X, cmd);
    [predicted_c, accuracy, decision_values] = svmpredict(p, X, model_c);
    predicted_c = max(min(predicted_c,1), -1);

    model_s = svmtrain(p_s, X, cmd);
    [predicted_s, accuracy, decision_values] = svmpredict(p, X, model_s);
    predicted_s = max(min(predicted_s,1), -1);

    save(sprintf('model\\%s_%s_Offset_SVR.mat', goal, region), 'minPerFeature',  'rangePerFeature', 'model_c', 'model_s');  
    
    predicted = cossin2hue(predicted_c, predicted_s);
else
    model = svmtrain(p, X, cmd);
    save(sprintf('model\\%s_%s_Offset_SVR.mat', goal, region), 'minPerFeature',  'rangePerFeature', 'model');
    
    [predicted, accuracy, decision_values] = svmpredict(p, X, model);
end

if  ~isempty( strfind(goal, 'hue') ) %goal for hue
    error_predicted = mean( hueDist(p, predicted) );
else
    error_predicted = mean( abs(p-predicted) );
end
disp(sprintf('Fitting mean error = %f', error_predicted));
fprintf(fid, 'Fitting mean error = %f\n', error_predicted);

% Fitting Goodness
h = figure; hold on;
plot(p, 'r.', 'MarkerSize', 10); 
plot(predicted, 'b.', 'MarkerSize', 10); 
xlim([1,length(p)]);
legend('Real Offset', 'Predicted by Fitting');
title('Fitting Offset');  %— Vector of residuals
saveas(h, sprintf('img\\%s_%s_Offset_SVR_Fitting.jpg', goal, region) );

fclose(fid);

% res  = p-predicted;
% RSS  = sum(res.*res);
% tss =  p - mean(p);
% TSS  = sum(tss.*tss);
% R_sqr = 1 - RSS/TSS;          % R square
% disp(sprintf('Fitting R_sqr = %f', R_sqr));



% %% Predict on MTurk Experimental Data
% category = 'all';
% % Load Image specific Brightness features: 
% if strcmp(goal, 'bright') == 1
%     path1 = 'E:\My Study\Research_Projects\2011_ImageCompositing\Experiment\Matlab_Bright_4.5\data';
% elseif strcmp(goal, 'color') == 1
%     path1 = 'E:\My Study\Research_Projects\2011_ImageCompositing\Experiment\Matlab_Color_2.5\data';
% end
% load ( sprintf('%s\\cell_Img_%s.mat', path1, category) );       %load cell_Img
% % Load Offset and Sigma
% load ( sprintf('%s\\Offset_Sigma_%s.mat', path1, category) );    %Load offset_high,offset_shdw,offset_mean; sigma_high,sigma_shdw,sigma_mean.
% 
% index = 1;
% for i = 1:length(cell_Img)  
%     Features = cell_Img{i};
%     assignFeatures;
%     
%     %% Feature for learning offset 
%     if strcmp(goal, 'bright') == 1
%          Features_Off =  [std_F, entropy_F, ...
%                         gCntrst_F, lCntrst_largest_F, lCntrst_mean_F, ...
%                         harshDrop_F, highPortion_F, ...
%                         cct_high_F, cct_shdw_F, ...
%                         cct_mean_warmest_F, cct_mean_coldest_F, cct_F, ...
%                         cct_std_F, cct_entropy_F, ...
%                         cct_gCntrst_F, cct_lCntrst_largest_F, cct_lCntrst_mean_F, ...    % Forground
%                         ...
%                         std_B, entropy_B, ...
%                         gCntrst_B, lCntrst_largest_B, lCntrst_mean_B, ...
%                         harshDrop_B, highPortion_B, ...
%                         cct_high_B, cct_shdw_B, ...
%                         cct_mean_warmest_B, cct_mean_coldest_B, cct_B, ...
%                         cct_std_B, cct_entropy_B, ...
%                         cct_gCntrst_B, cct_lCntrst_largest_B, cct_lCntrst_mean_B, ...      % background
%                         ...
%                         chi2_lab,   ...     % difference
%                         ];
%                     
%     elseif strcmp(goal, 'color') == 1
%         Features_Off =  [mean_high_F, mean_shdw_F, mean_F,   ...
%                         std_F, entropy_F, ...
%                         gCntrst_F, lCntrst_largest_F, lCntrst_mean_F, ...
%                         harshDrop_F, highPortion_F, ...
%                         cct_std_F, cct_entropy_F, ...
%                         cct_gCntrst_F, cct_lCntrst_largest_F, cct_lCntrst_mean_F,  ...    % first row
%                         ...
%                         mean_high_B, mean_shdw_B, mean_B,   ...
%                         std_B,entropy_B, ...
%                         gCntrst_B, lCntrst_largest_B, lCntrst_mean_B, ...
%                         harshDrop_B, highPortion_B, ...
%                         cct_std_B, cct_entropy_B, ...
%                         cct_gCntrst_B, cct_lCntrst_largest_B, cct_lCntrst_mean_B, ...      % second row
%                     ];
%     end; % if
%             
%     if  sum(sum( isnan(Features_Off) )) > 0
%         disp('Warning: there is NaN in Features_Off.');
%         continue;
%     end
% 
%     if  sum(sum( isnan([cct_high_F,cct_high_B,cct_shdw_F,cct_shdw_B,cct_F,cct_B ]) )) > 0
%         disp('Warning: there is NaN in CCTs of F and B.');
%         continue;
%     end
%     
%     X_sti(index, :) = Features_Off;   % stimuli
%     
%     
%     %% Real and Fitted Offset
%     if strcmp(goal, 'bright') == 1
%         switch lower(region)
%             case 'high'
%                 p_sti(index, :) = mean_high_F - mean_high_B;  % Calculate from stimuli
%                 p_off(index, :) = offset_high(i);             % Load from offset_high  
%             case 'shdw'
%                 p_sti(index, :) = mean_shdw_F - mean_shdw_B;
%                 p_off(index, :) = offset_shdw(i);
%             case 'mean'
%                 p_sti(index, :) = mean_F - mean_B;          
%                 p_off(index, :) = offset_mean(i);
%         end
%         
%     elseif  strcmp(goal, 'color') == 1
%         switch lower(region)
%             case 'high'
%                 p_sti(index, :) = cct_high_F - cct_high_B;  
%                 p_off(index, :) = offset_high(i);
%             case 'shdw'
%                 p_sti(index, :) = cct_shdw_F - cct_shdw_B;
%                 p_off(index, :) = offset_shdw(i);
%             case 'mean'
%                 p_sti(index, :) = cct_F - cct_B;          
%                 p_off(index, :) = offset_mean(i);
%         end
%     end
%     
%     index = index + 1;
% end
% 
% % Data normalization
% % Scale the data into [0, 1]
% minF = repmat(minPerFeature, size(X_sti,1),1);  % N x P, N = # observation, P = # features
% X_sti = (X_sti - minF) * rangePerFeature;
% 
% % predict
% cmd = ['-s 3 -t 2 -c ', num2str(bestc), ' -g ', num2str(bestg)];
% model2 = svmtrain(p, X, cmd);
% 
% [predicted, accuracy, decision_values] = svmpredict(p_sti, X_sti, model2);
% 
% 
% % Fitting Goodness
% h3 = figure; hold on;
% %plot(p_off-0.05, 'g.', 'MarkerSize', 25);
% plot(p_sti, 'r.', 'MarkerSize', 25); 
% plot(predicted, 'b.', 'MarkerSize', 25); 
% 
% legend('Real Offset', 'Predicted');
% xlim([1,length(p_sti)]);
% title('Predict Stimuli Offset');  %— Vector of residuals
% saveas(h3, sprintf('img\\Offset_Predict_Stimuli.jpg') );
% 
% res  = p_sti-predicted;
% RSS  = sum(res.*res);
% tss =  p_sti - mean(p_sti);
% TSS  = sum(tss.*tss);
% R_sqr = 1 - RSS/TSS;          % R square
% disp(sprintf('Predict Stimuli R_sqr = %f', R_sqr));

rmpath  libsvm-3.1\windows