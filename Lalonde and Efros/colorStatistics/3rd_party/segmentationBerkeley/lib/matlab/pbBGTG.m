function [pb,theta] = pbBGTG(im,pres,radius,norient)
% function [pb,theta] = pbBGTG(im,pres,radius,norient)
%
% Compute probability of boundary using BG and TG.
%
% David R. Martin <dmartin@eecs.berkeley.edu>
% April 2003

if nargin<2, pres='gray'; end
if nargin<3, radius=[0.01 0.02]; end
if nargin<4, norient=8; end
if numel(radius)==1, radius=radius*ones(1,2); end

% beta from logistic fits (trainBGTG.m)
if all(radius==[0.01 0.02]), % 64 textons
  if strcmp(pres,'gray'), % trained on grayscale segmentations
    beta = [ -4.6522915e+00  7.1345115e-01  7.0333326e-01 ];
    fstd = [  1.0000000e+00  3.7408935e-01  1.9171689e-01 ];
  elseif strcmp(pres,'color'), % trained on color segmentations
    beta = [ -4.4880396e+00  7.0690368e-01  6.5740193e-01 ];
    fstd = [  1.0000000e+00  3.7401028e-01  1.9181055e-01 ];
  else
    error(sprintf('Unknown presentation: %s',pres));
  end
  beta = beta ./ fstd;
else
  error(sprintf('no parameters for radius=[%g %g]\n',radius(1),radius(2)));
end

% get gradients
[bg,tg,gtheta] = detBGTG(im,radius,norient);

% compute oriented pb
[h,w,unused] = size(im);
pball = zeros(h,w,norient);
for i = 1:norient,
  b = bg(:,:,i); b = b(:);
  t = tg(:,:,i); t = t(:);
  x = [ones(size(b)) b t];
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
