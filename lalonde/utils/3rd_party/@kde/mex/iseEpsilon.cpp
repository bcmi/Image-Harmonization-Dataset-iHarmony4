/***********************************************************************
** ISE evaluation MEX code (taken from multi-tree epsilon product)
**
**
***********************************************************************/
//
// Written by Alex Ihler and Mike Mandel
// Copyright (C) 2003 Alexander Ihler; distributable under GPL -- see README.txt
//


#define MEX
#include <math.h>
#include "mex.h"
#include "cpp/BallTreeDensity.h"

void multiEval(void);
void computeSigVals(void);
double normConstant(void);

// a little addressing formula: 
//   to access a^th dimension of density pair (b,c)'s constant
#define SIGVALSMAX(a,b,c) (SigValsMax + a+Ndim*b+Ndim*Ndens*c)
#define SIGVALSMIN(a,b,c) (SigValsMin + a+Ndim*b+Ndim*Ndens*c)
double *SigValsMax, *SigValsMin;

BallTreeDensity *trees;    // structure of all trees
BallTree::index *ind;      // indices of this level of the trees

double *C,*sC,*M;

double *randunif1, *randunif2, *randnorm;  // required random numbers
double *samples;
BallTree::index *indices;    // return data

double maxErr;                 // epsilon tolerance (%) of algorithm
double total, soFar, soFarMin; // partition f'n and accumulation

unsigned int Ndim,Ndens;   // useful constants
unsigned long Nsamp;
bool bwUniform;

#ifdef MEX
//////////////////////////////////////////////////////////////////////
// MEX WRAPPER
//////////////////////////////////////////////////////////////////////
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  mxArray *rNorm, *rUnif1, *rUnif2, *rsize;
  double *ISE;
  double rUnif = 1;
  BallTreeDensity tempTree;
  unsigned int i,j;
  
  /*********************************************************************
  ** Verify arguments and initialize variables
  *********************************************************************/

  if (nrhs != 3)
    mexErrMsgTxt("Takes 3 input arguments");
  if (nlhs >  1)
    mexErrMsgTxt("Outputs 1 results");

  Ndens = 2;
  trees = (BallTreeDensity*) mxMalloc(Ndens*sizeof(BallTreeDensity));
  bwUniform = true;
  bool allGaussians = true;
  for (i=0;i<Ndens;i++) {                               // load densities
    trees[i] = BallTreeDensity( prhs[i] );  
    if (trees[i].getType() != BallTreeDensity::Gaussian) allGaussians = false;
    bwUniform = bwUniform && trees[i].bwUniform();
  }
  if (!allGaussians)
    mexErrMsgTxt("Sorry -- only Gaussian kernels supported");

  Ndim  = trees[0].Ndim();                      // more accessible dimension variable
  maxErr= 2*mxGetScalar(prhs[2]);               // epsilon (we always use 2*epsilon)

  plhs[0] = mxCreateDoubleMatrix(1,1,mxREAL);
  ISE = (double*) mxGetData(plhs[0]);

  Nsamp = 0; randunif1 =&rUnif; randunif2 =&rUnif; randnorm =&rUnif; // something positive
  SigValsMax = (double*) mxMalloc(Ndim*Ndens*Ndens*sizeof(double));  // precalc'd constants
  SigValsMin = (double*) mxMalloc(Ndim*Ndens*Ndens*sizeof(double));  // precalc'd constants
  C       = (double*) mxMalloc(Ndim*sizeof(double));
  sC      = (double*) mxMalloc(Ndim*sizeof(double));
  M       = (double*) mxMalloc(Ndim*sizeof(double));

  total =    -1; soFar = soFarMin = 0;   multiEval();  // compute cross-density terms
  *ISE = -2*soFar*normConstant(); tempTree = trees[1]; trees[1] = trees[0]; 
  total =    -1; soFar = soFarMin = 0;   multiEval();  // add square of 1st density
  *ISE += soFar*normConstant();   trees[1] = tempTree; tempTree = trees[0]; trees[0] = trees[1];
  total =    -1; soFar = soFarMin = 0;   multiEval();  // and square of 2nd density
  *ISE += soFar*normConstant();   trees[0] = tempTree;

  mxFree(trees);
  mxFree(C); mxFree(sC); mxFree(M); mxFree(SigValsMin); mxFree(SigValsMax);
}
#endif


double normConstant(void) {
  unsigned int i,j;
  double tmp, normConst;
  const double pi = 3.141592653589;
  
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
      for (i=0;i<Ndens;i++) tmp += 1/trees[i].bwMin(0)[j];  // compute result bandwidth
      normConst /= sqrt(tmp);                               // and its norm factor
    }
  }
  return normConst;
}


