%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function fitGMM
%   
% 
% Input parameters:
%
% Output parameters:
%   
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function model = fitGMM(data, gaussianType, nbGaussians)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Set up mixture model
inputDim = size(data, 2);
model = gmm(inputDim, nbGaussians, gaussianType);

% Initialize the model parameters from the data
optionsKmeans = zeros(1, 18);
optionsKmeans(2) = 1e-2;
optionsKmeans(14) = 20;	% Just use 20 iterations of k-means in initialization

% Options for EM
options = zeros(1, 18);
options(1) = 0; % quiet
options(2) = 1e-5;
options(3) = 1e-5;
options(14) = 500;	% Use 1000 iterations for EM

% First training step with k-means
model = gmminit(model, data, optionsKmeans);

% Run EM and fit mixtures
model = gmmem(model, data, options);

