%EMD (Earth Movers Distance) 
%   e=emd(w1,w2,C)
%   [e,F]=emd(w1,w2,C)
%   w1 is the weight vector of the first signature    (1 by n1)
%   w2 is the weight vector of the second signature   (1 by n2)
%   C is the Cost matrix between signatures  (n1 by n2)
%   you can compute the cost matrix depending on you features
%   e is the EMD distance
%   F is the Flow, a matrix (n1+n2-1 by 3) in which is row is
%   [from to amount] 

%   This is the MATLAB mex interface to the following implementation
%   http://ai.stanford.edu/~rubner/emd/default.htm  by Y. Rubner
