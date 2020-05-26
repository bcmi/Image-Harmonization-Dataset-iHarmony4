function H = entropy(x,type,varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Entropy(x,'lvout') -- Calculate a resubstitution entropy estimate for a KDE
%                       'lvout' uses a leave-one-out density estimate
% An error tolerance may be specified by Tol (see evalAvgLogL)
%
% see also: evalAvgLogL, evaluate
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Copyright (C) 2003 Alexander Ihler; distributable under GPL -- see README.txt

%  H = -evalAvgLogL(x,x,varargin{:});

if (nargin < 2) type = 'rs'; end;
if (strcmp(type,'lvout')), type='rs'; varargin={'lvout',varargin{:}}; end;

switch (type),
case {'rs','lln'}, H = -evalAvgLogL(x,x,varargin{:});
case 'rand',  N = varargin{1};
              ptsE = sample(p1,N); pE = kde(ptsE,1);
              KLD = evalAvgLogL(p1,pE) - evalAvgLogL(p2,pE);
case 'unscent', 
              D = getDim(x);  N = getNpts(x);
              ptsE = getPoints(x); wts = getWeights(x);
              ptsE = repmat(ptsE,[1,2*D+1]);  % make 2*dim copies of each point
              wts = repmat(wts,[1,2*D+1]);    %  (and its weight) 
              bw = getBW(x,1:N);
              for i=1:D
                ptsE(i,(i-1)*N+(1:N)) = ptsE(i,(i-1)*N+(1:N)) + bw(i,:);
                ptsE(i,(2*i-1)*N+(1:N)) = ptsE(i,(2*i-1)*N+(1:N)) - bw(i,:);
              end;
              pE = kde(ptsE,1,wts);
              H = -evalAvgLogL(x,pE);
case 'dist', H=entropyDist(x);
otherwise, error('Unknown entropy estimate method ''type''');
end;
  