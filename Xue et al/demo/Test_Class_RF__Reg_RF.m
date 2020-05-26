function Test_Class_RF__Reg_RF(goal)
close all; clc; 
%clear all;

%goal = 'cct'; %'lum', 'cntrst', 'cct', 'sat', 'hue';

disp(sprintf('Test_Class_RF__Reg_RF. Goal = %s\n', goal));

path = 'G:\My Study\ResearchProject\2011_ImageCompositing\Dataset\Experiments\Manipulated\';
fn = sprintf('%s\\pics.txt', path);       
piclist = textread(fn,'%s','delimiter','\n','whitespace','');

nPic = length(piclist);
%nPic = 2;


%% Load Models

% Classification
addpath RF_Class_C

fn = sprintf('model\\%s_Class_RF.mat', goal);   

load( fn );  % 'minPerFeature',  'rangePerFeature', 'model'
model_class_RF = model;
clear model;

% Regression
addpath RF_Reg_C

fn = sprintf('test\\%s_Test_Class_RF__Reg_RF.txt', goal);
fid = fopen(fn,'wt');


h = figure; hold on;

index = 1;

c_offsets = cell(nPic, 1);

%% Start
for p=1:nPic
   picnm = strtrim( piclist{p} );
   disp(sprintf('pic = %s\n', picnm));
   fprintf(fid, 'pic = %s\n', picnm);
   
   c_offsets{p} = zeros(3, 3, 8); % 1~4 input offsets, 5 input label, 6, predicted label, 7: predicted offset, 8, input mean offset
   
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
           setLabel;

           if  sum( isnan([Features_Off, label'])) > 0
                disp(sprintf('Warning: there is NaN in Features_Off or label.\n'));
                fprintf(fid, 'Warning: there is NaN in Features_Off or label.\n');
                continue;
           end
           
           %% Test Data normalization
           X_test = Features_Off;
           minF = repmat(minPerFeature, size(X_test,1),1);  % N x P, N = # observation, P = # features
           X_test = (X_test - minF) * rangePerFeature;

           
           %% Start classification
           pred_label = classRF_predict(X_test, model_class_RF);   %predicted label
           disp(sprintf('f=%d, b=%d, Predicted Label = %d\n', i,j, pred_label));
           fprintf(fid, 'f=%d, b=%d, Predicted Label = %d\n', i,j, pred_label);
           
           %% Start Regression
           switch goal
                case 'lum',
                       switch pred_label
                           case 1,  region = 'top';
                           case 2,  region = 'low';
                           case 3,  region = 'mean';
                       end
                case 'cntrst',
                       switch pred_label
                           case 1,  region = 'top';
                           case 2,  region = 'mean';
                       end
               case 'cct',
                       switch pred_label
                           case 1,  region = 'top';
                           case 2,  region = 'low';
                           case 3,  region = 'mean';
                           case 4,  region = 'high';
                       end
              case 'sat',
                       switch pred_label
                           case 1,  region = 'top';
                           case 2,  region = 'low';
                           case 3,  region = 'mean';
                       end
              case 'hue',
                       switch pred_label
                           case 1,  region = 'high';
                           case 2,  region = 'mean';
                       end
           end
           fn = sprintf('model\\%s_%s_Offset_RF.mat', goal, region);
           load( fn );  % 'minPerFeature',  'rangePerFeature', 'model' ('model_c','model_s');
           if  ~isempty( strfind(goal, 'hue') ) %goal for hue
                model_reg_RF_c = model_c;
                model_reg_RF_s = model_s;
                clear model_c; clear model_s;
                
                predicted_c = regRF_predict(X_test, model_reg_RF_c);
                predicted_c = max(min(predicted_c,1), -1);

                predicted_s = regRF_predict(X_test, model_reg_RF_s);
                predicted_s = max(min(predicted_s,1), -1);

                predicted = cossin2hue(predicted_c, predicted_s);
                if predicted>0.5,
                        predicted = predicted -1;
                elseif predicted<-0.5,
                        predicted = predicted + 1;
                end;
           else
                model_reg_RF = model;
                clear model;
                
                predicted = regRF_predict(X_test, model_reg_RF);
           end
                      
           
           %% Statistics
           if ~isempty(d1),   c_offsets{p}(i+1, j+1, 1) = d1(index);  end % input offset
           if ~isempty(d2),   c_offsets{p}(i+1, j+1, 2) = d2(index);  end % input offset
           if ~isempty(d3),   c_offsets{p}(i+1, j+1, 3) = d3(index);  end % input offset
           if ~isempty(d4),   c_offsets{p}(i+1, j+1, 4) = d4(index);  end % input offset
           c_offsets{p}(i+1, j+1, 5) = label;       % input min-Offset label
           c_offsets{p}(i+1, j+1, 6) = pred_label;   % predicted "Labels"
           c_offsets{p}(i+1, j+1, 7) = predicted;   % predicted offset
           switch goal,                             %input "mean offset"        
               case 'lum',      c_offsets{p}(i+1, j+1, 8) = lum_mean_F - lum_mean_B;   
               case 'cntrst',   c_offsets{p}(i+1, j+1, 8) = cntrst_top_F - cntrst_top_B;
               case 'cct',      c_offsets{p}(i+1, j+1, 8) = cct_mean_F - cct_mean_B;   
               case 'sat',      c_offsets{p}(i+1, j+1, 8) = sat_mean_F - sat_mean_B;   
               case 'hue',      c_offsets{p}(i+1, j+1, 8) = hue_mean_F - hue_mean_B;   
           end
           
           %% Plot
           switch pred_label
                case 1, ccp = 'r';  dp = d1(index);   %predicted input offset should be changed
                case 2, ccp = 'g';  dp = d2(index);
                case 3, ccp = 'b';  dp = d3(index);
                case 4, ccp = 'c';  dp = d4(index);
           end
            
           if i == j  % ground truth for a given background (say, b=2, f=2)
                if ~isempty(d1), plot(index, d1, 'r.', 'MarkerSize', 30); end
                if ~isempty(d2), plot(index, d2, 'g.', 'MarkerSize', 30); end
                if ~isempty(d3), plot(index, d3, 'b.', 'MarkerSize', 30); end
                if ~isempty(d4), plot(index, d4, 'c.', 'MarkerSize', 30); end
                plot(index, predicted, [ccp,'o'], 'MarkerSize', 10); 
           else
                plot(index, dp, [ccp, '.'], 'MarkerSize', 20); 
                plot(index, predicted,  [ccp,'o'], 'MarkerSize', 7); 
           end
           
           %% Real Adjustment
           % Prediction
%            shift_f = predicted - dp;   % dp is the input minOffset of the predicted label
%            outI = manipulateFeature(goal, oriI, oriMask, shift_f, 0);
%            fn   = sprintf('%s\\%s\\%s\\cls_RF+reg_RF\\%d_%d.jpg', path, picnm, goal, i, j);
%            imwrite( outI, fn, 'jpg');
           
           %% Increment index
           index = index + 1;
       end
   end
   
end % for p=1:nPic

xlim([1, index]);
title('Input min-Offset vs. Predicted');
saveas(h, sprintf('test\\%s_Test_Class_RF+Reg_RF.jpg', goal) );


%% Calc Statistics

% Prediction error
sumErr = 0;
errCnt = 0;
for p=1:nPic
     for j=1:3  % bg
         realLabel = c_offsets{p}(j,j, 5);  %ground truth label for a certain bg j
         for i=1:3  % fg
             pred_label = c_offsets{p}(i,j,6);    
             if pred_label ~= realLabel
                 errCnt = errCnt + 1;
             end;
             input_mean_off = c_offsets{p}(i, j, 8);
             mean_off_truth = c_offsets{p}(j, j, 8);  % mean offset of the ground truth (diagonal)
             input_off = c_offsets{p}(i, j, pred_label);          %predicted offset of predicted label
             pred_off  = c_offsets{p}(i, j, 7);          %predicted offset of predicted label
             if  ~isempty( strfind(goal, 'hue') ) %goal for hue
                err = hueDist( input_mean_off+(pred_off-input_off), mean_off_truth);  
             else
                err = abs( input_mean_off+(pred_off-input_off) - mean_off_truth );
             end
             sumErr = sumErr + err; 
         end
     end
end
errRate = errCnt / (nPic*9);
sumErr = sumErr / (nPic*9);
disp(sprintf('Error Rate=%f, Prediction error = %f\n', errRate, sumErr));
fprintf(fid, 'Error Rate=%f, Prediction error = %f\n', errRate, sumErr);
 

fclose(fid);

rmpath  RF_Reg_C
rmpath  RF_Class_C