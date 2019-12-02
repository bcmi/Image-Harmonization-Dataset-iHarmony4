function [pb] = pbRandom(im)
% function [pb] = pbRandom(im)

if ndims(im)~=2, error('image must be grayscale'); end

pb = rand(size(im));
