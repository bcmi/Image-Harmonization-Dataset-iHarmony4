% ADJCONTRAST - Adjusts image contrast using sigmoid function.
%
% function g = adjcontrast(im, gain, cutoff)
%
% Arguments:
%            im     - image to be processed.
%            gain   - controls the actual contrast; 
%                     A value of about 5 is neutral (little change).
%                     A value of 1 reduces contrast to about 20% of original
%                     A value of 10 increases contrast about 2.5x.
%                     a reasonable range of values to experiment with.
%            cutoff - represents the (normalised) grey value about which
%                     contrast is increased or decreased.  An initial
%                     value you might use is 0.5 (the midpoint of the
%                     greyscale) but different images may require
%                     different points of the greyscale to be enhanced.  

% Copyright (c) 2001 Peter Kovesi
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

% July 2001

function newim = adjcontrast(im, gain, cutoff)

    if isa(im,'uint8');
	newim = double(im);
    else 
	newim = im;
    end
    	
    % rescale range 0-1
    newim = newim-min(min(newim));
    newim = newim./max(max(newim));

    newim =  1./(1 + exp(gain*(cutoff-newim)));  % Apply Sigmoid function


