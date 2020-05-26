function [h,varargout] = hist(dens,N,dims,range)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% [H,X,Y] = hist(dens [,N][,dims][,range])  -- make a "histogram" of a KDE
%
%     Discretizes the KDE by evaluating it at a number of bins (N).
%     For 1-D densities, H is the normalized density evaluated at X.
%       Usage: [Y,X] = hist(p,100); plot(X,Y);
%     For k-D densities, H is the [len(X) x len(Y)] normalized values
%       evaluated at every pair (X,Y).  If only two values are returned, 
%       the second will be the matrix of 2-D (X,Y) pairs; if three are
%       returned the latter two will be the vectors X and Y.
%       Usage:  mesh(hist(p,100,[1,3]))
%
% see also: kde, plot
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Copyright (C) 2003 Alexander Ihler; distributable under GPL -- see README.txt


  if (nargin < 4) range = []; end;
  if (nargin < 3) dims = [1,2]; end;
  if (nargin < 2) N = 200; end;
  
  if ((getDim(dens) == 1) || (length(dims)==1)), % 1-dimensional density estimate
    if (getDim(dens)>1) dens = marginal(dens,dims); end;
    if (~range) range = [min(getPoints(dens)),max(getPoints(dens))]; end;
    X = linspace(range(1),range(2),N(1));
    h = evaluate(dens,X);
%    h = h / sum(h,2);
    if (nargout==2) varargout{1} = X; end;
      
  else                    % k-dimensional density estimate
    if (size(N) == 1) N = N*ones(1,length(dims)); end;
    if (length(range)==0) range = [min(getPoints(dens),[],2),max(getPoints(dens),[],2)]; end;
    X = linspace(range(dims(1),1),range(dims(1),2),N(1));
    Y = linspace(range(dims(2),1),range(dims(2),2),N(2));
    XY = [repmat(reshape(X,[1,N(1),1]),[1,1,N(2)]) ; 
          repmat(reshape(Y,[1,1,N(2)]),[1,N(1),1]) ];
    h = evaluate(marginal(dens,dims(1:2)),reshape(XY,[2,N(1)*N(2)]));

%    h = h / sum(h,2);
    h = reshape(h,[N(1),N(2)]);
    if (nargout==2) varargout{1} = XY; end;
    if (nargout==3) varargout{1} = X; varargout{2} = Y; end;
  end;
  
