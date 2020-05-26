% CLOUDS
%
% Function to create a movie of noise images having 1/f amplitude spectum properties
%
% Usage: clouds(size, factor, meandev, stddev, lowvel, velfactor, nframes)
%
%        size   - size of image to produce
%        factor - controls spectrum = 1/(f^factor)
%        meandev - mean change in phaseangle per frame
%        stddev  - stddev of change in phaseangle per frame
%        lowvel  - phase velocity at 0 frequency 
%        velfactor - phase velocity = freq^velfactor
%        nframes - no of frames in movie
%
%        factor = 0   - raw Gaussian noise image
%               = 1   - gives the 1/f `standard' drop-off for `natural' images
%               = 1.5 - seems to give the most intersting `cloud patterns'
%               = 2 or greater - produces `blobby' images
% PK 18-4-00
%

function clouds(size, factor, meandev, stddev, lowvel, velfactor, nframes)

rows = size;
cols = size;
phase = random('Uniform',0,2*pi,size,size);  % Random uniform distribution 0 - 2pi

% Create two matrices, x and y. All elements of x have a value equal to its 
% x coordinate relative to the centre, elements of y have values equal to 
% their y coordinate relative to the centre.  From these two matrices produce
% a radius matrix that gives distances from the middle

x = ones(rows,1) * (-cols/2 : (cols/2 - 1)); 
y = (-rows/2 : (rows/2 - 1))' * ones(1,cols);

x = x/(cols/2);
y = y/(rows/2);
radius = sqrt(x.^2 + y.^2);         % Matrix values contain radius from centre.
radius(rows/2+1,cols/2+1) = 1;      % .. avoid division by zero.

filter = 1./(radius.^factor);       % Construct the filter.
filter = fftshift(filter);

phasemod = fftshift(radius.^velfactor + lowvel);

% Construct fft of noise image with the specified amplitude spectrum



for n = 1:nframes
  disp(n);
  dphase = random('norm',meandev,stddev,size,size);  % Random normal distribution 
  dphase = dphase.*phasemod;

  phase = phase + dphase;
  newfft =  filter .* exp(i*phase);
  im = real(ifft2(newfft)); % Invert to obtain final noise image
  imagesc(im), axis('equal'), axis('off');

   if n==1
     CloudMovie = moviein(nframes);
   end

  CloudMovie(:,n) = getframe;


end

movie(CloudMovie,-5,12);

save('CloudMovie','CloudMovie');
