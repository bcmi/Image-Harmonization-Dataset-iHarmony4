function [bg,tg,theta] = detBGTG(im,radius,norient)
% function [bg,tg,theta] = detBGTG(im,radius,norient)
%
% Compute smoothed but not thinned BG and TG fields.

if nargin<2, radius=[0.01 0.02]; end
if nargin<3, norient=8; end

if numel(radius)==1, radius=radius*ones(2,1); end

[h,w,unused] = size(im);
idiag = norm([h w]);
if isrgb(im), im=rgb2gray(im); end

% compute brightness gradient
[bg,theta] = cgmo(im,idiag*radius(1),norient,...
                  'smooth','savgol','sigmaSmo',idiag*radius(1));

% compute texture gradient
no = 6;
ss = 1;
ns = 2;
sc = sqrt(2);
el = 2;
k = 64;
fname = sprintf( ...
    'unitex_%.2g_%.2g_%.2g_%.2g_%.2g_%d.mat',no,ss,ns,sc,el,k);
load(fname); % defines fb,tex,tsim
tmap = assignTextons(fbRun(fb,im),tex);
[tg,theta] = tgmo(tmap,k,idiag*radius(2),norient,...
                  'smooth','savgol','sigma',idiag*radius(2));


