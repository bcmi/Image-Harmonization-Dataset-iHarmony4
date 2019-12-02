
#ifndef __match_hh__
#define __match_hh__

class Matrix;

// returns the cost of the assignment
double matchEdgeMaps (
    const Matrix& bmap1, const Matrix& bmap2,
    double maxDist, double outlierCost,
    Matrix& match1, Matrix& match2);

#endif // __match_hh__
