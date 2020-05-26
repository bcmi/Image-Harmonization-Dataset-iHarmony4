% CLOUD9 - Cloud movie of 1/f noise.
%
% Function to create a movie of noise images having 1/f amplitude spectum
% properties.
%
% Usage: CloudMovie = cloud9(size, factor, nturns, velfactor, nframes)
%
%        size   - [rows cols] size of image to produce
%        factor - controls spectrum = 1/(f^factor)
%        nturns - No of 2pi cycles phase can change over the whole sequence
%        lowvel  - phase velocity at 0 frequency 
%        velfactor - phase velocity = freq^velfactor
%        nframes - no of frames in movie
%
%        factor = 0   - raw Gaussian noise image
%               = 1   - gives the 1/f `standard' drop-off for `natural' images
%               = 1.5 - seems to give the most intersting `cloud patterns'
%               = 2 or greater - produces `blobby' images
%
% Favourite parameters:
%                     m = cloud9([480 640], 1.5, 4, 1, .1, 100);
%

% Copyright (c) 2000 Peter Kovesi
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

%  April 2000


function CloudMovie = cloud9(sze, factor, nturns, lowvel, velfactor, nframes)

rows = sze(1);
cols = sze(2);
phase = i*random('Uniform',0,2*pi,rows,cols);  % Random uniform distribution 0 - 2pi

% Create two matrices, x and y. All elements of x have a value equal to its 
% x coordinate relative to the centre, elements of y have values equal to 
% their y coordinate relative to the centre.  From these two matrices produce
% a radius matrix that gives distances from the middle

x = ones(rows,1) * (-cols/2 : (cols/2 - 1)); % x = x/(cols/2);
y = (-rows/2 : (rows/2 - 1))' * ones(1,cols);% y = y/(rows/2);

radius = sqrt(x.^2 + y.^2);         % Matrix values contain radius from centre.
radius(rows/2+1,cols/2+1) = 1;      % .. avoid division by zero.

amp = 1./(radius.^factor);          % Construct the amplitude spectrum
amp = fftshift(amp);

phasemod = round(fftshift(radius.^velfactor + lowvel));

phasechange = 2*pi*((random('unid',nturns+1,rows,cols) -1 - nturns/2) .* phasemod );

maxturns = max(max(phasechange/(2*pi)))
maxturns = min(min(phasechange/(2*pi)))
minturns = min(min(abs(phasechange)/(2*pi)))

dphase = i*phasechange/(nframes-1);   % premultiply by i to save time in th eloop

% Construct fft of noise image with the specified amplitude spectrum

fig = figure(1), warning off, imagesc(zeros(rows,cols)), axis('off'), truesize(1)


set(fig,'DoubleBuffer','on');
%set(gca,'xlim',[-80 80],'ylim',[-80 80],...
%    	   'NextPlot','replace','Visible','off')
mov = avifile('cloud')

a = 0.7;  % Set up colormap
map = a*bone + (1-a)*gray;

for n = 1:nframes
  fprintf('frame %d/%d \r',n, nframes);

  phase = phase + dphase;
  newfft =  amp .* exp(phase);
  im = real(ifft2(newfft));            % Invert to obtain final noise image
  imagesc(im), colormap(bone),axis('equal'), axis('off'), truesize(1)

   %if n==1
    % CloudMovie = moviein(nframes);    % initialise movie storage
    %end
   F = getframe(gca);
   mov = addframe(mov,F);
  %CloudMovie(:,n) = getframe;
end
fprintf('\n');
warning on
 mov = close(mov);
%movie(CloudMovie,5,30);
%save('CloudMovie','CloudMovie');
