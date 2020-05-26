function [pb,theta] = pb2MM(im,sigma)
% function [pb,theta] = pb2MM(im,sigma)
%
% Compute probability of boundary using the spatially averaged
% second moment matrix.
%
% See also det2MM.
%
% David R. Martin <dmartin@eecs.berkeley.edu>
% March 2003

if nargin<2, sigma=2; end

switch sigma, % from logistic fits (train2MM.m)
 case  1, beta = [ -2.9101440e+00 -1.4635580e+01  2.5478994e+01 ];
 case  2, beta = [ -3.2511132e+00 -7.3345180e+00  3.0920345e+01 ];
 case  4, beta = [ -3.5676231e+00  1.2901075e+01  2.8938513e+01 ];
 case  8, beta = [ -3.4692147e+00  3.1719655e+01  2.8143428e+01 ];
 case 16, beta = [ -3.2552836e+00  6.4123944e+01  2.5891795e+01 ];
 otherwise,
  error(sprintf('no parameters for sigma=%g\n',sigma));
end

h = size(im,1);
w = size(im,2);
[a,b,theta] = det2MM(im,sigma);
a = sqrt(a(:));
b = sqrt(b(:));
x = [ ones(size(a)) a b ];
pb = 1 ./ (1 + exp(-x*beta'));
pb = reshape(pb,[h w]);
pb = nonmax(pb,theta);
