%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function [L,alpha,beta] = lms2lalphabeta(L,M,S)
%  Converts an image in RGB format to the LMS format, as described in 
%  http://en.wikipedia.org/wiki/LMS_Color_Space
% 
% Input parameters:
%
% Output parameters:
%   
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [L,alpha,beta] = lms2lalphabeta(L,M,S)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if (nargin == 1)
  S = double(L(:,:,3));
  M = double(L(:,:,2));
  L = double(L(:,:,1));
end

[m, n] = size(S);

T = [1/sqrt(3) 0 0; 0 1/sqrt(6) 0; 0 0 1/sqrt(2)] * [1 1 1; 1 1 -2; 1 -1 0];

res = T * log([L(:)'; M(:)'; S(:)']);

L = reshape(res(1,:), m, n);
alpha= reshape(res(2,:), m, n);
beta = reshape(res(3,:), m, n);

if ((nargout == 1) || (nargout == 0))
  L = cat(3,L,alpha,beta);
end