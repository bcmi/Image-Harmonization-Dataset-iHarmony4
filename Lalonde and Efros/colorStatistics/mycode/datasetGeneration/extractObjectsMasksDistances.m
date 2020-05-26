%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function extractObjectsMasksDistances
%   Generate test images to evaluate if our method actually captures
%   statistics of natural images. Uses location information to choose the
%   object to paste (closest mask in SSD distance). Second part: compute
%   the SSD distance from every image to every other one.
% 
% Input parameters:
%
% Output parameters:
%   
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function extractObjectsMasks 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
addpath ../database;
addpath ../../3rd_party/LabelMeToolbox;

% define the input and output paths
outputBasePath = '/nfs/hn01/jlalonde/results/colorStatistics/testDataSemantic/';
maskPath = fullfile(outputBasePath, 'maskInfo.mat');

fprintf('Loading the masks...');
load(maskPath);
fprintf('done.\n');

% Initialize a matrix of the corresponding size
distMatrix = zeros(accObjects, accObjects);
tmpDistMatrix = zeros(accObjects, accObjects);

% fill in the matrix elements
tmpMasks = double(reshape(permute(maskVec(1:accObjects,:,:), [2 3 1]), size(maskVec,2)*size(maskVec,3), accObjects));
for i=1:accObjects
    curMask = double(repmat(reshape(squeeze(maskVec(i,:,:)), size(maskVec,2)*size(maskVec,3), 1), 1, accObjects));
    distMatrix(i,:) = sum((curMask - tmpMasks).^2, 1);
    fprintf('%d.',i);
end

distMin = min(distMatrix, [], 2);

save(fullfile(outputBasePath, 'distMatrix.mat'), 'distMatrix', 'distMin');
