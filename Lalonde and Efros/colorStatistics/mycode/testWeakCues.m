%% Set paths
addpath ../xml;
addpath ../../3rd_party/color;
addpath ../../3rd_party/LabelMeToolbox;
addpath ../histogram;


dbPath = '/nfs/hn01/jlalonde/results/colorStatistics/testDataSemantic/testDataSemantic/';


%% Load the image
% xmlPath = fullfile(dbPath, 'img_6292_generated.xml'); 
% xmlPath = fullfile(dbPath, 'img_4133_generated.xml'); % good
% xmlPath = fullfile(dbPath, 'img_4135_generated.xml');
% xmlPath = fullfile(dbPath, 'img_4518_generated.xml');
% xmlPath = fullfile(dbPath, 'img_4494_generated.xml');
% xmlPath = fullfile(dbPath, 'img_4573_generated.xml');
% xmlPath = fullfile(dbPath, 'img_6461_generated.xml');
xmlPath = fullfile(dbPath, 'img_5769_generated.xml');
% xmlPath = fullfile(dbPath, 'img_4179_generated.xml');
% xmlPath = fullfile(dbPath, 'img_5214_generated.xml');
% xmlPath = fullfile(dbPath, 'img_4554_generated.xml');
% xmlPath = fullfile(dbPath, 'img_6983_generated.xml');
imgInfo = readStructFromXML(xmlPath);

genImg = imread(fullfile(dbPath, imgInfo.image.folder, 'lossless', imgInfo.image.filename));
srcImg = imread(imgInfo.object.imgSrc.path);

[hSrc,wSrc,c] = size(srcImg);

srcImg = imresize(srcImg, [256 256], 'bilinear');

%% Convert to useful color spaces
hsvGenImg = rgb2hsv(genImg);
labGenImg = rgb2lab(genImg);

hsvSrcImg = rgb2hsv(srcImg);
labSrcImg = rgb2lab(srcImg);


%% Get the object's pixels in both generated and source image
% load the object's polygon, and extract its mask
[xPoly, yPoly] = getLMpolygon(imgInfo.object.polygon);
objPoly = [xPoly yPoly]';
objPoly = objPoly .* repmat(([256 256]' ./ [wSrc hSrc]'), 1, size(objPoly, 2));

objMask = poly2mask(objPoly(1,:), objPoly(2,:), 256, 256); 
indObj = find(objMask);
indBg = find(~objMask);

%% Vectorize the images
hsvGenImgVec = reshape(hsvGenImg, 256*256, 3);
hsvSrcImgVec = reshape(hsvSrcImg, 256*256, 3);

%% Get the pixels for each combination

hsvObj = hsvGenImgVec(indObj, :);
hsvGenBg = hsvGenImgVec(indBg, :);
hsvSrcBg = hsvSrcImgVec(indBg, :);

%% Compute the histograms (joint)
hsvHistObj   = myHistoND(hsvObj, 100, [0 0 0], [1 1 1]);
hsvHistSrcBg = myHistoND(hsvSrcBg, 100, [0 0 0], [1 1 1]);
hsvHistGenBg = myHistoND(hsvGenBg, 100, [0 0 0], [1 1 1]);

figure(1);
climMax = 500;
subplot(3, 3, 1), imshow(genImg), title('Generated image');
subplot(3, 3, 4), imagesc(objMask), title('Object mask'), axis image off;
subplot(3, 3, 7), imshow(srcImg), title('Source image');
subplot(3, 3, 2), image((squeeze(sum(hsvHistGenBg, 3))), 'CDataMapping', 'scaled'), axis xy, xlabel('S'), ylabel('H'), title('Dst Background');
set(gca, 'CLim', [0 climMax]);
subplot(3, 3, 5), image((squeeze(sum(hsvHistObj, 3))), 'CDataMapping', 'scaled'), axis xy, xlabel('S'), ylabel('H'), title('Object');
set(gca, 'CLim', [0 climMax]);
subplot(3, 3, 8), image((squeeze(sum(hsvHistSrcBg, 3))), 'CDataMapping', 'scaled'), axis xy, xlabel('S'), ylabel('H'), title('Src Background');
set(gca, 'CLim', [0 climMax]);

hHistGenBg = sum(sum(hsvHistGenBg, 3),2);
hHistGenBg = hHistGenBg ./ sum(hHistGenBg(:));

hHistObj = sum(sum(hsvHistObj, 3),2);
hHistObj = hHistObj ./ sum(hHistObj(:));

