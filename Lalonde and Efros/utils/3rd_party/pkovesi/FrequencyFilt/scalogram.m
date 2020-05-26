% SCALOGRAM - Calculates phase and amplitude scalogram of 1D signal.
%
% Usage: 
% [amplitude, phase] = scalogram(signal, minwavelength, mult, nscales, sigmaOnf, threeD)
%
% Function to calculate the phase and amplitude scalograms of a 1D signal
% Analysis is done using quadrature pairs of log Gabor filters
%
% Arguments:
%        signal        - a 1D vector to be analyzed (for maximum speed 
%                        length should be a power of 2)
%        minwavelength - wavelength of smallest scale filter to use
%        mult          - scaling factor between successive filters
%        nscales       - No of filtering scales to use
%        sigmaOnf      - Shape factor of log Gabor filter controlling bandwidth
%                       .35 - bandwidth of approx 3 ocatves
%                       .55 - bandwidth of approx 2 ocatves
%                       .75 - bandwidth of approx 1 ocatve
%        threeD        - An optional argument (0 or 1) indicating whether
%                        to display additional 3D visualisations of the
%                        result (this can take a while to display).
%
% Output:
%         amplitude    - image of amplitude responses
%         phase        - image of phase responses
%
% Suggested values:
% [amplitude, phase] = scalogram(signal, 4, 1.05, 128, .55)
%

% Copyright (c) 1997-2001 Peter Kovesi
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

% March     1997  - Original version
% September 2001  - Code tidied and plots improved.

function [amplitude, phase] = scalogram(signal, minwavelength, mult, ...
					nscales, sigmaOnf, threeD)

    Octave = exist('OCTAVE_VERSION') ~= 0; % Are we running under Octave
    
% Check the input data

sze = size(signal);

if(sze(1) == 1 & sze(2) > 1)     % data is ok - do nothing
  ;
elseif(sze(1) > 1 & sze(2) == 1) % signal was a column vector - transpose the data
  signal = signal';           
elseif(sze(1) > 1 & sze(2) > 1)  % 2D data
  error('scalogram: data must be a 1D vector')
else
  error('scalogram: data must be a 1D vector - with more than one element')  
end

if nargin == 5
    threeD = 0;
end

ndata = length(signal);
if mod(ndata,2) == 1             % If there is an odd No of data points 
  ndata = ndata-1;               % throw away the last one.
  signal = signal(1:ndata);
end

signalfft = fft(signal);           % Take FFT of signal

amplitude = zeros(nscales,ndata);  % Pre-allocate memory for speed
phase     = zeros(nscales,ndata);
logGabor  = zeros(1,ndata);
EO        = zeros(1,ndata);

radius =  [0:fix(ndata/2)]/fix(ndata/2)/2;  % Frequency values 0 - 0.5
radius(1) = 1;                     % Fudge to stop log function complaining at origin.

wavelength = minwavelength;

for row = 1:nscales
   fo = 1.0/wavelength;            % Centre frequency of filter.

   % Construct filter
   logGabor(1:ndata/2+1) = exp((-(log(radius/fo)).^2) / (2 * log(sigmaOnf)^2));  
   logGabor(1) = 0;                % Set value at zero frequency to 0 (undo fudge).

   % Multiply filter and FFT of signal, then take inverse FFT.
   EO = ifft(signalfft .* logGabor);

   amplitude(row,:) = abs(EO);     % Record the amplitude of the result
   phase(row,:) = angle(EO);       % .. and the phase.
 
   wavelength = wavelength * mult; % Increment the filter wavelength.
end 


% Set up axis range for plotting the results.
minsig = min(signal); maxsig = max(signal); r = maxsig-minsig;  
rmin = minsig-r/10; rmax = maxsig+r/10;

% Set up data for labelling the scale axis
Nticks = 8;
dtick = fix(nscales/Nticks);
tickLocations = 1:dtick:nscales;
tickValues = round(minwavelength*mult.^(tickLocations-1));

% Amplitude only scalogram.
figure(1), clf, colormap(gray)
subplot(2,1,1), plot(signal), axis([0,ndata,rmin,rmax]), title('signal');
h = subplot(2,1,2); imagesc(-amplitude), colormap(gray), title('amplitude scalogram');
set(h,'YTick',tickLocations);
if ~Octave
  set(h,'YTickLabel',tickValues);
