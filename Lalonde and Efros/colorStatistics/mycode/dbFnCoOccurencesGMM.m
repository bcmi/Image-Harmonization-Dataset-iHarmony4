%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function dbFnCoOccurencesGMM(imgPath, imagesBasePath, outputBasePath, annotation, varargin)
%   Computes the co-occurences of colors in an image using GMM. Compute the
%   cube of indices (a 64x64x64 cube that maps to images indices that have
%   that color)
% 
% Input parameters:
%
%   - varargin: Possible values:
%     - 'Recompute':
%       - 0: (default) will not compute the histogram when results are
%         already available. 
%       - 1: will re-compute histogram no matter what
%     - 'ColorSpace':
%       - 'rgb': Use the original RGB colorspace
%       - 'lab': Use the CIE Lab colorspace
%
% Output parameters:
%   
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function dbFnCoOccurencesGMM(imgPath, imagesBasePath, outputBasePath, annotation, varargin)global histoIndices processDatabaseImgNumber;
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

addpath ../../3rd_party/color;
addpath ../histogram;

%%
% load tmp.mat;

% Number of bins to accumulate
nbBins = 64;


% check if the user specified the option to recompute
defaultArgs = struct('Recompute', 1, 'ColorSpaces', []);
args = parseargs(defaultArgs, varargin{:});
args.Recompute = 1;

% read the image and the xml information
[imgOrig, imgInfo, recompute, xmlPath] = readImageInfo(imgPath, outputBasePath, annotation, '', args.Recompute);

if ~recompute
    fprintf('Already computed. Skipping...\n');
    return;
elseif isempty(imgOrig)
    imgOrig = imread(imgPath);
end

% make sure the image isn't too big. Resize to 256x256
imgOrig = imresize(imgOrig, [256,256], 'bilinear');

for type=1:length(args.ColorSpaces)
    if strcmp(args.ColorSpaces{type}, 'lab')
        % convert the image to the L*a*b* color space (if asked by the user)
        fprintf('Converting to L*a*b*...');
        img = rgb2lab(imgOrig);

        % L = [0 100]
        % a = [-100 100]
        % b = [-100 100]
        mins = [0 -100 -100];
        maxs = [100 100 100];
        
        if type ~= 1
            error('dbFnCooccurencesGMM: color spaces mismatch');
        end
    elseif strcmp(args.ColorSpaces{type}, 'rgb')
        fprintf('Keeping RGB format...');
        img = imgOrig;
        
        mins = [0 0 0];
        maxs = [255 255 255];
        
        if type ~= 2
            error('dbFnCooccurencesGMM: color spaces mismatch');
        end
    else
        error('Color Space %s unsupported!', args.ColorSpace);
    end

    % Compute the histogram
    imgHist = imageHisto3D(img, ones(size(img,1), size(img,2)), nbBins, mins, maxs);

    % Store the image index
    fprintf('Storing the image index...');
    tic
    indHist = find(imgHist);
    for j=indHist(:)'
        histoIndices{type}{1,j} = [histoIndices{type}{1,j} processDatabaseImgNumber];
    end
    t = toc;
    fprintf('done in %f seconds!\n', t);
end