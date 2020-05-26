function h = ksizeHall(npd)
%
% Find kernel size according to "plug-in" method of 
%     Hall, Marron, Sheather, Jones (91)
% 
%

% Copyright (C) 2003 Alexander Ihler; distributable under GPL -- see README.txt

  x = getPoints(npd);
  [N1,N2] = size(x);
  sig = std(x,0,2);                     % estimate sigma (standard)
  lamS= .7413 * iqr(x')';               % find sigma by interquartile range lam
  if (max(lamS)==0) lamS=sig; end;      % replace sigma est. if possible
  BW = 1.0592 * lamS * N2^(-1/(4+N1));
  BW = repmat(BW,[1,N2]);
  
  dX = repmat(permute(x,[1,3,2]),[1,N2,1]);  % compute Xi-Xj for all i,j
  for i=1:N2, 
    dX(:,:,i) = (dX(:,:,i)-x)./BW;
  end;
  for i=1:N2, dX(:,i,i) = 2e22; end;
  dX = reshape(dX,[N1,N2*N2]);

%  use that to find I2 and I3
  I2=h_findI2(N2,dX,BW(:,1));      % I2 = \hat R( f^(2) ) = \int f^(2)^2 dx
  I3=h_findI3(N2,dX,BW(:,1));      % I3 = \hat R( f^(3) )

% for Gaussian Kernel, we evaluate to find:
%  RK = 1.0/(2^N1) * 1.0/pi^(N1/2.0);    % R(K) = \int K^2(x) dx
%  mu2 = 1.0;                            % \mu_i = \int x^i K(x) dx
%  mu4 = 3.0^N1;
  switch (npd.type)
    case 0, RK = 0.282095;   mu2 = 1.000000;   mu4 = 3.000000; % Gauss
    case 1, RK = 0.600000;   mu2 = 0.199994;   mu4 = 0.085708; % Epanetch
    case 2, RK = 0.250002;   mu2 = 1.994473;   mu4 = 23.299070;% Laplace
  end;

  J1 = RK/mu2^2 .* 1./I2;                       
  J2 = (mu4 * I3) ./ (20 * mu2) .* 1./I2;       
  h  = (J1/N2).^(1.0/5) + J2.*(J1/N2).^(3.0/5); 



% Let us estimate R(f^(p)) by R( \hat f^(p) )
%   (f is the original density to be est'd;  f^(p) is its pth derivative)
%   Let L be the kernel function for this second estimator, with bandwidth alpha
%
% Ip = \int f^(p)^2_\alpha(x) dx  
%    = [(-1)^p/n^2] \sum_i \sum_j L^(p)_\alpha * L^(p)_\alpha
%    = [(-1)^p/(n^2 \alpha^(2p+1))]  \sum_i \sum_j (L^(p) * L^(p))( (Xi-Xj)/\alpha )
%
% Take L to be a Gaussian kernel; we then evaluate L^(p) by:
%
  % L^(p)(x) = (-1)^p H_p(x) L(x)
  % H_p(x) = x H_{p-1}(x) - (p-1)H_{p-2}(x)
  % p=2 =>
  %   H_2(x) = x H_1(x) - H_0(x) = x * x - 1
  %   =>  L^(2)(x) = (x^2 - 1) * L(x)
  % p=3 =>
  %   H_3(x) = x H_2(x) - 2*H_1(x) = x*(x^2-1) - 2*x
  %   =>  L^(3)(x) = (x^3 - 3x) * L(x)
  %
                                
function I2 = h_findI2(n,dXa,alpha)
%%  load ksizeHSJM.mat;
%%  xInd = fix(Nquant * (dXa-Xmin) / (Xmax-Xmin));
%%  xInd = max(xInd,1); xInd = min(xInd,Nquant);
%%  s = sum( L2data(xInd) ,2);
%  s = sum( (dXa.^2 -1) .* 1/sqrt(2*pi) .* exp(-.5*dXa.^2) , 2);
  s = sum( (dXa.^2 -1) .* 1/sqrt(2*pi) .* repmat(exp(-.5*sum(dXa.^2,1)),[size(dXa,1),1]) , 2);
  I2=s./((n*(n-1))*alpha.^5);

function I3 = h_findI3(n,dXb,beta)
%%  load ksizeHSJM.mat;
%%  xInd = fix(Nquant * (dXb-Xmin) / (Xmax-Xmin));
%%  xInd = max(xInd,1); xInd = min(xInd,Nquant);
%%  s = sum( L3data(xInd) , 2);  
%  s = sum( (dXb.^3 -3*dXb) .* 1/sqrt(2*pi) .* exp(-.5*dXb.^2) , 2);
  s = sum( (dXb.^3 -3*dXb) .* 1/sqrt(2*pi) .* repmat(exp(-.5*sum(dXb.^2,1)),[size(dXb,1),1]) , 2);
  I3  = -s./((n*(n-1))*beta.^7);
