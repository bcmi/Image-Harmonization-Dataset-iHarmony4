function [tg] = tgso(tmap,ntex,radius,theta,varargin)
% function [tg] = tgso(tmap,ntex,radius,theta,...)
%
% Compute the texture gradient at a single orientation and scale.
%
% INPUT
%	tmap		Texton map, values in [1,ntex].
%	ntex		Number of textons.
%	radius		Radius of disc for tg.
%	theta		Orientation orthogonal to tg.
%	'smooth'	Smoothing method, one of 
%			{'gaussian','savgol','none'}, default 'none'.
%	'sigma'		Sigma for smoothing, default to radius.
%	'tsim'		Texton similarity matrix.  If not 
%			provided, then use chi-squared.
%
% OUTPUT
%	tg		The tg image.
%
% David R. Martin <dmartin@eecs.berkeley.edu>
% March 2003

% process options
smooth = 'none';
sigma = radius;
usechi2 = true;
for i = 1:2:numel(varargin),
  opt = varargin{i};
  if ~ischar(opt), error('option names not a string'); end
  if i==numel(varargin), error(sprintf('option ''%s'' has no value',opt)); end
  val = varargin{i+1};
  switch opt,
   case 'smooth',
    switch val,
     case {'none','gaussian','savgol'}, smooth=val;
     otherwise, error(sprintf('invalid option smooth=''%s''',val));
    end
   case 'sigma', sigma=val;
   case 'tsim', tsim=val; usechi2=false;
   otherwise, error(sprintf('invalid option ''%s''',opt));
  end
end

radius = max(1,radius);
theta = mod(theta,pi);

% check texton labels
if any(tmap~=round(tmap)),
  error('texton labels not integral');
end
if min(tmap(:)) < 1 | max(tmap(:))>ntex, 
  error(sprintf('texton labels out of range [1,%d]',ntex)); 
end

% radius of discrete disc
wr = floor(radius);

% count number of pixels in a disc
[u,v] = meshgrid(-wr:wr,-wr:wr);
gamma = atan2(v,u);
mask = (u.^2 + v.^2 <= radius^2);
mask(wr+1,wr+1) = 0; % mask out center pixel to remove bias
count = sum(mask(:));

% determine which half of the disc pixels fall in
% (0=masked 1=left 2=right)
side = 1 + (mod(gamma-theta,2*pi) < pi);
side = side .* mask;
if sum(sum(side==1)) ~= sum(sum(side==2)), error('bug:inbalance'); end
lmask = (side==1)/count*2;
rmask = (side==2)/count*2;

% compute tg using 2*ntex convolutions
if usechi2,
  tg = zeros(size(tmap));
  for i = 1:ntex,
    im = (tmap==i);
    tgL = conv2(im,lmask,'same');
    tgR = conv2(im,rmask,'same');
    tg = tg + sum((tgL-tgR).^2./(tgL+tgR+eps),3);
  end
  tg = 0.5 * tg;
else
  [h,w] = size(tmap);
  d = zeros(h*w,ntex);
  for i = 1:ntex,
    im = (tmap==i);
    tgL = conv2(im,lmask,'same');
    tgR = conv2(im,rmask,'same');
    d(:,i) = reshape(abs(tgL-tgR),h*w,1);
  end
  tg = sum((d*tsim).*d,2);
  tg = reshape(tg,h,w);
end

switch smooth,
 case 'gaussian',
  f = oeFilter([sigma .5],3,theta+pi/2);
  tg = applyFilter(f,tg);
 case 'savgol',
  a = fitparab(tg,sigma,sigma/4,theta);
  tg = max(0,a);
end

