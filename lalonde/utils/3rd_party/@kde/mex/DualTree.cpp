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
  if (nrhs > 3 || nrhs < 2)
    mexErrMsgTxt("Takes 2-3 input arguments");
  if (nlhs > 1)
    mexErrMsgTxt("Outputs 1 results");

  BallTreeDensity densTree = BallTreeDensity(prhs[0]);
  if (nrhs == 3) {                                            // REGULAR VERSION
    BallTree      atTree   = BallTree(prhs[1]);
    double maxErr= mxGetScalar(prhs[2]);
    plhs[0] = mxCreateDoubleMatrix(1,atTree.Npts(),mxREAL);   // allocate return vals
    densTree.evaluate(atTree, mxGetPr(plhs[0]), maxErr);      //  and evaluate

  } else {                                                    // LEAVE-ONE-OUT VERSION
    double maxErr= mxGetScalar(prhs[1]);
    plhs[0] = mxCreateDoubleMatrix(1,densTree.Npts(),mxREAL); // allocate return vals
    densTree.evaluate(mxGetPr(plhs[0]), maxErr);              //  and evaluate
  }    

}
