/***********************************************************************
** exact sampling MEX file
**
**  Calculate the partition function and sample Nsamp times
**    in O(N^d) time, O(d) storage
**
***********************************************************************/
//
// Written by Alex Ihler and Mike Mandel
// Copyright (C) 2003 Alexander Ihler; distributable under GPL -- see README.txt
//


#define MEX
#include <assert.h>
#include "cpp/BallTreeDensity.h"
#include "mex.h"

void exactEval(void);
double normConstant(void);
//void exactInit(void);

//
// Make recursion-independent variables global for simplicity
//
BallTreeDensity *trees;       // structure of all trees

double *samples;
BallTree::index *indices;       // return data -- samples & indices

double *randnorm, *randunif;  // random numbers; gaussian & sorted uniform

double total, soFar;          // partition function value & counter

unsigned int Ndim,Ndens;      // common size variables
unsigned long Nsamp;
bool bwUniform;

#ifdef MEX
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  mxArray *rsize, *rUnif, *rNorm; double *rsizeP;   // random # call vars
  unsigned int i,j;
  
  /*********************************************************************
  ** Verify arguments and initialize variables
  *********************************************************************/

  if (nrhs != 2)
    mexErrMsgTxt("Takes 2 input arguments");
  if (nlhs >  2)
    mexErrMsgTxt("Outputs 2 results");

  Ndens = (unsigned int) mxGetN(prhs[0]);               // get # of densities

  trees = new BallTreeDensity[Ndens];
  bwUniform = true;
  bool allGaussians = true;
  for (i=0;i<Ndens;i++) {                               // load densities
    trees[i] = BallTreeDensity( mxGetCell(prhs[0],i) );  
    if (trees[i].getType() != BallTreeDensity::Gaussian) allGaussians = false;
    bwUniform = bwUniform && trees[i].bwUniform();
  }
  if (!allGaussians)
    mexErrMsgTxt("Sorry -- only Gaussian kernels supported");

  Ndim = trees[0].Ndim();               // globally accessible dimension variable
  Nsamp = (unsigned long) mxGetScalar(prhs[1]);         // get requested # of samples

  // Create enough gaussian and (sorted) uniform samples to get us through
  //   the rest of the code:
  rsize = mxCreateDoubleMatrix(1,2,mxREAL);
  rsizeP= mxGetPr(rsize); rsizeP[0] = 1; rsizeP[1] = Nsamp+1;
  rUnif = mxCreateDoubleMatrix(1,Nsamp+1,mxREAL);
  mexCallMATLAB(1, &rNorm, 1, &rsize, "rand");   randunif = mxGetPr(rNorm);
  randunif[Nsamp] = 100;
  mexCallMATLAB(1, &rUnif, 1, &rNorm, "sort");   randunif = mxGetPr(rUnif);
  mxDestroyArray(rNorm);
  rsizeP[0] = Ndim; rsizeP[1] = Nsamp;
  mexCallMATLAB(1, &rNorm, 1, &rsize, "randn");  randnorm = mxGetPr(rNorm);

  // Make a return location for the samples
  plhs[0] = mxCreateDoubleMatrix(Ndim,Nsamp,mxREAL);
  samples = (double*) mxGetData(plhs[0]);
  plhs[1] = mxCreateNumericMatrix(Ndens,Nsamp,mxUINT32_CLASS,mxREAL);
  indices = (BallTree::index*) mxGetData(plhs[1]);

  total =    -1; soFar = 0; exactEval();          // recurse to get partition value
  total = soFar; soFar = 0; exactEval();          // recurse on trees to sample

  mxDestroyArray(rUnif); mxDestroyArray(rNorm); mxDestroyArray(rsize);

  delete[] trees;
}
#endif

