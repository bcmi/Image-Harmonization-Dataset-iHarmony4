% SHAPELETSURF - reconstructs surface from surface normals using shapelets
%
% Function reconstructs an estimate of a surface from its surface normals by
% correlating the surface normals with that those of a bank of shapelet
% basis functions. The correlation results are summed to produce the
% reconstruction.  The sumation of shapelet basis functions results in an
% implicit integration of the surface while enforcing surface continuity.
%
% Note that the reconstruction is only valid up to a scale factor. However
% the reconstruction process is very robust to noise and to missing data
% values.  Reconstructions (up to positive/negative shape ambiguity) are
% possible where there is an ambiguity of pi in tilt values.  Low quality
% reconstructions are also possible with just slant, or just tilt data
% alone.
% 
%
% Usage:
%  recsurf = shapletsurf(slant, tilt, nscales, minradius, mult, opt)
%                                       6        1        2
% Arguments:
%            slant     - 2D array of surface slant values across image.
%            tilt      - 2D array of surface tilt values.
%            nscales   - number of shapelet scales to use.
%            minsigma  - sigma of smallest scale Gaussian shapelet.
%            mult      - scaling factor between successive shapelets.
%
%   opt can be the string:
%           'slanttilt' - reconstruct using both slant and tilt (default).
%           'tiltamb'   - reconstruct assuming tilt ambiguity of pi.
%           'slant'     - reconstruct with slant only.
%           'tilt'      - reconstruct with tilt only.
%  
% Returns:
%           recsurf     - reconstructed surface.
%
% Remember when viewing the surface you should use 
%   >> axis ij 
% So that the surface corresponds to the image slant and tilt axes
%
% References:
%
% Peter Kovesi, "Surface Normals to Surfaces via Shapelets"
% Proceedings Australia-Japan Advanced Workshop on Computer Vision
% Adelaide, 9-11 September 2003
%
% Peter Kovesi, "Shapelets Correlated with Surface Normals Produce
% Surfaces". Technical Report 03-003, October 2003.
% http://www.csse.uwa.edu.au/~pk/research/pkpapers/shapelets-03-002.pdf

% Copyright (c) 2003-2005 Peter Kovesi
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

% July      2003 - Original version.
% September 2003 - Correction to reconstruction with tilt ambiguity.
% October   2003 - Changed to use Gaussian shapelets.
% February  2004 - Convolutions done via fft for speed.
% March     2004 - Padding of slant and tilt data to accommodate large filters.

function recsurf = shapeletsurf(varargin)
    
    [slant, tilt, nscales, minsigma, mult, opt] = checkargs(varargin(:));
    
    if strcmp(opt,'tiltamb')  % If we have an ambiguity of pi in the tilt 
        tilt = tilt*2;        % work with doubled angles.
    end

    [rows,cols] = size(slant);

    % Check size of largest filter and, if necessary, pad slant and tilt
    % data with zeros so that the largest filter can be accommodated.
    % If this is not done wraparound in the convolutions via the FFT produce
    % artifacts in the reconstruction.
    % Treat max size as +- 3 sigma
    maxsize = ceil(6*minsigma*mult^(nscales-1)); 
    paddingapplied = 0;

    if rows < maxsize | cols < maxsize  % padding needed
      paddingapplied = 1;
      rowpad = max(0,round(maxsize-rows));
      colpad = max(0,round(maxsize-cols));
      fprintf('Warning: To accommodate the largest filter size the\n');
      fprintf('slant and tilt data is being padded from %dx%d to %dx%d \n', ...
                      rows,cols, rows+rowpad, cols+colpad);

      slant = [slant zeros(rows, colpad)
               zeros(rowpad, cols+colpad)];
      tilt  = [tilt  zeros(rows, colpad)
               zeros(rowpad, cols+colpad)];
      origrows = rows; origcols = cols;    % Remember original size.
      [rows,cols] = size(slant);           % Update current size.
    end
    
    % Precompute some values for speed of execution.  Note that because we
    % generally want to use shapelets at quite large scales relative to the
    % size of the image correlations are done in the frequency domain for
    % speed. (Note that in the code below the conjugate of the fft is used
    % because we want the correlation, not convolution.)
    surfgrad = tan(slant);  SURFGRAD= fft2(surfgrad);
    sintilt = sin(tilt);    SINTILT = fft2(sintilt);
    costilt = cos(tilt);    COSTILT = fft2(costilt);
    SURFGRADSINTILT = fft2(surfgrad.*sintilt);  
    SURFGRADCOSTILT = fft2(surfgrad.*costilt);
    
    for s = 1:nscales
