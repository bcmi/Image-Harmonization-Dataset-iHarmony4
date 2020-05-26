function ksizeCalcUseful
%
% ksizeCalcUseful
%   -- find some useful numbers for the various kernels
%


%
% Kernel size calculations for Rule of Thumb, Maximal Smoothing Principle 
%   Assume that true density f is Gaussian  (or whatever)
%   and find h_\infty = BW minimizing AMISE (Asymp. Mean Squared Err)
%   by  h_\infty = (R(K)/mu2(K)/R(f^(2)))^(1/5) n^(-1/5)
%     where R(g) = \int g^2(x) dx
%           muJ(g) = \int x^J g(x) dx
%           g^(J) = J^th derivative of g
%

% Copyright (C) 2003 Alexander Ihler; distributable under GPL -- see README.txt


step = .005;
x = -10:step:10;
% Assume underlying distribution f is Gaussian
Rf = sum( f2(x).^2 .* step );
fprintf('Reference Rf = %f\n',Rf);

% Gaussian Kernel Calc:
sum(Gauss(x) .* step)
R = sum( Gauss(x).^2 .* step );
mu2 = sum( x.^2 .* Gauss(x) .* step );
mu4 = sum( x.^4 .* Gauss(x) .* step );
fprintf('Gauss: hROT = %f * sigma * n^(-1/5)\n',(R/mu2^2/Rf).^(1/5));
fprintf('Gauss: hMSP = %f * sigma * n^(-1/5)\n',3*(R/mu2^2/35).^(1/5));
fprintf('Gauss: R = %f   mu2 = %f   mu4 = %f\n',R,mu2,mu4);

sum(Epanetch(x) .* step)
R = sum( Epanetch(x).^2 .* step );
mu2 = sum( x.^2 .* Epanetch(x) .* step );
mu4 = sum( x.^4 .* Epanetch(x) .* step );
fprintf('Epan: hROT = %f * sigma * n^(-1/5)\n',(R/mu2^2/Rf).^(1/5));
fprintf('Epan: hMSP = %f * sigma * n^(-1/5)\n',3*(R/mu2^2/35).^(1/5));
fprintf('Epan: R = %f   mu2 = %f   mu4 = %f\n',R,mu2,mu4);

sum(Laplace(x) .* step)
R = sum( Laplace(x).^2 .* step );
mu2 = sum( x.^2 .* Laplace(x) .* step );
mu4 = sum( x.^4 .* Laplace(x) .* step );
fprintf('Laplace: hROT = %f * sigma * n^(-1/5)\n',(R/mu2^2/Rf).^(1/5));
fprintf('Laplace: hMSP = %f * sigma * n^(-1/5)\n',3*(R/mu2^2/35).^(1/5));
fprintf('Laplace: R = %f   mu2 = %f   mu4 = %f\n',R,mu2,mu4);


function k=Laplace(x)
  k=1/2 * exp(-abs(x)/1);
  
function k=Gauss(x)
  k=1/sqrt(2*pi) * 1/1 * exp(-.5*(x.^2)/1);
  
function k=Epanetch(x)
  k=3/4 * 1/1 * (1-min(x.^2,1));
  
function k=f2(x)
  % Assume gaussian f
  k = Gauss(x) .* (x.^2/1^4 - 1/1^4);
  
