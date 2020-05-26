//
// Matlab MEX interface for KD-tree C++ functions
//
// Written by Alex Ihler and Mike Mandel
// Copyright (C) 2003 Alexander Ihler; distributable under GPL -- see README.txt
//

#define MEX
#include "mex.h"
#include "cpp/BallTreeDensity.h"

void gibbs1(unsigned int _Ndens, const BallTreeDensity* _trees, 
            unsigned long Np, unsigned int Niter,
            double *_pts, BallTree::index *_ind,
            double *_randU, double* _randN);
void gibbs2(unsigned int _Ndens, const BallTreeDensity* _trees, 
            unsigned long Np, unsigned int Niter,
            double *_pts, BallTree::index *_ind,
            double *_randU, double* _randN);

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  mxArray **analyticFnParam;
  mxArray *aRandVec, *aRandVecN;
  mxArray *aRandParam;
  double *pRandParam, *randU, *randN;

  mxArray *pointsM, *weightsM, *indicesM;
  double *points, *weights;
  BallTree::index* indices;

  unsigned int i;
  unsigned int Niter,Ndens,Ndim,Np;
  
  /*********************************************************************
  ** Verify arguments and initialize variables
  *********************************************************************/

  if (nrhs < 3)
    mexErrMsgTxt("Takes 3-5 input arguments");
  if (nlhs != 2)
    mexErrMsgTxt("Outputs 2 results");

  Ndens = mxGetN(prhs[0]);               // get # of densities

  /*********************************************************************
  ** Transform Matlab cell arrays into struct NPD representation
  *********************************************************************/

  BallTreeDensity *trees = new BallTreeDensity[Ndens];
  bool allGaussians = true;
  for (i=0; i < Ndens; i++) {
    trees[i] = BallTreeDensity( mxGetCell(prhs[0],i) );
    if (trees[i].getType() != BallTreeDensity::Gaussian) allGaussians = false;
  }
  if (!allGaussians)
    mexErrMsgTxt("Sorry -- only Gaussian kernels supported");

  Ndim  = trees[0].Ndim();          //  # of dimensions  
  Np    = (unsigned long) mxGetScalar(prhs[1]);     //  # of points to sample
  Niter = (unsigned int)  mxGetScalar(prhs[2]);     //  # of gibbs iterations

  if ((nrhs < 5) || (mxGetN(prhs[3]) == 0)) {   // load analytic function
    analyticFnParam = NULL;                     //   params if required
  }
  else {
    analyticFnParam = (mxArray**) mxMalloc(3*sizeof(mxArray*));
    analyticFnParam[0] = (mxArray*) prhs[3];
    analyticFnParam[1] = (mxArray*) prhs[4];
  }

  pointsM = plhs[0] = mxCreateDoubleMatrix(Ndim, Np, mxREAL);   // set up matlab output
  points  = (double*) mxGetData(plhs[0]);
//  plhs[1] = mxCreateDoubleMatrix(1, Np, mxREAL);
//  weights = (double*) mxGetData(plhs[1]);
  plhs[1] = mxCreateNumericMatrix(Ndens, Np, mxUINT32_CLASS, mxREAL);
  indices = (BallTree::index*) mxGetData(plhs[1]);

  unsigned long maxNp = Np;             // largest # of particles we deal with
  for (unsigned int j=0; j<Ndens; j++)  // compute Max Np over all densities
    if (maxNp < trees[j].Npts()) maxNp = trees[j].Npts();
  unsigned int Nlevels = (unsigned int) (log(maxNp)/log(2))+1;  // how many levels to a balanced binary tree?

  // Generate enough random numbers to get us through the rest of this
  aRandParam = mxCreateDoubleMatrix(1, 2, mxREAL);
  pRandParam = mxGetPr(aRandParam);
  pRandParam[0] = 1;  pRandParam[1] = Np*Ndens*(Niter+1)*Nlevels;
  mexCallMATLAB(1, &aRandVec, 1, &aRandParam, "rand");   randU = mxGetPr(aRandVec);
  pRandParam[0] = 1;  pRandParam[1] = Ndim*Np*(Niter+1)*Nlevels;
  mexCallMATLAB(1, &aRandVecN, 1, &aRandParam, "randn"); randN = mxGetPr(aRandVecN);
  mxDestroyArray(aRandParam);

  // Params:  Ndens, trees, points, weights, indices, randomU, randomN
  gibbs2(Ndens,trees,Np,Niter,points,indices, randU,randN);

  delete[] trees;

  if (analyticFnParam != NULL)
    mxFree(analyticFnParam);

  mxDestroyArray(aRandVec);
  mxDestroyArray(aRandVecN);
}
