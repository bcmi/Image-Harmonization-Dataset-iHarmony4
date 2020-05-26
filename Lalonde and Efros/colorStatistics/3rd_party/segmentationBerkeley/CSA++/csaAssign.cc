
#include <algorithm>
#include <mex.h>
#include "csa.hh"

extern "C" {

void 
mexFunction (
    int nlhs, mxArray* plhs[],
    int nrhs, const mxArray* prhs[])
{
    // Check argument counts.
    if (nlhs < 1) {
        mexErrMsgTxt("Too few output arguments.");
    }
    if (nlhs > 1) {
        mexErrMsgTxt("Too many output arguments.");
    }
    if (nrhs < 2) {
        mexErrMsgTxt("Too few input arguments.");
    }
    if (nrhs > 2) {
        mexErrMsgTxt("Too many input arguments.");
    }

    // Get input arguments.
    const int n = (int) mxGetScalar (prhs[0]);
    const double* g = mxGetPr (prhs[1]);
    const int three = mxGetM (prhs[1]);
    const int m = mxGetN (prhs[1]);

    // Check input arguments.
    if (n < 1) {
        mexErrMsgTxt("n must be >0");
    }
    if ((n%2) != 0) {
        mexErrMsgTxt("n must be even");
    }
    if (m < 1) {
        mexErrMsgTxt("m must be >0");
    }
    if (three != 3) {
        mexErrMsgTxt("graph matrix must be 3xM");
    }

    // Build the input graph and check the data.
    int* graph = new int[m*3];
    int maxc = 0;
    for (int i = 0; i < m; i++) {
        int a = (int) g[3*i+0];
        int b = (int) g[3*i+1];
        int c = (int) g[3*i+2];
        graph[3*i+0] = a;
        graph[3*i+1] = b;
        graph[3*i+2] = c;
        if (a < 1 || a > n/2) {
            mexErrMsgTxt("edge tail not in [1,n/2]");
        }
        if (b <= n/2 || b > n) {
            mexErrMsgTxt("edge head not in (n/2,n]");
        }
        if (c < 0) {
            mexErrMsgTxt("edge weights must be non-negative");
        }
        maxc = std::max(c,maxc);
    }

    // The CSA package segfaults if all the edge weights are zero.
    // In this case, set all the weights to one, and then later
    // remember to set the returned graph weights back to zero.
    if (maxc == 0) {
        for (int i = 0; i < m; i++) {
            graph[3*i+2] = 1;
        }
    }

    // Run CSA.  It will either run successfully or segfault or loop
    // forever or return garbage.  But it claims to always return a
    // valid result if the input is valid.  The checks above try to
    // ensure that the input is ok, but I don't check that a perfect
    // match is present (which CSA requires but does not check for,
    // grumble, grumble).  In that case, you're on your own, since
    // I'm not sure how to quickly check for that condition.
    CSA csa (n, m, graph);
    int e = csa.edges();

    // Done with input graph.
    delete [] graph;
    graph = NULL;

    // Construct result.
    plhs[0] = mxCreateDoubleMatrix(3, e, mxREAL);
    double* points = mxGetPr(plhs[0]);
    for (int i = 0; i < e; i++) {
        int a, b, cost;
        csa.edge(i,a,b,cost);
        points[i*3+0] = a;
        points[i*3+1] = b;
        points[i*3+2] = (maxc==0) ? 0 : cost;
    }
}

}; // extern "C"
