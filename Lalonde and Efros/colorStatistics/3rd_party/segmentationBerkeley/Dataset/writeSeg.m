function writeSeg(seg,filename)
% function writeSeg(seg,filename)
%
% Write a segmentation file, given a segment membership matrix with
% values [1,k].
%
% David Martin <dmartin@eecs.berkeley.edu>
% January 2003

fid = fopen(filename,'w');
if fid==-1, 
  error(sprintf('Could not open file %s for writing.',filename));
end

% write header
[height,width] = size(seg);
fprintf(fid,'format ascii cr\n');
fprintf(fid,'width %d\n',width);
fprintf(fid,'height %d\n',height);
fprintf(fid,'segments %d\n',max(seg(:)));
fprintf(fid,'data\n');

% write data
seg = seg';
for row = 1:height,
  prevSeg = seg(1,row);
  start = 1;
  for col = 2:width,
    thisSeg = seg(col,row);
    if thisSeg == prevSeg, continue; end
    fprintf(fid,'%d %d %d %d\n', prevSeg-1, row-1, start-1, col-2);
    start = col;
    prevSeg = thisSeg;
  end
  fprintf(fid,'%d %d %d %d\n', prevSeg-1, row-1, start-1, width-1);
end

fclose(fid);
