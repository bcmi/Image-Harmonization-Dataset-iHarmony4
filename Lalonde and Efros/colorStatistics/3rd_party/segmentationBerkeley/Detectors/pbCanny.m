function [pb] = pbCanny(im,sigma,nthresh,hmult)
% function [pb] = pbCanny(im,sigma,nthresh,hmult)
%
% Compute probability of boundary using Canny, i.e. gradient
% magnitude with hysteresis thresholding.
%
% INPUT
%	im		Image.
%	sigma		Scale at which to compute image 
%			derivatives.
%	nthresh		Resolution for pb.
%	hmult		Multiplier for lower hysteresis 
%			threshold, in [0,1].
%
% OUTPUT
%	pb	Probability of boundary.
%
% See also pbGM.
%
% David R. Martin <dmartin@eecs.berkeley.edu>
% March 2003

if isrgb(im), im = rgb2gray(im); end;
idiag = norm(size(im));

if nargin<2, sigma=2; end
if nargin<3, nthresh=100; end
if nargin<4, hmult=1/3; end

if hmult<0 | hmult>1, error('Invalid hmult value'); end
if nthresh<1, error('Invalid nthresh value'); end

% start with the pb from gradient magnitude...
pbgm = pbGM(im,sigma);
% ...and apply hysteresis thresholding
pb = zeros(size(im));
thresh = linspace(1/nthresh,1-1/nthresh,nthresh);
progbar(0,nthresh);
for i = 1:nthresh,
  progbar(i,nthresh);
  [r,c] = find(pbgm>=thresh(i));
  if numel(r)==0, continue; end
  b = bwselect(pbgm>hmult*thresh(i),c,r,8);
  pb = max(pb,b*thresh(i));
end

