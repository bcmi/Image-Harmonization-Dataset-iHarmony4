function [m,theta] = detGM(im,sigma)
% function [m,theta] = detGM(im,sigma)
%
% Compute image gradient magnitude.
%
% INPUT
%	im	Image.
%	sigma	Scale at which to compute image derivatives.
%
% OUTPUT
%	m	Gradient magnitude.
%	theta	Orientation of gradient + pi/2 
%		(i.e. edge orientation).
%
% David R. Martin <dmartin@eecs.berkeley.edu>
% March 2003

if isrgb(im), im=rgb2gray(im); end
idiag = norm(size(im));

if nargin<2, sigma=2; end
sigma = max(0.5,sigma);

% compute x and y image derivatives
% use elongated Gaussian derivative filters
fb = cell(2,1);
fb{1} = oeFilter(sigma*[1 1],3,pi/2,1);
fb{2} = fb{1}';
fim = fbRun(fb,im);
dx = fim{1};
dy = fim{2};

% compute gradient magnitude and orientation
m = sqrt( dx.^2 + dy.^2 );
theta = mod(atan2(dy,dx)+pi/2,pi);
