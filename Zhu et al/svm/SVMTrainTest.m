% SetPaths;
% function SVMTrainTest(layer, modelFold)
%% caffe

%% vgg network
modelFold = '/data1/Projects/graphics_cnn/models/LabelMe_model_rgb_masks_vgg';
layer = 'fc6';
fprintf('svm train/test %s %s\n', modelFold, layer);
model = '/data1/Projects/software/caffe/models/vgg/vgg.caffemodel';
prototxt = sprintf('/data1/Projects/software/caffe/models/vgg/%s.prototxt', layer);
% model ='/data1/Projects/graphics_cnn/models/LabelMe_model_rgb_masks_10_vgg/model_iter_7500.caffemodel';
% model = '/data1/Projects/software/caffe/models/vgg/vgg.caffemodel';
% prototxt = sprintf('/data1/Projects/graphics_cnn/models/LabelMe_model_rgb_masks_10_vgg/%s.prototxt',layer);
use_gpu = 1;
method = 'liblinear';
addpath(fullfile('svm', method));
%% svm
opts.svmType = 4;
opts.kernelType =0;
opts.cost = 1;
opts.verbose = 0;
opts.epsilon = 0.1;

%% train a svm model
svmFold = fullfile(modelFold, method);
svmFile = fullfile(svmFold, sprintf('svm_%s_c%d_t%d.mat', layer,opts.cost, opts.svmType));
mkdirs(svmFold);

if ~exist(svmFile, 'file')
    ftrFile = fullfile(svmFold, sprintf('%s_train_ftrs.mat',layer));
    
    if ~exist(ftrFile, 'file')
        train_files = {'train_positive_baozi.txt', 'train_negative_baozi.txt'};
        %     trainFile_p = fullfile(modelFold, 'train_positive_baozi.txt');
        trainList = [];
        trainLabels = [];
        for k = 1 : numel(train_files)
            fid = fopen(fullfile(modelFold, train_files{k}), 'rt');
            tmp = textscan(fid, '%s %d\n');
            trainList  = [trainList; tmp{1}];
            trainLabels =[trainLabels; tmp{2}];
            fclose(fid);
        end
        
        rand_id = randperm(numel(trainLabels));
        trainList = trainList(rand_id);
        trainLabels = trainLabels(rand_id);
        %     fid = fopen(
        
        disp('extract training features');
        %         trainList = trainList(1:15);
        trainFeats = VGGCaffeBatch(trainList, use_gpu,prototxt, model);
        %         trainFeats = PlaceCaffeBatch(trainList, use_gpu, prototxt, model);
        save(ftrFile,'trainFeats', 'trainLabels','-v7.3');
    else
        disp('load training features');
        load(ftrFile);
    end
    disp('train svm model');
    trainFeats = cat(2, trainFeats{:});
    svm_model =  TrainModel(double(trainFeats'), double(trainLabels), opts);
    save(svmFile, 'svm_model','-v7.3');
else
    load(svmFile);
end


%% test a svm model
predFile = fullfile(svmFold, sprintf('%s_pred_c%d_t%d.mat', layer,opts.cost, opts.svmType));
if ~exist(predFile, 'file')
    test_files = {'test_positive_baozi.txt', 'test_negative_baozi.txt'};
    testList = [];
    label = [];
    for k = 1 : numel(test_files)
        %         testFile = fullfile(modelFold, 'test_baozi.txt');
        fid = fopen(fullfile(modelFold, test_files{k}), 'rt');
        tmp = textscan(fid, '%s %d\n');
        testList  = [testList; tmp{1}];
        label = [label; tmp{2}];
        fclose(fid);
    end
    ftrFile = fullfile(svmFold, sprintf('%s_test_ftrs.mat',layer));
    if ~exist(ftrFile, 'file')
        disp('extract test features');
        testFeats = VGGCaffeBatch(testList, use_gpu,prototxt, model);
        %         testFeats = PlaceCaffeBatch(testList, use_gpu, prototxt, model);
        save(ftrFile, 'testFeats', '-v7.3');
    else
        disp('load test features');
        load(ftrFile);
    end
    disp('test svm model');
    testFeats = cat(2, testFeats{:});
    pred =  TestModel(double(testFeats'), double(label),svm_model);
    acc = sum(pred==label)/ numel(label);
    save(predFile,'pred', 'label', 'acc');
else
    load(predFile);
end

fprintf('expr name = (%s) accuracy = %f\n', modelFold, acc);
% end
% auc = AUC(pred, label);


