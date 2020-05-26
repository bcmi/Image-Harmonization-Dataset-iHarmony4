% ==============================================================================
% KDE Matlab class definition
% ==============================================================================
% 
% The following is a simple list of all accessible functions for the KDE class.
% Before using, recompile all MEX functions using "mexall" in @kde/mex/
% 
% Constructors:
% =====================================================
%   kde( )              : empty kde
%   kde( kde )          : re-construct kde from points, weights, bw; or from struct
%   kde( points, bw, weights,type): Construct specified KDE;
%                Defaults: type='Gaussian', weights = ones(1,N)/N
% 
%   marginal( kde, dim)       : marginalize to the given dimensions 
% 
%   condition( kde, dim, A)   : marginalize to ~dim and weight by K(x_i(dim),a(dim)) 
% 
%   resample( kde, [kstype] ) : draw N samples from kde & use to construct a new kde
%
%   reduce( kde )             : construct a "reduced set" density estimate
% 
%   joinTrees( t1, t2, alpha ): make a new tree with t1 and t2 as the children of 
%                                 a new root node; t1 gets weight alpha
% 
% Accessors: 
% =====================================================
%   getType(kde)      : return the kernel type of the KDE ('Gaussian', etc)
% 
%   getBW(kde,index)  : return the bandwidth assoc. with x_i  (Ndim x length(index))
%   adjustBW          : set the bandwidth(s) of the KDE (by reference!)
% 
%   ksize             : automatic bandwidth selection via a number of methods
%     LCV             : 1D search using max leave-one-out likelihood criterion
%     HALL            : Plug-in estimator with good asymptotics; MISE criterion
%     ROT,MSP         : Fast standard-deviaion based methods; AMISE criterion
%     LOCAL           : Like LCV, but makes BW propto k-th NN distance (k=sqrt(N))
% 
%   getPoints(kde)    : Ndim x Npoints array of kernel locations
%   adjustPoints(p,delta) : shift points of P by delta (by reference!)
% 
%   getWeights        : [1 x Npts] array of kernel weights
%   adjustWeights     : set kernel weights (by reference!)
% 
%   rescale(kde,alpha): rescale a KDE by the (vector) alpha
% 
%   getDim	          : get the dimension of the data
%   getNpts           : get the # of kernel locations
%   getNeff           : "effective" # of kernels (accounts for non-uniform weights)
% 
%   sample(P,Np,KSType)	: draw Np new samples from P and set BW according to KSType
% 
% 
% Display: (visualization / Description)
% =====================================================
%   plot(kde...)      : plot the specified dimensions of the KDE locations
%   hist(kde...)      : discretize the kde at uniform bin lengths
%   display           : text output describing the KDE
%   double            : boolean evaluation of the KDE (non-empty)
% 
% 
% Statistics:
% =====================================================
%   covar             : find the (weighted) covariance of the kernel centers
%   mean              : find the (weighted) mean of the kernel centers
%   modes             : (attempt to) find the modes of the distribution
% 
%   knn(kde, pts, k)  : find the k nearest neighbors of each of pts in kde
% 
%   entropy           : estimate the entropy of the KDE
%   kld               : estimate divergence between two KDEs
%   ise               : eval/estimate integrated squared difference between two KDEs
% 
%   evaluate(kde, x[,tol]): evaluate KDE at a set of points x
%   evaluate(p, p2 [,tol]):  "" "", x = p2.pts (if we've already built a tree)
%   
%   evalAvgLogL(kde, x)   : compute Mean( log( evaluate(kde, x) ))
%   evalAvgLogL(kde, kde2):   "" "" but use the weights of kde2
%   evalAvgLogL(kde)      : self-eval; leave-one-out option
% 
%   llGrad(p,q)           : find the gradient of log-likelihood for p
%                           evaluated at the points q 
%   llHess(p,q)	  	  : find the Hessian of log-likelihood for p at q
%   entropyGrad(p)        : estimate gradient of entropy (uses llGrad)
%   miGrad(p,dim)         : "" for mutual information between p(dim), p(~dim)
%   klGrad(p1,p2)         : estimate gradient direction of KL-divergence
% 
% 
% 
% Mixture products: (NBP stuff; GAUSSIAN KERNELS ONLY)
% =====================================================
% 
% productApprox          : accessor for other product methods
%   prodSampleExact	     : sample N points exactly (N^d computation)
%   prodSampleEpsilon    : kd-tree epsilon-exact sampler
%   prodSampleGibbs1     : seq. index gibbs sampler
%   prodSampleGibbs2     : product of experts gibbs sampler
%   prodSampleGibbsMS1   : multiresolution version of GS1
%   prodSampleGibbsMS2   : multiresolution version of GS2
%   prodSampleImportance : importance sampling
%   prodSampleImportGauss: gaussian importance sampling
% 
% productExact           : exact computation (N^d kernel centers)
% 
% Usage Example:
% =====================================================
%     p = ksize(kde( rand(2,1000), 1 ),'rot');
%     plot(p, 'rx');
% See @kde/examples/demo_kde_#.m (#=1,2,3) for more examples.
%
% KDE class written by Alex Ihler and Michael Mandel
% Copyright (C) 2003 Alexander Ihler; distributable under GPL -- see README.txt
% Questions/Comments?  Contact Alex Ihler (ihler@mit.edu)
%
