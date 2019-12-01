function [xmin, fmin] = golden(npd, f, ax, bx, cx, tol, varargin)
%
%GOLDEN   Minimize function of one variable using golden section search
%
%   [xmin, fmin] = golden(npd, f, ax, bx, cx, tol) computes a local minimum
%   of f. xmin is the computed local minimizer of f and fmin is
%   f(xmin). xmin is computed to an relative accuracy of TOL.
%
%   The parameters ax, bx and cx must satisfy the following conditions:
%   ax < bx < cx, f(bx) < f(ax) and f(bx) < f(cx).
%
%   xmin satisfies ax < xmin < cx. golden is guaranteed to succeed if f
%   is continuous between ax and cx
%
%   Roman Geus, ETH Zuerich, 9.12.97
%
%   ATI -- added "npd" argument & made private to KDE class
C = (3-sqrt(5))/2;
R = 1-C;
 
x0 = ax;
x3 = cx;
if (abs(cx-bx) > abs(bx-ax)),
  x1 = bx;
  x2 = bx + C*(cx-bx);
else
  x2 = bx;
  x1 = bx - C*(bx-ax);
end
f1 = feval(f,x1,npd,varargin{:});
f2 = feval(f,x2,npd,varargin{:});
 
k = 1;
while abs(x3-x0) > tol*(abs(x1)+abs(x2)),
%  fprintf(1,'k=%4d, |a-b|=%e\n', k, abs(x3-x0));
  if f2 < f1,
    x0 = x1;
    x1 = x2;
    x2 = R*x1 + C*x3;   % x2 = x1+c*(x3-x1)
    f1 = f2;
    f2 = feval(f,x2,npd,varargin{:});
  else
    x3 = x2;
    x2 = x1;
    x1 = R*x2 + C*x0;   % x1 = x2+c*(x0-x2)
    f2 = f1;
    f1 = feval(f,x1,npd,varargin{:});
  end
  k = k+1;
  
%  [x0,x1,x2,x3,f1,f2]
end
 
if f1 < f2,
  xmin = x1;
  fmin = f1;
else
  xmin = x2;
  fmin = f2;
end
