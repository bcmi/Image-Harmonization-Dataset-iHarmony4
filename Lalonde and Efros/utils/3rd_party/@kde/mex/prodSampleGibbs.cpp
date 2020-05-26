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
  
int Ndim, Ndens;
unsigned long dNp;
double *newPoints, *newWeights;
BallTree::index *newIndices;

const BallTreeDensity *trees;



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
    dNp = trees[j].Npts();
    for (z=0, zz=trees[j].leafFirst(0); z<dNp; z++,zz++) 
      p[z] = trees[j].weight(zz);  // init by sampling from weights

    for (z=1; z<dNp; z++) p[z] += p[z-1];
    for (z=0, zz=trees[j].leafFirst(0); z<dNp-1; z++,zz++)
      if (*randU <= p[z]) break;
    ind[j] = zz;
    randU++;
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
    unsigned long dNp = trees[j].Npts();
    double pT = 0;

    zz = trees[j].leafFirst(0);
    for (z=0; z<dNp; z++,zz++) {
      p[z] = 0;
      for (i=0; i<Ndim; i++) {
        double tmp = X[i] - trees[j].mean(zz)[i];
        p[z] += (tmp*tmp)/trees[j].bw(zz)[i];
        p[z] += log(trees[j].bw(zz)[i]);   // unimportant if equal variances
      }
      p[z] = exp( -0.5 * p[z] ) * trees[j].weight(zz);
      pT += p[z];
    }
    for (z=0; z<dNp; z++) p[z] /= pT;

    for (z=1; z<dNp; z++) p[z] += p[z-1];    // construct CDF and sample a
    for (z=0,zz = trees[j].leafFirst(0); z<dNp-1; z++,zz++)         
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
  unsigned long dNp = trees[j].Npts();
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

  for (z = 0, zz = trees[j].leafFirst(0); z<dNp; z++, zz++) {
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
  for (z=0, zz = trees[j].leafFirst(0); z<dNp-1; z++, zz++)
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
  unsigned int i,j;
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

  particles = new double[Ndim*Ndens];
  variance  = new double[Ndim*Ndens];

  for (unsigned long s=0; s<Np; s++) {  //   (for each sample:)

    initIndices();                      // sample initial index values
    calcIndices();

    if (Ndens > 1) {                    // if there are multiple densities
      for (i=0;i<Niter;i++) {           //   perform Gibbs sampling
        for (j=0;j<Ndens;j++) {
          sampleIndex(j);
    } } }

    for (unsigned int j=0; j<Ndens; j++)              // save and
      newIndices[j] = trees[j].getIndexOf(ind[j])+1;  // return particle label
    samplePoint(newPoints);                           // draw a sample from that label
    newIndices += Ndens;                              // move pointers to next sample
    newPoints  += Ndim;
  }

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
  unsigned int i,j;
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

  particles = new double[Ndim*Ndens];
  variance  = new double[Ndim*Ndens];

  for (s=0; s<Np; s++) {                       

    initIndices();
    calcIndices();

    ///////////////////////////////////////////////////////////////
    // Perform Gibbs sampling only if multiple densities in product
    ///////////////////////////////////////////////////////////////
    if (Ndens > 1) {
      for (i=0;i<Niter;i++) {
        samplePoint(newPoints);
        sampleIndices(newPoints);
      }
    }

    for (unsigned int j=0; j<Ndens; j++)              // save and
      newIndices[j] = trees[j].getIndexOf(ind[j])+1;  // return particle label
    samplePoint(newPoints);                           // draw a sample from that label
    newIndices += Ndens;                              // move pointers to next sample
    newPoints  += Ndim;
  }

  delete[] ind; delete[] p; delete[] particles; delete[] variance;
};

