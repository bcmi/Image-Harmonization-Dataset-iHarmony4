%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function doExtractObjectsFromLabelme
% 
% Input parameters:
%
% Output parameters:
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function doExtractObjectsFromLabelme 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

addpath ../;
setPath;

% define the paths
imagesBasePath = '/nfs/hn21/projects/labelmeSubsampled/Images/';
highresImagesBasePath = '/nfs/hn21/projects/labelme/Images/';
annotationsBasePath = '/nfs/hn21/projects/labelmeSubsampled/Annotation/';
outputBasePath = '/nfs/hn24/home/jlalonde/results/colorStatistics/objectDb/';

dbFn = @dbFnExtractObjectsFromLabelme;

% call the database
parallelized = 1;
randomized = 1;
processLabelmeDatabaseFast(annotationsBasePath, '*static*', outputBasePath, dbFn, parallelized, randomized, ...
    'ImagesPath', imagesBasePath, 'HighResImagesPath', highresImagesBasePath);