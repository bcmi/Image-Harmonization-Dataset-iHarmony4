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

  // check for the right number of arguments
  if((nrhs < 3)||(nrhs > 4))
    mexErrMsgTxt("Takes 3-4 input arguments");
  if(nlhs != 1)
    mexErrMsgTxt("Outputs one result (a structure)");

  if (nrhs == 3) //                          points, weights, bandwidths
    plhs[0] = BallTreeDensity::createInMatlab(prhs[0],prhs[1],prhs[2]);
  else {          //                          points, weights, bandwidths,type
    int ktype = (int) mxGetScalar(prhs[3]);
    plhs[0] = BallTreeDensity::createInMatlab(prhs[0],prhs[1],prhs[2],(BallTreeDensity::KernelType) ktype);
  }
}
