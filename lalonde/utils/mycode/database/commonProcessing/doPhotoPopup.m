function doPhotoPopup
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

setPathGeometricContext;

% define the paths
% basePath = '/nfs/hn21/projects/labelmeSubsampled/';
% outputBasePath = '/nfs/hn25/labelmePopup/';

% basePath = '/nfs/hn01/jlalonde/results/colorStatistics/dataset/combinedDb/';
% outputBasePath = '/nfs/hn01/jlalonde/results/colorStatistics/dataset/combinedDbPopup/';

basePath = '/nfs/baikal/jhhays/flickr2/';
outputBasePath = '/nfs/baikal/jlalonde/flickr2_geomContext';

rand('state', sum(clock));

% imagesPath = fullfile(basePath, 'Images');
% dbPath = fullfile(basePath, 'Annotation');

dbFn = @dbFnPhotoPopup;

% maximum size of the image (in pixels), to avoid saving too large results
maxImageSize = 800;

% load the classifiers
codePath = '/nfs/hn01/jlalonde/code/';
baseClassifierData = fullfile(codePath, 'matlab', 'trunk', '3rd_party', 'geometricContext', 'classifiers');
classifierName = 'ijcvClassifier.mat';
classifiers = load(fullfile(baseClassifierData, classifierName));

% executable path for the superpixel segmenter
segmentExec = fullfile(codePath, 'c++', 'trunk', '3rd_party', 'segment', 'segment');

[s,r] = system('hostname -s');
if strfind(r, 'balaton')
    segmentExec = [segmentExec '_64'];
end

% call the database function 
parallelized = 1;
randomized = 1;
% processResultsDatabaseFast(dbPath, '', outputBasePath, dbFn, parallelized, randomized, ...
%     'Recompute', 1, 'ImagesPath', imagesPath, 'SuperpixelsOnly', 0, 'MaxImageSize', maxImageSize);

processImageDatabase(basePath, '',  'unlabelled', outputBasePath, dbFn,  parallelized, randomized, ...
    'Recompute', 1, 'ImagesPath', basePath, 'SuperpixelsOnly', 0, 'MaxImageSize', maxImageSize, ...
    'Classifiers', classifiers, 'ClassifierName', classifierName, 'SegmentExec', segmentExec);
