%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function segStruct = getSuperPixelFromFile(segPath)
%  Get a superpixel structure from a file
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function segStruct = getSuperPixelFromFile(segPath) 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% extract superpixel information
segStruct.imname = segPath;
imSeg = imread(segPath);
imSeg = double(imSeg);
segStruct.imsize = size(imSeg);
segStruct.imsize = segStruct.imsize(1:2);
imSeg = imSeg(:, :, 1) + imSeg(:, :, 2)*256 + imSeg(:, :, 3)*256^2;
[gid, gn] = grp2idx(imSeg(:));
segStruct.segimage = uint16(reshape(gid, segStruct.imsize));
segStruct.nseg = length(gn);
segStruct = APPgetSpStats(segStruct);