/*
 * WHISTC.MEX
 *
 * Usage:
 *          Y = whistc(X, W, edges)
 *          Y = whistc(X, W, edges, dim)
 *
 * Output is always double
 *
 * Modified histc mex implementation by Bagon Shai: shai.bagon@weizmann.ac.il
 *
 */

#include "mex.h"

/* Defines */
#define NOBIN -1
#define PRIVATE static
#define MIN(a,b) (a < b ? a : b)
#define MAX(a,b) (a > b ? a : b)

PRIVATE
/*
 * Allocate reduction output.
 */
mxArray *mfCreateHistResult(
int          ndims,
const int    *siz,
int          dim,
int		 nbins,
mxClassID    classid,
mxComplexity cmplxFlag
)
{
    int     i;
    int     *newsiz;
    mxArray *res;
    
    
    /* Output is the same size as the input with siz[dim] replaced by nbins */
    newsiz = (int *)mxCalloc(MAX(ndims,dim+1),sizeof(int));
    for (i=0; i < ndims; i++)
        newsiz[i]=siz[i];
    for (i=ndims; i < dim; i++)
        newsiz[i] = 1;
    
    newsiz[dim] = nbins;
    
    res = mxCreateNumericArray(MAX(ndims,dim+1),newsiz,classid,cmplxFlag);
    mxFree(newsiz);
    
    return res;
}


/*
 * Return index of first non-singleton dimension.
 */
PRIVATE int mfFindFirstNonSingleton(
int ndims,
const int *siz
)
{
    int i;
    int dim;
    
    /* Find first non-singleton dimension */
    for (i=0, dim=ndims-1; i < ndims; i++)
    {
        if (siz[i] != 1)
        {
            dim = i;
            break;
        }
    }
    return dim;
}


/*
 * GetElementSizeFromClassID
 *
 * Purpose: Given MATLAB class ID, return corresponding element size
 *
 * Inputs:  classID --- MATLAB class ID
 * Outputs: none
 * Return:  # of bytes for an element of this class
 */
PRIVATE int GetElementSizeFromClassID(mxClassID classID)
{
    int result;
    
    switch (classID)
{
    
        case mxCHAR_CLASS:
            result = sizeof(mxChar);
            break;
            
        case mxDOUBLE_CLASS:
            result = sizeof(double);
            break;
            
        case mxSINGLE_CLASS:
            result = sizeof(real32_T);
            break;
            
        case mxINT8_CLASS:
            result = sizeof(int8_T);
            break;
            
        case mxUINT8_CLASS:
            result = sizeof(uint8_T);
            break;
            
        case mxINT16_CLASS:
            result = sizeof(int16_T);
            break;
            
        case mxUINT16_CLASS:
            result = sizeof(uint16_T);
            break;
            
        case mxINT32_CLASS:
            result = sizeof(int32_T);
            break;
            
        case mxUINT32_CLASS:
            result = sizeof(uint32_T);
            break;
            
            default:
                mexErrMsgIdAndTxt("MATLAB:whistc:InvalidInput5",
                "Input array must be numeric.");
    }
    
    return(result);
}


/*
 * GetDoubleValue
 *
 * Purpose: Return value as a double
 *
 * Inputs:  x -- array element, classID --- MATLAB class ID
 * Outputs: none
 * Return:  value as a double
 */
PRIVATE double GetDoubleValue(void *x, mxClassID classID)
{
    double result;
    
    switch (classID)
{
    
        case mxCHAR_CLASS:
            result = ((double) *((mxChar *)x));
            break;
            
        case mxDOUBLE_CLASS:
            result = ((double) *((double *)x));
            break;
            
        case mxSINGLE_CLASS:
            result = ((double) *((real32_T *)x));
            break;
            
        case mxINT8_CLASS:
            result = ((double) *((int8_T *)x));
            break;
            
        case mxUINT8_CLASS:
            result = ((double) *((uint8_T *)x));
            break;
            
        case mxINT16_CLASS:
            result = ((double) *((int16_T *)x));
            break;
            
        case mxUINT16_CLASS:
            result = ((double) *((uint16_T *)x));
            break;
            
        case mxINT32_CLASS:
            result = ((double) *((int32_T *)x));
            break;
            
        case mxUINT32_CLASS:
            result = ((double) *((uint32_T *)x));
            break;
            
            default:
                mexErrMsgIdAndTxt("MATLAB:whistc:InvalidInput5",
                "Input array must be numeric.");
    }
    
    return(result);
}

