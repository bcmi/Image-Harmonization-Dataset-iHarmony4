%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function dbFnRecolorFromNearestNeighbor(outputBasePath, annotation, varargin)
%   
% 
% Input parameters:
%
% Output parameters:
%
%    
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function r=dbFnRecolorFromCombination(outputBasePath, annotation, varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
r=0;

%% Initialize
% read arguments
defaultArgs = struct('ColorSpaces', [], 'Types', [], 'CompTypes', [], 'TextonTypes',[], 'TextonCompTypes', [], ...
    'DbPath', [], 'ObjectDb', [], 'ObjectDbPath', [], 'SubsampledImagesPath', [], 'NbClusters', 0, ...
    'ImagesPath', []);
args = parseargs(defaultArgs, varargin{:});
clear('varargin');

% read the image
img = imread(fullfile(args.ImagesPath, annotation.image.folder, annotation.image.filename));

%% Find the corresponding object and background image in the database
fprintf('Finding indices in the database...');
objImgInd = getDatabaseIndexFromFilename(args.ObjectDb, 'document', annotation.objImgSrc.folder, annotation.objImgSrc.filename);
bgImgInd = getDatabaseIndexFromFilename(args.ObjectDb, 'document', annotation.bgImgSrc.folder, annotation.bgImgSrc.filename);
fprintf('done.');

%% Load the signatures
load(fullfile(args.DbPath, annotation.file.folder, annotation.signatures(1).filename));
weightsObjOrig = weightsObj;
centersObjOrig = centersObj;
indsObjOrig = indsObj;

weightsBgOrig = weightsBg;
centersBgOrig = centersBg;


%% Load the masks
load(fullfile(args.DbPath, annotation.file.folder, annotation.object.masks.filename));

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
        
        % Load the texton distance file
        textonDistancesFile = fullfile(args.DbPath, annotation.file.folder, annotation.global.distTextonNN.(args.TextonTypes{t}).distChi.filename);
        load(textonDistancesFile);
        textonDistances = distances;
        
        % Load the texton complementary files
        textonCompDistancesFile = fullfile(args.DbPath, annotation.file.folder, annotation.global.distTextonNN.(args.TextonCompTypes{t}).distChi.filename);
        load(textonCompDistancesFile);
        textonCompDistances = distances;
        
        % only keep the valid distances
        validOrigInd = origDistances >= 0;
        validCompInd = compDistances >= 0;
        validTextonInd = textonDistances >= 0;
        
        % both must be valid
        validInd = find(validOrigInd & validCompInd & validTextonInd);
        % remove the original images from the list
        validInd = setdiff(validInd, [objImgInd bgImgInd]);

        % combine the color and texton distances with a different weight
        alpha = 0.75;
        avgOrigDistances = alpha .* origDistances + (1-alpha) .* textonDistances;
        avgCompDistances = alpha .* compDistances + (1-alpha) .* textonCompDistances;

        % get the 50 nearest neighbors
        [sortedDist, sortedInd] = sort(avgOrigDistances(validInd));
        goodInd = sortedInd(1:50);

        dist = avgCompDistances(validInd(goodInd));
        [m, mInd] = min(dist);

        % Recolor the object according to the background
        distMat = pdist2(centersObjOrig', centersBgOrig');
        [distEMD, flowEMD] = emd_mex(weightsObjOrig', weightsBgOrig', distMat);

        % use local measure to recolor
%         sigma = 25;
        sigma = inf;
        [imgTgtNNLocal, imgTgtNNWLocal] = ...
            recolorImageFromEMD(centersBgOrig, centersObjOrig, rgb2lab(img), indsObjOrig, find(objMask(:)), flowEMD, sigma);%#ok

        % use global measure to recolor
        nnInfo = args.ObjectDb(validInd(goodInd((mInd)))).document;
        nnPath = fullfile(args.SubsampledImagesPath, nnInfo.image.folder, nnInfo.image.filename);
        nnImg = imread(nnPath);

        load(fullfile(args.ObjectDbPath, nnInfo.file.folder, nnInfo.signatures(1).filename));
        centersObjNN = centersObj;
        weightsObjNN = weightsObj;

        % Recolor the object according to the nearest-neighbor object
        distMat = pdist2(centersObjOrig', centersObjNN');
        [distEMD, flowEMD] = emd_mex(weightsObjOrig', weightsObjNN', distMat);

        % Use consider all colors equally (very large sigma!)
        sigma = inf;
        [imgTgtNNGlobal, imgTgtNNWGlobal] = ...
            recolorImageFromEMD(centersObjNN, centersObjOrig, rgb2lab(img), indsObjOrig, find(objMask(:)), flowEMD, sigma); %#ok

        % save results
        imgInfo = annotation;
        % clear previous results (if present)
        if isfield(imgInfo, 'recoloredImage')
            imgInfo = rmfield(imgInfo, 'recoloredImage');
        end

        % save both the local and global
        imgInfo.recoloredImage.loc = fullfile('recoloredImage', 'local', annotation.image.filename);
        [m,m,m] = mkdir(fullfile(outputBasePath, annotation.image.folder, fileparts(imgInfo.recoloredImage.loc))); %#ok
        imwrite(lab2rgb(imgTgtNNWLocal), fullfile(outputBasePath, annotation.image.folder, imgInfo.recoloredImage.loc));
        
        imgInfo.recoloredImage.glob = fullfile('recoloredImage', 'global', annotation.image.filename);
        [m,m,m] = mkdir(fullfile(outputBasePath, annotation.image.folder, fileparts(imgInfo.recoloredImage.glob))); %#ok
        imwrite(lab2rgb(imgTgtNNWGlobal), fullfile(outputBasePath, annotation.image.folder, imgInfo.recoloredImage.glob));

        imgInfo.recoloredImage.nn = fullfile('recoloredImage', 'nn', annotation.image.filename);
        [m,m,m] = mkdir(fullfile(outputBasePath, annotation.image.folder, fileparts(imgInfo.recoloredImage.nn))); %#ok 
        imwrite(nnImg, fullfile(outputBasePath, annotation.image.folder, imgInfo.recoloredImage.nn));
        
        xmlPath = fullfile(outputBasePath, imgInfo.file.folder, imgInfo.file.filename);
        writeXML(xmlPath, imgInfo);

%         h = figure(1);
%         subplot(1,4,1), imshow(img);
%         subplot(1,4,2), imshow(nnImg), title('nearest neighbor'), subplot(1,4,3), imshow(lab2rgb(imgTgtNNWGlobal)), title(titleGlobal);
%         subplot(1,4,4), imshow(lab2rgb(imgTgtNNWLocal)), title(titleLocal);
%         drawnow;
%         pause;

    end
end
fprintf('done.\n');

