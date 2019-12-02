SetPaths;
%% caffe
method = 'liblinear';
addpath(method);
use_gpu = 1;
%% svm
opts.svmType = 1;
opts.kernelType =0;
opts.cost = 10;
opts.verbose = 0;
opts.epsilon = 0.1;

%% train a svm model
modelFold = '/data1/Projects/scene/models/real_vs_alpha_top_all';
model = fullfile(modelFold, 'model_final.caffemodel'); 
prototxt = fullfile(modelFold, 'fc7.prototxt'); 
svmFold = fullfile(modelFold, method); 
svmFile = fullfile(modelFold, sprintf('svm_fc7_c%d.mat', opts.cost));
mkdirs(svmFold); 

if ~exist(svmFile, 'file')
    trainFile = fullfile(modelFold, 'train_baozi.txt');
    fid = fopen(trainFile, 'rt');
    tmp = textscan(fid, '%s %d\n');
    trainList  = tmp{1};
    trainLabels = tmp{2};
    fclose(fid);
    ftrFile = fullfile(modelFold, 'fc7_train_ftrs_finetuned.mat');
    if ~exist(ftrFile, 'file')
        disp('extract training features');
        trainFeats = PlaceCaffeBatch(trainList, use_gpu, prototxt, model);
        save(ftrFile,'trainFeats', '-v7.3');
    else
        disp('load training features');
        load(ftrFile);
    end
    disp('train svm model');
    svm_model =  TrainModel(double(trainFeats'), double(trainLabels), opts);
    save(svmFile, 'svm_model');
else
    load(svmFile);
end


%% test a svm model
predFile = fullfile(svmFold, sprintf('fc7_pred_c%d_finetuned.mat', opts.cost));
if ~exist(predFile, 'file')
    testFile = fullfile(modelFold, 'test_baozi.txt');
    fid = fopen(testFile, 'rt');
    tmp = textscan(fid, '%s %d\n');
    testList  = tmp{1};
    label = tmp{2};
    fclose(fid);
    ftrFile = fullfile(modelFold, 'fc7_test_ftrs_finetuned.mat');
    if ~exist(ftrFile, 'file')
        disp('extract test features');
        testFeats = PlaceCaffeBatch(testList, use_gpu, prototxt, model);
        save(ftrFile, 'testFeats', '-v7.3');
    else
        disp('load test features');
        load(ftrFile);
    end
    disp('test svm model');
    pred =  TestModel(double(testFeats'), double(label),svm_model);
    acc = sum(pred==label)/ numel(label);
    fprintf('expr name = (%s) accuracy = %f\n', modelFold, acc);
    save(predFile, 'pred', 'label', 'acc'); 
end

% auc = AUC(pred, label);


