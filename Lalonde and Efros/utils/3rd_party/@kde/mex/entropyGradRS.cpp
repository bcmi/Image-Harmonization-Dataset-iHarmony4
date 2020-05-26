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

void entGrad_Resub(const BallTreeDensity& dens, double* err);

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  const mxArray *cell;
  double *err;  

  /*********************************************************************
  ** Verify arguments and initialize variables
  *********************************************************************/

  if (nrhs != 1)
    mexErrMsgTxt("Takes 1 input arguments");
  if (nlhs >  1)
    mexErrMsgTxt("Outputs 1 results");

  if (!mxIsClass(prhs[0],"kde")) mexErrMsgTxt("Takes one KDE class variable");

  BallTreeDensity dens = BallTreeDensity(prhs[0]);

  if (dens.getType() != BallTreeDensity::Gaussian)
    mexErrMsgTxt("Sorry -- only Gaussian kernels supported");
        
  plhs[0] = mxCreateDoubleMatrix(dens.Ndim(),dens.Npts(),mxREAL);
  err     = mxGetPr(plhs[0]);

  entGrad_Resub(dens,err);
}

void entGrad_Resub(const BallTreeDensity& dens, double* err1) {
// Law-of-Large-Numbers Estimate of Entropy:
//
// for (j in #pts) {                                     % Dij = delta Xi-Xj
//   for (k in #pts) {                                   % Kij = kernel of j at i
//     Djk = (Xj-Xk)/(2*sig)                             %  
//     Kjk = exp(- Djk^2 / (2*sig))                      % K'ij = Kij*Dij
// ERj = (Sum(K'jk,k)/Sum(Kjk,k))                        % Error = Sum(K')/Sum(K)
//

  BallTree::index i,j;
  unsigned long jj;
  unsigned int Ndim = dens.Ndim();
  unsigned int k;
  double *Kprime = new double[Ndim];

  for (j=dens.leafFirst(dens.root());j<=dens.leafLast(dens.root());j++) {
    double p = 0;
    double* err = err1 + Ndim*dens.getIndexOf(j);
    for (k=0;k<Ndim;k++) Kprime[k] = 0;
    for (i=dens.leafFirst(dens.root());i<=dens.leafLast(dens.root());i++) {
      double K = 0;                                            // compute K(xi-yj)
      for (k=0;k<Ndim;k++) {                                   //   and K'(xi-yj)
        double mDiff = (dens.center(j)[k] - dens.center(i)[k]);
        K -= .5* ((mDiff*mDiff) / dens.bw(j)[k] + log(dens.bw(j)[k]));
      }
      K = dens.weight(i) * exp(K);                             // yj^th kernel at xi
      for (k=0;k<Ndim;k++) {                                   //   and K'(xi-yj)
        double mDiff = (dens.center(j)[k] - dens.center(i)[k]);
        Kprime[k] += K * mDiff / dens.bw(j)[k];
      }
      p += K;
    }
    for (k=0;k<Ndim;k++)
      err[k] = dens.weight(j) * Kprime[k] / p;                 //
  }
  delete[] Kprime;
}

