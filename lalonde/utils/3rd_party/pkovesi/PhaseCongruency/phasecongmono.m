% PHASECONGMONO - phase congruency of an image using monogenic filters
%
% This code is considerably faster than PHASECONG3 but you may prefer the
% output from PHASECONG3's oriented filters.
%
% There are potentially many arguments, here is the full usage:
%
%   [PC or ft T] =  ...
%                phasecongmono(im, nscale, minWaveLength, mult, ...
%                         sigmaOnf, k, cutOff, g, noiseMethod)
%
% However, apart from the image, all parameters have defaults and the
% usage can be as simple as:
%
%    phaseCong = phasecongmono(im);
% 
% Arguments:
%              Default values      Description
%
%    nscale           5    - Number of wavelet scales, try values 3-6
%    minWaveLength    3    - Wavelength of smallest scale filter.
%    mult             2.1  - Scaling factor between successive filters.
%    sigmaOnf         0.55 - Ratio of the standard deviation of the Gaussian 
%                            describing the log Gabor filter's transfer function 
%                            in the frequency domain to the filter center frequency.
%    k                2.0  - No of standard deviations of the noise energy beyond
%                            the mean at which we set the noise threshold point.
%                            You may want to vary this up to a value of 10 or
%                            20 for noisy images 
%    noiseMethod      -1   - Parameter specifies method used to determine
%                            noise statistics. 
%                              -1 use median of smallest scale filter responses
%                              -2 use mode of smallest scale filter responses
%                               0+ use noiseMethod value as the fixed noise threshold 
%                            A value of 0 will turn off all noise compensation.
%    cutOff           0.5  - The fractional measure of frequency spread
%                            below which phase congruency values get penalized.
%    g                10   - Controls the sharpness of the transition in
%                            the sigmoid function used to weight phase
%                            congruency for frequency spread.                        
%
% Returned values:
%    PC         - Phase congruency indicating edge significance
%    or         - Orientation image in integer degrees 0-180,
%                 positive anticlockwise.
%                 0 corresponds to a vertical edge, 90 is horizontal.
%    ft         - Local weighted mean phase angle at every point in the
%                 image.  A value of pi/2 corresponds to a bright line, 0
%                 corresponds to a step and -pi/2 is a dark line.
%    T          - Calculated noise threshold (can be useful for
%                 diagnosing noise characteristics of images).  Once you know
%                 this you can then specify fixed thresholds and save some
%                 computation time.
%
% Notes on specifying parameters:  
%
% The parameters can be specified as a full list eg.
%  >> PC = phasecongmono(im, 5, 3, 2.5, 0.55, 2.0);
%
% or as a partial list with unspecified parameters taking on default values
%  >> PC = phasecongmono(im, 5, 3);
%
% or as a partial list of parameters followed by some parameters specified via a
% keyword-value pair, remaining parameters are set to defaults, for example:
%  >> PC = phasecongmono(im, 5, 3, 'k', 2.5);
% 
% The convolutions are done via the FFT.  Many of the parameters relate to the
% specification of the filters in the frequency plane.  The values do not seem
% to be very critical and the defaults are usually fine.  You may want to
% experiment with the values of 'nscales' and 'k', the noise compensation factor.
%
% Notes on filter settings to obtain even coverage of the spectrum
% sigmaOnf       .85   mult 1.3
% sigmaOnf       .75   mult 1.6     (filter bandwidth ~1 octave)
% sigmaOnf       .65   mult 2.1  
% sigmaOnf       .55   mult 3       (filter bandwidth ~2 octaves)
%
% See Also:  PHASECONG, PHASECONG2, PHASECONG3, PHASESYMMONO, GABORCONVOLVE, PLOTGABORFILTERS

% References:
%
%     Peter Kovesi, "Image Features From Phase Congruency". Videre: A
%     Journal of Computer Vision Research. MIT Press. Volume 1, Number 3,
%     Summer 1999 http://mitpress.mit.edu/e-journals/Videre/001/v13.html
%
%     Michael Felsberg and Gerald Sommer, "A New Extension of Linear Signal
%     Processing for Estimating Local Properties and Detecting Features". DAGM
%     Symposium 2000, Kiel
%
%     Michael Felsberg and Gerald Sommer. "The Monogenic Signal" IEEE
%     Transactions on Signal Processing, 49(12):3136-3144, December 2001
%
%     Peter Kovesi, "Phase Congruency Detects Corners and Edges". Proceedings
%     DICTA 2003, Sydney Dec 10-12


% August 2008    Initial version developed from phasesymmono and phasecong2
%                where local phase information is calculated via Monogenic
%                filters. Simplification of noise compensation to speedup
%                execution. Options to calculate noise statistics via median
%                or mode of smallest filter response.  
% April 2009     Return of T for 'instrumentation' of noise
%                detection/compensation. Option to use a fixed threshold.
%                Frequency width measure slightly improved.
% June 2009      20% Speed improvement through calculating phase deviation via
%                acos() rather than computing cos(theta)-|sin(theta)| via dot
%                and cross products.  Also much smaller memory footprint

