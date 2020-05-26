function [points,ind] = sample(npd,Npts,ind)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% [pts,ind] = sample(kde,Npts)      -- sample Npts new points from a kde
%                            ,ind)  -- take the samples from the given indices
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Copyright (C) 2003 Alexander Ihler; distributable under GPL -- see README.txt

pts = getPoints(npd);
if (nargin < 3)
  points = zeros(getDim(npd),Npts); ind = zeros(1,Npts);
  bw  = getBW(npd);
  w = getWeights(npd); w = cumsum(w); w = w/w(end);
  randnums = randKernel(getDim(npd),Npts,getType(npd));
  t = [sort(rand(1,Npts)),10];

  ii = 1;
  for i=1:size(pts,2)
    while (w(i) > t(ii))
      points(:,ii) = pts(:,i) + bw(:,i).*randnums(:,ii);
      ind(ii) = i;
      ii = ii + 1;
    end;
  end;
else
  points = pts(:,ind) + getBW(npd,ind).*randKernel(getDim(npd),length(ind),getType(npd));
end;
