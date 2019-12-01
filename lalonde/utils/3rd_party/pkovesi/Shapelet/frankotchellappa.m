% FRANKOTCHELLAPPA  - Generates integrable surface from gradients
%
% An implementation of Frankot and Chellappa'a algorithm for constructing
% an integrable surface from gradient information.
%
% Usage:      z = frankotchellappa(dzdx,dzdy)
%
% Arguments:  dzdx,  - 2D matrices specifying a grid of gradients of z
%             dzdy     with respect to x and y.
%
% Returns:    z      - Inferred surface heights.

% Reference:
%
% Robert T. Frankot and Rama Chellappa
% A Method for Enforcing Integrability in Shape from Shading
% IEEE PAMI Vol 10, No 4 July 1988. pp 439-451
%
% Note this code just implements the surface integration component of the
% paper (Equation 21 in the paper).  It does not implement their shape from
% shading algorithm.

% Copyright (c) 2004 Peter Kovesi
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

% October 2004

function z = frankotchellappa(dzdx,dzdy)
    
    if ~all(size(dzdx) == size(dzdy))
      error('Gradient matrices must match');
    end

    [rows,cols] = size(dzdx);
    
    % The following sets up matrices specifying frequencies in the x and y
    % directions corresponding to the Fourier transforms of the gradient
    % data.  They range from -0.5 cycles/pixel to + 0.5 cycles/pixel. The
    % fiddly bits in the line below give the appropriate result depending on
    % whether there are an even or odd number of rows and columns
    
    [wx, wy] = meshgrid(([1:cols]-(fix(cols/2)+1))/(cols-mod(cols,2)), ...
			([1:rows]-(fix(rows/2)+1))/(rows-mod(rows,2)));
    
    % Quadrant shift to put zero frequency at the appropriate edge
    wx = ifftshift(wx); wy = ifftshift(wy);

    DZDX = fft2(dzdx);   % Fourier transforms of gradients
    DZDY = fft2(dzdy);

    % Integrate in the frequency domain by phase shifting by pi/2 and
    % weighting the Fourier coefficients by their frequencies in x and y and
    % then dividing by the squared frequency.  eps is added to the
    % denominator to avoid division by 0.
    
    Z = (-j*wx.*DZDX -j*wy.*DZDY)./(wx.^2 + wy.^2 + eps);  % Equation 21
    
    z = real(ifft2(Z));  % Reconstruction
