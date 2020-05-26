function [im] = imgRead(iid,format)
% function [im] = imgRead(iid,format)

if nargin<2, format='color'; end

im = double(imread(imgFilename(iid))) / 255;

if strcmp(format,'gray'),
  im = rgb2gray(im);
end
