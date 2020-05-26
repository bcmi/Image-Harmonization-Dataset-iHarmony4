% ODOT - Demonstrates odot and oslash operators on 1D signal
%
% Usage:  [smooth, energy] = odot(f, K)
%
% Arguments:    f - a 1D signal
%               K - optional 'Weiner' type factor to condition the results
%                   where division by 0 occurs in the 'oslash' operation.
%                   K defaults to 'eps', If oscillations appear in the
%                   plots try increasing the value of K
%
% Returns:     energy - the Local Energy of the signal.
%              smooth - the smooth component of the signal obtained by
%                       performing the 'oslash' operator between the
%                       signal and its Local Energy.
% Plots:
%           Signal            Hilbert Transform of Signal
%           Local Energy      Hilbert Transform of Energy
%           Smooth Component  Reconstruction
%
% Smooth         = signal 'oslash' energy
% Reconstruction = energy  'odot'  smooth
%
% Glitches in the results will be seen at points where the Local Energy
% peaks - these points cause numerical grief.  These problems can be
% alleviated by smoothing the signal slightly and/or increasing the
% parameter K.
%
% This code only works for 1D signals - I am not sure how you would
% implement it for 2D images...

% Reference:  Robyn Owens.  "Feature-Free Images", Pattern Recognition
% Letters. Vol 15. pp 35-44, 1994.

% Copyright (c) 2004 Peter Kovesi
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

% March 2004

function [smooth, energy] = odot(f, K)
    
    if nargin == 1
	K = eps;
    end
    
    N = length(f);
    
    if rem(N,2) > 0  % odd No of elements - trim the last one off to make the
		     % number of elements even for simplicity.
	N = N - 1;
	f = f(1:N);
    end
    
    F = fft(f);
    
    F(1) = 0;                        % Kill DC component
    f = real(ifft(F));               % Reconstruct signal minus DC component
    
    % Perform 90 degree phase shift on the signal by multiplying +ve
    % frequencies of the fft by i and the -ve frequencies by -i, and then
    % inverting. 
    
    phaseshift = [ ones(1,N/2)*i ones(1,N/2)*(-i) ];
    
    % Hilbert Transform of signal
    h = real(ifft(F.*phaseshift));        
    
    energy = sqrt(f.^2 + h.^2);           % Energy
    % Hilbert Transform of Energy
    energyh = real(ifft(fft(energy).*phaseshift)); 
					  
    % smooth = signal 'oslash' energy
    divisor = energy.^2 + energyh.^2;   
    % Where divisor << K,  weinercorrector -> 0/K
    % Where divisor >> K,  weinercorrector -> 1    
    weinercorrector = divisor.^2 ./ ((divisor.^2)+K);
    smooth = (f.*energy + energyh.*h)./divisor .* weinercorrector;
    
    % Hilbert transform of smooth component
    smoothh=real(ifft(fft(smooth).*phaseshift));
    
    % Reconstruction = energy odot smooth
    recon = (smooth.*energy - smoothh.*energyh);     
    
    subplot(3,2,1), plot(f),title('Signal'); 
    subplot(3,2,2), plot(h),title('Hilbert Transform of Signal'); 
    subplot(3,2,3), plot(energy),title('Local Energy'); 
    subplot(3,2,4), plot(energyh),title('Hilbert Transform of  Energy'); 
    subplot(3,2,5), plot(smooth),title('Smooth Component'); 
    subplot(3,2,6), plot(recon),title('Reconstruction'); 