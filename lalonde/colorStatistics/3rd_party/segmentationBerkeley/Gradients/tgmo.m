function [tg,theta] = tgmo(tmap,ntex,radius,norient,varargin)
% function [tg,theta] = tgmo(tmap,ntex,radius,norient,...)
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

[h,w] = size(tmap);
tg = zeros(h,w,norient);
fwrite(2,'[');
for i = 1:norient,
  fwrite(2,'.');
  if usechi2,
    tg(:,:,i) = tgso(tmap,ntex,radius,theta(i),...
                     'smooth',smooth,'sigma',sigma);
  else
    tg(:,:,i) = tgso(tmap,ntex,radius,theta(i),...
                     'smooth',smooth,'sigma',sigma,'tsim',tsim);
  end
end
fwrite(2,sprintf(']\n'));
