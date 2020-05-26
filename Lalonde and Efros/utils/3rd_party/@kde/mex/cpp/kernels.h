/////////////////////////////////////////////////////////////////////
// Find the kernel values at the minimum or maximum possible distance 
// between points in the aRoot-th ball in atTree 
// and the dRoot-th ball in the densTree 
// 3 Possible Kernels : Gaussian, Laplacian, Epanetchnikov
//   Takes account of possible non-uniform bandwidth values
/////////////////////////////////////////////////////////////////////
//
// Written by Alex Ihler and Mike Mandel
// Copyright (C) 2003 Alexander Ihler; distributable under GPL -- see README.txt
//
/////////////////////////////////////////////////////////////////////

double BallTreeDensity::minDistGauss(BallTree::index dRoot,
                  const BallTree& atTree, BallTree::index aRoot) const
{
  unsigned int k;
  double tmp,result=0;
  const double *atCenter, *densCenter, *bw;

  atCenter = atTree.center(aRoot); densCenter = center(dRoot);
  bw = bwMax(dRoot);
  for (k=0; k<atTree.Ndim(); k++) {
    tmp = fabs( atCenter[k] - densCenter[k] );
    tmp-= atTree.range(aRoot)[k] + range(dRoot)[k];
    tmp = (tmp > 0) ? tmp : 0;
    if (bwUniform()) result -= (tmp*tmp)/bw[k];
    else             result -= (tmp*tmp)/bw[k] + log(bwMin(dRoot)[k]);
  }
  result = exp(result/2);
  return result;
}

double BallTreeDensity::maxDistGauss(BallTree::index dRoot,
                  const BallTree& atTree, BallTree::index aRoot) const
{
  unsigned int k;
  double tmp,result=0;
  const double *atCenter, *densCenter, *bw;

  atCenter = atTree.center(aRoot); densCenter = center(dRoot);
  bw = bwMin(dRoot);
  for (k=0; k<atTree.Ndim(); k++) {
    tmp = fabs( atCenter[k] - densCenter[k] );
    tmp+= atTree.range(aRoot)[k] + range(dRoot)[k];
    if (bwUniform()) result -= (tmp*tmp)/bw[k];
    else             result -= (tmp*tmp)/bw[k] + log(bwMax(dRoot)[k]);
  }
  result = exp(result/2);
  return result;
}

///////////////////////////////////////////////////////////////////
//  Laplacian Kernel (double exponential)
///////////////////////////////////////////////////////////////////

double BallTreeDensity::minDistLaplace(BallTree::index dRoot,
                  const BallTree& atTree, BallTree::index aRoot) const
{
  unsigned int k;
  double tmp,result=0;
  const double *atCenter, *densCenter, *bw;

  atCenter = atTree.center(aRoot); densCenter = center(dRoot);
  bw = bwMax(dRoot);
  for (k=0; k<atTree.Ndim(); k++) {
    tmp = fabs( atCenter[k] - densCenter[k] );
    tmp-= atTree.range(aRoot)[k] + range(dRoot)[k];
    tmp = (tmp > 0) ? tmp : 0;
    if (bwUniform()) result -= tmp/bw[k];
    else             result -= tmp/bw[k] + log(bwMin(dRoot)[k]);
  }
  result = exp(result);
  return result;
}

double BallTreeDensity::maxDistLaplace(BallTree::index dRoot,
                  const BallTree& atTree, BallTree::index aRoot) const
{
  unsigned int k;
  double tmp,result=0;
  const double *atCenter, *densCenter, *bw;

  atCenter = atTree.center(aRoot); densCenter = center(dRoot);
  bw = bwMin(dRoot);
  for (k=0; k<atTree.Ndim(); k++) {
    tmp = fabs( atCenter[k] - densCenter[k] );
    tmp+= atTree.range(aRoot)[k] + range(dRoot)[k];
    if (bwUniform()) result -= tmp/bw[k];
    else             result -= tmp/bw[k] + log(bwMax(dRoot)[k]);
  }
  result = exp(result);
  return result;
}

///////////////////////////////////////////////////////////////////
//  Epanetchnikov Kernel (truncated quadratic)
//
// slightly hacked -- dim is the dimension to leave out (only compute
//   1 if in bounds, 0 if not), necc. for product kernel derivatives.
///////////////////////////////////////////////////////////////////

double BallTreeDensity::minDistEpanetch(BallTree::index dRoot,
                  const BallTree& atTree, BallTree::index aRoot, int dim) const
{
  unsigned int k;
  double tmp,result=1;
  const double *atCenter, *densCenter, *bw;

  atCenter = atTree.center(aRoot); densCenter = center(dRoot);
  bw = bwMax(dRoot);
  for (k=0; k<atTree.Ndim(); k++) {
    tmp = fabs( atCenter[k] - densCenter[k] );
    tmp-= atTree.range(aRoot)[k] + range(dRoot)[k];
    tmp = (tmp > 0) ? tmp : 0;
    tmp = (tmp > bw[k]) ? bw[k] : tmp;
    if (k==dim) { if (tmp==bw[k]) result=0; continue;}
    if (bwUniform()) result *= 1-(tmp/bw[k])*(tmp/bw[k]);
    else             result *= (1-(tmp/bw[k])*(tmp/bw[k]))/bwMin(dRoot)[k];
  }
  return result;
}

