% NOISEONF - Creates 1/f spectrum noise images.
%
% Function to create noise images having 1/f amplitude spectum properties.
% When displayed as a surface these images also generate great landscape
% terrain. 
%
% Usage: im = noiseonf(size, factor)
%
%        size   - A 1 or 2-vector specifying size of image to produce [rows cols]
%        factor - controls spectrum = 1/(f^factor)
%
%        factor = 0   - raw Gaussian noise image
%               = 1   - gives the 1/f 'standard' drop-off for 'natural' images
%               = 1.5 - seems to give the most interesting 'cloud patterns'
%               = 2 or greater - produces 'blobby' images

% Copyright (c) 1996-2011 Peter Kovesi
% Centre for Exploration Targeting
% The University of Western Australia
% http://www.csse.uwa.edu.au/~pk
% 
% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the "Software"), to deal
% in the Software without restriction, subject to the following conditions:
% The above copyright notice and this permission notice shall be included in 
% all copies or substantial portions of the Software.
% The Software is provided "as is", without warranty of any kind.

%  December  1996
%  March     2009 Arbitrary image size 
%  September 2011 Code tidy up

function im = noiseonf(sze, factor)
    
    if length(sze) == 2
        rows = sze(1); cols = sze(2);
    elseif length(sze) == 1
        rows = sze;  cols = sze;
    else
        error('size must be a 1 or 2-vector');
    end
    
    % Generate an image of random Gaussian noise, mean 0, std dev 1.    
    im = randn(rows,cols); 
    
    imfft = fftshift(fft2(im));      % Take fft of image.
    mag = abs(imfft);                % Get magnitude
    phase = imfft./mag;              % and phase
    
    % Construct the amplitude spectrum filter
    [x,y] = meshgrid([-cols/2:(cols/2-1)], [-rows/2:(rows/2-1)]);
    radius = sqrt(x.^2 + y.^2);     % Matrix values contain radius from centre.
    radius(rows/2+1,cols/2+1) = 1;  % .. avoid division by zero.
    filter = 1./(radius.^factor);   % Construct the filter.
    
    % Reconstruct fft of noise image, but now with the specified amplitude
    % spectrum
    newfft =  filter .* phase; 
    im = real(ifft2(fftshift(newfft))); % Invert to obtain final noise image

%caption = sprintf('noise with 1/(f^%2.1f) amplitude spectrum',factor);
%imagesc(im), axis('equal'), axis('off'), title(caption);