% GRAD2SLANTTILT - gradient in x y to slant tilt
%
% Function to convert a matrix of surface gradients to 
% slant and tilt values.
% 
% Usage:    [slant, tilt] = grad2slanttilt(dzdx, dzdy)
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


function [slant, tilt] = grad2slanttilt(dzdx, dzdy)
  
  if ~all(size(dzdx) == size(dzdy))
    error('dzdx must have same dimensions as dzdy');
  end
  
  tilt = atan2(-dzdy, -dzdx);

  gradmag = sqrt(dzdx.^2 + dzdy.^2)+eps;
  slant =  atan(gradmag);
  
  
