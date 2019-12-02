%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function 
% 
% Input parameters:
%
% Output parameters:
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function groupKeywordMasks(objectDb, topKeywords, topIndices)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Setup paths
addpath ../;
setPath;

basePath = '/nfs/hn01/jlalonde/results/colorStatistics';
objectDbPath = fullfile(basePath, 'objectDb');
databasesPath = fullfile(basePath, 'databases');
outputPath = fullfile(databasesPath, 'maskStacks');

if nargin == 0
    load(fullfile(databasesPath, 'objectDb.mat'));
    load(fullfile(databasesPath, 'keywordIndices.mat'));
end

maskWidth = 128;

%% Loop over all keywords, load the masks and stack them into one big matrix
for k=1:length(topKeywords)
    maskIndices = topIndices{k};
    
    maskStack = logical(zeros(maskWidth, maskWidth, length(maskIndices))); %#ok
    for i=maskIndices
        % Load the mask
        maskPath = fullfile(objectDbPath, objectDb(i).document.image.folder, objectDb(i).document.mask.transMask.filename);
        load(maskPath);
        
        % 256x256 is too big. let's resize it to 128x128
        mask = imresize(mask, [maskWidth maskWidth], 'nearest');
        
        % Stack into one big matrix
        maskStack(:,:,maskIndices==i) = mask;
    end
    
    % we're done stacking the masks for this keyword. Save the stack to file
    stackFilename = fullfile(outputPath, sprintf('%s_stack.mat', topKeywords{k}));
    fprintf('Saving %s...\n', stackFilename);
    save(stackFilename, 'maskStack', 'maskIndices');
end