function [pb] = pbHuman(pres,iid,r)
if nargin<3, r=[0.25 0.99]; end
segs = readSegs(pres,iid);
pb = zeros(size(segs{1}));
for i = 1:numel(segs),
  bmap = seg2bmap(segs{i});
  pb = pb + bmap;
end
pb = pb / numel(segs);
pb = (pb~=0) .* (pb * (r(2)-r(1)) + r(1));
pb = min(pb,r(2));
