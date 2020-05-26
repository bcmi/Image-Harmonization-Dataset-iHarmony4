//////////////////////////////////////////////////////////////////////////////////////
// BallTreeDensity.h  --  class definition for a tree-based kernel density estimate
//
// A few functions are defined only for MEX calls (construction & load from matlab)
// Most others can be used more generally.
// 
//////////////////////////////////////////////////////////////////////////////////////
//
// Written by Alex Ihler and Mike Mandel
// Copyright (C) 2003 Alexander Ihler; distributable under GPL -- see README.txt
//
//////////////////////////////////////////////////////////////////////////////////////
#ifndef __BALL_TREE_DENSITY_H
#define __BALL_TREE_DENSITY_H

#include "BallTree.h"
#include <assert.h>
#include <float.h>

class BallTreeDensity : public BallTree {
 public:
  enum KernelType { Gaussian, Epanetchnikov, Laplacian };
  KernelType getType(void) const { return type; };

  enum Gradient { WRTMean, WRTVariance, WRTWeight };

  /////////////////////////////
  // Constructors
  /////////////////////////////

  //BallTreeDensity( unsigned int d, index N, double* points_,
  //     double* weights_, double* bandwidths_);
#ifdef MEX             // for loading ball trees from matlab
  BallTreeDensity() : BallTree() { bandwidth = bandwidthMax = bandwidthMin = NULL; }
  BallTreeDensity(const mxArray* structure);
  static mxArray* createInMatlab(const mxArray* pts, const mxArray* wts, const mxArray* bw, BallTreeDensity::KernelType _type=Gaussian);
#endif

  /////////////////////////////
  // Accessor Functions  
  /////////////////////////////
  const double* mean(BallTree::index i)     const { return means+i*dims; }
  const double* variance(BallTree::index i) const { return bandwidth+i*dims; } // !!! only works for Gaussian

  const double* bw(BallTree::index i)     const { return bandwidth   +i*dims; }
  const double* bwMax(BallTree::index i)  const { return bandwidthMax+i*dims*multibandwidth; }
  const double* bwMin(BallTree::index i)  const { return bandwidthMin+i*dims*multibandwidth; }
  bool bwUniform(void) const { return multibandwidth==0; };
  //   -- Others inherited from BallTree --

///////////////////////////////
//
// Evaluation of the density at a set of points:
//   pre-constructed balltree version
//   array of doubles version
//   leave-one-out cross-validation version
//
  void evaluate(const BallTree& atPoints, double* values, double maxErr=0) const;
//  void evaluate(index Npts, const double* atPoints, double* values, double maxErr=0) const;
  void evaluate(double* p, double maxErr) const {  evaluate(*this,p,maxErr); }

  void llGrad(const BallTree& locations, double* gradDens, double* gradAt, double tolEval, double tolGrad, Gradient) const;
//  void llGrad(index Npts, const double* atPoints, double* gradDens, double* gradAt, double tolEval, double tolGrad) const;
 
  bool updateBW(const double*, index);




  /////////////////////////////
  // Private object functions
  /////////////////////////////
 protected:
#ifdef MEX
  static mxArray* matlabMakeStruct(const mxArray* pts, const mxArray* wts, const mxArray* bw, BallTreeDensity::KernelType type);
#endif
  virtual void swap(BallTree::index, BallTree::index);// leaf-swapping function
  virtual void   calcStats(BallTree::index root);     // recursion for computing BW ranges

  KernelType type;
  unsigned int multibandwidth;    // flag: is bandwidth uniform?

  double *means;                  // Weighted mean of points from this level down     
  double *bandwidth;              // Variance or other multiscale bandwidth
  double *bandwidthMax,*bandwidthMin; // Bounds on BW in non-uniform case
  
  // Internal evaluate functions:
  //   Recursive tree evaluation
  const static index DirectSize = 100;        // if N*M is less than this, just compute.

  void evaluate(BallTree::index myRoot, const BallTree& atTree, BallTree::index aRoot, double maxErr) const;
  void evalDirect(BallTree::index myRoot, const BallTree& atTree, BallTree::index aRoot) const;

  void llGradDirect(BallTree::index dRoot, const BallTree& atTree, BallTree::index aRoot, Gradient) const;
  void llGradRecurse(BallTree::index dRoot,const BallTree& atTree, BallTree::index aRoot, double tolGrad, Gradient) const;
  void llGradWDirect(index dRoot, const BallTree& atTree, index aRoot) const;
  void llGradWRecurse(index dRoot,const BallTree& atTree, index aRoot, double tolGrad) const;


  //   Bounds on kernel values between points in this subtree & another
  double maxDistKer(BallTree::index dRoot, const BallTree& atTree, BallTree::index aRoot) const { 
    switch(getType()) 
      { case Gaussian:       return maxDistGauss(dRoot,atTree,aRoot);
        case Laplacian:      return maxDistLaplace(dRoot,atTree,aRoot); 
        case Epanetchnikov:  return maxDistEpanetch(dRoot,atTree,aRoot); 
      }
    };
  double minDistKer(BallTree::index dRoot, const BallTree& atTree, BallTree::index aRoot) const {
    switch(getType()) 
      { case Gaussian:       return minDistGauss(dRoot,atTree,aRoot);
        case Laplacian:      return minDistLaplace(dRoot,atTree,aRoot); 
        case Epanetchnikov:  return minDistEpanetch(dRoot,atTree,aRoot); 
      }
    };

  // Types of kernels supported
  double maxDistLaplace(BallTree::index dRoot, const BallTree& atTree, BallTree::index aRoot) const;
  double minDistLaplace(BallTree::index dRoot, const BallTree& atTree, BallTree::index aRoot) const;
  double maxDistGauss(BallTree::index dRoot, const BallTree& atTree, BallTree::index aRoot) const;
  double minDistGauss(BallTree::index dRoot, const BallTree& atTree, BallTree::index aRoot) const;
  double maxDistEpanetch(BallTree::index dRoot, const BallTree& atTree, BallTree::index aRoot, int dim=-1) const;
  double minDistEpanetch(BallTree::index dRoot, const BallTree& atTree, BallTree::index aRoot, int dim=-1) const;

  void  dKdX_p(BallTree::index dRoot,const BallTree& atTree, BallTree::index aRoot, bool bothLeaves, Gradient) const;

};

#endif
