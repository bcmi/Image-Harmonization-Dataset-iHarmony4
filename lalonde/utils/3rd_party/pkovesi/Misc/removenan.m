% REMOVENAN - removes NaNs from an array 
%
% Usage: m = removenan(a, defaultval)
%
%   a          - The matrix containing NaN values
%   defaultval - The default value to replace NaNs
%                if omitted this defaults to 0
%
% See Also: FILLNAN

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

% September 2004


function m = removenan(a, defaultval)
    
    if nargin == 1
	defaultval = 0;
    end
    
    valid = find(~isnan(a));
    
    m = repmat(defaultval, size(a));
    m(valid) = a(valid);