% POLARTRANS - Transforms image to polar coordinates
%
% Usage:    pim = polartrans(im, nrad, ntheta, cx, cy, linlog, shape)
%
% Arguments:
%           im     - image to be transformed.
%           nrad   - number of radius values.
%           ntheta - number of theta values.
%           cx, cy - optional specification of origin.  If this is not
%                    specified it defaults to the centre of the image.
%           linlog - optional string 'linear' or 'log' to obtain a
%                    transformation with linear or logarithmic radius
%                    values. linear is the default.
%           shape  - optional string 'full' or 'valid'
%                    'full' results in the full polar transform being
%                    returned (the circle that fully encloses the original
%                    image). This is the default.
%                    'valid' returns the polar transform of the largest
%                    circle that can fit within the image. 
%
% Returns   pim    - image in polar coordinates with radius increasing
%                    down the rows and theta along the columns. The size
%                    of the image is nrad x ntheta.  Note that theta is
%                    +ve clockwise as x is considered +ve along the
%                    columns and y +ve down the rows. 
%
% When specifying the origin it is assumed that the top left pixel has
% coordinates (1,1).

% Copyright (c) 2002 Peter Kovesi
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

% December 2002
% November 2006  Correction to calculation of maxlogr (thanks to Chang Lei)

function pim = polartrans(im, nrad, ntheta, cx, cy, linlog, shape)

[rows, cols] = size(im);

if nargin==3         % Set origin to centre.
    cx = cols/2+.5;  % Add 0.5 because indexing starts at 1
    cy = rows/2+.5;
end

if nargin < 7, shape = 'full'; end
if nargin < 6, linlog = 'linear'; end

if strcmp(shape,'full')         % Find maximum radius value
    dx = max([cx-1, cols-cx]);
    dy = max([cy-1, rows-cy]);
    rmax = sqrt(dx^2+dy^2);
elseif strcmp(shape,'valid')    % Find minimum radius value
    rmax = min([cx-1, cols-cx, cy-1, rows-cy]);
else
    error('Invalid shape specification');
end

% Increments in radius and theta

deltatheta = 2*pi/ntheta;

if strcmp(linlog,'linear')
    deltarad = rmax/(nrad-1);
    [theta, radius] = meshgrid([0:ntheta-1]*deltatheta, [0:nrad-1]*deltarad);    
elseif strcmp(linlog,'log')
    maxlogr = log(rmax);
    deltalogr = maxlogr/(nrad-1);    
    [theta, radius] = meshgrid([0:ntheta-1]*deltatheta, exp([0:nrad-1]*deltalogr));
else
    error('Invalid radial transformtion (must be linear or log)');
end

xi = radius.*cos(theta) + cx;  % Locations in image to interpolate data
yi = radius.*sin(theta) + cy;  % from. 

[x,y] = meshgrid([1:cols],[1:rows]);
pim = interp2(x, y, double(im), xi, yi);

