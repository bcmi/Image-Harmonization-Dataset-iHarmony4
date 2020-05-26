%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function [hist1stOrder, hist2ndOrder] = computeStatistics(img, nbBins1stOrder, nbBins2ndOrder, mins, maxs)
%  Computes the first- and second-order statistics of an image (the color space doesn't matter)
% 
% Input parameters:
%   - img: input image
%   - nbBins1stOrder: number of bins for the 1st-order histogram
%   - nbBins2ndOrder: number of bins for the 2nd-order histogram
%   - mins: minimum (for each dimension) to use for the histogram
%   - maxs: maximum (for each dimension) to use for the histogram
%
% Output parameters:
%   - hist1stOrder: 1st-order histogram (nbBins1stOrder^3)
%   - hist2ndOrder: 2nd-order histogram (nbBins2ndOrder^6)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [hist1stOrder, hist2ndOrder] = computeStatistics(img, nbBins1stOrder, nbBins2ndOrder, mins, maxs) 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

addpath ../histogram;

%% Make sure the input image has only 2 dimensions
if ndims(img) ~= 2
    img = reshape(img, size(img,1)*size(img,2), size(img,3));
end

%% 1st-order statistics
hist1stOrder = myHistoND(img, nbBins1stOrder, mins, maxs);
hist1stOrder = hist1stOrder ./ sum(hist1stOrder(:));

%% 2nd-order statistics
histTmp = myHistoND(img, nbBins2ndOrder, mins, maxs);
histTmp = histTmp ./ sum(histTmp(:));

% find the non-zero entries in the histogram
colorInd = find(histTmp);

% create the 2nd-order histogram
hist2ndOrder = zeros(repmat(nbBins2ndOrder, 1, 6));

% reshape it in a nbBins^3*nbBins*nbBins*nbBins form
hist2ndOrder = reshape(hist2ndOrder, [nbBins2ndOrder^3 repmat(nbBins2ndOrder, 1, 3)]);

% set the corresponding entries to the 1st order histogram
hist2ndOrder(colorInd,:,:,:) = repmat(shiftdim(histTmp, -1), [length(colorInd) ones(1,3)]);

% reshape it back to its 6-D form
hist2ndOrder = reshape(hist2ndOrder, repmat(nbBins2ndOrder, 1, 6));