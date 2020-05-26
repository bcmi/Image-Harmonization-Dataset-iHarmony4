function doCoOccurencesHistoMarginals 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
addpath ../database;
addpath ../../3rd_party/parseArgs;

% define the input and output paths
imagesBasePath = '/nfs/hn21/projects/labelme/Images/';
annotationsBasePath = '/nfs/hn21/projects/labelme/Annotation/';
outputBasePath = '/nfs/hn01/jlalonde/results/colorStatistics/occurencesHistoMarginals/';
% subDirs = {'spatial_envelope_256x256_static_8outdoorcategories'};
subDirs = {'static_coast_landscape_outdoor', 'static_256x256_web_globalandscape', ...
    'static_outdoor_nature_florida_photos_by_fredo_durand', ...
    'static_outdoor_nature_galapagos_photos_by_fredo_durand', ...
    'static_outdoor_nature_tanzania_photos_by_fredo_durand', ...
    'static_nature_web_outdoor_animal', 'static_newyork_city_urban'};

colorSpaces{1} = 'lab';
colorSpaces{2} = 'rgb';
colorSpaces{3} = 'hsv';

dbFn = @dbFnCoOccurencesTmp;

%% Call the database function
processDatabaseParallel(imagesBasePath, subDirs, annotationsBasePath, outputBasePath, dbFn, ...
    'ColorSpaces', colorSpaces);


%% Simply call the database function with several colorspaces
function dbFnCoOccurencesTmp(imgPath, imagesBasePath, outputBasePath, annotation, varargin)

defaultArgs = struct('ColorSpaces', []);
args = parseargs(defaultArgs, varargin{:});

for i=1:length(args.ColorSpaces)
    dbFnCoOccurencesHistoMarginals(imgPath, imagesBasePath, outputBasePath, annotation, ...
        'ColorSpace', args.ColorSpaces{i});
end