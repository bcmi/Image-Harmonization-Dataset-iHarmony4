% EXTRACTFIELDS  - Separates fields from a video frame.
%
% Function to separate fields from a video frame
% and (optionally) interpolate intermediate lines
% for each field.
%
% Usage: [f1, f2] = extractfields(im,interp)
%
%   f1 and f2 are the odd and even fields
%   im is the frame to be split
%   interp is an optional string `interp' indicating
%   whether f1 and f2 should be padded out with interpolated
%   lines.

% Copyright (c) 2000 Peter Kovesi
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

% May 2000

function [f1, f2] = extractfields(im,interpstring)
    
    if nargin < 2
	interpstring = 'nointerp';
    end
    
    if (ndims(im)==3),    % A colour image - Transform red, green, blue components separately
	[f1r, f2r] = extractFieldsI(im(:,:,1), interpstring);
	[f1g, f2g] = extractFieldsI(im(:,:,2), interpstring);
	[f1b, f2b] = extractFieldsI(im(:,:,3), interpstring);
	
	% Reform colour image for field 1
	f1 = repmat(uint8(0),[size(f1r),3]);
	f1(:,:,1) = uint8(round(f1r));
	f1(:,:,2) = uint8(round(f1g));
	f1(:,:,3) = uint8(round(f1b));
	
	% Reform colour image for field 2
	f2 = repmat(uint8(0),[size(f2r),3]);
	f2(:,:,1) = uint8(round(f2r));
	f2(:,:,2) = uint8(round(f2g));
	f2(:,:,3) = uint8(round(f2b));
	
    else         % Assume grey scale image
	[f1, f2] = extractFieldsI(im,interpstring);
    end
    
    
function  [f1, f2] = extractFieldsI(im,interpstring)
    
    [rows,cols] = size(im);
    im = double(im);
    if nargin==2
	if strcmp(interpstring, 'interp')
	    interp = 1;
	elseif strcmp(interpstring, 'nointerp')
	    interp = 0;
	else
	    warning(['unknown interpolation option - no interpolation is' ...
		     ' being used']);
	    interp = 0;
	end
    else
	interp = 0;
    end
    
    
    if mod(rows,2) == 1
	rows = rows-1;        % This ensures even and odd fields end up with 
    end                     % the same No of rows
    
    f1 = im(1:2:rows,:);   % odd lines
    f2 = im(2:2:rows,:);   % even lines
    
    if interp
	f1 = interpfields(f1,'odd');
	f2 = interpfields(f2,'even');
    end
    
    

