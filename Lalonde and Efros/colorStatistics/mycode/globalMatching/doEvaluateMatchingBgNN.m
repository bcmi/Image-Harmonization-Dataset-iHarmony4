%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function doEvaluateMatchingBgNN
%   Evaluate the chi-square distance between the object and the
%   background's histograms
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
function doEvaluateMatchingBgNN 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
addpath ../;
setPath;

% define the input and output paths
dataPath = '/nfs/hn01/jlalonde/results/colorStatistics/testDataSemantic/';
dbPath = '/nfs/hn01/jlalonde/results/colorStatistics/testData/';
outputBasePath = '/nfs/hn01/jlalonde/results/colorStatistics/matchingResults/testData/';
subDirs = {'.'};

dbFn = @dbFnTmpMatching;
colorSpaces = {'lab', 'rgb', 'hsv'};

% load stuff
fprintf('Loading the database...');
load(fullfile(dataPath, 'db.mat'));

fprintf('Loading the object''s indices...');
load(fullfile(dataPath, 'maskInfo.mat'));

fprintf('Loading the object''s histograms...');
load(fullfile(dataPath, 'histogramsInfo.mat'));

fprintf('Loading the background''s histograms...');
load(fullfile(dataPath, 'backgroundsInfo.mat'));
fprintf('done.\n');


%% call the database function
processResultsDatabaseParallelFast(dbPath, outputBasePath, subDirs, dbFn, ...
    'ColorSpaces', colorSpaces, 'ImgIndVec', imgIndVec, 'ObjIndVec', objIndVec, ...
    'MarginalVec', marginalVec, 'JointVec', jointVec, ...
    'MarginalVecBg', marginalVecBg, 'JointVecBg', jointVecBg, 'Database', D);

%% Simply call the database function with several colorspaces
function dbFnTmpMatching(annotation, dbPath, outputBasePath, varargin)

defaultArgs = struct('ColorSpaces', [], 'ImgIndVec', [], 'ObjIndVec', [], ...
    'MarginalVec', [], 'JointVec', [], 'MarginalVecBg', [], 'JointVecBg', [], 'Database', []);
args = parseargs(defaultArgs, varargin{:});

for i=1:length(args.ColorSpaces)
    dbFnEvaluateMatchingBgNN(annotation, dbPath, outputBasePath, ...
        'ColorSpace', args.ColorSpaces{i}, 'ImgIndVec', args.ImgIndVec, ...
        'ObjIndVec', args.ObjIndVec, 'MarginalVec', args.MarginalVec, ...
        'JointVec', args.JointVec, 'MarginalVecBg', args.MarginalVecBg, ...
        'JointVecBg', args.JointVecBg, 'Database', args.Database);
end
