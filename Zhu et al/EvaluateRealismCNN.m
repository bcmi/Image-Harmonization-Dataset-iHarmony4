% Apply RealismCNN model directly on human evaluation dataset. 
% This script can reproduce RealismCNN results in Table 1. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% add paths
SetPaths;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% set parameters
EXPR_NAME = 'RealismCNN'; % realism_cnn_indoor
MODEL_DIR = '../models/';
% outdoor: lalonde_and_efros_dataset; indoor: indoor_images
DATA_DIR = '../data/human_evaluation/lalonde_and_efros_dataset';
WEB_DIR = '../web/';
% initialize vgg network
net_weights = fullfile(MODEL_DIR,'realismCNN_all_iter1.caffemodel');
net_model = fullfile(MODEL_DIR,'realismCNN_fc8.prototxt');
use_gpu = 1;
gpu_id = 0;

imgFold = fullfile(DATA_DIR, 'images');
labelFile = fullfile(DATA_DIR,'human_labels.mat');
webFold = fullfile(WEB_DIR, EXPR_NAME);
mkdirs(webFold);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% load labels
disp('loading image list and ground truth');
load(labelFile); %load imgList, labels,  etc.
%0: unrealistic composite; 1: realistic composite; 2: natural photos
pred_labels = labels;
pred_labels(pred_labels>0.5) = 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% load images
nImgs = numel(imgList);
ims = cell(nImgs, 1);

for n = 1 : nImgs
    ims{n} = imresize(imread(fullfile(imgFold, imgList{n})), [256,256]);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% predict scores
rstFile = fullfile(webFold, 'scores.mat');
if ~exist(rstFile, 'file')
    s = CaffeVGGBatch(ims, use_gpu, gpu_id, net_model, net_weights);
    s =cat(2, s{:});
    scores = double(s(2,:));
    save(rstFile, 'scores');
else
    fprintf('loading previous results from (%s)\n', rstFile); 
    load(rstFile, 'scores');
end

[~, tpr, fpr, ~]  = prec_rec(scores, pred_labels, 'plotPR',0, 'plotROC', 1);
rocScore = auroc(tpr, fpr);
fprintf('roc score = %3.3f\n', rocScore);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% create a webpage to display the results
fprintf('creating result webpage (%s)\n', webFold);
html = starthtml;
html = htmlAddTitle(html, sprintf('Experiment Name = %s', EXPR_NAME));
html = htmlAddTitle(html, sprintf('ROC Score = %3.3f', rocScore));

outImgFold = 'images';
mkdirs(fullfile(webFold, outImgFold));

%0 (red): unrealistic composite; 1 (green): realistic composite; 2 (blue): natural photos
colors = {uint8([255,0,0]), uint8([0,255,0]), uint8([0, 0, 255])};
nCols = 6;  % number of images per row
nRows = ceil(nImgs/nCols);
[sort_s, sort_ids] = sort(scores, 'ascend');
html = htmlAddTitle(html, sprintf('Ranking of photos according to visual realism prediction'));


for k = 1 : nRows
    ids = nCols * (k-1) + 1 : min(nCols*k,nImgs);
    nIds = numel(ids);
    ims = cell(nIds,1);
    imlinks = cell(nIds, 1);
    txts = cell(nIds, 1);
    for i = 1 : nIds;
        id = sort_ids(ids(i));
        im = imread(fullfile(imgFold, imgList{id}));
        im = imresize(im, [256,256]);
        im = DrawRect(im, [], colors{labels(id)+1}, 5);
        imlinks{i} = fullfile(outImgFold, imgList{id}); 
        outpath = fullfile(webFold, imlinks{i});
        imwrite(im, outpath);
        txts{i} = sprintf('score: %3.3f', sort_s(ids(i)));
    end
    
    html = htmlAddTable(html);
    html = htmlAddImages(html, imlinks, txts, imlinks, 200);
    html = htmlEndTable(html);
end

html = endhtml(html);
htmlWrite(html, webFold);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('done');