hHistSrcBg = sum(sum(hsvHistSrcBg, 3),2);
hHistSrcBg = hHistSrcBg ./ sum(hHistSrcBg(:));

subplot(3, 3, 3), plot(hHistGenBg), xlabel('H'), title(sprintf('Dst Background, dot=%f, \\chi^2=%f', dot(hHistGenBg, hHistObj), chisq(hHistGenBg, hHistObj)));
subplot(3, 3, 6), plot(hHistObj), xlabel('H'), title('Object');
subplot(3, 3, 9), plot(hHistSrcBg), xlabel('H'), title(sprintf('Src Background, dot=%f, \\chi^2=%f', dot(hHistSrcBg, hHistObj), chisq(hHistSrcBg, hHistObj)));

%% Get an interval
sHistObj = squeeze(sum(sum(hsvHistObj, 3),1));

% mean and +/- 1 stdev
meanObj = mean(hsvObj, 1);
stdevObj = std(hsvObj, 1);

interval = [max(meanObj - stdevObj, zeros(1,3)); min(meanObj + stdevObj,ones(1,3))];

%% Look at the distribution of hues in the saturation interval

hsvObjSatInt = hsvObj(hsvObj(:,2) >= interval(1,2) & hsvObj(:,2) <= interval(2,2),:);
hsvSrcBgSatInt = hsvSrcBg(hsvSrcBg(:,2) >= interval(1,2) & hsvSrcBg(:,2) <= interval(2,2),:);
hsvGenBgSatInt = hsvGenBg(hsvGenBg(:,2) >= interval(1,2) & hsvGenBg(:,2) <= interval(2,2),:);

hsvHistObjSatInt   = myHistoND(hsvObjSatInt, 100, [0 0 0], [1 1 1]);
hsvHistSrcBgSatInt = myHistoND(hsvSrcBgSatInt, 100, [0 0 0], [1 1 1]);
hsvHistGenBgSatInt = myHistoND(hsvGenBgSatInt, 100, [0 0 0], [1 1 1]);

figure(2);
climMax = 200;
subplot(3, 3, 1), imshow(genImg), title('Generated image');
subplot(3, 3, 4), imagesc(objMask), title('Object mask'), axis image off;
subplot(3, 3, 7), imshow(srcImg), title('Source image');
subplot(3, 3, 2), image((squeeze(sum(hsvHistGenBgSatInt, 3))), 'CDataMapping', 'scaled'), axis xy, xlabel('S'), ylabel('H'), title('Dst Background');
set(gca, 'CLim', [0 climMax]);
subplot(3, 3, 5), image((squeeze(sum(hsvHistObjSatInt, 3))), 'CDataMapping', 'scaled'), axis xy, xlabel('S'), ylabel('H'), title('Object');
set(gca, 'CLim', [0 climMax]);
subplot(3, 3, 8), image((squeeze(sum(hsvHistSrcBgSatInt, 3))), 'CDataMapping', 'scaled'), axis xy, xlabel('S'), ylabel('H'), title('Src Background');
set(gca, 'CLim', [0 climMax]);

hHistGenBgSatInt = sum(sum(hsvHistGenBgSatInt, 3),2);
hHistGenBgSatInt = hHistGenBgSatInt ./ sum(hHistGenBgSatInt(:));

hHistObjSatInt = sum(sum(hsvHistObjSatInt, 3),2);
hHistObjSatInt = hHistObjSatInt ./ sum(hHistObjSatInt(:));

hHistSrcBgSatInt = sum(sum(hsvHistSrcBgSatInt, 3),2);
hHistSrcBgSatInt = hHistSrcBgSatInt ./ sum(hHistSrcBgSatInt(:));

subplot(3, 3, 3), plot(hHistGenBgSatInt), xlabel('H'), title(sprintf('Dst Background, dot=%f, \\chi^2=%f', dot(hHistGenBgSatInt, hHistObjSatInt), chisq(hHistGenBgSatInt, hHistObjSatInt)));
subplot(3, 3, 6), plot(hHistObjSatInt), xlabel('H'), title('Object');
subplot(3, 3, 9), plot(hHistSrcBgSatInt), xlabel('H'), title(sprintf('Src Background, dot=%f, \\chi^2=%f', dot(hHistSrcBgSatInt, hHistObjSatInt), chisq(hHistSrcBgSatInt, hHistObjSatInt)));

