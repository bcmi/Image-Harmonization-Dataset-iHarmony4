function [r,g,b] = CalcIllumColor(mired, tint, Y)	
%mired: IN
%tint : IN
% Y   : IN

[x, y]  = Calcxy_byMiredAndTint(mired, tint);
%disp( sprintf('CalcIllumColor: x = %f, y= %f', x, y) );

% xyY 2 XYZ
X = Y/y * x;
Y = Y;
Z = Y/y * (1-x-y);

% XYZ 2 rgb
[r,g,b] = xyz2rgb(X,Y,Z, 'D65/2', 'srgb');
%disp( sprintf('CalcIllumColor: r = %f, g= %f, b=%f', r, g, b) );


