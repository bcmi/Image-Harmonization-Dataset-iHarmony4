%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function resultImg = backProjectPixels(H, pixelsCoords, srcImg, targetImg, option)
%  Back project pixels coordinates from one image to another using a pre-computed homography.
% 
% Input parameters:
%   - H: pre-computed homography
%   - pixelsCoords: coordinates of pixels from the source image to be back-projected [r c]
%   - srcImg: image containing the RGB values of the object to paste
%   - targetImg: image where to paste the object (background)
%   - option: option for interp2 (see matlab documentation)
%
% Output parameters:
%   - resultImg: resulting image. 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function resultImg = backProjectPixels(H, pixelsCoords, srcImg, targetImg, option) 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin == 3
    option = 'linear';
end

% Now, project all pixels in the mask to find their coordinates in the src image
projPixels = H * [pixelsCoords(:,2) pixelsCoords(:,1) ones(size(pixelsCoords, 1), 1)]';
projPixels = projPixels ./ repmat(projPixels(3,:), 3, 1);

[hTgt, wTgt, cTgt] = size(targetImg);
resultImg = targetImg;

% loop over each channels and change the values of the resultImg with the interpolated values on the
% srcImg
for c = 1:cTgt
    % Interpolate their pixel values (bilinear interpolation by default)
    interpValue = interp2(double(srcImg(:,:,c)), projPixels(1,:), projPixels(2,:), option);
    
    % obtain the linear indices
    indTgt = sub2ind([hTgt wTgt], pixelsCoords(:,1), pixelsCoords(:,2));
    
    % replace the pixel values
    tmpImg = resultImg(:,:,c);
    tmpImg(indTgt) = uint8(interpValue);
    resultImg(:,:,c) = tmpImg;
end
