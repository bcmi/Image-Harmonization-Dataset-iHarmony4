function doCoOccurencesHisto 
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
outputBasePath = '/nfs/hn01/jlalonde/results/colorStatistics/occurencesHisto/';
subDirs = {'spatial_envelope_256x256_static_8outdoorcategories'};

colorSpaces{1} = 'lab';
colorSpaces{2} = 'rgb';

dbFn = @dbFnCoOccurencesTmp;

%% Call the database function
processDatabaseParallel(imagesBasePath, subDirs, annotationsBasePath, outputBasePath, dbFn, ...
    'ColorSpaces', colorSpaces);


%% Simply call the database function with several colorspaces
function dbFnCoOccurencesTmp(imgPath, imagesBasePath, outputBasePath, annotation, varargin)

defaultArgs = struct('ColorSpaces', []);
args = parseargs(defaultArgs, varargin{:});

for i=1:length(args.ColorSpaces)
    dbFnCoOccurences(imgPath, imagesBasePath, outputBasePath, annotation, ...
        'ColorSpace', args.ColorSpaces{i});
end