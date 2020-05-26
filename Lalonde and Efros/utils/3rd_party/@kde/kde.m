function p = kde(points,ks,weights,typeS)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% kde(points,ksize[,weights][,type]) -- nonparametric density estimate of a pdf
%
%  points is the [Ndim x Npoints] array of kernel locations
%  ksize may be a scalar, [Ndim x 1], [Ndim x Npoints], or
%    a string (for data-based methods; see @kde/ksize for allowed methods)
%  weights is [1 x Npoints] and need not be pre-normalized
%  type can be one of: 'Gaussian', 'Laplacian', 'Epanetchnikov' 
%    (only 1st letter required) (Gaussian by default)
%
%  See also: ksize, getPoints, getBW, getWeights, getType
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Copyright (C) 2003 Alexander Ihler; distributable under GPL -- see README.txt

type = 0;
kstype = []; 
if ((nargin == 1) & isa(points,'kde'))
% CONSTRUCTOR FROM KDE-TYPE
  type = points.type; weights = getWeights(points);
  if (size(points.bandwidth,2)>2*points.N), ks = getBW(points,1:getNpts(points));
  else ks = getBW(points,1); end;
  if (type == 0), ks = ks.^2; end;
  points = getPoints(points);
elseif (nargin == 1)  % ugh, needed for deserialization
  for i=1:numel(points)
    p(i) = class(points(i), 'kde');
  end
  p = reshape(p, size(points));
  return

else if (nargin > 0)
% CONSTRUCTOR FROM RAW DATA
  error(nargchk(2,4,nargin));

  if (isa(ks,'char')) kstype = ks; ks =1; end;
  if (size(ks,1) == 1) ks = repmat(ks,[size(points,1),1]); end;

  if (nargin < 3) weights = ones(1,size(points,2)); end;
  if (isempty(weights)) weights = ones(1,size(points,2)); end;

  if (nargin < 4) typeS = 'g';
  else typeS = lower(typeS); typeS = typeS(1); end;
  switch(typeS)
    case 'l', type = 2;
    case 'e', type = 1;
    case 'g', type = 0;  ks = ks.^2;
    otherwise, error('Type must be one of (G)aussian, (L)aplacian, or (E)panetchnikov');
  end;

  weights = weights/sum(weights);  
  
  % Check matrix sizes:
  [D,N] = size(points);  
  if any(size(weights)~=[1,N]) error('Weights must be [1xNpoints] (or empty)'); end;
  bwsize = size(ks);
  if (any(bwsize~=[1,1]) && any(bwsize~=[D,1]) && any(bwsize~=[D,N]))
    error('Bandwidth must be scalar, [Dx1], [DxN], or an automatic selection method'); 
  end;
  
else
% EMPTY CONSTRUCTOR
  points = []; ks = []; weights = [];
end; end;

p = BallTreeDensity(points,weights,ks,type);
p = class(p,'kde');

if (length(kstype)) 
    p = ksize(p,kstype); 
end;
