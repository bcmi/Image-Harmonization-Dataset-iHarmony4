% FINDIMAGE - invokes image dialog box for interactive image loading
%
% Usage:  [im, filename] = findimage(disp, c)
%
% Arguments: 
%           disp - optional flag 1/0 that results in image being displayed
%              c - optional flag 1/0 that results in imcrop being invoked 
% Returns:
%             im - image
%       filename - filename of image

% Peter Kovesi  
% School of Computer Science & Software Engineering
% The University of Western Australia
% http://www.csse.uwa.edu.au/~pk
%
% March 2010

function [im, filename] = findimage(disp, c)

    if ~exist('disp','var'),  disp = 0;  end
    if ~exist('c','var'),     c = 0;     end
    
    [filename, user_canceled] = imgetfile;
    if user_canceled
        im = [];
        filename = [];
        return;
    end
    
    im = imread(filename);    
    
    if c
        fprintf('Crop a section of the image\n')
        figure(99), clf, im = imcrop(im); delete(99)
    end
    
    if disp
        show(im, 99);
    end
    
     
     