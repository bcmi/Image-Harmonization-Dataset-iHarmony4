%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function doGenerateTestImages
%   Generate test images to evaluate if our method actually captures
%   statistics of natural images. 
% 
% Input parameters:
%
% Output parameters:
%   
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function doGenerateTestImages 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%

% define the input and output paths
imagesBasePath = '/nfs/hn21/projects/labelme/Images/';
annotationsBasePath = '/nfs/hn21/projects/labelme/Annotation/';
outputBasePath = '/nfs/hn01/jlalonde/results/colorStatistics/dataset/';

dbFn = @dbFnGenerateTestImages;

totNbImages = 2500;

%% Get the number of objects for every image in the database
counts = LMcountobject(D);
% Get only the images that contain objects
indSegmentedImg = find(counts);
imgInd = find(indSegmentedImg)';
imgInd = imgInd(randperm(length(imgInd)));

%% Simpler to loop over the images
nbImages = 0;
for j=imgInd
    % do not generate image from the spatial* folder
    if ~strcmp(D(indSegmentedImg(j)).annotation.folder, 'spatial_envelope_256x256_static_8outdoorcategories')
    
        % build the image path
        imgPath = [imagesBasePath D(indSegmentedImg(j)).annotation.folder '/' D(indSegmentedImg(j)).annotation.filename];

        % do not read the image: the dbFn will open it if it needs to
        disp(['Processing of image ' imgPath]);

        % call the database function (which should take care of saving whatever it wants)
        nbImages = nbImages + dbFn(imgPath, imagesBasePath, outputBasePath, D(indSegmentedImg(j)).annotation, ...
            'Database', D, 'ImgPath', imagesBasePath, 'IndSegmentedImg', indSegmentedImg, ...
            'ImgFilename', sprintf('img_%04d', nbImages));

        % only load a specified number of images
        if nbImages == totNbImages
            break;
        end
    end
end



