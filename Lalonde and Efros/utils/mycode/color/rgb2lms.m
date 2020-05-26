%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function [L,M,S] = rgb2lms(R,G,B)
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

if (nargin == 1)
  B = double(R(:,:,3));
  G = double(R(:,:,2));
  R = double(R(:,:,1));
end

if ((max(max(R)) > 1.0) | (max(max(G)) > 1.0) | (max(max(B)) > 1.0))
  R = R/255;
  G = G/255;
  B = B/255;
end


