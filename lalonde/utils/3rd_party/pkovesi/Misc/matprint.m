% MATPRINT - prints a matrix with specified format string
%
% Usage: matprint(a, fmt, fid)
%
%                 a   - Matrix to be printed.
%                 fmt - C style format string to use for each value.
%                 fid - Optional file id.
%
% Eg. matprint(a,'%3.1f') will print each entry to 1 decimal place

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

% March 2002

function matprint(a, fmt, fid)
    
    if nargin < 3
	fid = 1;
    end
    
    [rows,cols] = size(a);
    
    % Construct a format string for each row of the matrix consisting of
    % 'cols' copies of the number formating specification
    fmtstr = [];
    for c = 1:cols
      fmtstr = [fmtstr, ' ', fmt];
    end
    fmtstr = [fmtstr '\n'];    % Add a line feed
    
    fprintf(fid, fmtstr, a');  % Print the transpose of the matrix because
                               % fprintf runs down the columns of a matrix.