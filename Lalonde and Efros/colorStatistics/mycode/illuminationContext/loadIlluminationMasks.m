%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%,
% function loadIlluminationMasks(type)
%  Loads all the illumination masks into one giant structure
% 
% Input parameters:
%  - type: either 'sky', 'ground' or 'vertical'. Indicates which type of geometric structure
%    to load.
%
% Output parameters:
%   
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function loadIlluminationMasks(type)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global globAccMasks;
addpath ../;
setPath;

fprintf('Loading masks for %s...\n', type);

popupBasePath = '/nfs/hn25/labelmePopup';
dbBasePath = '/nfs/hn01/jlalonde/results/colorStatistics';
outputBasePath = fullfile(dbBasePath, 'illuminationContext', 'concatMasks');
databasesPath = fullfile(dbBasePath, 'databases');

% Load the image database and the indices
load(fullfile(databasesPath, 'imageDb.mat'));
load(fullfile(databasesPath, 'objImgIndices.mat'));

dbFn = @dbFnLoadMasks;
parallelized = 0;
randomized = 0;

globAccMasks = cell(1, length(imageDb));

% Loop over all the color indices
processDatabase(imageDb, outputBasePath, dbFn, parallelized, randomized, ...
    'document', 'image.filename', 'image.folder', 'Type', type, ...
    'PopupPath', popupBasePath);
    
% save to file
save(fullfile(outputBasePath, sprintf('concatMasks_%s.mat', type)), 'globAccMasks');
    
function r = dbFnLoadMasks(outputBasePath, annotation, varargin) 
global globAccMasks processDatabaseImgNumber
r = 0;  

defaultArgs = struct('Type', [], 'PopupPath', []);
args = parseargs(defaultArgs, varargin{:});

xmlPopupPath = fullfile(args.PopupPath, annotation.file.folder, annotation.file.filename);
imgInfoPopup = loadXML(xmlPopupPath);

load(fullfile(args.PopupPath, annotation.file.folder, imgInfoPopup.popup.masks.(args.Type)));
globAccMasks{processDatabaseImgNumber} = mask;
    
m = whos('globAccMasks');
cumulSize = m.bytes / 1024^2;
fprintf('Total size: %fMB\n', cumulSize);

