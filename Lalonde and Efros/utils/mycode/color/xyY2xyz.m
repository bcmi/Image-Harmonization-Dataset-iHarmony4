function [X, Y, Z] = xyY2xyz(x, y, Y)
% Converts xyY to XYZ data.
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

if nargin == 1
    Y = x(:,:,3);
    y = x(:,:,2);
    x = x(:,:,1);
end

% first convert to XYZ
% x = xyY(:,:,1);
% y = xyY(:,:,2);
% Y = xyY(:,:,3);

X = x.*Y./y;
Z = Y./y.*(1 - x - y);

% special case: completely black!
indZero = (y == 0);
X(indZero) = 0;
Y(indZero) = 0;
Z(indZero) = 0;

% R = reshape(res(1,:), m, n);
% G = reshape(res(2,:), m, n);
% B = reshape(res(3,:), m, n);

if nargout == 1
    X = cat(3, X, Y, Z);
end

% xyz = cat(3, X, Y, Z);





return;




% then convert to rgb
cTrans = makecform('xyz2srgb');

if ~doClamp
    mat = [cTrans.cdata.MatTRC.RedColorant;
        cTrans.cdata.MatTRC.GreenColorant;
        cTrans.cdata.MatTRC.BlueColorant];
    rgb = reshape(xyz, size(x,1)*size(x,2), 3) * inv(mat);

    % remove negative values
    rgb = max(rgb, 0);

    % "hallucinate" HDR by linearly extrapolating outside the [0,1] range
    TRC = cell(1, 3);
    TRC{1} = double(cTrans.cdata.MatTRC.RedTRC);
    TRC{2} = double(cTrans.cdata.MatTRC.GreenTRC);
    TRC{3} = double(cTrans.cdata.MatTRC.BlueTRC);
    out = zeros(size(rgb));
    for i = 1 : 3
        out(:,i) = interp1(TRC{i}./max(TRC{i}), linspace(0,1,length(TRC{i})), rgb(:,i), 'linear', 'extrap');
    end
    rgb = reshape(out, size(x,1), size(x,2), 3);

else
    % applycform clamps in [0,1] interval and applies non-linearity from XYZ to RGB
    rgb = applycform(xyz, cTrans);
end

