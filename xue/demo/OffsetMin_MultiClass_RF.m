%function OffsetMin_MultiClass_RF(goal, ss)
close all; clc; 
clear all;

goal = 'sat';   % 'lum', 'cntrst', 'cct', 'sat', 'hue'

ss = 0.1;  % the scaling factor for sigma of Gaussian -> tolerance


load ('data\\cell_compositing_all.mat');   % load cell_compositing_all

nComp = length(cell_compositing_all);


disp(sprintf('MultiClass RF. Goal = %s, ss = %.2f', goal, ss));

%% Load computed features
loadData_multiClass;  %output: d1, d2, d3, d4, p1, p2, p3, p4


%% Plot 

% Plot all types of offsets
h = figure; hold on;
%plot(d4, 'c.', 'MarkerSize', 10);
plot(d2, 'g.', 'MarkerSize', 10);
plot(d3, 'b.', 'MarkerSize', 10);
plot(d1, 'r.', 'MarkerSize', 10); 

xlim([1,length(d)]);
legend('Low', 'Mean', 'High');
set(gca,'FontSize',20);
set(gca,'LineWidth',2);
xlabel('Index of Training Images');

switch goal
    case 'lum',  
        ylabel('Offsets in stops'); 
        ylim([-10, 10]); 
        title('Offsets of Luminance Zones', 'FontSize', 25);  
    case 'cct',  
        ylabel('Offsets in mired'); 
        ylim([-500, 500]); 
        title('Offsets of CCT Zones', 'FontSize', 25);
    case 'sat',  
        ylabel('Offsets in stops'); 
        ylim([-10, 10]); 
        title('Offsets of Saturation Zones', 'FontSize', 25); 
end
saveas(h, sprintf('img\\%s_All-Offset.jpg', goal) );
saveTightFigure(h, sprintf('img\\%s_All-Offset.pdf', goal) );

% Plot min-Offset Offsets
h = figure;  hold on;
plot(1, 0, 'g.', 'MarkerSize', 10);
plot(1, 0, 'b.', 'MarkerSize', 10);
plot(1, 0, 'r.', 'MarkerSize', 10);

for i= 1:length(d)
    switch p(i)
        case 1,            plot(i, d1(i), 'r.', 'MarkerSize', 10); 
        case 2,            plot(i, d2(i), 'g.', 'MarkerSize', 10); 
        case 3,            plot(i, d3(i), 'b.', 'MarkerSize', 10); 
        case 4,            plot(i, d4(i), 'c.', 'MarkerSize', 10); 
    end
end
xlim([1,length(d)]);
legend('Low', 'Mean', 'High');
set(gca,'FontSize',20);
set(gca,'LineWidth',2);
xlabel('Index of Training Images');

switch goal
    case 'lum',  
        ylabel('Offsets in stops'); 
        ylim([-10, 10]);
        title('Minimal Offsets of Luminance', 'FontSize', 25);
    case 'cct',  
        ylabel('Offsets in mired'); 
        ylim([-500, 500]);
        title('Minimal Offsets of CCT', 'FontSize', 25);
    case 'sat',  
        ylabel('Offsets in stops'); 
        ylim([-10, 10]);
        title('Minimal Offsets of Saturation', 'FontSize', 25);
end
saveas(h, sprintf('img\\%s_Min-Offset.jpg', goal) );
saveTightFigure(h, sprintf('img\\%s_Min-Offset.pdf', goal) );

% Plot Tolerable Offsets
h = figure;  hold on;
for i= 1:length(d)
    if ~isempty(p1), if p1(i),   plot(i, d1(i), 'r.', 'MarkerSize', 10);  end; end;
    if ~isempty(p2), if p2(i),   plot(i, d2(i), 'g.', 'MarkerSize', 10);  end; end;
    if ~isempty(p3), if p3(i),   plot(i, d3(i), 'b.', 'MarkerSize', 10);  end; end;
    if ~isempty(p4), if p4(i),   plot(i, d4(i), 'c.', 'MarkerSize', 10);  end; end;
end

xlim([1,length(d)]);
saveas(h, sprintf('img\\%s_Min-Offset.jpg', goal) );



%%  Statistics
fn = sprintf('img\\%s_OffsetMin_MultiClass_ss=%.2f_RF.txt', goal, ss);
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

%Fitting 
% Model 1
if ~isempty(p1),    model_1 = classRF_train(X, p1, ntree, mtry, extra_options);  end
if ~isempty(p2),    model_2 = classRF_train(X, p2, ntree, mtry, extra_options);  end
if ~isempty(p3),    model_3 = classRF_train(X, p3, ntree, mtry, extra_options);  end
if ~isempty(p4),    model_4 = classRF_train(X, p4, ntree, mtry, extra_options);  end

