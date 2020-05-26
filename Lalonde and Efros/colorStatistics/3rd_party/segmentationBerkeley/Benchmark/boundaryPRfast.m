function [thresh,cntR,sumR,cntP,sumP] = boundaryPRfast(pb,segs,nthresh)
% function [thresh,cntR,sumR,cntP,sumP] = boundaryPRfast(pb,segs,nthresh)
%
% Calcualte precision/recall curve using faster approximation.
% If pb is binary, then a single point is computed with thresh=0.5.
% The pb image can be smaller than the segmentations.
%
% INPUT
%	pb		Soft or hard boundary map.
%	segs		Array of segmentations.
%	[nthresh]	Number of points in PR curve.
%
% OUTPUT
%	thresh		Vector of threshold values.
%	cntR,sumR	Ratio gives recall.
%	cntP,sumP	Ratio gives precision.
%
% See also boundaryPR.
% 
% David Martin <dmartin@eecs.berkeley.edu>
% January 2003

if nargin<3, nthresh = 100; end
if islogical(pb), 
  [thresh,cntR,sumR,cntP,sumP] = boundaryPR(pb,segs,nthresh);
  return
end
nthresh = max(1,nthresh);

[height,width] = size(pb);
nsegs = length(segs);
thresh = linspace(1/(nthresh+1),1-1/(nthresh+1),nthresh)';

% compute boundary maps from segs
bmaps = cell(size(segs));
for i = 1:nsegs,
  bmaps{i} = double(seg2bmap(segs{i},width,height));
end

% thin everything
for i = 1:nsegs,
  bmaps{i} = bmaps{i} .* bwmorph(bmaps{i},'thin',inf);
end

% compute denominator for recall
sumR = 0;
for i = 1:nsegs,
  sumR = sumR + sum(bmaps{i}(:));
end
sumR = sumR .* ones(size(nthresh));
  
% zero counts for recall and precision
cntR = zeros(size(thresh));
cntP = zeros(size(thresh));
sumP = zeros(size(thresh));

fwrite(2,'[');
for t = nthresh:-1:1,
  fwrite(2,'.');
  % threshold and then thin pb to get binary boundary map
  bmap = (pb>=thresh(t));
  bmap = double(bwmorph(bmap,'thin',inf));
  if t<nthresh,
    % consider only new boundaries
    bmap = bmap .* ~(pb>=thresh(t+1));
    % these stats accumulate
    cntR(t) = cntR(t+1);
    cntP(t) = cntP(t+1);
    sumP(t) = sumP(t+1);
  end 
  % accumulate machine matches across the human segmentations, since
  % the machine pixels are allowed to match with any segmentation
  accP = zeros(size(pb));
  % compare to each seg in turn
  for i = 1:nsegs,
    % compute the correspondence
    [match1,match2] = correspondPixels(bmap,bmaps{i});
    % compute recall, and mask off what was matched in the groundtruth
    cntR(t) = cntR(t) + sum(match2(:)>0);
    bmaps{i} = bmaps{i} .* ~match2;
    % accumulate machine matches for precision
    accP = accP | match1;
  end
  % compute precision
  sumP(t) = sumP(t) + sum(bmap(:));
  cntP(t) = cntP(t) + sum(accP(:));
end
fprintf(2,']\n');
