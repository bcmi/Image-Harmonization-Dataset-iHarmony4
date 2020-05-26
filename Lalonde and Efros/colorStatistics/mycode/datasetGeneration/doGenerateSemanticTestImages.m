%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function doGenerateSemanticTestImages
%   Generate test images to evaluate if our method actually captures
%   statistics of natural images. 
% 
% Input parameters:
%
% Output parameters:
%   
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function doGenerateSemanticTestImages 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%

% define the input and output paths
imagesBasePath = '/nfs/hn21/projects/labelme/Images/';
annotationsBasePath = '/nfs/hn21/projects/labelme/Annotation/';
outputBasePath = '/nfs/hn01/jlalonde/results/colorStatistics/testDataSemantic/testDataSemantic/';
distMatrixPath = fullfile(outputBasePath, '../distMatrix.mat');
maskPath = fullfile(outputBasePath, '../maskInfo.mat');

fprintf('Loading the distance matrix...');
load(distMatrixPath);
fprintf('Loading the mask information...');
load(maskPath);
fprintf('done.\n');

% read all the directories with the names 'static' and 'outdoor'
list = dir([imagesBasePath '*static*outdoor*']);
cellList = struct2cell(list);
subDirs = cellList(1,:);

dbFn = @dbFnGenerateSemanticTestImages;

%% Load the database
fprintf('Loading the database...');
load(fullfile(outputBasePath, '../db.mat'));
fprintf('done.\n');

%% Simpler to loop over the images
totNbImages = 1594;
baseInd = 5406;
fprintf('Generating %d images...', totNbImages);
objIndRand = randperm(accObjects-1);
for j=objIndRand(1:totNbImages)
    imgInd = imgIndVec(j);

    % build the image path
    imgPath = fullfile(imagesBasePath, D(imgInd).annotation.folder, D(imgInd).annotation.filename);

    try
        % do not read the image: the dbFn will open it if it needs to
        disp(['Processing of image ' imgPath]);

        % call the database function (which should take care of saving whatever it wants)
        dbFn(imgPath, imagesBasePath, outputBasePath, D(imgInd).annotation, ...
            'Database', D, 'ImgPath', imagesBasePath, 'MaskVec', maskVec, ...
            'ImgFilename', sprintf('img_%04d', baseInd), 'DistMatrix', distMatrix, ...
            'ImgIndVec', imgIndVec, 'ObjIndVec', objIndVec, 'CurInd', j);

        baseInd = baseInd+1;
    catch
        fprintf('Image %s failed, skipping...\n', imgPath);
    end
end

