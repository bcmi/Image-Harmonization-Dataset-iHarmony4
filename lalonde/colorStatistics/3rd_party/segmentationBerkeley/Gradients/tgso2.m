function [tg] = tgso2(tmap,ntex,radius,theta,varargin)
% function [tg] = tgso2(tmap,ntex,radius,theta,...)
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

[h,w] = size(tmap);
tg = zeros(h,w);
fwrite(2,'[');
for x = 1:w,
  fwrite(2,'.');
  for y = 1:h,
    hist = zeros(ntex,2);
    for u = -wr:wr,
      xi = x + u;
      if xi<1 | xi>w, continue; end
      for v = -wr:wr,
        yi = y + v;
        if yi<1 | yi>h, continue; end
        s = side(v+wr+1,u+wr+1);
        if s==0, continue; end % masked out
        t = tmap(yi,xi);
        hist(t,s) = hist(t,s) + 1;
      end
    end
    hist = hist .* (2/count); % normalize
    if usechi2,
      chi = (hist(:,1)-hist(:,2)).^2 ./ (hist(:,1)+hist(:,2)+eps);
      tg(y,x) = 0.5*sum(chi);
    else
      lrdiff = abs(hist(:,1)-hist(:,2));
      tg(y,x) = lrdiff' * tsim * lrdiff;
    end
  end
end
fprintf(2,']\n');

switch smooth,
 case 'gaussian',
  f = oeFilter([sigma .5],3,theta+pi/2);
  tg = applyFilter(f,tg);
 case 'savgol',
  a = fitparab(tg,sigma,sigma/4,theta);
  tg = max(0,a);
end

