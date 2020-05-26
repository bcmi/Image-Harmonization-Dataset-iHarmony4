function acc = isum(x,idx,nbins)
% function acc = isum(x,idx,nbins)
%
% Indexed sum reduction, where acc(i) contains the sum of
% x(find(idx==i)).
%
% The mex version is 300x faster in R12, and 4x faster in R13.  As far
% as I can tell, there is no way to do this efficiently in matlab R12.
%
% David R. Martin <dmartin@eecs.berkeley.edu>
% March 2003

acc = zeros(nbins,1);
for i = 1:numel(x),
  if idx(i)<1, continue; end
  if idx(i)>nbins, continue; end
  acc(idx(i)) = acc(idx(i)) + x(i);
end
