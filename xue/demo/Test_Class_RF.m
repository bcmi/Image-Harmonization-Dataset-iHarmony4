function Test_Class_RF(goal)
clc; close all; 
%clear all;


%goal = 'lum'; %'lum', 'cntrst', 'cct', 'sat', 'hue';

disp(sprintf('Test_Class_RF. Goal = %s\n', goal));

path = 'G:\My Study\ResearchProject\2011_ImageCompositing\Dataset\Experiments\Manipulated\';
fn = sprintf('%s\\pics.txt', path);       
piclist = textread(fn,'%s','delimiter','\n','whitespace','');

nPic = length(piclist);

%% Set tolerance
sss = 0.3;
switch goal
    case 'lum',
        tol_top   = 2.500196 * sss;
        tol_low   =  3.138705  * sss;
        tol_mean = 3.344171 * sss;
    case 'cct',
        %aveSig_top=83.252058, aveSig_low=105.318797, aveSig_mean=94.340061, aveSig_high=112.641927
        tol_top  = 83.252058 * sss;
        tol_low  = 105.318797  * sss;
        tol_mean = 94.340061 * sss;
        %tol_high = 112.641927 * sss;
end


%% Load Model
fn = sprintf('model\\%s_Class_RF.mat', goal);   
load( fn );  % 'minPerFeature',  'rangePerFeature', 'model'

fn = sprintf('test\\%s_Test_Class_RF.txt', goal);
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
   
   c_offsets{p} = zeros(3, 3, 7); % 1~4 input offsets, 5 input label, 6, predicted label, 7, input mean offset
   
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
           predicted = classRF_predict(X_test, model);   %predicted label
           disp(sprintf('f=%d, b=%d, Predicted Label = %d\n', i,j, predicted));
           fprintf(fid, 'f=%d, b=%d, Predicted Label = %d\n', i,j, predicted);
                      
           
           %% Statistics
           if ~isempty(d1),   c_offsets{p}(i+1, j+1, 1) = d1(index);  end % input offset
           if ~isempty(d2),   c_offsets{p}(i+1, j+1, 2) = d2(index);  end % input offset
           if ~isempty(d3),   c_offsets{p}(i+1, j+1, 3) = d3(index);  end % input offset
           if ~isempty(d4),   c_offsets{p}(i+1, j+1, 4) = d4(index);  end % input offset
           c_offsets{p}(i+1, j+1, 5) = label;       % input min-Offset label
           c_offsets{p}(i+1, j+1, 6) = predicted;   % predicted "Labels"
           switch goal,                             %input "mean offset"        
               case 'lum',      c_offsets{p}(i+1, j+1, 7) = lum_mean_F - lum_mean_B;   
               case 'cntrst',   c_offsets{p}(i+1, j+1, 7) = cntrst_top_F - cntrst_top_B;
               case 'cct',      c_offsets{p}(i+1, j+1, 7) = cct_mean_F - cct_mean_B;   
               case 'sat',      c_offsets{p}(i+1, j+1, 7) = sat_mean_F - sat_mean_B;   
               case 'hue',      c_offsets{p}(i+1, j+1, 7) = hue_mean_F - hue_mean_B;   
           end
          
           
           %% Plot
           switch predicted
                case 1, ccp = 'r';  dp = d1(index);   %predicted input offset should be changed
                case 2, ccp = 'g';  dp = d2(index);
                case 3, ccp = 'b';  dp = d3(index);
                case 4, ccp = 'c';  dp = d4(index);
           end
            
           if i == j
                if ~isempty(d1), plot(index, d1(index), 'r.', 'MarkerSize', 30); end
                if ~isempty(d2), plot(index, d2(index), 'g.', 'MarkerSize', 30); end
                if ~isempty(d3), plot(index, d3(index), 'b.', 'MarkerSize', 30); end
                if ~isempty(d4), plot(index, d4(index), 'c.', 'MarkerSize', 30); end
                plot(index, 0, [ccp,'o'], 'MarkerSize', 10); 
           else
                plot(index, dp, [ccp, '.'], 'MarkerSize', 20); 
                %plot(index, 0,  [ccp,'o'], 'MarkerSize', 7); 
           end
           
           %% Real Adjustment
           % Prediction
%            shift_f = 0 - dp;   % dp is predicted minOffset
%            outI = manipulateFeature(goal, oriI, oriMask, shift_f, 0);
%            fn   = sprintf('%s\\%s\\%s\\cls_RF\\%d_%d.jpg', path, picnm, goal, i, j);
%            imwrite( outI, fn, 'jpg');
           
           %% Increment index
           index = index + 1;
       end
   end
   
end % for p=1:nPic

xlim([1, index]);
title('Input min-Offset vs. Predicted');
saveas(h, sprintf('test\\%s_Test_Class_RF.jpg', goal) );


%% Calc Statistics

% Prediction error
sumMinErr = 0;  
sumErr = 0;
errCnt = 0;
failCnt = 0;   
for p=1:nPic
     for j=1:3  % bg
         realLabel = c_offsets{p}(j,j, 5);  %ground truth label for a certain bg
         mean_off_truth = c_offsets{p}(j, j, 7);  % mean offset of the ground truth (diagonal)
         for i=1:3  % fg
             predicted = c_offsets{p}(i,j,6);    
             if predicted ~= realLabel
                 errCnt = errCnt + 1;
             end;
             off = c_offsets{p}(i, j, predicted);     % predicted offset to shift
             if  ~isempty( strfind(goal, 'hue') ) %goal for hue
                err = hueDist( c_offsets{p}(i, j, 7)+(0-off),  mean_off_truth );
             else
                err = abs( c_offsets{p}(i, j, 7)+(0-off) - mean_off_truth );
             end
             sumErr = sumErr + err; 
             
             %baseline
             minOff    = c_offsets{p}(i,j, realLabel);  % offset of ground truth label
             if  ~isempty( strfind(goal, 'hue') ) %goal for hue
                 err1 = hueDist( c_offsets{p}(i, j, 7)+(0-minOff), mean_off_truth );
             else
                 err1 = abs( c_offsets{p}(i, j, 7)+(0-minOff) - mean_off_truth );
             end;
                 
             sumMinErr = sumMinErr + err1;
             
             % failure rate
             cnt = abs( c_offsets{p}(i, j, 7)+(0-off) - mean_off_truth ) > tol_mean;  % cnt of wrong predicted results
             failCnt = failCnt + cnt;   
         end
     end
end
errRate = errCnt / (nPic*9);
sumErr = sumErr / (nPic*9);
sumMinErr = sumMinErr / (nPic*9);
failRate = failCnt / (nPic*9);

disp(sprintf('Exact minOffset error = %f\n', sumMinErr));
fprintf(fid, 'Exact minOffset error = %f\n', sumMinErr);

disp(sprintf('Error Rate=%f, Prediction error = %f, failure rate = %f\n', errRate, sumErr, failRate));
fprintf(fid, 'Error Rate=%f, Prediction error = %f, failure rate = %f\n', errRate, sumErr, failRate);


fclose(fid);

rmpath  RF_Class_C