function [pb,theta] = pbGM2(im,sigma)
% function [pb,theta] = pbGM2(im,sigma)
%
% Compute probability of boundary using gradient magnitude at
% multiple scales.
%
% See also gm.
%
% David R. Martin <dmartin@eecs.berkeley.edu>
% March 2003

if nargin<2, sigma=2; end

switch sigma, % from logistic fits (trainGM2.m)
 case  1, beta = [ -2.9845759e+00 -4.4804245e+00  2.6493560e+01 ];
 case  2, beta = [ -3.2341949e+00  6.5031017e+00  2.0245465e+01 ];
 case  4, beta = [ -3.0361378e+00  1.5965267e+01  1.6130494e+01 ];
 otherwise,
  error(sprintf('no parameters for sigma=%g\n',sigma));
end

h = size(im,1);
w = size(im,2);
[a,t1] = detGM(im,sigma); 
[b,t2] = detGM(im,sigma*2); 
a = a(:);
b = b(:);
x = [ ones(size(a)) a b ];
pb = 1 ./ (1 + exp(-x*beta'));
pb = reshape(pb,[h w]);

% average orientations for nonmax suppression
dt = mod(t2-t1,2*pi); % [0,2pi)
dt = (dt<pi).*dt + (dt>=pi).*(dt-2*pi); % [-pi,pi)
pb = nonmax(pb,t1+dt/2);
