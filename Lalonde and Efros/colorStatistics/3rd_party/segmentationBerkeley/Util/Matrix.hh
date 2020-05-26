
#ifndef __Matrix_hh__
#define __Matrix_hh__

// MATLAB style matrix class.
// Data storage is column-major.
// Uses LAPACK/BLAS for critical operations.

// If you use this to do matrix multiplication, then make sure you
// have a good BLAS.  I recommend using ATLAS.  You can download
// pre-built ATLAS libraries from http://www.netlib.org/atlas/.  You
// will need libf77blas.a and libatlas.a.

// Currently implements almost all of matlab/{elmat,elfun}.
// Should ultimately also implement much of matlab/{matfun,datafun}.

// Set to 1 or 0.  Controlls if the nextpow2 methods get defined,
// which depend on having the ieeefp.h header file.
#define NEXTPOW2 1

class Matrix 
{
public:

    // how to initialize a new matrix
    enum FillType {
        undef, zeros, ones, eye, rand, randn
    };

    // create special matrices
    friend Matrix zeros (int rows, int cols);
    friend Matrix ones (int rows, int cols);
    friend Matrix eye (int rows, int cols);
    friend Matrix rand (int rows, int cols);
    friend Matrix randn (int rows, int cols);
    friend Matrix zeros (int sz);
    friend Matrix ones (int sz);
    friend Matrix eye (int sz);
    friend Matrix rand (int sz);
    friend Matrix randn (int sz);

    // construct empty matrix
    Matrix ();

    // construct square matrix with specified fill
    Matrix (int sz, FillType type = zeros);

    // construct matrix with specified fill
    Matrix (int rows, int cols, FillType type = zeros);

    // copy constructor
    Matrix (const Matrix& that);

    // create a wrapped matrix 
    // (i.e. we're not responsible for freeing the data)
    Matrix (int rows, int cols, double* data);

    // destructor
    ~Matrix ();

    // reshape is only valid if the number of elements doesn't change
    void reshape (int rows, int cols);
    friend Matrix reshape (const Matrix& a, int rows, int cols);

    // resize a matrix
    void resize (int rows, int cols, FillType type = zeros);

    // matrix properties
    bool isvec () const;
    bool isrowvec () const;
    bool iscolvec () const;
    bool isempty () const;
    bool isscalar () const;
    bool issize (int rows, int cols) const;
    int nrows () const;
    int ncols () const;
    int numel () const;
    int length () const;
    Matrix size () const;
    bool samesize (const Matrix& a) const;
    friend bool isvec (const Matrix& a);
    friend bool isrowvec (const Matrix& a);
    friend bool iscolvec (const Matrix& a);
    friend bool isempty (const Matrix& a);
    friend bool isscalar (const Matrix& a);
    friend bool issize (const Matrix& a, int rows, int cols);
    friend int nrows (const Matrix& a);
    friend int ncols (const Matrix& a);
    friend int numel (const Matrix& a);
    friend int length (const Matrix& a);
    friend Matrix size (const Matrix& a);
    friend bool samesize (const Matrix& a, const Matrix& b);

    // TODO: catenation
    void horzcat (const Matrix& a);
    void vertcat (const Matrix& a);
    void blkdiag (const Matrix& a);
    friend Matrix horzcat (const Matrix& a, const Matrix& b);
    friend Matrix vertcat (const Matrix& a, const Matrix& b);
    friend Matrix blkdiag (const Matrix& a, const Matrix& b);

    // index/subscript conversion
    void ind2sub (const Matrix& ind, Matrix& i, Matrix& j);
    void sub2ind (const Matrix& i, const Matrix& j, Matrix& ind);
    friend void ind2sub (
        const Matrix& siz, const Matrix& ind, Matrix& i, Matrix& j);
    friend void sub2ind (
        const Matrix& siz, const Matrix& i, const Matrix& j, Matrix& ind);

    // access to raw data array
    bool iswrapped () const;
    friend bool iswrapped (const Matrix &a);
    double* data ();
    
    // 1D element access
    double& operator() (int index);
    const double& operator() (int index) const;

    // 2D element access
    double& operator() (int row, int col);
    const double& operator() (int row, int col) const;

    // sub-matrix access
    Matrix operator() (int r1, int r2, int c1, int c2) const;
    void insert (const Matrix& m, int r1, int r2, int c1, int c2);
    friend Matrix insert (const Matrix& a, const Matrix& m, 
                          int r1, int r2, int c1, int c2);

    // assignment
    void operator= (const double& val);
    void operator= (const Matrix& that);

    // eqality
    bool isequal (const Matrix& a) const;
    friend bool isequal (const Matrix& a, const Matrix& b);

    // filling
    void linspace (double a, double b);
    void logspace (double a, double b);
    friend Matrix linspace (double a, double b, int n);
    friend Matrix logspace (double a, double b, int n);

