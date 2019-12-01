function [tg,theta] = tgmo2(tmap,ntex,radius,norient,varargin)
% function [tg,theta] = tgmo2(tmap,ntex,radius,norient,...)
%
% Compute the texture gradient at a single scale and multiple
% orientations.
%
% INPUT
%	tmap		Texton map, values in [1,ntex].
%	ntex		Number of textons.
%	radius		Radius of disc for texture gradient.
%	norient		Number of orientation at which to compute 
%			the texture gradient.
%	'smooth'	Smoothing method, one of 
%			{'gaussian','savgol','none'}, default 'none'.
%	'sigma'		Sigma for smoothing, default to radius.
%	'tsim'		Texton similarity matrix.  If not 
%			provided, then use chi-squared.
%
% OUTPUT
%	tg		Size [h w norient] array of tg images.
%	theta		Vector of disc orientations (which are 
%			orthogonal to the texture gradient).
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
norient = max(1,norient);
theta = (0:norient-1)/norient*pi;

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
gamma = mod(atan2(v,u),2*pi);
mask = (u.^2 + v.^2 <= radius^2);
mask(wr+1,wr+1) = 0; % mask out center pixel to remove bias
count = sum(mask(:));

% determine which pie slice each pixel falls into
% 0=masked [1,2*norient]=slice
slice = 1 + floor(gamma/(pi/norient));
slice = slice .* mask;

[h,w] = size(tmap);
tg = zeros(h,w,norient);
fwrite(2,'[');
for x = 1:w,
  fwrite(2,'.');
  for y = 1:h,
    pie = zeros(ntex,2*norient);
    for u = -wr:wr,
      xi = x + u;
      if xi<1 | xi>w, continue; end
      for v = -wr:wr,
        yi = y + v;
        if yi<1 | yi>h, continue; end
        s = slice(v+wr+1,u+wr+1);
        if s==0, continue; end % masked out
        t = tmap(yi,xi);
        pie(t,s) = pie(t,s) + 1;
      end
    end
    pie = pie .* (2/count); % normalize
    % initialize left/right histograms
    lhist = sum(pie(:,1:norient),2);
    rhist = sum(pie(:,norient+1:end),2);
    % spin the disc to compute tg at each orientation
    for i = 1:norient,
      if usechi2,
        chi = (lhist-rhist).^2 ./ (lhist+rhist+eps);
        tg(y,x,i) = 0.5*sum(chi);
      else
        lrdiff = abs(lhist-rhist);
        tg(y,x,i) = lrdiff' * tsim * lrdiff;
      end
      if i<norient,
        inc = pie(:,norient+i) - pie(:,i);
        lhist = lhist + inc;
        rhist = rhist - inc;
      end
    end
  end
end
fprintf(2,']\n');

for i = 1:norient,
  switch smooth,
   case 'gaussian',
    f = oeFilter([sigma .5],3,theta(i)+pi/2);
    tg(:,:,i) = applyFilter(f,tg(:,:,i));
   case 'savgol',
    a = fitparab(tg(:,:,i),sigma,sigma/4,theta(i));
    tg(:,:,i) = max(0,a);
  end
end
