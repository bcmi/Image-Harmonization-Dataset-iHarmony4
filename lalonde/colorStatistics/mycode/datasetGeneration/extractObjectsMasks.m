%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function extractObjectsMasks
%   Generate test images to evaluate if our method actually captures
%   statistics of natural images. Uses location information to choose the
%   object to paste (closest mask in SSD distance). First part: extract the
%   objects' masks
% 
% Input parameters:
%
% Output parameters:
%   
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function extractObjectsMasks 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
addpath ../database;
addpath ../../3rd_party/LabelMeToolbox;

% define the input and output paths
imagesBasePath = '/nfs/hn21/projects/labelme/Images/';
annotationsBasePath = '/nfs/hn21/projects/labelme/Annotation/';
outputBasePath = '/nfs/hn01/jlalonde/results/colorStatistics/dataSet/';

% read all the directories with the names 'static' and 'outdoor'
list = dir([imagesBasePath '*static*outdoor*']);
cellList = struct2cell(list);
subDirs = cellList(1,:);

totNbImages = 2500;

%% Load the database
% D = LMdatabase(annotationsBasePath, subDirs);
load db.mat;

%% Get masks from database
%Randomly select 20K objects from the database
fprintf('Getting masks from database...');

%% Get the number of objects for every image in the database
counts = LMcountobject(D);

% Get only the images that contain objects
nbObjects = sum(counts);
maskVec = zeros(nbObjects, 30, 30, 'uint8');
imgIndVec = zeros(nbObjects, 1);
objIndVec = zeros(nbObjects, 1);

fprintf('The database has %d objects. \n', nbObjects);

% object to paste must occupy between 5% and 60% of the image
minAreaRatio = 0.05;
maxAreaRatio = 0.6;

maskFilter = fspecial('gaussian', [5 5], 1);

accObjects = 1;
N = length(D);

for i = 1:N
    % loop over all images
    imgInd = i;
    
    curAnnotation = D(imgInd).annotation;
    
    % look for the first object (at random) which is big enough
    if isfield(curAnnotation, 'object')
        % have to read the image to check for the size...
        img = imread(fullfile(imagesBasePath, curAnnotation.folder, curAnnotation.filename));
        imgArea = size(img,1)*size(img,2);
        indRand = randperm(length(curAnnotation.object));
        for objInd=indRand
            [xPoly, yPoly] = getLMpolygon(curAnnotation.object(objInd).polygon);
            objPoly = [xPoly yPoly]';
            objMask = poly2mask(objPoly(1,:), objPoly(2,:), size(img,1), size(img,2));
            areaObj = nnz(objMask) / imgArea;
            
            if areaObj > minAreaRatio && areaObj < maxAreaRatio
                % select the object index for generating the test image
                objIndVec(accObjects) = objInd;
                imgIndVec(accObjects) = imgInd;

                mask = double(objMask) .* 255;
                mask = imresize(mask, [30 30]);
                
                % blur it a little?
                mask = imfilter(mask, maskFilter, 'same');
                
                maskVec(accObjects, :, :) = uint8(mask);
                accObjects = accObjects + 1;
            end
        end
    end
    fprintf('%d(%d).', accObjects, i);
end
fprintf('done!\n');
fprintf('Accumulated %d masks', accObjects);

save maskInfo.mat maskVec objIndVec imgIndVec accObjects;
