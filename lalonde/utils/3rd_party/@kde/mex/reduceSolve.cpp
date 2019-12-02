//
// Matlab MEX interface for "reduce" function QP solvers
//
// Written by Alex Ihler
// Copyright (C) 2003 Alexander Ihler; distributable under GPL -- see README.txt
//

#define MEX
#include "mex.h"
#include "math.h"
double fabs(double);

void SMO(double* Q, double* D, unsigned int N, double* weights);
bool searchPoint(unsigned int& I1, unsigned int I2,double* weights,double* Q,double* D,unsigned int N, double&);
bool updateWeight(unsigned int I1,unsigned int I2,double* weights,double dW, double* Q, unsigned int N);

void multUpdate(double* Q, double* D, unsigned int N, double* weights);

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  // check for the right number of arguments
  if((nrhs < 2)||(nrhs > 3))
    mexErrMsgTxt("Takes 2-3 input arguments");
  if(nlhs != 1)
    mexErrMsgTxt("Outputs one result");

  unsigned int N = mxGetN(prhs[0]);
  unsigned int type;
  if (nrhs == 3) type = (unsigned int) mxGetScalar(prhs[2]); else type = 2; // default SMO
  double* Q = mxGetPr(prhs[0]);
  double* D = mxGetPr(prhs[1]);
  plhs[0] = mxCreateDoubleMatrix(1, N, mxREAL);
  double* weights = mxGetPr(plhs[0]);
  switch (type) {
    case 1: mexErrMsgTxt("Sorry -- standard QP not implemented in MEX yet."); break;
    case 2: SMO(Q,D,N,weights); break;
    case 3: multUpdate(Q,D,N,weights); break;
  }
}


#define weightTolerance 1e-6
#define errorTolerance  1e-5
//
// Sequential Minimal Optimisation (SMO) algorithm for Reduced Set Density Estimation (RSDE).
//    Finds weights to minimize : 0.5*wts*Q*wts'- wts*D'
//
void SMO(double* Q, double* D, unsigned int N, double* weights)
{
  unsigned int i,j,numChanged=0,I1,I2;
  double wtMax, sD, error1, error2=1e10;
  double *weightsBACKUP;
  bool* examine; 
  bool done = false, loop=false;
  examine = (bool*) mxMalloc(N*sizeof(bool));

  bool firstTime=true;

  weightsBACKUP = (double*) mxMalloc(N*sizeof(double));
  for (i=0,sD=0;i<N;i++) sD += D[i];
  for (i=0;i<N;i++) weights[i] = D[i]/sD;
  for (i=0;i<N;i++) examine[i] = true;

  while (!done) {
    wtMax = -1;
    for (i=0;i<N;i++) {
      if (firstTime) if (weights[i] < weightTolerance) examine[i] = false;
      if (examine[i] && (wtMax < weights[i])) { 
        wtMax = weights[i]; I2 = i; 
      }
    }
    double wI1_old;
    for (i=0;i<N;i++) weightsBACKUP[i] = weights[i];
    if (searchPoint(I1,I2,weights,Q,D,N,wI1_old)) numChanged++;

    loop = true;
    examine[I2] = false;  // don't care about matching I1 & I2 now
    if (weights[I1] == wI1_old) examine[I1] = 0;
    for (i=0;i<N;i++) {                    // check if we're done:
      if (weights[i] == wtMax) examine[i] = false;  // don't care about the maximal weight
      if (weights[i] == weights[I1] && i!=I1) examine[i] = false;
      if (examine[i]) loop = false;        // if still some to look at, not yet done with this set!
    }
    firstTime = false;

    if (loop) {
        error1=0;
        for (i=0;i<N;i++) {
          double tmp = 0;
          for (j=0;j<N;j++)
            tmp += Q[i+N*j]*weights[j];
          error1 += .5*weights[i]*tmp - weights[i]*D[i];
        }
        if (error1 > error2) {
          for (i=0;i<N;i++) weights[i] = weightsBACKUP[i];
//          printf("Error got worse!\n"); //should do: alpha=alpha_bk;
          done=true;
        } else if (fabs(error1-error2) < errorTolerance) done = true;
        
        if (numChanged==0) done = true;   // if nothing changed, we can quit
        if (~done) {
          loop = false; numChanged = 0;   // back to pairwise optimization steps
          for (i=0;i<N;i++) examine[i] = true; // consider everything again
          firstTime = true;
          error2 = error1;                  //  save this as the new error
        }
    }
//    printf("  -- %f\n",error2);
//    mexCallMATLAB(0, NULL, 0, NULL, "pause"); 
  }
  mxFree(examine);
}

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
// Find the second point to be updated
bool searchPoint(unsigned int& I1, unsigned int I2,double* weights,double* Q,double* D,unsigned int N, double& wI1_old)
{
  double dW=0, dWabs=0, W1, W2;
  unsigned int i,j;
  I1 = I2;  // default is, do nothing
  W2 = 0; 
  for (j=0;j<N;j++)  W2 += weights[j] * Q[N*j + I2];
  W2 -= D[I2];
  for (i=0; i<N; i++) {
    if (weights[i] <= weightTolerance) continue;
    W1 = 0;
    for (j=0;j<N;j++)  W1 += weights[j] * Q[i + N*j];
    W1 -= D[i];
    if (fabs(W1-W2) > dWabs) {
      dWabs = fabs(W1-W2); dW = W1-W2; I1 = i;
    }
  }
  wI1_old = weights[I1];
  return updateWeight(I1,I2,weights,dW,Q,N);
}

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
// adjust the weights of I1,I2
bool updateWeight(unsigned int I1,unsigned int I2,double* weights,
                  double dW, double* Q, unsigned int N)
{
  double alph1, alph2;
  if (I1==I2) return false;
  if (dW==0) return false;
  if (weights[I1] < weightTolerance) return false;
  
  alph2=weights[I2] + dW / (Q[I1+N*I1]-2*Q[I1+N*I2]+Q[I2+N*I2]);
  if (alph2 < 0) alph2 = 0;
  alph1 = weights[I1]+weights[I2]-alph2;
  if (alph1 < 0) {
    alph1=0;
    alph2=weights[I1]+weights[I2];
  }
  weights[I1]=alph1;
  weights[I2]=alph2;
  return true;
}