%% Look at the distribution of hues weighted by a gaussian fitted on the saturation

hsvHistObjSatInt   = myHistoND(hsvObj, 100, [0 0 0], [1 1 1]);
hsvHistSrcBgSatInt = myHistoND(hsvSrcBg, 100, [0 0 0], [1 1 1]);
hsvHistGenBgSatInt = myHistoND(hsvGenBg, 100, [0 0 0], [1 1 1]);

% h = fspecial('gaussian', [1 201], stdevObj(2)*200);
h = fspecial('gaussian', [1 201], stdevObj(2)*200/3);
h = h ./ max(h);
h = repmat(h, 100, 1);

% hsvHistObjSatInt = hsvHistObjSatInt .* h();

figure(3);
climMax = 200;
subplot(3, 3, 1), imshow(genImg), title('Generated image');
subplot(3, 3, 4), imagesc(objMask), title('Object mask'), axis image off;
subplot(3, 3, 7), imshow(srcImg), title('Source image');
subplot(3, 3, 2), image((squeeze(sum(hsvHistGenBgSatInt, 3)) .* h(:,ceil(99-meanObj(2)*100):ceil(99-meanObj(2)*100)+99)), 'CDataMapping', 'scaled'), axis xy, xlabel('S'), ylabel('H'), title('Dst Background');
set(gca, 'CLim', [0 climMax]);
subplot(3, 3, 5), image((squeeze(sum(hsvHistObjSatInt, 3) .* h(:,ceil(99-meanObj(2)*100):ceil(99-meanObj(2)*100)+99))), 'CDataMapping', 'scaled'), axis xy, xlabel('S'), ylabel('H'), title('Object');
set(gca, 'CLim', [0 climMax]);
subplot(3, 3, 8), image((squeeze(sum(hsvHistSrcBgSatInt, 3) .* h(:,ceil(99-meanObj(2)*100):ceil(99-meanObj(2)*100)+99))), 'CDataMapping', 'scaled'), axis xy, xlabel('S'), ylabel('H'), title('Src Background');
set(gca, 'CLim', [0 climMax]);

hHistGenBgSatInt = sum(sum(hsvHistGenBgSatInt, 3).* h(:,ceil(99-meanObj(2)*100):ceil(99-meanObj(2)*100)+99),2);
hHistGenBgSatInt = hHistGenBgSatInt ./ sum(hHistGenBgSatInt(:));

hHistObjSatInt = sum(sum(hsvHistObjSatInt, 3).* h(:,ceil(99-meanObj(2)*100):ceil(99-meanObj(2)*100)+99),2);
hHistObjSatInt = hHistObjSatInt ./ sum(hHistObjSatInt(:));

hHistSrcBgSatInt = sum(sum(hsvHistSrcBgSatInt, 3).* h(:,ceil(99-meanObj(2)*100):ceil(99-meanObj(2)*100)+99),2);
hHistSrcBgSatInt = hHistSrcBgSatInt ./ sum(hHistSrcBgSatInt(:));

subplot(3, 3, 3), plot(hHistGenBgSatInt), xlabel('H'), title(sprintf('Dst Background, dot=%f, \\chi^2=%f', dot(hHistGenBgSatInt, hHistObjSatInt), chisq(hHistGenBgSatInt, hHistObjSatInt)));
subplot(3, 3, 6), plot(hHistObjSatInt), xlabel('H'), title('Object');
subplot(3, 3, 9), plot(hHistSrcBgSatInt), xlabel('H'), title(sprintf('Src Background, dot=%f, \\chi^2=%f', dot(hHistSrcBgSatInt, hHistObjSatInt), chisq(hHistSrcBgSatInt, hHistObjSatInt)));

%% Look at the distribution of saturation

hsvHistObjHueInt   = myHistoND(hsvObj, 100, [0 0 0], [1 1 1]);
hsvHistSrcBgHueInt = myHistoND(hsvSrcBg, 100, [0 0 0], [1 1 1]);
hsvHistGenBgHueInt = myHistoND(hsvGenBg, 100, [0 0 0], [1 1 1]);

% hsvHistObjSatInt = hsvHistObjSatInt .* h();

