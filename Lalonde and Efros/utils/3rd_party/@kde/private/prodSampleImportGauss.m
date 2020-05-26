function [ptsS, wtsS] = prodSampleImportGaussian(npds,Npts,anFns,anParams,overSamp,type)
%
% Gaussian-approximation-based importance sampling (private function)
%
% See  Ihler,Sudderth,Freeman,&Willsky, "Efficient multiscale sampling from products
%         of Gaussian mixtures", in Proc. Neural Information Processing Systems 2003
%

% Copyright (C) 2003 Alexander Ihler; distributable under GPL -- see README.txt

if (nargin < 6) type = 'repeat'; end;

Ndim = getDim(npds{1});  NptsSamp = round(overSamp * Npts);
iC = zeros(Ndim,1); iM = iC;
for i=1:length(npds)
  iC = iC + 1./covar(npds{i});
  iM = iM + mean(npds{i}) ./ covar(npds{i});
end;
C = 1./iC;
M = iM .* C;

ptsN = randn(Ndim,NptsSamp);

pts = ptsN .* repmat(sqrt(C),[1,NptsSamp]);
pts = pts +  repmat(M,[1,NptsSamp]);

w = ones(1,NptsSamp)/NptsSamp;
for i=1:length(npds)
  w = w .* evaluate(npds{i},pts);
  w = w ./ sum(w);
end;
w = w ./ likeli(ptsN);

for i=1:length(anFns),
  w = w .* feval(anFns{i},pts,anParams{i}{:});
  w = w / sum(w);
end;

w = cumsum(w); w = w/w(end);
r = sort(rand(1,Npts));
j=1; i=1; k=1;

%%%%%%%%%%%%%%%%%%%%%%% % return < N unique samples (vs N repeating samples)
if(strcmp(type,'unique') )
  ptsS = zeros(Ndim,Npts); wtsS = ones(1,Npts);
  i=1; k=1; while i<=Npts, %for i=1:Npts
    while (w(j) <  r(i))  j=j+1; end;
    ptsS(:,k) = pts(:,j); i=i+1;
    while (i <= Npts && w(j) >= r(i))
      i=i+1;
      wtsS(k)=wtsS(k)+1;
    end;
  k=k+1;
  end;
  ptsS = ptsS(:,1:k-1); wtsS = wtsS(:,1:k-1); wtsS = wtsS/sum(wtsS);
%%%%%%%%%%%%%%%%%%%%%%%
else
  ptsS = zeros(Ndim,Npts);
  for i=1:Npts
    while (w(j) < r(i)) j = j+1; end;
    ptsS(:,i) = pts(:,j);
  end;
  wtsS = ones(1,Npts)/Npts;
end;
%%%%%%%%%%%%%%%%%%%%%%%


function L = likeli(pts)  % likelihood of points drawn from normal dist.
  L = 1/(2*pi)^(size(pts,1)/2) * exp(-sum(pts .^2,1));
  L = L + .01; % otherwise we get weight problems in the tails
