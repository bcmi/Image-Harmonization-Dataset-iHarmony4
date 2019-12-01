function doPrecomputeUniversalTextons 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

addpath ../;
setPath;

% define the paths
imagesPath = '/nfs/hn21/projects/labelmeSubsampled/Images/';
dbPath = '/nfs/hn01/jlalonde/results/colorStatistics/imageDb/';
outputBasePath = dbPath;
dbFn = @dbFnPrecomputeUniversalTextons;

% create filter bank structure to save in xml
fbParams.numOrient = 8;
fbParams.startSigma = 1;
fbParams.numScales = 2;
fbParams.scaling = 1.4;
fbParams.elong = 2;
filterBank = fbCreate(fbParams.numOrient, fbParams.startSigma, fbParams.numScales, ...
    fbParams.scaling, fbParams.elong);

% call the database
parallelized = 1;
randomized = 1;
processResultsDatabaseFast(dbPath, 'static', outputBasePath, dbFn, parallelized, randomized, ...
    'ImagesPath', imagesPath, 'Recompute', 1, 'FilterBank', filterBank, 'FilterBankParams', fbParams);

