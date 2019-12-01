function errI = miGrad(x,a_index,type,y,gamma)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% err = miGrad(dens,index [,estType])
%
%   Compute the gradient (direction of increasing) mutual information for a
%     kernel density estimate 'dens', namely, locations to shift the points 
%     of dens which should increase  I[ dens.pts(:,index), dens.pts(:,~index) ]
%
%   estType is one of:
%      'ISE'      -- integrated squared error gradient entropy estimates
%      'RS','LLN' -- resubstitution estimate of entropy gradients
%      'KL','DIST'-- nearest-neighbor distance based estimates
%
% see also: kde, entropyGrad, klGrad, adjustPoints
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Copyright (C) 2003 Alexander Ihler; distributable under GPL -- see README.txt

  if (nargin < 3) type = 'ise'; end;
  if (nargin < 5), gamma = 0; end;

  [Nd,Np] = size(getPoints(x));
  allind  = 1:Nd;
  b_index = setdiff(allind,a_index);

  errHA = entropyGrad(marginal(x,a_index),type);  %marginal a of x
  errHB = entropyGrad(marginal(x,b_index),type);  %marginal b of x
  errHAB= entropyGrad(x,type);

  % if we have negative examples
  if (gamma), 
    errHA = errHA - gamma * entropyGrad(marginal(y,a_index), type );
    errHB = errHB - gamma * entropyGrad(marginal(y,b_index), type );
    errHAB = errHAB - gamma * entropyGrad(y, type ); 
  end;
  
% errI = errHA+errHB-errHAB                      %  MI(a,b) = H(a)+H(b)-H(a,b):
  errI = -errHAB;
  errI(a_index,:) = errI(a_index,:)+errHA;
  errI(b_index,:) = errI(b_index,:)+errHB;

  