% Copyright (c) 1996-2009 Peter Kovesi
% School of Computer Science & Software Engineering
% The University of Western Australia
% pk @ csse uwa edu au
% http://www.csse.uwa.edu.au/
% 
% Permission is hereby  granted, free of charge, to any  person obtaining a copy
% of this software and associated  documentation files (the "Software"), to deal
% in the Software without restriction, subject to the following conditions:
% 
% The above copyright notice and this permission notice shall be included in all
% copies or substantial portions of the Software.
% 
% The software is provided "as is", without warranty of any kind.

function [PC, or, ft, T] = phasecongmono(varargin)

    % Get arguments and/or default values    
    [im, nscale, minWaveLength, mult, sigmaOnf, k, ...
     noiseMethod, cutOff, g] = checkargs(varargin(:));  

    epsilon         = .0001;            % Used to prevent division by zero.

    [rows,cols] = size(im);
    IM = fft2(im);                      % Fourier transform of image

    sumAn  = zeros(rows,cols);          % Matrix for accumulating filter response
                                        % amplitude values.
    sumf   = zeros(rows,cols);                                  
    sumh1  = zeros(rows,cols);                                      
    sumh2  = zeros(rows,cols);                                          

    % Pre-compute some stuff to speed up filter construction
    %
    % Set up u1 and u2 matrices with ranges normalised to +/- 0.5
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
    
    [u1,u2] = meshgrid(xrange, yrange);
    
    u1 = ifftshift(u1);   % Quadrant shift to put 0 frequency at the corners
    u2 = ifftshift(u2);
    
    % Compute frequency values as a radius from centre (but quadrant shifted)
    radius = sqrt(u1.^2 + u2.^2);   
    
    % Get rid of the 0 radius value in the middle (at top left corner after
    % fftshifting) so that taking the log of the radius, or dividing by the
    % radius, will not cause trouble.
    radius(1,1) = 1;
    
    % Construct the monogenic filters in the frequency domain.  The two
    % filters would normally be constructed as follows
    %    H1 = i*u1./radius; 
    %    H2 = i*u2./radius;
    % However the two filters can be packed together as a complex valued
    % matrix, one in the real part and one in the imaginary part.  Do this by
    % multiplying H2 by i and then adding it to H1 (note the subtraction
    % because i*i = -1).  When the convolution is performed via the fft the
    % real part of the result will correspond to the convolution with H1 and
    % the imaginary part with H2.  This allows the two convolutions to be
    % done as one in the frequency domain, saving time and memory.
    H = (1i*u1 - u2)./radius;
    
    % The two monogenic filters H1 and H2 are not selective in terms of the
    % magnitudes of the frequencies.  The code below generates bandpass
    % log-Gabor filters which are point-wise multiplied by IM to produce
    % different bandpass versions of the image before being convolved with H1
    % and H2
    
    % First construct a low-pass filter that is as large as possible, yet falls
    % away to zero at the boundaries.  All filters are multiplied by
    % this to ensure no extra frequencies at the 'corners' of the FFT are
    % incorporated as this can upset the normalisation process when
    % calculating phase congruency
    lp = lowpassfilter([rows,cols],.4,10);    % Radius .4, 'sharpness' 10

    for s = 1:nscale
        wavelength = minWaveLength*mult^(s-1);
        fo = 1.0/wavelength;                  % Centre frequency of filter.
        logGabor = exp((-(log(radius/fo)).^2) / (2 * log(sigmaOnf)^2));  
        logGabor = logGabor.*lp;              % Apply low-pass filter
        logGabor(1,1) = 0;                    % Set the value at the 0 frequency point of the filter
                                              % back to zero (undo the radius fudge).

        IMF = IM.*logGabor;       % Bandpassed image in the frequency domain.
        f = real(ifft2(IMF));     % Bandpassed image in spatial domain.

        h = ifft2(IMF.*H);        % Bandpassed monogenic filtering, real part of h contains
                                  % convolution result with h1, imaginary part
                                  % contains convolution result with h2.
        h1 = real(h); 
        h2 = imag(h);                                  
        An = sqrt(f.^2 + h1.^2 + h2.^2); % Amplitude of this scale component.
        sumAn = sumAn + An;              % Sum of component amplitudes over scale.
        sumf  = sumf  + f;
        sumh1 = sumh1 + h1;
        sumh2 = sumh2 + h2;  
        
        % At the smallest scale estimate noise characteristics from the
        % distribution of the filter amplitude responses stored in sumAn. 
        % tau is the Rayleigh parameter that is used to describe the
        % distribution.
        if s == 1 
            if noiseMethod == -1     % Use median to estimate noise statistics
                tau = median(sumAn(:))/sqrt(log(4));   
            elseif noiseMethod == -2 % Use mode to estimate noise statistics
                tau = rayleighmode(sumAn(:));
            end
            maxAn = An;
        else
            % Record maximum amplitude of components across scales.  This is needed
            % to determine the frequency spread weighting.
            maxAn = max(maxAn,An);   
        end
                                    
    end   % For each scale

    % Form weighting that penalizes frequency distributions that are
    % particularly narrow.  Calculate fractional 'width' of the frequencies
    % present by taking the sum of the filter response amplitudes and dividing
    % by the maximum component amplitude at each point on the image.  If
    % there is only one non-zero component width takes on a value of 0, if
    % all components are equal width is 1.
    width = (sumAn./(maxAn + epsilon) - 1) / (nscale-1);    
    
    % Now calculate the sigmoidal weighting function.
    weight = 1.0 ./ (1 + exp( (cutOff - width)*g)); 
    
    % Automatically determine noise threshold
    %
    % Assuming the noise is Gaussian the response of the filters to noise will
    % form Rayleigh distribution.  We use the filter responses at the smallest
    % scale as a guide to the underlying noise level because the smallest scale
    % filters spend most of their time responding to noise, and only
    % occasionally responding to features. Either the median, or the mode, of
    % the distribution of filter responses can be used as a robust statistic to
    % estimate the distribution mean and standard deviation as these are related
    % to the median or mode by fixed constants.  The response of the larger
    % scale filters to noise can then be estimated from the smallest scale
    % filter response according to their relative bandwidths.
    %
    % This code assumes that the expected reponse to noise on the phase
    % congruency calculation is simply the sum of the expected noise responses
    % of each of the filters.  This is a simplistic overestimate, however these
    % two quantities should be related by some constant that will depend on the
    % filter bank being used.  Appropriate tuning of the parameter 'k' will
    % allow you to produce the desired output. (though the value of k seems to
    % be not at all critical)
    
    if noiseMethod >= 0     % We are using a fixed noise threshold
        T = noiseMethod;    % use supplied noiseMethod value as the threshold
    else
        % Estimate the effect of noise on the sum of the filter responses as
        % the sum of estimated individual responses (this is a simplistic
        % overestimate). As the estimated noise response at succesive scales
        % is scaled inversely proportional to bandwidth we have a simple
        % geometric sum.
        totalTau = tau * (1 - (1/mult)^nscale)/(1-(1/mult));
        
        % Calculate mean and std dev from tau using fixed relationship
        % between these parameters and tau. See
        % http://mathworld.wolfram.com/RayleighDistribution.html
        EstNoiseEnergyMean = totalTau*sqrt(pi/2);        % Expected mean and std
        EstNoiseEnergySigma = totalTau*sqrt((4-pi)/2);   % values of noise energy
        
        T =  EstNoiseEnergyMean + k*EstNoiseEnergySigma; % Noise threshold
    end

    %------ Final computation of key quantities -------
    
    or = atan(-sumh2./sumh1);   % Orientation - this varies +/- pi/2
    or(or<0) = or(or<0)+pi;     % Add pi to -ve orientation value so that all
                                % orientation values now range 0 - pi
    or = fix(or/pi*180);        % Quantize to 0 - 180 degrees (for NONMAXSUP)
                                      
    ft = atan2(sumf,sqrt(sumh1.^2+sumh2.^2));  % Feature type - a phase angle
                                               % -pi/2 to pi/2.

    energy =  sqrt(sumf.^2 + sumh1.^2 + sumh2.^2) + epsilon;  % Overall energy

    % Compute phase congruency.  The original measure, 
    % PC = energy/sumAn 
    % is proportional to the weighted cos(phasedeviation).  This is not very
    % localised so this was modified to
    % PC = cos(phasedeviation) - |sin(phasedeviation)| 
    % (Note this was actually calculated via dot and cross products.)  This measure
    % approximates 
    % PC = 1 - phasedeviation.  
    % However, rather than use dot and cross products it is simpler and more
    % efficient to simply use acos(energy/sumAn) to obtain the weighted phase
    % deviation directly.  Note, in the expression below the noise threshold is
    % not subtracted from energy immediately as this would interfere with the
    % phase deviation computation.  Instead it is subtracted after this
    % computation, hence the separate division by sumAn.  Finally this result is
    % floored at 0, and then weighted for frequency spread.
    
    PC = weight.*max(1 - acos(energy./(sumAn + epsilon)) -  T./(sumAn+epsilon), 0); 
    
