function [e0,e1,theta] = det2MM(im,sigmaI,sigmaO)
% function [e0,e1,theta] = det2MM(im,sigmaI,sigmaO)
%
% Compute the eigenspectrum of the spatially averaged second moment
% matrix.
%
% INPUT
%	im	Image.
%	sigmaI	Inner scale (sigma for image derivatives).
%	sigmaO	Outer scale (sigma for spatial averaging).
%
% OUTPUT
%	e0,e1	Smaller,larger eigenvalues.
%	theta	Orientation of fist eigenvector + pi/2
%		(i.e. orientation of possible edge).
%
% David R. Martin <dmartin@eecs.berkeley.edu>
% March 2003

if ndims(im)>2, im = rgb2gray(im); end;
idiag = norm(size(im));

if nargin<2, sigmaI=2; end
if nargin<3, sigmaO=sigmaI; end % Scott Konishi says this is close
                                % to optimal.
sigmaI = max(0.5,sigmaI);
sigmaO = max(0.5,sigmaO);

% compute x and y image derivatives at inner scale
fb = cell(2,1);
fb{1} = oeFilter(sigmaI,3,pi/2,1);
fb{2} = fb{1}';
fim = fbRun(fb,im);
dx = fim{1};
dy = fim{2};

% compute smoothed squared image derivatives at outer scale
f = oeFilter(sigmaO,3);
dx2 = applyFilter(f,dx.^2);
dy2 = applyFilter(f,dy.^2);
dxy = applyFilter(f,dx.*dy);

% compute eigenvalues of the spatially averaged 2nd moment matrix
% and the orientations of the eigenvectors
k = sqrt( (dx2-dy2).^2 + 4.*dxy.^2 );
eig0 = (dx2 + dy2 - k) / 2;
eig1 = (dx2 + dy2 + k) / 2;
t0 = atan2( dx2-eig0, -dxy );
t1 = atan2( dx2-eig1, -dxy );

% order eigenvalues by their absolute value, so e0<=e1, and pick
% out the orientation corresponding to the largest eigenvalue
x = (abs(eig1) > abs(eig0));
e0 = abs(eig0.*x + eig1.*~x);
e1 = abs(eig1.*x + eig0.*~x);
theta = t1.*x + t0.*~x;
theta = mod(theta+pi/2,pi);

% check postconditions
if any(e0>e1), error('e0>e1'); end
