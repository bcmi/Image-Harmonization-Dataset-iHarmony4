%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function dbFnComputeIlluminationDistance(outputBasePath, annotation, varargin)
%  
% 
% Input parameters:
%
%
% Output parameters:
%   
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function r = dbFnComputeIlluminationDistance(outputBasePath, annotation, varargin) 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
r = 0;  

% check if the user specified the option to relabel
defaultArgs = struct('AccHistoJoint', [], 'AccHistoMarginals', [], 'Type', [], 'ImagesPath', [], ...
    'ColorIndex', 0, 'NbBins', 0, 'PopupDbPath', []);
args = parseargs(defaultArgs, varargin{:});
clear varargin;

xmlPath = fullfile(outputBasePath, annotation.file.folder, annotation.file.filename);

imgInfo.file = annotation.file;
imgInfo.image = annotation.image;

xmlPopupPath = fullfile(args.PopupDbPath, annotation.file.folder, annotation.file.filename);
imgInfoPopup = loadXML(xmlPopupPath);
colorIndex = {'lab', 'hsv', 'rgb', 'lalphabeta'};
[path, baseFilename] = fileparts(annotation.file.filename);

if args.ColorIndex == 1 || args.ColorIndex == 4
    % Load the image's joint histogram
    histoPath = fullfile(args.PopupDbPath, imgInfoPopup.file.folder, imgInfoPopup.illContext(args.ColorIndex).(args.Type).joint.filename);
    load(histoPath);
    
    % Find the valid indices only
    validInd = cellfun(@(x) ~isempty(x), args.AccHistoJoint);
    
    % Compute the chi-square distance from the histogram to all others
    fprintf('Computing pairwise distances for joint histograms...'); tic;
    dist = cellfun(@(x) chisq(full(x), histoJoint), args.AccHistoJoint(validInd));
    fprintf('done in %fs\n', toc);
    
    % Save a distance vector for the valid indices only, and -1 otherwise
    distancesJoint = -ones(1, length(args.AccHistoJoint));
    distancesJoint(validInd) = dist; %#ok
    
    outputBaseJointPath = 'joint';
    [m,m,m] = mkdir(fullfile(outputBasePath, outputBaseJointPath));
    outputJointPath = fullfile(outputBaseJointPath, sprintf('%s.mat', baseFilename));
    save(fullfile(outputBasePath, annotation.file.folder, outputJointPath), 'distancesJoint');
    imgInfo.distances.(args.Type).(colorIndex{args.ColorIndex}).joint.filename = outputJointPath;
end

% Now do it for the marginals
distancesMarginals = -ones(3, size(args.AccHistoMarginals,1));
fprintf('Computing pairwise distances for marginal histograms...'); tic;
for i=1:3
    % Load the image's marginal histogram
    histoPath = fullfile(args.PopupDbPath, imgInfoPopup.file.folder, imgInfoPopup.illContext(args.ColorIndex).(args.Type).marginal(i).filename);
    load(histoPath);
    
    % Find the valid indices only
    dbHistMarginals = args.AccHistoMarginals(:,i);
    validInd = cellfun(@(x) ~isempty(x), dbHistMarginals);
    
    % Compute the chi-square distance from the histogram to all others
    dist = cellfun(@(x) chisq(full(x), histoMarginal), dbHistMarginals(validInd));
    
    % Save a distance vector for the valid indices only, and -1 otherwise
    distancesMarginals(i, validInd) = dist; %#ok
end
fprintf('done in %fs\n', toc);

outputMargBasePath = 'marginals';
[m,m,m] = mkdir(fullfile(outputBasePath, outputMargBasePath));
outputMargPath = fullfile(outputMargBasePath, sprintf('%s.mat', baseFilename));
save(fullfile(outputBasePath, annotation.file.folder, outputMargPath), 'distancesMarginals');
imgInfo.distances.(args.Type).(colorIndex{args.ColorIndex}).marginals.filename = outputMargPath;

% save the file (overwrite)
fprintf('Saving xml file: %s\n', xmlPath);
writeXML(xmlPath, imgInfo);