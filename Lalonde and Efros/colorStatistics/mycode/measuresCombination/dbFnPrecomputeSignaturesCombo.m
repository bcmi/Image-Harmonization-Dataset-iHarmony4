%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function dbFnPrecomputeSignaturesCombo
%   Evaluate the matching of a test image based on the EMD between the object and its background
% 
% Input parameters:
%
% Output parameters:
%    
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function r=dbFnPrecomputeSignaturesCombo(outputBasePath, annotation, varargin) 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Initialize
r=0;

% read arguments
defaultArgs = struct('DbPath', [], 'ImagesPath', [], 'Sigmas', []);
args = parseargs(defaultArgs, varargin{:});

xmlPath = fullfile(outputBasePath, annotation.file.folder, annotation.file.filename);
imgInfo = loadXML(xmlPath);

%% Read and convert the image
img = imread(fullfile(args.ImagesPath, annotation.image.folder, annotation.image.filename));
img = rgb2lab(img);
[h,w,c] = size(img);

% Force to lab
type = 1;

%% Load the signatures
load(fullfile(args.DbPath, annotation.file.folder, annotation.signatures(type).filename));

%% Load the masks
load(fullfile(args.DbPath, annotation.file.folder, annotation.object.masks.filename));

%% Load the texton distance map
textonDistPath = fullfile(args.DbPath, annotation.file.folder, annotation.local.textonMatching.filename);
textonDist = imresize(imread(textonDistPath), [h w], 'bilinear');
textonDist = double(textonDist) ./ 255; % normalize
textonDist(bgMask == 0) = 1;
textonWeight = ones(size(textonDist)) - textonDist;

%% Compute the EMD between signatures
distMat = pdist2(centersObj', centersBg');
[distEMD, flowEMD] = emd_mex(weightsObj', weightsBg', distMat);

%% Get the mean/median pixel shift for different values of sigma
sigmas = args.Sigmas;

for i=1:2
    if i==2
        % use textons
        weightsBgTextons = reweightClustersFromTextons(weightsBg, textonWeight(bgMask(:)), indsBg);
        [distEMD, flowEMD] = emd_mex(weightsObj', weightsBgTextons', distMat);
        fprintf('\nTextons...\n');
        name = 'textons';
    else
        fprintf('\nColor only...\n');
        name = 'color';
    end

    meanPixelShifts = zeros(length(sigmas), 1);
    meanClusterShifts = zeros(length(sigmas), 1);
    pctDist = zeros(length(sigmas), 1);
    pctDistW = zeros(length(sigmas), 1);

    % montageImg = zeros(size(img,1), size(img,2), 3, length(sigmas), 'uint8');

    for sigma=sigmas
        fprintf('%d...', sigma);
        [imgTgtNN, imgTgtNNW, pixelShift, clusterShift, clusterShiftWeight] = recolorImageFromEMD(centersBg, centersObj, img,  indsObj, find(objMask(:)), flowEMD, sigma); %#ok
        %     montageImg(:,:,:,sigmas==sigma) = lab2rgb(imgTgtNNW);

        clusterShiftWeightMax = max(clusterShiftWeight, [], 2);
        pctDist(sigmas==sigma) = nnz(clusterShiftWeightMax<0.5) / length(clusterShiftWeightMax);
        pctDistW(sigmas==sigma) = sum(clusterShiftWeightMax .* weightsObj);

        meanPixelShifts(sigmas==sigma) = mean(sqrt(sum(pixelShift.^2, 2)));
        meanClusterShifts(sigmas==sigma) = sum(sqrt(sum(clusterShift.^2, 2)) .* weightsObj) ./ sum(weightsObj);
    end
    fprintf('done.\n');

    t = 0.9;
    % linearly interpolate to find sigma (make sure no two x have the same value: artificially increase each one of them by a really small amount)
    bestSigma = interp1(pctDistW+(eps.*(1:length(pctDistW))'), sigmas, t);
    if isnan(bestSigma)
        bestSigma = 0; %#ok
    end

    % figure(1), montage(montageImg);
    % title(sprintf('\\sigma=%.2f', bestSigma));
    % pause;

    % Save xml information
    [p,filename] = fileparts(annotation.file.filename);
    imgInfo.evalCombo.signaturesEMD(i).filename = fullfile('evalCombo', 'signaturesEMD', sprintf('%s_%d.mat', filename, i));
    imgInfo.evalCombo.signaturesEMD(i).name = name;
    outputFilename = fullfile(outputBasePath, imgInfo.evalCombo.signaturesEMD(i).filename);
    [m,m,m] = mkdir(fileparts(outputFilename)); %#ok
    save(outputFilename, 'sigmas', 'meanPixelShifts', 'meanClusterShifts', 'pctDistW', 'pctDist', 'bestSigma');
end

%% Save the xml to disk
fprintf('Saving xml file: %s\n', xmlPath);
writeXML(xmlPath, imgInfo);

