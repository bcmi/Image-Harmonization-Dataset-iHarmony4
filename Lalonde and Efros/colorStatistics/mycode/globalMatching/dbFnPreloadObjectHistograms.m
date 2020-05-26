%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function dbFnPreloadObjectHistograms(outputBasePath, annotation, varargin)
%  
% 
% Input parameters:
%
% Output parameters:
%   
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function r = dbFnPreloadObjectHistograms(outputBasePath, annotation, varargin) 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
r = 0;  

global concatHisto processDatabaseImgNumber;

%% Setup
% check if the user specified the option to relabel
defaultArgs = struct('ColorSpace', [], 'ObjectDbPath', [], 'Type', [], 'MaxSizeMB', [], ...
    'Dims', []);
args = parseargs(defaultArgs, varargin{:});

if strcmp(args.ColorSpace, 'lab')
    type = 1;
    
elseif strcmp(args.ColorSpace, 'rgb')
    type = 2;
    
elseif strcmp(args.ColorSpace, 'hsv')
    type = 3;
    
elseif strcmp(args.ColorSpace, 'lalphabeta')
    type = 4;
    
else
    error('Color Space %s unsupported!', args.ColorSpace);
end

% load the histogram
histPath = fullfile(args.ObjectDbPath, annotation.file.folder, annotation.histograms(type).filename);
load(histPath);

if strcmp(args.Type, 'jointObj')
    concatHisto{processDatabaseImgNumber} = jointObjHisto; %#ok
elseif strcmp(args.Type, 'jointBg')
    concatHisto{processDatabaseImgNumber} = jointBgHisto; %#ok
elseif strcmp(args.Type, 'margObj')
    concatHisto{processDatabaseImgNumber} = margObjHisto; %#ok
elseif strcmp(args.Type, 'margBg')
    concatHisto{processDatabaseImgNumber} = margBgHisto; %#ok
else
    error('Type unsupported');
end

% check is max size is attained
sizeHisto = whos('concatHisto');
if (sizeHisto.bytes / 1024^2) > args.MaxSizeMB
    % read existing files
    nb = 0;
    files = dir(fullfile(outputBasePath, sprintf('concatHisto_%s_%s*', args.ColorSpace, args.Type)));
    if length(files)
        str = sprintf('concatHisto_%s_%s_%%04d.mat', args.ColorSpace, args.Type);
        nb = sscanf(files(end).name, str) + 1;
    end
    
    % save to file
    outputFile = fullfile(outputBasePath, sprintf('concatHisto_%s_%s_%04d.mat', args.ColorSpace, args.Type, nb));
    fprintf('Saving to file %s...\n', outputFile);
    save(outputFile, 'concatHisto');
    
    % reset concatHisto
    concatHisto = cell(args.Dims, 1);
else
    fprintf('%f MB \n', sizeHisto.bytes / 1024^2);
end



