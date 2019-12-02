//
// Matlab MEX interface for KD-tree C++ functions
//
// Written by Alex Ihler and Mike Mandel
// Copyright (C) 2003 Alexander Ihler; distributable under GPL -- see README.txt
//

#include <math.h>
#include "mex.h"
#define MEX
#include "cpp/BallTreeDensity.h"

const double pi = 3.141592653589;
const double s2pi = .398942280401432; // = 1/sqrt(2*pi);
const double s2 = 1.414213562373095;  // = sqrt(2);

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  BallTreeDensity atTree, densTree;
  BallTreeDensity *target;
  double *gradD, *gradA;
  double tolGrad=1e-3, tolEval=1e-3;
  int Ndin;
  /*********************************************************************
  ** Verify arguments and initialize variables
  *********************************************************************/

  if ((nrhs > 5)||(nrhs < 2))
    mexErrMsgTxt("Takes 2-5 input arguments");
  if (nlhs > 2)
    mexErrMsgTxt("Outputs 1-2 results");

  if (!mxIsClass(prhs[0],"kde")) mexErrMsgTxt("Takes two KDE class variables");
  densTree = BallTreeDensity(prhs[0]);

  if (!mxIsClass(prhs[1],"kde")) {
    if (!mxIsDouble(prhs[1]) || (mxGetN(prhs[1])!= 1 || mxGetM(prhs[1])!=1)) 
      mexErrMsgTxt("Second argument must be a KDE or the gradient type (scalar double).");
    Ndin = 1; target = &densTree;
  } else {
    atTree   = BallTreeDensity(prhs[1]);
    Ndin = 2; target = &atTree;
  }

  if (nrhs < Ndin+1) mexErrMsgTxt("Requires gradient type argument (scalar).");

  int Nrows = densTree.Ndim();
  int gradWRTint = (int) mxGetScalar(prhs[Ndin]);
  BallTreeDensity::Gradient gradWRT = (BallTreeDensity::Gradient) gradWRTint;
  if(gradWRT == BallTreeDensity::WRTWeight)
    Nrows = 1;

  if (nrhs > Ndin+1) tolGrad  = mxGetScalar(prhs[Ndin+1]);
  if (nrhs > Ndin+2) tolEval = mxGetScalar(prhs[Ndin+2]);

  plhs[0] = mxCreateDoubleMatrix(Nrows,densTree.Npts(),mxREAL);
  gradD   = mxGetPr(plhs[0]);
  if (nlhs == 2) { 
    plhs[1] = mxCreateDoubleMatrix(Nrows,target->Npts(),mxREAL);
    gradA   = mxGetPr(plhs[1]);
  } else gradA = NULL;
  
  densTree.llGrad(*target,gradD,gradA,tolEval,tolGrad,gradWRT);
}