figure(4);
climMax = 200;
subplot(3, 3, 1), imshow(genImg), title('Generated image');
subplot(3, 3, 4), imagesc(objMask), title('Object mask'), axis image off;
subplot(3, 3, 7), imshow(srcImg), title('Source image');
subplot(3, 3, 2), image((squeeze(sum(hsvHistGenBgHueInt, 3))), 'CDataMapping', 'scaled'), axis xy, xlabel('S'), ylabel('H'), title('Dst Background');
set(gca, 'CLim', [0 climMax]);
subplot(3, 3, 5), image((squeeze(sum(hsvHistObjHueInt, 3))), 'CDataMapping', 'scaled'), axis xy, xlabel('S'), ylabel('H'), title('Object');
set(gca, 'CLim', [0 climMax]);
subplot(3, 3, 8), image((squeeze(sum(hsvHistSrcBgHueInt, 3))), 'CDataMapping', 'scaled'), axis xy, xlabel('S'), ylabel('H'), title('Src Background');
set(gca, 'CLim', [0 climMax]);

sHistGenBgHueInt = sum(sum(hsvHistGenBgHueInt, 3),1);
sHistGenBgHueInt = sHistGenBgHueInt ./ sum(sHistGenBgHueInt(:));

sHistObjHueInt = sum(sum(hsvHistObjHueInt, 3),1);
sHistObjHueInt = sHistObjHueInt ./ sum(sHistObjHueInt(:));

sHistSrcBgHueInt = sum(sum(hsvHistSrcBgHueInt, 3),1);
sHistSrcBgHueInt = sHistSrcBgHueInt ./ sum(sHistSrcBgHueInt(:));

subplot(3, 3, 3), plot(sHistGenBgHueInt), xlabel('S'), title(sprintf('Dst Background, dot=%f, \\chi^2=%f', dot(sHistGenBgHueInt, sHistObjHueInt), chisq(sHistGenBgHueInt, sHistObjHueInt)));
subplot(3, 3, 6), plot(sHistObjHueInt), xlabel('S'), title('Object');
subplot(3, 3, 9), plot(sHistSrcBgHueInt), xlabel('S'), title(sprintf('Src Background, dot=%f, \\chi^2=%f', dot(sHistSrcBgHueInt, sHistObjHueInt), chisq(sHistSrcBgHueInt, sHistObjHueInt)));


%% Look at the distribution of saturation weighted by a gaussian fitted on the hue

hsvHistObjHueInt   = myHistoND(hsvObj, 100, [0 0 0], [1 1 1]);
hsvHistSrcBgHueInt = myHistoND(hsvSrcBg, 100, [0 0 0], [1 1 1]);
hsvHistGenBgHueInt = myHistoND(hsvGenBg, 100, [0 0 0], [1 1 1]);
% mean and +/- 1 stdev
meanObj = mean(hsvObj, 1);
stdevObj = std(hsvObj, 1);

% h = fspecial('gaussian', [1 201], stdevObj(2)*200);
h = fspecial('gaussian', [1 201], stdevObj(1)*200/3);
h = h ./ max(h);
h = repmat(h, 100, 1)';

% hsvHistObjSatInt = hsvHistObjSatInt .* h();

figure(5);
climMax = 200;
subplot(3, 3, 1), imshow(genImg), title('Generated image');
subplot(3, 3, 4), imagesc(objMask), title('Object mask'), axis image off;
subplot(3, 3, 7), imshow(srcImg), title('Source image');
subplot(3, 3, 2), image((squeeze(sum(hsvHistGenBgHueInt, 3)) .* h(ceil(99-meanObj(1)*100):ceil(99-meanObj(1)*100)+99,:)), 'CDataMapping', 'scaled'), axis xy, xlabel('S'), ylabel('H'), title('Dst Background');
set(gca, 'CLim', [0 climMax]);
subplot(3, 3, 5), image((squeeze(sum(hsvHistObjHueInt, 3) .* h(ceil(99-meanObj(1)*100):ceil(99-meanObj(1)*100)+99,:))), 'CDataMapping', 'scaled'), axis xy, xlabel('S'), ylabel('H'), title('Object');
set(gca, 'CLim', [0 climMax]);
subplot(3, 3, 8), image((squeeze(sum(hsvHistSrcBgHueInt, 3) .* h(ceil(99-meanObj(1)*100):ceil(99-meanObj(1)*100)+99,:))), 'CDataMapping', 'scaled'), axis xy, xlabel('S'), ylabel('H'), title('Src Background');
set(gca, 'CLim', [0 climMax]);

sHistGenBgHueInt = sum(sum(hsvHistGenBgHueInt, 3).* h(ceil(99-meanObj(1)*100):ceil(99-meanObj(1)*100)+99,:),1);
sHistGenBgHueInt = sHistGenBgHueInt ./ sum(sHistGenBgHueInt(:));