PRIVATE mxArray *muMustBeDouble(const mxArray *x)
{
    mxArray *result;
    double *pr;
    mxClassID classid = mxGetClassID(x);
    int i;
    int n = mxGetNumberOfElements(x);
    
    if (classid == mxDOUBLE_CLASS)
        return (mxArray *)x;
    
    result = mxCreateNumericArray(mxGetNumberOfDimensions(x),mxGetDimensions(x),
    mxDOUBLE_CLASS,mxREAL);
    pr = mxGetPr(result);
    
    switch (classid)
{
    
        case mxCHAR_CLASS:
{
    mxChar *val;
    
    val = (mxChar *)mxGetData(x);
    
    for (i=0; i<n; i++)
        *pr++ = (double) (*val++);
    break;
        }
        case mxSINGLE_CLASS:
{
    real32_T *val;
    
    val = (real32_T *)mxGetData(x);
    
    for (i=0; i<n; i++)
        *pr++ = (double) (*val++);
    break;
        }
        case mxINT8_CLASS:
{
    int8_T *val;
    
    val = (int8_T *)mxGetData(x);
    
    for (i=0; i<n; i++)
        *pr++ = (double) (*val++);
    break;
        }
        case mxUINT8_CLASS:
{
    uint8_T *val;
    
    val = (uint8_T *)mxGetData(x);
    
    for (i=0; i<n; i++)
        *pr++ = (double) (*val++);
    break;
        }
        case mxINT16_CLASS:
{
    int16_T *val;
    
    val = (int16_T *)mxGetData(x);
    
    for (i=0; i<n; i++)
        *pr++ = (double) (*val++);
    break;
        }
        case mxUINT16_CLASS:
{
    uint16_T *val;
    
    val = (uint16_T *)mxGetData(x);
    
    for (i=0; i<n; i++)
        *pr++ = (double) (*val++);
    break;
        }
        case mxINT32_CLASS:
{
    int32_T *val;
    
    val = (int32_T *)mxGetData(x);
    
    for (i=0; i<n; i++)
        *pr++ = (double) (*val++);
    break;
        }
        case mxUINT32_CLASS:
{
    uint32_T *val;
    
    val = (uint32_T *)mxGetData(x);
    
    for (i=0; i<n; i++)
        *pr++ = (double) (*val++);
    break;
        }
        default:
            mexErrMsgIdAndTxt("MATLAB:whistc:InvalidInput5",
            "Input array must be numeric.");
    }
    
    return(result);
}

/*
 * mfGetDimArg
 *
 * Purpose: Get an integer value from MATLAB array; error out if array is
 *          empty or not an integer.
 *
 * Inputs:  A --- MATLAB array
 * Outputs: none
 * Return:  integer value
 *
 */
PRIVATE int mfGetDimArg(const mxArray *A)
{
    double d;
    int result;
    static char msg[] = "Dimension argument must be a positive integer scalar.";
    
    if ((mxGetNumberOfElements(A)!=1) || mxIsComplex(A))
        mexErrMsgIdAndTxt("MATLAB:whistc:InvalidDimension",msg);
    
    d = GetDoubleValue(mxGetData(A),mxGetClassID(A));
    result = (int)d;
    
    if (((double) result) != d || result < 1)
        mexErrMsgIdAndTxt("MATLAB:whistc:InvalidDimension",msg);
    
    return(result - 1); /* return 0 based index */
}


/*
 * Return index of bin the x.  x is in bin k if  bin_edges[k] <= x < bin_edges[k+1].
 *
 * Special case: x is in the last bin if x == bin_edges[nbins].
 */
PRIVATE int findBin(
double x,
double *bin_edges, /* Bin edges */
int nbins	/* Number of edges */
)
{
    int k = NOBIN;
    
    /* Check for NaN and empty bin_edges */
    if (! mxIsNaN(x) && bin_edges != NULL)
    {
    /* Use a binary search */
{
    int k0 = 0;
    int k1 = nbins-1;
    
    if (x >= bin_edges[0] && x < bin_edges[nbins-1])
    {
        k = (k0+k1)/2;
        while (k0 < k1-1)
        {
            if (x >= bin_edges[k]) k0 = k;
            else k1 = k;
            k = (k0+k1)/2;
        }
        k = k0;
    }
    }
    
    /* Check for special case */
    if (x == bin_edges[nbins-1])
        k = nbins-1;
    }
    
    return k;
}

/*
 * Return index of bin the x.  x is in bin k if  bin_edges[k] <= x < bin_edges[k+1].
 *
 * Special case: x is in the last bin also if x == bin_edges[nbins].
 */
