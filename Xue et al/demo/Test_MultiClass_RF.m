function Test_MultiClass_RF(goal, ss)
clc; close all; 
%clear all;
%goal = 'cct';  %'lum', 'cntrst', 'cct', 'sat', 'hue';


disp(sprintf('Test_MultiClass_ss=%.2f_RF. Goal = %s\n', ss, goal));

path = 'G:\My Study\ResearchProject\2011_ImageCompositing\Dataset\Experiments\Manipulated\';
fn = sprintf('%s\\pics.txt', path);       
piclist = textread(fn,'%s','delimiter','\n','whitespace','');

nPic = length(piclist);

%% Set tolerance in statistics of FailRate
sss = 0.3;
switch goal
    case 'lum',
        tol_top  = 3.19 * sss;
        tol_low  = 3.19 * sss;
        tol_mean = 3.19 * sss;
    case 'cct',
        tol_top  = 65.18 * sss;
        tol_low  = 65.18 * sss;
        tol_mean = 65.18 * sss;
        %tol_high = 112.641927 * sss;
    case 'sat',
        tol_top  = 0.993 * sss;
        tol_low  = 0.993 * sss;
        tol_mean = 0.993 * sss;
        %tol_high = 112.641927 * sss;
end
%% Load Model

fn = sprintf('model\\%s_MultiClass_ss=%.2f_RF.mat', goal, ss);   
load( fn );  % 'minPerFeature',  'rangePerFeature', 'model_1', 'model_2', 'model_3'

fn = sprintf('test\\%s_Test_MultiClass_ss=%.2f_RF.txt', goal, ss);
fid = fopen(fn,'wt');


addpath RF_Class_C

h = figure; hold on;

index = 1;

c_offsets = cell(nPic, 1);

