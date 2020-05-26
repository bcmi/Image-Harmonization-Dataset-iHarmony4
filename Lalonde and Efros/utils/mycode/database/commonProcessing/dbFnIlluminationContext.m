%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function dbFnIlluminationContext
%  Computes the L*a*b* histogram on different semantic parts of the image. At this point, sky and
%  ground are supported. These regions are obtained from Derek's photo-popup results. Saves
%  histograms in .mat files, and general information in the xml file.
% 
% Input parameters:
%
% Output parameters:
%   
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function r = dbFnIlluminationContext(outputBasePath, annotation, varargin) 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

r = 0;  

% parse input parameters
defaultArgs = struct('Recompute', 0, 'PopupDir', [], 'ImagesPath', [], 'NbBins', 0);
args = parseargs(defaultArgs, varargin{:});

% load the output xml structure
xmlPath = fullfile(outputBasePath, annotation.file.folder, annotation.file.filename);
if exist(xmlPath, 'file')
    imgInfo = loadXML(xmlPath);
else
    fprintf('File not found! Skipping...\n');
    return;
end

if ~args.Recompute && isfield(imgInfo, 'illContext')
    fprintf('Results already computed! Skipping...\n');
    return;
end

% read the image
imgPath = fullfile(args.ImagesPath, annotation.image.folder, annotation.image.filename);
img = imread(imgPath);
[h,w,c] = size(img); %#ok

% find the photoPopup xml
xmlPopupFile = fullfile(args.PopupDir, annotation.file.folder, annotation.file.filename);

if ~exist(xmlPopupFile, 'file')
    error('No photoPopup xml found.');
end

imgInfoPopup = loadXML(xmlPopupFile);

minLimits = [0 -100 -100];
maxLimits = [100 100 100];
colorImg = rgb2lab(img);

% reshape the image as a vector
colorImg = reshape(double(colorImg), [w*h 3]);

% read the popup mat file
popupMatFile = fullfile(args.PopupDir, imgInfoPopup.file.folder, imgInfoPopup.popup.filename);
load(popupMatFile);

% types to compute
typeNames = {'sky', 'ground', 'vertical'};
typeAnnotations = {'sky', '000', '090'};

for i=1:size(typeNames, 2)
    fprintf('Processing type %s...', typeNames{i});

    mask = double(cimages(:,:,cellfun(@(x) strcmp(x,typeAnnotations{i}), cnames))); %#ok
    
    % resize the mask to be the same size as the image
    mask = imresize(mask, [h w]);

    % reshape the mask
    mask = reshape(mask, [w*h 1]);
    
    % build the output .mat file path
    [path, baseFileName] = fileparts(annotation.file.filename);
    histSubDir = 'illContext';

    histDir = fullfile(outputBasePath, annotation.file.folder);
    [s,s,s] = mkdir(fullfile(histDir, histSubDir)); %#ok

    fprintf('Computing and saving histograms...'); tic;

    % compute the joint histograms
    histo = myHistoNDWeighted(colorImg, mask, args.NbBins, minLimits, maxLimits);
    
    % save in sparse format to save disk space
    histoSparse = sparse(reshape(histo, args.NbBins^2, args.NbBins));

    histName = fullfile(histSubDir, sprintf('%s_%s.mat', baseFileName, typeNames{i}));
    imgInfo.illContext.filename = histName;

    save(fullfile(histDir, histName), 'histoSparse');
    fprintf('done in %.2fs\n', toc);
end

% save the file (overwrite)
fprintf('Saving xml file: %s\n', xmlPath);
writeXML(xmlPath, imgInfo);

