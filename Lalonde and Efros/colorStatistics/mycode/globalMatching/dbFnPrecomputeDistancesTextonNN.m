%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function dbFnPrecomputeDistancesTextonNN
%   
% Input parameters:
%
% Output parameters:
%    
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function r=dbFnPrecomputeDistancesTextonNN(outputBasePath, annotation, varargin) 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Initialize
r=0;

% read arguments
defaultArgs = struct('ObjectDbPath', [], 'ImageDbPath', [], 'DbPath', [], ...
    'ImagesPath', [], 'ConcatHisto', [], 'Type', [], 'NbDistances', 0, ...
    'SyntheticDbPath', []);
args = parseargs(defaultArgs, varargin{:});

% read the image
imgPath = fullfile(args.ImagesPath, annotation.image.folder, annotation.image.filename);
img = imread(imgPath);
[h,w,c] = size(img); %#ok

% read the source image texton map
objImgInfo = loadXML(fullfile(args.ImageDbPath, annotation.objImgSrc.folder, strrep(annotation.objImgSrc.filename, '.jpg', '.xml')));
objTextonMapPath = fullfile(args.ImageDbPath, objImgInfo.file.folder, objImgInfo.univTextons.textonMap);
load(objTextonMapPath); objTextonMap = textonMap;

% read the background image texton map
bgImgInfo = loadXML(fullfile(args.ImageDbPath, annotation.bgImgSrc.folder, strrep(annotation.bgImgSrc.filename, '.jpg', '.xml')));
bgTextonMapPath = fullfile(args.ImageDbPath, bgImgInfo.file.folder, bgImgInfo.univTextons.textonMap);
load(bgTextonMapPath); bgTextonMap = textonMap;

% load the masks
load(fullfile(args.SyntheticDbPath, annotation.file.folder, annotation.object.masks.filename)); %bgMask, objMask
% resize the background mask to the source image size
bgMask = imresize(bgMask, [str2double(bgImgInfo.image.size.height) str2double(bgImgInfo.image.size.width)], 'nearest'); %#ok

% re-build the object mask
objInfo = loadXML(fullfile(args.ObjectDbPath, objImgInfo.file.folder, ...
    sprintf('%s_%04d.xml', strrep(objImgInfo.file.filename, '.xml', ''), str2double(annotation.object.objectId))));
objPoly = getPoly(objInfo.object.polygon);
objMask = poly2mask(objPoly(:,1), objPoly(:,2), str2double(objImgInfo.image.size.height), str2double(objImgInfo.image.size.width));

%% Compute marginal and joint histograms 
validInd = cellfun(@(x) ~isempty(x), args.ConcatHisto);

% initialize the distances
distances = [];
xmlPath = fullfile(outputBasePath, annotation.file.folder, annotation.file.filename);
try
    % load existing xml information (if present)
    imgInfo = loadXML(xmlPath);
    load(fullfile(args.DbPath, annotation.file.folder, imgInfo.global.distTextonNN.(args.Type).distChi.filename));
catch
    distances = -ones(1, args.NbDistances);
end

% compute normalized histograms
objTextonHist = histc(objTextonMap(objMask(:)), 1:1000); objTextonHist = objTextonHist ./ sum(objTextonHist(:));
bgTextonHist = histc(bgTextonMap(bgMask(:)), 1:1000); bgTextonHist = bgTextonHist ./ sum(bgTextonHist(:));

% types = {'textonObj', 'textonBg'};
if ~isempty(strfind(args.Type, 'Obj'))
    % compute the object's texton histogram
    textonHist = objTextonHist;
else
    textonHist = bgTextonHist;
end
dist = cellfun(@(x) chisq(x, textonHist), args.ConcatHisto(validInd));
distances(validInd) = dist;

% save the texton histograms
imgInfo.textons.histograms.filename = fullfile('textons', strrep(annotation.file.filename, '.xml', '.mat'));
outputFile = fullfile(outputBasePath, imgInfo.file.folder, imgInfo.textons.histograms.filename);
[m,m,m] = mkdir(fileparts(outputFile));
save(outputFile, 'objTextonHist', 'bgTextonHist');

imgInfo.global.distTextonNN.(args.Type).distChi.filename = fullfile('global', 'distTextonNN', args.Type, sprintf('%s_chi.mat', strrep(annotation.file.filename, '.xml', '')));

outputFile = fullfile(outputBasePath, imgInfo.file.folder, imgInfo.global.distTextonNN.(args.Type).distChi.filename);
[m,m,m] = mkdir(fileparts(outputFile));
save(outputFile, 'distances');

%% Save the xml to disk
fprintf('Saving xml file: %s\n', xmlPath);
writeXML(xmlPath, imgInfo);



