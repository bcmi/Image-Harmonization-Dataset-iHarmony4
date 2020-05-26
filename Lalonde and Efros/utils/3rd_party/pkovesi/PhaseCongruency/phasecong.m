% PHASECONG - Computes phase congruency on an image.
%
% Usage: [pc or ft] = phasecong(im)
%
% This function calculates the PC_2 measure of phase congruency.  
% For maximum speed the input image should be square and have a 
% size that is a power of 2, but the code will operate on images
% of arbitrary size.  
%
%
% Returned values:
%                 pc - Phase congruency image (values between 0 and 1)   
%                 or - Orientation image.  Provides orientation in which 
%                      local energy is a maximum in in degrees (0-180), 
%                      angles positive anti-clockwise.
%                 ft - A complex valued image giving the weighted mean 
%                      phase angle at every point in the image for the 
%                      orientation having maximum energy.  Use the
%                      function DISPFEAT to display this data.
%
% Parameters:  
%                 im - A greyscale image to be processed.
%                 
% You can also specify numerous optional parameters.  See the code to find
% out what they are.  The convolutions are done via the FFT.  Many of the
% parameters relate to the specification of the filters in the frequency
% plane.  Default values for parameters are set within the file rather than
% being required as arguments because they rarely need to be changed - nor
% are they very critical.  However, you may want to experiment with
% specifying/editing the values of `nscales' and `noiseCompFactor'.
%
% Note this phase congruency code is very computationally expensive and uses
% *lots* of memory.
%
%
% Example MATLAB session:
%
% >> im = imread('picci.tif');   
% >> image(im);                          % Display the image
% >> [pc or ft] = phasecong(im);
% >> imagesc(pc), colormap(gray);        % Display the phase congruency image
%
%
% To convert the phase congruency image to an edge map (with my usual parameters):
%
% >> nm = nonmaxsup(pc, or, 1.5);        % Non-maxima suppression.  
%    The parameter 1.5 can result in edges more than 1 pixel wide but helps
%    in picking up `broad' maxima.
% >> edgim = hysthresh(nm, 0.4, 0.2);    % Hysteresis thresholding.
% >> edgeim = bwmorph(edgim,'skel',Inf); % Skeletonize the edgemap to fix
%                                        % the non-maximal suppression.
% >> imagesc(edgeim), colormap(gray);
%
%
% To display the different feature types present in your image use:
%
% >> dispfeat(ft,edgim);
%
% With a small amount of editing the code can be modified to calculate
% a dimensionless measure of local symmetry in the image.  The basis
% of this is that one looks for points in the image where the local 
% phase is 90 or 270 degrees (the symmetric points in the cycle).
% Editing instructions are within the code.
%
% Notes on filter settings to obtain even coverage of the spectrum
% dthetaOnSigma 1.5
% sigmaOnf  .85   mult 1.3
% sigmaOnf  .75   mult 1.6     (bandwidth ~1 octave)
% sigmaOnf  .65   mult 2.1  
% sigmaOnf  .55   mult 3       (bandwidth ~2 octaves)
%

% References:
%
%     Peter Kovesi, "Image Features From Phase Congruency". Videre: A
%     Journal of Computer Vision Research. MIT Press. Volume 1, Number 3,
%     Summer 1999 http://mitpress.mit.edu/e-journals/Videre/001/v13.html

% Copyright (c) 1996-2005 Peter Kovesi
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

% Original Version written April 1996     
% Noise compensation corrected. August 1998
% Noise compensation corrected. October 1998  - Again!!!
% Modified to operate on non-square images of arbitrary size. September 1999
% Modified to return feature type image. May 2001



function[phaseCongruency,orientation, featType]=phasecong(im, nscale, norient, ...
						minWaveLength, mult, ...
						sigmaOnf, dThetaOnSigma, ...
						k, cutOff)

sze = size(im);

if nargin < 2
    nscale          = 3;     % Number of wavelet scales.
end
if nargin < 3
    norient         = 6;     % Number of filter orientations.
end
if nargin < 4
    minWaveLength   = 3;     % Wavelength of smallest scale filter.
end
if nargin < 5
    mult            = 2;     % Scaling factor between successive filters.
end
if nargin < 6
    sigmaOnf        = 0.55;  % Ratio of the standard deviation of the
                             % Gaussian describing the log Gabor filter's transfer function 
			     % in the frequency domain to the filter center frequency.
end
if nargin < 7
    dThetaOnSigma   = 1.7;   % Ratio of angular interval between filter orientations
			     % and the standard deviation of the angular Gaussian
			     % function used to construct filters in the
                             % freq. plane.
end
if nargin < 8
    k               = 3.0;   % No of standard deviations of the noise energy beyond the
			     % mean at which we set the noise threshold point.
			     % standard deviation to its maximum effect
                             % on Energy.
end
if nargin < 9
    cutOff          = 0.4;   % The fractional measure of frequency spread
                             % below which phase congruency values get penalized.
end
   
g               = 10;    % Controls the sharpness of the transition in the sigmoid
                         % function used to weight phase congruency for frequency
                         % spread.
epsilon         = .0001; % Used to prevent division by zero.


thetaSigma = pi/norient/dThetaOnSigma;  % Calculate the standard deviation of the
                                        % angular Gaussian function used to
                                        % construct filters in the freq. plane.

imagefft = fft2(im);                    % Fourier transform of image
sze = size(imagefft);
rows = sze(1);
cols = sze(2);
zero = zeros(sze);

totalEnergy = zero;                     % Matrix for accumulating weighted phase 
                                        % congruency values (energy).
totalSumAn  = zero;                     % Matrix for accumulating filter response
                                        % amplitude values.
orientation = zero;                     % Matrix storing orientation with greatest
                                        % energy for each pixel.
estMeanE2n = [];

% Pre-compute some stuff to speed up filter construction

x = ones(rows,1) * (-cols/2 : (cols/2 - 1))/(cols/2);  
y = (-rows/2 : (rows/2 - 1))' * ones(1,cols)/(rows/2);
radius = sqrt(x.^2 + y.^2);       % Matrix values contain *normalised* radius from centre.
radius(round(rows/2+1),round(cols/2+1)) = 1; % Get rid of the 0 radius value in the middle 
                                             % so that taking the log of the radius will 
                                             % not cause trouble.
theta = atan2(-y,x);              % Matrix values contain polar angle.
                                  % (note -ve y is used to give +ve
                                  % anti-clockwise angles)
sintheta = sin(theta);
costheta = cos(theta);
clear x; clear y; clear theta;      % save a little memory

% The main loop...

for o = 1:norient,                   % For each orientation.
  disp(['Processing orientation ' num2str(o)]);
  angl = (o-1)*pi/norient;           % Calculate filter angle.
  wavelength = minWaveLength;        % Initialize filter wavelength.
  sumE_ThisOrient   = zero;          % Initialize accumulator matrices.
  sumO_ThisOrient   = zero;       
  sumAn_ThisOrient  = zero;      
  Energy_ThisOrient = zero;      
  EOArray = [];          % Array of complex convolution images - one for each scale.
  ifftFilterArray = [];  % Array of inverse FFTs of filters

  % Pre-compute filter data specific to this orientation
  % For each point in the filter matrix calculate the angular distance from the
  % specified filter orientation.  To overcome the angular wrap-around problem
  % sine difference and cosine difference values are first computed and then
  % the atan2 function is used to determine angular distance.

  ds = sintheta * cos(angl) - costheta * sin(angl); % Difference in sine.
  dc = costheta * cos(angl) + sintheta * sin(angl); % Difference in cosine.
  dtheta = abs(atan2(ds,dc));                           % Absolute angular distance.
  spread = exp((-dtheta.^2) / (2 * thetaSigma^2));      % Calculate the angular filter component.

  for s = 1:nscale,                  % For each scale.

    % Construct the filter - first calculate the radial filter component.
    fo = 1.0/wavelength;                  % Centre frequency of filter.
    rfo = fo/0.5;                         % Normalised radius from centre of frequency plane 
                                          % corresponding to fo.
    logGabor = exp((-(log(radius/rfo)).^2) / (2 * log(sigmaOnf)^2));  
    logGabor(round(rows/2+1),round(cols/2+1)) = 0; % Set the value at the center of the filter
                                                   % back to zero (undo the radius fudge).

    filter = logGabor .* spread;          % Multiply by the angular spread to get the filter.
    filter = fftshift(filter);            % Swap quadrants to move zero frequency 
                                          % to the corners.

    ifftFilt = real(ifft2(filter))*sqrt(rows*cols);  % Note rescaling to match power
    ifftFilterArray = [ifftFilterArray ifftFilt];    % record ifft2 of filter

    % Convolve image with even and odd filters returning the result in EO
    EOfft = imagefft .* filter;           % Do the convolution.
    EO = ifft2(EOfft);                    % Back transform.

    EOArray = [EOArray, EO];              % Record convolution result
    An = abs(EO);                         % Amplitude of even & odd filter response.

    sumAn_ThisOrient = sumAn_ThisOrient + An;     % Sum of amplitude responses.
    sumE_ThisOrient = sumE_ThisOrient + real(EO); % Sum of even filter convolution results.
    sumO_ThisOrient = sumO_ThisOrient + imag(EO); % Sum of odd filter convolution results.

    if s == 1                             % Record the maximum An over all scales
      maxAn = An;
    else
      maxAn = max(maxAn, An);
    end
    
    if s==1
      EM_n = sum(sum(filter.^2));           % Record mean squared filter value at smallest
    end                                     % scale. This is used for noise estimation.

    wavelength = wavelength * mult;         % Finally calculate Wavelength of next filter
  end                                       % ... and process the next scale

  % Get weighted mean filter response vector, this gives the weighted mean phase angle.

  XEnergy = sqrt(sumE_ThisOrient.^2 + sumO_ThisOrient.^2) + epsilon;   
  MeanE = sumE_ThisOrient ./ XEnergy; 
  MeanO = sumO_ThisOrient ./ XEnergy; 

  % Now calculate An(cos(phase_deviation) - | sin(phase_deviation)) | by using
  % dot and cross products between the weighted mean filter response vector and
  % the individual filter response vectors at each scale.  This quantity is 
  % phase congruency multiplied by An, which we call energy.

  for s = 1:nscale,       
      EO = submat(EOArray,s,cols);  % Extract even and odd filter 
      E = real(EO); O = imag(EO);
      Energy_ThisOrient = Energy_ThisOrient ...
        + E.*MeanE + O.*MeanO - abs(E.*MeanO - O.*MeanE);
  end

  % Note: To calculate the phase symmetry measure replace the for loop above 
  % with the following loop. (The calculation of MeanE, MeanO, sumE_ThisOrient 
  % and sumO_ThisOrient can also be omitted). It is suggested that the value
  % of nscale is increased (to say, 5 for a 256x256 image) and that cutOff is
  % set to 0 to eliminate weighting for frequency spread.

%   for s = 1:nscale,                  
%     Energy_ThisOrient = Energy_ThisOrient ...
%      + abs(real(submat(EOArray,s,cols))) - abs(imag(submat(EOArray,s,cols)));
%   end

  % Compensate for noise
  % We estimate the noise power from the energy squared response at the smallest scale.
  % If the noise is Gaussian the energy squared will have a Chi-squared 2DOF pdf.
  % We calculate the median energy squared response as this is a robust statistic.  
  % From this we estimate the mean.  
  % The estimate of noise power is obtained by dividing the mean squared energy value
  % by the mean squared filter value

  medianE2n = median(reshape(abs(submat(EOArray,1,cols)).^2,1,rows*cols));
  meanE2n = -medianE2n/log(0.5);
  estMeanE2n = [estMeanE2n meanE2n];

  noisePower = meanE2n/EM_n;                       % Estimate of noise power.

  % Now estimate the total energy^2 due to noise
  % Estimate for sum(An^2) + sum(Ai.*Aj.*(cphi.*cphj + sphi.*sphj))

  EstSumAn2 = zero;
  for s = 1:nscale
    EstSumAn2 = EstSumAn2+submat(ifftFilterArray,s,cols).^2;
  end

  EstSumAiAj = zero;
  for si = 1:(nscale-1)
    for sj = (si+1):nscale
      EstSumAiAj = EstSumAiAj + submat(ifftFilterArray,si,cols).*submat(ifftFilterArray,sj,cols);
    end
  end

  EstNoiseEnergy2 = 2*noisePower*sum(sum(EstSumAn2)) + 4*noisePower*sum(sum(EstSumAiAj));

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

  Energy_ThisOrient = max(Energy_ThisOrient - T, zero);  % Apply noise threshold

  % Form weighting that penalizes frequency distributions that are particularly
  % narrow.
  % Calculate fractional 'width' of the frequencies present by taking
  % the sum of the filter response amplitudes and dividing by the maximum 
  % amplitude at each point on the image.

  width = sumAn_ThisOrient ./ (maxAn + epsilon) / nscale;    

  % Now calculate the sigmoidal weighting function for this orientation.

  weight = 1.0 ./ (1 + exp( (cutOff - width)*g)); 

  % Apply weighting

  Energy_ThisOrient =   weight.*Energy_ThisOrient;

  % Update accumulator matrix for sumAn and totalEnergy

  totalSumAn  = totalSumAn + sumAn_ThisOrient;
  totalEnergy = totalEnergy + Energy_ThisOrient;

  % Update orientation matrix by finding image points where the energy in this
  % orientation is greater than in any previous orientation (the change matrix)
  % and then replacing these elements in the orientation matrix with the
  % current orientation number.

  if(o == 1),
    maxEnergy = Energy_ThisOrient;
    featType = E + i*O;
  else
    change = Energy_ThisOrient > maxEnergy;
    orientation = (o - 1).*change + orientation.*(~change);
    featType = (E+i*O).*change + featType.*(~change);
    maxEnergy = max(maxEnergy, Energy_ThisOrient);
  end

end  % For each orientation


disp('Mean Energy squared values recorded with smallest scale filter at each orientation');
disp(estMeanE2n);

% Display results
%imagesc(totalEnergy), axis image, title('total energy');
%disp('Hit any key to continue '); pause
%imagesc(totalSumAn), axis image, title('total sumAn'); 
%disp('Hit any key to continue '); pause

% Normalize totalEnergy by the totalSumAn to obtain phase congruency

phaseCongruency = totalEnergy ./ (totalSumAn + epsilon);

%imagesc(phaseCongruency), axis image, title('phase congruency');

% Convert orientation matrix values to degrees

orientation = orientation * (180 / norient);

featType = featType*i;   % Rotate feature phase angles by 90deg so that 0
                         % phase corresponds to a step edge (this is a
                         % fudge I must have something the wrong way
                         % around somewhere)


%
% SUBMAT
%
% Function to extract the i'th sub-matrix 'cols' wide from a large
% matrix composed of several matricies.  The large matrix is used in
% lieu of an array of matricies 

function a = submat(big,i,cols)

a = big(:,((i-1)*cols+1):(i*cols));

