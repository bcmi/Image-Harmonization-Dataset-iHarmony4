function fim = fftconv2(im,f)
% function fim = fftconv2(im,f)
%
% Convolution using FFT.
% 
% David R. Martin <dmartin@eecs.berkeley.edu>
% March 2003

% wrap the filter around the origin and pad with zeros
padf = zeros(size(im));
r = floor(size(f,1)/2);
padf(1:r+1,1:r+1) = f(r+1:end,r+1:end);
padf(1:r,end-r+1:end) = f(r+2:end,1:r);
padf(end-r+1:end,1:r) = f(1:r,r+2:end);
padf(end-r+1:end,end-r+1:end) = f(1:r,1:r);

% magic
fftim = fft2(im);
fftf = fft2(padf);
fim = real(ifft2(fftim.*fftf));

