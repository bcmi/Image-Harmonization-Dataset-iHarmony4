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
  if (nrhs > 2 || nrhs < 2)
    mexErrMsgTxt("Takes 2 input arguments");
  if (nlhs != 0)
    mexErrMsgTxt("Outputs no results; modifies passed kde by reference.");

  BallTreeDensity densTree = BallTreeDensity(prhs[0]);
  double* delta = (double*) mxGetData(prhs[1]);
  densTree.movePoints(delta);
}
