% [edges] = csaAssign(n,graph)
%
% Compute min-cost assignment with non-negative integral edge weights
% using Andrew Goldberg's CSA package (precise costs version).
%
% INPUT
%	n	Number of nodes in the bipartite graph (must be even).
%	graph	3xm matrix describing graph.
%
% OUTPUT
%	edges	3xn matrix of edges in assignment.
%
% You must ensure that an assignment involving all nodes exists, else
% the code may hang.  This is a feature of the CSA package.  If your
% problem does not necessarily provide such an assignment, then you
% should overlay a high-cost perfect match as a safety net.
%
% Both graph and edges matrices have the same structure.  Each column
% gives a graph edge e.  The two nodes are given by e(1) and e(2):
%
%	e(1) < e(2)
%	1 <= e(1) <= n/2
%	n/2 < e(2) <= n
%
% The edge weight is given by e(3). 
%
% Since the output edge matrix should contain one reference to each
% node, sum(sum(edges(1:2,:))) == n*(n+1)/2.
%
% David Martin <dmartin@eecs.berkeley.edu>
% January, 2003
