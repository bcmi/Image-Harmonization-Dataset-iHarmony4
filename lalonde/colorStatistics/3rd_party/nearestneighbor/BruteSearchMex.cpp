#include "mex.h"
#include "BruteSearchTranspose.cpp"






// In Matlab la funzione deve essere idc=NNSearch(x,y,pk,ptrtree)

/* the gateway function */
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    
    double       *p;//reference points
    double       *qp;//query points
    double* results;
    char*        String;//Input String
    int String_Leng;//length of the input String
    int N,Nq,dim,i,j;
    double* distances;//distances for k-neighbors
    int* idck;//k-neighbors
    int idc;//nearest neighbor
    double*k;
    int kint;
    double* r;
    double* D;//Output distance matrix
    double mindist;
    
    //Errors Check
    
    if (nlhs>2)
    {
        mexErrMsgTxt("Too many outputs");
    }
    
    if (nrhs<2)
    {
        mexErrMsgTxt("Not enough inputs");
    }
    
    
    N=mxGetN(prhs[0]);//number of reference points
    Nq=mxGetN(prhs[1]);//number of query points
    dim=mxGetM(prhs[0]);//dimension of points
    
//     mexPrintf("Dimension %4.4d\n",dim);
   
    
    //Check is inputs has the same dimension
    if (mxGetM(prhs[1])!=dim)
    {
        mexErrMsgTxt("Points must have the same dimension");
    }
    
    
    //Checking input format
    if( !mxIsDouble(prhs[0]) || !mxIsDouble(prhs[1]) )
    { mexErrMsgTxt("Inputs points must be double matrix ");
    }
    
    
    
    p = mxGetPr(prhs[0]);//puntatore all'array dei punti
    qp = mxGetPr(prhs[1]);//puntatore all'array dei punti
    

    
    //Getting the Input String
    
    if (nrhs>2)
    {
        
        
        if(!mxIsChar(prhs[2]))//is the input a string
            
        {
            mexErrMsgTxt("Input 3 must be of type char.");
        }
        
        
        String_Leng=mxGetN(prhs[2]);//StringLength
        
        if (String_Leng>1)//Check if string is correct
        {
            mexErrMsgTxt("Input 3 must be only one String.");
        }
        
        
        
        String =mxArrayToString (prhs[2]);//get the string
        
        if(String == NULL)
        {
            mexErrMsgTxt("Could not convert input to string.");
        }
//         mexPrintf("The input string is:  %s\n",String);
    }
    else
    {
        String=NULL;
//         mexPrintf("No input string\n");
    }
    
    
    //Choose the algorithm from the input String
    
    if(String==NULL)
    {  //Nearest Neighbor
//         mexPrintf("Nearest Neighbor\n");
        plhs[0] = mxCreateDoubleMatrix(Nq, 1,mxREAL);//costruisce l'output array
        results = mxGetPr(plhs[0]);//appicicaci il puntatore
        
        if (nlhs==1)
        { //Search with no distance
            
            for (i=0;i<Nq;i++)
            {
                results[i]=BruteSearch(p,&qp[i*dim] ,N,dim,&mindist)+1;
            }
//            mexPrintf("end search\n");
        }
        else //Search with distance
        { //build the output distance matrix
            plhs[1] = mxCreateDoubleMatrix(Nq, 1,mxREAL);
            D = mxGetPr(plhs[1]);//appicicaci il puntatore
            
            for (i=0;i<Nq;i++)
            {
                
               
                results[i]=BruteSearch(p,&qp[i*dim] ,N,dim,&mindist)+1;
                D[i]=sqrt(mindist);
            }
//              mexPrintf("end search\n");
        }
        
    }
    
    
    
    else if(String[0]=='k')
    {       //KNearest Neighbor
        
//         mexPrintf("KNearest Neighbor\n");
        
        
        
        if (nrhs<4)
        {
            mexErrMsgTxt("Number of neighbours not given");
        }
        
        k=mxGetPr(prhs[3]);
        
        kint=k[0];
        
        
        idck=new int[kint];
        distances=new double[kint];
     
        plhs[0] = mxCreateDoubleMatrix(Nq,kint,mxREAL);//costruisce l'output array
        results = mxGetPr(plhs[0]);//appicicaci il puntatore
        
        if (nlhs==1) //Search without Distance matrix output
        {
            for (i=0;i<Nq;i++)
            {
             
                BruteKSearch(p,&qp[i*dim] ,kint,N,dim,distances,idck);//Run the query
                
                for(j=0;j<kint;j++)
                {   
                    results[j*Nq+i]=idck[j]+1;//plus one Matlab notation
                }
                
            }
        }
        else//Search with Distance matrix
        {
            plhs[1] = mxCreateDoubleMatrix(Nq,kint,mxREAL);//costruisce l'output array
            D = mxGetPr(plhs[1]);//appicicaci il puntatore
            for (i=0;i<Nq;i++)
            {
               
                BruteKSearch(p,&qp[i*dim] ,kint,N,dim,distances,idck);//Run the query
                
                for(j=0;j<kint;j++)
                {
                    D[j*Nq+i]=sqrt(distances[j]);
                    results[j*Nq+i]=idck[j]+1;//plus one Matlab notation
                }
               
            }
            
        }
            //deallocatememory
    delete [] distances;
    delete [] idck;
    }
    
    
    else if(String[0]=='r')
    {       //Radius Search
       
//        mexPrintf("radius\n");
        if (Nq>1)
        {
            mexErrMsgTxt("Radius Serach possible with only one query point");
        }
        
        if (nrhs<4)
        {
            mexErrMsgTxt("Radius not given");
        }
        
        r=mxGetPr(prhs[3]);
       
        vector<int> idcv;
        
        if (nlhs==1)//Search without distance
        {
            BruteRSearch(p,qp,*r,N,dim,&idcv);
            
            kint=idcv.size();//Size of vector
            
            plhs[0] = mxCreateDoubleMatrix(1,kint,mxREAL);//costruisce l'output array
            results = mxGetPr(plhs[0]);
           
            for(i=0;i<kint;i++)//copy in the otput array
            {
//                              mexPrintf("%4.1d\n",idcv[i]);
                results[i]=idcv[i]+1;//copy the output
            }
            
        }
        else
        {
        vector<double> distvect;//declare the distance vector
       
        BruteRSearchWithDistance(p,qp,*r,N,dim,&idcv,&distvect);
        
        kint=idcv.size();//Size of vector
     
       
        plhs[0] = mxCreateDoubleMatrix(1,kint,mxREAL);//costruisce l'output array
        results = mxGetPr(plhs[0]);
       
        plhs[1] = mxCreateDoubleMatrix(1,kint,mxREAL);//costruisce l'output array
        D= mxGetPr(plhs[1]);
       
        for(i=0;i<kint;i++)//copy in the otput array
        {
          
            results[i]=idcv[i]+1;//copy the output
            D[i]=distvect[i];//The distance is already radsquared
        }
        }
    }
    
    
    
    else
    {
        mexErrMsgTxt("Invalid Input String.");
    }
    

}






