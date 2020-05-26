% PHASECONG2 - Computes edge and corner phase congruency in an image.
%
% This function calculates the PC_2 measure of phase congruency.  
% This function supersedes PHASECONG
%
% There are potentially many arguments, here is the full usage:
%
%   [M m or ft pc EO] = phasecong2(im, nscale, norient, minWaveLength, ...
%                         mult, sigmaOnf, dThetaOnSigma, k, cutOff, g)
%
% However, apart from the image, all parameters have defaults and the
% usage can be as simple as:
%
%    M = phasecong2(im);
% 
% Arguments:
%              Default values      Description
%
%    nscale           4    - Number of wavelet scales, try values 3-6
%    norient          6    - Number of filter orientations.
%    minWaveLength    3    - Wavelength of smallest scale filter.
%    mult             2.1  - Scaling factor between successive filters.
%    sigmaOnf         0.55 - Ratio of the standard deviation of the Gaussian 
%                            describing the log Gabor filter's transfer function 
%                            in the frequency domain to the filter center frequency.
%    dThetaOnSigma    1.2  - Ratio of angular interval between filter orientations
%                            and the standard deviation of the angular Gaussian
%                            function used to construct filters in the
%                            freq. plane.
%    k                2.0  - No of standard deviations of the noise energy beyond
%                            the mean at which we set the noise threshold point.
%                            You may want to vary this up to a value of 10 or
%                            20 for noisy images 
%    cutOff           0.5  - The fractional measure of frequency spread
%                            below which phase congruency values get penalized.
%    g                10   - Controls the sharpness of the transition in
%                            the sigmoid function used to weight phase
%                            congruency for frequency spread.                        
%
% Returned values:
%    M          - Maximum moment of phase congruency covariance.
%                 This is used as a indicator of edge strength.
%    m          - Minimum moment of phase congruency covariance.
%                 This is used as a indicator of corner strength.
%    or         - Orientation image in integer degrees 0-180,
%                 positive anticlockwise.
%                 0 corresponds to a vertical edge, 90 is horizontal.
%    ft         - *Not correctly implemented at this stage*
%                 A complex valued image giving the weighted mean 
%                 phase angle at every point in the image for each
%                 orientation. 
%    pc         - Cell array of phase congruency images (values between 0 and 1)   
%                 for each orientation
%    EO         - A 2D cell array of complex valued convolution results
%
%   EO{s,o} = convolution result for scale s and orientation o.  The real part
%   is the result of convolving with the even symmetric filter, the imaginary
%   part is the result from convolution with the odd symmetric filter.
%
%   Hence:
%       abs(EO{s,o}) returns the magnitude of the convolution over the
%       image at scale s and orientation o.
%       angle(EO{s,o}) returns the phase angles.
%   
% Notes on specifying parameters:  
%
% The parameters can be specified as a full list eg.
%  >> [M m or ft pc EO] = phasecong2(im, 5, 6, 3, 2.5, 0.55, 1.2, 2.0, 0.4, 10);
%
% or as a partial list with unspecified parameters taking on default values
%  >> [M m or ft pc EO] = phasecong2(im, 5, 6, 3);
%
% or as a partial list of parameters followed by some parameters specified via a
% keyword-value pair, remaining parameters are set to defaults, for example:
%  >> [M m or ft pc EO] = phasecong2(im, 5, 6, 3, 'cutOff', 0.3, 'k', 2.5);
% 
% The convolutions are done via the FFT.  Many of the parameters relate to the
% specification of the filters in the frequency plane.  The values do not seem
% to be very critical and the defaults are usually fine.  You may want to
% experiment with the values of 'nscales' and 'k', the noise compensation factor.
%
% Notes on filter settings to obtain even coverage of the spectrum
% dthetaOnSigma 1.2    norient 6
% sigmaOnf       .85   mult 1.3
% sigmaOnf       .75   mult 1.6     (filter bandwidth ~1 octave)
% sigmaOnf       .65   mult 2.1  
% sigmaOnf       .55   mult 3       (filter bandwidth ~2 octaves)
%
% For maximum speed the input image should have dimensions that correspond to
% powers of 2, but the code will operate on images of arbitrary size.
%
% See Also:  PHASECONG, PHASESYM, GABORCONVOLVE, PLOTGABORFILTERS