if isempty(p3) && isempty(p4)
    save(sprintf('model\\%s_MultiClass_ss=%.2f_RF.mat', goal, ss), 'minPerFeature',  'rangePerFeature', 'model_1', 'model_2');  
elseif isempty(p4)
    save(sprintf('model\\%s_MultiClass_ss=%.2f_RF.mat', goal, ss), 'minPerFeature',  'rangePerFeature', 'model_1', 'model_2', 'model_3');
else
    save(sprintf('model\\%s_MultiClass_ss=%.2f_RF.mat', goal, ss), 'minPerFeature',  'rangePerFeature', 'model_1', 'model_2', 'model_3', 'model_4');
end

if ~isempty(p1),    predicted_1 = classRF_predict(X, model_1);  end
if ~isempty(p2),    predicted_2 = classRF_predict(X, model_2);  end
if ~isempty(p3),    predicted_3 = classRF_predict(X, model_3);  end
if ~isempty(p4),    predicted_4 = classRF_predict(X, model_4);  end

% Plot Min-offsets only
h = figure;  hold on;
for i= 1:length(d)   %500:600  %
    if ~isempty(p1), 
        plot(i, d1(i), 'r.', 'MarkerSize', 10); 
        if predicted_1(i), plot(i, d1(i), 'ro', 'MarkerSize', 5);  end; 
    end;
    if ~isempty(p2), 
        plot(i, d2(i), 'g.', 'MarkerSize', 10);         
        if predicted_2(i), plot(i, d2(i), 'go', 'MarkerSize', 5);  end; 
    end;
    if ~isempty(p3), 
        plot(i, d3(i), 'b.', 'MarkerSize', 10); 
        if predicted_3(i), plot(i, d3(i), 'bo', 'MarkerSize', 5);  end; 
    end;
    if ~isempty(p4), 
        plot(i, d4(i), 'c.', 'MarkerSize', 10); 
        if predicted_4(i), plot(i, d4(i), 'co', 'MarkerSize', 5);  end; 
    end;
end
%xlim([1,length(d)]);
title('0-Matching using Predicted Label');
saveas(h, sprintf('img\\%s_MultiClass_RF_CV.jpg', goal) );

if ~isempty(p1),
    errorRate_1 = length( find(predicted_1~=p1)) / length(p1);
    disp( sprintf('Fitting Error rate 1 = %f\n',errorRate_1) );
    fprintf(fid, 'Fitting Error rate 1 = %f\n', errorRate_1);
end
if ~isempty(p2),
    errorRate_2 = length( find(predicted_2~=p2)) / length(p2);
    disp( sprintf('Fitting Error rate 2 = %f\n',errorRate_2) );
    fprintf(fid, 'Fitting Error rate 2 = %f\n', errorRate_2);
end
if ~isempty(p3),
    errorRate_3 = length( find(predicted_3~=p3)) / length(p3);
    disp( sprintf('Fitting Error rate 3 = %f\n',errorRate_3) );
    fprintf(fid, 'Fitting Error rate 3 = %f\n', errorRate_3);
end
if ~isempty(p4),
    errorRate_4 = length( find(predicted_4~=p4)) / length(p4);
    disp( sprintf('Fitting Error rate 4 = %f\n',errorRate_4) );
    fprintf(fid, 'Fitting Error rate 4 = %f\n', errorRate_4);
end

errOff = zeros(1, length(d));
for index =1:length(d)
    if ~isempty(p1), predLabel_1 = predicted_1(index); end;
    if ~isempty(p2), predLabel_2 = predicted_2(index); end;
    if ~isempty(p3), predLabel_3 = predicted_3(index); end;
    if ~isempty(p4), predLabel_4 = predicted_4(index); end;
    findBestLabel;
    errOff(index) = bestOff;
end
error_predicted = mean( abs( errOff ) );
disp(sprintf('fitting mean error = %f', error_predicted));
fprintf(fid, 'fitting mean error = %f\n', error_predicted);




