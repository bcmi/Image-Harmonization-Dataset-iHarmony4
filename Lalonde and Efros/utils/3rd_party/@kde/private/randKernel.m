function samples = randKernel(N,M,type)
%
% samples = randKernel(N,M,type) -- Draw samples from a kernel of the 
%                           given type, with bandwidth 1; for bw!=1,
%                       eg bw=getBW(dens,ind), use B.*randKernel(N,M,type)
%

% Copyright (C) 2003 Alexander Ihler; distributable under GPL -- see README.txt

  type = lower(type); type = type(1);
  switch type,
      case 'g', samples = randNormal(N,M);
      case 'l', samples = randLaplace(N,M);
      case 'e', samples = randEpanetch(N,M);
      otherwise, error('Unknown kernel type -- cannot draw samples!');
  end;

function samples = randLaplace(N,M)
% Sample forom double-exponential
%
  binary = rand(N,M) > .5;
  binary = 2*binary -1;
  samples = binary .* log(rand(N,M));
  
function samples = randNormal(N,M)
% Sample from Gaussian -- built-in matlab routine
%
  samples = randn(N,M);
  
function samples = randEpanetch(N,M)
%
% Sample from Truncated Quadratic by analytic solution of CDF (a cubic)
%
  u = rand(N,M);
  a2 = 0; a1=-3; a0=4*u-2;          % defines the cubic
  Q = 1/3 * a1;                     % solve (assumes simple a2=0 form)
  R = 1/2 * (-a0);
  D = Q.^3 + R.^2;
  S = (R + sqrt(D)).^(1/3);
  T = (R - sqrt(D)).^(1/3);
%  ans1 = S + T;
%  ans2 = -.5*(S+T) + .5*sqrt(3)*i*(S-T);
  ans3 = -.5*(S+T) - .5*sqrt(3)*i*(S-T);    % only this sol'n in [-1,1] (?)

  samples = zeros(N,M);
%  F= find(abs(ans1)<1); if (samples(F)~=0) fprintf('!'); end; samples(F)=ans1(F);
%  F= find(abs(ans2)<1); if (samples(F)~=0) fprintf('!'); end; samples(F)=ans2(F);
  F= find(abs(ans3)<1); if (samples(F)~=0) fprintf('!'); end; samples(F)=ans3(F);
  
