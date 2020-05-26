//////////////////////////////////////////////////////////////////////////////////////
// KD-tree code extended for use in kernel density estimation
//////////////////////////////////////////////////////////////////////////////////////
//
// Written by Alex Ihler and Mike Mandel
// Copyright (C) 2003 Alexander Ihler; distributable under GPL -- see README.txt
//
//////////////////////////////////////////////////////////////////////////////////////
#define MEX
//#define NEWVERSION
#include <math.h>
#include <assert.h>
#include "mex.h"
#include "BallTreeDensity.h"

double *pMin, *pMax;                // need to declare these here, for kernel 
double **pAdd, *pErr;
double *min, *max;                  //   derivative functions in kernel.h

#include "kernels.h"                // min&max kernel bounds for various kernels

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
//
// EVALUATION
//
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

void pushDownLocal(const BallTree& atTree, const BallTree::index aRoot)
{
  BallTree::index close;
    if (!atTree.isLeaf(aRoot)) {
      close = atTree.left(aRoot); 
      if (close != BallTree::NO_CHILD) pAdd[0][close] += pAdd[0][aRoot];
      close = atTree.right(aRoot); 
      if (close != BallTree::NO_CHILD) pAdd[0][close] += pAdd[0][aRoot];
      pAdd[0][aRoot] = 0;
    }
}
void pushDownAll(const BallTree& locations)
{
  BallTree::index j;
  for (j=locations.root(); j<locations.leafFirst(locations.root())-1; j++) {
      pAdd[0][locations.left(j)] += pAdd[0][j];
      pAdd[0][locations.right(j)] += pAdd[0][j];
      pAdd[0][j] = 0;
    }
    for (j=locations.leafFirst(locations.root()); j<=locations.leafLast(locations.root()); j++) {
      pMin[j] += pAdd[0][j] - pErr[j];
      pMax[j] += pAdd[0][j] + pErr[j];
      pAdd[0][j] = 0; pErr[j] = 0; 
    }
}
void recurseMinMax(const BallTree& atTree, const BallTree::index aRoot)
{
  BallTree::index l,r; l = atTree.left(aRoot); r = atTree.right(aRoot);
  if (!atTree.isLeaf(l)) recurseMinMax(atTree,l);
  if (!atTree.isLeaf(r)) recurseMinMax(atTree,r);
  pMin[aRoot] = pMin[l]; pMax[aRoot] = pMax[l];
  if (pMin[aRoot] > pMin[r]) pMin[aRoot] = pMin[r];
  if (pMax[aRoot] < pMax[r]) pMax[aRoot] = pMax[r];
}
/////////////////////////////////////////////////////////////////////
// Recursively evaluate the density implied by the samples of the 
// subtree (rooted at dRoot) of densTree at the locations given by
// the subtree (rooted at aRoot) of *this, to within the error 
// percentage "maxErr"
/////////////////////////////////////////////////////////////////////

