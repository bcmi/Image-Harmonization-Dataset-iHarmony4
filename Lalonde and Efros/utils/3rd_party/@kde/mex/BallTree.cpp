//
// Matlab MEX interface for KD-tree C++ functions
//
// Written by Alex Ihler and Mike Mandel
// Copyright (C) 2003 Alexander Ihler; distributable under GPL -- see README.txt
//

#define MEX
#include "cpp/BallTree.h"
#include "mex.h"

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{

  // check for the right number of arguments
  if(nrhs != 2)
    mexErrMsgTxt("Takes 2 input arguments");
  if(nlhs != 1)
    mexErrMsgTxt("Outputs one result (a structure)");

//                                   points, weights
  plhs[0] = BallTree::createInMatlab(prhs[0],prhs[1]);

}
