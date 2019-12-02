function Offset_Reg_glm(goal, region)
close all; clc; 
%clear all;

load ('data\\cell_compositing_all.mat');   % load cell_compositing_all

nComp     = length(cell_compositing_all);

%goal = 'lum';   % 'lum', 'cntrst', 'cct', 'sat', 'hue'

%region = 'mean';  % 'top', 'low', 'mean', 'high'

disp(sprintf('Reg glm. Goal = %s, region = %s', goal, region));

%% Load data
loadData_reg;


%% Baseline
fn = sprintf('img\\%s_%s_Offset_Reg_glm.txt', goal, region);
fid = fopen(fn,'wt');

error_zero = mean( abs(p) );
disp(sprintf('0-matching mean error = %f', error_zero));
fprintf(fid, '0-matching mean error = %f\n', error_zero);

%% Data normalization
% Scale the data into [0, 1]
minPerFeature   = min(X,[],1);      % 1 x P.   P = # features
rangePerFeature = spdiags(1./(max(X,[],1)-min(X,[],1))',0,size(X,2),size(X,2));   % diag( P )

X = (X - repmat(min(X,[],1),size(X,1),1)) * spdiags(1./(max(X,[],1)-min(X,[],1))',0,size(X,2),size(X,2));



%% Fitting 
% Genearl Linear Model
if  ~isempty( strfind(goal, 'hue') ) %goal for hue
    [coef_c, dev, stats] = glmfit(X, p_c, 'normal', 'link', 'identity', 'constant', 'on');
    [coef_s, dev, stats] = glmfit(X, p_s, 'normal', 'link', 'identity', 'constant', 'on');
    save(sprintf('model\\%s_%s_Offset_GLM.mat', goal, region), 'minPerFeature',  'rangePerFeature', 'coef_c', 'coef_s');
    
    % Results
    predicted_c = [ones(length(p_c),1), X] * coef_c;
    predicted_c = max(min(predicted_c,1), -1);
    predicted_s = [ones(length(p_s),1), X] * coef_s;
    predicted_s = max(min(predicted_s,1), -1);
    predicted   = cossin2hue(predicted_c, predicted_s);
else
    [coef, dev, stats] = glmfit(X, p, 'normal', 'link', 'identity', 'constant', 'on');
    %coef = pinv([ones(length(p),1), X]) * p;
    save(sprintf('model\\%s_%s_Offset_GLM.mat', goal, region), 'minPerFeature',  'rangePerFeature', 'coef');
    
    predicted = [ones(length(p),1), X] * coef;
end


% Fitting Goodness
h = figure; hold on;
plot(p, 'r.', 'MarkerSize', 10); 
plot(predicted, 'b.', 'MarkerSize', 10); 
xlim([1,length(p)]);
legend('Real Offset', 'Predicted by Fitting');
title('Fitting Offset');  %— Vector of residuals
saveas(h, sprintf('img\\%s_%s_Offset_GLM_Fitting.jpg', goal, region) );

if  ~isempty( strfind(goal, 'hue') ) %goal for hue
    error_predicted = mean( hueDist(p, predicted) );
else
    error_predicted = mean( abs(p-predicted) );
end
disp(sprintf('Fitting mean error = %f', error_predicted));
fprintf(fid, 'Fitting mean error = %f\n', error_predicted);

% % R^2
% res  = p-predicted;
% RSS  = sum(res.*res);
% tss =  p - mean(p);
% TSS  = sum(tss.*tss);
% R_sqr = 1 - RSS/TSS;          % R square
% disp(sprintf('Fitting R_sqr = %f', R_sqr));



%% k-fold Cross Validation

nFold = 10;
predicted = zeros(size(p));
[N D] = size(X);
randvector =  randperm(N);  % [1:N];  %
for i=1:nFold
    s = floor( N/nFold * (i-1) );
    s = min(max(s,1), N);
    t = floor( N/nFold * i  );
    t = min(max(t,1), N);    %disp(sprintf('s=%d, t=%d\n', s, t));
   %disp(sprintf('s=%d, t=%d\n', s, t));
    X_tst = X(randvector(s:t),:);       % 1/nFold
    p_tst = p(randvector(s:t),:);
    X_trn = X( [randvector(1:(s-1)), randvector((t+1):end)],:); % 1-1/nFold
    p_trn = p( [randvector(1:(s-1)), randvector((t+1):end)],:);

    if  ~isempty( strfind(goal, 'hue') ) %goal for hue
        p_trn_c = p_c( [randvector(1:(s-1)), randvector((t+1):end)],:);
        [coef_c, dev, stats] = glmfit(X_trn, p_trn_c, 'normal', 'link', 'identity', 'constant', 'on');
        predicted_c = [ones(length(p_tst), 1), X_tst] * coef_c;
        predicted_c = max(min(predicted_c,1), -1);
        
        p_trn_s = p_s( [randvector(1:(s-1)), randvector((t+1):end)],:);
        [coef_s, dev, stats] = glmfit(X_trn, p_trn_s, 'normal', 'link', 'identity', 'constant', 'on');
        predicted_s = [ones(length(p_tst), 1), X_tst] * coef_s;
        predicted_s = max(min(predicted_s,1), -1);
        
        predicted(randvector(s:t)) = cossin2hue(predicted_c, predicted_s);
    else
        [coef, dev, stats] = glmfit(X_trn, p_trn, 'normal', 'link', 'identity', 'constant', 'on');
        %coef = pinv([ones(length(p_trn),1), X_trn]) * p_trn;
        predicted(randvector(s:t)) = [ones(length(p_tst), 1), X_tst] * coef;
    end

    
end

h1 = figure; hold on;
plot(p, 'r.', 'MarkerSize', 10); 
plot(predicted, 'b.', 'MarkerSize', 10); 
xlim([1, length(p)]);
legend('Real Offset', 'Predicted by CV');
title('CV Sigma');  %— Vector of residuals
saveas(h1, sprintf('img\\%s_%s_Offset_GLM_CV.jpg', goal, region) );

if  ~isempty( strfind(goal, 'hue') ) %goal for hue
    error_predicted = mean( hueDist(p, predicted) );
else
    error_predicted = mean( abs(p-predicted) );
end
disp(sprintf('CV mean error = %f', error_predicted));
fprintf(fid,'CV mean error = %f\n', error_predicted);

fclose(fid);


% % R^2
% res = predicted - p;
% RSS  = sum(res.*res);
% tss =  p - mean(p);
% TSS  = sum(tss.*tss);
% R_sqr = 1 - RSS/TSS;          % R square
% disp(sprintf('CV R_sqr = %f', R_sqr));




%% Predict on MTurk Experimental Data
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
%          Features_Off =  [std_F, ...
%                         gCntrst_F, lCntrst_largest_F, lCntrst_mean_F, ...
%                         harshDrop_F, highPortion_F, ...
%                         cct_high_F, cct_shdw_F, ...
%                         cct_mean_warmest_F, cct_mean_coldest_F, cct_F, ...
%                         cct_std_F, cct_entropy_F, ...
%                         cct_gCntrst_F, cct_lCntrst_largest_F, cct_lCntrst_mean_F, ...    % Forground
%                         ...
%                         std_B, ...
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
% [coef, dev, stats] = glmfit(X, p, 'normal', 'link', 'identity', 'constant', 'on');
% 
% predicted = [ones(length(p_sti), 1), X_sti] * coef;
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
% saveas(h3, sprintf('img\\Offset_glmRgr_Predict_Stimuli.jpg') );
% 
% res  = p_sti-predicted;
% RSS  = sum(res.*res);
% tss =  p_sti - mean(p_sti);
% TSS  = sum(tss.*tss);
% R_sqr = 1 - RSS/TSS;          % R square
% disp(sprintf('Predict Stimuli R_sqr = %f', R_sqr));