%% K-fold Cross Validation
nFold = 10;
[N D] = size(X);
randvector =  randperm(N);  % [1:N];  %
for i=1:nFold
    s = floor( N/nFold * (i-1) );
    s = min(max(s,1), N);
    t = floor( N/nFold * i  );
    t = min(max(t,1), N);    %disp(sprintf('s=%d, t=%d\n', s, t));
    %disp(sprintf('s=%d, t=%d\n', s, t));
    X_tst = X(randvector(s:t),:);       % 1/nFold
    X_trn = X( [randvector(1:(s-1)), randvector((t+1):end)],:); % 1-1/nFold
    
    if ~isempty(p1),    
        p_tst_1 = p1(randvector(s:t),:);
        p_trn_1 = p1( [randvector(1:(s-1)), randvector((t+1):end)],:);

        model_1 = classRF_train(X_trn, p_trn_1, ntree, mtry, extra_options);  
        predicted_1(randvector(s:t)) = classRF_predict(X_tst, model_1);
    end
    
    if ~isempty(p2),    
        p_tst_2 = p2(randvector(s:t),:);
        p_trn_2 = p2( [randvector(1:(s-1)), randvector((t+1):end)],:);

        model_2 = classRF_train(X_trn, p_trn_2, ntree, mtry, extra_options);  
        predicted_2(randvector(s:t)) = classRF_predict(X_tst, model_2);
    end
    if ~isempty(p3),    
        p_tst_3 = p3(randvector(s:t),:);
        p_trn_3 = p3( [randvector(1:(s-1)), randvector((t+1):end)],:);

        model_3 = classRF_train(X_trn, p_trn_3, ntree, mtry, extra_options);  
        predicted_3(randvector(s:t)) = classRF_predict(X_tst, model_3);
    end
    if ~isempty(p4),    
        p_tst_4 = p4(randvector(s:t),:);
        p_trn_4 = p4( [randvector(1:(s-1)), randvector((t+1):end)],:);

        model_4 = classRF_train(X_trn, p_trn_4, ntree, mtry, extra_options);  
        predicted_4(randvector(s:t)) = classRF_predict(X_tst, model_4);
    end
    
end

% Plot Min-offsets only
h2 = figure;  hold on;
for i= 1:length(d)   %500:600  %
    if ~isempty(p1), 
        plot(i, d1(i), 'r.', 'MarkerSize', 10); 
        if predicted_1(i), plot(i, d1(i), 'ro', 'MarkerSize', 5);  end; 
    end;
    if ~isempty(p2), 
        plot(i, d2(i), 'g.', 'MarkerSize', 10);         
        if predicted_2(i), plot(i, d2(i), 'go', 'MarkerSize', 5);  end; 
    end;
    if ~isempty(p3), 
        plot(i, d3(i), 'b.', 'MarkerSize', 10); 
        if predicted_3(i), plot(i, d3(i), 'bo', 'MarkerSize', 5);  end; 
    end;
    if ~isempty(p4), 
        plot(i, d4(i), 'c.', 'MarkerSize', 10); 
        if predicted_4(i), plot(i, d4(i), 'co', 'MarkerSize', 5);  end; 
    end;
end
%xlim([1,length(d)]);
title('0-Matching using Predicted Label');
saveas(h2, sprintf('img\\%s_MultiClass_RF_CV.jpg', goal) );

if ~isempty(p1),
    errorRate_1 = length( find(predicted_1~=p1)) / length(p1);
    disp( sprintf('CV Error rate 1 = %f\n',errorRate_1) );
    fprintf(fid, 'CV Error rate 1 = %f\n', errorRate_1);
end
if ~isempty(p2),
    errorRate_2 = length( find(predicted_2~=p2)) / length(p2);
    disp( sprintf('CV Error rate 2 = %f\n',errorRate_2) );
    fprintf(fid, 'CV Error rate 2 = %f\n', errorRate_2);
end
if ~isempty(p3),
    errorRate_3 = length( find(predicted_3~=p3)) / length(p3);
    disp( sprintf('CV Error rate 3 = %f\n',errorRate_3) );
    fprintf(fid, 'CV Error rate 3 = %f\n', errorRate_3);
end
if ~isempty(p4),
    errorRate_4 = length( find(predicted_4~=p4)) / length(p4);
    disp( sprintf('CV Error rate 4 = %f\n',errorRate_4) );
    fprintf(fid, 'CV Error rate 4 = %f\n', errorRate_4);
end

errOff = zeros(1, length(d));
for index =1:length(d)
    if ~isempty(p1), predLabel_1 = predicted_1(index); end;
    if ~isempty(p2), predLabel_2 = predicted_2(index); end;
    if ~isempty(p3), predLabel_3 = predicted_3(index); end;
    if ~isempty(p4), predLabel_4 = predicted_4(index); end;
    findBestLabel;
    errOff(index) = bestOff;
end
error_predicted = mean( abs( errOff ) );
disp(sprintf('CV mean error = %f', error_predicted));
fprintf(fid, 'CV mean error = %f\n', error_predicted);


fclose(fid);

rmpath  RF_Class_C
