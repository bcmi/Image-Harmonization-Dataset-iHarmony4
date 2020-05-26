#include <mex.h>
#include <matrix.h>
#include <stdio.h>

/* res = existfile(filename) */

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
	mxArray *resultArray;
	int result = 0;
	char filename[500];
	FILE *fid;
	
	if (nrhs > 0)
	{
		mxGetString(prhs[0], filename, 498);
		fid = fopen(filename, "r");
		if (fid == NULL )
		{
			/* file does not exist */
			result = 0;
		}
		else
		{
			/* file exists */
			result = 1;
			fclose(fid);
		}
	}
	else
	{
		result = 0;
	}
	resultArray = mxCreateDoubleScalar(result);
	
	plhs[0] = resultArray;
	nlhs = 1;
}
