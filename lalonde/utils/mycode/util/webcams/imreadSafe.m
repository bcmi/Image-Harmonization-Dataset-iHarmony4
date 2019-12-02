%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function im = imreadSafe(imgPath)
%  Imread makes the system crash when a jpeg is malformed. This version
%  (which will be slightly slower and does not support all the options of
%  the original one) checks the size of the image before opening it, and
%  will open only images larger than 1K.
% 
% Input parameters:
%ip
% Output parameters:
%   
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [im, imWarp, maskWarp] = imreadSafe(imgPath, varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% parse arguments
defaultArgs = struct('Mask', []);
args = parseargs(defaultArgs, varargin{:});

if ~isempty(strfind(imgPath, 'http://'))
    % don't do any fancy-schmancy processing: we're read-only test mode 
    im = imread(imgPath);
    imWarp = []; maskWarp = [];
    return;
end

p = dir(imgPath);

if p.bytes < 300
    % bad image!
    im = []; imWarp = []; maskWarp = [];
    return;
else
    lastwarn('test', 'MATLAB:rjpg8c:libraryMessage');
    im = im2double(imread(imgPath));
    [msg, msgId] = lastwarn;
    
    if strcmp(msgId, 'MATLAB:rjpg8c:libraryMessage') && ~strcmp(msg, 'test')
        % bad image!
        im = []; imWarp = []; maskWarp = [];
        return;
    end
    
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
end
