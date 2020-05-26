function Test_Reg_SVR(goal, region)
clc; close all;  
%clear all;


%goal = 'cct'; %'lum', 'cntrst', 'cct', 'sat', 'hue';

%region = 'top'; % 'top', 'low', 'mean', 'high'

disp(sprintf('Test_Reg_SVR. Goal = %s, region = %s\n', goal, region));

path = 'G:\My Study\ResearchProject\2011_ImageCompositing\Dataset\Experiments\Manipulated\';
fn = sprintf('%s\\pics.txt', path);       
piclist = textread(fn,'%s','delimiter','\n','whitespace','');

nPic = length(piclist);


%% Load Model
addpath libsvm-3.1\windows
fn = sprintf('model\\%s_%s_Offset_SVR.mat', goal, region);
load( fn );  % 'minPerFeature',  'rangePerFeature', 'model' ('model_c','model_s');

fn = sprintf('test\\%s_%s_Test_Reg_SVR.txt', goal, region);
fid = fopen(fn,'wt');

h = figure; hold on;

index = 1;

c_offsets = cell(nPic, 1);

%% Start
for p=1:nPic
   picnm = strtrim( piclist{p} );
   disp(sprintf('pic = %s\n', picnm));
   fprintf(fid, 'pic = %s\n', picnm);
   
   c_offsets{p} = zeros(3, 3, 3);
   
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
            
            
           %% Input Offset
           setOffset;
           
           disp(sprintf('f=%d, b=%d, Input Offset = %f\n', i, j, offset));
           fprintf(fid, 'f=%d, b=%d, Input Offset = %f\n', i, j, offset);
           
           
           %% Test Data normalization
           X_test = Features_Off;
           minF = repmat(minPerFeature, size(X_test,1),1);  % N x P, N = # observation, P = # features
           X_test = (X_test - minF) * rangePerFeature;

           
           %% Prediction 
           if  ~isempty( strfind(goal, 'hue') ) %goal for hue
                [predicted_c, accuracy, decision_values] = svmpredict(offset, X_test, model_c);
                predicted_c = max(min(predicted_c,1), -1);

                [predicted_s, accuracy, decision_values] = svmpredict(offset, X_test, model_s);
                predicted_s = max(min(predicted_s,1), -1);

                predicted = cossin2hue(predicted_c, predicted_s);
                if predicted>0.5,
                        predicted = predicted -1;
                elseif predicted<-0.5,
                        predicted = predicted + 1;
                end;
           else
                [predicted, accuracy, decision_values] = svmpredict(offset, X_test, model);
           end
           disp(sprintf('Predicted Offset = %f\n', predicted));
           fprintf(fid, 'Predicted Offset = %f\n', predicted);
           
           
           %% Statistics
           c_offsets{p}(i+1, j+1, 1) = offset;   % input
           c_offsets{p}(i+1, j+1, 2) = predicted;   % predicted
           switch goal,                             %input "mean offset"        
               case 'lum',      c_offsets{p}(i+1, j+1, 3) = lum_mean_F - lum_mean_B;   
               case 'cntrst',   c_offsets{p}(i+1, j+1, 3) = cntrst_top_F - cntrst_top_B;
               case 'cct',      c_offsets{p}(i+1, j+1, 3) = cct_mean_F - cct_mean_B;   
               case 'sat',      c_offsets{p}(i+1, j+1, 3) = sat_mean_F - sat_mean_B;   
               case 'hue',      c_offsets{p}(i+1, j+1, 3) = hue_mean_F - hue_mean_B;   
           end
           
           %% Plot
           if i == j
                plot(index, offset, 'r.', 'MarkerSize', 30); 
                plot(index, predicted, 'b.', 'MarkerSize', 30); 
           else
                plot(index, offset, 'r.', 'MarkerSize', 15); 
                plot(index, predicted, 'b.', 'MarkerSize', 15); 
           end
           
           %% Real Adjustment
           % Baseline: zero-mean
%            shift_f = 0 - offset;
%            outI = manipulateFeature(goal, oriI, oriMask, shift_f, 0);
%            fn   = sprintf('%s\\%s\\%s\\zero\\%s_%d_%d.jpg', path, picnm, goal, region, i, j);
%            imwrite( outI, fn, 'jpg');
%            
%            % Prediction
%            shift_f = predicted - offset;
%            outI = manipulateFeature(goal, oriI, oriMask, shift_f, 0);
%            fn   = sprintf('%s\\%s\\%s\\reg_SVR\\%s_%d_%d.jpg', path, picnm, goal, region, i, j);
%            imwrite( outI, fn, 'jpg');
           
           %% Increment index
           index = index + 1;
       end
   end
   
end % for p=1:nPic

xlim([1, index]);
title('Input Offset vs. Predicted');
saveas(h, sprintf('test\\%s_%s_Test_Reg_SVR.jpg', goal, region) );


%% Calc Statistics

% Baseline zero-mean error
sumErr = 0;
for p=1:nPic
     a = c_offsets{p}(:, :, 1);   % input offset
     b = zeros(size(a));          % predicted offset, 0 for zero matching
     c = c_offsets{p}(:, :, 3);   % input mean offset
     if  ~isempty( strfind(goal, 'hue') ) %goal for hue
        err = mean(mean(hueDist(c+(b-a), repmat(diag(c)',3,1) )));  
     else
        err = mean(mean(abs( c+(b-a) - repmat(diag(c)',3,1) )));   % repmat(...): diagonal composites
     end
     sumErr = sumErr + err; 
end
sumErr = sumErr / nPic;
disp(sprintf('0-matching error= %f\n', sumErr));
fprintf(fid, '0-matching error= %f\n', sumErr);


% Prediction error
sumErr = 0;
for p=1:nPic
     a = c_offsets{p}(:, :, 1);   % input
     b = c_offsets{p}(:, :, 2);   % predicted
     c = c_offsets{p}(:, :, 3);   % input mean offset
     if  ~isempty( strfind(goal, 'hue') ) %goal for hue
        err = mean(mean(hueDist(c+(b-a), repmat(diag(c)',3,1) )));  
     else
        err = mean(mean(abs( c+(b-a) - repmat(diag(c)',3,1) )));   % repmat(...): diagonal composites
     end
     sumErr = sumErr + err; 
end
sumErr = sumErr / nPic;
disp(sprintf('Prediction error = %f\n', sumErr));
fprintf(fid, 'Prediction error = %f\n', sumErr);

fclose(fid);

rmpath  libsvm-3.1\windows