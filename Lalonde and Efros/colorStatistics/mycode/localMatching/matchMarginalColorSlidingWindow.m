%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function windowDist = matchMarginalColorSlidingWindow(imgTgt, colorHisto)
%  Computes the histogram distance (chi-square) from one histogram to every window (in a sliding
%  window sense) over an image
% 
% Input parameters:
%  - imgTgt: image (assumed in correct color space representation)
%  - colorHisto: color histogram (Nx3)
%  - nbBins: number of bins
%  - mins: minimum value in each dimension (3x1)
%  - maxs: maximum value in each dimension (3x1)
%
% Output parameters:
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function windowDist = matchMarginalColorSlidingWindow(imgTgt, colorHisto, nbBins, mins, maxs)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

windowHalfSize = 10;

[r,c,d] = size(imgTgt);
windowDist = ones(r,c);

% normalize the color histogram only once
colorHistoNorm = colorHisto ./ repmat(sum(colorHisto, 1), [nbBins 1]);

for i=1+windowHalfSize:r-windowHalfSize
    indWindowi = i-windowHalfSize:i+windowHalfSize;

    for j=1+windowHalfSize+1:c-windowHalfSize
        indWindowj = j-windowHalfSize:j+windowHalfSize;

        % compute the histograms
        windowHisto = zeros(nbBins, 3);
        for d=1:3
            window = imgTgt(indWindowi, indWindowj, d);
            windowHisto(:,d) = myHistoND(window(:), nbBins, mins(d), maxs(d));
        end
        
        % compute and store the distance
        windowDist(i,j) = (chisqNorm(colorHistoNorm(:,1), windowHisto(:,1)) + ...
            chisqNorm(colorHistoNorm(:,2), windowHisto(:,2)) + ...
            chisqNorm(colorHistoNorm(:,3), windowHisto(:,3))) ./ 3;
    end
end
