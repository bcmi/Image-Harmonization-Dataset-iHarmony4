%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function [L,alpha,beta] = rgblalphabeta(R,G,B)
%  Converts an image in RGB format to the L-alpha-beta, as described in 
%  http://isg.cs.tcd.ie/campfire/erikreinhard2.html
% 
% Input parameters:
%
% Output parameters:
%   
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [L,alpha,beta] = rgb2lalphabeta(R,G,B)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if (nargin == 1)
    B = R(:,:,3);
    G = R(:,:,2);
    R = R(:,:,1);
end

[X,Y,Z] = rgb2xyz(R,G,B);
[L,M,S] = xyz2lms(X,Y,Z);
[L,alpha,beta] = lms2lalphabeta(L,M,S);

if ((nargout == 1) || (nargout == 0))
  L = cat(3,L,alpha,beta);
end