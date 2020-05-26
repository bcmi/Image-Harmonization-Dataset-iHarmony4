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

double erf(double c) {          // disabled for lack of windows erf f'n
  return 1.0;
}

const double pi = 3.141592653589;
const double s2pi = .398942280401432; // = 1/sqrt(2*pi);
const double s2 = 1.414213562373095;  // = sqrt(2);

void entDirISE(const BallTreeDensity& dens, double* err);

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  const mxArray *cell;
  struct NPD* npd;  
  double *err;
  
  /*********************************************************************
  ** Verify arguments and initialize variables
  *********************************************************************/

  if (nrhs != 1)
    mexErrMsgTxt("Takes 1 input arguments");
  if (nlhs >  1)
    mexErrMsgTxt("Outputs 1 results");

  if (!mxIsClass(prhs[0],"kde")) mexErrMsgTxt("Takes one NPDE class variable");


  BallTreeDensity dens = BallTreeDensity(prhs[0]);
  
  if (dens.getType() != BallTreeDensity::Gaussian)
    mexErrMsgTxt("Sorry -- only Gaussian kernels supported");
     
  plhs[0] = mxCreateDoubleMatrix(dens.Ndim(),dens.Npts(),mxREAL);
  err     = mxGetPr(plhs[0]);

  entDirISE(dens,err);
}



///
/// BELOW: TOTALLY UNUSED!!!
///
/* function kprm = ker_diff(x,y,sigwin,vdiff,expeval)
% -compute derivative of kernel evaluated at data for max entropy
%  learning rule
%
    u            = permute(repmat(y,[1,1,Nx2]),[1,3,2]);
    xi           = repmat(x,[1,1,Ny2]);
    vdiff        = (xi-u);
    expeval      = -(0.5/sigwin^2e0)*sum(vdiff.^2e0,1);
  kprm          = -1.0/((2*pi)^(Nx1/2.0)*sigwin^(Nx1+2.0))*exp(expeval);
  kprm          = repmat(kprm,[Nx1,1,1]) .* vdiff;
*/
void kprm(const BallTreeDensity& dens, const BallTree& loc, double *e) 
{
  unsigned int Nd = dens.Ndim();
  double Cnorm = 1.0/pow((double) 2*pi,(double) ((double)Nd)/2);
  unsigned int k;
  BallTree::index i,j;
  unsigned long jj;
  
  for (j=loc.leafFirst(0);j<=loc.leafLast(0);j++) {
    jj = dens.getIndexOf(j);
    for (k=0;k<Nd;k++) e[k+Nd*jj]=0;
    for (i=dens.leafFirst(0);i<=dens.leafLast(0);i++) {
      double Ktmp = 0;
      for (k=0;k<Nd;k++) {
        double mDiff = (dens.center(i)[k] - loc.center(j)[k]);
        Ktmp += -.5 * ((mDiff*mDiff) / dens.bw(i)[k] - log(dens.bw(i)[k]));
      }
      Ktmp = Cnorm * exp(Ktmp);
      for (k=0;k<Nd;k++)
        e[i+Nd*jj] -= Ktmp * (dens.center(i)[k] - loc.center(j)[k])/ dens.bw(i)[k];
    }
  }
}
/////

/*  
function kconv = ker_diffconv(x,sigwin,d2)
%
% KER_DIFFCONV
%
% -this function represents the convolution of a gaussian kernel with its
%  derivative
%
%      x       N1 X N2 matrix containing  N2 observations of the N1-dimensional
%              random vector
%      sigwin  standard deviation (in one direction) for estimator kernel
%
 [N1,N2,N3]= size(x);
 if (nargin < 3)
  expeval       = -(0.25/sigwin.^2e0)*sum(x.^2e0,1);
  expeval       = max(expeval,-8.7e1);
 else
  expeval       = -(0.25/sigwin.^2e0)*d2;
  expeval       = max(expeval,-8.7e1);
 end;
 kconv          = -1.0/(pi^(N1/2.0)*sigwin^(N1+2.0)*2^(N1+1))*repmat(exp(expeval),[N1,1,1]).*x;
*/
// for non-uniform kernel size --
//   S = 1/(((2pi)^Nd/2) * prod(sig_i) * s_i^2 * 1/2^Nd/2 * 1/2 
void kasum(const BallTreeDensity& dens, const BallTree& loc, double *e) 
{
  unsigned long Np = dens.Npts();
  unsigned int Nd = dens.Ndim();
  double Cnorm = 1.0/(pow(pi,((double)Nd)/2)*pow(2,Nd+1));
  unsigned int k;
  BallTree::index i,j;
  unsigned long jj;
  
  for (j=loc.leafFirst(0);j<=loc.leafLast(0);j++) {
    jj = dens.getIndexOf(j);
    for (k=0;k<Nd;k++) e[k+Nd*jj]=0;
    for (i=dens.leafFirst(0);i<=dens.leafLast(0);i++) {
      double Ktmp = 0;
      for (k=0;k<Nd;k++) {
        double mDiff = (dens.center(i)[k] - loc.center(j)[k]);
        Ktmp += -.25 * (mDiff*mDiff) / dens.bw(i)[k]; // - 0*log(sig[k+Nd*ii]);  // cancel with SlpGn below
      }
      Ktmp = Cnorm * exp(Ktmp);
      for (k=0;k<Nd;k++) {              // Calculate KA(i,j,k); sum over k
        double KAijk  = Ktmp * (dens.center(i)[k] - loc.center(j)[k])/ dens.bw(i)[k];
        double SlpGn_ik = Cnorm / dens.bw(i)[k];  // other sigs cancel with log above
        e[k+Nd*jj]+= KAijk * 1/SlpGn_ik / Np;
      }
    }
  }
}
  