% References:
%
%     Peter Kovesi, "Image Features From Phase Congruency". Videre: A
%     Journal of Computer Vision Research. MIT Press. Volume 1, Number 3,
%     Summer 1999 http://mitpress.mit.edu/e-journals/Videre/001/v13.html
%
%     Peter Kovesi, "Phase Congruency Detects Corners and
%     Edges". Proceedings DICTA 2003, Sydney Dec 10-12

% April 1996     Original Version written 
% August 1998    Noise compensation corrected. 
% October 1998   Noise compensation corrected.   - Again!!!
% September 1999 Modified to operate on non-square images of arbitrary size. 
% May 2001       Modified to return feature type image. 
% July 2003      Altered to calculate 'corner' points. 
% October 2003   Speed improvements and refinements. 
% July 2005      Better argument handling, changed order of return values
% August 2005    Made Octave compatible
% May 2006       Bug in checkargs fixed
% Jan 2007       Bug in setting radius to 0 for odd sized images fixed.
% April 2009     Scaling of covariance values fixed. (Negligible change to results) 

% Copyright (c) 1996-2009 Peter Kovesi
% School of Computer Science & Software Engineering
% The University of Western Australia
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

function [M, m, or, featType, PC, EO]=phasecong2(varargin)
    
% Get arguments and/or default values    
[im, nscale, norient, minWaveLength, mult, sigmaOnf, ...
                  dThetaOnSigma,k, cutOff, g] = checkargs(varargin(:));     

Octave = exist('OCTAVE_VERSION') ~= 0;  % Are we running under Octave?

epsilon         = .0001;                % Used to prevent division by zero.

thetaSigma = pi/norient/dThetaOnSigma;  % Calculate the standard deviation of the
                                        % angular Gaussian function used to
                                        % construct filters in the freq. plane.

[rows,cols] = size(im);
imagefft = fft2(im);              % Fourier transform of image

zero = zeros(rows,cols);
totalEnergy = zero;               % Total weighted phase congruency values (energy).
totalSumAn  = zero;               % Total filter response amplitude values.
orientation = zero;               % Matrix storing orientation with greatest
                                  % energy for each pixel.
EO = cell(nscale, norient);       % Array of convolution results.                                 
covx2 = zero;                     % Matrices for covariance data
covy2 = zero;
covxy = zero;

estMeanE2n = [];
ifftFilterArray = cell(1,nscale); % Array of inverse FFTs of filters

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

radius = sqrt(x.^2 + y.^2);       % Matrix values contain *normalised* radius from centre.
theta = atan2(-y,x);              % Matrix values contain polar angle.
                                  % (note -ve y is used to give +ve
                                  % anti-clockwise angles)
                                  
radius = ifftshift(radius);       % Quadrant shift radius and theta so that filters
theta  = ifftshift(theta);        % are constructed with 0 frequency at the corners.
radius(1,1) = 1;                  % Get rid of the 0 radius value at the 0
                                  % frequency point (now at top-left corner)
                                  % so that taking the log of the radius will 
                                  % not cause trouble.

sintheta = sin(theta);
costheta = cos(theta);
clear x; clear y; clear theta;    % save a little memory

% Filters are constructed in terms of two components.
% 1) The radial component, which controls the frequency band that the filter
%    responds to
% 2) The angular component, which controls the orientation that the filter
%    responds to.
% The two components are multiplied together to construct the overall filter.

% Construct the radial filter components...

% First construct a low-pass filter that is as large as possible, yet falls
% away to zero at the boundaries.  All log Gabor filters are multiplied by
% this to ensure no extra frequencies at the 'corners' of the FFT are
% incorporated as this seems to upset the normalisation process when
% calculating phase congrunecy.
lp = lowpassfilter([rows,cols],.45,15);   % Radius .45, 'sharpness' 15

