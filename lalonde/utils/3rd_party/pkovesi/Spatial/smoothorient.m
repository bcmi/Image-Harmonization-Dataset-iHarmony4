% SMOOTHORIENT - applies smoothing to orientation field
%
% Usage: smorient = smoothorient(orient, sigma)
%
% Input:
%       orient - Image containing feature normal orientation angles in degrees.
%       sigma  - Standard deviation of Gaussian to use (try 1)
%
% Returns:
%       smorient - Smoothed orientation image.
%
% It seems to be useful to smooth the orientation field returned by phasecong2
% before applying nonmaximal suppression.
%
% See Also:  NONMAXSUP, PHASECONG2

% Copyright (c) 2007 Peter Kovesi
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

function smor = smoothorient(or, sigma)
    
    or = or/180*pi;   % Convert orientations to radians
    
    % Smoothing is applied separately to the sine and cosine of the angles to
    % avoid wraparound problems.
    cosor = cos(or);
    sinor = sin(or);

    f = fspecial('gaussian', max(1,fix(6*sigma)), sigma);
    cosor = filter2(f,cosor);
    sinor = filter2(f,sinor);
    
    % Reconstitute angles and convert back to degrees
    smor = atan2(sinor, cosor)/pi*180;
