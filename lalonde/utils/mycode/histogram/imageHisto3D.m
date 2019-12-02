%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function hist = imageHisto3D(image, mask, nbBins, varargin)
%  Computes the 3-dimensional histogram of an input image. The image can be
%  expressed in any color space. 
%
% Input parameters:
%   - image: the input image (size MxNx3), in whatever color space
%   - mask: binary mask (1=count, 0=do not count) that indicates which
%   pixels to include in the histogram
%   - nbBins: number of bins of the output histogram. MUST be the same in
%   each dimension
%   - varargin: Override the min and max with input values. Must be 1x3
%   vectors
%
% Output parameters:
%   
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function hist = imageHisto3D(image, mask, nbBins, varargin) 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% make sure the image has 3 channels
if (size(size(image),2) ~= 3)
    error('Input image must have 3 channels');
end

[rows, cols, nbchannels] = size(image);

if (nbchannels ~= 3) 
    error('Input image must have 3 channels');
end

% make sure varargin is well formatted
if length(varargin) ~= 0
    if length(varargin) ~= 2
        error('Incorrect input arguments: must be [image, nbBins, min, max]')
    end
    if isempty(find(size(varargin{1})==3))
        error('min must be 3x1 or 1x3');
    end
    if isempty(find(size(varargin{2})==3))
        error('max must be 3x1 or 1x3');
    end
end

% reshape the image in an Mx3 vector where M is the number of pixels
vec = reshape(image, rows*cols, 3);
% keep only the pixels corresponding to the 1's in the mask
ind = find(mask);
vec = vec(ind, :);

% override min/max with input arguments
if length(varargin) ~= 0
    minVals = varargin{1};
    maxVals = varargin{2};
    
    if size(minVals,2) ~= 3
        minVals = minVals';
    end
    if size(maxVals,2) ~= 3
        maxVals = maxVals';
    end
else
    minVals = min(vec);
    maxVals = max(vec);
end

% compute the edges in each dimension
span = maxVals - minVals;
step = repmat(span ./ nbBins, nbBins+1, 1);
edges = repmat([0:nbBins]', 1, 3) .* step + repmat(minVals, nbBins+1, 1);

c = mat2cell(edges, size(edges, 1), [1 1 1]);
hist = histnd(vec, c{:});

% put the values from the last bin in the second-to-last bin (the last bin
% contains values >= last edge)
hist(:,:,end-1) = hist(:,:,end-1) + hist(:,:,end);
hist = hist(:,:,1:end-1);

hist(:,end-1,:) = hist(:,end-1,:) + hist(:,end,:);
hist = hist(:,1:end-1,:);

hist(end-1,:,:) = hist(end-1,:,:) + hist(end,:,:);
hist = hist(1:end-1,:,:);