%        fprintf('scale %d out of %d\r',s,nscales);
        
        % Use a Gaussian filter shape as the shapelet basis function
        % as the phase distortion in the reconstruction should be zero.
        f = gaussianf(minsigma*mult^(s-1), rows, cols);

        [fdx,fdy] = gradient(f);                  % filter gradients
        [fslant,ftilt] = grad2slanttilt(fdx,fdy); % filter slants and tilts
        
        if strcmp(opt,'tiltamb')
            ftilt = ftilt*2;
        end    
        
        % Now perform the correlations (via the fft) as required depending
        % on the options selected. 
        sinftilt = sin(ftilt);   
        cosftilt = cos(ftilt);   
        filtgrad = tan(fslant);   
        
        filtgradsintilt = filtgrad.*sinftilt;
        filtgradcostilt = filtgrad.*cosftilt;
        
        if strcmp(opt,'slanttilt')     % both slant and tilt data available
            FILTGRADSINTILT = fft2(filtgrad.*sinftilt);
            FILTGRADCOSTILT = fft2(filtgrad.*cosftilt);
            fim{s} = real(ifft2(conj(FILTGRADCOSTILT) .* SURFGRADCOSTILT)) + ...
                     real(ifft2(conj(FILTGRADSINTILT) .* SURFGRADSINTILT));
            
        elseif strcmp(opt,'tiltamb')   % assume tilt ambiguity of pi
            FILTGRADSINTILT = fft2(filtgrad.*sinftilt);
            FILTGRADCOSTILT = fft2(filtgrad.*cosftilt);
            FILTGRAD = fft2(filtgrad);
            fim{s} = (real(ifft2(conj(FILTGRADCOSTILT) .* SURFGRADCOSTILT)) + ...
                      real(ifft2(conj(FILTGRADSINTILT) .* SURFGRADSINTILT)) + ...
                      real(ifft2(conj(FILTGRAD) .* SURFGRAD)))/2;    
            
        elseif strcmp(opt,'tilt');     % tilt only reconstruction
            SINFTILT = fft2(sinftilt);
            COSFTILT = fft2(cosftilt);
            fim{s} = real(ifft2(conj(COSFTILT) .* COSTILT)) + ...
                     real(ifft2(conj(SINFTILT) .* SINTILT));      
            
        elseif strcmp(opt,'slant');    % just use slant and ignore tilt
            FILTGRAD = fft2(filtgrad);
            fim{s} = real(ifft2(conj(FILTGRAD) .* SURFGRAD));  
        end
        
    end
%    fprintf('\n');
    
    % Reconstruct by adding filtered outputs
    
    recsurf = zeros(size(slant));
    for s = 1:nscales
        recsurf = recsurf + fim{s};
    end


    if paddingapplied  % result is padded - extract the bit we want.
	recsurf = recsurf(1:origrows, 1:origcols);
    end
    
%-------------------------------------------------------------------------
% Function to generate a Gaussian filter for use as a shapelet.
% Usage:
%      f = gaussian(sigma, rows, cols)
%
% Arguments:
%      sigma      - standard deviation of Gaussian
%      rows, cols - size of filter to create

function f = gaussianf(sigma, rows, cols)

    [x,y] = meshgrid( [1:cols]-(fix(cols/2)+1), [1:rows]-(fix(rows/2)+1));
    r = sqrt(x.^2 + y.^2);
    f = fftshift(exp(-r.^2/(2*sigma^2)));

%--------------------------------------------------------------------------
% Function to check argument values and set defaults

function [slant, tilt, nscales, minradius, mult, opt] = checkargs(arg);
    
    if length(arg)<5 
        error('too few arguments');
    elseif length(arg)>6
        error('too many arguments');
    end
    
    slant     = arg{1};
    tilt      = arg{2};
    nscales   = arg{3};
    minradius = arg{4};
    mult      = arg{5};
    
    if length(arg) == 5
        opt = 'slanttilt'; % Default is to assume both slant and tilt values
                           % are valid.
    else
        opt = arg{6};
    end
    
    if ~all(size(slant)==size(tilt))
        error('slant and tilt matrices must match');
    end
    
    if nscales < 1
        error('number of scales must be 1 or greater');
    end
    
    if minradius < .1
        error('minimum radius of shapelet must be greater than .1');
    end
    
    if mult < 1
        error('scaling factor between successive filters should be greater than 1');
    end
    


