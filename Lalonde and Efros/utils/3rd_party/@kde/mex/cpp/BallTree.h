//////////////////////////////////////////////////////////////////////////////////////
// BallTree.h  --  class definition for a BallTree (actually KD-tree) object
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
#ifndef __BALL_TREE_H
#define __BALL_TREE_H

#ifdef MEX
#include "mex.h"
#endif

#include <math.h>
#include <stdint.h>
#define FALSE 0
#define TRUE 1

double log(double);
double exp(double);
double sqrt(double);
double pow(double , double);
double fabs(double);
#define PI 3.141592653589


class BallTree {
 public:
  //typedef unsigned int index;              // define "index" type (long)
  typedef uint32_t index;              // define "index" type (long)
  const static BallTree::index NO_CHILD = (index) -1;  // indicates no further children

  /////////////////////////////
  // Constructors
  /////////////////////////////
  
  //BallTree( unsigned int d, index N, double* centers_,
  //     double* ranges_, double* weights_ );
#ifdef MEX
  BallTree();
  BallTree(const mxArray* structure);     // for loading ball trees from matlab
  
  // For creating BallTree structures in matlab:
  static mxArray*  createInMatlab(const mxArray* pts, const mxArray* wts);
#endif

  /////////////////////////////
  // Accessor Functions  
  /////////////////////////////
  BallTree::index root() const              { return 0; }
  unsigned int    Ndim() const              { return dims; }
  index Npts()                    const { return num_points; }
  index Npts(BallTree::index i)   const { return highest_leaf[i]-lowest_leaf[i]+1; }
  const double* center(BallTree::index i)   const { return centers+i*dims; }
  const double* range(BallTree::index i)    const { return ranges +i*dims; }
  double  weight(BallTree::index i)         const { return *(weights+i); }
  bool isLeaf(BallTree::index ind)          const { return ind >= num_points; }
  bool validIndex(BallTree::index ind)      const { return ((0<=ind) && (ind < 2*num_points)); }
  BallTree::index left(BallTree::index i)   const { return left_child[i]; }
  BallTree::index right(BallTree::index i)  const { return right_child[i]; }
  BallTree::index leafFirst(BallTree::index i) const { return lowest_leaf[i]; }
  BallTree::index leafLast(BallTree::index i)  const { return highest_leaf[i]; }

  // Convert a BallTree::index to the numeric index in the original data
  index getIndexOf(BallTree::index i) const { return permutation[i]; }

  void movePoints(double*);
  void changeWeights(const double *);

  // Test two sub-trees to see which is nearer another BallTree
  BallTree::index closer(BallTree::index, BallTree::index, const BallTree&,BallTree::index) const;  
  BallTree::index closer(BallTree::index i, BallTree::index j, const BallTree& other_tree) const
      { return closer(i,j,other_tree,other_tree.root()); };

  void kNearestNeighbors(index *, double *, const double *, int, int) const;

  /////////////////////////////
  // Private class f'ns
  /////////////////////////////
 protected:
#ifdef MEX
  static mxArray*  matlabMakeStruct(const mxArray* pts, const mxArray* wts);
#endif
  virtual void calcStats(BallTree::index);     // construction recursion

  unsigned int dims;             // dimension of data 
  BallTree::index num_points;     // # of points 
  double *centers;                // ball centers, dims numbers per ball 
  double *ranges;                 // bounding box ranges, dims per ball, dist from center to one side
  double *weights;                // total weight in each ball 
  
  BallTree::index *left_child,  *right_child;  // left, right children; no parent indices
  BallTree::index *lowest_leaf, *highest_leaf; // lower & upper leaf indices for each ball
  BallTree::index *permutation;                // point's position in the original data

  BallTree::index next;                        // internal var for placing the non-leaf nodes 

  static const char *FIELD_NAMES[];            // list of matlab structure fields
  static const int nfields;

  // for building the ball tree
  void buildBall(BallTree::index firstLeaf, BallTree::index lastLeaf, BallTree::index root);
  BallTree::index most_spread_coord(BallTree::index, BallTree::index) const;
  BallTree::index partition(unsigned int dim, BallTree::index low, BallTree::index high);
  virtual void swap(BallTree::index, BallTree::index);         // leaf-swapping function

  void select(unsigned int dimension, index position, 
		       index low, index high);

  double minDist(index, const double*) const;
  double maxDist(index, const double*) const;

  // build the non-leaf nodes from the leaves
  void buildTree();
};

#endif
