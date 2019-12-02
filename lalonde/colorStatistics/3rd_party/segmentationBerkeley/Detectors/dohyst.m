function dohyst(indir,outdir,hmult,nthresh)
% function dohyst(indir,outdir,hmult,nthresh)
%
% Read pb files from indir, apply hysteresis thresholding, and
% write the resulting pb files into outdir.
% 
% David R. Martin <dmartin@eecs.berkeley.edu>
% April 2003

if nargin<3, hmult=1/3; end
if nargin<4, nthresh=100; end

iids = imgList('test');
unused = mkdir(outdir);
for i = 1:numel(iids),
  iid = iids(i);
  pbold = double(imread(sprintf('%s/%d.bmp',indir,iid)))/255;
  thresh = linspace(1/nthresh,1-1/nthresh,nthresh);
  fwrite(2,sprintf('%3d/%d ',i,numel(iids)));
  progbar(0,nthresh);
  pbnew = zeros(size(pbold));
  for i = 1:nthresh,
    progbar(i,nthresh);
    [r,c] = find(pbold>=thresh(i));
    if numel(r)==0, continue; end
    b = bwselect(pbold>hmult*thresh(i),c,r,8);
    pbnew = max(pbnew,b*thresh(i));
  end
  imwrite(pbnew,sprintf('%s/%d.bmp',outdir,iid),'bmp');
end
