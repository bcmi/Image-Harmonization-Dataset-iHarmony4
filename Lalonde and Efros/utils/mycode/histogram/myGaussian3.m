%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function h = myGaussian3(N, Sigma)
%   Returns a 3D gaussian lowpass filter with standard deviation Sigma. Sigma can be a scalar or a
%   3x3 matrix.
% 
% Input parameters:
%   - N: filter dimensions (scalar or 1x3 matrix)
%   - Sigma: Standard deviation (scalar) or covariance matrix (3x3 matrix)
%
% Output parameters:
%   - h: filter
%    
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function h = myGaussian3(N, Sigma) 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Check input arguments
if ~(all(size(N)==[1 1]) || all(size(N)==[1 3])),
    error(id('InvalidFirstInput'), 'N must be a scalar or a 1-by-3 size vector.');
end
if ~(all(size(Sigma)==[1 1]) || all(size(Sigma)==[3 3]))
    error(id('InvalidFirstInput'), 'Sigma must be a scalar or a 3-by-3 size matrix.');
end
if length(N) == 1, siz = [N N N]; else siz = N; end
if length(Sigma) == 1, sig = eye(3).*Sigma.^2; else sig = Sigma; end

% build the kernel
[x,y,z] = meshgrid(-(siz(2)-1)/2:(siz(2)-1)/2, -(siz(1)-1)/2:(siz(1)-1)/2, -(siz(3)-1)/2:(siz(3)-1)/2);
h = exp(-([x(:) y(:) z(:)] * inv(sig) * [x(:) y(:) z(:)]')./2);
h = reshape(diag(h), siz);
h = h/sum(h(:));
