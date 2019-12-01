%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function doSplitLabelledData
%   Splits the labelled data into realistic, unrealistic and conflicting groups
% 
% Input parameters:
%
%   - varargin: Possible values:
%     - 'Recompute':
%       - 0: (default) will not compute the histogram when results are
%         already available. 
%       - 1: will re-compute histogram no matter what
%
% Output parameters:
%
%    
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function doSplitLabelledData
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
addpath '../database/';

% define the input and output paths
dbPath = '/nfs/hn01/jlalonde/results/colorStatistics/testDataSemantic/testDataSemantic/';
outputRealisticPath = '/nfs/hn01/jlalonde/results/colorStatistics/testDataSemantic/split/testDataRealistic/';
outputUnrealisticPath = '/nfs/hn01/jlalonde/results/colorStatistics/testDataSemantic/split/testDataUnrealistic/';
outputConflictingPath = '/nfs/hn01/jlalonde/results/colorStatistics/testDataSemantic/split/testDataConflicting/';

subDirs = {'.'};

dbFn = @dbFnSplitData;

% call the database function
processResultsDatabaseFast(dbPath, '', subDirs, dbFn, 'UnrealisticPath', outputUnrealisticPath, ...
    'RealisticPath', outputRealisticPath, 'ConflictingPath', outputConflictingPath);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function dbFnManualLabelTestSet
%   Manually label the test set
% 
% Input parameters:
%
%   - varargin: Possible values:
%     - 'Recompute':
%       - 0: (default) will not compute the histogram when results are
%         already available. 
%       - 1: will re-compute histogram no matter what
%
% Output parameters:
%
%    
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function dbFnSplitData(annotation, dbPath, outputBasePath, varargin)
addpath ../../3rd_party/parseArgs;

% check if the user specified the option to recompute
defaultArgs = struct('Recompute', 1, 'UnrealisticPath', [], 'RealisticPath', [], 'ConflictingPath', []);
args = parseargs(defaultArgs, varargin{:});

% if sscanf(imgInfo.generated, '%d')
if isfield(annotation, 'class')
    nbLabelers = length(annotation.class);
    
    type = annotation.class(1).type;
    for i=2:nbLabelers
        if ~strcmp(type, 'o') && ~strcmp(type, annotation.class(i).type) && ~strcmp(annotation.class(i).type, 'o')
            type = 'c';
            fprintf('Labeling conflict!\n');
            break;
        else
            type = 'o';
        end
    end
    
    cmd = [];
    if strcmp(type, 'r')
        cmd = sprintf('cp %s %s', fullfile(dbPath, annotation.image.folder, annotation.image.filename), fullfile(args.RealisticPath, annotation.image.filename));
    elseif strcmp(type, 'u')
        cmd = sprintf('cp %s %s', fullfile(dbPath, annotation.image.folder, annotation.image.filename), fullfile(args.UnrealisticPath, annotation.image.filename));
    elseif strcmp(type, 'c')
        cmd = sprintf('cp %s %s', fullfile(dbPath, annotation.image.folder, annotation.image.filename), fullfile(args.ConflictingPath, annotation.image.filename));
    end
    if ~isempty(cmd)
        system(cmd);
    else
        fprintf('%s labeled as other...\n', annotation.image.filename);
    end
else
    fprintf('%s unlabeled yet...\n', annotation.image.filename);
end
% end
