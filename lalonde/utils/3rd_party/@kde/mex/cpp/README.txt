Very brief README on the BallTree and BallTreeDensity classes
=============================================================

Really, these should be called "KDTree" classes, since we use bounding boxes
rather than spheres (balls), but I've never changed the name.

A KD-Tree is a heirarchical data structure for storing point sets, which
caches statistics of subsets of the points to speed up computations.  We
are concerned with kernel density estimates, which have three components:
  locations (d-dimensional)
  bandwidths, assumed diagonal (d-dimensional)
  weights (1-dimensional)
At each level of the tree, we cache statistics of a set S
  The weighted mean of all points in S
  The total weight of all points in S
  A bounding box containing all points of S, described by
    its center and half-width (in each dimension)
  "Bandwidth" info:
     The variance of a Gaussian approximation to the kernels in S
     The min. and max. BW of any kernel in S (if non-uniform BWs)
   All points in S are stored contiguously, and thus can be described by
     a lower & upper index in the leaf nodes of the tree
   Because they are now spatially contiguous, there is a permutation to
     restore their original ordering, which is stored in the structure.
   The left & right child nodes, typically each containing about half the
     points in S.  For leaf nodes, "left" is a self-reference to the same
     node and "right" is NO_CHILD.

The code itself uses branch-and-bound style computations to perform approximate
  and exact operations more efficiently.
