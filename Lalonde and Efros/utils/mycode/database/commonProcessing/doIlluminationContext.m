function doIlluminationContext 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% addpath ../;
setPathGeometricContext;

% define the paths
imagesPath = '/nfs/baikal/jhhays/flickr2/';
outputBasePath = '/nfs/baikal/jlalonde/flickr2_geomContext';

popupBasePath = outputBasePath;
dbFn = @dbFnIlluminationContext;

nbBins = 50;

recompute = 0;

% call the database
parallelized = 1;
randomized = 1;
processImageDatabase(imagesPath, '',  'unlabelled', outputBasePath, dbFn,  parallelized, randomized, ...
    'PopupDir', popupBasePath, 'ImagesPath', imagesPath, 'Recompute', recompute, 'NbBins', nbBins);

