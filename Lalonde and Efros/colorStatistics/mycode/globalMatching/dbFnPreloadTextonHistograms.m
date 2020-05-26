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
function r = dbFnPreloadTextonHistograms(outputBasePath, annotation, varargin) 
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
    'Dims', [], 'ImageDb', [], 'ImageDbPath', [], 'ObjectToImageInd', []);
args = parseargs(defaultArgs, varargin{:});

w = str2double(annotation.image.size.width);
h = str2double(annotation.image.size.height);

% load the texton map
imgInfo = args.ImageDb(args.ObjectToImageInd(processDatabaseImgNumber)).document;
textonHistoPath = fullfile(args.ImageDbPath, imgInfo.file.folder, imgInfo.univTextons.textonMap);
load(textonHistoPath);

% load the polygon information and compute the masks
polygon = getPoly(annotation.object.polygon);
objMask = poly2mask(polygon(:,1), polygon(:,2), h, w);
bgMask = ~objMask;

textonObjHisto = histc(textonMap(objMask(:)), 1:1000);
textonBgHisto = histc(textonMap(bgMask(:)), 1:1000);

% normalize the histograms
textonObjHisto = textonObjHisto ./ sum(textonObjHisto(:));
textonBgHisto = textonBgHisto ./ sum(textonBgHisto(:));

if strcmp(args.Type, 'textonObj')
    concatHisto{processDatabaseImgNumber} = textonObjHisto; %#ok
elseif strcmp(args.Type, 'textonBg')
    concatHisto{processDatabaseImgNumber} = textonBgHisto; %#ok
else
    error('Type unsupported');
end

% check is max size is attained
sizeHisto = whos('concatHisto');
if (sizeHisto.bytes / 1024^2) > args.MaxSizeMB
    % read existing files
    nb = 0;
    files = dir(fullfile(outputBasePath, sprintf('concatHisto_%s*', args.Type)));
    if length(files)
        str = sprintf('concatHisto_%s_%%04d.mat', args.Type);
        nb = sscanf(files(end).name, str) + 1;
    end
    
    % save to file
    outputFile = fullfile(outputBasePath, sprintf('concatHisto_%s_%04d.mat', args.Type, nb));
    fprintf('Saving to file %s...\n', outputFile);
    save(outputFile, 'concatHisto');
    
    % reset concatHisto
    concatHisto = cell(args.Dims, 1);
else
    fprintf('%f MB \n', sizeHisto.bytes / 1024^2);
end