PRIVATE int findNonDoubleBin(
void *px,
mxClassID classid,
double *bin_edges, /* Bin edges */
int nbins	/* Number of edges */
)
{
    int k = NOBIN;
    double val = GetDoubleValue(px,classid);
    
    /* Check for NaN */
    if (mxIsNaN(val))
        return NOBIN;
    
    /* Use a binary search */
    {
        int k0 = 0;
        int k1 = nbins-1;
        
        if (val >= bin_edges[0] && val < bin_edges[nbins-1])
        {
            k = (k0+k1)/2;
            while (k0 < k1-1)
            {
                if (val >= bin_edges[k]) k0 = k;
                else k1 = k;
                k = (k0+k1)/2;
            }
            k = k0;
        }
        }
        
    /* Check for special case */
        if (val == bin_edges[nbins-1])
            k = nbins-1;
        
        return k;
}


/*
 * Inner HIST loop: y = WHISTC(x,w,edges)
 */
PRIVATE void _HistLoop(
const mxArray *x, /* input array */
const mxArray *w, /* input weights */
const mxArray *edges, /* input array */
mxArray *y,       /* output array */
mxArray *bin_output, /* bin index output array */
int stride,       /* stride along active dimension */
int mx,	      /* number of elements along active dimension in x */
int my            /* number of elements along active dimension in y */
)
{
    double *xr = mxGetPr(x);
    double *wr = mxGetPr(w);
    double *yr = mxGetPr(y);
    double *pbin = NULL;
    double *bin_edges = mxGetPr(edges);
    int i,j,k,n1,n2;
    int xoffset,yoffset;
    int bin;
    
    if (bin_output != NULL)
        pbin = mxGetPr(bin_output);
    
    if (mx < 1) {
        return;
    }
    
    /* If stride <= 1 choose the roles of n1 and n2 so the loop is faster */
    if (stride <= 1)
    {
        n1 = stride;
        n2 = mxGetNumberOfElements(x)/mx;
        xoffset = 0;
        yoffset = 0;
    }
    else
    {
        n1 = mxGetNumberOfElements(x)/stride/mx;
        n2 = stride;
        xoffset = stride*mx - 1;
        yoffset = stride*my - 1;
    }
    
    /* real loop */
    for (i=0; i < n1; i++)
    {
        for (j=0; j < n2; j++)
        {
            for (k=0; k < mx; k++)
            {
                bin = findBin(*xr,bin_edges,my); /* element xr is in bin */
                if (bin != NOBIN)
                    yr[bin*stride]+= *wr;
                if (pbin != NULL)
                {
                    *pbin = bin+1; /* MATLAB indices are 1-based */
                    pbin += stride;
                }
                xr += stride;
                wr += stride;
            }
            if (pbin != NULL) pbin -= xoffset;
            xr -= xoffset;
            wr -= xoffset;
            yr += my*stride - yoffset;
        }
    /* go to next page of input and output arrays */
        if (pbin != NULL) pbin += xoffset - stride + 1;
        xr += xoffset - stride + 1;
        wr += xoffset - stride + 1;
        yr += yoffset - stride + 1;
    }
}
/*
 * Inner HIST loop for x,w single precision float : y = WHISTC(x,w,edges)
 */
PRIVATE void _SingleHistLoop(
const mxArray *x, /* input array */
const mxArray *w, /* input weights */
const mxArray *edges, /* input array */
mxArray *y,       /* output array */
mxArray *bin_output, /* bin index output array */
int stride,       /* stride along active dimension */
int mx,	      /* number of elements along active dimension in x */
int my            /* number of elements along active dimension in y */
)
{
    float *xr = (float*)mxGetData(x);
    float *wr = (float*)mxGetData(w);
    float *yr = (float*)mxGetData(y);
    float *pbin = NULL;
    double *bin_edges = mxGetPr(edges);
    int i,j,k,n1,n2;
    int xoffset,yoffset;
    int bin;
    
    if (bin_output != NULL)
        pbin = (float*)mxGetData(bin_output);
    
    if (mx < 1) {
        return;
    }
    
    /* If stride <= 1 choose the roles of n1 and n2 so the loop is faster */
    if (stride <= 1)
    {
        n1 = stride;
        n2 = mxGetNumberOfElements(x)/mx;
        xoffset = 0;
        yoffset = 0;
    }
    else
    {
        n1 = mxGetNumberOfElements(x)/stride/mx;
        n2 = stride;
        xoffset = stride*mx - 1;
        yoffset = stride*my - 1;
    }
    
    /* real loop */
    for (i=0; i < n1; i++)
    {
        for (j=0; j < n2; j++)
        {
            for (k=0; k < mx; k++)
            {
                bin = findBin(*xr,bin_edges,my); /* element xr is in bin */
                if (bin != NOBIN)
                    yr[bin*stride]+= *wr;
                if (pbin != NULL)
                {
                    *pbin = bin+1; /* MATLAB indices are 1-based */
                    pbin += stride;
                }
                xr += stride;
                wr += stride;
            }
            if (pbin != NULL) pbin -= xoffset;
            xr -= xoffset;
            wr -= xoffset;
            yr += my*stride - yoffset;
        }
    /* go to next page of input and output arrays */
        if (pbin != NULL) pbin += xoffset - stride + 1;
        xr += xoffset - stride + 1;
        wr += xoffset - stride + 1;
        yr += yoffset - stride + 1;
    }
}


