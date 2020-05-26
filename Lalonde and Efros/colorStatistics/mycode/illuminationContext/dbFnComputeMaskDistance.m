%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function dbFnComputeMaskDistance(outputBasePath, annotation, varargin)
%  
% 
% Input parameters:
%
%
% Output parameters:
%   
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function r = dbFnComputeMaskDistance(outputBasePath, annotation, varargin) 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
r = 0;  

% check if the user specified the option to relabel
defaultArgs = struct('AccMasks', [], 'Type', [], 'PopupDbPath', []);
args = parseargs(defaultArgs, varargin{:});
clear varargin;

xmlPath = fullfile(outputBasePath, annotation.file.folder, annotation.file.filename);

imgInfo.file = annotation.file;
imgInfo.image = annotation.image;

xmlPopupPath = fullfile(args.PopupDbPath, annotation.file.folder, annotation.file.filename);
imgInfoPopup = loadXML(xmlPopupPath);
[path, baseFilename] = fileparts(annotation.file.filename);

% Load the image's joint histogram
maskPath = fullfile(args.PopupDbPath, imgInfoPopup.file.folder, imgInfoPopup.popup.masks.(args.Type));
load(maskPath);

% Find the valid indices only
validInd = cellfun(@(x) ~isempty(x), args.AccMasks);

% Compute the chi-square distance from the histogram to all others
fprintf('Computing pairwise distances for masks...'); tic;
dist = cellfun(@(x) sum(sum((double(x) - double(mask)).^2)), args.AccMasks(validInd));
fprintf('done in %fs\n', toc);

% Save a distance vector for the valid indices only, and -1 otherwise
distances = -ones(1, length(args.AccMasks));
distances(validInd) = dist; %#ok

outputBaseMaskPath = 'distances';
[m,m,m] = mkdir(fullfile(outputBasePath, outputBaseMaskPath));
outputMaskPath = fullfile(outputBaseMaskPath, sprintf('%s.mat', baseFilename));
save(fullfile(outputBasePath, annotation.file.folder, outputMaskPath), 'distances');
imgInfo.distances.(args.Type) = outputMaskPath;

% save the file (overwrite)
fprintf('Saving xml file: %s\n', xmlPath);
writeXML(xmlPath, imgInfo);