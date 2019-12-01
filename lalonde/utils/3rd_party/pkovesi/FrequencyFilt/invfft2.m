% INVFFT2 - takes inverse fft and returns real part
%
% Function to `wrap up' taking the inverse Fourier transform
% and extracting the real part into the one operation

% Peter Kovesi  October 1999

function ift = invfft2(ft)
ift = real(ifft2(ft));
