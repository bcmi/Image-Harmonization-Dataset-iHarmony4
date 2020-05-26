function Hessians = llHess(p1,p2,tolGrad,tolEval)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% H = llHess(p1, p2, tolGrad [,tolEval])
%
%    Compute the Hessian of the log-likelihood log(p1) eval'd at locations p2
%      p2 is a KDE or double matrix; H is (D x D x Npts)
%    tolGrad and tolEval are not used in the current implementation.
%
% See also:  llGrad
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Copyright (C) 2003 Alexander Ihler; distributable under GPL -- see README.txt

%
% Should probably be MEX'd, but I haven't gotten around to it yet.
%

if (isa(p2,'kde')), X2 = getPoints(p2); else X2 = p2; p2 = kde(X2,1); end;

X1 = getPoints(p1);
N = size(X1,2); M = size(X2,2); D = size(X1,1);

Hessians = zeros(D,D,M);
px = evaluate(p1,p2);
[tmp, grad] = llGrad(p1,p2,0);
BW = getBW(p1,1:N);  wts = getWeights(p1);
for m=1:M                       		% for each point to evaluate at,
  x = X2(:,m);                  		%   rename for convenience
  Hessians(:,:,m) = -grad(:,m)*grad(:,m)';	% first term: outer prod. of gradients

  diff = X1 - repmat(x,[1,N]);
  HessAdd = zeros(D,D);				% compute 2nd term of Hessian:
  if (p1.type == 0) 					% GAUSSIAN KERNEL
    K  = (2*pi)^(D/2) * exp( - diff.^2 ./ 2 ./ BW.^2 ) ./ getBW(p1,1:N);
    Kp = - diff./BW.^2 .* K;				
    Kpp= (-K./BW.^2)   +   (-diff./BW.^2 .* Kp);
  elseif (p1.type == 1)					% EPANETCH. KERNEL
    K  = 1./BW .* max( 1 - (diff./BW).^2 , 0);
    Kpp= -(K~=0) .* 2 ./ BW.^3;
    Kp = Kpp .* diff;
  elseif (p1.type == 2)					% LAPLACIAN KERNEL
    K  = 1./BW .* exp( - diff ./ BW );
    Kp = - diff./BW .* K;
    Kpp= - K./BW  + (-diff./BW .* Kp); 
  end;
  for dim=1:D
    HessAdd(dim,dim) = (wts * (Kpp(dim,:) .* prod(K([1:dim-1,dim+1:D],:),1))');
    for dim2=dim+1:D
    HessAdd(dim,dim2)= (wts * (Kp(dim,:).*Kp(dim2,:).*prod(K([1:dim-1,dim+1:dim2-1,dim2+1:D],:),1))');
    HessAdd(dim2,dim) = HessAdd(dim,dim2);
  end;end;
  Hessians(:,:,m) = Hessians(:,:,m) + HessAdd ./ px(m);
  
end;

