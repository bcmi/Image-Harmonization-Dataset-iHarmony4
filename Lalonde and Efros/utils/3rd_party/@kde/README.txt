==============================================================================
MATLAB KDE Class Description & Specification
==============================================================================

  The KDE class is a general matlab class for k-dimensional kernel density
estimation.  It is written in a mix of matlab ".m" files and MEX/C++ code.
Thus, to use it you will need to be able to compile C++ code for Matlab.
Note that the default compiler for Windows does *not* support C++, so you
will need GCC under Linux, or GCC or Visual C++ for Windows. Bloodshed
(http://www.bloodshed.net) supplies a nice development environment along
with the MinGW (http://www.mingw.org) compiler. See the page 
http://gnumex.sourceforge.net/ for help setting up MEX with MinGW.

  Kernels supported are:  Gaussian, Epanetchnikov (truncated quadratic), 
				and Laplacian (Double exponential)
  For multivariate density estimates, the code supports product kernels -- 
        kernels which are products of the kernel function in each dimension.  
	For example, for Gaussian kernels this is equivalent to requiring a 
	diagonal covariance.
	It can also support non-uniform kernel bandwidths -- i.e. bandwidths 
	which vary over kernel centers.

  The implementation uses "kd-trees", a heirarchical representation for
point sets which caches sufficient statistics about point locations etc.
in order to achieve potential speedups in computation.  For the Epanetchnikov
kernel this can translate into speedups with no loss of precision; but for
kernels with infinite support it provides an approximation tolerance level,
which allows tradeoffs between evaluation quality and computation speed.

  In particular, we implement Alex Gray's "Dual Tree" evaluation algorithm;
see [Gray and Moore, "Very Fast Multivariate Kernel Density Estimation using
via Computational Geometry", in Proceedings, Joint Stat. Meeting 2003] for more 
details. This gives a tolerance parameter which is a percent error (from the 
exact, N^2 computation) on the value at any evaluated point.  In general, 
"tolerance" parameters in the matlab code / notes refers to this percent 
tolerance. This percentage error translates to an absolute additive error on 
the mean log-likelihood, for example.

  An exception to this is the gradient calcuation functions, which calculate
using an absolute tolerance value.  This is due to the difficulty of finding
a percentage bound when the function calculated is not strictly positive.

  We have also recently implemented the so-called Improved Fast Gauss Transform,
described in [Yang, Duraiswami, and Gumerov, "Improved Fast Gauss Transform", 
submitted to the Siam Journal of Scientific Computing].  This often performs
MUCH faster than the dual tree algorithm mentioned above, but the error bounds
which control the computation are often quite loose, and somewhat unwieldy
(for example, it is difficult to obtain the fractional error bounds provided &
used by the dual tree methods and other functions in the KDE toolbox).  Thus 
for the moment we have left the IFGT separate, with alternate controls for 
computational complexity (see below, and the file "evalIFGT.m").


==============================================================================
Getting Started
==============================================================================
  Unzip the KDE class to a directory called @kde.

  Compile the MEX functions.  This can be done by running "makemex" from
    inside matlab, in the "@kde/mex" directory.  If this fails, make sure that
    MEX / C++ compilation works.  The KDE toolbox is tested in Matlab R13, but 
    apparently has problems in R12; I'm planning to investigate this.

    NOTE: MS Visual C++ has a bug in dealing with "static const" variables; I
      think there is a patch available, or you can change these to #defines.

  Operate from the class' parent directory, or add it to your MATLAB path
    (e.g. if you unzip to "myhome/@kde", cd in matlab to the "myhome" dir,
    or add it to the path.)
  
  Objects of type KDE may be created by e.g.
    p = kde( rand(2,1000), [.05;.03] );		% Gaussian kernel, 2D
						%  BW = .05 in dim 1, .03 in dim 2.
    p = kde( rand(2,1000), .05, ones(1,1000) )  % Same as above, but uniform BW and
						%  specifying weights 
    p = kde( rand(2,1000), .05, ones(1,1000), 'Epanetchnikov')  % Quadratic kernel
						% Just 'E' or 'e' also works
    p = kde( rand(2,1000), 'rot' );		% Gaussian kernel, 2D, 
						%  BW chosen by "rule of thumb" (below)

  To see the kernel shape types, you can use:
    plot(-3:.01:3, evaluate(kde(0,1,1,T),-3:.01:3) ); % where T = 'G', 'E', or 'L'

  
  Kernel sizes may be selected automatically using e.g.
    p = ksize(p, 'lcv');	% 1D Likelihood-based search for BW
    p = ksize(p, 'rot');	% "Rule of Thumb"; Silverman '86 / Scott '92
    p = ksize(p, 'hall');	% Plug-in type estimator

  Density estimates may be visualized using e.g.
    plot(p);
  or
    mesh(hist(p));

  See help kde/plot and help kde/hist for more information.

  Also, the demonstration programs @kde/examples/demo_kde_#.m may be helpful.

==============================================================================
KDE Matlab class definition
==============================================================================

The following is a simple list of all accessible functions for the KDE class.


Constructors:
=====================================================
  kde( )			: empty kde
  kde( kde )			: re-construct kde from points, weights, bw, etc.
  kde( points, bw )		: construct Gauss kde with weights 1/N
  kde( points, bw, weights)	: construct Gaussian kde
  kde( points, bw, weights,type): potentially non-Gaussian

  marginal( kde, dim)		: marginalize to the given dimensions 

  condition( kde, dim, A)	: marginalize to ~dim and weight by K(x_i(dim),a(dim)) 

  resample( kde, [kstype] )	: draw N samples from kde & use to construct a new kde

  reduce( kde, ...)             : construct a "reduced" density estimate (fewer points)

  joinTrees( t1, t2 )           : make a new tree with t1 and t2 as
				  the children of a new root node

Accessors: (data access, extremely limited or no processing req'd)
=====================================================
  getType(kde)		: return the kernel type of the KDE ('Gaussian', etc)

  getBW(kde,index)	: return the bandwidth assoc. with x_i  (Ndim x length(index))
  adjustBW		: set the bandwidth(s) of the KDE (by reference!)
			   Note: cannot change from a uniform -> non-uniform bandwidth

  ksize			: automatic bandwidth selection via a number of methods
    LCV			: 1D search using max leave-one-out likelihood criterion
    HALL		: Plug-in estimator with good asymptotics; MISE criterion
    ROT,MSP		: Fast standard-deviaion based methods; AMISE criterion
    LOCAL		: Like LCV, but makes BW propto k-th NN distance (k=sqrt(N))

  getPoints(kde)	: Ndim x Npoints array of kernel locations
  adjustPoints(p,delta) : shift points of P by delta (by reference!)

  getWeights		: [1 x Npts] array of kernel weights
  adjustWeights		: set kernel weights (by reference!)

  rescale(kde,alpha)	: rescale a KDE by the (vector) alpha

  getDim		: get the dimension of the data
  getNpts		: get the # of kernel locations
  getNeff		: "effective" # of kernels (accounts for non-uniform weights)

  sample(P,Np,KSType)	: draw Np new samples from P and set BW according to KSType


Display: (visualization / Description)
=====================================================
  plot(kde...)		: plot the specified dimensions of the KDE locations
  hist(kde...)		: discretize the kde at uniform bin lengths
  display		: text output describing the KDE
  double		: boolean evaluation of the KDE (non-empty)


Statistics:  (useful stats & operations on a kde)
=====================================================
  covar			: find the (weighted) covariance of the kernel centers
  mean			: find the (weighted) mean of the kernel centers
  modes			: (attempt to) find the modes of the distribution

  knn(kde, points, k)   : find the k nearest neighbors of each of
			    points in kde

  entropy		: estimate the entropy of the KDE
          ??? Maybe be able to specify alternate entropy estimates? Distance, etc?
  kld			: estimate divergence between two KDEs
  ise			: eval/estimate integrated square difference between two KDEs

  evaluate(kde, x[,tol]): evaluate KDE at a set of points x
  evaluate(p, p2 [,tol]):  "" "", x = p2.pts (if we've already built a tree)

  evalIFGT(kde, x, N)   : same as above, but use the (very fast) Nth order improved 
  evalIFGT(p, p2, N)    : Fast Gauss transform.  Req's uniform-BW Gaussian kernels.
  
  evalAvgLogL(kde, x)	: compute Mean( log( evaluate(kde, x) ))
  evalAvgLogL(kde, kde2):   "" "" but use the weights of kde2
  evalAvgLogL(kde)      : self-eval; leave-one-out option

  llGrad(p,q)		: find the gradient of log-likelihood for p
			    evaluated at the points of q
  llHess(p,q)		: find the Hessian of log-likelihood of p at q
  entropyGrad(p)	: estimate gradient of entropy (uses llGrad)
  miGrad(p,dim)		: "" for mutual information between p(dim), p(~dim)
  klGrad(p1,p2) 	: estimate gradient direction of KL-divergence



Mixture products: (NBP stuff)
=====================================================
GAUSSIAN KERNELS ONLY

productApprox		: accessor for other product methods

  prodSampleExact	: sample N points exactly (N^d computation)
  prodSampleEpsilon	: kd-tree epsilon-exact sampler
  prodSampleGibbs1	: seq. index gibbs sampler
  prodSampleGibbs2	: product of experts gibbs sampler
  prodSampleGibbsMS1	: multiresolution version of GS1
  prodSampleGibbsMS2	: multiresolution version of GS2
  prodSampleImportance 	: importance sampling
  prodSampleImportGauss	: gaussian importance sampling

productExact		: exact computation (N^d kernel centers)


=====================================================
USAGE EXAMPLES
=====================================================

The demonstration programs @kde/examples/demo_kde_#.m may be helpful.


=====================================================
COPYRIGHT / LICENSE
=====================================================
The kde package and all code were written by Alex Ihler and Mike Mandel,
and are copyrighted under the (lesser) GPL:
  Copyright (C) 2003  Alexander Ihler

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU Lesser General Public License
as published by the Free Software Foundation; version 2.1 or later.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

The authors may be contacted via email at: ihler@mit.edu

