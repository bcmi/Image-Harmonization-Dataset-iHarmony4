%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function doPrecomputeHistoObjBg_testData
%   Pre-computes the histograms of the entire image, each of its objects, and the background of each
%   of these objects.
% 
% Input parameters:
%
%
% Output parameters:
%   
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function doPrecomputeHistoObjBg_testData 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
addpath '../database/';

% define the input and output paths
% imagesBasePath = '/nfs/hn21/projects/labelme/Images/';
% annotationsBasePath = '/nfs/hn21/projects/labelme/Annotation/';
% outputBasePath = '/nfs/hn01/jlalonde/results/colorStatistics/occurencesTextons/';

dbPath = '/nfs/hn01/jlalonde/results/colorStatistics/testDataJoint/';
subDirs = {'.'};
outputBasePath = '/nfs/hn01/jlalonde/results/colorStatistics/precomputedHistograms/testDataJoint/';

% read all the directories with the names 'static' and 'outdoor'
% list = dir([imagesBasePath '*static*outdoor*']);
% cellList = struct2cell(list);
% subDirs = cellList(1,:);

minArea = 0.05;
maxArea = 0.6;

nbBins = 100;

colorSpaces = {'lab', 'rgb', 'hsv'};

dbFn = @dbFnTmp;

%% Call the database function
processResultsDatabaseParallelFast(dbPath, outputBasePath, subDirs, dbFn, ...
    'Recompute', 1, 'ColorSpaces', colorSpaces, 'MinArea', minArea, 'MaxArea', maxArea, ...
    'NbBins', nbBins);


%%
function dbFnTmp(annotation, dbPath, outputBasePath, varargin)

addpath ../../3rd_party/parseArgs;

imgPath = fullfile(dbPath, annotation.image.folder, annotation.image.filename);
imagesBasePath = dbPath;

fakeAnnotation = annotation.image;
fakeAnnotation.object = annotation.object;

imSrc = imread(fakeAnnotation.object.imgSrc.path);
[hSrc,wSrc,c] = size(imSrc);

% resize the polygon here!
if isfield(fakeAnnotation, 'object')
    for i=1:length(fakeAnnotation.object)
        for j=1:length(fakeAnnotation.object(i).polygon.pt)
            x = sscanf(fakeAnnotation.object(i).polygon.pt(j).x, '%f');
            y = sscanf(fakeAnnotation.object(i).polygon.pt(j).y, '%f');
            
            fakeAnnotation.object(i).polygon.pt(j).x = sprintf('%f', x / wSrc * 256);
            fakeAnnotation.object(i).polygon.pt(j).y = sprintf('%f', y / hSrc * 256);
        end
    end
end

defaultArgs = struct('Recompute', 0, 'ColorSpaces', [], 'MinArea', 0, 'MaxArea', 0, 'NbBins', 0);
args = parseargs(defaultArgs, varargin{:});

for i=1:numel(args.ColorSpaces)
    dbFnPrecomputeHistoObjBg(imgPath, imagesBasePath, outputBasePath, fakeAnnotation, ...
        'Recompute', args.Recompute, 'ColorSpace', args.ColorSpaces{i}, ...
        'MinArea', args.MinArea, 'MaxArea', args.MaxArea, 'NbBins', args.NbBins);
end
