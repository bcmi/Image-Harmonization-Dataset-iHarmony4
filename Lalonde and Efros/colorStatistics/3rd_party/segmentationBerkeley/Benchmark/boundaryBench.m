function boundaryBench(pbDir,pres,nthresh,fast)
% function boundaryBench(pbDir,pres,nthresh,fast)
%
% Run the boundary detector benchmark on the Pb files found in
% pbDir for the BSDS test images.
%
% See also imgList, bsdsRoot.
%
% David Martin <dmartin@eecs.berkeley.edu>
% March 2003

if nargin<3, nthresh=30; end
if nargin<4, fast=0; end

iids = imgList('test');

cntR_total = zeros(nthresh,1);
sumR_total = zeros(nthresh,1);
cntP_total = zeros(nthresh,1);
sumP_total = zeros(nthresh,1);
scores = zeros(numel(iids),5);

for i = 1:numel(iids),
  iid = iids(i);
  fprintf(2,'Processing image %d/%d (iid=%d)...\n',i,numel(iids),iid);

  pbFile = fullfile(pbDir,sprintf('%d.bmp',iid));
  fprintf(2,'  Reading pb file...\n');
  pb = double(imread(pbFile))/255;
  if ndims(pb)~=2,
    error(sprintf('pb file ''%s'' is not grayscale',pbFile));
  end

  fprintf(2,'  Reading segs...\n');
  segs = readSegs(pres,iid);

  % Make sure the pb and the segmentations are the same size.
  if numel(pb)<numel(segs{1}),
    % upsample pb to the size of the segmentations
    pb = imresize(pb,size(segs{1}),'nearest');
  elseif numel(pb)>numel(segs{1}),
    error('Cannot evaluate pb bigger than segmentations.');
  end

  if fast,
    fwrite(2,'  Calculating precision/recall (fast method) ');
    [thresh,cntR,sumR,cntP,sumP] = boundaryPRfast(pb,segs,nthresh);
  else
    fwrite(2,'  Calculating precision/recall (exact method) ');
    [thresh,cntR,sumR,cntP,sumP] = boundaryPR(pb,segs,nthresh);
  end
  
  fprintf(2,'  Writing results...\n');

  R = cntR ./ (sumR + (sumR==0));
  P = cntP ./ (sumP + (sumP==0));
  F = fmeasure(R,P);
  [bestT,bestR,bestP,bestF] = maxF(thresh,R,P);
  
  fname = fullfile(pbDir,sprintf('%d_pr.txt',iid));
  fid = fopen(fname,'w');
  if fid==-1, 
    error(sprintf('Could not open file %s for writing.',fname));
  end
  fprintf(fid,'%10g %10g %10g %10g\n',[thresh R P F]');
  fclose(fid);
  
  scores(i,:) = [iid bestT bestR bestP bestF];
  fname = fullfile(pbDir,'scores.txt');
  fid = fopen(fname,'w');
  if fid==-1, 
    error(sprintf('Could not open file %s for writing.',fname));
  end
  fprintf(fid,'%10d %10g %10g %10g %10g\n',scores(1:i,:)');
  fclose(fid);

  cntR_total = cntR_total + cntR;
  sumR_total = sumR_total + sumR;
  cntP_total = cntP_total + cntP;
  sumP_total = sumP_total + sumP;

  R = cntR_total ./ (sumR_total + (sumR_total==0));
  P = cntP_total ./ (sumP_total + (sumP_total==0));
  F = fmeasure(R,P);
  [bestT,bestR,bestP,bestF] = maxF(thresh,R,P);
  
  fname = fullfile(pbDir,'pr.txt');
  fid = fopen(fname,'w');
  if fid==-1, 
    error(sprintf('Could not open file %s for writing.',fname));
  end
  fprintf(fid,'%10g %10g %10g %10g\n',[thresh R P F]');
  fclose(fid);
  
  fname = fullfile(pbDir,'score.txt');
  fid = fopen(fname,'w');
  if fid==-1, 
    error(sprintf('Could not open file %s for writing.',fname));
  end
  fprintf(fid,'%10g %10g %10g %10g\n',bestT,bestR,bestP,bestF);
  fclose(fid);
end

% compute f-measure fromm recall and precision
function [f] = fmeasure(r,p)
f = 2*p.*r./(p+r+((p+r)==0));

% interpolate to find best F and coordinates thereof
function [bestT,bestR,bestP,bestF] = maxF(thresh,R,P)
bestT = thresh(1);
bestR = R(1);
bestP = P(1);
bestF = fmeasure(R(1),P(1));
for i = 2:numel(thresh),
  for d = linspace(0,1),
    t = thresh(i)*d + thresh(i-1)*(1-d);
    r = R(i)*d + R(i-1)*(1-d);
    p = P(i)*d + P(i-1)*(1-d);
    f = fmeasure(r,p);
    if f > bestF,
      bestT = t;
      bestR = r;
      bestP = p;
      bestF = f;
    end
  end
end

