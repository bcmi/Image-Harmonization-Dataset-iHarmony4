% PLOTGABORFILTERS - Plots log-Gabor filters
%
% The purpose of this code is to see what effect the various parameter
% settings have on the formation of a log-Gabor filter bank.
%
% Usage: [Ffilter, Efilter, Ofilter] = plotgaborfilters(sze,  nscale, norient,...
%                                       minWaveLength, mult, sigmaOnf, dThetaOnSigma)
%
% Arguments:
% Many of the parameters relate to the specification of the filters in the frequency plane.  
%
%   Variable       Suggested   Description
%   name           value
%  ----------------------------------------------------------
%    sze             = 200     Size of image grid on which the filters
%                              are calculated.  Note that the actual size
%                              of the filter is really specified by its
%                              wavelength. 
%    nscale          = 4;      Number of wavelet scales.
%    norient         = 6;      Number of filter orientations.
%    minWaveLength   = 3;      Wavelength of smallest scale filter.
%    mult            = 2;      Scaling factor between successive filters.
%    sigmaOnf        = 0.65;   Ratio of the standard deviation of the
%                              Gaussian describing the log Gabor filter's
%                              transfer function in the frequency domain
%                              to the filter center frequency. 
%    dThetaOnSigma   = 1.5;    Ratio of angular interval between filter
%                              orientations and the standard deviation of
%                              the angular Gaussian function used to
%                              construct filters in the freq. plane.
%
% Note regarding the specification of norient: In the default case it is assumed
% that the angles of the filters are evenly spaced at intervals of pi/norient
% around the frequency plane.  If you want to visualize filters at a specific
% set of orientations that are not necessarily evenly spaced you can set the
% orientations by passing a CELL array of orientations as the argument to
% norient. In this case the value supplied for dThetaOnSigma will be used as
% thetaSigma - the angular standard deviation of the filters.  Yes, this is
% an ugly abuse of the argument list, but there it is!
% Example:
% View filters over 3 scales with orientations of -0.3 and +0.3 radians,
% minWaveLength of 6, mult of 2, sigmaOnf of 0.65 and thetaSigma of 0.4 
%   plotgaborfilters2(200, 3, {-.3 .3}, 6, 2, 0.65, 0.4);
%
% Returns:
%    Ffilter - a 2D cell array of filters defined in the frequency domain.
%    Efilter - a 2D cell array of even filters defined in the spatial domain.
%    Ofilter - a 2D cell array of odd filters defined in the spatial domain.
%
%    Ffilter{s,o} = filter for scale s and orientation o.
%    The even and odd filters in the spatial domain for scale s,
%    orientation o, are obtained using.              
%
%    Efilter = ifftshift(real(ifft2(fftshift(filter{s,o}))));
%    Ofilter = ifftshift(imag(ifft2(fftshift(filter{s,o}))));
%
% Plots:
%    Figure 1         -  Sum of the filters in the frequency domain
%    Figure 2         -  Cross sections of Figure 1
%    Figures 3 and 4  -  Surface and intensity plots of filters in the
%                        spatial domain at the smallest and largest
%                        scales respectively.
%
% See also: GABORCONVOLVE, PHASECONG

% Copyright (c) 2001-2008 Peter Kovesi
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

% May 2001      - Original version.
% February 2005 - Cleaned up.
% August   2005 - Ffilter,Efilter and Ofilter corrected to return with scale
%                 varying as the first index in the cell arrays.
% July 2008     - Allow specific filter orientations to be specified in
%                 norient via a cell array.

