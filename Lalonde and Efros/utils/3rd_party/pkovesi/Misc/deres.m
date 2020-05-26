% DERES -  Deresolves an image.
%
% Usage:  im2 = deres(im, s)
%
% Arguments:  im  - image to be deresolved
%             s   = deresolution factor
%
% Returns the deresolved image

% PK October 2000

function im2 = deres(im, s)

    if ndims(im) == 3  % Assume colour image
	im2 = zeros(size(im));
	im2(:,:,1) = blkproc(im(:,:,1),[s s], 'mean2(x)');
	im2(:,:,2) = blkproc(im(:,:,2),[s s], 'mean2(x)');
	im2(:,:,3) = blkproc(im(:,:,3),[s s], 'mean2(x)');
    else
	im2 = blkproc(im,[s s], 'mean2(x)');
    end
    
    

    