%% Start
for p=1:nPic
   picnm = strtrim( piclist{p} );
   disp(sprintf('pic = %s\n', picnm));
   fprintf(fid, 'pic = %s\n', picnm);
   
   c_offsets{p} = zeros(3, 3, 14); % 1~4 input offsets, 5~8 input label, 9~12, predicted label, 13, Final Label Select, 14, input mean offset
   
   %% Test every Manipulated
   for j = [0,1,2]    % background
      for i = [0,1,2]   % foreground
           fn   = sprintf('%s\\%s\\%s\\%d_%d.jpg', path, picnm, goal, i, j);
           oriI = im2double(imread(fn));   % 0 ~ 1.0, 3 channel
           % figure; imshow(oriI);

           %Load original Mask
           fn = sprintf('%s\\%s\\Mask.jpg', path, picnm);
           oriMask = im2double(imread(fn));      % 0~1, 3channel  
           oriMask = oriMask(:,:,1);     % change to a single channel_

           %% Calculate fg/bg features of the input
           [Mask, I_bright, I_lCntrst, I_cct, I_S, I_H] = prepImg_input(oriMask, oriI);
           
           if sum(sum(Mask)) < 2500
                disp('Skip: Too Small Masked object (area<2500)!');
                continue;
           end

           fgbgFeatures = calcFeaturesAfterPrep(Mask, I_bright, I_lCntrst, I_cct, I_S, I_H);

           assignFeatures;
           
           
           %% Feature for learning offset
           selectFeatures;
            
            
           %% Input  Min-offsets and Labels
           setMultiLabel;   % label_1, label_2, label_3, label_4

           if  sum( isnan([Features_Off])) > 0
               disp(sprintf('Warning: there is NaN in Features_Off.\n'));
               fprintf(fid, 'Warning: there is NaN in Features_Off.\n');
               continue;
           end
           
           
           %% Test Data normalization
           X_test = Features_Off;
           minF = repmat(minPerFeature, size(X_test,1),1);  % N x P, N = # observation, P = # features
           X_test = (X_test - minF) * rangePerFeature;

           %% Start classification
           disp(sprintf('f=%d, b=%d\n', i,j));
           fprintf(fid, 'f=%d, b=%d\n', i,j);
           if ~isempty(d1),    
               predLabel_1 = classRF_predict(X_test, model_1);  
               disp(sprintf('Predicted Label 1 = %d\n', predLabel_1));
               fprintf(fid, 'Predicted Label 1 = %d\n', predLabel_1);
           end
           if ~isempty(d2),    
               predLabel_2 = classRF_predict(X_test, model_2);  
               disp(sprintf('Predicted Label 2 = %d\n', predLabel_2));
               fprintf(fid, 'Predicted Label 2 = %d\n', predLabel_2);
           end
           if ~isempty(d3),    
               predLabel_3 = classRF_predict(X_test, model_3);  
               disp(sprintf('Predicted Label 3 = %d\n', predLabel_3));
               fprintf(fid, 'Predicted Label 3 = %d\n', predLabel_3);
           end
           if ~isempty(d4),    
               predLabel_4 = classRF_predict(X_test, model_4);  
               disp(sprintf('Predicted Label 4 = %d\n', predLabel_4));
               fprintf(fid, 'Predicted Label 4 = %d\n', predLabel_4);
           end
           

           
           %% Statistics
           if ~isempty(d1),   c_offsets{p}(i+1, j+1, 1) = d1(index);  end % input offset
           if ~isempty(d2),   c_offsets{p}(i+1, j+1, 2) = d2(index);  end % input offset
           if ~isempty(d3),   c_offsets{p}(i+1, j+1, 3) = d3(index);  end % input offset
           if ~isempty(d4),   c_offsets{p}(i+1, j+1, 4) = d4(index);  end % input offset
           
           if ~isempty(d1),    
                c_offsets{p}(i+1, j+1, 5) = label_1;       % input min-Offset label
                c_offsets{p}(i+1, j+1, 9) = predLabel_1;   % predicted "Labels"
           end
           if ~isempty(d2),    
                c_offsets{p}(i+1, j+1, 6) = label_2;       % input min-Offset label
                c_offsets{p}(i+1, j+1, 10) = predLabel_2;   % predicted "Labels"
           end
           if ~isempty(d3),    
                c_offsets{p}(i+1, j+1, 7) = label_3;       % input min-Offset label
                c_offsets{p}(i+1, j+1, 11) = predLabel_3;   % predicted "Labels"
           end
           if ~isempty(d4),    
                c_offsets{p}(i+1, j+1, 8) = label_4;       % input min-Offset label
                c_offsets{p}(i+1, j+1, 12) = predLabel_4;   % predicted "Labels"
           end
           
           switch goal,                             %input "mean offset"        
               case 'lum',      c_offsets{p}(i+1, j+1, 14) = lum_mean_F - lum_mean_B;   
               case 'cntrst',   c_offsets{p}(i+1, j+1, 14) = cntrst_top_F - cntrst_top_B;
               case 'cct',      c_offsets{p}(i+1, j+1, 14) = cct_mean_F - cct_mean_B;   
               case 'sat',      c_offsets{p}(i+1, j+1, 14) = sat_mean_F - sat_mean_B;   
               case 'hue',      c_offsets{p}(i+1, j+1, 14) = hue_mean_F - hue_mean_B;   
           end
          
           
           %% Plot
           if i == j
               r1 = 20; r2 = 10;
           else
               r1 = 10; r2 = 5;
           end
           
            if ~isempty(d1), 
                plot(index, d1(index), 'r.', 'MarkerSize', r1); 
                if predLabel_1, plot(index, d1(index), 'ro', 'MarkerSize', r2);  end; 
            end
            if ~isempty(d2), 
                plot(index, d2(index), 'g.', 'MarkerSize', r1); 
                if predLabel_2, plot(index, d2(index), 'go', 'MarkerSize', r2);  end; 
            end
            if ~isempty(d3), 
                plot(index, d3(index), 'b.', 'MarkerSize', r1); 
                if predLabel_3, plot(index, d3(index), 'bo', 'MarkerSize', r2);  end; 
            end
            if ~isempty(d4), 
                plot(index, d4(index), 'c.', 'MarkerSize', r1);
                if predLabel_4, plot(index, d4(index), 'co', 'MarkerSize', r2);  end; 
            end

           
           %% Real Adjustment
           findBestLabel;  % Output: bestOpt, minCost
           
           c_offsets{p}(i+1, j+1, 13) = bestOpt;
           
           % Prediction
%            shift_f = 0 - bestOff;   % the predicted minOffset
%            outI = manipulateFeature(goal, oriI, oriMask, shift_f, 0);
%            fn   = sprintf('%s\\%s\\%s\\multiCls_RF\\%d_%d.jpg', path, picnm, goal, i, j);
%            imwrite( outI, fn, 'jpg');
           
           %% Increment index
           index = index + 1;
       end
   end
   
