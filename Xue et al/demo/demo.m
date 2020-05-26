clc; close all;
clear all;

sz = [256,256];
imgPath = 'demoData/a0002_1_4.jpg';
name_parts = regexp(imgPath,'_','split');
objMaskPath = [name_parts{1,1},'_',name_parts{1,2},'.png'];
oriI = im2double(imread(imgPath));
oriMask = im2double(imread(objMaskPath));      % 0~1, 3channel  
oriMask = oriMask(:,:,1);
oriI = imresize(oriI, sz);
oriMask = imresize(oriMask, sz);
outI = oriI;
% cntrst
goal   = 'cntrst';
method = 'zero';  %'reg_SVR';    %
region = 'top';
ss = [];
outI = MatchAlgorithm(outI, oriMask, goal, method, region, ss);
% Lum
goal   = 'lum';
method = 'multiCls_RF';   %'zero'; %  'cls_RF';  %
region = 'top';
ss = 0.1;
outI = MatchAlgorithm(outI, oriMask, goal, method, region, ss);
% cct
goal   = 'cct';
method = 'multiCls_RF'; %'cls_RF';  %'zero'; %
region = 'mean';
ss = 0.1;
outI = MatchAlgorithm(outI, oriMask, goal, method, region, ss);
% Sat
goal   = 'sat';
method = 'multiCls_RF';   %'zero'; %  'cls_RF';  %
region = []; %'top';
ss = 0.1;
outI = MatchAlgorithm(outI, oriMask, goal, method, region, ss);
result_path = 'demoData/result.jpg';
imwrite(outI,result_path);



