function OffsetMin_Class_RF(goal)
close all; clc; 
%clear all;

load ('data\\cell_compositing_all.mat');   % load cell_compositing_all

nComp = length(cell_compositing_all);

%goal = 'lum';   % 'lum', 'cntrst', 'cct', 'sat', 'hue'

disp(sprintf('Class RF. Goal = %s', goal));


%% Load computed features
loadData_class;



%% Plot 

% Plot all types of offsets
h = figure; hold on;
plot(d1, 'r.', 'MarkerSize', 10); 
plot(d2, 'g.', 'MarkerSize', 10); 
plot(d3, 'b.', 'MarkerSize', 10); 
plot(d4, 'c.', 'MarkerSize', 10);
xlim([1,length(d)]);
legend('top', 'low', 'mean', 'high');
title('Real Offset');  %— Vector of residuals
saveas(h, sprintf('img\\%s_All-Offset.jpg', goal) );

% Plot Min-offsets only
h = figure;  hold on;
for i= 1:length(d)
    switch p(i)
        case 1
            plot(i, d1(i), 'r.', 'MarkerSize', 10); 
        case 2
            plot(i, d2(i), 'g.', 'MarkerSize', 10); 
        case 3
            plot(i, d3(i), 'b.', 'MarkerSize', 10); 
        case 4
            plot(i, d4(i), 'c.', 'MarkerSize', 10); 
    end
end
%xlim([1,length(d)]);
title('min(top, low, mean)');
saveas(h, sprintf('img\\%s_Min-Offset.jpg', goal) );

% h = figure; 
% hist(d, 100);
% obj = findobj(gca,'Type','patch');
% set(obj,'FaceColor','b','EdgeColor','w')



%%  Statistics
fn = sprintf('img\\%s_OffsetMin_Class_RF.txt', goal);
fid = fopen(fn,'wt');

mean_d1 = mean(d1);    std_d1  = std(d1);  error_d1 = mean( abs( d1 ) );
disp(sprintf('mean_d1 = %f,  \t std_d1 = %f,\t error_d1 = %f', mean_d1, std_d1, error_d1));
fprintf(fid, 'mean_d1 = %f,  \t std_d1 = %f,\t error_d1 = %f\n', mean_d1, std_d1, error_d1);

mean_d2 = mean(d2);    std_d2  = std(d2);  error_d2 = mean( abs( d2 ) );
disp(sprintf('mean_d2 = %f,  \t std_d2 = %f,\t error_d2 = %f', mean_d2, std_d2, error_d2));
fprintf(fid, 'mean_d2 = %f,  \t std_d2 = %f,\t error_d2 = %f\n', mean_d2, std_d2, error_d2);

mean_d3 = mean(d3);    std_d3  = std(d3);  error_d3 = mean( abs( d3 ) );
disp(sprintf('mean_d3 = %f,  \t std_d3 = %f,\t error_d3 = %f', mean_d3, std_d3, error_d3));
fprintf(fid, 'mean_d3 = %f,  \t std_d3 = %f,\t error_d3 = %f\n', mean_d3, std_d3, error_d3);

mean_d4 = mean(d4);    std_d4  = std(d4);  error_d4 = mean( abs( d4 ) );
disp(sprintf('mean_d4 = %f,  \t std_d4 = %f,\t error_d4 = %f', mean_d4, std_d4, error_d4));
fprintf(fid, 'mean_d4 = %f,  \t std_d4 = %f,\t error_d4 = %f\n', mean_d4, std_d4, error_d4);


mean_d = mean(d);    std_d  = std(d);      error_d = mean( abs( d ) );
disp(sprintf('mean_d = %f,  \t std_d = %f,\t error_d = %f', mean_d, std_d, error_d));
fprintf(fid, 'mean_d = %f,  \t std_d = %f,\t error_d = %f\n', mean_d, std_d, error_d);





%% Data normalization
% Scale the data into [0, 1]
minPerFeature   = min(X,[],1);      % 1 x P.   P = # features
rangePerFeature = spdiags(1./(max(X,[],1)-min(X,[],1))',0,size(X,2),size(X,2));   % diag( P )

X = (X - repmat(min(X,[],1),size(X,1),1)) * spdiags(1./(max(X,[],1)-min(X,[],1))',0,size(X,2),size(X,2));


%% %% Learn Labels
addpath RF_Class_C


%% Start classification
clear extra_options
extra_options.importance = 1; %(0 = (Default) Don't, 1=calculate)

ntree = 0;    %default 500
mtry  = 0;    % default max(floor(size(X,2)/3), 1);

%Fitting Results

model = classRF_train(X, p, ntree, mtry, extra_options);
save(sprintf('model\\%s_Class_RF.mat', goal), 'minPerFeature',  'rangePerFeature', 'model');  

predicted = classRF_predict(X, model);

% Fitting Goodness
h = figure; hold on;
plot(p, 'r.', 'MarkerSize', 15); 
plot(predicted, 'b.', 'MarkerSize', 15); 
xlim([1,length(p)]);
legend('Real Label', 'Predicted by Fitting');
title('Fitting Labels');  %— Vector of residuals
saveas(h, sprintf('img\\%s_Label_Fitting.jpg', goal) );

errorRate = length( find(predicted~=p)) / length(p);
disp( sprintf('Fitting Error rate %f\n',errorRate) );
fprintf(fid, 'Fitting Error rate %f\n', errorRate);


% k-fold Cross Validation
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

    model = classRF_train(X_trn, p_trn, ntree, mtry, extra_options);
    predicted(randvector(s:t)) = classRF_predict(X_tst, model);
end

h1 = figure; hold on;
plot(p, 'r.', 'MarkerSize', 10); 
plot(predicted, 'b.', 'MarkerSize', 10); 
xlim([1, length(p)]);
legend('Real Label', 'Predicted by CV');
title('CV Label');  %— Vector of residuals
saveas(h1, sprintf('img\\%s_Label_RF_CV.jpg', goal) );

% Plot Min-offsets only
h2 = figure;  hold on;
for i= 1:length(d)   %500:600  %
    switch p(i)
        case 1
            plot(i, d1(i), 'r.', 'MarkerSize', 10); 
        case 2
            plot(i, d2(i), 'g.', 'MarkerSize', 10); 
        case 3
            plot(i, d3(i), 'b.', 'MarkerSize', 10); 
        case 4
            plot(i, d4(i), 'c.', 'MarkerSize', 10); 
    end
    
    switch predicted(i)
        case 1
            plot(i, 0, 'ro', 'MarkerSize', 7); 
        case 2
            plot(i, 0, 'go', 'MarkerSize', 7); 
        case 3
            plot(i, 0, 'bo', 'MarkerSize', 7); 
        case 4
            plot(i, 0, 'co', 'MarkerSize', 7); 
    end
end
%xlim([1,length(d)]);
title('0-Matching using Predicted Label');
saveas(h2, sprintf('img\\%s_LabelMatch_RF_CV.jpg', goal) );


errorRate = length( find(predicted~=p)) / length(p);
disp( sprintf('Classification CV error rate %f\n',errorRate) );
fprintf(fid, 'Classification CV error rate %f\n',errorRate);

error_predicted = mean(  abs( [d1(predicted==1)'  d2(predicted==2)'  d3(predicted==3)'  d4(predicted==4)']  ));
disp(sprintf('CV mean error = %f', error_predicted));
fprintf(fid, 'CV mean error = %f\n', error_predicted);

fclose(fid);

rmpath  RF_Class_C