    // element shuffling
    void transpose ();		// transpose
    void fliplr ();		// swap columns
    void flipud ();		// swap rows
    void rot90 (int k = 1);	// rotate CC k*90 degrees
    friend Matrix transpose (const Matrix& a);
    friend Matrix fliplr (const Matrix& a);
    friend Matrix flipud (const Matrix& a);
    friend Matrix rot90 (const Matrix& a, int k = 1);

    // replication
    Matrix repmat (int m, int n) const;
    friend Matrix repmat (const Matrix& a, int m, int n);

    // find non-zeros 
    Matrix find () const;
    friend Matrix find (const Matrix& a);

    // gather/scatter
    Matrix operator() (const Matrix& indices) const; 
    Matrix gather (const Matrix& indices) const;
    void scatter (const Matrix& indices, const Matrix& values); 
    void scatter (const Matrix& indices, double value); 
    friend Matrix scatter (
        const Matrix& a, const Matrix& indices, const Matrix& values); 
    friend Matrix scatter (
        const Matrix& a, const Matrix& indices, double value); 

    // masking
    void tril (int k = 0);	// save lower triangle
    void triu (int k = 0);	// save upper triangle
    friend Matrix tril (const Matrix& a, int k = 0);
    friend Matrix triu (const Matrix& a, int k = 0);

    // diagonal
    Matrix getdiag (int k = 0) const;	   	// get vector
    void setdiag (double val, int k = 0);	// set from scalar
    void setdiag (const Matrix& d, int k = 0);	// set from vector
    // make a diagonal matrix if a is a vector
    // extract diagonal as column vector if a is a matrix
    friend Matrix diag (const Matrix& a, int k = 0); 

    // reductions
    bool any () const;		// logical-or reduction
    bool all () const;		// logical-and reduction
    double sum () const;	// sum reduction
    Matrix rsum () const;	// row sums
    Matrix csum () const;	// column sums
    double prod () const;	// product reduction
    Matrix rprod () const;	// row products
    Matrix cprod () const;	// column products
    friend bool any (const Matrix& a);
    friend bool all (const Matrix& a);
    friend double sum (const Matrix& a);
    friend Matrix rsum (const Matrix& a);
    friend Matrix csum (const Matrix& a);
    friend double prod (const Matrix& a);
    friend Matrix rprod (const Matrix& a);
    friend Matrix cprod (const Matrix& a);

    // min and max reductions
    double min () const;		// total min
    double min (int& index) const;	// total min with index
    Matrix rmin () const;		// row mins
    Matrix rmin (Matrix& indices) const;// row mins with indices
    Matrix cmin () const;		// column mins
    Matrix cmin (Matrix& indices) const;// column mins with indices
    double max () const;		// total max
    double max (int& index) const;	// total max with index
    Matrix rmax () const;		// row maxs
    Matrix rmax (Matrix& indices) const;// row maxs with indices
    Matrix cmax () const;		// column maxs
    Matrix cmax (Matrix& indices) const;// column maxs with indices
    friend double min (const Matrix& a);
    friend double min (const Matrix& a, int& index);
    friend Matrix rmin (const Matrix& a);
    friend Matrix rmin (const Matrix& a, Matrix& indices);
    friend Matrix cmin (const Matrix& a);
    friend Matrix cmin (const Matrix& a, Matrix& indices);
    friend double max (const Matrix& a);
    friend double max (const Matrix& a, int& index);
    friend Matrix rmax (const Matrix& a);
    friend Matrix rmax (const Matrix& a, Matrix& indices);
    friend Matrix cmax (const Matrix& a);
    friend Matrix cmax (const Matrix& a, Matrix& indices);

    // binary min and max
    friend Matrix min (const Matrix& a, const Matrix& b);
    friend Matrix min (const Matrix& a, double b);
    friend Matrix min (double a, const Matrix& b);
    friend Matrix max (const Matrix& a, const Matrix& b);
    friend Matrix max (const Matrix& a, double b);
    friend Matrix max (double a, const Matrix& b);

    // rounding
    void ceil ();	// round toward +inf
    void floor ();	// round toward -inf
    void round ();	// round to nearest
    void fix ();	// round towards zero
    friend Matrix ceil (const Matrix& a);
    friend Matrix floor (const Matrix& a);
    friend Matrix round (const Matrix& a);
    friend Matrix fix (const Matrix& a);

    // nan, inf
    void iznan ();
    void izinf ();
    void izfinite ();
    friend Matrix iznan (const Matrix& a);
    friend Matrix izinf (const Matrix& a);
    friend Matrix izfinite (const Matrix& a);

    // sign
    void abs ();	// absolute value
    void sign ();	// -1,0,1 for negative,zero,positive
    friend Matrix abs (const Matrix& a);
    friend Matrix sign (const Matrix& a);

