function [f,y] = sampleDetector(detector,pres,n,buffer)
% function [f,y] = sampleDetector(detector,pres,n,buffer)
%
% Sample on and off-boundary pixels fromthe BSDS training images,
% returning 0|1 class labels in y with the associated feature 
% vectors in y.  The feature vectors are computed by the function
% provided by the argument detector.
%
% INPUT
%	detector	Function f = detector(im), where im is an
%			image and f is a mxp feature vector, where
%			m is the number of features and p is the
%			number of pixels in the image.
%	pres		One of {'gray','color'}.
%	[n=1000000]	Approximate number of samples total.  Some
%			images may provide fewer samples than others.
%	[buffer=2]	Buffer zone around boundary pixels where we
%			don't take off-boundary samples.
%
% OUTPUT
%	f		Feature vectors (mxn); m=#features, n=#samples.
%	y		Vector (1xn) of 0|1 class labels (1=boundary).
%
% David R. Martin <dmartin@eecs.berkeley.edu>
% March 2003

if nargin<3, n=1000000; end
if nargin<4, buffer=2; end

% list of images
iids = imgList('train');

% number of samples per image
nPer = ceil(n/numel(iids));

y = zeros(1,0);
f = [];

for i = 1:numel(iids),
  tic;
  % read the image
  iid = iids(i);
  fprintf(2,'Processing image %d/%d (iid=%d)...\n',i,numel(iids),iid);
  im = imgRead(iid);
  % run the detector to get feature vectors
  fprintf(2,'  Running detector...\n');
  features = feval(detector,im);
  % load the segmentations and union the boundary maps
  fprintf(2,'  Loading segmentations...\n');
  segs = readSegs(pres,iid);
  bmap = zeros(size(segs{1}));
  for j = 1:numel(segs),
    bmap = bmap | seg2bmap(segs{j});
  end  
  dmap = bwdist(bmap);
  % sample 
  fprintf(2,'  Sampling...\n');
  onidx = find(bmap)';
  offidx = find(dmap>buffer)';
  ind = [ onidx offidx ];
  cnt = numel(ind);
  idx = randperm(cnt);
  idx = idx(1:min(cnt,nPer));
  y = [ y bmap(ind(idx)) ];
  f = [ f features(:,ind(idx)) ];
  fprintf(2,'  %d samples.\n',numel(idx));
  toc;
end
