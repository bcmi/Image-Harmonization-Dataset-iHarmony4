function [ptsS, wtsS] = prodSampleImportPair(npds,Npts,anFns,anParams,overSamp,type)
%
% Message-based importance sampling (private function)
%
% See  Ihler,Sudderth,Freeman,&Willsky, "Efficient multiscale sampling from products
%         of Gaussian mixtures", in Proc. Neural Information Processing Systems 2003
%

% Copyright (C) 2003 Alexander Ihler; distributable under GPL -- see README.txt

Ndim = getDim(npds{1});
Ndens=length(npds);
if (nargin < 6) type = 'repeat'; end;

if (Ndens < 2) error('Cannot use ImportancePair sampling on < 2 kdes...'); end;

p=[]; pts = []; wts = []; sumNpds={}; relwt = 0;  NptsSamp = round(overSamp * Npts);
for i=1:Ndens
 for j=i+1:Ndens
  p = [p,prodSampleEpsilon(npds([i,j]),NptsSamp/Ndens,1e-3)]; 
  %if (isempty(sumNpds)) sumNpds = kde(p,'rot');
  %else sumNpds = joinTrees(sumNpds,kde(p,'rot'),relwt/(relwt+1));
  %end;
  %relwt = relwt + 1;
end; end;
sumNpds = kde(p,'rot');

pts = sample(sumNpds,NptsSamp);
wts = evaluate(sumNpds,pts);
w = ones(1,overSamp*Npts);
for i=1:length(npds)
  w = w .* evaluate(npds{i},pts);
end;
w = w ./ wts;

for i=1:length(anFns),
  w = w .* feval(anFns{i},pts,anParams{i}{:});
  w = w / sum(w);
end;

w = cumsum(w); if(w(end)~=0) w = w/w(end); end;
r = sort(rand(1,Npts));

%%%%%%%%%%%%%%%%%%%%%%%%%%%% Unique vs Repeating %%%
if (strcmp(type,'unique')) 
  ptsS = zeros(Ndim,Npts); wtsS = zeros(1,Npts);
  i=1; j=1; k=1; 
  while i<=Npts, %for i=1:Npts
    while (w(j) <  r(i))  j=j+1; end;
    ptsS(:,k) = pts(:,j); i=i+1; wtsS(k)=1;
    while (i <= Npts && w(j) >= r(i))
      i=i+1; 
      wtsS(k)=wtsS(k)+1; 
    end;
    k=k+1;
  end;
  ptsS = ptsS(:,1:k-1); wtsS = wtsS(:,1:k-1); wtsS = wtsS/sum(wtsS);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
else
  j=1; ptsS = zeros(Ndim,Npts);
  for i=1:Npts
    while (w(j) < r(i)) j = j+1; end;
    ptsS(:,i) = pts(:,j);
  end;
  if (w(end)==0) wtsS = zeros(1,Npts);
  else wtsS = ones(1,Npts)/Npts; end;
end;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