/*
%
% KUPRMCONV 
%
% -this returns the convolution of the N-dimensional uniform distribution
%  with the gradient of the N-dimensional Gaussian kernel
%
%      sigma   standard deviation (in one direction) for estimator kernel
%      a       width of uniform distribution
%      x       Nd x Np points 
%*/
// COMPUTE BOUNDARY REPULSION TERM
void kukprmconv(const BallTreeDensity& dens, double a, bool erfFlag, double *fr) 
{
  double *erfj, *erfterm;           // both malloc'd to Nd doubles

  unsigned int Nd = dens.Ndim();
  unsigned long Np = dens.Npts();
  double aNd  = pow(a,Nd);
  BallTree::index j;
  unsigned long jj;
  unsigned int i,k;

  erfj = (double*) mxMalloc(Nd*sizeof(double));
  erfterm = (double*) mxMalloc(Nd*sizeof(double));

  a = a/2;                          // more useful like this
  for (j=dens.leafFirst(0);j<=dens.leafLast(0);j++) {
    jj = dens.getIndexOf(j);
    unsigned int i;
    for (i=0;i<Nd;i++) {
      double tPlus  = (dens.center(j)[i]+a);         // compute k1term ...
      double tMinus = (dens.center(j)[i]-a);
      erfj[i] = 0.5*(erf(tPlus/s2/sqrt(dens.bw(j)[i]))-erf(tMinus/s2/sqrt(dens.bw(j)[i])));

      tPlus  = -.5 * tPlus*tPlus/dens.bw(j)[i];
      tMinus = -.5 * tMinus*tMinus/dens.bw(j)[i];
      fr[i+Nd*jj] = s2pi/sqrt(dens.bw(j)[i]) * ( exp(tMinus) - exp(tPlus) );
    }
    for (i=0;i<Nd;i++) {
      erfterm[i] = 1.0;
      if (erfFlag)
        for (unsigned int k=0;k<Nd;k++)
          if (k!=i) erfterm[i] *= erfj[k];
      fr[i+Nd*jj] *= -1/aNd * erfterm[i];
    }
  }
  mxFree(erfj); mxFree(erfterm);
}

/* 
% entDirISE
%
%      slpgn   kernel nomalization factor, can be passed, or if zero is
%              passed back
%      kasum   term due to attraction
%      fr      term due to boundary
%
*/

void entDirISE(const BallTreeDensity& dens, double* err) 
{
  bool erfFlag = false;
  double *fr, *KASum;
  unsigned int Nd = dens.Ndim();
  BallTree::index j;
  unsigned long jj;
  double Cnorm = 1.0/(pow(pi,((double)Nd)/2)*pow(2,Nd+1));
  fr = err;  KASum = (double*) mxMalloc(Nd*dens.Npts()*sizeof(double));

  kasum(dens,dens,KASum);
  kukprmconv(dens,2.0,erfFlag,fr);   //*** times slpgn ???
  
  for (unsigned int i=0;i<Nd;i++) {
    for (j=dens.leafFirst(0);j<=dens.leafLast(0);j++) {
      jj = dens.getIndexOf(j);
    
      double SigProd = 1; 
      for (unsigned int k=0;k<Nd;k++) 
        SigProd *= sqrt(dens.bw(j)[k]);
    
      err[i+Nd*jj] /= Cnorm / SigProd / dens.bw(j)[i];//*dens.bw(j)[i]);
      err[i+Nd*jj] -= KASum[i+Nd*jj];   // negative for repulsion, positive for attraction
  }}
  mxFree(KASum);
}
