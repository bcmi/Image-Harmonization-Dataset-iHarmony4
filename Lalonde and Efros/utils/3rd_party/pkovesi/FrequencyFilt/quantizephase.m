% QUANTIZEPHASE Quantize phase values in an image
%
% Usage:  qim = quantizephase(im, N)
%
% Arguments:  im - Image to be processed
%              N - Desired number of quantized phase values 
%
% Returns:  qim - Phase quantized image
%
% Phase values in an image are important.  However, despite this, they can be
% quantized very heavily with little perceptual loss.  The value of N can be
% as low as 4, or even 3!  Using N = 2 is also worth a look.
%
% 

% Copyright (c) 2011 Peter Kovesi
% Centre for Exploration Targeting
% The University of Western Australia
% http://www.csse.uwa.edu.au/~pk/research/matlabfns/
% 
% Permission is hereby  granted, free of charge, to any  person obtaining a copy
% of this software and associated  documentation files (the "Software"), to deal
% in the Software without restriction, subject to the following conditions:
% 
% The above copyright notice and this permission notice shall be included in all
% copies or substantial portions of the Software.
% 
% The software is provided "as is", without warranty of any kind.

% May 2011

function qim = quantizephase(im, N)
    
    IM = fft2(im);
    amp = abs(IM);
    phase = angle(IM);
    
    % Quantize the phase values as follows:
    % Add pi - .001 so that values range [0 - 2pi)
    % Divide by 2pi so that values range [0 - 1)
    % Scale by N so that values range [0 - N)
    % Round twoards 0 using fix giving integers [0 - N-1]
    % Scale by 2*pi/N to give N discrete phase values  [0 - 2*pi)
    % Subtract pi so that discrete values range [-pi - pi)
    % Add pi/N to counteract the phase shift induced by rounding towards 0
    % using fix.
    phase = fix( (phase+pi-.001)/(2*pi) * N) * (2*pi)/N - pi  + pi/N ;
    % figure, hist(phase(:),100)

    % Reconstruct Fourier transform with quantized phase values and take inverse
    % to obtain the new image.
    QIM = amp.*(cos(phase) + i*sin(phase));
    qim = real(ifft2(QIM));  
    
