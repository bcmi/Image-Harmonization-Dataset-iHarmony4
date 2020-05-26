///////////////////////////////////////////////////////
// Functions for single-scale gibbs samplers
//
///////////////////////////////////////////////////////
//
// Written by Alex Ihler and Mike Mandel
// Copyright (C) 2003 Alexander Ihler; distributable under GPL -- see README.txt
//


#define MEX
#include "mex.h"
#include "cpp/BallTreeDensity.h"
#include <assert.h>

/**** "GLOBAL" VARS **********/
// REMEMBER -- all multi-dim arrays are column-indexing!  [i,j] => [j*N+i]

double *particles; // [Ndim x Ndens]      // means of selected particles    
double *variance;  // [Ndim x Ndens]      //   variance of selected particles
double  *p;        // [Np]                // probability of ith kernel

BallTree::index *ind;                       // current indexes of MCMC step

double *Malmost, *Calmost; //[Ndim x 1]   // Means & Cov. of all indices but j^th

// Random number callback
double *randU;      // [Npoints * Ndens * (Niter+1)] uniformly distrib'd random variables
double *randN;     // [Ndim * Npoints] normally distrib'd random variables
  
int Ndim, Ndens, Nlevels;
unsigned long dNp;
double *newPoints, *newWeights;
BallTree::index* newIndices;

const BallTreeDensity *trees;

BallTree::index **levelList, **levelListNew;
unsigned long *dNpts;

////////////////////////////////////////////
// Generate initial samples of kernel labels
////////////////////////////////////////////
// uses Ndens, trees, ind, p, randU
void initIndices(void) 
{
  unsigned int j;
  unsigned long z;
  BallTree::index zz;
  
  for (j=0; j<Ndens; j++) {
    dNp = dNpts[j]; //trees[j].Npts();
    for (z=0, zz=levelList[j][0]; z<dNp; zz=levelList[j][++z])
      p[z] = trees[j].weight(zz);  // init by sampling from weights

    for (z=1; z<dNp; z++) p[z] += p[z-1];
    for (z=0, zz=levelList[j][0]; z<dNp-1; zz=levelList[j][++z])
      if (*randU <= p[z]) break;
    ind[j] = zz;
    randU++;
  }
}

void levelInit(void)
{
  unsigned int j;
  unsigned long z;

  for (j=0;j<Ndens;j++) {
    dNpts[j] = 1;
    levelList[j][0] = trees[j].root();
  }
}

void levelDown(void)
{
  unsigned int j;
  unsigned long y,z;

  for (j=0;j<Ndens;j++) {
    z = 0;
    for (y=0;y<dNpts[j];y++) {
      if (trees[j].validIndex(trees[j].left(levelList[j][y])))
        levelListNew[j][z++] = trees[j].left(levelList[j][y]);
      if (trees[j].validIndex(trees[j].right(levelList[j][y])))
        levelListNew[j][z++] = trees[j].right(levelList[j][y]);
      if (ind[j] == levelList[j][y])                        // make sure ind points to
        ind[j] = levelListNew[j][z-1];                      //  a child of the old ind
    }
    dNpts[j] = z;
    BallTree::index *tmp; tmp=levelList[j];                 // make new list the current
    levelList[j] = levelListNew[j]; levelListNew[j]=tmp;    //   list and recycle the old
  }
}

///////////////////////////////////////////////////////////
// calculate means & variance implied by the given indices
///////////////////////////////////////////////////////////
// uses Ndens, trees, ind, particles, variance
void calcIndices(void) 
{
  for (unsigned int j=0; j<Ndens; j++) {
    for (unsigned int z=0; z<Ndim; z++) {
      particles[z+Ndim*j] = trees[j].mean(ind[j])[z];
      variance[z+Ndim*j]  = trees[j].bw(ind[j])[z];
    }
  }
}

///////////////////////////////////////////////////////////
// use labelings to generate point X
///////////////////////////////////////////////////////////
// uses particles, variance, randN
void samplePoint(double* X) 
{
  for (unsigned int j=0; j<Ndim; j++) {
    double mn=0, vn=0;
    for (unsigned int z=0; z<Ndens; z++){ // Compute mean and variances of
      vn += 1/variance[j+Ndim*z];         //   product of selected particles
      mn += particles[j+Ndim*z]/variance[j+Ndim*z];
      }
    vn = 1/vn; mn *= vn;
    X[j] = mn + sqrt(vn) * (*(randN++));  // then draw a sample from it
  }
}

