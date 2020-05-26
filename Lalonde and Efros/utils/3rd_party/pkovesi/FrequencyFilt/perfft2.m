% PERFFT2  2D Fourier transform of Moisan's periodic image component
%
% Usage: [P, S, p, s] = perfft2(im)
%
% Argument:  im - Image to be transformed
% Returns:    P - 2D fft of periodic image component
%             S - 2D fft of smooth component
%             p - Periodic component (spatial domain)
%             s - Smooth component (spatial domain)
%
% Moisan's "Periodic plus Smooth Image Decomposition" decomposes an image 
% into two components
%        im = p + s
% where s is the 'smooth' component with mean 0 and p is the 'periodic'
% component which has no sharp discontinuities when one moves cyclically across
% the image boundaries.  
%
% This wonderful decomposition is very useful when one wants to obtain an FFT of
% an image with minimal artifacts introduced from the boundary discontinuities.
% The image p gathers most of the image information but avoids periodization
% artifacts.
%
% The typical use of this function is to obtain a 'periodic only' fft of an
% image 
%   >>  P = perfft2(im);
%
% Displaying the amplitude spectrum of P will yield a clean spectrum without the
% typical vertical-horizontal 'cross' arising from the image boundaries that you
% would normally see.
%
% The computational cost of obtaining the 'periodic only' FFT involves taking an
% additional FFT.
%
%
% Reference: 
% This code is adapted from Lionel Moisan's Scilab function 'perdecomp.sci' 
% "Periodic plus Smooth Image Decomposition" 07/2012 avalailable at
%
%   http://www.mi.parisdescartes.fr/~moisan/p+s
%
% Paper:
% L. Moisan, "Periodic plus Smooth Image Decomposition", Journal of
% Mathematical Imaging and Vision, vol 39:2, pp. 161-179, 2011.

% Peter Kovesi
% Centre for Exploration Targeting
% The University of Western Australia
% peter.kovesi at uwa edu au
% September 2012

function [P, S, p, s] = perfft2(im)
    
    if ~isa(im, 'double'), im = double(im); end
    [rows,cols] = size(im);
    
    % Compute the boundary image which is equal to the image discontinuity
    % values across the boundaries at the edges and is 0 elsewhere
    s = zeros(size(im));
    s(1,:)   = im(1,:) - im(end,:);
    s(end,:) = -s(1,:);
    s(:,1)   = s(:,1)   + im(:,1) - im(:,end);
    s(:,end) = s(:,end) - im(:,1) + im(:,end);
    
    % Generate grid upon which to compute the filter for the boundary image in
    % the frequency domain.  Note that cos() is cyclic hence the grid values can
    % range from 0 .. 2*pi rather than 0 .. pi and then pi .. 0
    [cx, cy] = meshgrid(2*pi*[0:cols-1]/cols, 2*pi*[0:rows-1]/rows);    
    
    % Generate FFT of smooth component
    S = fft2(s)./(2*(2 - cos(cx) - cos(cy)));
    
    % The (1,1) element of the filter will be 0 so S(1,1) may be Inf or NaN
    S(1,1) = 0;          % Enforce 0 mean 

    P = fft2(im) - S;    % FFT of periodic component

    if nargout > 2       % Generate spatial domain results 
        s = real(ifft2(S)); 
        p = im - s;         
    end
    
