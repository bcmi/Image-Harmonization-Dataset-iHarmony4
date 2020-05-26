function [pb,theta] = pbTG(im,radius,norient)
% function [pb,theta] = pbTG(im,radius,norient)
%
% Compute probability of boundary using TG.
%
% David R. Martin <dmartin@eecs.berkeley.edu>
% April 2003

if nargin<2, radius=0.02; end
if nargin<3, norient=8; end

% beta from logistic fits (trainTG.m)
if radius==0.02, % 64 textons
  beta = [ -4.7151584e+00  1.2222425e+00 ];
  fstd = [  1.0000000e+00  1.9171689e-01 ];
  beta = beta ./ fstd;
else
  error(sprintf('no parameters for radius=%g\n',radius));
end

% get gradients
[tg,gtheta] = detTG(im,radius,norient);

% compute oriented pb
[h,w,unused] = size(im);
pball = zeros(h,w,norient);
for i = 1:norient,
  t = tg(:,:,i); t = t(:);
  x = [ones(size(t)) t];
  pbi = 1 ./ (1 + (exp(-x*beta')));
  pball(:,:,i) = reshape(pbi,[h w]);
end

% nonmax suppression and max over orientations
[unused,maxo] = max(pball,[],3);
pb = zeros(h,w);
theta = zeros(h,w);
r = 2.5;
for i = 1:norient,
  mask = (maxo == i);
  a = fitparab(pball(:,:,i),r,r,gtheta(i));
  pbi = nonmax(max(0,a),gtheta(i));
  pb = max(pb,pbi.*mask);
  theta = theta.*~mask + gtheta(i).*mask;
end
pb = max(0,min(1,pb));

% mask out 1-pixel border where nonmax suppression fails
pb(1,:) = 0;
pb(end,:) = 0;
pb(:,1) = 0;
pb(:,end) = 0;
