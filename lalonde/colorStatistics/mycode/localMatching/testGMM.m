function testGMM
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Setup path and load stuff
addpath ../;
setPath;

basePath = '/nfs/hn01/jlalonde/results/colorStatistics/dataset/filteredDb';
dbPath = fullfile(basePath, 'Annotation');
imagesPath = fullfile(basePath, 'Images');

testImage = 'image_111149';

imagePath = fullfile(imagesPath, sprintf('%s.jpg', testImage));
annotationPath = fullfile(dbPath, sprintf('%s.xml', testImage));

% Load the masks
imgInfo = loadXML(annotationPath);
load(fullfile(dbPath, imgInfo.object.masks.filename));

rgbImage = double(imread(imagePath));
grayImage = mean(double(rgbImage), 3);
labImage = rgb2lab(rgbImage);
hsvImage = rgb2hsv(rgbImage);
chromaImage(:,:,1) = (rgbImage(:,:,1) ./ rgbImage(:,:,2)) .^ (1/3);
chromaImage(:,:,2) = (rgbImage(:,:,3) ./ rgbImage(:,:,2)) .^ (1/3);

% figure(1);
% subplot(2,2,1), imshow(rgbImage), subplot(2,2,3), imshow(grayImage);
% subplot(2,2,2), imshow(bgMask), subplot(2,2,4), imshow(objMask);


%% Try with the gray-level image only
% img = chromaImage;
% img = labImage(:,:,2:3);
img = labImage;
% img = hsvImage(:,:,1:2);

[h,w,c] = size(img);
imgVector = reshape(img, [w*h c]);
colorsVector = reshape(rgbImage, [w*h 3]);

% Retrieve the background and object pixels
bgPixels = double(imgVector(bgMask(:), :));
objPixels = double(imgVector(objMask(:), :));

figure(1), displayColors(bgPixels, colorsVector(bgMask(:), :)), title('Background pixels');
figure(2), displayColors(objPixels, colorsVector(objMask(:), :)), title('Object pixels');

%% Try the signatures clustering idea
nbClusters = 50;
[centersObj, weightsObj] = signaturesKmeans(objPixels, nbClusters);
[rO,gO,bO] = lab2rgb(centersObj(:,1), centersObj(:,2), centersObj(:,3));
[centersBg, weightsBg] = signaturesKmeans(bgPixels, nbClusters);
[rB,gB,bB] = lab2rgb(centersBg(:,1), centersBg(:,2), centersBg(:,3));
h = figure(3); hold on;
plotSignatures(h, centersObj, weightsObj, 'lab');
plotSignatures(h, centersBg, weightsBg, 'lab');
title(sprintf('K-means clustering with k=%d on image colors', nbClusters));
% figure(4), displayColors(imgVector, colorsVector), title('Original image colors');

%% Compute the EMD between signatures
distMat = pdist2(centersObj', centersBg');
[distEMD, flowEMD] = emd_mex(weightsObj', weightsBg', distMat);

h = figure(4); hold on;
plotEMD(h, centersObj, centersBg, flowEMD);
plotSignatures(h, centersObj, weightsObj, 'lab');
plotSignatures(h, centersBg, weightsBg, 'lab');
title(sprintf('K-means clustering with k=%d on image colors, EMD=%f', nbClusters, distEMD));

%% Cluster the data and compute pairwise distances
nbCenters = 12;
clustering = 'kmeans';

% Compute pairwise distances
D = zeros(nbCenters);

if strcmp(clustering, 'kmeans')
    [objCenters, sse] = vgg_kmeans(double(objPixels)', nbCenters, 'maxiters', 1000, 'mindelta', 1e-5);
    [bgCenters, sse] = vgg_kmeans(double(bgPixels)', nbCenters, 'maxiters', 1000, 'mindelta', 1e-5);
    
elseif strcmp(clustering, 'gmm')
    modelObj = fitGMM(double(objPixels), 'spherical', nbCenters);
    modelBg = fitGMM(double(bgPixels), 'spherical', nbCenters);
    
    % Look at how the recoloring works with different types of distances
    for i=1:nbCenters
        for j=1:nbCenters
            D(i,j) = sum((modelObj.centres(i,:) - modelBg.centres(j,:)).^2);

            % bidirectional KL-divergence
            %         D(i,j) = gaussianKL(modelObj.centres(i,:), eye(3).*modelObj.covars(i), ...
            %             modelBg.centres(j,:), eye(3).*modelBg.covars(j)) + ...
            %             gaussianKL(modelBg.centres(j,:), eye(3).*modelBg.covars(j), ...
            %             modelObj.centres(i,:), eye(3).*modelObj.covars(i));
            %
            %         D(i,j) = D(i,j) * modelObj.priors(i) * modelBg.priors(j);
        end
    end
    objCenters = modelObj.centres';
    bgCenters = modelBg.centres';
end

centers = [objCenters'; bgCenters'];
D = squareform(pdist(centers));
D = D(nbCenters+1:end, 1:nbCenters);

%% Compute best match
[C,T] = hungarian(D);

%% Display results with cluster centers 

% Display the 3-D points
figure(3);
hold on;
displayColors(bgPixels, colorsVector(bgMask(:), :));
displayColors(objPixels, colorsVector(objMask(:), :));

% Display the cluster centers
for i=1:nbCenters
    scatter3(objCenters(1,i), objCenters(2,i), objCenters(3,i), 30, 's');
    scatter3(bgCenters(1,i), bgCenters(2,i), bgCenters(3,i), 30, 's');
end

for l=1:nbCenters
    % draw a line between each pair of corresponding centers
    x = [objCenters(1,l) bgCenters(1, C(l))];
    y = [objCenters(2,l) bgCenters(2, C(l))];
    z = [objCenters(3,l) bgCenters(3, C(l))];
    line(x, y, z, 'LineWidth', 3);
end
return;

%% Display results on top of histogram

% figure;
% image(abHisto', 'CDataMapping', 'scaled'); axis xy equal;
figure;
plot(objPixels(:,1), objPixels(:,2), '.b'); axis equal;
hold on;

% Display gaussians
for i = 1:nbGaussians
    if ndims(model.covars) == 3
        [v,d] = eig(model.covars(:,:,i));
    elseif ndims(model.covars) == 2
        [v,d] = eig(eye(2) * model.covars(i));
    end
    for j = 1:2
        % Ensure that eigenvector has unit length
        v(:,j) = v(:,j)/norm(v(:,j));
        start=model.centres(i,:)-sqrt(d(j,j))*(v(:,j)');
        endpt=model.centres(i,:)+sqrt(d(j,j))*(v(:,j)');
        linex = [start(1) endpt(1)];
        liney = [start(2) endpt(2)];
        line(linex, liney, 'Color', 'k', 'LineWidth', 3)
    end
    % Plot ellipses of one standard deviation
    theta = 0:0.02:2*pi;
    x = sqrt(d(1,1))*cos(theta);
    y = sqrt(d(2,2))*sin(theta);
    % Rotate ellipse axes
    ellipse = (v*([x; y]))';
    % Adjust centre
    ellipse = ellipse + ones(length(theta), 1)*model.centres(i,:);
    plot(ellipse(:,1), ellipse(:,2), 'r-');
end