//
// Multiplicative update optimisation algorithm for Reduced Set Density Estimation (RSDE).
//    Minimising 0.5*alpha'*Q*alpha-alpha'*D
//    Updating rule: alpha=(alpha.*D')./(Q*alpha);

#define alpha_tolerance 1e-6
#define error_tolerance 1e-5

void multUpdate(double* Q, double* D, unsigned int N, double* weights)
{
  unsigned int i,j;
  double sumA,sumAD, err, errNew, tmp;
  double *a = (double*) mxMalloc(N*sizeof(double));

//  printf("Performing multUpdate\n",N);
//  mexCallMATLAB(0, NULL, 0, NULL, "pause"); 
  
  for (i=0,sumA=0;i<N;i++) sumA += D[i];
  for (i=0;i<N;i++) weights[i] = D[i]/sumA;

  for (i=0,err=0;i<N;i++) {               // compute ISE error value
    for (j=0,tmp=0;j<N;j++) tmp += Q[i*N+j]*weights[j];
    err += .5*weights[i]*tmp - weights[i]*D[i];
  }
  double dE=1;                      // improvement in ISE each iteration

  while (fabs(dE)>error_tolerance) {

    for (i=0,sumA=0,sumAD=0;i<N;i++) {             
      for (j=0, tmp=0;j<N;j++) tmp += Q[i+N*j]*weights[j];
      a[i] = weights[i]/tmp;
      sumA += a[i]; sumAD += a[i]*D[i];
    }
    for (i=0;i<N;i++) weights[i] = a[i]*(D[i] + (1-sumAD)/sumA);
  
    for (i=0,sumA=0;i<N;i++) {
      if (weights[i] <= alpha_tolerance) weights[i] = 0;
      sumA += weights[i];
    }  
    for (i=0;i<N;i++) weights[i] /= sumA;

    for (i=0,errNew=0;i<N;i++) {     // compute new error
      for (j=0, tmp=0;j<N;j++) tmp += Q[i+N*j]*weights[j];
      errNew += .5*weights[i]*tmp - weights[i]*D[i];
    }
    dE = errNew - err;  err = errNew; // and check for convergence
  }
  mxFree(a);
}