/*
 * Inner HIST loop for non-doubles: y = HIST(x,edges)
 */
PRIVATE void _NonDoubleHistLoop(
const mxArray *x, /* input array */
const mxArray *w, /* input weights */
const mxArray *edges, /* input array */
mxArray *y,       /* output array */
mxArray *bin_output, /* bin index output array */
int stride,       /* stride along active dimension */
int mx,	      /* number of elements along active dimension in x */
int my            /* number of elements along active dimension in y */
)
{
    uint8_T *xr = (uint8_T *) mxGetData(x); /* Treat x as a bunch of bytes */
    double *wr = mxGetPr(w);
    double *yr = mxGetPr(y);
    double *pbin = NULL;
    double *bin_edges = mxGetPr(edges);
    int i,j,k,n1,n2;
    int xoffset,yoffset;
    int bin;
    mxClassID classid = mxGetClassID(x);
    int elem_size = GetElementSizeFromClassID(classid);
    
    if (mx < 1) {
        return;
    }
    
    if (bin_output != NULL)
        pbin = mxGetPr(bin_output);
    
    /* If stride <= 1 choose the roles of n1 and n2 so the loop is faster */
    if (stride <= 1)
    {
        n1 = stride;
        n2 = mxGetNumberOfElements(x)/mx;
        xoffset = 0;
        yoffset = 0;
    }
    else
    {
        n1 = mxGetNumberOfElements(x)/stride/mx;
        n2 = stride;
        xoffset = stride*mx - 1;
        yoffset = stride*my - 1;
    }
    
    /* real loop */
    for (i=0; i < n1; i++)
    {
        for (j=0; j < n2; j++)
        {
            for (k=0; k < mx; k++)
            {
                bin = findNonDoubleBin(xr,classid,bin_edges,my);
                if (bin != NOBIN)
                    yr[bin*stride]++;
                if (pbin != NULL)
                {
                    *pbin = bin+1; /* MATLAB indices are 1-based */
                    pbin += stride;
                }
                xr += stride*elem_size;
            }
            if (pbin != NULL) pbin -= xoffset;
            xr -= xoffset*elem_size;
            yr += my*stride - yoffset;
        }
    /* go to next page of input and output arrays */
        if (pbin != NULL) pbin += xoffset - stride + 1;
        xr += (xoffset - stride + 1)*elem_size;
        yr += yoffset - stride + 1;
    }
}


/*
 * Full whistc function
 */
