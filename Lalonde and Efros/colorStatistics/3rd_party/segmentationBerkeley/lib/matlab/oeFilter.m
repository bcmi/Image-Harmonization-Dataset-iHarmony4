function [f] = oeFilter(sigma,support,theta,deriv,hil,vis)
% function [f] = oeFilter(sigma,support,theta,deriv,hil,vis)
%
% Compute unit L1-norm 2D filter.
% The filter is a Gaussian in the x direction.
% The filter is a Gaussian derivative with optional Hilbert
% transform in the y direction.
% The filter is zero-meaned if deriv>0.
%
% INPUTS
%	sigma		Scalar, or 2-element vector of [sigmaX sigmaY].
%	[support]	Make filter +/- this many sigma.
%	[theta]		Orientation of x axis, in radians.
%	[deriv]		Degree of y derivative, one of {0,1,2}.
%	[hil]		Do Hilbert transform in y direction?
%	[vis]		Visualization for debugging?
%
% OUTPUTS
%	f	Square filter.
%
% David R. Martin <dmartin@eecs.berkeley.edu>
% March 2003

nargchk(1,6,nargin);
if nargin<2, support=3; end
if nargin<3, theta=0; end
if nargin<4, deriv=0; end
if nargin<5, hil=0; end
if nargin<6, vis=0; end

if numel(sigma)==1,
  sigma = [sigma sigma];
end
if deriv<0 | deriv>2,
  error('deriv must be in [0,2]');
end

% Calculate filter size; make sure it's odd.
hsz = max(ceil(support*sigma));
sz = 2*hsz + 1;

% Sampling limits.
maxsamples = 1000; % Max samples in each dimension.
maxrate = 10; % Maximum sampling rate.
frate = 10; % Over-sampling rate for function evaluation.

% Cacluate sampling rate and number of samples.
rate = min(maxrate,max(1,floor(maxsamples/sz)));
samples = sz*rate;

% The 2D samping grid.
r = floor(sz/2) + 0.5 * (1 - 1/rate);
dom = linspace(-r,r,samples);
[sx,sy] = meshgrid(dom,dom);

% Bin membership for 2D grid points.
mx = round(sx);
my = round(sy);
membership = (mx+hsz+1) + (my+hsz)*sz;

% Rotate the 2D sampling grid by theta.
su = sx*sin(theta) + sy*cos(theta);
sv = sx*cos(theta) - sy*sin(theta);

if vis,
  figure(1); clf; hold on;
  plot(sx,sy,'.');
  plot(mx,my,'o');
  %plot([sx(:) mx(:)]',[sy(:) my(:)]','k-');
  plot(su,sv,'x');
  axis equal;
  ginput(1);
end

% Evaluate the function separably on a finer grid.
R = r*sqrt(2)*1.01; % radius of domain, enlarged by >sqrt(2)
fsamples = ceil(R*rate*frate); % number of samples
fsamples = fsamples + mod(fsamples+1,2); % must be odd
fdom = linspace(-R,R,fsamples); % domain for function evaluation
gap = 2*R/(fsamples-1); % distance between samples

% The function is a Gaussian in the x direction...
fx = exp(-fdom.^2/(2*sigma(1)^2));
% .. and a Gaussian derivative in the y direction...
fy = exp(-fdom.^2/(2*sigma(2)^2));
switch deriv,
 case 1,
  fy = fy .* (-fdom/(sigma(2)^2));
 case 2,
  fy = fy .* (fdom.^2/(sigma(2)^2) - 1);
end
% ...with an optional Hilbert transform.
if hil,
  fy = imag(hilbert(fy));
end

% Evaluate the function with NN interpolation.
xi = round(su/gap) + floor(fsamples/2) + 1;
yi = round(sv/gap) + floor(fsamples/2) + 1;
f = fx(xi) .* fy(yi);

% Accumulate the samples into each bin.
f = isum(f,membership,sz*sz);
f = reshape(f,sz,sz);

% zero mean
if deriv>0,
  f = f - mean(f(:));
end

% unit L1-norm
sumf = sum(abs(f(:)));
if sumf>0,
  f = f / sumf;
end

