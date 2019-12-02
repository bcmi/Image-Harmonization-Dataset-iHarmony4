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

void KLGrad_Resub(const BallTreeDensity&, const BallTreeDensity&, double*, double*);

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  const mxArray *cell;
  double *err1, *err2;

  /*********************************************************************
  ** Verify arguments and initialize variables
  *********************************************************************/

  if (nrhs != 2)
    mexErrMsgTxt("Takes 2 input arguments");
  if (nlhs >  2)
    mexErrMsgTxt("Outputs 2 results");

  if (!mxIsClass(prhs[0],"kde")) mexErrMsgTxt("Takes two KDE class variables");
  if (!mxIsClass(prhs[1],"kde")) mexErrMsgTxt("Takes two KDE class variables");

  BallTreeDensity p1 = BallTreeDensity(prhs[0]);
  BallTreeDensity p2 = BallTreeDensity(prhs[1]);

  if (p1.getType() != BallTreeDensity::Gaussian)
    mexErrMsgTxt("Sorry -- only Gaussian kernels supported");
  if (p2.getType() != BallTreeDensity::Gaussian)
    mexErrMsgTxt("Sorry -- only Gaussian kernels supported");
   
  plhs[0] = mxCreateDoubleMatrix(p1.Ndim(),p1.Npts(),mxREAL);
  plhs[1] = mxCreateDoubleMatrix(p2.Ndim(),p2.Npts(),mxREAL);
  err1     = mxGetPr(plhs[0]);
  err2     = mxGetPr(plhs[1]);

  KLGrad_Resub(p1,p2,err1,err2);
}

//void entGrad_Resub(const BallTreeDensity& dens, const BallTreeDensity &loc, double* err) {
//// Law-of-Large-Numbers Estimate of Entropy:
////
//// for (j in #pts) {                                     % Dij = delta Xi-Xj
////   for (k in #pts) {                                   % Kij = kernel of j at i
////     Djk = (Xj-Xk)/(2*sig)                             %  
////     Kjk = exp(- Djk^2 / (2*sig))                      % K'ij = Kij*Dij
//// ERj = (Sum(K'jk,k)/Sum(Kjk,k))                        % Error = Sum(K')/Sum(K)
////
//
//  double *KpOverK_K;
//  KpOverK_K = err;
//
//  BallTree::index i,j;
//  unsigned long jj;
//  unsigned int Ndim = dens.Ndim();
//  unsigned int k;
//
//  for (j=loc.leafFirst(0);j<=loc.leafLast(0);j++) {
//    jj = loc.getIndexOf(j);
//    double K = 0; //K[jj] = 0;
//    for (k=0;k<Ndim;k++) KpOverK_K[k+Ndim*jj]=0;
//    for (i=dens.leafFirst(0);i<=dens.leafLast(0);i++) {
//      double Ktmp = 0;
//      for (k=0;k<Ndim;k++) {
//        double mDiff = (loc.center(j)[k] - dens.center(i)[k]);
//        Ktmp += -.5 * (mDiff*mDiff) / dens.bw(i)[k];
//      }
//      Ktmp = exp(Ktmp);
//      for (k=0;k<Ndim;k++)
//        KpOverK_K[k+Ndim*jj] += Ktmp * (loc.center(j)[k] - dens.center(i)[k]) / dens.bw(i)[k];// * dens.bw(j)[k]);
//      K += Ktmp; //K[jj] += Ktmp;
//    }
//    for (k=0;k<Ndim;k++) KpOverK_K[k+Ndim*jj] /= K; //K[jj];
//    for (k=0;k<Ndim;k++) KpOverK_K[k+Ndim*jj] *= .05;           // epsilon change
//  }
//}

