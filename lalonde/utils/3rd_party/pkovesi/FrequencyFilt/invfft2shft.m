% INVFFT2SHFT  - takes inverse fft, quadrant shifts and returns real part.
%
% Function to `wrap up' taking the inverse Fourier transform
% quadrant shifting and extraction of the real part into the one operation

% Peter Kovesi  October 1999

function ift = invfft2shft(ft)
ift = fftshift(real(ifft2(ft)));