    // exponentials (element-wise)
    void exp ();	// e^x
    void log ();	// natural log
    void log10 ();	// base 10 log
    void log2 ();	// base 2 log
    void pow2 ();	// 2^x
    void sqrt ();	// square root
#if NEXTPOW2
    void nextpow2 ();	// smallest i s.t. 2^i>x
#endif // NEXTPOW2
    friend Matrix exp (const Matrix& a);
    friend Matrix log (const Matrix& a);
    friend Matrix log10 (const Matrix& a);
    friend Matrix log2 (const Matrix& a);
    friend Matrix pow2 (const Matrix& a);
    friend Matrix sqrt (const Matrix& a);
#if NEXTPOW2
    friend Matrix nextpow2 (const Matrix& a);
#endif // NEXTPOW2

    // trigonometric functions
    void sin ();	// Sine.
    void sinh ();	// Hyperbolic sine.
    void asin ();	// Inverse sine.
    void asinh ();	// Inverse hyperbolic sine.
    void cos ();	// Cosine.
    void cosh ();	// Hyperbolic cosine.
    void acos ();	// Inverse cosine.
    void acosh ();	// Inverse hyperbolic cosine.
    void tan ();	// Tangent.
    void tanh ();	// Hyperbolic tangent.
    void atan ();	// Inverse tangent.
    void atanh ();	// Inverse hyperbolic tangent.
    void sec ();	// Secant.
    void sech ();	// Hyperbolic secant.
    void asec ();	// Inverse secant.
    void asech ();	// Inverse hyperbolic secant.
    void csc ();	// Cosecant.
    void csch ();	// Hyperbolic cosecant.
    void acsc ();	// Inverse cosecant.
    void acsch ();	// Inverse hyperbolic cosecant.
    void cot ();	// Cotangent.
    void coth ();	// Hyperbolic cotangent.
    void acot ();	// Inverse cotangent.
    void acoth ();	// Inverse hyperbolic cotangent.
    friend Matrix sin (const Matrix& a);
    friend Matrix sinh (const Matrix& a);
    friend Matrix asin (const Matrix& a);
    friend Matrix asinh (const Matrix& a);
    friend Matrix cos (const Matrix& a);
    friend Matrix cosh (const Matrix& a);
    friend Matrix acos (const Matrix& a);
    friend Matrix acosh (const Matrix& a);
    friend Matrix tan (const Matrix& a);
    friend Matrix tanh (const Matrix& a);
    friend Matrix atan (const Matrix& a);
    friend Matrix atanh (const Matrix& a);
    friend Matrix sec (const Matrix& a);
    friend Matrix sech (const Matrix& a);
    friend Matrix asec (const Matrix& a);
    friend Matrix asech (const Matrix& a);
    friend Matrix csc (const Matrix& a);
    friend Matrix csch (const Matrix& a);
    friend Matrix acsc (const Matrix& a);
    friend Matrix acsch (const Matrix& a);
    friend Matrix cot (const Matrix& a);
    friend Matrix coth (const Matrix& a);
    friend Matrix acot (const Matrix& a);
    friend Matrix acoth (const Matrix& a);

    // computed assignment (all element-wise)
#define DEFOP(OP) \
    Matrix& operator OP (const double& val); \
    Matrix& operator OP (const Matrix& that);
    DEFOP(+=);
    DEFOP(-=);
    DEFOP(*=);
    DEFOP(/=);
    DEFOP(^=);	// exponentiation, not xor
#undef DEFOP

    // binary operators (all element-wise)
#define DEFOP(OP) \
    friend Matrix operator OP (const Matrix& a, const Matrix& b); \
    friend Matrix operator OP (const Matrix& a, double b); \
    friend Matrix operator OP (double a, const Matrix& b);
    DEFOP(+);
    DEFOP(-);
    DEFOP(*);
    DEFOP(/);
    DEFOP(^);	// exponentiation, not xor
    DEFOP(<);
    DEFOP(>);
    DEFOP(==);
    DEFOP(!=);
    DEFOP(<=);
    DEFOP(>=);
    DEFOP(&&);
    DEFOP(||);
#undef DEFOP

    // unary operators
#define DEFOP(OP) \
    friend Matrix operator OP (const Matrix& a);
    DEFOP(!);
#undef DEFOP

    // misc binary functions
#define DEFOP(OP) \
    friend Matrix OP (const Matrix& a, const Matrix& b); \
    friend Matrix OP (const Matrix& a, double b); \
    friend Matrix OP (double a, const Matrix& b);
    DEFOP(rem);
    DEFOP(mod);
    DEFOP(atan2);
#undef DEFOP

    // matrix multiplication
    friend Matrix mtimes (const Matrix& a, const Matrix& b); 

protected:

    void _alloc (int rows, int cols, FillType type);
    void _delete ();
    void _zero ();

    int _rows, _cols, _n;
    double* _data;
    bool _wrapped;

}; // class Matrix

#endif // __Matrix_hh__
