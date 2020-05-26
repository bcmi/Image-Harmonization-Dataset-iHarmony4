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
function [bestModel, bestNbGaussians] = fitGMMCrossValidate(data, gaussianType, doDisplay)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if strcmp(gaussianType, 'full')
    nbGaussians = 1:20;   
elseif strcmp(gaussianType, 'diag')
    nbGaussians = 1:20;
elseif strcmp(gaussianType, 'spherical');
    nbGaussians = 1:20;
else
    error('fitGMM: Unknown option!');
end

errors = zeros(length(nbGaussians), 1);
[nbPoints, inputDim] = size(data);

if doDisplay
    figure;
end

for c=nbGaussians
    fprintf('Using %d %s gaussians\n', c, gaussianType);

    % Set up mixture model
    model = gmm(inputDim, c, gaussianType);

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

    % k-fold cross-validation
    k = 10;
    
    indRand = randperm(nbPoints);
    nbTrain = round(nbPoints/k);
    
    errCV = zeros(1,k);
    for i=1:k
        fprintf('%d...', i);

        indTrain = indRand((i-1)*nbTrain+1:min((i)*nbTrain, nbPoints));
        indTest = setdiff(indRand, indTrain);

        % First training step with k-means
        model = gmminit(model, data(indTrain,:), optionsKmeans);

        % Run EM and fit mixtures
        model = gmmem(model, data(indTrain,:), options);
        indResult = find(nbGaussians == c);
        errCV(i) = -sum(log(gmmprob(model, data(indTest,:))));
    end
    
    errors(indResult) = mean(errCV);
    
    if doDisplay
        plot(nbGaussians(1:indResult), errors(1:indResult), 'b'); 
        drawnow;
    end
end

% Find the best model that minimizes the error
[m, minInd] = min(errors);
bestModel = models(minInd);
bestNbGaussians = nbGaussians(minInd);