function [thresh,cntR,sumR,cntP,sumP] = boundaryPR(pb,segs,nthresh)
% function [thresh,cntR,sumR,cntP,sumP] = boundaryPR(pb,segs,nthresh)
%
% Calcualte precision/recall curve.
% If pb is binary, then a single point is computed.
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
% See also boundaryPRfast.
% 
% David Martin <dmartin@eecs.berkeley.edu>
% January 2003

if nargin<3, nthresh = 100; end
if islogical(pb), nthresh = 1; end
nthresh = max(1,nthresh);

[height,width] = size(pb);
nsegs = length(segs);
thresh = linspace(1/(nthresh+1),1-1/(nthresh+1),nthresh)';

% compute boundary maps from segs
bmaps = cell(size(segs));
for i = 1:nsegs,
  bmaps{i} = double(seg2bmap(segs{i},width,height));
end

% make sure the boundary maps are thinned to a standard thickness
for i = 1:nsegs,
  bmaps{i} = bmaps{i} .* bwmorph(bmaps{i},'thin',inf);
end

% zero all counts
cntR = zeros(size(thresh));
sumR = zeros(size(thresh));
cntP = zeros(size(thresh));
sumP = zeros(size(thresh));

if nthresh>1, progbar(0,nthresh); end
for t = 1:nthresh,
  % threshold pb to get binary boundary map
  bmap = (pb>=thresh(t));
  % thin the thresholded pb to make sure boundaries are standard thickness
  bmap = double(bwmorph(bmap,'thin',inf));
  % accumulate machine matches, since the machine pixels are
  % allowed to match with any segmentation
  accP = zeros(size(pb));
  % compare to each seg in turn
  for i = 1:nsegs,
    %fwrite(2,'+');
    % compute the correspondence
    [match1,match2] = correspondPixels(bmap,bmaps{i});
    % accumulate machine matches
    accP = accP | match1;
    % compute recall
    sumR(t) = sumR(t) + sum(bmaps{i}(:));
    cntR(t) = cntR(t) + sum(match2(:)>0);
  end
  % compute precision
  sumP(t) = sumP(t) + sum(bmap(:));
  cntP(t) = cntP(t) + sum(accP(:));
  if nthresh>1, progbar(t,nthresh); end
end
