% SHOWLOGFFT - Displays log amplitude spectrum of an fft.
%
% Usage:  showlogfft(ft, figNo)
%
% Arguments:  ft    - Fourier transform to be displayed
%             figNo - Optional figure number to display image in.
%
% The fft is quadrant shifted to place zero frequency at the centre and the
% log of the amplitude displayed (to compress grey values).  An offset of 1
% is added to avoid log(0)
%
% If figNo is omitted a new figure window is created.  If figNo is supplied,
% and the figure exists, the existing window is reused to display the image,
% otherwise a new window is created.

% Copyright (c) 1999 Peter Kovesi
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

% October 1999
% September 2008 Octave compatible
function showlogfft(im, figNo)

    Octave = exist('OCTAVE_VERSION') ~= 0;  % Are we running under Octave?     
    Title = inputname(1);      % Get variable name of image data    
        
    if nargin == 2
	figure(figNo);         % Reuse or create a figure window with this number
    else
	figNo = figure;        % Create new figure window
    end

    imagesc(log(fftshift(abs(im))+1));
    colormap(gray); title(Title), axis('image')
    if ~Octave; truesize(figNo), end
