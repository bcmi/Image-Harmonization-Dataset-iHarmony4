function [cg,theta] = detCG(im,radius,norient)
% function [cg,theta] = detCG(im,radius,norient)
%
% Compute smoothed but not thinned CG fields.

if nargin<2, radius=0.02; end
if nargin<3, norient=8; end

[h,w,unused] = size(im);
idiag = norm([h w]);

% compute color gradient
[cg,theta] = cgmo(im,idiag*radius,norient,...
                  'smooth','savgol','sigmaSmo',idiag*radius);
