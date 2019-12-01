%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function doCompileOccurencesTextonsSplit
%   Compiles the textons results obtained from the training data
% 
% Input parameters:
%
% Output parameters:
%
%    
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function doCompileOccurenceTextonsNNglobal histoImg histoBg histoObj indObj indImg nbImg nbObjects;
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

addpath '../database/';

% define the input and output paths
dbPath = '/nfs/hn01/jlalonde/results/colorStatistics/occurencesTextons/trainData/';
outputDbPath = '/nfs/hn01/jlalonde/results/colorStatistics/occurencesTextons/';
dbFn = @dbFnCompileOccurenteTextonsNN;
% subDirs = {'images'};

% read all the directories with the names 'static' and 'outdoor'
list = dir([dbPath '*static*outdoor*']);
cellList = struct2cell(list);
subDirs = cellList(1,:);
% subDirs = {'april21_static_outdoor_davis'};

N = 5;

% just count how many objects we have
nbObjects = 0; nbImg = 0;
processResultsDatabaseFast(dbPath, outputDbPath, subDirs, @dbFnCount, 'N', N);

fprintf('Number of objects found: %d\n', nbObjects);
fprintf('Number of images found: %d\n', nbImg);

% call the database function
histoImg = zeros(nbImg, 10000, 'single'); 
histoBg = zeros(nbObjects, 10000, 'single'); 
histoObj = zeros(nbObjects, 10000, 'single'); 
indObj = zeros(nbObjects, 1); 
indImg = zeros(nbObjects, 1); 

nbImg = 0; nbObjects = 0;
processResultsDatabaseFast(dbPath, outputDbPath, subDirs, dbFn, 'N', N);

% re-convert back to sparse
histoImg = sparse(double(histoImg));
histoBg = sparse(double(histoBg));
histoObj = sparse(double(histoObj));

% save the acumulated histograms
save(fullfile(outputDbPath, sprintf('trainDataTextons_%dx%d.mat', N, N)), 'histoImg', 'histoBg', 'histoObj', 'indObj', 'indImg');

function dbFnCount(annotation, dbPath, outputBasePath, varargin)
global nbObjects nbImg;

if isfield(annotation, 'colorStatisticsTextons5x5ObjBgUnsorted')
    if (isfield(annotation.colorStatisticsTextons5x5ObjBgUnsorted, 'file'))
        % load the histogram
        load(fullfile(dbPath, annotation.image.folder, annotation.colorStatisticsTextons5x5ObjBgUnsorted.file));
        
        nbObjects = nbObjects + size(textonHistObj, 1);
        nbImg = nbImg + 1;
    end
end


function dbFnCompileOccurenteTextonsNN(annotation, dbPath, outputBasePath, varargin)
global histoImg histoBg histoObj indObj indImg nbImg nbObjects;

if isfield(annotation, 'colorStatisticsTextons5x5ObjBgUnsorted')
    if (isfield(annotation.colorStatisticsTextons5x5ObjBgUnsorted, 'file'))
        % load the histogram
        load(fullfile(dbPath, annotation.image.folder, annotation.colorStatisticsTextons5x5ObjBgUnsorted.file));
        
        nbImg = nbImg + 1;

        % stack it onto the existing histogram
        nbObjCur = size(textonHistObj, 1);
        
        histoImg(nbImg,:) = single(full(textonHistImg'));
        
        histoBg(nbObjects+1:nbObjects+nbObjCur, :) = single(full(textonHistBg));
        histoObj(nbObjects+1:nbObjects+nbObjCur, :) = single(full(textonHistObj));
        
        indObj(nbObjects+1:nbObjects+nbObjCur, :) = (1:size(textonHistObj, 1))';
        indImg(nbObjects+1:nbObjects+nbObjCur, :) = repmat(nbImg, size(textonHistObj, 1), 1);
        
        nbObjects = nbObjects + nbObjCur;
    end
end
totSize = 0;
s = whos('histoImg'); totSize = totSize + s.bytes;
s = whos('histoObj'); totSize = totSize + s.bytes;
s = whos('histoBg'); totSize = totSize + s.bytes;

fprintf('Total size of accumulated histograms: %f MB\n', totSize / 1024^2);

