function doCoOccurences(type) 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

addpath '../database/';

if strcmp(type, 'natural')
    % define the input and output paths
    imagesBasePath = '/nfs/hn21/projects/naturalSceneCategories/';
    outputBasePath = '/nfs/hn01/jlalonde/results/colorStatistics/naturalSceneCategories/';
    trainingImagesSubDirs = '*';
elseif strcmp(type, 'pascal')
    % define the input and output paths
    imagesBasePath = '/nfs/hn22/pascal/';
    outputBasePath = '/nfs/hn01/jlalonde/results/colorStatistics/pascal/'; 
    % define subdirectories to use for the training images
    trainingImagesSubDirs = {'PNGimages'};
end

% we want to do it for several color spaces
dbFn = @dbFnColorSpacesOccurences;

% call the database function
processGenericDatabaseParallel(imagesBasePath, trainingImagesSubDirs, outputBasePath, dbFn);


%% Simply call the co-occurences database function with several colorspaces
function dbFnColorSpacesOccurences(imgPath, imagesBasePath, outputBasePath, annotation)

dbFnCoOccurences(imgPath, imagesBasePath, outputBasePath, annotation, 'Recompute', 1, 'ColorSpace', 'lab');
dbFnCoOccurences(imgPath, imagesBasePath, outputBasePath, annotation, 'Recompute', 1, 'ColorSpace', 'rgb');


