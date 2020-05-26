
#include <mex.h>
#include <string.h>
#include <assert.h>

// If you have trouble mexifying this file, then consider using
// the MATLAB code (isum.m) instead.  So long as your MATLAB 
// version is at least 6.5, you won't suffer too much of a 
// performance penalty.

void 
mexFunction (
    int nlhs, mxArray* plhs[],
    int nrhs, const mxArray* prhs[])
{
    // Check number of arguments.
    if (nlhs < 1) {
        mexErrMsgTxt("Too few output arguments.");
    }
    if (nlhs > 1) {
        mexErrMsgTxt("Too many output arguments.");
    }
    if (nrhs < 3) {
        mexErrMsgTxt("Too few input arguments.");
    }
    if (nrhs > 3) {
        mexErrMsgTxt("Too many input arguments.");
    }

    const double* x = mxGetPr(prhs[0]);
    const double* idx = mxGetPr(prhs[1]);
    int nbins = (int)mxGetScalar(prhs[2]);
    if (nbins < 0) { nbins = 0; }

    // Check arguments.
    const int n = mxGetNumberOfElements(prhs[0]);
    if (n != mxGetNumberOfElements(prhs[1])) { 
        mexErrMsgTxt("x and idx must be the same size");
    }

    // Do the reduction.
    plhs[0] = mxCreateDoubleMatrix(nbins,1,mxREAL);
    double* acc = mxGetPr(plhs[0]);
    memset(acc,0,nbins*sizeof(*acc));
    for (int i = 0; i < n; i++) {
        int v = (int)idx[i];
        if (v < 1) { continue; }
        if (v > nbins) { continue; }
        acc[v-1] += x[i];
    }
}

