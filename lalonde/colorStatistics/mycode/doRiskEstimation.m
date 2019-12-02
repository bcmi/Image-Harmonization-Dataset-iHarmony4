function doRiskEstimationglobal cumulativeHistogram;
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

addpath ../../3rd_party/color;
addpath ../../3rd_party/parseArgs;
addpath ../histogram;
addpath ../database;
addpath ../xml;

% define the input and output paths
imagesBasePath = '/nfs/hn21/projects/naturalSceneCategories/';
% imagesBasePath = '/nfs/hn01/jlalonde/temp/';
outputBasePath = '/nfs/hn01/jlalonde/results/colorStatistics/naturalSceneCategories/';
trainingImagesSubDirs = '*';
% trainingImagesSubDirs = {'land'};

dbFn = @dbFnRisk;

% Test at the following bin sizes
binSizes = 10:20:100;
% Initialize the risk estimate
riskEstimate = zeros(length(binSizes), 1);
figure(1);
for i=1:length(binSizes)
    nbBins = binSizes(i);
    fprintf('Computing for %d bins...', nbBins);
    
    % call the database function -> this will compute the histogram for each image, and accumulate
    % it into one big histogram
    cumulativeHistogram = [];
    processGenericDatabase(imagesBasePath, trainingImagesSubDirs, outputBasePath, dbFn, 'Recompute', 0, 'nbBins', nbBins);
%     bar(cumulativeHistogram); 
    image(cumulativeHistogram, 'CDataMapping', 'scaled'); axis equal;
    title(sprintf('AB histogram, with %d bins', nbBins));
    drawnow;
    saveas(gcf, sprintf('histAB_%d.jpg', nbBins));
    
    % bin width (WLOG we assume that the data is in the interval [0,1])
    h = 1/nbBins;
    % number of elements
    n = sum(sum(sum(cumulativeHistogram)));
    
    % normalize the histogram 
    normHist = cumulativeHistogram ./ n;
    
    % compute the estimator of risk
    riskEstimate(i) = 2/((n-1)*h) - (n+1)/((n-1)*h)*sum(sum(sum(normHist.^2)));
    
    fprintf('done.\n');
end

% plot the results
figure, plot(binSizes, riskEstimate);
ylabel('cross-validation score');
xlabel('number of bins');
saveas(gcf, 'crossvalidationAB.jpg');


%%
function dbFnRisk(imgPath, imagesBasePath, outputBasePath, annotation, varargin)
global cumulativeHistogram;

% check if the user specified the option to recompute
defaultArgs = struct('Recompute', 0, 'nbBins', 10);
args = parseargs(defaultArgs, varargin{:});

% get the bins from the argument
nbBins = args.nbBins;

% read the image
img = imread(imgPath);

% make sure all the images have the same size
img = imresize(img, [256,256], 'bilinear');

% convert the image to the L*a*b* color space
labImg = rgb2lab(img);

% add small amount of random noise to the data
% what stdev should we use in each dimensions?
stdevL = 5;
stdevAB = 10;
noise = randn(size(labImg)) .* repmat(shiftdim([stdevL stdevAB stdevAB], -1), [size(labImg,1) size(labImg,2) 1]);
labImg = labImg + noise;
% imshow(reshape(lab2rgb(reshape(labImg, 256*256,3)), 256, 256, 3));

% minRange = [0 -100 -100];
% maxRange = [100 100 100];

% compute the histogram
% histogram = imageHisto3D(labImg, ones(size(labImg(:,:,1))), nbBins, minRange, maxRange);
% histogram = histc(reshape(labImg(:,:,1), 256*256, 1), 0:(100/nbBins):100);
% histogram(end-1) = histogram(end-1)+histogram(end);
% histogram = histogram(1:end-1);
% histogram = myHistoND(reshape(labImg(:,:,1), 256*256,1), nbBins);
% bar(histogram);

histogram = myHistoND(reshape(labImg(:,:,2:3), 256*256,2), nbBins);
% image(histogram2D);

% add it to the global variable
if isempty(cumulativeHistogram)
    cumulativeHistogram = histogram;
else
    cumulativeHistogram = cumulativeHistogram + histogram;
end