end % for p=1:nPic

xlim([1, index]);
title('Input min-Offset vs. Predicted');
saveas(h, sprintf('test\\%s_Test_MultiClass_ss=%.2f_RF.jpg', goal, ss) );


%% Calc Statistics

% Prediction error
sumErrByMean = 0;   % error metric by mean
sumErr = 0;          % error metric by original offset    
failCnt = 0;
errCnt_1 = 0;
errCnt_2 = 0;
errCnt_3 = 0;
errCnt_4 = 0;
for p=1:nPic
     for j=1:3  % bg
         realLabel_1 = c_offsets{p}(j,j, 5);  %ground truth label for a certain bg
         realLabel_2 = c_offsets{p}(j,j, 6);  %ground truth label for a certain bg
         realLabel_3 = c_offsets{p}(j,j, 7);  %ground truth label for a certain bg
         realLabel_4 = c_offsets{p}(j,j, 8);  %ground truth label for a certain bg
         for i=1:3  % fg
             predLabel_1 = c_offsets{p}(i,j,9);    
             predLabel_2 = c_offsets{p}(i,j,10);    
             predLabel_3 = c_offsets{p}(i,j,11);    
             predLabel_4 = c_offsets{p}(i,j,12);    
             if ~isempty(predLabel_1), if predLabel_1 ~= realLabel_1,  errCnt_1 = errCnt_1 + 1;       end; end;
             if ~isempty(predLabel_2), if predLabel_2 ~= realLabel_2,  errCnt_2 = errCnt_2 + 1;       end; end;
             if ~isempty(predLabel_3), if predLabel_3 ~= realLabel_3,  errCnt_3 = errCnt_3 + 1;       end; end;
             if ~isempty(predLabel_4), if predLabel_4 ~= realLabel_4,  errCnt_4 = errCnt_4 + 1;       end; end;
             
             pred_label  = c_offsets{p}(i,j,13);        %predicted label
             pred_off    = c_offsets{p}(i, j, pred_label);  % input offset of the predicted label
             mean_off_input = c_offsets{p}(i,j,14);
             mean_off_truth = c_offsets{p}(j,j,14);  
             
             off_truth = c_offsets{p}(j,j,pred_label);  
             
             if  ~isempty( strfind(goal, 'hue') ) %goal for hue
                errByMean = hueDist(mean_off_input+(0-pred_off), mean_off_truth);
             else
                errByMean = abs( mean_off_input+(0-pred_off) - mean_off_truth );
             end
             sumErrByMean = sumErrByMean + errByMean; 
             
             if  ~isempty( strfind(goal, 'hue') ) %goal for hue
                err = hueDist(0, off_truth);
             else
                err = abs( 0 - off_truth );
             end
             sumErr = sumErr + err; 
             
              % failure rate
             if errByMean > tol_mean;  % cnt of wrong predicted results
                failCnt = failCnt + 1;   
             end
             
         end %fg
     end     %bg
end % for pic
errRate_1 = errCnt_1 / (nPic*9);
errRate_2 = errCnt_2 / (nPic*9);
errRate_3 = errCnt_3 / (nPic*9);
errRate_4 = errCnt_4 / (nPic*9);

sumErrByMean = sumErrByMean / (nPic*9);
sumErr = sumErr / (nPic*9);
%disp(sprintf('Exact minOffset error = %f\n', sumMinErr));
%fprintf(fid, 'Exact minOffset error = %f\n', sumMinErr);

failRate = failCnt / (nPic*9);

disp(sprintf('Error Rate 1=%f, E-R 2= %f, E-R 3=%f, E-R 4 = %f, \n  Prediction errorByMean = %f, error = %f, failRate = %f\n',  ...
              errRate_1, errRate_2, errRate_3, errRate_4, sumErrByMean, sumErr, failRate));
fprintf(fid,'Error Rate 1=%f, E-R 2= %f, E-R 3=%f, E-R 4 = %f, \n  Prediction errorByMean = %f, error = %f, failRate = %f\n',  ...
              errRate_1, errRate_2, errRate_3, errRate_4, sumErrByMean, sumErr, failRate);

fclose(fid);

rmpath  RF_Class_C