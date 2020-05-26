%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function dbFnEvaluateMatchingNNColorTextonThreshold(outputBasePath, annotation, varargin)
%   
% 
% Input parameters:
%
% Output parameters:
%
%    
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function r=dbFnEvaluateMatchingNNColorTextonThreshold(outputBasePath, annotation, varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
r=0;

%% Initialize
% read arguments
defaultArgs = struct('ColorSpaces', [], 'Types', [], 'CompTypes', [], 'TextonTypes',[], 'TextonCompTypes', [], ...
    'DbPath', [], 'ObjectDb', [], 'ImagesPath', []);
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
        
        % Load the texton distance file
        textonDistancesFile = fullfile(args.DbPath, annotation.file.folder, annotation.global.distTextonNN.(args.TextonTypes{t}).distChi.filename);
        load(textonDistancesFile);
        textonDistances = distances;
        
        % Load the texton complementary distance file
        textonDistancesFile = fullfile(args.DbPath, annotation.file.folder, annotation.global.distTextonNN.(args.TextonCompTypes{t}).distChi.filename);
        load(textonDistancesFile);
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
%         alphas = [0 0.25 0.5 0.75 1];
        alphas = 0.5;
        for alpha=alphas
            avgOrigDistances = alpha .* origDistances + (1-alpha) .* textonDistances;
            avgCompDistances = alpha .* compDistances + (1-alpha) .* textonCompDistances;

            % get the 50 nearest neighbors
            [sortedDist, sortedInd] = sort(avgOrigDistances(validInd));
            goodInd = sortedInd(1:50);

            dist = avgCompDistances(validInd(goodInd));
            
            N = 10;
            nnMontage = zeros(256, 256, 3, N, 'uint8');
            for i=1:N
                nnImgInfo = args.ObjectDb(validInd(goodInd(i))).document;
                im = imread(fullfile(args.ImagesPath, nnImgInfo.image.folder, nnImgInfo.image.filename));
                nnMontage(:,:,:,i) = imresize(im, [256 256], 'bilinear');
                imwrite(im, sprintf('nnImg/nnImg_%04d.jpg', i), 'Quality', 100);
            end
            
            montage(nnMontage);
        end
    end
end
fprintf('done.\n');

%% Save the xml to disk
fprintf('Saving xml file: %s\n', xmlPath);
% writeXML(xmlPath, imgInfo);