///////////////////////////////////////////////////////////
// given a point X, sample indices of all input densities
///////////////////////////////////////////////////////////
// uses Npts, trees, ind, particles, variance, Cwtg
void sampleIndices(double* X) {
  unsigned int i,j,k;
  unsigned long z;
  BallTree::index zz;

  for (j=0;j<Ndens;j++) {
    unsigned long dNp = dNpts[j]; //trees[j].Npts();
    double pT = 0;

    for (z=0, zz=levelList[j][0]; z<dNp; zz=levelList[j][++z]) {
      p[z] = 0;
      for (i=0; i<Ndim; i++) {
        double tmp = X[i] - trees[j].mean(zz)[i];
        p[z] += (tmp*tmp)/ trees[j].bw(zz)[i];
        p[z] += log(trees[j].bw(zz)[i]);
      }
      p[z] = exp( -0.5 * p[z] ) * trees[j].weight(zz);
      pT += p[z];
    }
    for (z=0; z<dNp; z++) p[z] /= pT;

    for (z=1; z<dNp; z++) p[z] += p[z-1];    // construct CDF and sample a
    for (z=0, zz=levelList[j][0]; z<dNp-1; zz=levelList[j][++z])
      if (*randU <= p[z]) break;             //  new kernel from jth density
    ind[j] = zz;                             //  using those weights
    randU++;
  }
  calcIndices();                             // recompute particles, variance
}

///////////////////////////////////////////////////////////
// given indices for i!=j, sample density j's index
///////////////////////////////////////////////////////////
// uses Ndens, trees, ind, particles, variance, Calmost, Malmost
void sampleIndex(unsigned int j) 
{
  unsigned int i;
  unsigned long z;
  BallTree::index zz;
  unsigned long dNp = dNpts[j]; //trees[j].Npts();
  double pT=0;

  // determine product of selected particles from all but jth density
  for (i=0; i<Ndim; i++) {
    double iCalmost = 0, iMalmost = 0;
    for (unsigned int k=0; k<Ndens; k++) {
      if (k!=j) iCalmost += 1/variance[i+Ndim*k];
      if (k!=j) iMalmost += particles[i+Ndim*k]/variance[i+Ndim*k];
    }
    Calmost[i] = 1/iCalmost;
    Malmost[i] = iMalmost * Calmost[i];
  }

  for (z=0, zz=levelList[j][0]; z<dNp; zz=levelList[j][++z]) {
    p[z] = 0;
    for (i=0; i<Ndim; i++) {
      double tmpC = trees[j].bw(zz)[i] + Calmost[i];
      double tmpM = trees[j].mean(zz)[i] - Malmost[i];
      p[z] += (tmpM*tmpM)/tmpC + log(tmpC);
    }
    p[z] = exp( -0.5 * p[z] ) * trees[j].weight(zz);
    pT  += p[z];
  }
  for (z=0; z<dNp; z++) p[z] /= pT;              // normalize weights

  for (z=1; z<dNp; z++) p[z] += p[z-1];          // construct CDF and sample
  for (z=0, zz=levelList[j][0]; z<dNp-1; zz=levelList[j][++z])
    if (*randU <= p[z]) break;                   //   a new kernel from the jth
  ind[j] = zz;                                   //   density using these weights
  randU++;

  for (i=0; i<Ndim; i++) {
    particles[i+Ndim*j] = trees[j].mean(ind[j])[i];
    variance[i+Ndim*j]  = trees[j].bw(ind[j])[i];  
  }
}

