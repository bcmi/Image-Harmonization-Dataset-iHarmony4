function [textons] = unitex(fb,k)
% function [textons] = unitex(fb,k)
%
% Compute universal textons from the training images.

iids = imgList('train');

n = 100000;
nper = round(n/numel(iids));
n = nper * numel(iids);

d = numel(fb);
data = zeros(d,n);

c = 0;
for i = 1:numel(iids),
  iid = iids(i);
  fprintf(2,'Processing image %d/%d (iid=%d)...\n',i,numel(iids),iid);
  im = imgRead(iid,'gray');
  fim = fbRun(fb,im);
  npix = numel(im);
  p = randperm(npix);
  p = p(1:min(npix,nper));
  m = numel(p);
  for j = 1:d,
    data(j,c+1:c+m) = fim{j}(p);
  end
  c = c + m;
end
data = data(:,1:c);

fprintf(2,'Computing %d universal textons from %d samples...\n',k,c);
[unused,textons] = kmeansML(k,data,'maxiter',30,'verbose',1);
