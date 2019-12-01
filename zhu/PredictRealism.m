%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% add paths
SetPaths;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% set parameters
exprName = 'realism_cnn_all'; % realism_cnn_indoor
MODEL_DIR = '../models/';
IMAGE_FOLD = '../data/cnn_training/LabelMe_15categories/composites';
WEB_DIR = '../web/ranking/';
DISPLAY_TOP_K = 50;
IS_DEDUPLICATE = true;
% initialize vgg network
net_weights = fullfile(MODEL_DIR,'realismCNN_15categories_iter1.caffemodel');
net_model = fullfile(MODEL_DIR,'realismCNN_fc8.prototxt');
use_gpu = 1;
gpu_id = 0;

webFold = fullfile(WEB_DIR, exprName);
mkdirs(webFold);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% load image list
imgList = LoadImageList(IMAGE_FOLD);
nImgs = numel(imgList);
imgPaths = AddPaths(IMAGE_FOLD, imgList);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% realism prediction
scoreFile = fullfile(webFold, 'scores.mat');
if ~exist(scoreFile, 'file')
    s = CaffeVGGBatch(imgPaths, use_gpu, gpu_id, net_model, net_weights);
    s = cat(2, s{:});
    scores = double(s(2,:));
    save(scoreFile, 'scores');
else
    fprintf('loading previous results from (%s)\n', scoreFile);
    load(scoreFile, 'scores');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% create a webpage to display top/bottom ranked DISPLAY_TOP_K images
fprintf('creating result webpage (%s)\n', webFold);
html = starthtml;
html = htmlAddTitle(html, sprintf('Experiment Name = %s', exprName));
outImgFold = 'images'; 
mkdirs(fullfile(webFold, outImgFold)); 
flags = {'descend','ascend'};
names = {'Top', 'Bottom'};
topK = min(DISPLAY_TOP_K, nImgs); 

for n = 1 : numel(flags)
    [sort_s,sort_ids] = sort(scores, flags{n});
    html = htmlAddTitle(html, sprintf('%s ranked %d images by visual realism', names{n}, topK));
    html = htmlAddTable(html);
    imlinks = cell(topK, 1); 
    txts = cell(topK, 1); 
    for k = 1 : topK
        id = sort_ids(k); 
        imlinks{k} = fullfile(outImgFold, imgList{id});
        txts{k} = sprintf('score = %3.3f', sort_s(k)); 
        impath = imgPaths{id}; 
        outpath = fullfile(webFold, imlinks{k}); 
        copyfile(impath, outpath);
    end
    html = htmlAddImages(html, imlinks, txts, imlinks, 256);
    html = htmlEndTable(html);
end

htmlWrite(html, webFold);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('done');