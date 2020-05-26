% SUPERQUAD - generates a superquadratic surface
%
% Usage:  [x,y,z] = superquad(xscale, yscale, zscale, e1, e2, n)
%
% Arguments:
%        xscale, yscale, zscale  - Scaling in the x, y and z directions.
%        e1, e2      - Exponents of the x and y coords.
%        n           - Number of subdivisions of logitude and latitude on
%                      the surface.
%
% Returns: x,y,z  - matrices defining paramteric surface of superquadratic
%
% If the result is not assigned to any output arguments the function
% plots the surface for you, otherwise the x, y and z parametric
% coordinates are returned for subsequent display using, say, SURFL.
%
% Examples:
%     superquad(1, 1, 1, 1, 1, 100)   -  sphere of radius 1 with 100 subdivisions
%     superquad(1, 1, 1, 2, 2, 100)   -  octahedron of radius 1 
%     superquad(1, 1, 1, 3, 3, 100)   - 'pointy' octahedron 
%     superquad(1, 1, 1, .1, .1, 100) -  cube (with rounded edges)
%     superquad(1, 1, .2, 1, .1, 100) - 'square cushion'
%     superquad(1, 1, .2, .1, 1, 100) -  cylinder
%
% See also: SUPERTORUS

% Copyright (c) 2000 Peter Kovesi
% School of Computer Science & Software Engineering
% The University of Western Australia
% pk at csse uwa edu au
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

% September 2000

function [x,y,z] = superquad(xscale, yscale, zscale, e1, e2, n)

    % Set up parameters of the parametric surface, in this case matrices
    % corresponding to longitude and latitude on our superquadratic sphere.
    long = ones(n,1)*[-pi:2*pi/(n-1):pi];
    lat  = [-pi/2:pi/(n-1): pi/2]'*ones(1,n);
    
    x = xscale * pow(cos(lat),e1) .* pow(cos(long),e2);
    y = yscale * pow(cos(lat),e1) .* pow(sin(long),e2);
    z = zscale * pow(sin(lat),e1);
    
    % Ensure top and bottom ends are closed.  If we do not do this you find
    % that due to numerical errors the ends may not be perfectly closed.
    x(1,:)   = 0; y(1,:)   = 0;
    x(end,:) = 0; y(end,:) = 0;    
    
    if nargout == 0
        surfl(x,y,z), shading interp, colormap(copper), axis equal
        clear x y z  % suppress output
    end

%--------------------------------------------------------------------
% Internal function providing a modified definition of power whereby the
% sign of the result always matches the sign of the input value.

function r = pow(a, p)
    
    r = sign(a).* abs(a).^p;
    