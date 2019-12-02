%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% err = entropyGrad(npd,estType)
%   Compute gradient of an entropy estimate for the npde
%
%   entType is one of:
%       ISE     :  integrated squared error from uniform estimate
%       RS,LLN  :  law of large numbers resubstitution estimate
%       KL,dist :  nearest-neighbor distance based estimate
%
% see also: kde, miGrad, klGrad, adjustPoints
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Copyright (C) 2003 Alexander Ihler; distributable under GPL -- see README.txt

function err=entropyGrad(npd,entType)
  if (nargin < 2), entType = 'ISE'; end;
  switch (upper(entType))
      case 'ISE', err = entropyGradISE(npd);
      case {'RS','LLN'}, [err1,err2]=llGrad(npd,npd,0,1e-3,1e-2); 
                         err = -(err1+err2); 
                         % err = entropyGradRS(npd);
      case {'KL','DIST'}, err = entropyGradDist(npd);
  end;  

