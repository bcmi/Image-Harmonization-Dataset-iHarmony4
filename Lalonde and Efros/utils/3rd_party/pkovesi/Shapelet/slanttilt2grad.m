% SLANTTILT2GRAD - slant and tilt to gradient in x y 
%
% Function to convert a matrix of slant and tilt values to
% surface gradients.
% 
% Usage:    [dzdx, dzdy] = slanttilt2grad(slant, tilt)
%

% Copyright (c) 2003 Peter Kovesi
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

% July 2003


function [dzdx, dzdy] = slanttilt2grad(slant, tilt)
  
  if ~all(size(slant) == size(tilt))
    error('slant matrix must have same dimensions as tilt');
  end
  
  gradmag = tan(slant); 

  dzdx = -gradmag.*cos(tilt);
  dzdy = -gradmag.*sin(tilt);
