%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [err1,err2]=klGrad(dens1,dens2,estType)
%   Compute gradient of a KL-divergence estimate, D(dens1 || dens2);
%   estType is one of:
%       ise          :  integrated squared error from uniform estimate (not yet implemented)
%       rs,lln,means :  law of large numbers resubstitution estimate; kld(p1,p2,'rs')
%       abs          :  abs(LLN); similar to above but minimizing kld(p1,p2,'abs')
%       KL,dist      :  nearest-neighbor distance based estimate (not yet implemented)
%
% see also: kde, miGrad, entropyGrad, adjustPoints
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Copyright (C) 2003 Alexander Ihler; distributable under GPL -- see README.txt

function [err1,err2]=klGrad(p1,p2,estType,respectTo)
  if (nargin < 3), estType = 'lvout'; end;
  if (nargin < 4), respectTo = 0; end;
  
  switch (lower(estType))
                     
      case 'lvout2',     % deriv(D(p1||p2) - H(p1) - H(p2))
                         [dPLPdens, dPLPat] = llGrad(p1,respectTo,1e-3,1e-3);
                         [dQLQdens, dQLQat] = llGrad(p2,respectTo,1e-3,1e-3);
                         [dPLQdens, dPLQat] = llGrad(p2,p1,respectTo,1e-3,1e-3);
                         
                         %LP = evaluate(p1,p1,'lvout');
                         %LP20 = prctile(LP,20);
                         %LQ = evaluate(p2,p2,'lvout');
                         %LQ20 = prctile(LQ,20);
                         
                         %errXX1(:,LP<L20) = 0;
                         %errXX2(:,LP<L20) = 0;
                         %err
                         
                         err1 = (2*(dPLPdens + dPLPat) - dPLQat);
                         err2 = (-dPLQdens + dQLQat + dQLQdens);
    
      case 'lvout',      
                         [errXX1, errXX2] = llGrad(p1,0,1e-3,1e-3);
                         [errXYY, errXYX] = llGrad(p2,p1,0,1e-3,1e-3);
                         err1 = (errXX1 + errXX2 - errXYX);
                         err2 = (-errXYY);
     
      case 'ise', error('ISE approximation to KL-gradient not yet supported');

      case {'rs','lln'}, [errXX1, errXX2] = llGrad(p1,p1,0,1e-3,1e-3);
                         [errXYY, errXYX] = llGrad(p2,p1,0,1e-3,1e-3); 
                         err1 = (errXX1 + errXX2 - errXYX);
                         err2 = (-errXYY);

      case {'abs'},      [errXX1, errXX2] = llGrad(p1,p1,0,1e-3,1e-3);
                         [errXYY, errXYX] = llGrad(p2,p1,0,1e-3,1e-3); 
                         err1 = (errXX1 + errXX2 - errXYX);
                         err2 = (-errXYY);
                         eval1 = evaluate(p1,p1); eval2 = evaluate(p2,p1);
                         klSigns1 = sign(log(eval1./eval2));
                         eval1 = evaluate(p1,p2); eval2 = evaluate(p2,p2);
                         klSigns2 = sign(log(eval2./eval1));
                         Nd = getDim(p1);
                         err1 = repmat(klSigns1,[Nd,1]).*err1; 
                         err2 = repmat(klSigns2,[Nd,1]).*err2;
%                         klSign = kld(p1,p2);
%                         if (klSign<0) err1=-err1; err2=-err2; end;
      case {'kl','dist'}, error('Distance approx. to KL-gradient not yet supported.');
  end;  

