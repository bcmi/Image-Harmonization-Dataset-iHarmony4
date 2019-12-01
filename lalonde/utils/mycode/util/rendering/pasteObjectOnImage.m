%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function resultImg = pasteObjectOnImage(targetImg, targetPoly, srcImg, srcPoly, srcImgHighres, option)
%  Paste an object (determined by a source image and a binary background)
%  on a target image (background)
% 
% Input parameters:
%   - targetImg: image where to paste the object (background)
%   - targetPoly: [x y]' vertices of the polygon defining the object's boundaries in targetImg
%   - srcImg: image containing the RGB values of the object to paste
%   - srcPoly: [x y]' vertices of the polygon defining the object's boundaries in srcImg
%   - selectedImgHighres: high resolution version of the selected image
%   - option: option for interp2 (see matlab documentation)
%
% Output parameters:
%   - resultImg: resulting image. 
%
% Warning:
%   - This function simply copies the pixels from one image to another. It
%     does not assume anything about the target and source images being the
%     same size.
%   
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [resultImg, H] = pasteObjectOnImage(targetImg, targetPoly, srcImg, srcPoly, srcImgHighres, option) 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin == 5
    % bilinear interpolation
    option = 'linear'; 
end

% Back-project each pixel on the targetImg to the srcImg and get pixel value by bilinear
% interpolation

% Resize the polygon to the dimensions of the high-resolution image
scale = size(srcImgHighres) ./ size(srcImg);
srcPoly = srcPoly .* repmat(scale([2 1])', 1, size(srcPoly,2));

[hTgt, wTgt, cTgt] = size(targetImg);

% find all the pixel coordinates associated with the target polygon
maskTgt = poly2mask(targetPoly(1,:), targetPoly(2,:), hTgt, wTgt);
[rPolyTgt, cPolyTgt] = find(maskTgt > 0);

% find the mapping between the points in targetPoly and srcPoly, s.t. src = H*tgt
x = [targetPoly; ones(1, size(targetPoly,2))];
y = [srcPoly; ones(1, size(srcPoly,2))];
H = vgg_mrdivs(x,y);

resultImg = backProjectPixels(H, [rPolyTgt cPolyTgt], srcImgHighres, targetImg, option);

