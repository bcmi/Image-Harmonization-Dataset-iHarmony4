function LAB = rgb2lab(RGB)

% LAB = rgb2lab(RGB)
%
% This uses the following color space conversion: Reinhard01CGA_color.
% Both LAB and RGB are nx3 matrix of double values. RGB range is [0,1].
%
% Wei Xu
% July 2009

% from rgb to linear lms
% this transform maps the RGB white (RGB=(1,1,1)) to XYZ white
% (XYZ=(1,1,1)).

M1 = [0.3811 0.5783 0.0402;
      0.1967 0.7244 0.0782;
      0.0241 0.1288 0.8444];
LMS = (M1 * RGB')';

% conver from linear space to log10 space
log_LMS = log10(LMS);

% from lms to lab
M2 = diag([1/sqrt(3) 1/sqrt(6) 1/sqrt(2)]) * [1 1 1; 1 1 -2; 1 -1 0];
LAB = (M2 * log_LMS')';

