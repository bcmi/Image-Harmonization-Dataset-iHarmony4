% HOMOMORPHIC - Performs homomorphic filtering on an image.
%
% Function performs homomorphic filtering on an image. This form of
% filtering sharpens features and flattens lighting variantions in an image.
% It usually is very effective on images which have large variations in
% lighting, for example when a subject appears against strong backlighting.
%
%
% Usage: newim =
% homomorphic(inimage,boost,CutOff,order,lhistogram_cut,uhistogram_cut, hndl)
% homomorphic(inimage,boost,CutOff,order,lhistogram_cut,uhistogram_cut)
% homomorphic(inimage,boost,CutOff,order,hndl)
% homomorphic(inimage,boost,CutOff,order)
%
% Parameters:  (suggested values are in brackets)
%         boost    - The ratio that high frequency values are boosted
%                    relative to the low frequency values (2).
%         CutOff   - Cutoff frequency of the filter (0 - 0.5)
%         order    - Order of the modified Butterworth style filter that
%                    is used, this must be an integer > 1 (2)
%         lhistogram_cut - Percentage of the lower end of the filtered image's
%                          histogram to be truncated, this eliminates extreme
%                          values in the image from distorting the final result. (0)
%         uhistogram_cut - Percentage of upper end of histogram to truncate. (5)
%         hndl           - Optional handle to text box for updating
%                          messages to be sent to a GUI interface.
%
%  If lhistogram_cut and uhistogram_cut are not specified no histogram truncation will be
%  applied.
%
%
% Suggested values: newim = homomorphic(im, 2, .25, 2, 0, 5);
%

% homomorphic called with no arguments invokes GUI interface.
%
% or simply   homomorphic  to invoke the GUI   - GUI version does not work!

% Copyright (c) 1999-2001 Peter Kovesi
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

% June 1999
% December 2001 cleaned up and modified to work with colour images

function him = homomorphic(im, boost, CutOff, order, varargin)
    

%    if nargin == 0             % invoke GUI if it exists
%	if exist('homomorphicGUI.m');
%	    homomorphicGUI;
%	    return;
%	else
%	    error('homomorphicGUI does not exist');
%	end
%    
%    else
    
	if ndims(im) == 2  % Greyscale image
	    him = Ihomomorphic(im, boost, CutOff, order, varargin);
	    
	else               % Assume colour image in RGB format
	    hsv = rgb2hsv(im);   % Convert to HSV and apply homomorphic
				 % filtering to just the intensity component.
            hsv(:,:,3) = Ihomomorphic(hsv(:,:,3), boost, CutOff, order, varargin);
	    him = hsv2rgb(hsv);  % Convert back to RGB
	end
	
%    end
    
%------------------------------------------------------------------------
% Internal function that does the real work
%------------------------------------------------------------------------    
	
function him = Ihomomorphic(im, boost, CutOff, order, varargin)

    % The possible elements in varargin are:
    % {lhistogram_cut, uhistogram_cut, hndl}

    varargin = varargin{:};
    
    if nargin == 5
	nopparams  = length(varargin);
    end
    
    if (nopparams == 3)
	dispStatus = 1;
	truncate = 1;
	lhistogram_cut = varargin{1};
	uhistogram_cut = varargin{2};	
	hndl = varargin{3};		
    elseif (nopparams == 2)
	dispStatus = 0;
	truncate = 1;
	lhistogram_cut = varargin{1};
	uhistogram_cut = varargin{2};	
    elseif (nopparams == 1)
	dispStatus = 1;
	truncate = 0;
	hndl = varargin{1};			
    elseif (nopparams == 0)
	dispStatus = 0;
	truncate = 0;
    else
	disp('Usage: newim = homomorphic(inimage,LowGain,HighGain,CutOff,order,lhistogram_cut,uhistogram_cut)');
	error('or    newim = homomorphic(inimage,LowGain,HighGain,CutOff,order)');
    end
    
    [rows,cols] = size(im);
    
    im = normalise(im);                        % Rescale values 0-1 (and cast
					       % to `double' if needed).
    FFTlogIm = fft2(log(im+.01));              % Take FFT of log (with offset
                                               % to avoid log of 0).
    h = highboostfilter([rows cols], CutOff, order, boost);
    him = exp(real(ifft2(FFTlogIm.*h)));       % Apply the filter, invert
					       % fft, and invert the log.

    if truncate
						   
	% Problem:
	% The extreme bright values in the image are exaggerated by the filtering.  
	% These (now very) bright values have the overall effect of darkening the
	% whole image when we rescale values to 0-255.
	%
	% Solution:
	% Construct a histogram of the image.  Find the level below which a high
	% percentage of the image lies (say 95%).  Saturate the grey levels in
	% the image to this level.
	
	if dispStatus
	    set(hndl,'String','Calculating histogram and truncating...');
	    drawnow;
	else
	    disp('Calculating histogram and truncating...');
	end
	
	him = histtruncate(him, lhistogram_cut, uhistogram_cut);

    else
	him = normalise(him);  % No truncation, but fix range 0-1
    end
    



