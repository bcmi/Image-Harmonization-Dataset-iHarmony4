function [net] = CaffeInit(use_gpu, gpu_id, net_model, net_weights)
fprintf('net_weights = %s\n', net_weights);
fprintf('net_model = %s\n', net_model);
fprintf('use_gpu = %d\n', use_gpu); 
fprintf('gpu_id = %d\n', gpu_id);
if exist('use_gpu', 'var') && use_gpu
    caffe.set_mode_gpu();
%     gpu_id = 0;  % we will use the first gpu in this demo
    caffe.set_device(gpu_id);
else
    caffe.set_mode_cpu();
end
%
% model_dir = '../../models/bvlc_reference_caffenet/';
% net_model = [model_dir 'deploy.prototxt'];
% net_weights = [model_dir 'bvlc_reference_caffenet.caffemodel'];
phase = 'test'; % run with phase test (so that dropout isn't applied)
% assert(exist(net_weights,'file')~=0); 
% assert(exist(net_model,'file')~=0);
if ~exist(net_weights, 'file')
    error('no net weights (%s)',net_weights); 
%     error('Please download CaffeNet from Model Zoo before you run this demo');
end
if ~exist(net_model,'file')
    error('no net model (%s)', net_model);
end

% Initialize a network
net = caffe.Net(net_model, net_weights, phase);
end