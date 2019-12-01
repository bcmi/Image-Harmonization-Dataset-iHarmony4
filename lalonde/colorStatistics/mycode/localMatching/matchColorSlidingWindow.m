%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function windowDist = matchColorSlidingWindow(imgTgt, colorHisto)
%  Computes the histogram distance (chi-square) from one histogram to every window (in a sliding
%  window sense) over an image
% 
% Input parameters:
%
% Output parameters:
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function windowDist = matchColorSlidingWindow(imgTgt, colorHisto, nbBins, mins, maxs)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

windowHalfSize = 10;

[r,c,d] = size(imgTgt);
windowDist = ones(r,c);

% normalize the color histogram only once
colorHistoNorm = colorHisto ./ sum(colorHisto(:));

for i=1+windowHalfSize:r-windowHalfSize
    tic;
    indWindowi = i-windowHalfSize:i+windowHalfSize;

    for j=1+windowHalfSize+1:c-windowHalfSize
        indWindowj = j-windowHalfSize:j+windowHalfSize;

        % compute the histogram
        window = imgTgt(indWindowi, indWindowj, :);
        windowHisto = myHistoND(reshape(window, [size(window,1)*size(window,2) size(window,3)]), nbBins, mins, maxs);
        
        % compute and store the distance
        windowDist(i,j) = chisqNorm(colorHistoNorm, windowHisto);
    end
    toc;
end