// KLGrad1 -- calculate gradient of  - E_p1[ log p2 ] WRT points of p1
//
//  in notes, xi -> p1  and  yj -> p2
//
void KLGrad_Resub(const BallTreeDensity& p1, const BallTreeDensity &p2, double* err1, double* err2) 
{
  BallTree::index i,j;
  unsigned int k, Ndim = p1.Ndim();
  double *err, *Kprime = new double[Ndim]; 

//////////////////////////////////////////////////////////////////////////////////
//  dE_p1[ log p1 ] / dp1
//////////////////////////////////////////////////////////////////////////////////
  for (i=p1.leafFirst(0);i<=p1.leafLast(0);i++) {              // err[i] = Sum_yj wi wj K'(xi-yj)/p2(xi)
    double p = 0;
    err = err1 + Ndim*p1.getIndexOf(i);
    for (k=0;k<Ndim;k++) Kprime[k] = 0;
    for (j=p1.leafFirst(0);j<=p1.leafLast(0);j++) {
      double K = 0;                                            // compute K(xi-yj)
      for (k=0;k<Ndim;k++) {                                   //   and K'(xi-yj)
        double mDiff = (p1.center(j)[k] - p1.center(i)[k]);
        K -= .5* ((mDiff*mDiff) / p1.bw(i)[k] + log(p1.bw(i)[k]));
      }
      K = p1.weight(j) * exp(K);                               // yj^th kernel at xi
      for (k=0;k<Ndim;k++) {                                   //   and K'(xi-yj)
        double mDiff = (p1.center(j)[k] - p1.center(i)[k]);
        Kprime[k] += K * mDiff / p1.bw(i)[k];
      }
      p += K;
    }
    for (k=0;k<Ndim;k++)
      err[k] = p1.weight(i) * Kprime[k] / p;                 //
  }
////////////////////////////////////////////////////////////////////////////////////
////  dE_p1[ log p2 ] / dp1
////////////////////////////////////////////////////////////////////////////////////
  for (i=p1.leafFirst(0);i<=p1.leafLast(0);i++) {              // err[i] = Sum_yj wi wj K'(xi-yj)/p2(xi)
    double p = 0;
    err = err1 + Ndim*p1.getIndexOf(i);
    for (k=0;k<Ndim;k++) Kprime[k] = 0;
    for (j=p2.leafFirst(0);j<=p2.leafLast(0);j++) {  
      double K = 0;                                            // compute K(xi-yj)
      for (k=0;k<Ndim;k++) {                                   //   and K'(xi-yj)
        double mDiff = (p1.center(i)[k] - p2.center(j)[k]);
        K -= .5* ((mDiff*mDiff) / p2.bw(i)[k] + log(p2.bw(i)[k]));
      }
      K = p2.weight(j) * exp(K);                               // yj^th kernel at xi
      for (k=0;k<Ndim;k++) {                                   //   and K'(xi-yj)
        double mDiff = (p1.center(i)[k] - p2.center(j)[k]);
        Kprime[k] += - K * mDiff / p2.bw(i)[k];
      }
      p += K;
    }
    for (k=0;k<Ndim;k++)
      err[k] -= p1.weight(i) * Kprime[k] / p;                  //
  }
////////////////////////////////////////////////////////////////////////////////////
////   dE_p1[ log p2 ] / dp2
////////////////////////////////////////////////////////////////////////////////////
  for (j=p2.leafFirst(0);j<=p2.leafLast(0);j++) {              // err[i] = Sum_yj wi wj K'(xi-yj)/p2(xi)
    double p = 0;
    err = err2 + Ndim*p2.getIndexOf(j);
    for (k=0;k<Ndim;k++) Kprime[k] = 0;
    for (i=p1.leafFirst(0);i<=p1.leafLast(0);i++) {  
      double K = 0;                                            // compute K(xi-yj)
      for (k=0;k<Ndim;k++) {                                   //   and K'(xi-yj)
        double mDiff = (p2.center(j)[k] - p1.center(i)[k]);
        K -= .5* ((mDiff*mDiff) / p2.bw(i)[k] + log(p2.bw(i)[k]));
      }
      K = p1.weight(i) * exp(K);                               // yj^th kernel at xi
      for (k=0;k<Ndim;k++) {                                   //   and K'(xi-yj)
        double mDiff = (p2.center(j)[k] - p1.center(i)[k]);
        Kprime[k] += - K * mDiff / p2.bw(j)[k];
      }
      p += K;
    }
    for (k=0;k<Ndim;k++)
      err[k] = - p2.weight(j) * Kprime[k] / p;                    //
  }
//////////////////////////////////////////////////////////////////////////////////
//  dE_p2[ log p2 ] / dp2
//////////////////////////////////////////////////////////////////////////////////
//  for (i=p2.leafFirst(0);i<=p2.leafLast(0);i++) {              // err[i] = Sum_yj wi wj K'(xi-yj)/p2(xi)
//    double p = 0;
//    err = err2 + Ndim*p2.getIndexOf(i);
//    for (k=0;k<Ndim;k++) Kprime[k] = 0;
//    for (j=p2.leafFirst(0);j<=p2.leafLast(0);j++) {
//      double K = 0;                                            // compute K(xi-yj)
//      for (k=0;k<Ndim;k++) {                                   //   and K'(xi-yj)
//        double mDiff = (p2.center(j)[k] - p2.center(i)[k]);
//        K -= .5* ((mDiff*mDiff) / p2.bw(i)[k]);// -log(p1.bw(i)[k]));
//      }
//      K = p2.weight(j) * exp(K);                               // yj^th kernel at xi
//      for (k=0;k<Ndim;k++) {                                   //   and K'(xi-yj)
//        double mDiff = (p2.center(j)[k] - p2.center(i)[k]);
//        Kprime[k] += K * mDiff / p2.bw(i)[k];
//      }
//      p += K;
//    }
//    for (k=0;k<Ndim;k++)
//      err[k] += p2.weight(i) * Kprime[k] / p;                 //
//  }
////////////////////////////////////////////////////////////////////////////////////
  delete[] Kprime;
}