void mexFunction(
int		  nlhs, 	/* number of expected outputs */
mxArray	  *plhs[],	/* mxArray output pointer array */
int		  nrhs, 	/* number of inputs */
const mxArray	  *prhs[]	/* mxArray input pointer array */
)
{
    const mxArray	*x;
    const mxArray   *w;  /* weights */
    mxArray	*edges;
    mxArray     *bin_output;
    double *bin_edges;
    int nbins;
    int i;
    const int MaxNumInputs = 4;  /* inputs: data, weights and possibly dimension to work along */
    const int MinNumInputs = 3;
    const int NumOutputs = 2;	/* weighted histogram, and bins locations */
    
    if (nrhs > MaxNumInputs) mexErrMsgIdAndTxt("MATLAB:whistc:TooManyInputs",
    "Too many input arguments.");
    if (nrhs < MinNumInputs) mexErrMsgIdAndTxt("MATLAB:whistc:TooFewInputs",
    "Not enough input arguments.");
    if (nlhs > NumOutputs) mexErrMsgIdAndTxt("MATLAB:whistc:TooManyOutputs",
    "Too many output arguments.");
    
    /* data array - check input */
    x = prhs[0];
    if (mxIsEmpty(x))
        mexErrMsgIdAndTxt("MATLAB:whistc:InvalidInput1",
        "First input must be non-empty numeric array.");
    
    if (!(mxIsNumeric(x) || mxIsChar(x)) || mxIsSparse(x))
        mexErrMsgIdAndTxt("MATLAB:whistc:InvalidInput2",
        "First input must be non-sparse numeric array.");
    
    /* weights array - check inputs */
    w = prhs[1];
    if (mxIsEmpty(w))
        mexErrMsgIdAndTxt("MATLAB:whistc:InvalidInput1",
        "Second input must be non-empty numeric array.");
    
    if (!(mxIsNumeric(w) || mxIsChar(w)) || mxIsSparse(w))
        mexErrMsgIdAndTxt("MATLAB:whistc:InvalidInput2",
        "Second input must be non-sparse numeric array.");
    
    if ( ( ! (mxGetM(w) == mxGetM(x)) ) || /* num of rows */
    ( ! (mxGetN(w) == mxGetN(x)) ) ) /* number of columns */
        mexErrMsgIdAndTxt("MATLAB:whistc:InvalidInput2",
        "First and second inputs sizes mismatch.");
    
    edges = muMustBeDouble(prhs[2]);
    
    nbins = mxGetNumberOfElements(edges);
    
    /* Make sure the edges vector is monotonically non-decreasing */
    bin_edges = mxGetPr(edges);
    for (i=0; i<nbins-1; i++)
    {
        if (bin_edges[i] > bin_edges[i+1])
            mexErrMsgIdAndTxt("MATLAB:whistc:InvalidInput3",
            "Edges vector must be monotonically non-decreasing.");
    }
    
    if (nrhs == 3 && mxGetM(x)==0 && mxGetN(x)==0)
    {
    /*
     * Special case:
     *
     * whistc([], [], edges) is nbins-by-0
     */
        plhs[0] = mxCreateDoubleMatrix(nbins, 0, mxREAL);
        if (nlhs > 1)
            plhs[1] = mxCreateNumericArray(mxGetNumberOfDimensions(x),mxGetDimensions(x),
            mxDOUBLE_CLASS,mxREAL);
    }
    else
    {
        int	  ndims = mxGetNumberOfDimensions(x);
        const int *siz = mxGetDimensions(x);
        int 	  dim;
        int	  stride;
        int       m;
        
        /* Determine active dimension -- dim */
        if (nrhs == 4)
            dim = mfGetDimArg(prhs[3]);
        else
            dim = mfFindFirstNonSingleton(ndims,siz);
        
    /* Compute stride along active dimension */
        for (i=0, stride=1; i < MIN(ndims,dim); i++)
            stride *= siz[i];
        
    /* Number of elements along active dimension */
        m = (dim < ndims ? siz[dim] : 1);
        
        if (mxIsComplex(x))
            mexErrMsgIdAndTxt("MATLAB:whistc:InvalidInput4",
            "All inputs must be real.");
        
        if ( (mxGetClassID(x) == mxDOUBLE_CLASS) &&
        (mxGetClassID(w) == mxDOUBLE_CLASS)) {
            plhs[0] = mfCreateHistResult(ndims,siz,dim,nbins,mxDOUBLE_CLASS,mxREAL);
            if (nlhs > 1)
                bin_output = mxCreateNumericArray(mxGetNumberOfDimensions(x),mxGetDimensions(x),
                mxDOUBLE_CLASS,mxREAL);
            else
                bin_output = NULL;
            _HistLoop(x, w, edges,plhs[0],bin_output,stride,m,nbins);
        }
        else
            if ( (mxGetClassID(x) == mxSINGLE_CLASS) &&
            (mxGetClassID(w) == mxSINGLE_CLASS)) {
                plhs[0] = mfCreateHistResult(ndims,siz,dim,nbins,mxSINGLE_CLASS,mxREAL);
                if (nlhs > 1)
                    bin_output = mxCreateNumericArray(mxGetNumberOfDimensions(x),mxGetDimensions(x),
                    mxSINGLE_CLASS,mxREAL);
                else
                    bin_output = NULL;
            
                _SingleHistLoop(x, w, edges,plhs[0],bin_output,stride,m,nbins);
            }
            else
                mexErrMsgIdAndTxt("MATLAB:whisc:InvalidInput4",
                "First and second inputs must be double.");
    /* _NonDoubleHistLoop(x, w, edges,plhs[0],bin_output,stride,m,nbins); */
    }
    
    if (edges != prhs[2])
        mxDestroyArray(edges);
    if (nlhs > 1)
        plhs[1] = bin_output;
}
