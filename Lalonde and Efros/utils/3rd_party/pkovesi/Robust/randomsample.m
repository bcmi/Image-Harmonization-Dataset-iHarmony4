% RANDOMSAMPLE - selects n random items from an array
%
% Usage:  items = randomsample(a, n)
%
% Arguments:    a - Either an array of values from which the items are to
%                   be selected, or an integer in which case the items
%                   are values selected from the array [1:a]
%               n - The number of items to be selected.
%
%
% This function can be used as a basic replacement for RANDSAMPLE for those
% who do not have the statistics toolbox.
% Also,
%    r = randomsample(n,n) will give a random permutation of the integers 1:n 
%
% See also: RANSAC

% Strategy is to generate a random integer index into the array and select that
% item from the array.  The selected element in the array is then overwritten by
% the last element in the array and the process is then repeated except that
% when we select the next element we generate a random integer index that lies
% in the range 1 to arraylength - 1, and so on.  This ensures items are not
% repeated.

% Copyright (c) 2006 Peter Kovesi
% School of Computer Science & Software Engineering
% The University of Western Australia
% pk at csse uwa edu au    
% http://www.csse.uwa.edu.au/~pk
% 
% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the "Software"), to deal
% in the Software without restriction, subject to the following conditions:
% 
% The above copyright notice and this permission notice shall be included in 
% all copies or substantial portions of the Software.
%
% The Software is provided "as is", without warranty of any kind.

% September   2006 



function item = randomsample(a, n)
    
    npts = length(a);

    if npts == 1   % We have a scalar argument for a
	npts = a;
	a = [1:a]; % Construct an array 1:a
    end
    
    if npts < n
	error(...
	sprintf('Trying to select %d items from a list of length %d',n, npts));
    end
    
    item = zeros(1,n);
    
    for i = 1:n
	% Generate random value in the appropriate range 
	r = ceil((npts-i+1).*rand);
	item(i) = a(r);       % Select the rth element from the list
	a(r)    = a(end-i+1); % Overwrite selected element
    end                       % ... and repeat