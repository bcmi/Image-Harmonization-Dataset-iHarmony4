function varargout = rgb2xyz(varargin)
% Converts RGB to XYZ data.
%
%   img = rgb2xyz(img)
%   vec = rgb2xyz(vec)
%   [x,y,z] = rgb2xyz(r, g, b)
%
% Takes in image, vector (3xN) or independent channels.
%
% See https://en.wikipedia.org/wiki/CIE_1931_color_space
%
% ----------
% Jean-Francois Lalonde

[R,G,B,type] = parseColorInput(varargin{:});

M = [0.412453 0.357580 0.180423; 0.212671 0.715160 0.072169; 0.019334 0.119193 0.950227];
res = M * [R(:)'; G(:)'; B(:)'];

varargout = parseColorOutput(res(1,:), res(2,:), res(3,:), type, varargin{:});
