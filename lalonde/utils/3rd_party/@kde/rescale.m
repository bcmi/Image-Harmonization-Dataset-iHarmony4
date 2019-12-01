function npd = rescale(npd,factor)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% rescale(P, factor) --  Rescales the KDE "P" proportionally by 
%                           "factor" (a column-vector)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Copyright (C) 2003 Alexander Ihler; distributable under GPL -- see README.txt

N = npd.N;
npd.centers    = npd.centers .* repmat(factor,[1,2*N]);
npd.ranges     = npd.ranges .* max(factor);  % to be safe
npd.means      = npd.means .* repmat(factor,[1,2*N]);
npd.bandwidth     = npd.bandwidth .* repmat(factor.^2,size(npd.bandwidth)./size(factor));
