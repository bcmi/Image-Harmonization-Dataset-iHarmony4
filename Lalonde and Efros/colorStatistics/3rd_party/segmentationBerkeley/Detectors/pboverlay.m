function [im] = pboverlay(im,pb,channel,faint)
% function [im] = pboverlay(im,pb,channel,faint)
%
% Overlay the pb onto an image.  
%
% INPUTS
%	im		Grayscale or RGB image, values in [0,1].
%	pb		Boundary map, values in [0,1].
%	[channel=2]	Row vector of channels into which to 
%			put the pb, in [1,3].
%	[faint=0.4]	Mulitplier for image, in [0,1].
%
% OUTPUTS
%	im		Faded image with overlayed pb.
%
% David R. Martin <dmartin@eecs.berkeley.edu>

if nargin<3, channel=2; end;
if nargin<4, faint=0.4; end;
faint = max(0,min(1,faint));

if ~isgray(pb),
  error('pb not a grayscale image'); 
end
if ~(isrgb(im) | isgray(im)),
  error('im not a grayscale or rgb image');
end

if isgray(im), im = cat(3,im,im,im); end
im = im * faint;
for c = channel,
  im(:,:,c) = min(1,pb+im(:,:,c));
end
