function Offset_Reg_RF(goal, region)
close all; clc; 
%clear all;

load ('data\\cell_compositing_all.mat');   % load cell_compositing_all

nComp     = length(cell_compositing_all);

%goal = 'lum';   % 'lum', 'cntrst', 'cct', 'sat', 'hue'

%region = 'mean';  % 'top', 'low', 'mean', 'high'

disp(sprintf('Reg RF. Goal = %s, region = %s', goal, region));

%% Load data
loadData_reg;


%% Baseline
fn = sprintf('img\\%s_%s_Offset_Reg_RF.txt', goal, region);
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
addpath RF_Reg_C



clear extra_options
extra_options.importance = 1; %(0 = (Default) Don't, 1=calculate)

ntree = 0;    %default 500
mtry  = 0;    %default floor(sqrt(size(X,2)))

% Genearl Linear Model
if  ~isempty( strfind(goal, 'hue') ) %goal for hue
    model_c = regRF_train(X, p_c, ntree, mtry, extra_options);
    model_s = regRF_train(X, p_s, ntree, mtry, extra_options);
    save(sprintf('model\\%s_%s_Offset_RF.mat', goal, region), 'minPerFeature',  'rangePerFeature', 'model_c', 'model_s');
    
    predicted_c = regRF_predict(X, model_c);
    predicted_c = max(min(predicted_c,1), -1);
    predicted_s = regRF_predict(X, model_s);
    predicted_s = max(min(predicted_s,1), -1);
    predicted   = cossin2hue(predicted_c, predicted_s);
else
    model = regRF_train(X, p, ntree, mtry, extra_options);
    save(sprintf('model\\%s_%s_Offset_RF.mat', goal, region), 'minPerFeature',  'rangePerFeature', 'model');
    
    predicted = regRF_predict(X, model);
end


% Fitting Goodness
h = figure; hold on;
plot(p, 'r.', 'MarkerSize', 10); 
plot(predicted, 'b.', 'MarkerSize', 10); 
xlim([1,length(p)]);
legend('Real Offset', 'Predicted by Fitting');
title('Fitting Offset');  %— Vector of residuals
saveas(h, sprintf('img\\%s_%s_Offset_RF_Fitting.jpg', goal, region) );

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
        model_c = regRF_train(X_trn, p_trn_c, ntree, mtry, extra_options);
        predicted_c = regRF_predict(X_tst, model_c);
        predicted_c = max(min(predicted_c,1), -1);
        
        p_trn_s = p_s( [randvector(1:(s-1)), randvector((t+1):end)],:);
        model_s = regRF_train(X_trn, p_trn_s, ntree, mtry, extra_options);
        predicted_s = regRF_predict(X_tst, model_s);
        predicted_s = max(min(predicted_s,1), -1);
        
        predicted(randvector(s:t)) = cossin2hue(predicted_c, predicted_s);
    else
        model = regRF_train(X_trn, p_trn, ntree, mtry, extra_options);
        predicted(randvector(s:t)) = regRF_predict(X_tst, model);
    end

    
end

h1 = figure; hold on;
plot(p, 'r.', 'MarkerSize', 10); 
plot(predicted, 'b.', 'MarkerSize', 10); 
xlim([1, length(p)]);
legend('Real Offset', 'Predicted by CV');
title('CV Sigma');  %— Vector of residuals
saveas(h1, sprintf('img\\%s_%s_Offset_RF_CV.jpg', goal, region) );

if  ~isempty( strfind(goal, 'hue') ) %goal for hue
    error_predicted = mean( hueDist(p, predicted) );
else
    error_predicted = mean( abs(p-predicted) );
end
disp(sprintf('CV mean error = %f', error_predicted));
fprintf(fid, 'CV mean error = %f\n', error_predicted);


fclose(fid);
rmpath RF_Reg_C

% % R^2
% res = predicted - p;
% RSS  = sum(res.*res);
% tss =  p - mean(p);
% TSS  = sum(tss.*tss);
% R_sqr = 1 - RSS/TSS;          % R square
% disp(sprintf('CV R_sqr = %f', R_sqr));

