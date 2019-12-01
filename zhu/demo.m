%reproduce color adjusetment results reported in the paper. 
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% specify directories 
DATA_DIR = 'demoData/';
MODEL_DIR = 'models'; 
RST_DIR = 'result/';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% set paramters for color adjustment 
opts.WEIGHT = 50;                                     % regulaziation weight
opts.SEEDS = 0.6:0.2:1.4;                             % multiple initiailization
opts.LOWER_BOUND = [0.4,0.4,0.4,-0.5,-0.5,-0.5];      % lower bound of search range
opts.UPEER_BOUND = [2.0,2.0,2.0,0.5,0.5,0.5];         % upper bound of search range 
opts.EXT = sprintf('_iter3_weight%.1f', opts.WEIGHT); % file extension of result images
opts.IS_SOFT = true;                                 % feathering the mask or not

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
srcList = cell(1,1);
tgtList = cell(1, 1);
maskList = cell(1, 1);
rstList = cell(1, 1);
ind=1;
srcList{ind}=fullfile(DATA_DIR,'a0002_1_4.jpg');
tgtList{ind} = fullfile(DATA_DIR,'a0002.jpg');
maskList{ind} = fullfile(DATA_DIR,'a0002_1.png');
rstList{ind} = fullfile(RST_DIR,'a0002_1_4.jpg');

ColorAdjustmentBatch_my(srcList, tgtList, maskList, rstList, opts, net, 1);

CaffeReset();
disp('done'); 
