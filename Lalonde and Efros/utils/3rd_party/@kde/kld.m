function KLD = kld(p1,p2,type,varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% kld   An estimate of the KL-Divergence between two density estimates
%
%   kld(P,Q) estimates the KL-divergence D(P || Q) from sampling P and 
%               evaluating  at P and Q.
%   Optional Arguments:
%     kld(P,Q,'type') where 'type' is one of
%       'rs','lln':  (default) use the evaluation of Q at the means of P
%       'rand',N  :  use a stochastic approximation with N samples
%       'unscent' :  use an unscented transform (deterministic) approximation
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Copyright (C) 2003 Alexander Ihler; distributable under GPL -- see README.txt

% Discontinued (bad estimate, replaced by ISE for the only application)
%       'abs'     :  use the absolute log ratio of P & Q eval'd at P's means


if (nargin < 3) type = 'rs'; end;

switch (type),
case {'rs','lln'}, KLD = evalAvgLogL(p1,p1) - evalAvgLogL(p2,p1);
case 'rand',  N = varargin{1};
              ptsE = sample(p1,N); pE = kde(ptsE,1);
              KLD = evalAvgLogL(p1,pE) - evalAvgLogL(p2,pE);
case 'unscent', 
              D = getDim(p1);  N = getNpts(p1);
              ptsE = getPoints(p1); wts = getWeights(p1);
              ptsE = repmat(ptsE,[1,2*D+1]);  % make 2*dim copies of each point
              wts = repmat(wts,[1,2*D+1]);    %  (and its weight) 
              bw = getBW(p1,1:N);
              for i=1:D
                ptsE(i,(i-1)*N+(1:N)) = ptsE(i,(i-1)*N+(1:N)) + bw(i,:);
                ptsE(i,(2*i-1)*N+(1:N)) = ptsE(i,(2*i-1)*N+(1:N)) - bw(i,:);
              end;
              pE = kde(ptsE,1,wts);
              KLD = evalAvgLogL(p1,pE) - evalAvgLogL(p2,pE);
case 'dist', error('Distance based estimate not yet implemented');
otherwise, error('Unknown KL-divergence ''type'' argument');
end;
 
