% NOISECOMP - Function for denoising an image
%
% function cleanimage = noisecomp(image, k, nscale, mult, norient, softness)
%
% Parameters:
%              k - No of standard deviations of noise to reject 2-3
%              nscale - No of filter scales to use (5-7) - the more scales used
%                       the more low frequencies are covered
%              mult   - multiplying factor between scales  (2.5-3)
%              norient - No of orientations to use (6)
%              softness - degree of soft thresholding (0-hard  1-soft)
%
% For maximum processing speed the input image should have a size that
% is a power of 2.  
%
% The convolutions are done via the FFT.  Many of the parameters relate 
% to the specification of the filters in the frequency plane.  
% The parameters are set within the file rather than being specified as 
% arguments because they rarely need to be changed - nor are they very 
% critical.
%
% Reference:
% Peter Kovesi, "Phase Preserving Denoising of Images". 
% The Australian Pattern Recognition Society Conference: DICTA'99. 
% December 1999. Perth WA. pp 212-217
% http://www.cs.uwa.edu.au/pub/robvis/papers/pk/denoise.ps.gz. 
%

% Copyright (c) 1998-2000 Peter Kovesi
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

% September 1998 - original version
% May 1999       - 
% May 2000       - modified to allow arbitrary size images
         

function cleanimage = noisecomp(image, k, nscale, mult, norient, softness)

%nscale          = 6;    % Number of wavelet scales.
%norient         = 6;    % Number of filter orientations.
minWaveLength   = 2;     % Wavelength of smallest scale filter.
%mult            = 2;    % Scaling factor between successive filters.
sigmaOnf        = 0.55;  % Ratio of the standard deviation of the Gaussian 
                         % describing the log Gabor filter's transfer function 
                         % in the frequency domain to the filter center frequency.
dThetaOnSigma   = 1.;   % Ratio of angular interval between filter orientations
                         % and the standard deviation of the angular Gaussian
                         % function used to construct filters in the freq. plane.
epsilon         = .00001;% Used to prevent division by zero.


thetaSigma = pi/norient/dThetaOnSigma;  % Calculate the standard deviation of the
                                        % angular Gaussian function used to
                                        % construct filters in the freq. plane.

imagefft = fft2(image);                 % Fourier transform of image
[rows,cols] = size(imagefft);

% Create two matrices, x and y. All elements of x have a value equal to its 
% x coordinate relative to the centre, elements of y have values equal to 
% their y coordinate relative to the centre.

x = ones(rows,1) * (-cols/2 : (cols/2 - 1))/(cols/2); 
y = (-rows/2 : (rows/2 - 1))' * ones(1,cols)/(rows/2);

radius = sqrt(x.^2 + y.^2);      % Matrix values contain normalised radius from centre.
radius(round(rows/2+1),round(cols/2+1)) = 1;   % Get rid of the 0 radius value in the middle so that
                                 % taking the log of the radius will not cause trouble.
theta = atan2(-y,x);             % Matrix values contain polar angle.
                                 % (note -ve y is used to give +ve anti-clockwise angles)
clear x; clear y;                % save a little memory
sig = [];
estMeanEn = [];
aMean = [];
aSig = [];

totalEnergy = zeros(rows,cols);               % response at each orientation.

for o = 1:norient,                   % For each orientation.
  disp(['Processing orientation ' num2str(o)]);
  angl = (o-1)*pi/norient;           % Calculate filter angle.
  wavelength = minWaveLength;        % Initialize filter wavelength.

  % Pre-compute filter data specific to this orientation
  % For each point in the filter matrix calculate the angular distance from the
  % specified filter orientation.  To overcome the angular wrap-around problem
  % sine difference and cosine difference values are first computed and then
  % the atan2 function is used to determine angular distance.

  ds = sin(theta) * cos(angl) - cos(theta) * sin(angl); % Difference in sine.
  dc = cos(theta) * cos(angl) + sin(theta) * sin(angl); % Difference in cosine.
  dtheta = abs(atan2(ds,dc));                           % Absolute angular distance.
  spread = exp((-dtheta.^2) / (2 * thetaSigma^2));      % Calculate the angular filter component.

  for s = 1:nscale,                  % For each scale.

    % Construct the filter - first calculate the radial filter component.
    fo = 1.0/wavelength;                  % Centre frequency of filter.
    rfo = fo/0.5;                         % Normalised radius from centre of frequency plane 
                                          % corresponding to fo.
    logGabor = exp((-(log(radius/rfo)).^2) / (2 * log(sigmaOnf)^2));  
    logGabor(round(rows/2+1),round(cols/2+1)) = 0;      % Set the value at the center of the filter
                                          % back to zero (undo the radius fudge).

    filter = logGabor .* spread;          % Multiply by the angular spread to get the filter.
    filter = fftshift(filter);            % Swap quadrants to move zero frequency 
                                          % to the corners.

    % Convolve image with even an odd filters returning the result in EO
    EOfft = imagefft .* filter;           % Do the convolution.
    EO = ifft2(EOfft);                    % Back transform.
    aEO = abs(EO);

    if s == 1
      % Estimate the mean and variance in the amplitude response of the smallest scale  
      % filter pair at this orientation. 
      % If the noise is Gaussian the amplitude response will have a Rayleigh distribution.
      % We calculate the median amplitude response as this is a robust statistic.  
      % From this we estimate the mean and variance of the Rayleigh distribution

      medianEn =  median(reshape(aEO,1,rows*cols));
      meanEn = medianEn*.5*sqrt(-pi/log(0.5));

      RayVar = (4-pi)*(meanEn.^2)/pi;
      RayMean = meanEn;

      estMeanEn = [estMeanEn meanEn];
      sig = [sig sqrt(RayVar)];

      %% May want to look at actual distribution on special images
      % hist(reshape(aEO,1,rows*cols),100);
      % pause(1);
    end

    % Now apply soft thresholding

    T = (RayMean + k*sqrt(RayVar))/(mult^(s-1));  % Noise effect inversely proportional to
                                                  % bandwidth/centre frequency.

    validEO = aEO > T;                   % Find where magnitude of energy exceeds noise.
    V = softness*T*EO./(aEO + epsilon);  % Calculate array of noise vectors to subtract.
    V = ~validEO.*EO + validEO.*V;       % Adjust noise vectors so that EO values will 
                                         % not be negated
    EO = EO-V;                           % Subtract noise vector.

    totalEnergy = totalEnergy + EO;
    wavelength = wavelength * mult;      % Wavelength of next filter
  end                               
end  % For each orientation
disp('Estimated mean noise in each orientation')
disp(estMeanEn);

cleanimage = real(totalEnergy);
%imagesc(cleanimage), title('denoised image'), axis image;