end

ylabel('scale');


% Phase only scalogram: phase encoded by hue, saturation uniform.
figure(2), clf
hsv(:,:,1) = (phase+pi)/(2*pi);               % hue varies with phase.
hsv(:,:,2) = ones(size(amplitude));           % saturation fixed at 1
hsv(:,:,3) = ones(size(amplitude));           % intensity is fixed at 1.

subplot(2,1,1), plot(signal), axis([0,ndata,rmin,rmax]), title('signal');
h = subplot(2,1,2); 
if Octave
    imagesc(hsv2rgboctave(hsv));
else
    image(hsv2rgb(hsv));
end
title('phase scalogram');
set(h,'YTick',tickLocations);
if ~Octave
    set(h,'YTickLabel',tickValues);
end

ylabel('scale');

% Phase and amplitude scalogram: phase encoded by hue, amplitude encoded by saturation.
figure(3), clf
hsv(:,:,2) = amplitude/max(max(amplitude));   % saturation varies with amplitude.

subplot(2,1,1), plot(signal), axis([0,ndata,rmin,rmax]), title('signal');
h = subplot(2,1,2); 
if Octave
    imagesc(hsv2rgboctave(hsv));
else
    image(hsv2rgb(hsv));
end

title('scalogram:   phase encoded by hue, amplitude encoded by saturation');
set(h,'YTick',tickLocations);
if ~Octave
  set(h,'YTickLabel',tickValues);
end

ylabel('scale');

if threeD            % Generate 3D plots.
    h = figure(4); clf;
    surfl(amplitude, [30,60]), axis('ij'), view(30,70), box on
    axis([0,ndata,0,nscales,0,max(max(amplitude))]), shading interp, colormap(gray);
    title('amplitude surface'); 
    h = get(h,'CurrentAxes');
    set(h,'YTick',tickLocations);
    if ~Octave    
	set(h,'YTickLabel',tickValues);
    end
    ylabel('scale');

    h = figure(5); clf;
    hsv(:,:,2) = ones(size(amplitude));           % saturation fixed at 1
    warp(amplitude, hsv2rgb(hsv)), axis('ij'), view(30,70), box on, grid on
    title('amplitude surface, phase encoded by hue');
    h = get(h,'CurrentAxes');
    set(h,'YTick',tickLocations);
    if ~Octave    
	set(h,'YTickLabel',tickValues);
    end
    ylabel('scale');
end


%------------------------------------------------------------------
% Function to convert image defined by HSV values to rgb
% Needed for Octave 

function rgbimage = hsv2rgboctave(hsvimage)

    % Code follows Foley, van Dam, Feiner and Hughes  page 593
	
	[rows,cols,depth] = size(hsvimage);
	
	h = hsvimage(:,:,1);
	s = hsvimage(:,:,2);	    
	v = hsvimage(:,:,3);	    	    
	    
	h = h(:); s = s(:); v = v(:);
	
	h = 6*h;
	i = fix((h-eps)*6);
	f = h-i;
	p = v.*(1-s);
	q = v.*(1-s.*f);
	t = v.*(1-(s.*(1-f)));
	
	i0 = find(i==0);
	i1 = find(i==1);
	i2 = find(i==2);
	i3 = find(i==3);
	i4 = find(i==4);
	i5 = find(i==5);
	
	r = zeros(size(h)); 	g = zeros(size(h)); 	b = zeros(size(h)); 
	
	r(i0)=v(i0); r(i1)=q(i1); r(i2)=p(i2); r(i3)=p(i3); r(i4)=t(i4); r(i5)=v(i5);
	g(i0)=t(i0); g(i1)=v(i1); g(i2)=v(i2); g(i3)=q(i3); g(i4)=p(i4); g(i5)=p(i5);	
	b(i0)=p(i0); b(i1)=p(i1); b(i2)=t(i2); b(i3)=v(i3); b(i4)=v(i4); b(i5)=q(i5);	
	
	rgbimage(:,:,1) = reshape(r,rows,cols);
	rgbimage(:,:,2) = reshape(g,rows,cols);
	rgbimage(:,:,3) = reshape(b,rows,cols);	
	
