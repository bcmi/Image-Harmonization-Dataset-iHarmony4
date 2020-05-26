%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function hist = myHistoNDWeighted(vec, weights, nbBins, varargin) 
%  Computes the N-dimensional histogram of an input vector, weighted version
%
% Input parameters:
%   - vec: the input vector (size MxN)
%   - weights: weight (Mx1) of each input feature
%   - nbBins: number of bins of the output histogram. MUST be the same in
%   each dimension
%   - varargin: Override the min and max with input values. Must be 1xN
%   vectors
%
% Output parameters:
%   
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function hist = myHistoNDWeighted(vec, weights, nbBins, varargin) 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% make sure varargin is well formatted
if length(varargin) ~= 0
    if length(varargin) ~= 2
        error('Incorrect input arguments: must be [image, nbBins, min, max]')
    end
end

% override min/max with input arguments
if length(varargin) ~= 0
    minVals = varargin{1};
    maxVals = varargin{2};
    
    minVals = minVals(:)';
    maxVals = maxVals(:)';
else
    minVals = min(vec);
    maxVals = max(vec);
end

nbDims = size(vec, 2);

% compute the edges in each dimension
span = maxVals - minVals;
step = repmat(span ./ nbBins, nbBins+1, 1);
edges = repmat((0:nbBins)', 1, nbDims) .* step + repmat(minVals, nbBins+1, 1);

c = mat2cell(edges, size(edges, 1), ones(1, nbDims));
hist = whistnd(vec, weights, c{:});

% put the values from the last bin in the second-to-last bin (the last bin contains values >= last edge)
permutations = [nbDims 1:nbDims-1];
for i=1:nbDims
    % shift
    if nbDims > 1
        hist = permute(hist, permutations);
    end
    s = size(hist);
    ind = cell(1,size(s,2)-1);
    for j=2:size(s, 2);
        ind{j-1} = 1:s(j);
    end
    hist(end-1,ind{:}) = hist(end-1,ind{:}) + hist(end,ind{:});
    hist = hist(1:end-1,ind{:});
end
