%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function doResizeLabelme
%   Resizes all the images from 'static' folders' to a maximum size of 800x800. Can also be used if
%   the database has been updated. Set 'Recompute' to 0 and it will update only the images that have
%   changed.
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function doResizeLabelme 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Load paths and define variables
setPathLabelme;

% First, define the root folder for the new database
homeImages = '/nfs/hn21/projects/labelme/Images/';
homeAnnotations = '/nfs/hn21/projects/labelme/Annotation/';
newDbPath = '/nfs/hn21/projects/labelmeSubsampled800/';

dbFn = @dbFnResizeLabelme;
newMaxSize = 800;

%% Run the function on all the database
parallelized = 1;
randomized = 1;
processLabelmeDatabaseFast(homeAnnotations, {'static*'}, {'static_web*', 'static_256*'}, newDbPath, dbFn, parallelized, randomized, ...
    'Recompute', 0, 'ImagesPath', homeImages, 'NewMaxSize', newMaxSize);
% processLabelmeDatabase(homeImages, '*static*', homeAnnotations, newDbPath, dbFn, 'Recompute', 0);


