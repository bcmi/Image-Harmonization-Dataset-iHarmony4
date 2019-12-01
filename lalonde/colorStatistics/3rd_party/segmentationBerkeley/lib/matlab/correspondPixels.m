% [match1,match2,cost,oc] = correspondPixels(bmap1,bmap2,maxDist,outlierCost)
%
% Compute minimum-cost correspondance between two boundary maps.
%
% The cost of corresponding two pixels is equal to their Euclidean
% distance.  Two pixels with dist>maxDist cannot be corresponded,
% with cost equal to outlierCost.
%
% INPUTS
%	bmap1		MxN matrix, 1=boundary, 0=non-boundary.
%	bmap2		MxN matrix.
%	[maxDist=0.01]	Maximum distance allowed between matched
%			pixels, as a fraction of the image diagonal.
%	[outlierCost=100]
%			Cost of not matching a pixel, as a multiple
%			of maxDist.
%
% OUTPUTS
%	match1		MxN integer matrix of correspondances for map1.
%	match2		MxN integer matrix of correspondances for map2.
%	[cost]		The cost of the assignment.
%	[oc]		The outlier cost in units of pixels.
%
% The output match matrices provide indices of the correspondance, as
% given by sub2ind.  Indices of zero denote outliers. The following
% expressions may be useful:
%
% length(find(bmap1)) + length(find(bmap2))
%			The number of pixels to match.
% length(find(match1)) + length(find(match2))
%			The number of corresponded pixels.
% length(find(bmap1&~match1)) + length(find(bmap2&~match2))
%			The number of outliers.
% [find(match1) match1(find(match1))] 
%			Kx2 list of the K assignment edges.
% sortrows([match2(find(match2)) find(match2)])
%			The same Kx2 list of assignment edges.
% cost - oc * (length(find(bmap1&~match1)) + length(find(bmap2&~match2)))
%			The assignment cost discluding outliers.
%
% See also csaAssign.
%
% David Martin <dmartin@eecs.berkeley.edu>
% January 2003
