%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function [L,M,S] = xyz2lms(X,Y,Z)
%  Converts an image in RGB format to the LMS format, as described in 
%  http://en.wikipedia.org/wiki/LMS_Color_Space
% 
% Input parameters:
%
% Output parameters:
%   
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [L,M,S] = xyz2lms(X,Y,Z)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if (nargin == 1)
  Z = double(X(:,:,3));
  Y = double(X(:,:,2));
  X = double(X(:,:,1));
end

[m, n] = size(X);

T = [0.3897 0.6890 -0.0787; -0.2298 1.1834 0.0464; 0 0 1];

res = T * [X(:)'; Y(:)'; Z(:)'];

L = reshape(res(1,:), m, n);
M = reshape(res(2,:), m, n);
S = reshape(res(3,:), m, n);

if ((nargout == 1) || (nargout == 0))
  L = cat(3,L,M,S);
end