sHistObjHueInt = sum(sum(hsvHistObjHueInt, 3).* h(ceil(99-meanObj(1)*100):ceil(99-meanObj(1)*100)+99,:),1);
sHistObjHueInt = sHistObjHueInt ./ sum(sHistObjHueInt(:));

sHistSrcBgHueInt = sum(sum(hsvHistSrcBgHueInt, 3).* h(ceil(99-meanObj(1)*100):ceil(99-meanObj(1)*100)+99,:),1);
sHistSrcBgHueInt = sHistSrcBgHueInt ./ sum(sHistSrcBgHueInt(:));

subplot(3, 3, 3), plot(sHistGenBgHueInt), xlabel('S'), title(sprintf('Dst Background, dot=%f, \\chi^2=%f', dot(sHistGenBgHueInt, sHistObjHueInt), chisq(sHistGenBgHueInt, sHistObjHueInt)));
subplot(3, 3, 6), plot(sHistObjHueInt), xlabel('S'), title('Object');
subplot(3, 3, 9), plot(sHistSrcBgHueInt), xlabel('S'), title(sprintf('Src Background, dot=%f, \\chi^2=%f', dot(sHistSrcBgHueInt, sHistObjHueInt), chisq(sHistSrcBgHueInt, sHistObjHueInt)));

%% Look at the distribution of saturation weighted by the object's colors

hsvHistObj   = myHistoND(hsvObj, 100, [0 0 0], [1 1 1]);
hsvHistSrcBg = myHistoND(hsvSrcBg, 100, [0 0 0], [1 1 1]);
hsvHistGenBg = myHistoND(hsvGenBg, 100, [0 0 0], [1 1 1]);

hsvHistSrcBg = hsvHistSrcBg .* hsvHistObj;
hsvHistGenBg = hsvHistGenBg .* hsvHistObj;

hsvHistSrcBg = hsvHistSrcBg ./ sum(hsvHistSrcBg(:));
hsvHistGenBg = hsvHistGenBg ./ sum(hsvHistGenBg(:));

figure(6);
climMax = 100;
subplot(3, 3, 1), imshow(genImg), title('Generated image');
subplot(3, 3, 4), imagesc(objMask), title('Object mask'), axis image off;
subplot(3, 3, 7), imshow(srcImg), title('Source image');
subplot(3, 3, 2), image((squeeze(sum(hsvHistGenBg, 3))), 'CDataMapping', 'scaled'), axis xy, xlabel('S'), ylabel('H'), title('Dst Background');
% set(gca, 'CLim', [0 climMax]);
subplot(3, 3, 5), image((squeeze(sum(hsvHistObj, 3))), 'CDataMapping', 'scaled'), axis xy, xlabel('S'), ylabel('H'), title('Object');
% set(gca, 'CLim', [0 climMax]);
subplot(3, 3, 8), image((squeeze(sum(hsvHistSrcBg, 3))), 'CDataMapping', 'scaled'), axis xy, xlabel('S'), ylabel('H'), title('Src Background');
% set(gca, 'CLim', [0 climMax]);

hHistGenBgHueInt = sum(sum(hsvHistGenBg, 3),2);
hHistGenBgHueInt = hHistGenBgHueInt ./ sum(hHistGenBgHueInt(:));

hHistObjHueInt = sum(sum(hsvHistObj, 3),2);
hHistObjHueInt = hHistObjHueInt ./ sum(hHistObjHueInt(:));

hHistSrcBgHueInt = sum(sum(hsvHistSrcBg, 3),2);
hHistSrcBgHueInt = hHistSrcBgHueInt ./ sum(hHistSrcBgHueInt(:));

subplot(3, 3, 3), plot(hHistGenBgHueInt), xlabel('H'), title(sprintf('Dst Background, dot=%f, \\chi^2=%f', dot(hHistGenBgHueInt, hHistObjHueInt), chisq(hHistGenBgHueInt, hHistObjHueInt)));
subplot(3, 3, 6), plot(hHistObjHueInt), xlabel('H'), title('Object');
subplot(3, 3, 9), plot(hHistSrcBgHueInt), xlabel('H'), title(sprintf('Src Background, dot=%f, \\chi^2=%f', dot(hHistSrcBgHueInt, hHistObjHueInt), chisq(hHistSrcBgHueInt, hHistObjHueInt)));



