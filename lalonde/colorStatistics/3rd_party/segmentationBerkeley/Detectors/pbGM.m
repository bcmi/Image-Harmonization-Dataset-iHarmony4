function [pb,theta] = pbGM(im,sigma)
% function [pb,theta] = pbGM(im,sigma)
%
% Compute probability of boundary using gradient magnitude.
%
% See also gm.
%
% David R. Martin <dmartin@eecs.berkeley.edu>
% March 2003

if nargin<2, sigma=2; end

switch sigma, % from logistic fits (trainGM.m)
 case  1, beta = [ -2.6828268e+00 1.6251270e+01 ];
 case  2, beta = [ -2.9906198e+00 2.2454909e+01 ];
 case  4, beta = [ -3.2040961e+00 2.5838634e+01 ];
 case  8, beta = [ -2.9314518e+00 2.9306847e+01 ];
 case 16, beta = [ -2.4502722e+00 3.4139686e+01 ]; 
 otherwise,
  error(sprintf('no parameters for sigma=%g\n',sigma));
end

h = size(im,1);
w = size(im,2);
[m,theta] = detGM(im,sigma);
m = m(:);
x = [ ones(size(m)) m ];
pb = 1 ./ (1 + exp(-x*beta'));
pb = reshape(pb,[h w]);
pb = nonmax(pb,theta);


