%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function doExtractImagesFromLabelme
% 
% Input parameters:
%
% Output parameters:
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function doExtractImagesFromLabelme 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

setPathLabelme;

% define the paths
basePath = '/nfs/hn21/projects/labelmeSubsampled800';
imagesBasePath = fullfile(basePath, 'Images/');
annotationsBasePath = fullfile(basePath, 'Annotation');
highresImagesBasePath = '/nfs/hn21/projects/labelme/Images/';

% outputBasePath = '/nfs/hn01/jlalonde/results/colorStatistics/imageDb/';
outputBasePath = '/nfs/hn01/jlalonde/results/skyModeling/imageDb/';

dbFn = @dbFnExtractImagesFromLabelme;

% call the database
parallelized = 1;
randomized = 1;
processLabelmeDatabaseFast(annotationsBasePath, '', outputBasePath, dbFn, parallelized, randomized, ...
    'ImagesPath', imagesBasePath, 'HighResImagesPath', highresImagesBasePath);