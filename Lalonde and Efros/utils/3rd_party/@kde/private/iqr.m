function i = iqr(x)
%
% Calculate interquartile range without the stats package
%

% Copyright (C) 2003 Alexander Ihler; distributable under GPL -- see README.txt

xS = sort(x);         % sort along dimensions
N  = size(x,1);
i  = xS(ceil(3*N/4),:) - xS(ceil(N/4),:);
