function OffsetMin_Class_SVR(goal)
close all; clc; 
%clear all;

load ('data\\cell_compositing_all.mat');   % load cell_compositing_all

nComp = length(cell_compositing_all);

%goal = 'lum';   % 'lum', 'cntrst', 'cct', 'sat', 'hue'

disp(sprintf('Class SVR. Goal = %s', goal));


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
legend('top', 'low', 'mean', 'median');
title('Real Offset');  %— Vector of residuals
saveas(h, sprintf('img\\%s_All-Offset.jpg', goal) );

% Plot Min-offsets only
hh = figure;  hold on;
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
saveas(hh, sprintf('img\\%s_Min-Offset.jpg', goal) );

% h = figure; 
% hist(d, 100);
% obj = findobj(gca,'Type','patch');
% set(obj,'FaceColor','b','EdgeColor','w')



%%  Statistics
fn = sprintf('img\\%s_OffsetMin_Class_SVR.txt', goal);
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
addpath  libsvm-3.1\windows


%% Parameter Selection
unbalanced = false;  % default is false
if unbalanced == true
    % weight for different classes
    cnt1 = sum(p==1)+1;
    cnt2 = sum(p==2)+1;
    cnt3 = sum(p==3)+1;
    sumcnt = 1/cnt1 + 1/cnt2 + 1/cnt3;
    w1   = 1/cnt1 / sumcnt;
    w2   = 1/cnt2 / sumcnt;
    w3   = 1/cnt3 / sumcnt;
    minw = min([w1, w2, w3]);
    w1   = w1/minw;
    w2   = w2/minw;
    w3   = w3/minw;
else
    w1   = 1;
    w2   = 1;
    w3   = 1;
end

nFold = 10;
cvPara = true;  % if use cv to select parameters

if cvPara == true
    maxAccuracy = 0;
    for log2c = -4:2:4,   %default c = 1
      for log2g = -6:2:2,      %default g = 1/ # features
          %for log2w3 = 0:8
                % -s 0 :  C-SVC   -t 2 RBF kernel
                cmd = ['-s 0 -t 2 -c ', num2str(2^log2c), ' -g ', num2str(2^log2g), ' -v ',  num2str(nFold), ...  -v: cross-validation mode
                       '-w1', num2str(w1), '-w2', num2str(w2), '-w3', num2str(w3)];   % -wi weight of class i
                accuracy = svmtrain(p, X, cmd);
                if(accuracy > maxAccuracy)
                    bestc = 2^log2c;
                    bestg = 2^log2g;
                    %w3    = 2^log2w3;       %unbalanced weighted
                    maxAccuracy = accuracy;
                end
          %end
      end
    end
    %fprintf('%d CV to choose parameters: (bestc=%f, bestg=%f, w3 = %f, maxAccuracy=%f)\n', nFold, bestc, bestg, w3, maxAccuracy);
    fprintf('%d CV to choose parameters: (bestc=%f, bestg=%f, maxAccuracy=%f)\n', nFold, bestc, bestg, maxAccuracy);
    fprintf(fid, '%d CV to choose parameters: (bestc=%f, bestg=%f, maxAccuracy=%f)\n', nFold, bestc, bestg, maxAccuracy);
else
    bestc = 16;    %default c = 1
    bestg = 1;   %default g = 1/ # features
    fprintf('Preset parameters: (bestc=%f, bestg=%f)\n', bestc, bestg);
    fprintf(fid, 'Preset parameters: (bestc=%f, bestg=%f)\n', bestc, bestg);
end
    


%% K-Fold Cross-Validation 
bestPredicted = zeros(size(p));
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

    % -s 0 :  C-SVC   -t 2 RBF kernel
    cmd = ['-s 0 -t 2 -c ', num2str(bestc), ' -g ', num2str(bestg),  ...
           '-w1', num2str(w1), '-w2', num2str(w2), '-w3', num2str(w3)];   % -wi weight of class i;
    model2 = svmtrain(p_trn, X_trn, cmd);

    [predicted_tst, accuracy, decision_values] = svmpredict(p_tst, X_tst, model2);

    predicted(randvector(s:t)) = predicted_tst;
end


errorRate = sum( predicted~=p ) / length(p);
disp( sprintf('Classification CV error rate %f\n',errorRate) );
fprintf(fid, 'Classification CV error rate %f\n',errorRate);

error_predicted = mean(  abs( [d1(predicted==1)'  d2(predicted==2)'  d3(predicted==3)'  d4(predicted==4)']  ));
disp(sprintf('CV mean error = %f', error_predicted));
fprintf(fid, 'CV mean error = %f\n', error_predicted);


% plot
h1 = figure; hold on;
plot(p, 'r.', 'MarkerSize', 10); 
plot(predicted, 'b.', 'MarkerSize', 10); 
xlim([1, length(p)]);
legend('Real Label', 'predicted by CV');
title('CV Label');  %— Vector of residuals
saveas(h1, sprintf('img\\%s_Label_SVC_CV.jpg', goal) );


% Plot Min-offsets only
h2 = figure;  hold on;
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
saveas(h2, sprintf('img\\%s_LabelMatch_SVC_CV.jpg', goal) );


%% Fitting
% -s 0 :  C-SVC   -t 2 RBF kernel
cmd = ['-s 0 -t 2 -c ', num2str(bestc), ' -g ', num2str(bestg),  ...
       '-w1', num2str(w1), '-w2', num2str(w2), '-w3', num2str(w3)];   % -wi weight of class i;
model = svmtrain(p, X, cmd);
save(sprintf('model\\%s_Class_SVC.mat', goal), 'minPerFeature',  'rangePerFeature', 'model');  

[predicted, accuracy, decision_values] = svmpredict(p, X, model);

errorRate = sum( predicted~=p ) / length(p);
disp( sprintf('Classification Fitting error rate %f\n',errorRate) );
fprintf(fid, 'Classification Fitting error rate %f\n',errorRate);

error_predicted = mean(  abs( [d1(predicted==1)'  d2(predicted==2)'  d3(predicted==3)'  d4(predicted==4)']  ));
disp(sprintf('Fitting mean error = %f', error_predicted));
fprintf(fid, 'Fitting mean error = %f', error_predicted);

fclose(fid);
rmpath  libsvm-3.1\windows