//////////////////////////////////////////////////////////////////////////
// calculate bounds on the min/max distance possible between two ball-trees
//   return un-exponentiated values
//
double minDistProd(const BallTreeDensity& bt1, BallTree::index i,
                   const BallTreeDensity& bt2, BallTree::index j,
                   const double* SigValIJ,const double* SigNIJ)             //  precomp'd weighting factors
{
  double result=0;
  const double *center1, *center2;

  center1 = bt1.center(i); center2 = bt2.center(j);
  for (unsigned int k=0;k<Ndim;k++) {
    double tmp = fabs( center1[k] - center2[k] );
    tmp-= bt1.range(i)[k] + bt2.range(j)[k];
    if (tmp < 0) tmp = 0;
    result -= (tmp*tmp) * SigValIJ[k];
    if (!bwUniform) result += log(SigNIJ[k]); // !!! no should be min Sig val not max
  }
  result /= 2;
  return result;
}

double maxDistProd(const BallTreeDensity& bt1, BallTree::index i,
                   const BallTreeDensity& bt2, BallTree::index j,
                   const double* SigValIJ,const double* SigNIJ)             //  precomp'd weighting factors
{
  double result=0;
  const double *center1, *center2;

  center1 = bt1.center(i); center2 = bt2.center(j);
  for (unsigned int k=0;k<Ndim;k++) {
    double tmp = fabs( center1[k] - center2[k] );
    tmp+= bt1.range(i)[k] + bt2.range(j)[k];
    result -= (tmp*tmp) * SigValIJ[k];
    if (!bwUniform) result += log(SigNIJ[k]); // !!! no should be max Sig val not min
  }
  result /= 2;
  return result;
}

// Compute (1 over) the \Lambda_(i,j) values needed for distance-weight computations
// 
void computeSigVals(void) {
  unsigned int i,j,k;
  double *SigNormMin = (double*) mxMalloc(Ndim*sizeof(double));
  double *SigNormMax = (double*) mxMalloc(Ndim*sizeof(double));
  for (i=0;i<Ndim;i++) {
    SigNormMin[i] = SigNormMax[i] = 0;
    for (j=0;j<Ndens;j++) SigNormMin[i]+=1/trees[j].bwMin(ind[j])[i]; // compute \Lambda_L 
    for (j=0;j<Ndens;j++) SigNormMax[i]+=1/trees[j].bwMax(ind[j])[i]; //
    SigNormMax[i] = 1/SigNormMax[i]; SigNormMin[i] = 1/SigNormMin[i];
  }
  for (i=0;i<Ndim;i++) {
    for (j=0;j<Ndens;j++)                                    //  then compute pairwise leave-
      for (k=j;k<Ndens;k++) {                                //  two-out normalized values
        *SIGVALSMIN(i,k,j) = SigNormMax[i] / (trees[j].bwMin(ind[j])[i]*trees[k].bwMin(ind[k])[i]);
        *SIGVALSMAX(i,k,j) = SigNormMin[i] / (trees[j].bwMax(ind[j])[i]*trees[k].bwMax(ind[k])[i]);
        *SIGVALSMIN(i,j,k) = *SIGVALSMIN(i,k,j);             //  make symmetric
        *SIGVALSMAX(i,j,k) = *SIGVALSMAX(i,k,j);
      }
  }
//  delete[] SigNorm;  //(don't need this anymore)
  mxFree(SigNormMin);
  mxFree(SigNormMax);

}

