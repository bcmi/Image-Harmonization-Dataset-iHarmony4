function [textonObjHist, textonBgHist, colorObjHist, colorBgHist] = ...
    computeColorAndTextonHistograms(img, objMask, filterBank, clusterCenters, ...
    nbColorBins, indActiveLab)
% Computes color and texton histograms, for both object and background
%
% ----------
% Jean-Francois Lalonde

% compute texton map
textonMap = textonify(img, filterBank, clusterCenters);

% compute object and background distributions
textonObjHist = histc(textonMap(objMask), 1:1000);
textonBgHist = histc(textonMap(~objMask), 1:1000);

imgLab = rgb2lab(img);
imgLabVec = reshape(imgLab, size(imgLab,1)*size(imgLab,2), size(imgLab,3));

% compute color distributions
colorObjHist = myHistoND(imgLabVec(objMask, :), nbColorBins, [0 -100 -100], [100 100 100]);
colorObjHist = colorObjHist(indActiveLab);
colorBgHist = myHistoND(imgLabVec(~objMask, :), nbColorBins, [0 -100 -100], [100 100 100]);
colorBgHist = colorBgHist(indActiveLab);
