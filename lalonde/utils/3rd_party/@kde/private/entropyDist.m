function h=entropyDist(npd)
%
% Compute entropy estimate using nearest neighbor estimate
%

% Copyright (C) 2003 Alexander Ihler; distributable under GPL -- see README.txt

Ce = .57721566490153286;

pts = getPoints(npd);

[N1,N2] = size(pts);
[tmp,D] = knn(npd,pts,2);

Sr = N1* pi^(N1/2) / gamma((N1/2) + 1);
h = N1/N2 * sum( log(D) ) + log(Sr * (N2-1)/N1 ) + Ce;