double normConstant(void) {
  unsigned int i,j;
  double tmp,normConst;
  const double pi=3.141592653589;
  
  normConst = 1;                               // precalculate influence of normalization
  tmp = pow(2*pi,((double)Ndim)/2);
  for (i=0;i<Ndens;i++) {                      // divide by norm fact of each indiv. gauss.
    normConst /= tmp;
    if (bwUniform) for (j=0;j<Ndim;j++) {
      normConst /= sqrt(trees[i].bwMin(0)[j]);
    }
  }
  normConst *= tmp;                            // times norm factor of resulting gaussian
  for (j=0;j<Ndim;j++) {
    tmp = 0;
    if (bwUniform) {
      for (i=0;i<Ndens;i++) tmp += 1/trees[i].bwMin(0)[j];     // compute result bandwidth
      normConst /= sqrt(tmp);                               // and its norm factor
    }
  }
  return normConst;
}

void exactEval(void) {
  unsigned int i,j;

  BallTree::index *ind = new BallTree::index[Ndens];  // current data indices
  double *M = new double[Ndim];
  double *C = new double[Ndim];
  double *sC= new double[Ndim];

if (bwUniform) {                    // IF THIS IS THE SAME FOR ALL INDICES
  for (j=0;j<Ndim;j++) {            // Find variance of each product kernel
    double tmp = 0;                 // 
    for (i=0;i<Ndens;i++) 
      tmp += 1/trees[i].bw(trees[i].leafFirst(trees[i].root()))[j];
    C[j] = 1/tmp;
    sC[j] = sqrt(C[j]);             // also find std. deviation value
  }
}

  for (i=0;i<Ndens;i++) 
    ind[i] = trees[i].leafFirst( trees[i].root() ); // initialize indices
  
  do {                              //   for all combos of input indices  

    if (!bwUniform) {               // IF THIS IS NOT THE SAME FOR ALL INDICES
      for (j=0;j<Ndim;j++) {            // Find variance of each product kernel
        double tmp = 0;                 // 
        for (i=0;i<Ndens;i++) 
          tmp += 1/trees[i].bw(ind[i])[j];
        C[j] = 1/tmp;
        sC[j] = sqrt(C[j]);             // also find std. deviation value
      }
    }
   
    for (j=0;j<Ndim;j++) {          
      M[j] = 0;                     // Find mean of the product kernel
      for (i=0;i<Ndens;i++)
        M[j] += trees[i].mean(ind[i])[j] / trees[i].bw(ind[i])[j];
    }
    for (j=0;j<Ndim;j++) M[j] *= C[j];
  
    double p = 1;
    for (i=0;i<Ndens;i++) {
      p *= trees[i].weight(ind[i]);               // calculate contribution of
      double sum = 0;                             //   each component to weight
      for (j=0;j<Ndim;j++) {                      //   of this product element
        double tmp = trees[i].center(ind[i])[j] - M[j];
        sum -= tmp*tmp / trees[i].bw(ind[i])[j];
        if (!bwUniform) sum -= log(trees[i].bw(ind[i])[j]);
      }
      p *= (double) exp(sum/2);                   // p is prop. to weight of this gaussian
    }
    if (!bwUniform) for (j=0;j<Ndim;j++) p*=sC[j];
    soFar += p;                                   // keep a running tab on the total weight
    
    while (*randunif <= soFar/total) {            // if this index is a sample
      randunif++;                                 // (or more than one)
      for (i=0;i<Ndim;i++)                        // draw from its gaussian
        *(samples++) = M[i] + sC[i] * (*(randnorm++));
      for (i=0;i<Ndens;i++)                       // save its indices
        *(indices++) = trees[i].getIndexOf(ind[i])+1; 
    }
    
    ind[0]++;                                     // increment indices 
    for (i=0;i<Ndens-1;i++) {                     //  checking for wrap-around
      if (!trees[i].validIndex(ind[i])) { 
        ind[i] = trees[i].leafFirst( trees[i].root() );
        ind[i+1]++;
      }
    }
  } while (trees[Ndens-1].validIndex(ind[Ndens-1])); // test for end-of-loop

  delete[] ind;                                     // free allocated memory
  delete[] M; delete[] C; delete[] sC;
}