void BallTreeDensity::evaluate(BallTree::index dRoot,
              const BallTree& atTree, BallTree::index aRoot, 
              double maxErr) const
{
  BallTree::index k, close, far;
  double Kmin,Kmax,add,total;

  // find the minimum and maximum effect of these two balls on each other
  Kmax = minDistKer(dRoot, atTree, aRoot);
  Kmin = maxDistKer(dRoot, atTree, aRoot);

  total = pMin[ aRoot ];		   	     // take pmin of data below this level
#ifdef NEWVERSION
  total += pAdd[0][aRoot] - pErr[aRoot]; // add lower bound from local expansion
#endif
  total += weight(dRoot)*Kmin;           // also add minimum for this block

  // if the weighted contribution of this multiply is below the
  //    threshold, no need to recurse; just treat as constant
  //// //if ( Kmax - Kmin <= maxErr) {                    // APPROXIMATE: ABSOLUTE
  if ( Kmax - Kmin <= maxErr * total) {                    // APPROXIMATE: PERCENT
    Kmin *= weight(dRoot); Kmax *= weight(dRoot);

    if (this == &atTree && aRoot==dRoot) {                 // LEAVE-ONE-OUT (and same subtree)
      for (k=atTree.leafFirst(aRoot); k<=atTree.leafLast(aRoot); k++){
        pMin[k] += Kmin * (1 - weight(k)/weight(dRoot));   // leave our weight out of it
        pMax[k] += Kmax * (1 - weight(k)/weight(dRoot));   // 
      }
      recurseMinMax(atTree,aRoot);
    } else {                                               //     NO L-O-O => just add away
#ifdef NEWVERSION
      pAdd[0][aRoot] += (Kmin + Kmax)/2; pErr[aRoot] = (Kmax-Kmin)/2;
#else
      // !!! Should *not* do this -- instead add to local expansion (constant term)
      for (k=atTree.leafFirst(aRoot); k<=atTree.leafLast(aRoot); k++) {
        pMin[k] += Kmin;
        pMax[k] += Kmax;
      }
#endif
      if (!atTree.isLeaf(aRoot)) { pMin[aRoot] += Kmin; pMax[aRoot] += Kmax; }
    }

  } else if (Npts(dRoot)*atTree.Npts(aRoot)<=DirectSize){  // DIRECT EVALUATION
    evalDirect(dRoot,atTree,aRoot);
  } else if (0) {                                          // FAST GAUSS APPROX
    // if FGTTerms > 0 : have computed Hermite expansions of densTree (sigma uniform)
    // if FGTError(dRoot->Nterms,minDistDtoA,sigma) < maxError * total
    //  (if maxError, sigma, Nterms known, compute R0 & check >= minDist)
    //   translate dRoot's hermite expansion to a local expansion around aRoot
    //   Need to iterate over aRoot's leaves & evaluate?  (N log N)
    //   Update pMin structure...
  } else {                                                 // RECURSE ON SUBTREES

#ifdef NEWVERSION
    // push any local expansion
    pushDownLocal(atTree,aRoot);
#endif

    // Find the subtree in closest to the other tree's left child and do 
    // that first so that the values are higher and there is a better
    // chance of being able to skip a recursion.
    close = atTree.closer( atTree.left(aRoot), atTree.right(aRoot), *this, left(dRoot)); 
    if (left(dRoot) != NO_CHILD && close != NO_CHILD)
      evaluate(left(dRoot), atTree, close, maxErr); 
    far   = (close == atTree.left(aRoot)) ? atTree.right(aRoot) : atTree.left(aRoot);
    if (left(dRoot) != NO_CHILD && far != NO_CHILD)
      evaluate(left(dRoot), atTree, far, maxErr); 

    // Now the same thing for the density's right child    
    close = atTree.closer( atTree.left(aRoot), atTree.right(aRoot), *this, right(dRoot)); 
    if (right(dRoot) != NO_CHILD && close != NO_CHILD) 
      evaluate(right(dRoot), atTree, close, maxErr); 
    far   = (close == atTree.left(aRoot)) ? atTree.right(aRoot) : atTree.left(aRoot);
    if (right(dRoot) != NO_CHILD && far != NO_CHILD) 
      evaluate(right(dRoot), atTree, far, maxErr); 

    // Propogate additions in children's minimum value to this node
    if (!atTree.isLeaf(aRoot)) {
      pMin[aRoot] = pMin[ atTree.left(aRoot) ]; 
      pMax[aRoot] = pMax[ atTree.left(aRoot) ];
      if (atTree.right(aRoot) != NO_CHILD) {
        if (pMin[aRoot] > pMin[ atTree.right(aRoot) ])
          pMin[aRoot] = pMin[ atTree.right(aRoot) ];
        if (pMax[aRoot] < pMax[ atTree.right(aRoot) ])
          pMax[aRoot] = pMax[ atTree.right(aRoot) ];
      }
    }

  }
}

