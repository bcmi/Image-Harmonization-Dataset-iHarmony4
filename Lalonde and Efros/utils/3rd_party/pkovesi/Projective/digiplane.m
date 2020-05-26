% DIGIPLANE - Digitise and transform points within a planar region in an image.
%
% This function allows you to digitise points within a planar region of an
% image for which an inverse perspective transformation has been previously
% determined using, say, INVPERSP.  The digitised points are then
% transformed into coordinates defined in terms of the reference frame.
%
% Usage:  pts = digiplane(im, T, xyij)
%
% Arguments:    im   - Image. 
%               T    - Inverse perspective transform.
%               xyij - An optional string 'xy' or 'ij' indicating what
%                      coordinate system should be used when displaying
%                      the image. 
%                      xy - cartesian system with origin at bottom-left.
%                      ij - 'matrix' system with origin at top-left.
%                      An image which has been rectified, say using
%                      imTrans, may want 'xy' set.
%
% Returns:      pts  - Nx2 array of transformed (x,y) coordinates.
%
% See also: invpersp, imTrans
%
%
% Examples of use:
%     Assuming you have an image `im' for which you have a set of image
%     points 'impts' and a corresponding set of reference points 'refpts'.
%
%     T = invpersp(refpts, impts);  % Compute perspective transformation.
%     p = digiplane(im,T);          % Digitise points in original image.
%
%   ... or work with the rectified image
%     [newim, newT] = imTrans(im,T); % Rectify image using T from above
%     p = digiplane(newim,newT);     % Digitise points in rectified image. 

%  Peter Kovesi  
%  School of Computer Science & Software Engineering
%  The University of Western Australia
%  pk @ csse uwa edu au
%  http://www.csse.uwa.edu.au/~pk
%
%  August 2001

function pts = digiplane(im, T, xyij)
    
    if nargin < 3
	xyij = 'ij';
    end
    
    pts = [];
    figure(1), clf, imshow(im), axis(xyij), hold on
    
    fprintf('Digitise points in the image with the left mouse button\n');
    fprintf('Click any other button to exit\n');

    [x,y,but] = ginput(1);
    while but == 1
	p = T*[x;y;1];          % Transform point.
	xp = p(1)/p(3);
	yp = p(2)/p(3);
	pts = [pts; xp yp];
	
	plot(x,y,'r+');         % Mark coordinates on image.
	text(x+3,y-3,sprintf('[%.1f, %.1f]',xp,yp),'Color',[0 0 1], ...
	     'FontSize',6); 

	[x,y,but] = ginput(1); 	% Get next point.
    end
    




