%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function dbFnLabHistogram(imgPath, imagesBasePath, outputBasePath, annotation, varargin)
%  Computes the L*a*b* histogram on different semantic parts of the image. At this point, sky and
%  ground are supported. These regions are obtained from Derek's photo-popup results. Saves
%  histograms in .mat files, and general information in the xml file.
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function r = dbFnIlluminationContext(outputBasePath, annotation, varargin) 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

r = 0;  

% check if the user specified the option to relabel
defaultArgs = struct('Recompute', 0, 'PopupDir', [], 'ImagesPath', [], 'NbBins', 0, ...
    'IndActiveLab', [], 'IndActiveLalphabeta', []);
args = parseargs(defaultArgs, varargin{:});

if ~isfield(annotation, 'folder')
    annotation.folder = annotation.image.folder;
    annotation.filename = annotation.image.filename;
end

% load the output xml structure
xmlPath = fullfile(outputBasePath, annotation.folder, strrep(annotation.filename, '.jpg', '.xml'));
imgInfo = loadXML(xmlPath);

if ~args.Recompute && isfield(imgInfo, 'illContext')
    fprintf('Results already computed! Skipping...\n');
end

% read the image
imgPath = fullfile(args.ImagesPath, annotation.folder, annotation.filename);
img = imread(imgPath);
[h,w,c] = size(img); %#ok

popupBaseDir = args.PopupDir;

% find the photoPopup xml
xmlPopupFile = fullfile(popupBaseDir, annotation.folder, strrep(annotation.filename, '.jpg', '.xml'));

if ~exist(xmlPopupFile, 'file')
    error('No photoPopup xml found.');
end

imgInfoPopup = loadXML(xmlPopupFile);

if isfield(imgInfo, 'illContext')
    imgInfo = rmfield(imgInfo, 'illContext');
end

% We want: 
% - Full joint: Lab and Lalphabeta
% - Marginals: R,G,B -- L,a,b -- L,alpha,beta -- H,S,V

for c=1:4
    switch c
        case 1
            colorName = 'lab';
            minLimits = [0 -100 -100];
            maxLimits = [100 100 100];
            colorImg = rgb2lab(img);
            indActive = args.IndActiveLab;
        case 2
            colorName = 'hsv';
            minLimits = [0 0 0];
            maxLimits = [1 1 1];
            colorImg = rgb2hsv(img);
        case 3
            colorName = 'rgb';
            minLimits = [0 0 0];
            maxLimits = [255 255 255];
            colorImg = img;
        case 4
            colorName = 'lalphabeta';
            minLimits = [-10 -3 -0.5];
            maxLimits = [0 3 0.5];
            colorImg = rgb2lalphabeta(img);
            indActive = args.IndActiveLalphabeta;
        otherwise
            error('Invalid color');
    end

    % reshape the image as a vector
    colorImg = reshape(double(colorImg), [w*h 3]);

    % read the popup mat file
    popupMatFile = fullfile(popupBaseDir, annotation.folder, imgInfoPopup.popup.filename);
    load(popupMatFile);

    % types to compute
    typeNames = {'sky', 'ground', 'vertical'};
    typeAnnotations = {'vsky', 'v000', 'v090'};

    for i=1:size(typeNames, 2)
        fprintf('Processing type %s...', typeNames{i});

        mask = double(cimages{1}(:,:,cellfun(@(x) strcmp(x,typeAnnotations{i}), cnames, 'UniformOutput', true))); %#ok

        % make sure the images are the same size
        [hs,ws] = size(mask);

        % reshape the mask
        mask = reshape(mask, [w*h 1]);

        if w ~= ws || h ~= hs
            error('Segments image and original image must have the same size!');
        end
        
        % build the output .mat file path
        [path, baseFileName] = fileparts(annotation.filename);
        histSubDir = fullfile('illContext', colorName);
                
        histDir = fullfile(outputBasePath, annotation.folder);
        [s,s,s] = mkdir(fullfile(histDir, histSubDir)); %#ok
        
        fprintf('Computing and saving histograms for %s...', colorName);tic; 
        if c == 1 || c == 4
            % compute the joint histograms
            histoJoint = myHistoNDWeighted(colorImg, mask, args.NbBins, minLimits, maxLimits);
            
            % keep only the valid indices
            histoJoint = histoJoint(indActive); %#ok
            
            histName = fullfile(histSubDir, sprintf('%s_%s_joint.mat', baseFileName, typeNames{i}));
            imgInfo.illContext(c).(typeNames{i}).joint.filename = histName;
            
            save(fullfile(histDir, histName), 'histoJoint');
        end

        % compute the marginal histograms
        for d=1:3
            histoMarginal = myHistoNDWeighted(colorImg(:,d), mask, args.NbBins, minLimits(d), maxLimits(d)); %#ok
            
            histName = fullfile(histSubDir, sprintf('%s_%s_marg_%d.mat', baseFileName, typeNames{i}, d));
            imgInfo.illContext(c).(typeNames{i}).marginal(d).filename = histName;
            
            save(fullfile(histDir, histName), 'histoMarginal');
        end
    
        fprintf('done in %fs\n', toc);
    end

    % save xml information
    imgInfo.illContext(c).name = colorName;
    imgInfo.illContext(c).nbBins = num2str(args.NbBins);
end

% save the file (overwrite)
fprintf('Saving xml file: %s\n', xmlPath);
writeXML(xmlPath, imgInfo);