double BallTreeDensity::maxDistEpanetch(BallTree::index dRoot,
                  const BallTree& atTree, BallTree::index aRoot, int dim) const
{
  unsigned int k;
  double tmp,result=1;
  const double *atCenter, *densCenter, *bw;

  atCenter = atTree.center(aRoot); densCenter = center(dRoot);
  bw = bwMin(dRoot);
  for (k=0; k<atTree.Ndim(); k++) {
    tmp = fabs( atCenter[k] - densCenter[k] );
    tmp+= atTree.range(aRoot)[k] + range(dRoot)[k];
    tmp = (tmp > bw[k]) ? bw[k] : tmp;
    if (k==dim) { if (tmp==bw[k]) result=0; continue;}
    if (bwUniform()) result *= 1-(tmp/bw[k])*(tmp/bw[k]);
    else             result *= (1-(tmp/bw[k])*(tmp/bw[k]))/bwMax(dRoot)[k];
  }
  return result;
}



/////////////////////////////////////////////////////////////////////
// Find upper and lower bounds on 1/p(yj) K'(xi-yj)
//   for any points yj in the aRoot-th ball of atTree 
//              and xi in the dRoot-th ball of densTree 
// 3 Possible Kernels : Gaussian, Laplacian, Epanetchnikov
//   Takes account of possible non-uniform bandwidth values
/////////////////////////////////////////////////////////////////////

void BallTreeDensity::dKdX_p(BallTree::index dRoot,const BallTree& atTree, 
			     BallTree::index aRoot, bool bothLeaves, 
			     Gradient gradType) const
{
  // Compute a maximum value of K'(yi-xj) for any pair: xj in dRoot, yi in aRoot
  //
  // e.g. Gaussian:  <----- K ------------------->  <------- D ------->
  //  K'(x) = exp(-sum( .5*(a[m]-d[m])^2/bw[m] ) ) * (a[k]-d[k])/bw[k]
  //
  // Crappy bound is  [ min(Kmax*Dmin,Kmin*Dmin), max(Kmax*Dmax,Kmin*Dmin) ]
  //
  const double *atCenter, *densCenter;
  double Kmin,Kmax;
  atCenter = atTree.center(aRoot); densCenter = center(dRoot);

//  printf("%d:%d \n",dRoot,aRoot);

  if (getType()!=Epanetchnikov) {                // for the exponential forms:
    if (!bothLeaves) {
      Kmin = maxDistKer(dRoot,atTree,aRoot);     // if non-leaf node need both
      Kmax = minDistKer(dRoot,atTree,aRoot);     //  values;
    } else                                         // leaf nodes, we know they're equal
      Kmax = Kmin = maxDistKer(dRoot,atTree,aRoot);//  so don't double-compute
  }
  
  for(unsigned int k=0;k<Ndim();k++) {
    double tmp = atCenter[k] - densCenter[k];
    double Dmax = tmp + range(dRoot)[k] + atTree.range(aRoot)[k];  // compute extremum of arguments
    double Dmin = tmp - range(dRoot)[k] - atTree.range(aRoot)[k];

    if (getType() == Epanetchnikov) {                        // non-exponential form
      Kmin = 2*maxDistEpanetch(dRoot,atTree,aRoot,k);        //  => leave out k^th dim
      Kmax = 2*minDistEpanetch(dRoot,atTree,aRoot,k);        //  when calculating
      if (!bwUniform()) { Kmax /= bwMin(dRoot)[k]; Kmin /= bwMax(dRoot)[k]; }
    }    

    if (getType() == Laplacian) {                              // non-quadratic form
      if (Dmin < 0) Dmin = -1;  if (Dmax < 0) Dmax = -1;       //  => sign(x-y) instead
      if (Dmin > 0) Dmin = +1;  if (Dmax > 0) Dmax = +1;       //  of (x-y)
    }                                                          

    double bwmax = bwMax(dRoot)[k], bwmin = bwMin(dRoot)[k];
    if (getType() == Epanetchnikov) {
      bwmax *= bwmax; bwmin *= bwmin;
    }

    if (gradType == WRTMean) {
      if (Dmin < 0)
	max[k] = -Kmax*Dmin/bwmin/pMin[aRoot];
      else
	max[k] = -Kmin*Dmin/bwmax/pMax[aRoot]; 
      
      if (Dmax < 0)
	min[k] = -Kmin*Dmax/bwmax/pMax[aRoot];
      else
	min[k] = -Kmax*Dmax/bwmin/pMin[aRoot];

    } else if(gradType == WRTWeight) {
      max[k] = -Kmax / pMin[aRoot];
      min[k] = -Kmin / pMax[aRoot];
      break;  // only need to do for the first dimension

    } else if(gradType == WRTVariance) {
      max[k] = -Kmax / pMin[aRoot] * (0.5 / bwmin) * (Dmax * Dmax / bwmin - 1);
      min[k] = -Kmin / pMax[aRoot] * (0.5 / bwmax) * (Dmin * Dmin / bwmax - 1);

    } else {
      max[k] = min[k] = 0;
    }
//    printf("  %d -- %f %f  -> %f / %f\n",k,Kmin,Kmax,min[k],max[k]);
  }
}  

