function [filename] = imgFilename(iid)
% function [filename] = imgFileName(iid)
%
% Return image filename.
%
% INPUT
%	iid		Image ID.
%
% OUTPUT
%	filename	Image filename.
%
% David Martin <dmartin@eecs.berkeley.edu>
% January 2003

filename = fullfile(bsdsRoot,'images','test',sprintf('%d.jpg',iid));
if length(dir(filename))==1, return; end

filename = fullfile(bsdsRoot,'images','train',sprintf('%d.jpg',iid));
if length(dir(filename))==1, return; end

error(sprintf('Could not find image %d in %s/images/{train,test}.', ...
              iid,bsdsRoot));
