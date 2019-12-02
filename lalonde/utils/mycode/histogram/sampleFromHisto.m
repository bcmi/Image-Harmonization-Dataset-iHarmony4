%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function samples = sampleFromHisto(histo, N)
%   Samples from a non-parametric distribution modeled by a 3-D histogram
% 
% Input parameters:
%   - histo: input histogram to sample from. Can be of any arbitrary
%   dimension
%   - N: number of desired samples
%
% Output parameters:
%   - samples: resulting samples, which should be distributed according to
%   the non-parametric model defined by the input histogram
%   
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function samples = sampleFromHisto(histo, N) 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

nbDims = ndims(histo);
if nbDims == 2
    if size(histo(:)) == size(histo) | size(histo(:)') == size(histo)
        nbDims = 1;
    end
end

histo = histo ./ sum(histo(:));
histoVec = reshape(histo, numel(histo), 1);

% Compute cumulative histogram
cumulHistoVec = cumsum(histoVec);

% Generate samples
samples = zeros(N, nbDims);
for c=1:N
    % Randomly pick a bin according to the distribution
    ind = find(rand <= cumulHistoVec);
    ind = ind(1);
    
    % Get the color subscript from the cube
    samples(c,:) = ind2subv(size(histo), ind);
end


