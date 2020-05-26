%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function displayNearestNeighborsMontage
%  
% 
% Input parameters:
%
% Output parameters:
%   
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function h=displayNearestNeighborsMontage(imageDb, imagesPath, img, sortedInd, K, ...
    titleStr, fileStr, doSave, doDisplay)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% retrieve the top K matches
montageImg = zeros(600, 800, 3, K+1, 'uint8');
montageImg(:,:,:,1) = imresize(img, [600 800], 'nearest');
for i=1:K
    fprintf('Loading %dth nearest neighbor...\n', i);
    nnImgInfo = imageDb(sortedInd(i)).document;
    nnImg = imread(fullfile(imagesPath, nnImgInfo.image.folder, nnImgInfo.image.filename));

    imgTmp = imresize(nnImg, [600 800], 'nearest');
    if size(imgTmp,3) == 3
        montageImg(:,:,:,i+1) = imgTmp;
    else
        montageImg(:,:,:,i+1) = repmat(imgTmp, [1 1 3]);
    end
end

h = figure;
montage(montageImg);
title(strrep(titleStr, '_', '\_'));

if doSave
    saveas(gcf, fileStr);
end

if ~doDisplay
    close(h);
end
