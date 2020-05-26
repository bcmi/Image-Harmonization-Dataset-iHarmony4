function [e,varargout] = DualTree(dens,pos,lvFlag)
%
% Crappy matlab implementation of kernel density estimate evaluation.
% Slow & bloated.  Only use this if BallTreeDensity.dll is absent.
%
%

% Copyright (C) 2003 Alexander Ihler; distributable under GPL -- see README.txt

  if (dens.type ~= 0) error('Sorry -- crappy matlab version only does Gaussians.'); end;
  if (isa(pos,'kde')) pos = getPoints(kde); end;
  
  N1 = getDim(dens);
  N2 = getNpts(dens);
  [tmp, N3] = size(pos);
  if (tmp ~= N1) error('Eval locations have wrong dimension'); end;
  if (nargin < 3) lvFlag = 0; end;  
  saveFlag = 0; 

  sig = getBWall(dens); logsig = log(sig);            %
  saveVal = repmat(permute(pos,[1,3,2]),[1,N2,1]);    % New, faster version of above
  for i=1:N3, 
    saveVal(:,:,i)=-.5*((saveVal(:,:,i)-getPoints(dens))./sig).^2 - logsig; 
  end;

  prob  = reshape(sum(saveVal,1),[N2,N3]);
  prob  = exp(prob);

  if (lvFlag)                                          % if leave-one-out estimate
    prob( sub2ind(size(prob),1:N2,1:N2) )=0;           % clear the diagonal
    WeightAdj = 1-getWeights(dens);
  end;                                                 % (later avg over only N2-1 points)

  if (nargout >= 2)
    prob         = 1.0/((2*pi)^(N1/2.0)) * prob .* repmat(getWeights(dens)',[1,N3]);
    e            = sum(prob,1);
  else 
    e            = 1.0/((2*pi)^(N1/2.0)) * (getWeights(dens)*prob);
  end;
  if (lvFlag), e = e./WeightAdj; end;

  if (nargout == 2)  varargout(1) = {prob}; end;        % also return probabilities?
