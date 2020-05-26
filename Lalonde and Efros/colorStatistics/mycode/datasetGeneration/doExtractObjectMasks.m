%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function doExtractObjectsMasks
%   Extract the object's masks
% 
% Input parameters:
%
% Output parameters:
%   
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function doExtractObjectMasks 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

addpath ../; 
setPath;

% define the input and output paths
imagesBasePath = '/nfs/hn21/projects/labelmeSubsampled/Images/';
annotationsBasePath = '/nfs/hn24/home/jlalonde/results/colorStatistics/objectDb/';
outputBasePath = '/nfs/hn24/home/jlalonde/results/colorStatistics/objectDb/';

dbFn = @dbFnExtractObjectMasks;

imageSize = 256;

parallelized = 1;
randomized = 1;
processResultsDatabaseFast(annotationsBasePath, 'static', outputBasePath, dbFn, parallelized, randomized, ...
    'ImageSize', imageSize, 'ImagesPath', imagesBasePath);

