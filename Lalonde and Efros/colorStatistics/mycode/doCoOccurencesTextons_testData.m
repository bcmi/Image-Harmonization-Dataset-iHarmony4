%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function doCoOccurencesTextons
%   Computes the 1st and 2nd order statistics using 3x3 texton patches
% 
% Input parameters:
%
%
% Output parameters:
%   
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function doCoOccurencesTextons_testData 
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

clusterCenterPath = '/nfs/hn01/jlalonde/results/colorStatistics/smallDataset/occurencesSmallDataset/occurencesTextons/';

dbPath = '/nfs/hn01/jlalonde/results/colorStatistics/testDataJoint/';
subDirs = {'.'};
outputBasePath = '/nfs/hn01/jlalonde/results/colorStatistics/occurencesTextons/testDataJoint/';

% read all the directories with the names 'static' and 'outdoor'
% list = dir([imagesBasePath '*static*outdoor*']);
% cellList = struct2cell(list);
% subDirs = cellList(1,:);

N = 5;
clusterCentersFile = sprintf('clusterCenters%dx%d_100000_unsorted.mat', N, N);

fprintf('Loading the cluster centers...');
load(fullfile(clusterCenterPath, clusterCentersFile));
fprintf('done.\n');

minArea = 0.05;
maxArea = 0.6;

dbFn = @dbFnTmp;

%% Call the database function
% processDatabaseParallel(imagesBasePath, subDirs, annotationsBasePath, outputBasePath, dbFn, ...
%     'ColorSpace', 'lab', 'ClusterCenters', clusterCenters, 'N', N, ...
%     'MinArea', minArea, 'MaxArea', maxArea);
processResultsDatabaseParallelFast(dbPath, outputBasePath, subDirs, dbFn, ...
    'ColorSpace', 'lab', 'ClusterCenters', clusterCenters, 'N', N, ...
    'MinArea', minArea, 'MaxArea', maxArea);

function dbFnTmp(annotation, dbPath, outputBasePath, varargin)

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

dbFnCoOccurencesTextonsObjBg(imgPath, imagesBasePath, outputBasePath, fakeAnnotation, varargin{:})
