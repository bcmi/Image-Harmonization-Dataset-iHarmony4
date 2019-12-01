function [c] = savgol(z,d,k,ra,rb,theta)
% function [c] = savgol(z,d,k,ra,rb,theta)
%
% Directional 2D Savitsky-Golay filtering with elliptical support.
% The computation is done with a convolution, so the boundary of the
% output will be biased.  The boundary is of size floor(max(ra,rb)).
%
% INPUT
%	z	Values to fit.
%	d	Degree of fit, usually 2 or 4.
%	k	Coefficient to return in [1,d+1], 1 for smoothing.
%	ra,rb	Radius of elliptical neighborhood, ra=major axis.
%	theta	Orientation of fit (i.e. of minor axis).
%
% OUTPUT
%	c	Coefficient of fit.
%
% David R. Martin <dmartin@eecs.berkeley.edu>
% March 2003

if d<0, error('d is invalid'); end
if k<1 | k>d+1, error('k is invalid'); end

ra = max(1.5,ra);
rb = max(1.5,rb);
ira2 = 1 / ra^2;
irb2 = 1 / rb^2;
wr = floor(max(ra,rb));
wd = 2*wr+1;
sint = sin(theta);
cost = cos(theta);

% 1. compute linear filters for coefficients
% (a) compute inverse of least-squares problem matrix
filt = zeros(wd,wd,d+1);
xx = zeros(2*d+1,1);
for u = -wr:wr,
  for v = -wr:wr,
    ai = -u*sint + v*cost; % distance along major axis
    bi = u*cost + v*sint; % distance along minor axis
    if ai*ai*ira2 + bi*bi*irb2 > 1, continue; end % outside support
    xx = xx + cumprod([1;ai+zeros(2*d,1)]);
  end
end
A = zeros(d+1,d+1);
for i = 1:d+1, 
  A(:,i) = xx(i:i+d); 
end
A = inv(A);
% (b) solve least-squares problem for delta function at each pixel
for u = -wr:wr,
  for v = -wr:wr,
    zz = zeros(wd);
    zz(v+wr+1,u+wr+1) = 1;
    yy = zeros(d+1,1);
    ai = -u*sint + v*cost; % distance along major axis
    bi = u*cost + v*sint; % distance along minor axis
    if ai*ai*ira2 + bi*bi*irb2 > 1, continue; end % outside support
    yy = cumprod([1;ai+zeros(d,1)]);
    filt(v+wr+1,u+wr+1,:) = A*yy;
  end
end

% 2. apply the filter to get the fit coefficient at each pixel
c = conv2(z,filt(:,:,k),'same');

