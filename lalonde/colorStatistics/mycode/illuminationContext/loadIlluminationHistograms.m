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
function loadIlluminationHistograms(type)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global globAccHistoJoint globAccHistoMarginals globCount;
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
load(fullfile(outputBasePath, 'indActiveLab_50.mat'));
load(fullfile(outputBasePath, 'indActiveLalphabeta_50.mat'));

%% Load all the histograms into several fairly small structures (big enough to fit into 1GB of ram)
maxSize = 500; % MB
dbFn = @dbFnLoadHistos;
parallelized = 0;
randomized = 0;

% globCount = 0;

% ** WARNING: This should loop over a preloaded database!!
% processResultsDatabaseFast(imagesPath, '', outputBasePath, dbFn, parallelized, randomized, ...
%     'Type', type, 'MaxSize', maxSize, 'TotalLength', length(imageDb), 'ImagesPath', imagesPath, ...
%     'ColorIndex', colorIndex);

% Loop over all the color indices
colorIndex = {'lab', 'hsv', 'rgb', 'lalphabeta'};
for i=1:4
    globAccHistoJoint = {};
    if i == 1
        globAccHistoJoint = cell(length(imageDb), 1); % sparse(length(imageDb), length(indActiveLab));
    elseif i == 4
        globAccHistoJoint = cell(length(imageDb), 1); % sparse(length(imageDb), length(indActiveLalphabeta));
    end
    
    globAccHistoMarginals = cell(length(imageDb), 4); % sparse(length(imageDb), nbBins);

    processDatabase(imageDb, outputBasePath, dbFn, parallelized, randomized, ...
        'document', 'image.filename', 'image.folder', 'Type', type, 'MaxSize', maxSize, ...
        'TotalLength', length(imageDb), 'ImagesPath', imagesPath, 'ColorIndex', i);
    
    % save to file
    save(fullfile(outputBasePath, sprintf('concatHisto_%s_%s.mat', type, colorIndex{i})), ...
        'globAccHistoJoint', 'globAccHistoMarginals');
    
end


function r = dbFnLoadHistos(outputBasePath, annotation, varargin) 
global globAccHistoJoint globAccHistoMarginals globCount processDatabaseImgNumber;
r = 0;  

defaultArgs = struct('Type', [], 'MaxSize', 0, 'TotalLength', 0, 'ImagesPath', [], 'ColorIndex', 0);
args = parseargs(defaultArgs, varargin{:});
    
if isfield(annotation, 'illContext')
    if isfield(annotation.illContext, args.Type)
        if args.ColorIndex == 1 || args.ColorIndex == 4
            % load the joint
            load(fullfile(args.ImagesPath, annotation.image.folder, annotation.illContext(args.ColorIndex).(args.Type).joint.filename));
            globAccHistoJoint{processDatabaseImgNumber} = sparse(histoJoint);
        end
        
        % load the marginals
        for i=1:3
            load(fullfile(args.ImagesPath, annotation.image.folder, annotation.illContext(args.ColorIndex).(args.Type).marginal(i).filename));
            globAccHistoMarginals{processDatabaseImgNumber, i} = sparse(histoMarginal);
        end
    end
end

iJoint = whos('globAccHistoJoint');
iMarginal = whos('globAccHistoMarginals');
cumulSize = (iJoint.bytes + iMarginal.bytes) / 1024^2;
fprintf('Total size: %fMB\n', cumulSize);

% if cumulSize > args.MaxSize
%     % save to file
%     outputFile = fullfile(outputBasePath, sprintf('cumul_%s_%04d.mat', args.Type, globCount));
%     fprintf('Saving %s...', outputFile);
%     save(outputFile, 'globAccHisto');
%     fprintf('done.\n');
%     
%     % reset the size to 0
%     globAccHisto = cell(1, args.TotalLength);
%     globCount = globCount + 1;
% end


