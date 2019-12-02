
#include "mex.h"
#include "emd.h"

#define DATA_TYPE double

/*indexing a matlab matrix (2d array)
v : pointer to an array
d : number of rows
i,j : row and column index
*/
#define MAT_ELEM(v,d,i,j) (*(v+((d)*(j))+(i)))


DATA_TYPE *ptrCost=NULL;
int rowsCost=0;

float dist(feature_t *iF1, feature_t *jF2)
{
    return (float)MAT_ELEM(ptrCost,rowsCost,*iF1,*jF2);
}


void mexFunction(
int          nlhs,
mxArray      *plhs[],
int          nrhs,
const mxArray *prhs[]
)
{
    int i,n1,n2;
    DATA_TYPE* ptr;
    feature_t *f1,*f2;
    float *w1,*w2;
    float       e;
    flow_t      *flow;
    int  flowSize;
    signature_t s1,s2;
    /* Check for proper arguments */
    if (nrhs != 3)
    {
        mexErrMsgTxt("3 input arguments required.");
    }

    if(nlhs > 2)
    {
        mexErrMsgTxt("Too many outputs.");
    }
    
    if(!mxIsNumeric(prhs[0]) || !mxIsNumeric(prhs[1]) || !mxIsNumeric(prhs[2]))
    mexErrMsgTxt("Input arguments must be numeric matrices\n");
    
    if(mxIsSparse(prhs[0])||mxIsSparse(prhs[1])||mxIsSparse(prhs[2]))
    {
        mexErrMsgTxt("Sparse matrices are not supported.");
    }
    
    if (mxGetNumberOfDimensions(prhs[0])>2 ||
    mxGetNumberOfDimensions(prhs[1])>2 ||
    mxGetNumberOfDimensions(prhs[2])>2 )
    mexErrMsgTxt("Multidemnsionl arrays are not supported!\n");
    
    if( mxGetClassID(prhs[0])!=mxDOUBLE_CLASS ||
    mxGetClassID(prhs[1])!=mxDOUBLE_CLASS ||
    mxGetClassID(prhs[2])!=mxDOUBLE_CLASS )
    mexErrMsgTxt("Currently only double type is supported.\n");
    
    if(mxGetM(prhs[0]))
    
    n1 = mxGetN(prhs[0]);
    n2 = mxGetN(prhs[1]);
    if(!n1 || !n2)
    mexErrMsgTxt("Signatures can not be empty!\n");
    if(1!=mxGetM(prhs[0]) || 1!=mxGetM(prhs[1]))
    mexErrMsgTxt("Weights of signatures should be row vectors!\n");
    
    ptrCost=(DATA_TYPE*)mxGetData(prhs[2]);rowsCost=mxGetM(prhs[2]);
    if(n1!=mxGetM(prhs[2]) ||  n2!=mxGetN(prhs[2]))
    mexErrMsgTxt("Size of cost matrix is not consistent with signatures.\n");
    
    f1=mxCalloc(n1,sizeof(feature_t));
    w1=mxCalloc(n1,sizeof(float));
    ptr=(DATA_TYPE*)mxGetData(prhs[0]);
    for(i=0;i<n1;i++)
    {
        w1[i]=(float)ptr[i];
        f1[i]=i;
    }
    f2=mxCalloc(n2,sizeof(feature_t));
    w2=mxCalloc(n2,sizeof(float));
    ptr=(DATA_TYPE*)mxGetData(prhs[1]);
    for(i=0;i<n2;i++)
    {
        w2[i]=(float)ptr[i];
        f2[i]=i;
    }
    s1.n=n1;s1.Features=f1;s1.Weights=w1;
    s2.n=n2;s2.Features=f2;s2.Weights=w2;
    
    if(nlhs<=1)
    {
		e = emd(&s1, &s2, dist, 0, 0);
        plhs[0]=mxCreateDoubleScalar(e);
    }else if(nlhs==2)
    {
		flow=mxCalloc(n1+n2-1,sizeof(flow_t));
		e = emd(&s1, &s2, dist, flow, &flowSize);
		if(flowSize!=n1+n2-1)
			mexErrMsgTxt("s.t. wrong!.\n");
		plhs[0]=mxCreateDoubleScalar(e);
        plhs[1]= mxCreateDoubleMatrix(flowSize,3,mxREAL);
		ptr=(DATA_TYPE*)mxGetData(plhs[1]);
		for(i=0;i<flowSize;i++)
		{
			MAT_ELEM(ptr,flowSize,i,0)=flow[i].from+1;
			MAT_ELEM(ptr,flowSize,i,1)=flow[i].to+1;
			MAT_ELEM(ptr,flowSize,i,2)=flow[i].amount;
		}
		mxFree(flow);
    }

    mxFree(f1);
    mxFree(f2);
    mxFree(w1);
    mxFree(w2);
}

