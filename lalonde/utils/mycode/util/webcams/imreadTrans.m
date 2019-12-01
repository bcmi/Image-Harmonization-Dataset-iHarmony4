%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function [im, imWarp, maskWarp] = imreadTrans(imgPath) 
%  Reads an image, but also its transformation with respect to a reference
%  image. Useful when a camera is moving. Performs the transformation on
%  the fly to save memory on disk.
% 
% Input parameters:
% 
% Output parameters:
%   
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [im, imWarp, maskWarp] = imreadTrans(imgPath, varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% parse arguments
defaultArgs = struct('Mask', []);
args = parseargs(defaultArgs, varargin{:});

im = im2double(imread(imgPath));
if isempty(args.Mask)
    args.Mask = ones(size(im,1), size(im,2));
end

if nargout > 1
    % load homography
    hFilename = strrep(imgPath, '.jpg', '.mat');
    if exist(hFilename, 'file')
        hData = load(hFilename);
        imWarp = vgg_warp_H(im, hData.H, 'linear', 'img');
        imWarp(isnan(imWarp)) = 0;
        if nargout > 2
            
            % apply transformation to mask too
            maskWarp = vgg_warp_H(args.Mask, hData.H, 'linear', 'img') > 0.5;
            maskWarp(isnan(maskWarp)) = 0;
        end
    else
        % no homography: return original image
        imWarp = im;
        if nargout > 2
            maskWarp = args.Mask;
        end
    end
end
