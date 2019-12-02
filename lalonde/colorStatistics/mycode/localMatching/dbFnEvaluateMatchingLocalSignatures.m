%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function dbFnEvaluateMatchingLocalSignatures
%   Evaluate the matching of a test image based on the EMD between the object and its background
% 
% Input parameters:
%
% Output parameters:
%    
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function r=dbFnEvaluateMatchingLocalSignatures(outputBasePath, annotation, varargin) 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Initialize
r=0;

% read arguments
defaultArgs = struct('ColorSpace', [], 'DbPath', [], 'ImagesPath', []);
args = parseargs(defaultArgs, varargin{:});

% read the masks
load(fullfile(args.DbPath, annotation.file.folder, annotation.object.masks.filename));

xmlPath = fullfile(outputBasePath, annotation.file.folder, annotation.file.filename);
imgInfo = loadXML(xmlPath);

if strcmp(args.ColorSpace, 'lab')
    type = 1;
    
elseif strcmp(args.ColorSpace, 'rgb')
    type = 2;
    
elseif strcmp(args.ColorSpace, 'hsv')
    type = 3;
    
elseif strcmp(args.ColorSpace, 'lalphabeta')
    type = 4;
else
    error('Color Space %s unsupported!', args.ColorSpace);
end

imgInfo.localEval(type).colorSpace = args.ColorSpace;

%% Load the signatures
load(fullfile(args.DbPath, annotation.file.folder, annotation.signatures(type).filename));

% Compute the pairwise distances between the object and the background
distMat = pdist2(centersObj', centersBg');
[distEMD, flowEMD] = emd_mex(weightsObj', weightsBg', distMat);

sigma = 25;
clusterShift = zeros(length(centersObj), 3);
for c=1:length(centersObj)
    dstClusters = flowEMD(flowEMD(:,1) == c, 2);
    weights = flowEMD(flowEMD(:,1) == c, 3);
    
    shifts = centersBg(dstClusters, :) - repmat(centersObj(c, :), [length(dstClusters) 1]); %#ok
    clusterShift(c,:) = sum(shifts .* repmat(weights, [1 3]), 1) ./ sum(weights);
    
    % gaussian kernel on the distance (far distances are less important)
    clusterShift(c,:) = clusterShift(c,:) .* exp(-abs(clusterShift(c,:)).^2./(sigma.^2));
end

% compute weighted average of cluster shifts
totClusterShift = sum(sqrt(sum(clusterShift.^2, 2)) .* weightsObj) ./ sum(weightsObj);

imgInfo.localEval(type).objBgDst.joint.distEMD = distEMD;
imgInfo.localEval(type).objBgDst.joint.distEMDWeighted = totClusterShift;

%% Save the xml to disk
fprintf('Saving xml file: %s\n', xmlPath);
writeXML(xmlPath, imgInfo);

