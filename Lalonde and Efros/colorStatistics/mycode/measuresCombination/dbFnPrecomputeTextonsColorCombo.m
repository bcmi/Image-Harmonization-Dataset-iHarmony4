%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function dbFnPrecomputeTextonsColorCombo
%   Evaluate the matching of a test image based on different local measures (which don't require the
%   use of global statistics), based only on similar regions (using texton histogram distance)
% 
% Input parameters:
%
% Output parameters:
%    
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function r=dbFnPrecomputeTextonsColorCombo(outputBasePath, annotation, varargin) 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Initialize
r=0;
nbBins = 100;

% read arguments
defaultArgs = struct('DbPath', [], 'ImagesPath', [], 'Sigmas', []);
args = parseargs(defaultArgs, varargin{:});

% read the composite image
imgPath = fullfile(args.ImagesPath, annotation.image.folder, annotation.image.filename);
img = imread(imgPath);

[h,w,c] = size(img);

% read the masks
maskPath = fullfile(args.DbPath, annotation.file.folder, annotation.object.masks.filename);
load(maskPath); % objMask, bgMask

% read the texton distance map
textonDistPath = fullfile(args.DbPath, annotation.file.folder, annotation.local.textonMatching.filename);
textonDist = imresize(imread(textonDistPath), [h w], 'bilinear');
textonDist = double(textonDist) ./ 255; % normalize
textonDist(bgMask == 0) = 1;

textonWeight = ones(size(textonDist)) - textonDist;

% read the color distance map
colorDistPath = fullfile(args.DbPath, annotation.file.folder, annotation.local.colorMatching.filename);
colorDist = imread(colorDistPath);
colorDist = double(colorDist) ./ 255; % normalize

colorWeight = ones(size(colorDist)) - colorDist;

xmlPath = fullfile(outputBasePath, annotation.file.folder, annotation.file.filename);

if exist(xmlPath, 'file')
    imgInfo = loadXML(xmlPath);
else
    imgInfo.image = annotation.image;
    imgInfo.file = annotation.file;
end

%% Convert to Lab
imgColor = rgb2lab(img);

% L = [0 100]
% a = [-100 100]
% b = [-100 100]
mins = [0 -100 -100];
maxs = [100 100 100];
type = 1;

%% Compute the object and background's histograms
imgVec = double(reshape(imgColor, [h*w 3]));

% combine the masks together (weighted sum)
alphas = [0 0.33 0.66];
for alpha=alphas
    fprintf('\nalpha=%.2f\n', alpha);
    weights = textonWeight .* alpha + colorWeight .* (1-alpha);

    sigmas = args.Sigmas;
    overlapW = zeros(length(sigmas), 1);
    distChi = zeros(length(sigmas), 1);
    for sigma=sigmas
        fprintf('%.2f...', sigma);

        overlap = nnz(weights(bgMask(:)) < sigma) / nnz(bgMask);
        overlapW(sigmas==sigma) = overlap;

        bgInd = weights(bgMask(:)) < sigma; %#ok

        if overlap > 0 && nnz(bgInd)
            histObjJoint = myHistoND(imgVec(objMask(:),:), nbBins, mins, maxs);
            histBgDstJoint = myHistoND(imgVec(bgInd(:),:), nbBins, mins, maxs);

            distChi(sigmas==sigma) = chisq(histObjJoint, histBgDstJoint);
        else
            distChi(sigmas==sigma) = 1;
        end
    end

    % Save xml information
    [p,filename] = fileparts(annotation.file.filename);
    imgInfo.evalCombo.histograms(alphas==alpha).filename = fullfile('evalCombo', 'histograms', sprintf('%s_%.2f.mat', filename, alpha));
    imgInfo.evalCombo.histograms(alphas==alpha).alpha = alpha;
    outputFilename = fullfile(outputBasePath, imgInfo.evalCombo.histograms(alphas==alpha).filename);
    [m,m,m] = mkdir(fileparts(outputFilename)); %#ok
    save(outputFilename, 'sigmas', 'alphas', 'overlapW', 'distChi');

end

%% Save the xml to disk
fprintf('\nSaving xml file: %s\n', xmlPath);
writeXML(xmlPath, imgInfo);

