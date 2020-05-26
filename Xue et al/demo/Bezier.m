function [x, y] = Bezier(t, alp) 
%% inplicit curve 
% INPUT:  alp, parameter: 0 - 1
% INPUT:  t, curve parameter, in [0,1]
% OUTPUT: x, y: cardisian coordinates

x0 = 0;     y0 = 0;
x1 = alp; y1 = 1-alp; 
x2 = 1;     y2 = 1;

x = (1-t).^2 *x0 + 2*(1-t).*t*x1 + t.^2 *x2;
y = (1-t).^2 *y0 + 2*(1-t).*t*y1 + t.^2 *y2;