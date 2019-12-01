% GREYTRANS - Interactive greyscale manipulation of an image (RGB or greyscale)
%
% Usage:   [newim, x, y] = greytrans(im, npts)
%
% Arguments
%            im   - Image to be transformed
%            npts - Optional number of control points of the spline
%                   defining the  mapping function. This defaults to 4 if
%                   not specified.
%
% Returns:
%            newim - The transformed image.
%            x,y   - Coordinates of spline control points that define the
%                    mapping function.  These coordinates can be passed
%                    to the function REMAPIM if you want to apply the
%                    transformation to other images.
%
% Image intensity values are remapped to new values via a mapping
% function defined by a series of spline points.  The mapping function is
% defined over the range 0-1, accordingly the input image is normalised
% to the range 0-1.  The output image will also lie in this range.  
% Colour images are processed by first converting to HSV and then
% remapping the Value component and then reconstructing new RGB values.

% Copyright (c) 2002-2003 Peter Kovesi
% School of Computer Science & Software Engineering
% The University of Western Australia
% http://www.csse.uwa.edu.au/
% 
% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the "Software"), to deal
% in the Software without restriction, subject to the following conditions:
% 
% The above copyright notice and this permission notice shall be included in 
% all copies or substantial portions of the Software.
%
% The Software is provided "as is", without warranty of any kind.

% April 2002
% March 2003 - modified to work with colour images.

function [nim,x,y] = greytrans(im, npts)
    
    if nargin == 1
	npts = 4;    % default No of control points
    end

    if npts < 2
	error('Number of control points must be > 2');
    end
    
    x = [0:npts-1]/(npts-1); y = x;
    h = figure(1); clf
%    set(h,'Position',[150 100 800 550]), clf
    im = normalise(im);  % rescale range 0 - 1
    him1 = subplot('Position',[.025 .28 .45 .7]);
    him2 = subplot('Position',[.525 .28 .45 .7]);   
    hcp = subplot('Position',[.35 .03 .25 .25]);
    
    subplot(him1), imshow(im), title('Original Image');    
    subplot(him2), imshow(im), title('Remapped Image');        
    subplot(hcp), plotcurve(x,y);
    
    if ndims(im)==3        % Assume we have a colour image
	colour = 1;
        hsv = rgb2hsv(im);
	v =  hsv(:,:,3);   % Extract the value - this is what we want to
                           % remap
    else
	colour = 0;
    end
    
    fprintf('Manipulate the mapping curve by clicking with the left mouse button.\n');
    fprintf('The closest control point is moved to the digitised location.\n');
    fprintf('Click any other button to exit\n');
    
    but = 1;
    while but==1
	subplot(hcp), [xp yp but] = ginput(1);
	if but ~= 1
	    break;
	end
	ind = indexOfClosestPt(xp,yp,x,y);

	% Make sure control points cannot 'cross' each other and keep
        % x-coords of end points at 0 and 1
	if ind > 1 & ind < npts
	    if xp < x(ind-1)
		x(ind) = x(ind-1)+0.01;
	    elseif xp > x(ind+1)
		x(ind) = x(ind+1)-0.01;
	    else
		x(ind) = xp;
	    end
	elseif ind == 1
	    x(ind) = 0;
	elseif ind == npts
	    x(ind) = 1;
	end

	% Make sure you cannot put control points too high or low...
	if yp > 1   
	    yp = 1;
	elseif yp < 0
	    yp = 0;
	end

	y(ind) = yp;
	
	subplot(hcp), plotcurve(x,y);
	if colour
	    nv = remapim(v, x , y, 0);  % Remap value component
	    hsv(:,:,3) = nv;            % Reconstruct colour image
	    nim = hsv2rgb(hsv);
	else
	    nim = remapim(im, x , y, 0);
	end
	subplot(him2), imshow(nim), title('Remapped Image');
	drawnow
    end
    
%----------------------------------------------------------------
% Function to find control point closest to digitised location

function ind = indexOfClosestPt(xp,yp,x,y)
    dist = sqrt( (x-xp).^2 + (y-yp).^2 );
    [d,ind] = min(dist);

%----------------------------------------------------------------
% Function to plot mapping curve

function plotcurve(x,y)
    xx = [0:.01:1];    
    yy = spline(x,y,xx);    
    plot(x, y,'ro');    
    hold on
    plot(xx,yy);
    xlabel('input grey value');
    ylabel('output grey value');   
    title('Mapping Function');
    axis([0 1 0 1]), axis square
    drawnow
    hold off

    
