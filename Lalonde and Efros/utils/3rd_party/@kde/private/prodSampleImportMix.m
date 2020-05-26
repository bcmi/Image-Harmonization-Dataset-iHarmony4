function [ptsS, wtsS] = prodSampleImportMix(npds,Npts,anFns,anParams,overSamp,type)
%
% Message-based importance sampling (private function)
%
% See  Ihler,Sudderth,Freeman,&Willsky, "Efficient multiscale sampling from products
%         of Gaussian mixtures", in Proc. Neural Information Processing Systems 2003
%

% Copyright (C) 2003 Alexander Ihler; distributable under GPL -- see README.txt

if (nargin < 6) type='repeat'; end;

Ndim = getDim(npds{1});  NptsSamp = round(overSamp * Npts);

pts = []; wts = [];
sumNpds = npds{1};
for i=2:length(npds)
  sumNpds = joinTrees(sumNpds,npds{i}, (i-1)/i );
end;
pts = sample(sumNpds,NptsSamp); wts = evaluate(sumNpds,pts);

w = ones(1,NptsSamp);
for i=1:length(npds)
  w = w .* (evaluate(npds{i},pts)+eps);
  w = w/sum(w);
end;
w = w ./ wts;

for i=1:length(anFns),
  w = w .* feval(anFns{i},pts,anParams{i}{:});
  w = w / sum(w);
end;

w = cumsum(w); w = w/w(end);
r = sort(rand(1,Npts));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Unique vs Repeating %%%
if (strcmp(type,'unique'))
  ptsS = zeros(Ndim,Npts); wtsS = ones(1,Npts);
  i=1; j=1; k=1; while i<=Npts, %for i=1:Npts
    while (w(j) <  r(i))  j=j+1; end;
    ptsS(:,k) = pts(:,j); i=i+1;
    while (i <= Npts && w(j) >= r(i))
      i=i+1; 
      wtsS(k)=wtsS(k)+1; 
    end;
    k=k+1;
  end;
  ptsS = ptsS(:,1:k-1); wtsS = wtsS(:,1:k-1); wtsS = wtsS/sum(wtsS);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
else
  j=1; ptsS = zeros(Ndim,Npts);
  for i=1:Npts
    while (w(j) < r(i)) j = j+1; end;
    ptsS(:,i) = pts(:,j);
  end;
  wtsS = ones(1,Npts)/Npts;
end;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
