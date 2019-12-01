//
// Matlab MEX interface for KD-tree C++ functions
//
// Written by Alex Ihler and Mike Mandel
// Copyright (C) 2003 Alexander Ihler; distributable under GPL -- see README.txt
//

#define MEX
#include <math.h>
#include "mex.h"
#include "cpp/BallTreeDensity.h"

void mexFunction(int nlhs, mxArray *plhs[],int nrhs, const mxArray *prhs[])
{
  // verify arguments
  if (nrhs != 2)
    mexErrMsgTxt("Takes 2 input arguments");
  if (nlhs != 0)
    mexErrMsgTxt("Outputs no results; modifies passed kde by reference.");

  BallTreeDensity densTree = BallTreeDensity(prhs[0]);
  int N = mxGetN(prhs[1]);
  int M = mxGetM(prhs[1]);

  if (N != densTree.Npts() && N != 1)
    mexErrMsgTxt("Wrong number of bandwidths");
  if (M != densTree.Ndim())
    mexErrMsgTxt("Wrong dimension for bandwidths");

  double* newBWs = mxGetPr(prhs[1]);
  if(densTree.getType() == BallTreeDensity::Gaussian) {
    double *newBWtmp = newBWs;
    newBWs = new double[M*N];
    for(BallTree::index i=0; i<M*N; i++)
      newBWs[i] = newBWtmp[i]*newBWtmp[i];
  }

  bool result;
  result = densTree.updateBW(newBWs, N);

  if(densTree.getType() == BallTreeDensity::Gaussian)
    delete[] newBWs;

  if (!result)
    mexErrMsgTxt("Can't change between uniform and non-uniform bandwidths");
}
