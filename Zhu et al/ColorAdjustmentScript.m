%ã€?reproduce color adjusetment results reported in the paper. 
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% specify directories 
DATA_DIR = '../data/color_adjustment/';
MODEL_DIR = '../models'; 
WEB_DIR = '../web/color_adjustment'; 
EXPR_NAME = 'recolor_dataset'; 
webFold = fullfile(WEB_DIR, EXPR_NAME);
imgFold  = fullfile(DATA_DIR, 'pngimages');

outImgFold = 'results';
mkdirs({webFold, fullfile(webFold, outImgFold)});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% set paramters for color adjustment 
opts.WEIGHT = 50;                                     % regulaziation weight
opts.SEEDS = 0.6:0.2:1.4;                             % multiple initiailization
opts.LOWER_BOUND = [0.4,0.4,0.4,-0.5,-0.5,-0.5];      % lower bound of search range
opts.UPEER_BOUND = [2.0,2.0,2.0,0.5,0.5,0.5];         % upper bound of search range 
opts.EXT = sprintf('_iter3_weight%.1f', opts.WEIGHT); % file extension of result images
opts.IS_SOFT = false;                                 % feathering the mask or not

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% initialize vgg network
net_weights = fullfile(MODEL_DIR,'realismCNN_15categories_iter3.caffemodel');
net_model = fullfile(MODEL_DIR,'realismCNN_opt.prototxt');
use_gpu = 1;
gpu_id = 0;
CaffeReset();
net = CaffeInit(use_gpu, gpu_id, net_model, net_weights);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% load images
listFile = fullfile(DATA_DIR, 'imageList.mat'); % load imgList
load(listFile);
% comment the following line if you would like to reproduce all the results 
imgList = {'image_001900'};
nImgs = numel(imgList);
srcList = cell(nImgs, 1);
tgtList = cell(nImgs, 1);
maskList = cell(nImgs, 1);
rstList = cell(nImgs, 1);

for n = 1 : nImgs
    name = imgList{n}; % image name without extension
    srcList{n} = fullfile(imgFold, [name '_obj.png']);
    tgtList{n} = fullfile(imgFold, [name '_bg.png']);
    maskList{n} = fullfile(imgFold, [name '_softmask.png']);
    rstList{n} = fullfile(webFold, outImgFold, name);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% recolor images
ColorAdjustmentBatch(srcList, tgtList, maskList, rstList, opts, net);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% create a webpage to display results
html = starthtml; 
html = htmlAddTitle(html, sprintf('Experiment Name: %s', EXPR_NAME));  

for n = 1 : nImgs
    name = imgList{n}; 
    ims = cell(3, 1);
    txts = {'object mask', 'cut_and_paste', 'our result'}; 
    ims{1} = fullfile(outImgFold, [name '_mask.png']); 
    copyfile(maskList{n}, fullfile(webFold, ims{1})); 
    ims{2} = fullfile(outImgFold, [name '_cut_and_paste.png']);
    ims{3} = fullfile(outImgFold, [name opts.EXT '.png']); 
    html = htmlAddTitle(html, sprintf('image name = %s', name));
    html = htmlAddTable(html); 
    html = htmlAddImages(html, ims, txts, ims, 256);
    html = htmlEndTable(html); 
end

htmlWrite(html, webFold); 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
CaffeReset();
disp('done'); 