///////////////////////////////////////////////////////////
// given indices for i!=j, sample density j's index
///////////////////////////////////////////////////////////
// uses particles, variance, ind
// uses newPoints, newIndices, trees, Ndens
void gibbs1(unsigned int _Ndens, const BallTreeDensity* _trees,
            unsigned long Np, unsigned int Niter,
            double *_pts, BallTree::index *_ind,
            double *_randU, double* _randN)
{
  unsigned int i,j,l;
  unsigned long s, maxNp;

  Ndens = _Ndens;                       // SET UP GLOBALS
  trees = _trees;
  newPoints = _pts; newIndices = _ind;
  randU = _randU; randN = _randN;
  Ndim  = trees[0].Ndim();              // dimension of densities    
  maxNp = 0;                            // largest # of particles we deal with
  for (unsigned int j=0; j<Ndens; j++)  // compute Max Np over all densities
    if (maxNp < trees[j].Npts()) maxNp = trees[j].Npts();

  ind = new BallTree::index[Ndens];     // ALLOCATE GLOBALS
  p = new double[maxNp];
  Malmost = new double[Ndim];
  Calmost = new double[Ndim];

  Nlevels = (unsigned int) (log(maxNp)/log(2))+1;          // how many levels to a balanced binary tree?

  particles = new double[Ndim*Ndens];
  variance  = new double[Ndim*Ndens];

  dNpts = new unsigned long[Ndens];
  levelList = new BallTree::index*[Ndens];
  levelListNew = new BallTree::index*[Ndens];
  for (j=0;j<Ndens;j++) { 
    levelList[j] = new BallTree::index[maxNp];
    levelListNew[j] = new BallTree::index[maxNp];
  }
  
  for (unsigned long s=0; s<Np; s++) {  //   (for each sample:)

    levelInit();
//  for (l=0;l<Nlevels;l++)  levelDown();
//  for (j=0;j<Ndens;j++)  printf("%d ",dNpts[j]);
    initIndices();                      // sample initial index values
    calcIndices();

    for (l=0;l<Nlevels;l++) {
      samplePoint(newPoints);
      levelDown();
      sampleIndices(newPoints);
      for (i=0;i<Niter;i++) {           //   perform Gibbs sampling
        for (j=0;j<Ndens;j++) {
          sampleIndex(j);
        } 
      } 
    }

    for (unsigned int j=0; j<Ndens; j++)              // save and
      newIndices[j] = trees[j].getIndexOf(ind[j])+1;  // return particle label
    samplePoint(newPoints);                           // draw a sample from that label
    newIndices += Ndens;                              // move pointers to next sample
    newPoints  += Ndim;
  }

  for (j=0;j<Ndens;j++) { delete[] levelList[j];  delete[] levelListNew[j]; }
  delete[] levelList; delete[] levelListNew;
  delete[] dNpts;

  delete[] ind; delete[] p; delete[] particles; delete[] variance;
  delete[] Malmost; delete[] Calmost;
};

///////////////////////////////////////////////////////////
// uses particles, variance, ind
// uses newPoints, newIndices, trees, Ndens
void gibbs2(unsigned int _Ndens, const BallTreeDensity* _trees, 
            unsigned long Np, unsigned int Niter,
            double *_pts, BallTree::index *_ind,
            double *_randU, double* _randN)
{
  unsigned int i,j,l;
  unsigned long s, maxNp;

  Ndens = _Ndens;                       // SET UP GLOBALS
  trees = _trees;
  newPoints = _pts; newIndices = _ind;
  randU = _randU; randN = _randN;
  Ndim  = trees[0].Ndim();              // dimension of densities    
  maxNp = 0;                            // largest # of particles we deal with
  for (unsigned int j=0; j<Ndens; j++)  // compute Max Np over all densities
    if (maxNp < trees[j].Npts()) maxNp = trees[j].Npts();

  ind = new BallTree::index[Ndens];     // ALLOCATE GLOBALS
  p = new double[maxNp];
  
  Nlevels = (unsigned int) (log(maxNp)/log(2))+1;          // how many levels to a balanced binary tree?

  particles = new double[Ndim*Ndens];
  variance  = new double[Ndim*Ndens];

  dNpts = new unsigned long[Ndens];
  levelList = new BallTree::index*[Ndens];
  levelListNew = new BallTree::index*[Ndens];
  for (j=0;j<Ndens;j++) { 
    levelList[j] = new BallTree::index[maxNp];
    levelListNew[j] = new BallTree::index[maxNp];
  }

  for (s=0; s<Np; s++) {                       

    levelInit();
    initIndices();
    calcIndices();

    ///////////////////////////////////////////////////////////////
    // Perform Gibbs sampling only if multiple densities in product
    ///////////////////////////////////////////////////////////////
    samplePoint(newPoints);
    for (l=0;l<Nlevels;l++) {
      levelDown();
      for (i=0;i<Niter;i++) {
        sampleIndices(newPoints);
        samplePoint(newPoints);
    }}

    for (unsigned int j=0; j<Ndens; j++)              // save and
      newIndices[j] = trees[j].getIndexOf(ind[j])+1;  // return particle label
    newIndices += Ndens;                              // move pointers to next sample
    newPoints  += Ndim;
  }

  for (j=0;j<Ndens;j++) { delete[] levelList[j];  delete[] levelListNew[j]; }
  delete[] levelList; delete[] levelListNew;
  delete[] dNpts;

  delete[] ind; delete[] p; delete[] particles; delete[] variance;
};

