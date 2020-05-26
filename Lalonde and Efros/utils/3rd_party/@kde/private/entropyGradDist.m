function Dvect=entropyGradDist(npd)
%
% Compute entropy estimate using nearest neighbor estimate
%

% Copyright (C) 2003 Alexander Ihler; distributable under GPL -- see README.txt

pts = getPoints(npd);
Ce = .57721566490153286;
[N1,N2] = size(pts);
[I,D] = knn(npd,pts,2);
I = I(2,:);
Dvect = pts - pts(:,I);

%Sr = N1* pi^(N1/2) / gamma((N1/2) + 1);
%h = N1/N2 * sum( log(D) ) + log(Sr * (N2-1)/N1 ) + Ce;

Dvect = N1/N2 * Dvect ./ repmat(D.^2,[N1,1]);   % find gradient direction
%Dvect = .1 * Dvect / max(max(Dvect));        % scale for epsilon steps
