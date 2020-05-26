function [pb,theta] = pb2MM2(im,sigma)
% function [pb,theta] = pb2MM2(im,sigma)
%
% Compute probability of boundary using the spatially averaged
% second moment matrix at multiple scales.
%
% See also det2MM.
%
% David R. Martin <dmartin@eecs.berkeley.edu>
% March 2003

if nargin<2, sigma=1; end

switch sigma, % from logistic fits (train2MM2.m)
 case 1, beta = [ -3.2369080e+00 ...
                  -7.9668057e+00 -7.1098318e-01 ...
                  -4.6178498e-01  3.1575066e+01 ];
 case 2, beta = [ -3.5512404e+00 ...
                  -8.0101784e+00  1.3527093e+01 ...
                   1.0531737e+01  1.9292447e+01 ];
 otherwise,
  error(sprintf('no parameters for sigma=%g\n',sigma));
end

h = size(im,1);
w = size(im,2);
[a1,b1,t1] = det2MM(im,sigma);
[a2,b2,t2] = det2MM(im,sigma*2);
a1 = sqrt(a1(:)); 
b1 = sqrt(b1(:));
a2 = sqrt(a2(:)); 
b2 = sqrt(b2(:));
x = [ ones(size(a1)) a1 b1 a2 b2 ];
pb = 1 ./ (1 + exp(-x*beta'));
pb = reshape(pb,[h w]);

% average orientations for nonmax suppression
dt = mod(t2-t1,2*pi); % [0,2pi)
dt = (dt<pi).*dt + (dt>=pi).*(dt-2*pi); % [-pi,pi)
pb = nonmax(pb,t1+dt/2);

