%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function dbFnCoOccurences(imgPath, imagesBasePath, outputBasePath, annotation, varargin)
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
function dbFnLoad3x3Patches(imgPath, imagesBasePath, outputBasePath, annotation, varargin)global patches3x3;
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% load('tmp.mat');

addpath ../../3rd_party/parseArgs;
addpath ../../3rd_party/color;

% check if the user specified the option to recompute
defaultArgs = struct('ColorSpace', 'lab');
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
imagePatches = zeros(254*254, 27, 'single');

% extract all the 3x3 color patches from the image
for i=2:255
    for j=2:255
        patch = reshape(img(i-1:i+1, j-1:j+1, :), 9, 3);
        % sort the patch colors along the L dimension (first dimension)
        
        [s, ind] = sort(patch(:,1));
        patch = reshape(patch(ind, :), 1, 27);
        imagePatches((i-2)*254+j-1, :) = patch;
    end
end

% select only 1/64 of them
divs = 64;
indPatches = randperm(254^2);
indPatches = indPatches(1:floor(254^2/divs));
% add them to the global variable
patches3x3 = [patches3x3; imagePatches(indPatches, :)];
fprintf('done!\n');



