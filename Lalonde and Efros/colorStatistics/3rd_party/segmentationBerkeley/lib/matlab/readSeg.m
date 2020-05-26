function [seg] = readSeg(filename)
% function [seg] = reaSeg(filename)
%
% Read a segmentation file.
% Return a segment membership matrix with values [1,k].
%
% Charless Fowlkes <fowlkes@eecs.berkeley.edu>
% David Martin <dmartin@eecs.berkeley.edu>
% January 2003

fid = fopen(filename,'r');
if fid==-1, 
  error(sprintf('Could not open file %s for reading.',filename));
end

% parse header
width = 0;
height = 0;
while 1,
  line = fgetl(fid); 
  if ~ischar(line), error('Premature EOF.'); end
  if strcmp(line,'data'), break; end;

  [a,count] = sscanf(line,'width %d');
  if count==1, width=a; continue; end
  
  [a,count] = sscanf(line,'height %d');
  if count==1, height=a; continue; end
end

% read data
vals = fscanf(fid,'%d %d %d %d');
fclose(fid);

% parse data
seg = zeros(width,height);
vals = reshape(vals,4,length(vals)/4);
vals = vals + 1;
for i = 1:size(vals,2),
  s = vals(1,i);
  r = vals(2,i);
  c1 = vals(3,i);
  c2 = vals(4,i);
  seg(c1:c2,r) = s;
end
seg = seg';

% validate data
if min(seg(:)) < 1, 
  error('Some pixel is not assigned a segment.'); 
end
if length(unique(seg(:))) ~= max(seg(:)), 
  error('Some segment IDs are missing.'); 
end