///////////////////////////////////////////
// Maybe we just want to evaluate this stuff directly.
///////////////////////////////////////////
void BallTreeDensity::evalDirect(BallTree::index dRoot, const BallTree& atTree, BallTree::index aRoot) const
{
  BallTree::index i,j;
  bool firstFlag = true;
  double minVal=2e22, maxVal=0;

  for (j=atTree.leafFirst(aRoot); j<=atTree.leafLast(aRoot); j++) {
    for (i=leafFirst(dRoot); i<=leafLast(dRoot); i++) {
      if (this != &atTree || i!=j) {               // Check leave-one-out condition;
        double d = weight(i) * maxDistKer(i,atTree,j);  //  Do direct N^2 kernel evaluation
        //if (this == &atTree) d /= 1-weight(j);     // leave-one-out => renormalize weights
        pMin[j] += d;
        pMax[j] += d;
      }
    }
#ifdef NEWVERSION
  }
  recurseMinMax(atTree,aRoot);              // pass up min (& max) value for pruning
#else
  if (pMin[j] < minVal) minVal = pMin[j];   // determine min & max value in this block
  if (pMax[j] > maxVal) maxVal = pMax[j];   
  }
  pMin[aRoot] = minVal; pMax[aRoot] = maxVal;
#endif
}