logGabor = cell(1,nscale);

for s = 1:nscale
    wavelength = minWaveLength*mult^(s-1);
    fo = 1.0/wavelength;                  % Centre frequency of filter.
    logGabor{s} = exp((-(log(radius/fo)).^2) / (2 * log(sigmaOnf)^2));  
    logGabor{s} = logGabor{s}.*lp;        % Apply low-pass filter
    logGabor{s}(1,1) = 0;                 % Set the value at the 0 frequency point of the filter
                                          % back to zero (undo the radius fudge).
end

% Then construct the angular filter components...

spread = cell(1,norient);

for o = 1:norient
  angl = (o-1)*pi/norient;           % Filter angle.

  % For each point in the filter matrix calculate the angular distance from
  % the specified filter orientation.  To overcome the angular wrap-around
  % problem sine difference and cosine difference values are first computed
  % and then the atan2 function is used to determine angular distance.

  ds = sintheta * cos(angl) - costheta * sin(angl);    % Difference in sine.
  dc = costheta * cos(angl) + sintheta * sin(angl);    % Difference in cosine.
  dtheta = abs(atan2(ds,dc));                          % Absolute angular distance.
  spread{o} = exp((-dtheta.^2) / (2 * thetaSigma^2));  % Calculate the
                                                       % angular filter component.
end

% The main loop...

for o = 1:norient                    % For each orientation.
%  fprintf('Processing orientation %d\r',o);
%  if Octave fflush(1); end

  angl = (o-1)*pi/norient;           % Filter angle.
  sumE_ThisOrient   = zero;          % Initialize accumulator matrices.
  sumO_ThisOrient   = zero;       
  sumAn_ThisOrient  = zero;      
  Energy            = zero;      

  for s = 1:nscale,                  % For each scale.
    filter = logGabor{s} .* spread{o};   % Multiply radial and angular
                                         % components to get the filter. 

%    if o == 1   % accumulate filter info for noise compensation (nominally the same 
                 % for all orientations, hence it is only done once)
        ifftFilt = real(ifft2(filter))*sqrt(rows*cols);  % Note rescaling to match power
        ifftFilterArray{s} = ifftFilt;                   % record ifft2 of filter
%    end

    % Convolve image with even and odd filters returning the result in EO
    EO{s,o} = ifft2(imagefft .* filter);      

    An = abs(EO{s,o});                         % Amplitude of even & odd filter response.
    sumAn_ThisOrient = sumAn_ThisOrient + An;  % Sum of amplitude responses.
    sumE_ThisOrient = sumE_ThisOrient + real(EO{s,o}); % Sum of even filter convolution results.
    sumO_ThisOrient = sumO_ThisOrient + imag(EO{s,o}); % Sum of odd filter convolution results.

    if s==1                                 % Record mean squared filter value at smallest
      EM_n = sum(sum(filter.^2));           % scale. This is used for noise estimation.
      maxAn = An;                           % Record the maximum An over all scales.
    else
      maxAn = max(maxAn, An);
    end

  end                                       % ... and process the next scale

  % Get weighted mean filter response vector, this gives the weighted mean
  % phase angle.

  XEnergy = sqrt(sumE_ThisOrient.^2 + sumO_ThisOrient.^2) + epsilon;   
  MeanE = sumE_ThisOrient ./ XEnergy; 
  MeanO = sumO_ThisOrient ./ XEnergy; 

  % Now calculate An(cos(phase_deviation) - | sin(phase_deviation)) | by
  % using dot and cross products between the weighted mean filter response
  % vector and the individual filter response vectors at each scale.  This
  % quantity is phase congruency multiplied by An, which we call energy.

  for s = 1:nscale,       
      E = real(EO{s,o}); O = imag(EO{s,o});    % Extract even and odd
                                               % convolution results.
      Energy = Energy + E.*MeanE + O.*MeanO - abs(E.*MeanO - O.*MeanE);
  end

  % Compensate for noise
  % We estimate the noise power from the energy squared response at the
  % smallest scale.  If the noise is Gaussian the energy squared will have a
  % Chi-squared 2DOF pdf.  We calculate the median energy squared response
  % as this is a robust statistic.  From this we estimate the mean.
  % The estimate of noise power is obtained by dividing the mean squared
  % energy value by the mean squared filter value

  medianE2n = median(reshape(abs(EO{1,o}).^2,1,rows*cols));
  meanE2n = -medianE2n/log(0.5);
  estMeanE2n(o) = meanE2n;

  noisePower = meanE2n/EM_n;                       % Estimate of noise power.