%------------------------------------------------------------------
% CHECKARGS
%
% Function to process the arguments that have been supplied, assign
% default values as needed and perform basic checks.
    
function [im, nscale, minWaveLength, mult, sigmaOnf, ...
          k,  noiseMethod, cutOff, g] = checkargs(arg)

    nargs = length(arg);
    
    if nargs < 1
        error('No image supplied as an argument');
    end    
    
    % Set up default values for all arguments and then overwrite them
    % with with any new values that may be supplied
    im              = [];
    nscale          = 5;     % Number of wavelet scales.    
    minWaveLength   = 3;     % Wavelength of smallest scale filter.    
    mult            = 2.1;   % Scaling factor between successive filters.    
    sigmaOnf        = 0.65;  % Ratio of the standard deviation of the
                             % Gaussian describing the log Gabor filter's
                             % transfer function in the frequency domain
                             % to the filter center frequency.    
    k               = 2.0;   % No of standard deviations of the noise
                             % energy beyond the mean at which we set the
                             % noise threshold point. 

    noiseMethod     = -1;    % Use the median response of smallest scale
                             % filter to estimate noise statistics
    cutOff          = 0.5;
    g               = 10;
    
    % Allowed argument reading states
    allnumeric   = 1;       % Numeric argument values in predefined order
    keywordvalue = 2;       % Arguments in the form of string keyword
                            % followed by numeric value
    readstate = allnumeric; % Start in the allnumeric state
    
    if readstate == allnumeric
        for n = 1:nargs
            if isa(arg{n},'char')
                readstate = keywordvalue;
                break;
            else
                if     n == 1, im            = arg{n}; 
                elseif n == 2, nscale        = arg{n};              
                elseif n == 3, minWaveLength = arg{n};
                elseif n == 4, mult          = arg{n};
                elseif n == 5, sigmaOnf      = arg{n};
                elseif n == 6, k             = arg{n};              
                elseif n == 7, noiseMethod   = arg{n};              
                elseif n == 8, cutOff        = arg{n};              
                elseif n == 9, g            = arg{n};                               
                end
            end
        end
    end

    % Code to handle parameter name - value pairs
    if readstate == keywordvalue
        while n < nargs
                   
            if ~isa(arg{n},'char') || ~isa(arg{n+1}, 'double')
                error('There should be a parameter name - value pair');
            end
            
            if     strncmpi(arg{n},'im'      ,2),      im =            arg{n+1};
            elseif strncmpi(arg{n},'nscale'  ,2),      nscale =        arg{n+1};
            elseif strncmpi(arg{n},'minWaveLength',2), minWaveLength = arg{n+1};
            elseif strncmpi(arg{n},'mult'    ,2),      mult =          arg{n+1};
            elseif strncmpi(arg{n},'sigmaOnf',2),      sigmaOnf =      arg{n+1};
            elseif strncmpi(arg{n},'k'       ,1),      k =             arg{n+1};
            elseif strncmpi(arg{n},'noisemethod',3),   noiseMethod =   arg{n+1}; 
            elseif strncmpi(arg{n},'cutOff'    ,2),    cutOff =        arg{n+1}; 
            elseif strncmpi(arg{n},'g'       ,1),      g =             arg{n+1};                    
            else   error('Unrecognised parameter name');
            end

            n = n+2;
            if n == nargs
                error('Unmatched parameter name - value pair');
            end
        end
    end
    
    if isempty(im)
        error('No image argument supplied');
    end

    if ~isa(im, 'double')
        im = double(im);
    end
    
    if nscale < 1
        error('nscale must be an integer >= 1');
    end
    
    if minWaveLength < 2
        error('It makes little sense to have a wavelength < 2');
    end          
        
    
%-------------------------------------------------------------------------
% RAYLEIGHMODE
%
% Computes mode of a vector/matrix of data that is assumed to come from a
% Rayleigh distribution.
%
% Usage:  rmode = rayleighmode(data, nbins)
%
% Arguments:  data  - data assumed to come from a Rayleigh distribution
%             nbins - Optional number of bins to use when forming histogram
%                     of the data to determine the mode.
%
% Mode is computed by forming a histogram of the data over 50 bins and then
% finding the maximum value in the histogram.  Mean and standard deviation
% can then be calculated from the mode as they are related by fixed
% constants.
%
% mean = mode * sqrt(pi/2)
% std dev = mode * sqrt((4-pi)/2)
% 
% See
% http://mathworld.wolfram.com/RayleighDistribution.html
% http://en.wikipedia.org/wiki/Rayleigh_distribution
%

function rmode = rayleighmode(data, nbins)
    
    if nargin == 1
        nbins = 50;  % Default number of histogram bins to use
    end

    mx = max(data(:));
    edges = 0:mx/nbins:mx;
    n = histc(data(:),edges); 
    [dum,ind] = max(n); % Find maximum and index of maximum in histogram 

    rmode = (edges(ind)+edges(ind+1))/2;

