//
// Matlab MEX interface for KD-tree C++ functions
//
// Written by Alex Ihler and Mike Mandel
// Copyright (C) 2003 Alexander Ihler; distributable under GPL -- see README.txt
//

#define MEX
#include "cpp/BallTreeDensity.h"
#include "mex.h"

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  if(nrhs > 3 || nrhs < 2)
    mexErrMsgTxt("Takes 2 or 3 arguments");
  if(nlhs > 2)
    mexErrMsgTxt("Outputs 2 or fewer results");

  if(*mxGetPr(mxGetField(prhs[0], 0, "D")) != mxGetM(prhs[1]))
    mexErrMsgTxt("Search points have different number of dimensions from tree points.");

  mxArray *nns, *dists;
  BallTree::index *nn_array;

  BallTreeDensity findingIn = BallTreeDensity(prhs[0]);
  double *findingFrom = mxGetPr(prhs[1]);

  int k = 1;
  if(nrhs == 3)
    k = (int)mxGetScalar(prhs[2]);

  int N = mxGetN(prhs[1]);
  nns = mxCreateNumericMatrix(k, N, mxUINT32_CLASS, mxREAL);
  dists = mxCreateDoubleMatrix(1, N, mxREAL);
  nn_array = (BallTree::index *)mxGetData(nns);

  findingIn.kNearestNeighbors(nn_array, mxGetPr(dists), findingFrom, N, k);

  plhs[0] = nns;
  // convert to matlab indices
  for(BallTree::index i=0; i<N*k; i++)
    if(nn_array[i] != BallTree::NO_CHILD)
      nn_array[i]++;

  if(nlhs >= 2)
    plhs[1] = dists;
}
