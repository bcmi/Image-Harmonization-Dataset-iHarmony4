function [segs,uids] = readSegs(present,iid)
% function [segs,uids] = readSegs(present,iid)
%
% Return a cell array of segmentations of an image 
% and the associated UIDs.
%
% David Martin <dmartin@eecs.berkeley.edu>
% January 2003

files = dir(fullfile(bsdsRoot,'human',present,'*'));
segs = {};
uids = {};
n = 0;
for i = 1:length(files),
  if ~files(i).isdir, continue; end
  if strcmp(files(i).name,'.'), continue; end
  if strcmp(files(i).name,'..'), continue; end
  uid = sscanf(files(i).name,'%d',1);
  file = segFilename(present,uid,iid);
  if length(dir(file))==0, continue; end
  n = n + 1;
  segs{n} = readSeg(file);
  uids{n} = uid;
end
