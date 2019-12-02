%WHISTC Histogram count.
%   N = WHISTC(X, W, EDGES), for vector X with weights W, counts the weights of values 
%   in X that fall between the elements in the EDGES vector (which must contain
%   monotonically non-decreasing values).  N is a LENGTH(EDGES) vector
%   containing these counts.  
%
%   N(k) will count the weight W(i) if EDGES(k) <= X(i) < EDGES(k+1).  The
%   last bin will count any values of X that equals EDGES(end).  Values
%   outside the values in EDGES are not counted.  Use -inf and inf in
%   EDGES to include all non-NaN values.
%
%   For matrices, HISTC(X, W, EDGES) is a matrix of column histogram counts.
%   For N-D arrays, HISTC(X, W, EDGES) operates along the first non-singleton
%   dimension.
%
%   HISTC(X, W, EDGES,DIM) operates along the dimension DIM. 
%
%   [N,BIN] = HISTC(X, W, EDGES,...) also returns an index matrix BIN.  If X is a
%   vector, N(K) = SUM(W(BIN==K)). BIN is zero for out of range values. 
%
%   Use BAR(EDGES,N,'histc') to plot the histogram.
%
%
%   Class support for inputs X, W, EDGES:
%      float: double, single
%
%   See also HISTC.
%   Implemented in a MATLAB mex file.
%#mex
