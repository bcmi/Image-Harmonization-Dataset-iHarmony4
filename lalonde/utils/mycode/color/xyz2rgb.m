function [R,G,B] = xyz2rgb(X,Y,Z)
% Converts XYZ to RGB data.
%
%   rgb = xyz2rgb(xyz)
% 
% Converts between images.
%
%   [r, g, b] = xyz2rgb(x, y, z)
%
% Converts between individual channels.
%
% See http://en.wikipedia.org/wiki/CIE_1931_Color_Space
%
% ----------
% Jean-Francois Lalonde

if (nargin == 1)
    Z = X(:,:,3);
    Y = X(:,:,2);
    X = X(:,:,1);
end

[m, n] = size(X);

M = [3.2404813 -1.5371515 -0.4985363; -0.9692549 1.8759900 0.0415559; 0.05564663 -0.20404133 1.0573110];
   
res = M * [X(:)'; Y(:)'; Z(:)'];

R = reshape(res(1,:), m, n);
G = reshape(res(2,:), m, n);
B = reshape(res(3,:), m, n);

if nargout == 1
    R = cat(3,R,G,B);
end