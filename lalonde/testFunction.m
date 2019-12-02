%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function testFunction
%   Example test function which loads up each image in the database, and displays 
%   various information. This file aims to illustrate how to extract the data
%   from the xml files.
% 
% Input parameters:
%
% Output parameters:
%
% Requires:
%   - the matlab image processing toolbox (only for display purposes here)
%   - the loadXML function, from the labelme matlab toolbox. You can get it from
%     http://labelme.csail.mit.edu/LabelMeToolbox/index.html
%
% Additional information
%   - the file 'userLabelings.mat' contains two variables:
%     - imageLabel, which contains the actual labels (0=unknown,
%       1=realistic, 2=unrealistic)
%     - isGenerated, which indicates whether the image is generated
%       or real (0=real, 1=generated)
%     The indices correspond to images, in alphabetical order. 
%   - the file 'indices.mat' contains three variables:
%     - indReal: indices of real images (180)
%     - indRealistic: indices of realistic images (180)
%     - indUnrealistic: indices of unrealistic images (359)
%     The indices correspond to images, in alphabetical order. 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function testFunction
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
% set this variable to the base path of the database
databasePath = '/nfs/hn01/jlalonde/results/colorStatistics/iccv07/dataset/onlineDb';
labelmePath = '/nfs/hn21/projects/labelmeSubsampled800/';

dbPath = fullfile(databasePath, 'Annotation');
imagesPath = fullfile(databasePath, 'Images');

labelmeImagesPath = fullfile(labelmePath, 'Images');

% get the files
fileList = dir(fullfile(dbPath, '*.xml'));

% figure to display the images
figure;

% loop over all the files
for i=1:length(fileList)
    % load the xml information
    filePath = fullfile(dbPath, fileList(i).name);
    imgInfo = loadXML(filePath);
    
    % load the composite image
    imgPath = fullfile(imagesPath, imgInfo.image.filename);
    img = imread(imgPath);
    subplot(1,5,1), imshow(img), title('Composite');
    
    % load the masks
    maskPath = fullfile(dbPath, imgInfo.object.masks.filename);
    m = load(maskPath);
    
    % example: display the original image, the object only and the background only
    subplot(1,5,2), imshow(im2double(repmat(m.objMask, [1 1 3])) .* im2double(img)), title('Object');
    subplot(1,5,3), imshow(im2double(repmat(m.bgMask, [1 1 3])) .* im2double(img)), title('Background');
    
    % load the original images used to create the composite
    objImgPath = fullfile(labelmeImagesPath, imgInfo.objImgSrc.folder, imgInfo.objImgSrc.filename);
    objImg = imread(objImgPath);
    
    bgImgPath = fullfile(labelmeImagesPath, imgInfo.bgImgSrc.folder, imgInfo.bgImgSrc.filename);
    bgImg = imread(bgImgPath);
    
    % example: display the two images used to generate the composite 
    % resize only for display purposes
    subplot(1,5,4), imshow(imresize(objImg, [size(img,1) size(img,2)])), title('Original object');
    subplot(1,5,5), imshow(imresize(bgImg, [size(img,1) size(img,2)])), title('Original background');

    % wait for user input
    pause;
    
    % note: the masks cannot be used directly in the original images because we allow
    % for translation when copying the objects (see paper). The original mask needs to be
    % reconstructed from the object's polygon using the image processing toolbox function poly2mask
end