/////////////////////////////////////////////////////////////////////
// Dual Tree evaluation: estimate the values at this ball tree's
// points given the other tree as the samples from a distribution.
/////////////////////////////////////////////////////////////////////
void BallTreeDensity::evaluate(const BallTree& locations, double* p, double maxErr) const
{
  BallTree::index j;
  
  assert(Ndim() == locations.Ndim());
  assert(p != NULL);

  pMin = new double[2*locations.Npts()];
  pMax = new double[2*locations.Npts()];
  for (j=0;j<2*locations.Npts();j++) pMin[j] = pMax[j] = 0;
#ifdef NEWVERSION
  pAdd = new double*[1]; pAdd[0] = new double[2*locations.Npts()];
  pErr = new double[2*locations.Npts()];
  for (j=0;j<2*locations.Npts();j++) pAdd[0][j] = pErr[j] = 0;
#endif
  
  evaluate(root(), locations, locations.root(), 2*maxErr);

  // Compute & account for the kernel f'ns normalization constant
  double norm = 1;
  switch(getType()) {
    case Gaussian:  norm = pow(2*PI, ((double)Ndim())/2 );
                    if (bwUniform()) 
                      for (unsigned int i=0;i<Ndim();i++) norm *= sqrt(bandwidthMax[i]);
                    break;
    case Laplacian: norm = pow(2, ((double)Ndim()) );
                    if (bwUniform()) 
                      for (unsigned int i=0;i<Ndim();i++) norm *= bandwidthMax[i];
                    break;
    case Epanetchnikov: norm = pow(4.0/3, ((double)Ndim()) );
                    if (bwUniform()) 
                      for (unsigned int i=0;i<Ndim();i++) norm *= bandwidthMax[i];
                    break;
  }

  BallTree::index lRoot = locations.root();
#ifdef NEWVERSION
  pushDownAll(locations);
#endif
  if (this == &locations) {                          // if we need to do leave-one-out
    for (j=locations.leafFirst(lRoot); j<=locations.leafLast(lRoot); j++)
      p[locations.getIndexOf(j)] = .5*(pMin[j]+pMax[j])/norm/(1-weight(j));
  } else {
    for (j=locations.leafFirst(lRoot); j<=locations.leafLast(lRoot); j++)
      p[locations.getIndexOf(j)] = .5*(pMin[j]+pMax[j])/norm;
  }

  delete[] pMin; delete[] pMax; 
#ifdef NEWVERSION
  delete[] pAdd[0]; delete[] pAdd;
#endif
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
//
// GRADIENT CALCULATION
//
//    Recursively evaluate the derivative of log-likelihood for two trees
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
double *gradD, *gradA;

////////////////////////////////////////////////////////////////////////////////////
// DIRECT VERSION:
//   Just iterate over the N^2 indices; faster than recursion for small N.
////////////////////////////////////////////////////////////////////////////////////
void BallTreeDensity::llGradDirect(BallTree::index dRoot, const BallTree& atTree, BallTree::index aRoot, Gradient gradWRT) const
{
  BallTree::index i,j;
  unsigned int k;

  for (i=atTree.leafFirst(aRoot);i<=atTree.leafLast(aRoot);i++) {
    for (j=leafFirst(dRoot);j<=leafLast(dRoot);j++) {
      if (this != &atTree || i!=j) {               // Check leave-one-out condition;
        index Nj = Ndim() * getIndexOf(j);
        index Ni = atTree.Ndim() * atTree.getIndexOf(i);
        dKdX_p(j,atTree,i,true,gradWRT);            // use "true" to signal leaf evaluation
        if (gradD) for (k=0;k<Ndim();k++) {
          gradD[Nj+k] -= weight(j) * atTree.weight(i) * (max[k]+min[k])/2;
        }
        if (gradA) for (k=0;k<Ndim();k++) {
          gradA[Ni+k] += weight(j) * atTree.weight(i) * (max[k]+min[k])/2;
        }
  } } }
}

////////////////////////////////////////////////////////////////////////////////////
// RECURSIVE VERSION:
//   Try to find approximations to speed things up.
////////////////////////////////////////////////////////////////////////////////////
void BallTreeDensity::llGradRecurse(BallTree::index dRoot,const BallTree& atTree, BallTree::index aRoot, double tolGrad, Gradient gradWRT) const
{
  BallTree::index i,j,close,far;
  unsigned int k; 

  dKdX_p(dRoot,atTree,aRoot,false,gradWRT);      // "false" signals maybe not leaf nodes
  double norm = 0;
  for (k=0;k<Ndim();k++) norm += .25*(max[k]-min[k])*(max[k]-min[k]);

  if (norm <= tolGrad) {     // IF OUR APPROXIMATION IS GOOD ENOUGH, ...
    if (this == &atTree && aRoot==dRoot) {                 // LEAVE-ONE-OUT (and same subtree)
      if (gradD) for (j=leafFirst(dRoot);j<=leafLast(dRoot);j++) {
        index Nj = Ndim() * getIndexOf(j);
        for (k=0;k<Ndim();k++)
          gradD[Nj+k] -= (atTree.weight(aRoot)-atTree.weight(j)) * weight(j) * (max[k]+min[k])/2;
      }
      if (gradA) for (i=atTree.leafFirst(aRoot);i<=atTree.leafLast(aRoot);i++) {
        index Ni = atTree.Ndim() * atTree.getIndexOf(i);
        for (k=0;k<Ndim();k++)
          gradA[Ni+k] += atTree.weight(i) * (weight(dRoot)-weight(i)) * (max[k]+min[k])/2;
      }
    } else {                                              // NO LOO; just regular
      if (gradD) for (j=leafFirst(dRoot);j<=leafLast(dRoot);j++) {
        index Nj = Ndim() * getIndexOf(j);
        for (k=0;k<Ndim();k++)
          gradD[Nj+k] -= atTree.weight(aRoot) * weight(j) * (max[k]+min[k])/2;
      }
      if (gradA) for (i=atTree.leafFirst(aRoot);i<=atTree.leafLast(aRoot);i++) {
        index Ni = atTree.Ndim() * atTree.getIndexOf(i);
        for (k=0;k<Ndim();k++)
          gradA[Ni+k] += atTree.weight(i) * weight(dRoot) * (max[k]+min[k])/2;
      }
    } 
                          // OR, IF THERE ARE VERY FEW POINTS
  } else if (Npts(dRoot)*atTree.Npts(aRoot)<=DirectSize){  // DIRECT EVALUATION
    llGradDirect(dRoot,atTree,aRoot,gradWRT);
    
  } else {
    close = atTree.closer( atTree.left(aRoot), atTree.right(aRoot), *this, left(dRoot)); 
    if (left(dRoot) != NO_CHILD && close != NO_CHILD)
      llGradRecurse(left(dRoot),atTree,close,tolGrad,gradWRT);
    far   = (close == atTree.left(aRoot)) ? atTree.right(aRoot) : atTree.left(aRoot);
    if (left(dRoot) != NO_CHILD && far != NO_CHILD)
      llGradRecurse(left(dRoot),atTree,far,tolGrad,gradWRT);

    close = atTree.closer( atTree.left(aRoot), atTree.right(aRoot), *this, right(dRoot)); 
    if (right(dRoot) != NO_CHILD && close != NO_CHILD) 
      llGradRecurse(right(dRoot),atTree,close,tolGrad,gradWRT);
    far   = (close == atTree.left(aRoot)) ? atTree.right(aRoot) : atTree.left(aRoot);
    if (right(dRoot) != NO_CHILD && far != NO_CHILD) 
      llGradRecurse(right(dRoot),atTree,far,tolGrad,gradWRT);
  }
}

////////////////////////////////////////////////////////////////////////////////////
//   L = sum_i wi log p(yi) = sum_i wi log[ sum_j wj K(yi-xj) ]
//  =>  d(log L)/dxj[k] = - sum_i wi 1/p(yi) wj K'(xj-yi)
//      d(log L)/dyi[k] = wi 1/p(yi) sum_j wj K'(xj-yi)     (same K')
//
////////////////////////////////////////////////////////////////////////////////////
void BallTreeDensity::llGrad(const BallTree& locations, double* _gradD, double* _gradA, double tolEval, double tolGrad, Gradient gradWRT) const
{
  BallTree::index j, k;
  gradD = _gradD; gradA = _gradA;

  min = new double[locations.Ndim()]; max = new double[locations.Ndim()];
  pMin = new double[2*locations.Npts()];
  pMax = new double[2*locations.Npts()];
  for (j=0;j<2*locations.Npts();j++) pMin[j] = pMax[j] = 0;
#ifdef NEWVERSION
  pAdd = new double*[1]; pAdd[0] = new double[2*locations.Npts()];
  pErr = new double[2*locations.Npts()];
  for (j=0;j<2*locations.Npts();j++) pAdd[0][j] = pErr[j] = 0;
#endif
  evaluate(root(), locations, locations.root(), 2*tolEval);
#ifdef NEWVERSION
  pushDownAll(locations);  
#endif
  if (this == &locations) {                          // fix leave-one-out normalization
    for (j=leafFirst(root()); j<=leafLast(root()); j++)
      pMax[j] /= (1-weight(j)); pMin[j] /= (1-weight(j));
  }

  if(gradWRT == WRTWeight)
    llGradWRecurse(root(),locations,locations.root(), tolGrad*tolGrad);
  else
    llGradRecurse(root(),locations,locations.root(), tolGrad*tolGrad, gradWRT);

  if (this == &locations) {                          // fix leave-one-out normalization
    for (j=leafFirst(root()); j<=leafLast(root()); j++) {
      index Nj = Ndim() * getIndexOf(j);
      for (k=0;k<Ndim();k++) {
        if (gradD) gradD[Nj+k] /= (1-weight(j)); 
		if (gradA) gradA[Nj+k] /= (1-weight(j));
  } } }

  delete[] min; delete[] max; 
  delete[] pMax; delete[] pMin;
#ifdef NEWVERSION
  delete[] pAdd[0]; delete[] pAdd; delete[] pErr;
#endif
}



////////////////////////////////////////////////////////////////////////////////////
// Gradient wrt WEIGHT 
// DIRECT VERSION:
//   Just iterate over the N^2 indices; faster than recursion for small N.
////////////////////////////////////////////////////////////////////////////////////
void BallTreeDensity::llGradWDirect(BallTree::index dRoot, const BallTree& atTree, 
				    BallTree::index aRoot) const
{
  BallTree::index i,j;

  for (i=atTree.leafFirst(aRoot);i<=atTree.leafLast(aRoot);i++) {
    for (j=leafFirst(dRoot);j<=leafLast(dRoot);j++) {
      dKdX_p(j,atTree,i,true,WRTWeight);            // use "true" to signal leaf evaluation
      if (gradD)
        gradD[getIndexOf(j)] -= atTree.weight(i) * (max[0]+min[0])/2;
      if (gradA)
        gradA[atTree.getIndexOf(i)] += weight(j) * (max[0]+min[0])/2;
    } 
  }
}

////////////////////////////////////////////////////////////////////////////////////
// Gradient wrt WEIGHT 
// RECURSIVE VERSION:
//   Try to find approximations to speed things up.
////////////////////////////////////////////////////////////////////////////////////
void BallTreeDensity::llGradWRecurse(BallTree::index dRoot,const BallTree& atTree, 
				     BallTree::index aRoot, double tolGrad) const
{
  BallTree::index i,j,close,far;

  dKdX_p(dRoot,atTree,aRoot,false,WRTWeight);      // "false" signals maybe not leaf nodes
  double norm = (max[0]-min[0]) * (max[0]-min[0]);

  if (norm <= tolGrad) {
    if (gradD) for (j=leafFirst(dRoot);j<=leafLast(dRoot);j++) {
      gradD[getIndexOf(j)] -= atTree.weight(aRoot) * (max[0]+min[0])/2;
    }
    if (gradA) for (i=atTree.leafFirst(aRoot);i<=atTree.leafLast(aRoot);i++) {
      gradA[atTree.getIndexOf(i)] += weight(dRoot) * (max[0]+min[0])/2;
    }
    
  } else if (Npts(dRoot)*atTree.Npts(aRoot)<=100){  // DIRECT EVALUATION
    llGradWDirect(dRoot,atTree,aRoot);
    
  } else {
    close = atTree.closer( atTree.left(aRoot), atTree.right(aRoot), *this, left(dRoot)); 
    if (left(dRoot) != NO_CHILD && close != NO_CHILD)
      llGradWRecurse(left(dRoot),atTree,close,tolGrad);
    far   = (close == atTree.left(aRoot)) ? atTree.right(aRoot) : atTree.left(aRoot);
    if (left(dRoot) != NO_CHILD && far != NO_CHILD)
      llGradWRecurse(left(dRoot),atTree,far,tolGrad);

    close = atTree.closer( atTree.left(aRoot), atTree.right(aRoot), *this, right(dRoot)); 
    if (right(dRoot) != NO_CHILD && close != NO_CHILD) 
      llGradWRecurse(right(dRoot),atTree,close,tolGrad);
    far   = (close == atTree.left(aRoot)) ? atTree.right(aRoot) : atTree.left(aRoot);
    if (right(dRoot) != NO_CHILD && far != NO_CHILD) 
      llGradWRecurse(right(dRoot),atTree,far,tolGrad);
  }
}


///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
//
// CONSTRUCTION METHODS
//
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////


#ifdef MEX
// Load the arrays already allocated in matlab from the given
// structure.
BallTreeDensity::BallTreeDensity(const mxArray* structure) : BallTree(structure) {

  means     = mxGetPr(mxGetField(structure,0,"means"));
  bandwidth = (double*) mxGetData(mxGetField(structure,0,"bandwidth"));
  type = (BallTreeDensity::KernelType) mxGetScalar(mxGetField(structure,0,"type")); 

  if (mxGetN(mxGetField(structure,0,"bandwidth")) == 6*num_points) {
    multibandwidth = 1;
    bandwidthMax = bandwidth + 2*num_points*dims;       // not all the same =>
    bandwidthMin = bandwidthMax + 2*num_points*dims;    //   track min/max vals
  } else {                                              // all the same => min = max
    multibandwidth = 0;                                 //         = any leaf node
    bandwidthMax = bandwidthMin = bandwidth + num_points*dims;
  }
}


// Create new matlab arrays and put them in the given structure
mxArray* BallTreeDensity::createInMatlab(const mxArray* _pointsMatrix, const mxArray* _weightsMatrix,
                                         const mxArray* _bwMatrix,BallTreeDensity::KernelType _type)
{
  mxArray* structure = matlabMakeStruct(_pointsMatrix, _weightsMatrix,_bwMatrix,_type);
  BallTreeDensity dens(structure);
  if (dens.Npts() > 0) dens.buildTree();

  return structure;
}

// Create new matlab arrays and put them in the given structure.
mxArray* BallTreeDensity::matlabMakeStruct(const mxArray* _pointsMatrix, const mxArray* _weightsMatrix,
                                           const mxArray* _bwMatrix,BallTreeDensity::KernelType _type)
{
  BallTree::index i,j;

  mxArray* structure = BallTree::matlabMakeStruct(_pointsMatrix, _weightsMatrix);

  unsigned int Nd = (unsigned int) mxGetScalar(mxGetField(structure,0,"D"));
  index Np = (BallTree::index) mxGetScalar(mxGetField(structure,0,"N"));

  mxAddField(structure, "means");
  mxSetField(structure, 0, "means", mxCreateDoubleMatrix(Nd, 2*Np, mxREAL));

  mxAddField(structure, "bandwidth");
  if (mxGetN(_bwMatrix) == 1)
    mxSetField(structure, 0, "bandwidth",     mxCreateDoubleMatrix(Nd, 2*Np, mxREAL));
  else
    mxSetField(structure, 0, "bandwidth",     mxCreateDoubleMatrix(Nd, 6*Np, mxREAL));

  mxAddField(structure, "type");
    mxSetField(structure, 0, "type",          mxCreateDoubleScalar((double)_type));

  // initialize arrays
  double* means = (double *) mxGetData(mxGetField(structure, 0, "means"));
  double* points = (double *) mxGetData(mxGetField(structure, 0, "centers"));
  for (j=0,i=Nd*Np; j<Nd*Np; i++,j++)
    means[i] = points[i];
  double* bw = (double *) mxGetData(mxGetField(structure, 0, "bandwidth"));
  double* bwIn = (double *) mxGetData(_bwMatrix);
  if (mxGetN(_bwMatrix) == 1) {
    for (j=0,i=Nd*Np; j<Nd*Np; i++,j++)
      bw[i] = bwIn[j%Nd];
  } else {
    double *bwMax, *bwMin; bwMax = bw + 2*Np*Nd; bwMin = bwMax + 2*Np*Nd;
    for (j=0,i=Nd*Np; j<Nd*Np; i++,j++)
      bwMax[i] = bwMin[i] = bw[i] = bwIn[j];
  }  

  return structure;
}
#endif

// returns true on success, false on failure
bool BallTreeDensity::updateBW(const double* newBWs, index N)
{
  if((N == num_points && multibandwidth == 0) || 
     (N == 1 && multibandwidth == 1)) {
//     mexPrintf("multibandwidth=%d, num_points=%d, N=%d\n", multibandwidth, num_points, N);
    return false;
  }

  index i,j;
  // pointers all stay the same, just copy data over
  if (N == 1) {
    for (j=0,i=dims*num_points; j<dims*num_points; i++,j++)
      bandwidth[i] = newBWs[j%dims];
  } else {
    double *bwMax, *bwMin; 
    bwMax = bandwidth + 2*num_points*dims; 
    bwMin = bwMax + 2*num_points*dims;
    for (j=0,i=dims*num_points; j<dims*num_points; i++,j++)
      bwMax[i] = bwMin[i] = bandwidth[i] = newBWs[j];
  }  

  // calculate bandwidths for non-leaf nodes
  for (i=num_points-1; i != 0; i--)
    calcStats(i);
  calcStats(root());
  return true;
}

void BallTreeDensity::calcStats(BallTree::index root)
{
  BallTree::calcStats(root);

  BallTree::index Ni, NiL, NiR;
  double wtL,wtR,wtT;
  unsigned int k;

  BallTree::index leftI = left(root), rightI=right(root);   // get children indices 
  if (!validIndex(leftI) || !validIndex(rightI)) return;    // nothing to do if this
                                                            //   isn't a parent node
  Ni  = dims*root;   NiL = dims*leftI;   NiR = dims*rightI;
  wtL = weight(leftI); wtR = weight(rightI); wtT = wtL + wtR + DBL_EPSILON;
  wtL /= wtT; wtR /= wtT;

  if (!bwUniform()) {
    for(k = 0; k < dims; k++) {
      bandwidthMax[Ni+k] = (bandwidthMax[NiL+k] > bandwidthMax[NiR+k]) 
                              ? bandwidthMax[NiL+k] : bandwidthMax[NiR+k];
      bandwidthMin[Ni+k] = (bandwidthMin[NiL+k] < bandwidthMin[NiR+k]) 
                              ? bandwidthMin[NiL+k] : bandwidthMin[NiR+k];
  } }

  switch(type) {
  case Gaussian:
    for(unsigned int k=0; k < dims; k++) {
      means[Ni+k]     = wtL * means[NiL+k] + wtR * means[NiR+k];
      bandwidth[Ni+k] = wtL* (bandwidth[NiL+k] + means[NiL+k]*means[NiL+k]) +
                        wtR* (bandwidth[NiR+k] + means[NiR+k]*means[NiR+k]) -
                        means[Ni+k]*means[Ni+k];
    }; break;
  case Laplacian:
    for(unsigned int k=0; k < dims; k++) {
      means[Ni+k]     = wtL * means[NiL+k] + wtR * means[NiR+k];
      bandwidth[Ni+k] = wtL* (2*bandwidth[NiL+k]*bandwidth[NiL+k] + means[NiL+k]*means[NiL+k]) +
                        wtR* (2*bandwidth[NiR+k]*bandwidth[NiR+k] + means[NiR+k]*means[NiR+k]) -
                        means[Ni+k]*means[Ni+k];     // compute in terms of variance
      bandwidth[Ni+k] = sqrt(.5*bandwidth[Ni+k]);    //  then convert back to normal BW rep.
    }; break;
  case Epanetchnikov:
    for(unsigned int k=0; k < dims; k++) {
      means[Ni+k]     = wtL * means[NiL+k] + wtR * means[NiR+k];
      bandwidth[Ni+k] = wtL* (.2*bandwidth[NiL+k]*bandwidth[NiL+k] + means[NiL+k]*means[NiL+k]) +
                        wtR* (.2*bandwidth[NiR+k]*bandwidth[NiR+k] + means[NiR+k]*means[NiR+k]) -
                        means[Ni+k]*means[Ni+k];     // compute in terms of variance
      bandwidth[Ni+k] = sqrt(5*bandwidth[Ni+k]);     //  then convert back to normal BW rep.
    }; break; 
 }

}

// Swap the ith leaf with the jth leaf.
void BallTreeDensity::swap(BallTree::index i, BallTree::index j) 
{
  if (i==j) return;

  BallTree::swap(i,j);

  i *= dims;  j *= dims;
  for(unsigned int k=0; k<dims; i++,j++,k++) {
    double tmp;
    tmp = means[i];       means[i]      = means[j];       means[j]      = tmp;
    tmp = bandwidth[i];   bandwidth[i]  = bandwidth[j];   bandwidth[j]  = tmp;
    if (!bwUniform()) {
      tmp = bandwidthMax[i];bandwidthMax[i]=bandwidthMax[j];bandwidthMax[j]=tmp;
      tmp = bandwidthMin[i];bandwidthMin[i]=bandwidthMin[j];bandwidthMin[j]=tmp;
    }
  }
}