function [Ffilter, Efilter, Ofilter, filtersum] = ...
	plotgaborfilters(sze, nscale, norient, minWaveLength, mult, ...
				   sigmaOnf, dThetaOnSigma) 

    rows = sze; cols = sze;

    
    if iscell(norient)   % Filter orientations and spread have been specified
                         % explicitly
        filterOrient = cell2mat(norient);
        thetaSigma = dThetaOnSigma;  % Use dThetaOnSigma directly as thetaSigma 
        norient = length(filterOrient);
	
    else                 % Usual setup with filters evenly oriented
	filterOrient = [0 : pi/norient : pi-pi/norient];
	
	% Calculate the standard deviation of the angular Gaussian function
	% used to construct filters in the frequency plane.     
	thetaSigma = pi/norient/dThetaOnSigma;
    end
    
    % Double up all the filter orientations by adding another set offset by
    % pi.  This allows us to see the overall orientation coverage of the
    % filters a bit more easily.
    filterOrient = [filterOrient filterOrient+pi];  
    
    % Pre-compute some stuff to speed up filter construction
    
    % Set up X and Y matrices with ranges normalised to +/- 0.5
    % The following code adjusts things appropriately for odd and even values
    % of rows and columns.
    if mod(cols,2)
	xrange = [-(cols-1)/2:(cols-1)/2]/(cols-1);
    else
	xrange = [-cols/2:(cols/2-1)]/cols;	
    end
    
    if mod(rows,2)
	yrange = [-(rows-1)/2:(rows-1)/2]/(rows-1);
    else
	yrange = [-rows/2:(rows/2-1)]/rows;	
    end
    
    [x,y] = meshgrid(xrange, yrange);
    
    radius = sqrt(x.^2 + y.^2);       % Normalised radius (frequency) values 0.0 - 0.5

    % Get rid of the 0 radius value in the middle so that taking the log of
    % the radius will not cause trouble.
    radius(fix(rows/2+1),fix(cols/2+1)) = 1; 
    
    theta = atan2(-y,x);              % Matrix values contain polar angle.
				      % (note -ve y is used to give +ve
				      % anti-clockwise angles)
    sintheta = sin(theta);
    costheta = cos(theta);
    clear x; clear y; clear theta;    % save a little memory

    % Define a low-pass filter that is as large as possible, yet falls away to zero
    % at the boundaries.  All log Gabor filters are multiplied by this to ensure
    % that filters are as similar as possible across orientations (Eliminate the
    % extra frequencies at the 'corners' of the FFT)
    lp = fftshift(lowpassfilter([rows,cols],.45,10));   % Radius .4, 'sharpness' 10

    % The main loop...

    filtersum = zeros(rows,cols);

    for o = 1:2*norient,                   % For each orientation.
	angl = filterOrient(o);
	wavelength = minWaveLength;        % Initialize filter wavelength.

	% Compute filter data specific to this orientation
	% For each point in the filter matrix calculate the angular distance from the
	% specified filter orientation.  To overcome the angular wrap-around problem
	% sine difference and cosine difference values are first computed and then
	% the atan2 function is used to determine angular distance.
	
	ds = sintheta * cos(angl) - costheta * sin(angl); % Difference in sine.
	dc = costheta * cos(angl) + sintheta * sin(angl); % Difference in cosine.
	dtheta = abs(atan2(ds,dc));                       % Absolute angular distance.
	spread = exp((-dtheta.^2) / (2 * thetaSigma^2));  % The angular filter component.

	% Alternate spread function
        dtheta = min(dtheta*norient,pi);
        spread = (cos(dtheta)+1)/2;
        
	for s = 1:nscale,                  % For each scale.
	   
	    % Construct the filter - first calculate the radial filter component.
	    fo = 1.0/wavelength;                  % Centre frequency of filter.
	    
	    logGabor = exp((-(log(radius/fo)).^2) / (2 * log(sigmaOnf)^2));  
	    logGabor(round(rows/2+1),round(cols/2+1)) = 0; % Set value at center of the filter
							   % back to zero (undo the radius fudge).
							   
            logGabor = logGabor.*lp;             % Apply low-pass filter 
	    Ffilter{s,o} = logGabor .* spread;   % Multiply by the angular
						 % spread to get the filter.
					       
            filtersum = filtersum + Ffilter{s,o};
						 
	    Efilter{s,o} = ifftshift(real(ifft2(fftshift(Ffilter{s,o}))));
	    Ofilter{s,o} = ifftshift(imag(ifft2(fftshift(Ffilter{s,o}))));
    					  
	    wavelength = wavelength*mult;
	end
    end

    % Plot sum of filters and slices radially and tangentially
    figure(1), clf, show(filtersum,1), title('sum of filters');
    
    figure(2), clf
    subplot(2,1,1), plot(filtersum(round(rows/2+1),:))
    title('radial slice through sum of filters');
    
    ang = [0:pi/32:2*pi];
    r = rows/4;
    tslice = improfile(filtersum,r*cos(ang)+cols/2,r*sin(ang)+rows/2);
    subplot(2,1,2), plot(tslice), axis([0 length(tslice) 0 1.1*max(tslice)]);
    title('tangential slice through sum of filters at f = 0.25');	   

    % Plot Even and Odd filters at the largest and smallest scales
    h = figure(3); clf
    set(h,'name',sprintf('Filters: Wavelenth = %.2f',minWaveLength));
    subplot(3,2,1), surfl(Efilter{1,1}), shading interp, colormap(gray), 
    title('Even Filter');
    subplot(3,2,2), surfl(Ofilter{1,1}), shading interp, colormap(gray)
    title('Odd Filter');
    subplot(3,2,3),imagesc(Efilter{1,1}), axis image, colormap(gray)
    subplot(3,2,4),imagesc(Ofilter{1,1}), axis image, colormap(gray)
    subplot(3,2,5),imagesc(Ffilter{1,1}), axis image, colormap(gray)
    title('Frequency Domain');
    
    h = figure(4); clf
    set(h,'name',sprintf('Filters: Wavelenth = %.2f',minWaveLength*mult^(nscale-1)));
    subplot(3,2,1), surfl(Efilter{nscale,1}), shading interp, colormap(gray)
    title('Even Filter');
    subplot(3,2,2), surfl(Ofilter{nscale,1}), shading interp, colormap(gray)
    title('Odd Filter');
    subplot(3,2,3),imagesc(Efilter{nscale,1}), axis image, colormap(gray)
    subplot(3,2,4),imagesc(Ofilter{nscale,1}), axis image, colormap(gray)
    subplot(3,2,5),imagesc(Ffilter{nscale,1}), axis image, colormap(gray)
    title('Frequency Domain');