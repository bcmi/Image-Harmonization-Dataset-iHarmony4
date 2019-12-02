

addpath ../xml;
addpath ../../3rd_party/color;
addpath ../../3rd_party/LabelMeToolbox;
addpath ../histogram;

imgInfo = readStructFromXML('/nfs/hn01/jlalonde/results/colorStatistics/testDataSemantic/testDataSemantic/img_4657_generated.xml');
imDest = imread(fullfile('/usr1/projects/labelme/Images', imgInfo.image.originalFolder, imgInfo.image.originalFilename));

imSrc = imread(imgInfo.object.imgSrc.path);

%%
[xPoly, yPoly] = getLMpolygon(imgInfo.object.polygon);
objMask = poly2mask(xPoly, yPoly, size(imSrc, 1), size(imSrc, 2));

indSrcObj = find(objMask);
indSrcBg = find(~objMask);

%% RGB

% compute bunch of histograms
imSrcVec = reshape(imSrc, size(imSrc, 1)*size(imSrc,2), 3);
imDestVec = reshape(imDest, size(imDest, 1)*size(imDest,2), 3);

colors{1} = 'R';
colors{2} = 'G'; 
colors{3} = 'B';

figure(1);
for c=1:3
    histSrcObj = myHistoND(imSrcVec(indSrcObj, c), 100, 0, 255);
    histSrcObj = histSrcObj ./ sum(histSrcObj(:));
    histSrcBg = myHistoND(imSrcVec(indSrcBg, c), 100, 0, 255);
    histSrcBg = histSrcBg ./ sum(histSrcBg(:));
    
    histDestImg = myHistoND(imDestVec(:, c), 100, 0, 255);
    histDestImg = histDestImg ./ sum(histDestImg(:));
    
    subplot(3, 3, (c-1)*3+1), plot(histSrcObj), title(sprintf('Object, %s', colors{c}));
    subplot(3, 3, (c-1)*3+2), plot(histSrcBg), title(sprintf('Source background, %s', colors{c}));
    subplot(3, 3, (c-1)*3+3), plot(histDestImg), title(sprintf('Destination background, %s', colors{c}));
end

%% HSV

imSrcVec = reshape(rgb2hsv(imSrc), size(imSrc, 1)*size(imSrc,2), 3);
imDestVec = reshape(rgb2hsv(imDest), size(imDest, 1)*size(imDest,2), 3);

%%
colors{1} = 'H';
colors{2} = 'S'; 
colors{3} = 'V';

figure(2);
for c=1:3
    histSrcObj = myHistoND(imSrcVec(indSrcObj, c), 100, 0, 1);
    histSrcObj = histSrcObj ./ sum(histSrcObj(:));
    histSrcBg = myHistoND(imSrcVec(indSrcBg, c), 100, 0, 1);
    histSrcBg = histSrcBg ./ sum(histSrcBg(:));
    
    histDestImg = myHistoND(imDestVec(:, c), 100, 0, 1);
    histDestImg = histDestImg ./ sum(histDestImg(:));
    
    subplot(3, 3, (c-1)*3+1),  plot(histSrcObj), title(sprintf('Object, %s', colors{c}));
    subplot(3, 3, (c-1)*3+2), plot(histSrcBg), title(sprintf('Source background, %s', colors{c}));
    subplot(3, 3, (c-1)*3+3), plot(histDestImg), title(sprintf('Destination background, %s', colors{c}));
end

%% LAB
imSrcVec = reshape(rgb2lab(imSrc), size(imSrc, 1)*size(imSrc,2), 3);
imDestVec = reshape(rgb2lab(imDest), size(imDest, 1)*size(imDest,2), 3);

%% 
histSrcObj = myHistoND(imSrcVec(indSrcObj, 1), 100, 0, 100);
histSrcObj = histSrcObj ./ sum(histSrcObj(:));
histSrcBg = myHistoND(imSrcVec(indSrcBg, 1), 100, 0, 100);
histSrcBg = histSrcBg ./ sum(histSrcBg(:));

histDestImg = myHistoND(imDestVec(:, 1), 100, 0, 100);
histDestImg = histDestImg ./ sum(histDestImg(:));

figure(3)
subplot(3, 2, 1), plot(histSrcObj), title(sprintf('Object histogram, L'));
subplot(3, 2, 2), plot(histSrcBg), title(sprintf('Source image background histogram, L'));
subplot(3, 2, 3), plot(histDestImg), title(sprintf('Destination image background histogram, L'));


%%
histSrcObj = myHistoND(imSrcVec(indSrcObj, 2:3), 100, [-100 -100], [100 100]);
histSrcObj = histSrcObj ./ sum(histSrcObj(:));
histSrcBg = myHistoND(imSrcVec(indSrcBg, 2:3), 100, [-100 -100], [100 100]);
histSrcBg = histSrcBg ./ sum(histSrcBg(:));

histDestImg = myHistoND(imDestVec(:, 2:3), 100, [-100 -100], [100 100]);
histDestImg = histDestImg ./ sum(histDestImg(:));

subplot(3, 2, 4), image(histSrcObj, 'CDataMapping', 'scaled'), colormap(gray), title(sprintf('Object, AB channel'));
subplot(3, 2, 5), image(histSrcBg, 'CDataMapping', 'scaled'), colormap(gray), title(sprintf('Source background, AB'));
subplot(3, 2, 6), image(histDestImg, 'CDataMapping', 'scaled'), colormap(gray), title(sprintf('Destination background, AB'));
