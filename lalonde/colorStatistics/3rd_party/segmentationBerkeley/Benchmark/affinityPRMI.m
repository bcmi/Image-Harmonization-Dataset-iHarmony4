function [thresh,cntR,sumR,cntP,sumP,miHist] = affinityPRMI(pairs,segs,nthresh)
% function [thresh,cntR,sumR,cntP,sumP,miHist] = affinityPRMI(pairs,segs,nthresh)
%
% Calcualte precision/recall and mutual information data.
%
% INPUT
%	pairs		3xN array of (i,j,wij) triples.
%	segs		Array of segmentations.
%	[nthresh]	Number of points in PR curve.
%
% OUTPUT
%	thresh		Vector of threshold values.
%	cntR,sumR	Ratio gives recall.
%	cntP,sumP	Ratio gives precision.
%	miHist		Joint histogram of (sameseg,Wij) for MI.
% 
% For pairs, the i,j indices are 1-based 1D indices into the
% segmentations.
%
% See also calcMI.
%
% David Martin <dmartin@eecs.berkeley.edu>
% January 2003

if nargin<3, nthresh = 100; end
nthresh = max(1,nthresh);

if size(pairs,1)~=3,
  error('pairs must be 3xN');
end
n = size(pairs,2);

if pairs(3,:)<0 | pairs(3,:)>1, 
  error('illegal wij value in pairs(3,:); wij must be in [0,1]');
end

nsegs = length(segs);
if nsegs==0,
  error('segs is empty');
end

[height,width] = size(segs{1});
thresh = linspace(1/(nthresh+1),1-1/(nthresh+1),nthresh)';

% For the mutual information, we need the joint distribution of the
% same segment indicator (given by the segmentations) and Wij.  We
% will bin the Wij values, and so get a 2D histogram estimate of the
% joint.  This histogram is also sufficient information to compute
% precision and recall.
miHist = zeros(nthresh,2);
for index = 1:n,
  % groundtruth is same-segment iff all humans give same-segment
  i = pairs(1,index);
  j = pairs(2,index);
  same = 1;
  for s = 1:nsegs,
    same = same & (segs{s}(i)==segs{s}(j));
  end
  % bin the wij value
  wij = pairs(3,index);
  bin = 1+round(wij*(nthresh-1));
  % increment histogram
  miHist(bin,1+same) = miHist(bin,1+same) + 1;
end

% compute precision and recall
cumHist = flipud(cumsum(flipud(miHist)));
cntR = cumHist(:,2);
sumR = zeros(size(cntR))+cumHist(1,2);
cntP = cumHist(:,2);
sumP = sum(cumHist,2);