%  if o == 1
  % Now estimate the total energy^2 due to noise
  % Estimate for sum(An^2) + sum(Ai.*Aj.*(cphi.*cphj + sphi.*sphj))

  EstSumAn2 = zero;
  for s = 1:nscale
    EstSumAn2 = EstSumAn2 + ifftFilterArray{s}.^2;
  end

  EstSumAiAj = zero;
  for si = 1:(nscale-1)
    for sj = (si+1):nscale
      EstSumAiAj = EstSumAiAj + ifftFilterArray{si}.*ifftFilterArray{sj};
    end
  end
  sumEstSumAn2 = sum(sum(EstSumAn2));
  sumEstSumAiAj = sum(sum(EstSumAiAj));

%  end % if o == 1

  EstNoiseEnergy2 = 2*noisePower*sumEstSumAn2 + 4*noisePower*sumEstSumAiAj;

  tau = sqrt(EstNoiseEnergy2/2);                     % Rayleigh parameter
  EstNoiseEnergy = tau*sqrt(pi/2);                   % Expected value of noise energy
  EstNoiseEnergySigma = sqrt( (2-pi/2)*tau^2 );

  T =  EstNoiseEnergy + k*EstNoiseEnergySigma;       % Noise threshold

  % The estimated noise effect calculated above is only valid for the PC_1 measure. 
  % The PC_2 measure does not lend itself readily to the same analysis.  However
  % empirically it seems that the noise effect is overestimated roughly by a factor 
  % of 1.7 for the filter parameters used here.

  T = T/1.7;        % Empirical rescaling of the estimated noise effect to 
                    % suit the PC_2 phase congruency measure

  Energy = max(Energy - T, zero);          % Apply noise threshold

  % Form weighting that penalizes frequency distributions that are
  % particularly narrow.  Calculate fractional 'width' of the frequencies
  % present by taking the sum of the filter response amplitudes and dividing
  % by the maximum amplitude at each point on the image.

  width = sumAn_ThisOrient ./ (maxAn + epsilon) / nscale;    

  % Now calculate the sigmoidal weighting function for this orientation.

  weight = 1.0 ./ (1 + exp( (cutOff - width)*g)); 

  % Apply weighting to energy and then calculate phase congruency

  PC{o} = weight.*Energy./sumAn_ThisOrient;   % Phase congruency for this orientation
  featType{o} = E+i*O;

  % Build up covariance data for every point
  covx = PC{o}*cos(angl);
  covy = PC{o}*sin(angl);
  covx2 = covx2 + covx.^2;
  covy2 = covy2 + covy.^2;
  covxy = covxy + covx.*covy;

end  % For each orientation

fprintf('                                          \r');

% Edge and Corner calculations

% The following is optimised code to calculate principal vector
% of the phase congruency covariance data and to calculate
% the minimumum and maximum moments - these correspond to
% the singular values.

% First normalise covariance values by the number of orientations/2

covx2 = covx2/(norient/2);
covy2 = covy2/(norient/2);
covxy = 4*covxy/norient;   % This gives us 2*covxy/(norient/2)

denom = sqrt(covxy.^2 + (covx2-covy2).^2)+epsilon;
sin2theta = covxy./denom;
cos2theta = (covx2-covy2)./denom;
or = atan2(sin2theta,cos2theta)/2;    % Orientation perpendicular to edge.
or = round(or*180/pi);                % Return result rounded to integer
                                      % degrees.
