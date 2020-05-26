% HOMOGREPROJERR
%
% Computes the symmetric reprojection error for points related by a
% homography.
%
% Usage:
%           d2 = homogreprojerr(H, x1, x2)
%
% Arguments:
%           H      - The homography.
%           x1, x2 - [ndim x npts] arrays of corresponding homogeneous
%                    data points.
%
% Returns:
%           d2 - 1 x npts vector of squared reprojection distances for
%                each corresponding pair of points.

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

% May      2003
% November 2005 - bug fix (thanks to Scott Blunsden)

function d2 = homogreprojerr(H, x1, x2)
     
    x2t = H*x1;      % Calculate projections of points
    x1t = H\x2;
 
    x1  = hnormalise(x1);  % Ensure scale is 1
    x2  = hnormalise(x2);    
    x1t = hnormalise(x1t);
    x2t = hnormalise(x2t);    
    
    d2 = sum( (x1-x1t).^2  + (x2-x2t).^2) );