void multiEvalRecursive(void) {
  unsigned int i,j;
  double minVal=0, maxVal=0;                    // for computing bounds and 
  unsigned int maxInd0, maxInd1;  //  determining which tree to split

  //
  // find min/max values of product
  //
  if (!bwUniform) computeSigVals();

  double maxDiscrep = -1;
  bool allLeaves = true;
  for (i=0; i<Ndens; i++) {                       // For each pair of densities, bound
    for (j=i+1;j<Ndens;j++) {                     //   the total weight of their product:
      double maxValT = minDistProd(trees[i],ind[i],trees[j],ind[j],SIGVALSMAX(0,i,j),SIGVALSMIN(0,i,j));  // compute min & max
      double minValT = maxDistProd(trees[i],ind[i],trees[j],ind[j],SIGVALSMIN(0,i,j),SIGVALSMAX(0,i,j));  // dist = max/min values
      maxVal += maxValT; minVal += minValT;

      if ((maxValT - minValT) > maxDiscrep) {           // also find which pair
        maxDiscrep = maxValT - minValT;                 //   has the largest
        maxInd0=i; maxInd1=j;                           //   discrepancy (A/B)
      }
    }
    allLeaves = allLeaves && trees[i].isLeaf(ind[i]);
  }
  maxVal = exp(maxVal); minVal = exp(minVal);

  // If the approximation is good enough,
  if (allLeaves || fabs(maxVal - minVal) <= maxErr * (soFarMin+minVal) ) {  // APPROXIMATE
    double add = (maxVal + minVal)/2;                   // compute contribution
    for (i=0;i<Ndens;i++) add *= trees[i].weight(ind[i]);
    soFar += add;
    add = minVal; for (i=0;i<Ndens;i++) add *= trees[i].weight(ind[i]);
    soFarMin += add;

    while (*randunif1 <= soFar/total) {                 // for all the samples coming from this block
      randunif1++;
      for (j=0;j<Ndim;j++) M[j] = 0;                    // clear out M
      if (!bwUniform) for (j=0;j<Ndim;j++) C[j] = 0;    // clear out C if necc.

      for (i=0;i<Ndens;i++) {                           // find an index within this block
        double SumTmp = 0;
        BallTree::index index = trees[i].leafFirst(ind[i]);  // start with 1st leaf and
        for (;index <= trees[i].leafLast(ind[i]);index++) {
          SumTmp += trees[i].weight(index) / trees[i].weight(ind[i]);
          if (SumTmp > *randunif2) break;
        }
        randunif2++;
        for (j=0;j<Ndim;j++)                                 // compute product mean:
          M[j] += trees[i].center(index)[j] / trees[i].bw(index)[j];
        *(indices++) = trees[i].getIndexOf(index);           // and save selected indices
        if (!bwUniform) for (j=0;j<Ndim;j++)                 // compute covariance
            C[j] += 1/trees[i].bw(index)[j];                 //  contribution of each dens.
      }
      if (!bwUniform) for (j=0;j<Ndim;j++) {                 // finish computing covar and
          C[j] = 1/C[j];                                     //  std dev. of product kernel
          sC[j] = sqrt(C[j]);
      }

      for (j=0;j<Ndim;j++) M[j] *= C[j];
      for (j=0;j<Ndim;j++)                              // sample from the product dist.
        *(samples++) = M[j] + sC[j] * (*(randnorm++));
    }

  // Otherwise, we need to subdivide at least one tree:
  } else {                                              // RECURSION  
    unsigned int split;
    double size0 = trees[maxInd0].range(ind[maxInd0])[0];  // from the pair with the largest
    double size1 = trees[maxInd1].range(ind[maxInd1])[0];  // pairwise max-min discrepancy term,

    for(BallTree::index k=0; k<trees[maxInd0].Ndim(); k++)
      if(trees[maxInd0].range(ind[maxInd0])[k] > size0)
	size0 = trees[maxInd0].range(ind[maxInd0])[k];
    for(BallTree::index k=0; k<trees[maxInd1].Ndim(); k++)
      if(trees[maxInd1].range(ind[maxInd1])[k] > size1)
	size1 = trees[maxInd1].range(ind[maxInd1])[k];    

    split = (size0 > size1) ? maxInd0 : maxInd1;        // take the largest.
    
    BallTree::index current = ind[split];
    if (!trees[split].isLeaf(current)) {
      ind[split] = trees[split].left(current);  
      multiEvalRecursive();                             // recurse left 
      ind[split] = trees[split].right(current);         //   and right tree
      multiEvalRecursive();                             // restore indices 
      ind[split] = current;                             //   for calling f'n
    }                                                   
  }
}


void multiEval(void) {
  unsigned int i,j,k;
//  ind = new BallTree::index[Ndens];               // construct index array  
  ind = (BallTree::index*) mxMalloc(Ndens*sizeof(BallTree::index));    // construct index array  
  for (i=0;i<Ndens;i++) ind[i] = trees[i].root(); //  & init to root node

  if (bwUniform) {                                     // if all one kernel size, do this in
    computeSigVals();                                  //   one operation.
    for (i=0;i<Ndim;i++) {                             // compute covariance and
      double tmp = 0;                                  //   std. deviation of a
      for (j=0;j<Ndens;j++)                            // resulting product kernel 
        tmp += 1/trees[j].bw(trees[j].leafFirst(trees[j].root()))[i]; 
      C[i] = 1/tmp;
      sC[i] = sqrt(C[i]);
    }
  }

  multiEvalRecursive();

//  delete[] ind;
  mxFree(ind);
}

