%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function accHisto = computeColorDistanceHistogram(imgVector, interval, nbIter, nbPixelsDistances)
%   
% Input parameters:
%
% Output parameters:
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function accHisto = computeColorDistanceHistogram(imgVector, interval, nbIter, nbPixelsDistances)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


nbPixels = size(imgVector, 1);
accHisto = zeros(nbIter, length(interval));

imgVector = double(imgVector);

% accumulate over 5 iterations
for i=1:nbIter
    % randomly select pixels in the image
    randInd = randperm(nbPixels);
    D = squareform(pdist(imgVector(randInd(1:nbPixelsDistances), :)));

    % histogram the distances
    accHisto(i,:) = histc(D(:), interval);
end

accHisto = mean(accHisto, 1);