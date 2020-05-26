% Function to make ramps test surface for shape from shapelet testing
%
% Usage:
%           function [z,s,t] = testp(noise)
%
% Arguments:
%              noise - An optional parameter specifying the standard
%                      deviation of Gaussian noise to add to the slant and tilt
%                      values. 
% Returns;
%              z     - A 2D array of surface height values which can be
%                      viewed using surf(z)
%              s,t   - Corresponding arrays of slant and tilt angles in
%                      radians for each point on the surface.

% Copyright (c) 2003-2005 Peter Kovesi
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

% July      2003  - Original version
% August    2005  - Changes to accommodate Octave
% September 2008  - Needle plot reinstated for Octave

function [z,s,t] = testp(noise)

    Octave = exist('OCTAVE_VERSION') ~= 0;  % Are we running under Octave?    

    if nargin == 0
	noise = 0;
    end
    
    p1 = [zeros(1,15) [0:.2:10] zeros(1,15)];
    p2 = zeros(1,length(p1));
    n = ceil(length(p1)/2);
    p3 = [1:n n:-1:1]/n*6;
    p3 = p3(1:length(p1));
    
    z = [ones(15,1)*p2
	 ones(15,1)*p1
	 ones(15,1)*p3
	 ones(15,1)*p2];
    
    
    figure(1); clf;% surfl(z), shading interp; colormap(copper);
    surf(z);       % colormap(white);
    
    [dx, dy] = gradient(z);
    [s,t] = grad2slanttilt(dx,dy);
    
    [rows,cols] = size(s);

    if noise
	if Octave
	    t = t + noise*randn(rows,cols);
	    s = s + noise*randn(rows,cols);	   
	else
	    t = t + random('Normal',0,noise,rows,cols);  % add noise to tilt
	    s = s + random('Normal',0,noise,rows,cols);  % ... and slant
	end
	% constrain noisy slant values to 0-pi
	s = max(s, 0);
	s = min(s, pi/2-0.05);  % -0.05 to avoid infinite gradient
    end
    
    figure(2),needleplotst(s,t,5,2), axis('off')
    
    