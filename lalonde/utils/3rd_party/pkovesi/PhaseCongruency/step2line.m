%  STEP2LINE - Generate test image interpolating a step to a line.
%
%  Function to generate a test image where the feature type changes
%  from a step edge to a line feature from top to bottom
%
%  Usage:
%      im = step2line(nscales, ampexponent, sze)
%
%      nscales     - No of fourier components used to construct the signal
%      ampexponent - decay exponent of amplitude with frequency
%                    a value of -1 will produce amplitude inversely
%                    proportional to frequency (corresponds to step feature)
%                    a value of -2 will result in the line feature
%                    appearing as a triangular waveform.
%      sze         - Optional size of image, defaults to 256x256
%
%      Returns:
%              im  - Image showing the grating pattern
%
%  suggested parameters: 
%      step2line(100, -1) 
%

% Copyright (c) 1997 Peter Kovesi
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
%
% 1997            Original version
% September 2011  Modified to allow number of cycles to be specified

function im = step2line(nscales, ampexponent, Npts, nCycles, phaseCycles)
    
    Octave = exist('OCTAVE_VERSION') ~= 0;  % Are we running under Octave?    

    if ~exist('Npts', 'var'),    Npts = 256;    end
    if ~exist('nCycles', 'var'), nCycles = 1.5; end
    if ~exist('phaseCycles', 'var'), phaseCycles = 0.5; end
    
    x = [0:(Npts-1)]/(Npts-1)*nCycles*2*pi;
    
    im = zeros(Npts,Npts);
    off = 0;
    
    for row = 1:Npts
	signal = zeros(1,Npts);
	for scale = 1:2:(nscales*2-1)
	    signal = signal + scale^ampexponent*sin(scale*x + off);
	end
	im(row,:) = signal;
	off = off + phaseCycles*pi/Npts;
    end
    
    figure
    colormap(gray);
    imagesc(im), axis('off') , title('step to line feature interpolation');
    
    range = 3.2;
    s = 'Profiles having phase congruency at 0/180, 30/210, 60/240 and 90/270 degrees';    

    if Octave
	plot(im(1,:)) , title(s), axis([0,Npts,-range,range]), axis('off'); hold('on')
	plot(im(fix(Npts/3),:)), axis([0,Npts,-range,range]), axis('off');
	plot(im(fix(2*Npts/3),:)), axis([0,Npts,-range,range]), axis('off');
	plot(im(Npts,:)), axis([0,Npts,-range,range]), axis('off');     
	hold('off')

    else   % MATLAB plotting
	figure
	subplot(4,1,1), plot(im(1,:)) , title(s), axis([0,Npts,-range,range]), axis('off');
	subplot(4,1,2), plot(im(fix(Npts/3),:)), axis([0,Npts,-range,range]), axis('off');
	subplot(4,1,3), plot(im(fix(2*Npts/3),:)), axis([0,Npts,-range,range]), axis('off');
	subplot(4,1,4), plot(im(Npts,:)), axis([0,Npts,-range,range]), axis('off');
    end
    
	