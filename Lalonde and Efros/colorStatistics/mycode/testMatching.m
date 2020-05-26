function testMatching 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

addpath ../../3rd_party/color;
addpath ../histogram;

% image and histograms
imgPath = '/nfs/hn21/projects/naturalSceneCategories/forest/natu994.jpg';
hist1stPath = 'coast_1st.mat';
hist2ndPath = 'coast_2nd.mat';

% must be consistent!
nbBins1stOrder = 64;
nbBins2ndOrder = 16;

mins = [0 -100 -100];
maxs = [100 100 100];

load(hist1stPath);
load(hist2ndPath);

% load an image, convert it to Lab
rgbImg = imread(imgPath);
labImg = rgb2lab(rgbImg);

% compute its first- and second-order statistics
[hist1stOrderImg, hist2ndOrderImg] = computeStatistics(labImg, nbBins1stOrder, nbBins2ndOrder, mins, maxs);

% normalize the histograms (shouldn't this be done by the function instead?)
hist1stOrderImg = hist1stOrderImg ./ sum(hist1stOrderImg(:));
hist2ndOrderImg = hist2ndOrderImg ./ sum(hist2ndOrderImg(:));

% compute KL-divergence between histograms!
d1st = klDivergence(hist1stOrderImg, hist1stOrder);
d2nd = klDivergence(hist2ndOrderImg, hist2ndOrder);

