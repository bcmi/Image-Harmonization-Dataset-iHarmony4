function [cg,theta] = cgmo(im,radius,norient,varargin)
% function [cg] = cgmo(im,radius,norient,...)
%
% Compute the color gradient at a single scale and multiple
% orientations.
%
% INPUT
%	im		Grayscale or RGB image, values in [0,1].
%	radius		Radius of disc for cg.
%	norient		Number of orientations for cg.
%	'nbins'		Number of bins; should be > 1/sigmaSim.
%	'sigmaSim'	For color similarity function.
%	'gamma'		Gamma correction for LAB [2.5].
%	'smooth'	Smoothing method, one of 
%			{'gaussian','savgol','none'}, default 'none'.
%	'sigmaSmo'	Sigma for smoothing, default to radius.
%
% OUTPUT
%	cg		Size [h,w,d,norient] array of cg images,
%			where d is the dimensionality of the image.
%
% The input parameters {radius,nbins,sigmaSim,sigmaSmo} should be
% scalars when the input image is grayscale, and can be either scalars
% or 3-element vectors when the image is RGB.
%
% See also cgmo.
%
% David R. Martin <dmartin@eecs.berkeley.edu>
% April 2003

% process options
nbins = 32;
sigmaSim = 0.1;
gamma = 2.5;
smooth = 'none';
sigmaSmo = radius;
for i = 1:2:numel(varargin),
  opt = varargin{i};
  if ~ischar(opt), error('option names not a string'); end
  if i==numel(varargin), error(sprintf('option ''%s'' has no value',opt)); end
  val = varargin{i+1};
  switch opt,
   case 'nbins', nbins=val;
   case 'sigmaSim', sigmaSim=val;
   case 'gamma', gamma=val;
   case 'smooth',
    switch val,
     case {'none','gaussian','savgol'}, smooth=val;
     otherwise, error(sprintf('invalid option smooth=''%s''',val));
    end
   case 'sigmaSmo', sigmaSmo=val;
   otherwise, error(sprintf('invalid option ''%s''',opt));
  end
end

% check arguments
if ndims(im)==2, % grayscale image
  if numel(radius)~=1, error('radius should have 1 element'); end
  if numel(nbins)~=1, error('nbins should have 1 element'); end
  if numel(sigmaSim)~=1, error('sigmaSim should have 1 element'); end
  if numel(sigmaSmo)~=1, error('sigmaSim should have 1 element'); end
elseif ndims(im)==3, % RGB image
  if numel(radius)==1, radius = radius*ones(3,1); end
  if numel(nbins)==1, nbins = nbins*ones(3,1); end
  if numel(sigmaSim)==1, sigmaSim = sigmaSim*ones(3,1); end
  if numel(sigmaSmo)==1, sigmaSmo = sigmaSmo*ones(3,1); end
  if numel(radius)~=3, error('radius should have 1 or 3 elements'); end
  if numel(nbins)~=3, error('nbins should have 1 or 3 elements'); end
  if numel(sigmaSim)~=3, error('sigmaSim should have 1 or 3 elements'); end
  if numel(sigmaSmo)~=3, error('sigmaSmo should have 1 or 3 elements'); end
  radius = radius(:);
  nbins = nbins(:);
  sigmaSim = sigmaSim(:);
  sigmaSmo = sigmaSmo(:);
else
  error('image not of valid dimension');
end
norient = max(1,norient);
nbins = max(1,nbins);

% min and max values for a,b channels of LAB
% used to scale values into the unit interval
abmin = -73;
abmax = 95;

% make sure nbins is large enough with respect to sigmaSim
if any( nbins < 1./sigmaSim ),
  warning('nbins < 1/sigmaSim is suspect');
end

% check pixel valies
if min(im(:)) < 0 | max(im(:))>1, 
  error('pixel values out of range [0,1]');
end

if ndims(im)==2, % grayscale image

  % compute cg from gray values
  cmap = max(1,ceil(im*nbins));
  csim = colorsim(nbins,sigmaSim);
  [cg,theta] = tgmo(...
      cmap,nbins,radius,norient,...
      'tsim',csim,'smooth',smooth,'sigma',sigmaSmo);

else, % RGB image

  % convert gamma-corrected image to LAB and scale values into [0,1]
  lab = RGB2Lab(im.^gamma);
  lab(:,:,1) = lab(:,:,1) ./ 100;
  lab(:,:,2) = (lab(:,:,2) - abmin) ./ (abmax-abmin);
  lab(:,:,3) = (lab(:,:,3) - abmin) ./ (abmax-abmin);
  lab(:,:,2) = max(0,min(1,lab(:,:,2)));
  lab(:,:,3) = max(0,min(1,lab(:,:,3)));

  % compute cg from LAB values
  cg = zeros([size(im) norient]);
  for i = 1:3,
    cmap = max(1,ceil(lab(:,:,i)*nbins(i)));
    csim = colorsim(nbins(i),sigmaSim(i));
    [cg(:,:,i,:),theta] = tgmo(...
        cmap,nbins(i),radius(i),norient,...
        'tsim',csim,'smooth',smooth,'sigma',sigmaSmo(i));
  end

end

% compute color similarity matrix assuming colors are in [0,1]
function m = colorsim(nbins,sigma)
bc = ((1:nbins)-0.5)/nbins; % bin centers
[x,y] = meshgrid(bc,bc);
m = 1.0 - exp(-abs(x-y).^2./(2*sigma.^2));
