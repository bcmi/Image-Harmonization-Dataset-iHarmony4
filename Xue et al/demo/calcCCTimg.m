function cct_I = calcCCTimg( I )   % in mired = 1e6 / color temp.

% suppose I is already invGamma mapped, sRGB, 3 channel, in [0, 1] (HDR)

XYZ_I   =  rgb2xyz(I, 'srgb', 'D65/2', 'Gamma', 1.0);
xy_I    =  xyz2xy(XYZ_I);
cct_I   =  xy2cct(xy_I);

cct_I   = max(cct_I, 1500);     % clip:  warmest, 1500K
cct_I   = min(cct_I, 20000);    % clip:  coldest, 20,000K

cct_I   = cct_I .^(-1) * 1e6;