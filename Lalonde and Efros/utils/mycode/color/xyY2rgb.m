%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function rgb = xyY2rgb(xyY, doClamp)
%  Converts an image in xyY format to the RGB format, as described in 
%  http://en.wikipedia.org/wiki/CIE_1931_Color_Space
% 
% Input parameters:
%   - xyY: input image (3 channels) in the xyY color space
%   - doClamp: 0 or [1], clamps the output in the [0,1] range. If not,
%       linearly extrapolates the values of rgb
%
% Output parameters:
%   
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function rgb = xyY2rgb(xyY, doClamp)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2009 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% default value: clamp to the [0,1] interval
if nargin == 1
    doClamp = 1;
end

% first convert to XYZ
x = xyY(:,:,1);
y = xyY(:,:,2);
Y = xyY(:,:,3);

X = x.* Y./y;
Z = Y./y - X - Y;

% special case: completely black!
indZero = (y == 0);
X(indZero) = 0;
Y(indZero) = 0;
Z(indZero) = 0;

xyz = cat(3, X, Y, Z);

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