neg = or < 0;                                 
or = ~neg.*or + neg.*(or+180);        % Adjust range from -90 to 90
                                      % to 0 to 180.

M = (covy2+covx2 + denom)/2;          % Maximum moment
m = (covy2+covx2 - denom)/2;          % ... and minimum moment




    
%------------------------------------------------------------------
% CHECKARGS
%
% Function to process the arguments that have been supplied, assign
% default values as needed and perform basic checks.
    
function [im, nscale, norient, minWaveLength, mult, sigmaOnf, ...
          dThetaOnSigma,k, cutOff, g] = checkargs(arg); 

    nargs = length(arg);
    
    if nargs < 1
        error('No image supplied as an argument');
    end    
    
    % Set up default values for all arguments and then overwrite them
    % with with any new values that may be supplied
    im              = [];
    nscale          = 4;     % Number of wavelet scales.    
    norient         = 6;     % Number of filter orientations.
    minWaveLength   = 3;     % Wavelength of smallest scale filter.    
    mult            = 2.1;   % Scaling factor between successive filters.    
    sigmaOnf        = 0.55;  % Ratio of the standard deviation of the
                             % Gaussian describing the log Gabor filter's
                             % transfer function in the frequency domain
                             % to the filter center frequency.    
    dThetaOnSigma   = 1.5;   % Ratio of angular interval between filter orientations    
                             % and the standard deviation of the angular Gaussian
                             % function used to construct filters in the
                             % freq. plane.
    k               = 2.0;   % No of standard deviations of the noise
                             % energy beyond the mean at which we set the
                             % noise threshold point. 
    cutOff          = 0.5;   % The fractional measure of frequency spread
                             % below which phase congruency values get penalized.
    g               = 10;    % Controls the sharpness of the transition in
                             % the sigmoid function used to weight phase
                             % congruency for frequency spread.                      
    
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
                elseif n == 3, norient       = arg{n};
                elseif n == 4, minWaveLength = arg{n};
                elseif n == 5, mult          = arg{n};
                elseif n == 6, sigmaOnf      = arg{n};
                elseif n == 7, dThetaOnSigma = arg{n};
                elseif n == 8, k             = arg{n};              
                elseif n == 9, cutOff        = arg{n}; 
                elseif n == 10,g             = arg{n};                                                    
                end
            end
        end
    end

    % Code to handle parameter name - value pairs
    if readstate == keywordvalue
        while n < nargs
            
            if ~isa(arg{n},'char') | ~isa(arg{n+1}, 'double')
                error('There should be a parameter name - value pair');
            end
            
            if     strncmpi(arg{n},'im'      ,2), im =        arg{n+1};
            elseif strncmpi(arg{n},'nscale'  ,2), nscale =    arg{n+1};
            elseif strncmpi(arg{n},'norient' ,2), norient =   arg{n+1};
            elseif strncmpi(arg{n},'minWaveLength',2), minWaveLength = arg{n+1};
            elseif strncmpi(arg{n},'mult'    ,2), mult =      arg{n+1};
            elseif strncmpi(arg{n},'sigmaOnf',2), sigmaOnf =  arg{n+1};
            elseif strncmpi(arg{n},'dThetaOnSigma',2), dThetaOnSigma =  arg{n+1};
            elseif strncmpi(arg{n},'k'       ,1), k =         arg{n+1};
            elseif strncmpi(arg{n},'cutOff'  ,2), cutOff   =  arg{n+1};
            elseif strncmpi(arg{n},'g'       ,1), g        =  arg{n+1};         
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
    
    if norient < 1 
        error('norient must be an integer >= 1');
    end    

    if minWaveLength < 2
        error('It makes little sense to have a wavelength < 2');
    end          

    if cutOff < 0 | cutOff > 1
        error('Cut off value must be between 0 and 1');
    end
    

    



