%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function dbFnLoadNxNPatches(imgPath, imagesBasePath, outputBasePath, annotation, varargin)
%   Computes the co-occurences of colors in an image. Saves the results
%   (2-D prob. density in a .mat file)
% 
% Input parameters:
%
%   - varargin: Possible values:
%     - 'ColorSpace':
%       - 'rgb': Use the original RGB colorspace
%       - 'lab': Use the CIE Lab colorspace
%
% Output parameters:
%   
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function dbFnLoadNxNPatches(imgPath, imagesBasePath, outputBasePath, annotation, varargin)global patches;
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% load('tmp.mat');

addpath ../../3rd_party/parseArgs;
addpath ../../3rd_party/color;

% check if the user specified the option to recompute
defaultArgs = struct('ColorSpace', 'lab', 'N', 1);
args = parseargs(defaultArgs, varargin{:});

% Load the image
fprintf('Computing patches...');
img = imread(imgPath);
img = imresize(img, [256 256], 'bilinear');

% Convert to specified color space (if needed)
if strcmp(args.ColorSpace, 'lab')
    % convert the image to the L*a*b* color space (if asked by the user)
    fprintf('Converting to L*a*b*...');
    img = rgb2lab(img);
    
    % L = [0 100]
    % a = [-100 100]
    % b = [-100 100]
    mins = [0 -100 -100];
    maxs = [100 100 100];
    type = 1;
elseif strcmp(args.ColorSpace, 'rgb')
    mins = [0 0 0];
    maxs = [255 255 255];
    type = 2;
    error('No ordering method implemented for rgb!');
else
    error('Color Space %s unsupported!', args.ColorSpace);
end

% initialize the current image's patches to zero
N = args.N;
nbPatchesRow = 256-N+1;
imagePatches = zeros(nbPatchesRow^2, (N^2)*3, 'single');

lims = ceil(N/2):ceil(N/2)+nbPatchesRow-1;
halfSize = floor(N/2);

% extract all the 3x3 color patches from the image
c = 1;
for i=lims
    for j=lims
        patch = reshape(img(i-halfSize:i+halfSize, j-halfSize:j+halfSize, :), N^2, 3);
        % sort the patch colors along the L dimension (first dimension)
        
%         [s, ind] = sort(patch(:,1));
        ind = 1:size(patch,1);
        patch = reshape(patch(ind, :), 1, N^2*3);
        imagePatches(c, :) = patch;
        c = c+1;
    end 
end

% We want to end up with ~250MB of data
% divs = 64;
divs = 110; % This should generate ~400MB of data, if we have 2500 images
indPatches = randperm(nbPatchesRow^2);
indPatches = indPatches(1:floor(nbPatchesRow^2/divs));
% add them to the global variable
patches = [patches; single(imagePatches(indPatches, :))];
fprintf('done!\n');



