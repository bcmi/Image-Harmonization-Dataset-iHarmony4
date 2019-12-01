function [a,b,c] = fitparab(z,ra,rb,theta)
% function [a,b,c] = fitparab(z,ra,rb,theta)
%
% Fit cylindrical parabolas to elliptical patches of z at each
% pixel.  
%
% INPUT
%	z	Values to fit.
%	ra,rb	Radius of elliptical neighborhood, ra=major axis.
%	theta	Orientation of fit (i.e. of minor axis).
%
% OUTPUT
%	a,b,c	Coefficients of fit: a + bx + cx^2
%
% David R. Martin <dmartin@eecs.berkeley.edu>
% March 2003

ra = max(1.5,ra);
rb = max(1.5,rb);
ira2 = 1 / ra^2;
irb2 = 1 / rb^2;
wr = floor(max(ra,rb));
sint = sin(theta);
cost = cos(theta);

% compute the interior quickly with convolutions
a = savgol(z,2,1,ra,rb,theta);
if nargout>1, b = savgol(z,2,2,ra,rb,theta); end
if nargout>2, c = savgol(z,2,3,ra,rb,theta); end

% re-compute the border, since the convolution screws it up
[h,w] = size(z);
for x = 1:w,
  for y = 1:h,
    if x>wr & x<=w-wr & y>wr & y<=h-wr, continue; end
    d0=0; d1=0; d2=0; d3=0; d4=0;
    v0=0; v1=0; v2=0;
    for u = -wr:wr,
      xi = x + u;
      if xi<1 | xi>w, continue; end
      for v = -wr:wr,
        yi = y + v;
        if yi<1 | yi>h, continue; end
        di = -u*sint + v*cost; % distance along major axis
        ei = u*cost + v*sint; % distance along minor axis (at theta)
        if di*di*ira2 + ei*ei*irb2 > 1, continue; end
        zi = z(yi,xi);
        di2 = di*di;
        d0 = d0 + 1;
        d1 = d1 + di;
        d2 = d2 + di2;
        d3 = d3 + di*di2;
        d4 = d4 + di2*di2;
        v0 = v0 + zi;
        v1 = v1 + zi*di;
        v2 = v2 + zi*di2;
      end
    end
    
    % much faster to do 3x3 matrix inverse manually
    detA = -d2*d2*d2 + 2*d1*d2*d3 - d0*d3*d3 - d1*d1*d4 + d0*d2*d4;
    invA = [-d3*d3+d2*d4  d2*d3-d1*d4 -d2*d2+d1*d3 ; ...
            d2*d3-d1*d4 -d2*d2+d0*d4  d1*d2-d0*d3 ; ...
            -d2*d2+d1*d3  d1*d2-d0*d3 -d1*d1+d0*d2 ] / (detA + eps);
    param = invA * [ v0 ; v1 ; v2 ];

    a(y,x) = param(1);
    if nargout>1, b(y,x) = param(2); end
    if nargout>2, c(y,x) = param(3); end
  end
end

