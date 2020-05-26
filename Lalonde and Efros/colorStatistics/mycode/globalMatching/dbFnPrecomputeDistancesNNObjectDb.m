%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function dbFnPrecomputeDistancesNNObjectDb
%   
% Input parameters:
%
% Output parameters:
%    
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function r=dbFnPrecomputeDistancesNNObjectDb(outputBasePath, annotation, varargin) 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Initialize
r=0;

% read arguments
defaultArgs = struct('ColorSpace', [], 'ObjectDbPath', [], ...
    'DbPath', [], 'ImagesPath', [], 'ConcatHisto', [], 'Type', [], 'NbBins', [], ...
    'ActiveInd', [], 'NbDistances', 0);
args = parseargs(defaultArgs, varargin{:});

imgPath = fullfile(args.ImagesPath, annotation.image.folder, annotation.image.filename);
img = imread(imgPath);
[h,w,c] = size(img);

xmlPath = fullfile(outputBasePath, annotation.file.folder, annotation.file.filename);
if exist(xmlPath, 'file')
    imgInfo = loadXML(xmlPath);
else
    imgInfo.file = annotation.file;
    imgInfo.image = annotation.image;
end

%% Color space conversion
if strcmp(args.ColorSpace, 'lab')
    % convert the image to the L*a*b* color space (if asked by the user)
    fprintf('Converting to L*a*b*...\n');
    imgColor = rgb2lab(img);
    
    % L = [0 100]
    % a = [-100 100]
    % b = [-100 100]
    mins = [0 -100 -100];
    maxs = [100 100 100];
    type = 1;
    
elseif strcmp(args.ColorSpace, 'rgb')
    fprintf('Keeping RGB ...\n');
    imgColor = img;
    
    mins = [0 0 0];
    maxs = [255 255 255];
    type = 2;
    
elseif strcmp(args.ColorSpace, 'hsv')
    % convert the image to the HSV color space
    fprintf('Converting to HSV...\n');
    imgColor = rgb2hsv(img);
    
    mins = [0 0 0];
    maxs = [1 1 1];
    type = 3;
    
elseif strcmp(args.ColorSpace, 'lalphabeta')
    % convert the image to the l-alpha-beta color space
    fprintf('Converting to L-alpha-beta...\n');
    imgColor = rgb2lalphabeta(img);

    mins = [-10 -3 -0.5];
    maxs = [0 3 0.5];
    type = 4;
    
else
    error('Color Space %s unsupported!', args.ColorSpace);
end

imgVec = double(reshape(imgColor, [h*w c]));

%% Compute marginal and joint histograms 
polygon = getPoly(annotation.object.polygon);
objMask = poly2mask(polygon(:,1), polygon(:,2), h, w);
bgMask = ~objMask;

validInd = cellfun(@(x) ~isempty(x), args.ConcatHisto);

% initialize the distances
distances = [];
try
    load(fullfile(args.DbPath, annotation.file.folder, imgInfo.global.distNN.(args.Type)(type).distChi.filename));
catch
    distances = -ones(1, args.NbDistances);
end

% types = {'jointObj', 'jointBg', 'margObj', 'margBg'};
if ~isempty(strfind(args.Type, 'marg'))
    
    % marginal
    margHisto = zeros(args.NbBins, 3);
    if ~isempty(strfind(args.Type, 'Obj'))
        for c=1:3
            margHisto(:,c) = myHistoND(imgVec(objMask(:), c), args.NbBins, mins(c), maxs(c));
        end
    else
        for c=1:3
            margHisto(:,c) = myHistoND(imgVec(bgMask(:), c), args.NbBins, mins(c), maxs(c));
        end
    end
    
    dist = cellfun(@(x) chisq(x(:,1), margHisto(:,1)) + chisq(x(:,2), margHisto(:,2)) + chisq(x(:,3), margHisto(:,3)), ...
        args.ConcatHisto(validInd));
    dist = dist ./ 3;
    distances(validInd) = dist;
    
else
    % joint
    if ~isempty(strfind(args.Type, 'Obj'))
        jointHisto = myHistoND(imgVec(objMask(:), :), args.NbBins, mins, maxs);
    else
        jointHisto = myHistoND(imgVec(bgMask(:), :), args.NbBins, mins, maxs);
    end
    % only keep the useful part
    jointHisto = jointHisto(args.ActiveInd);
    
    dist = cellfun(@(x) chisq(x, jointHisto), args.ConcatHisto(validInd));
    distances(validInd) = dist;
end

imgInfo.global.distNN.(args.Type)(type).distChi.filename = fullfile('global', 'distNN', args.Type, args.ColorSpace, sprintf('%s_chi.mat', strrep(annotation.file.filename, '.xml', '')));
imgInfo.global.distNN.(args.Type)(type).nbBins = args.NbBins;
imgInfo.global.distNN.(args.Type)(type).colorSpace = args.ColorSpace;

outputFile = fullfile(outputBasePath, imgInfo.file.folder, imgInfo.global.distNN.(args.Type)(type).distChi.filename);
[m,m,m] = mkdir(fileparts(outputFile));
save(outputFile, 'distances');

%% Save the xml to disk
fprintf('Saving xml file: %s\n', xmlPath);
writeXML(xmlPath, imgInfo);



