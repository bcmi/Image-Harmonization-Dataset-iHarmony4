% SUPERTORUS - generates  a 'supertorus' surface
%
% Usage:
%          [x,y,z] = supertorus(xscale, yscale, zscale, rad, e1, e2, n)
%
% Arguments:
%        xscale, yscale, zscale  - Scaling in the x, y and z directions.
%        e1, e2      - Exponents of the x and y coords.
%        rad         - Mean radius of torus. 
%        n           - Number of subdivisions of logitude and latitude on
%                      the surface.
%
% Returns: x,y,z  - matrices defining paramteric surface of superquadratic
%
% If the result is not assigned to any output arguments the function
% plots the surface for you, otherwise the x, y and z parametric
% coordinates are returned for subsequent display using, say, SURFL.
%
% If rad is set to 0 the surface becomes a superquadratic
%
% Examples:
%     supertorus(1, 1, 1, 2, 1, 1, 100)   -  classical torus 100 subdivisions
%     supertorus(1, 1, 1, .8, 1, 1, 100)  -  an 'orange'
%     supertorus(1, 1, 1, 2, .1, 1, 100)  -  a round 'washer'
%     supertorus(1, 1, 1, 2, .1, 2, 100)  -  a square 'washer'
%
% See also: SUPERQUAD

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

function [x,y,z] = supertorus(xscale,yscale,zscale,rad,e1,e2, n)
    
    long = ones(n,1)*[-pi:2*pi/(n-1):pi];
    lat  = [-pi:2*pi/(n-1): pi]'*ones(1,n);
    
    x = xscale * (rad + pow(cos(lat),e1)) .* pow(cos(long),e2);
    y = yscale * (rad + pow(cos(lat),e1)) .* pow(sin(long),e2);
    z = zscale * pow(sin(lat),e1);
    
    if nargout == 0
        surfl(x,y,z), shading interp, colormap(copper), axis equal
        clear x y z  % suppress output
    end
    
%--------------------------------------------------------------------
% Internal function providing a modified definition of power whereby the
% sign of the result always matches the sign of the input value.

function r = pow(a,p)
    
    r = sign(a).* abs(a.^p);
