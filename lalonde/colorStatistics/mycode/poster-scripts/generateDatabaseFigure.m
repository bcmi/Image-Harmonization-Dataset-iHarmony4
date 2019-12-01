function generateDatabaseFigure(syntheticDb)

%% Setup paths and load databases
addpath /nfs/hn01/jlalonde/code/matlab/trunk/mycode/colorStatistics;
setPath;

dbBasePath = fullfile(basePath, 'dataset', 'filteredDb');
imagesPath = fullfile(dbBasePath, 'Images');
databasesPath = fullfile(basePath, 'databases');

load(fullfile(databasesPath, 'userIndicesTrainTest.mat'));

if nargin ~= 1
    load(fullfile(databasesPath, 'syntheticDb.mat'));
end

%%

if 0
    nbImg = 20;
    
    randIndRealistic = indRealistic(ceil(rand(1, nbImg).*length(indRealistic)))';
    randIndUnrealistic = indUnrealistic(ceil(rand(1, nbImg).*length(indUnrealistic)))';
    randIndReal = indReal(ceil(rand(1, nbImg).*length(indReal)))';
else
    nbImg = 6;

    randIndRealistic = [1412 371 625 292 1105 390 1651];
    randIndUnrealistic = [1151 216 1542 1741 1545 73 1198];
    randIndReal = indReal(1:length(indReal));
end

montageImageRealistic = zeros(256,256, 3, nbImg, 'uint8');
montageImageUnrealistic = zeros(256,256, 3, nbImg, 'uint8');
montageImageReal = zeros(256,256, 3, nbImg, 'uint8');

for i=1:nbImg
    montageImageRealistic(:,:,:,i) = imresize(imread(fullfile(imagesPath, syntheticDb(randIndRealistic(i)).document.image.folder, syntheticDb(randIndRealistic(i)).document.image.filename)), [256 256], 'bilinear');
    montageImageUnrealistic(:,:,:,i) = imresize(imread(fullfile(imagesPath, syntheticDb(randIndUnrealistic(i)).document.image.folder, syntheticDb(randIndUnrealistic(i)).document.image.filename)), [256 256], 'bilinear');
    montageImageReal(:,:,:,i) = imresize(imread(fullfile(imagesPath, syntheticDb(randIndReal(i)).document.image.folder, syntheticDb(randIndReal(i)).document.image.filename)), [256 256], 'bilinear');
end

figure(1), myMontage(montageImageRealistic, 2, 3), title(sprintf('Realistic, [%s]', num2str(randIndRealistic)));
figure(2), mymontage(montageImageUnrealistic, 2, 3), title(sprintf('Unrealistic, [%s]', num2str(randIndUnrealistic)));
figure(3), mymontage(montageImageReal, 2, 3), title(sprintf('Real, [%s]', num2str(randIndReal))); 
frRealistic = getframe(get(figure(1), 'CurrentAxes'));
frUnrealistic = getframe(get(figure(2), 'CurrentAxes'));
frReal = getframe(get(figure(3), 'CurrentAxes'));
imwrite(frRealistic.cdata, fullfile('datasetImg', 'exampleDatabaseRealistic.png'));
imwrite(frUnrealistic.cdata, fullfile('datasetImg', 'exampleDatabaseUnrealistic.png'));
imwrite(frReal.cdata, fullfile('datasetImg', 'exampleDatabaseReal.png'));
