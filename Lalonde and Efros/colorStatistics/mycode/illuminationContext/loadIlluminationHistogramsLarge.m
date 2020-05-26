%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function loadHistos(type)
%  Loads all the histograms and stacks them into several ~500MB structure. 
%  Should greatly speed up the nearest-neighbor computation
% 
% Input parameters:
%  - type: either 'sky', 'ground' or 'vertical'. Indicates which type of geometric structure
%    to load.
%
% Output parameters:
%   
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function loadIlluminationHistogramsLarge(type)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global globAccHisto globCount;
addpath ../;
setPath;

fprintf('Computing histograms for %s...\n', type);

dbBasePath = '/nfs/hn01/jlalonde/results/colorStatistics';
outputBasePath = fullfile(dbBasePath, 'illuminationContext', 'concatHistograms');
databasesPath = fullfile(dbBasePath, 'databases');
imagesPath = fullfile(dbBasePath, 'imageDb');

% Load the image database and the indices
load(fullfile(databasesPath, 'imageDb.mat'));
load(fullfile(databasesPath, 'objImgIndices.mat'));

%% Load all the histograms into several fairly small structures (big enough to fit into 1GB of ram)
maxSize = 500; % MB
dbFn = @dbFnLoadHistos;
parallelized = 0;
randomized = 0;
globAccHisto = cell(1, length(imageDb));
globCount = 0;

processDatabase(imageDb, outputBasePath, dbFn, parallelized, randomized, ...
    'document', 'image.filename', 'image.folder', 'Type', type, 'MaxSize', maxSize, ...
    'TotalLength', length(imageDb), 'ImagesPath', imagesPath);

function r = dbFnLoadHistos(outputBasePath, annotation, varargin) 
global globAccHisto globCount processDatabaseImgNumber;
r = 0;  

defaultArgs = struct('Type', [], 'MaxSize', 0, 'TotalLength', 0, 'ImagesPath', []);
args = parseargs(defaultArgs, varargin{:});
    
if isfield(annotation, 'illContext')
    if isfield(annotation.illContext, args.Type)
        % use only lab
        load(fullfile(args.ImagesPath, annotation.image.folder, annotation.illContext(1).(args.Type).filename));

        globAccHisto{processDatabaseImgNumber} = histo;
    end
end

a=whos('globAccHisto');
cumulSize = a.bytes / 1024^2;
fprintf('Total size: %fMB\n', cumulSize);

if cumulSize > args.MaxSize
    % save to file
    outputFile = fullfile(outputBasePath, sprintf('cumul_%s_%04d.mat', args.Type, globCount));
    fprintf('Saving %s...', outputFile);
    save(outputFile, 'globAccHisto');
    fprintf('done.\n');
    
    % reset the size to 0
    globAccHisto = cell(1, args.TotalLength);
    globCount = globCount + 1;
end


