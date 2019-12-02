function p = evaluate(dens,pos,varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% EVALUATE    Evaluate the likelihood of a density estimate at given locations
%
%   EVALUATE(X,Y [,...]) returns a vector of the likelihood of the points Y under 
%                       the density estimate X, to a percent error tolerance Tol
%                       Y may be [Ndim x Npoints] doubles or another KDE
%  Optional arguments:
%     'lvout'   -- leave-one-out, used: evaluate(X,X,'lvout')
%     Tol       -- evaluate up to percent error tolerance Tol (default 1e-3)
%                       Specify zero for an exact calculation.
%
%
% See: Gray & Moore, "Very Fast Multivariate Kernel Density Estimation using
%          via Computational Geometry", in Proceedings, Joint Stat. Meeting 2003
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Copyright (C) 2003 Alexander Ihler; distributable under GPL -- see README.txt

  lvFlag = 0; errTol = 1e-3;
  for i=1:nargin-2,
    if (strcmp(varargin{i},'lvout')) lvFlag=1; end;
    if (isa(varargin{i},'double'))   errTol = varargin{i}; end;
  end;

  if (isa(pos,'kde')) posKDE = pos; dim = getDim(pos);
  else                posKDE = BallTree(pos,ones(1,size(pos,2))/size(pos,2)); dim = size(pos,1);
  end;
  
  if (getDim(dens)~= dim) error('X and Y must have the same dimension'); end;
  
  if (lvFlag) p = DualTree(dens,errTol);
  else        p = DualTree(dens,posKDE,errTol);
  end;
  
  
