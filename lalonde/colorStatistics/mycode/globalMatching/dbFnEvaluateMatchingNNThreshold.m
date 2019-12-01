%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function dbFnEvaluateMatchingNNThreshold(outputBasePath, annotation, varargin)
%   
% 
% Input parameters:
%
% Output parameters:
%
%    
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function r=dbFnEvaluateMatchingNNThreshold(outputBasePath, annotation, varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
r=0;

%% Initialize
% read arguments
defaultArgs = struct('ColorSpaces', [], 'Types', [], 'CompTypes', [], 'DbPath', [], 'ObjectDb', []);
args = parseargs(defaultArgs, varargin{:});
clear('varargin');

xmlPath = fullfile(outputBasePath, annotation.file.folder, annotation.file.filename);
imgInfo = loadXML(xmlPath);

%% Find the corresponding object and background image in the database
fprintf('Finding indices in the database...');
objImgInd = getDatabaseIndexFromFilename(args.ObjectDb, 'document', annotation.objImgSrc.folder, annotation.objImgSrc.filename);
bgImgInd = getDatabaseIndexFromFilename(args.ObjectDb, 'document', annotation.bgImgSrc.folder, annotation.bgImgSrc.filename);
fprintf('done.');

%% Compute nearest neighbor for each type and each color space
fprintf('Computing nearest-neighbors...');
% Loop over all color spaces
for c=1:length(args.ColorSpaces)
    if strcmp(args.ColorSpaces{c}, 'lab')
        colorType = 1;
    elseif strcmp(args.ColorSpaces{c}, 'lalphabeta')
        colorType = 4;
    else
        error('Unsupported color type!');
    end
    
    % Loop over all types
    for t=1:length(args.Types)
        % Load the complementary distance (object - background)
        compDistancesFile = fullfile(args.DbPath, annotation.file.folder, annotation.global.distNN.(args.CompTypes{t})(colorType).distChi.filename);
        load(compDistancesFile);
        compDistances = distances;

        % Load the distance file
        distancesFile = fullfile(args.DbPath, annotation.file.folder, annotation.global.distNN.(args.Types{t})(colorType).distChi.filename);
        load(distancesFile);
        origDistances = distances;
        
        % only keep the valid distances
        validOrigInd = origDistances >= 0;
        validCompInd = compDistances >= 0;
        
        % both must be valid
        validInd = find(validOrigInd & validCompInd);
        % remove the original images from the list
        validInd = setdiff(validInd, [objImgInd bgImgInd]);
        
        % get the 50 nearest neighbors
        [sortedDist, sortedInd] = sort(origDistances(validInd));
        goodInd = sortedInd(1:50);
        
        dist = compDistances(validInd(goodInd));
        
        type = sprintf('%s_threshold', args.Types{t});

        if ~isempty(strfind(args.Types{t}, 'marg'))
            imgInfo.globalEval(colorType).(type).marginal(1).distChi = min(dist);
            imgInfo.globalEval(colorType).(type).marginal(2).distChi = min(dist);
            imgInfo.globalEval(colorType).(type).marginal(3).distChi = min(dist);
        else
            imgInfo.globalEval(colorType).(type).joint(1).distChi = min(dist);
        end
    end
end
fprintf('done.\n');

%% Save the xml to disk
fprintf('Saving xml file: %s\n', xmlPath);
writeXML(xmlPath, imgInfo);

