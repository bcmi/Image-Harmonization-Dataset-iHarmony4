function graph = sparsify(sm)
% function graph = sparsify(sm)
%
% Given a smilarity matrix sm, return a sparse graph representation
% suitable for csaAssign.  For example, if sm is an nxn similarity
% matrix, then Hungarian-style matching can be accomplished by
% executing csaAssign(2*n,sparsify(sm)).
%
% See also csaAssign.
%
% David Martin <dmartin@eecs.berkeley.edu>
% March, 2003

if ndims(sm)~=2 | size(sm,1)~=size(sm,2),
  error('sm must be a square matrix');
end

n = size(sm,1);
graph = zeros(3,n*n);
graph(1,:) = repmat(1:n,1,n);
graph(2,:) = n + reshape(repmat(1:n,n,1),1,n*n);
graph(3,:) = reshape(sm,1,n*n);


