
#include <stdlib.h>
#include <assert.h>
#include <string.h>
#include <math.h>
#include <algorithm>
#include "Random.hh"
#include "Matrix.hh"
#include "Exception.hh"
#include "String.hh"

#if NEXTPOW2
#include <ieee754.h>
#endif // NEXTPOW2

// TODO: 
// - File I/O
// - Visualization
// - Matrix manipulation:
//   - horzcat vertcat blkdiag
// - Data functions:
//   - mean median std var
//   - randperm rsort csort
//   - diff gradient del2
//   - corrcoef cov
//   - cumsum cumprod
//   - hist histc
// - Matrix functions (using LAPACK/BLAS):
//   - norm rank det trace null orth rref subspace
//   - mldivide mrdivide inverse rcond cond chol lu qr lsqnonneg pinv 
//   - eig svd gsvd eigs svds poly
//   - expm logm sqrtm

#ifndef NOBLAS
extern "C" void dgemm_( // C := alpha*op(A)*op(B) + beta*C
    char* transa, char* transb, 
    int* m, int* n, int* k, 
    double* alpha, double* a, int* lda, 
    double* b, int* ldb, 
    double* beta, double* c, int* ldc);
#endif

// nan, inf
static const u_int64_t _qnan = 0x7ff7ffffffffffffll;
static const u_int64_t _snan = 0x7fffffffffffffffll;
static const u_int64_t _inf  = 0x7ff0000000000000ll;
static const double qnan = *(double*)&_qnan;
static const double snan = *(double*)&_snan;
static const double inf = *(double*)&_inf;

// trunc 
//static inline double trunc (double x) { 
//    return (x > 0) ? floor(x) : ceil(x); 
//}

// trigonometric functions
static inline double sec (double x) { return cos(1.0/x); }
static inline double sech (double x) { return cosh(1.0/x); }
static inline double asec (double x) { return acos(1.0/x); }
static inline double asech (double x) { return acosh(1.0/x); }
static inline double csc (double x) { return sin(1.0/x); }
static inline double csch (double x) { return sinh(1.0/x); }
static inline double acsc (double x) { return asin(1.0/x); }
static inline double acsch (double x) { return asinh(1.0/x); }
static inline double cot (double x) { return tan(1.0/x); }
static inline double coth (double x) { return tanh(1.0/x); }
static inline double acot (double x) { return atan(1.0/x); }
static inline double acoth (double x) { return atanh(1.0/x); }

// exponential functions
//static inline double log2 (double x) { return log(x) / log(2); }
static inline double pow2 (double x) { return pow(2,x); }

// matlab-style remainder / modulus functions
static inline double rem (double x, double y) { 
    return (y==0) ? qnan : (x - y*trunc(x/y)); 
}
static inline double mod (double x, double y) { 
    return (y==0) ? x : (x - y*floor(x/y)); 
}

#if NEXTPOW2
// return smallest integer i s.t. 2^i > abs(x)
static inline double nextpow2 (double x) {
    if (!finite(x)) { return x; }
    ieee754_double val;
    val.d = x;
    int e = (int)val.ieee.exponent - IEEE754_DOUBLE_BIAS;
    if (val.ieee.mantissa0 != 0) { return e+1; }
    if (val.ieee.mantissa1 != 0) { return e+2; } 
    return e;
}
#endif // NEXTPOW2

Matrix 
zeros (int rows, int cols) 
{ 
    return Matrix(rows,cols,Matrix::zeros); 
}

Matrix 
ones (int rows, int cols) 
{ 
    return Matrix(rows,cols,Matrix::ones); 
}

Matrix 
eye (int rows, int cols) 
{ 
    return Matrix(rows,cols,Matrix::eye); 
}

Matrix 
rand (int rows, int cols) 
{ 
    return Matrix(rows,cols,Matrix::rand); 
}

Matrix 
randn (int rows, int cols) 
{ 
    return Matrix(rows,cols,Matrix::randn); 
}


Matrix 
zeros (int sz) 
{ 
    return Matrix(sz,sz,Matrix::zeros); 
}

Matrix 
ones (int sz) 
{ 
    return Matrix(sz,sz,Matrix::ones); 
}

Matrix 
eye (int sz) 
{ 
    return Matrix(sz,sz,Matrix::eye); 
}

Matrix 
rand (int sz) 
{ 
    return Matrix(sz,sz,Matrix::rand); 
}

Matrix 
randn (int sz) 
{ 
    return Matrix(sz,sz,Matrix::randn); 
}


Matrix::Matrix () 
{
    _alloc(0,0,undef);
}

Matrix::Matrix (int sz, FillType type) 
{
    sz = std::max(0,sz);
    _alloc(sz,sz,type);
}

Matrix::Matrix (int rows, int cols, FillType type) 
{
    rows = std::max(0,rows);
    cols = std::max(0,cols);
    _alloc(rows,cols,type);
}

Matrix::Matrix (const Matrix& that) 
{
    _alloc(that._rows,that._cols,undef);
    *this = that;
}

Matrix::Matrix (int rows, int cols, double* data) 
{
    _rows = std::max(0,rows);
    _cols = std::max(0,cols);
    _data = data;
    _wrapped = true;
}

Matrix::~Matrix () 
{
    _delete();
}

void 
Matrix::reshape (int rows, int cols) 
{
    rows = std::max(0,rows);
    cols = std::max(0,cols);
    if (rows*cols != _n) {
        throw Exception (String (
            "Reshape cannot change number of elements: (%d,%d) vs. (%d,%d).",
            rows, cols, _rows, _cols));
    }
    _rows = rows;
    _cols = cols;
}

Matrix 
reshape (const Matrix& a, int rows, int cols)
{
    Matrix z(a);
    z.reshape(rows,cols);
    return z;
}

void 
Matrix::resize (int rows, int cols, FillType type)
{
    rows = std::max(0,rows);
    cols = std::max(0,cols);
    _delete();
    _alloc(rows,cols,type);
}

// array properties
bool 
Matrix::isvec () const 
{ 
    return (_rows == 1 || _cols == 1); 
}

bool 
Matrix::isrowvec () const 
{ 
    return (_rows == 1); 
}

bool 
Matrix::iscolvec () const 
{ 
    return (_cols == 1); 
}

bool 
Matrix::isempty () const 
{ 
    return (_n == 0); 
}

bool 
Matrix::isscalar () const 
{ 
    return (_n == 1); 
}

int 
Matrix::nrows () const 
{ 
    return _rows; 
}

int 
Matrix::ncols () const 
{ 
    return _cols; 
}

int 
Matrix::numel () const 
{ 
    return _n; 
}

int 
Matrix::length () const 
{ 
    return (_n==0) ? 0 : std::max(_rows,_cols);
}

Matrix
Matrix::size () const 
{ 
    Matrix a (1,2);
    a(0) = _rows;
    a(1) = _cols;
    return a;
}

bool 
Matrix::samesize (const Matrix& a) const
{
    return issize(a._rows,a._cols);
}

bool 
samesize (const Matrix& a, const Matrix& b)
{
    return a.samesize(b);
}

bool 
isvec (const Matrix& a)
{
    return a.isvec();
}

bool 
isrowvec (const Matrix& a)
{
    return a.isrowvec();
}

bool 
iscolvec (const Matrix& a)
{
    return a.iscolvec();
}

bool 
isempty (const Matrix& a)
{
    return a.isempty();
}

bool 
isscalar (const Matrix& a)
{
    return a.isscalar();
}

bool 
issize (const Matrix& a, int rows, int cols)
{
    return a.issize(rows,cols);
}

int 
nrows (const Matrix& a)
{
    return a.nrows();
}

int 
ncols (const Matrix& a)
{
    return a.ncols();
}

int 
numel (const Matrix& a)
{
    return a.numel();
}

int 
length (const Matrix& a)
{
    return a.length();
}

Matrix
size (const Matrix& a)
{
    return a.size();
}

bool 
Matrix::issize (int rows, int cols) const 
{
    return (_rows == rows && _cols == cols);
}

void ind2sub (
    const Matrix& siz, const Matrix& ind, Matrix& i, Matrix& j)
{
    if (siz.numel() != 2) {
        throw Exception ("ind2sub: siz must have 2 elements.");
    }
    const int rows = (int) siz(0);
    i = zeros(ind._rows,ind._cols);
    j = zeros(ind._rows,ind._cols);
    for (int index = 0; index < ind._n; index++) {
        const int indi = (int) ind._data[index];
        i._data[index] = indi % rows;
        j._data[index] = indi / rows;
    }
}

void sub2ind (
    const Matrix& siz, const Matrix& i, const Matrix& j, Matrix& ind)
{
    if (siz.numel() != 2) {
        throw Exception ("sub2ind: siz must have 2 elements.");
    }
    if (!samesize(i,j)) {
        throw Exception ("sub2ind: i and j just be the same size.");
    }
    const int rows = (int) siz(0);
    ind = zeros(i._rows,i._cols);
    for (int index = 0; index < ind._n; index++) {
        const int ii = (int) i._data[index];
        const int ji = (int) i._data[index];
        ind._data[index] = ji*rows + ii;
    }
}

void 
Matrix::ind2sub (const Matrix& ind, Matrix& i, Matrix& j)
{
    return ::ind2sub(::size(*this),ind,i,j);
}

void 
Matrix::sub2ind (const Matrix& i, const Matrix& j, Matrix& ind)
{
    return ::sub2ind(::size(*this),i,j,ind);
}

bool 
Matrix::iswrapped () const
{
    return _wrapped;
}

bool
iswrapped (const Matrix &a)
{
    return a.iswrapped();
}

double* 
Matrix::data () 
{
    return _data; 
}

double& 
Matrix::operator() (int index) 
{
    if ((unsigned)index >= (unsigned)_n) {
        throw Exception (String (
            "Index (%d) exceeds matrix length (%d).",
            index, _n));
    }
    return _data[index];
}

const double& 
Matrix::operator() (int index) const 
{
    if ((unsigned)index >= (unsigned)_n) {
        throw Exception (String (
            "Index (%d) exceeds matrix dimension (%d).",
            index, _n));
    }
    return _data[index];
}

double&  
Matrix::operator() (int row, int col) 
{
    if ((unsigned)row >= (unsigned)_rows 
        || (unsigned)col >= (unsigned)_cols) {
        throw Exception (String (
            "Index (%d,%d) exceeds matrix dimensions (%d,%d).",
            row, col, _rows, _cols));
    }
    int index = col*_rows + row;
    return _data[index];
}

const double& 
Matrix::operator() (int row, int col) const 
{
    if ((unsigned)row >= (unsigned)_rows 
        || (unsigned)col >= (unsigned)_cols) {
        throw Exception (String (
            "Index (%d,%d) exceeds matrix dimensions (%d,%d).",
            row, col, _rows, _cols));
    }
    int index = col*_rows + row;
    return _data[index];
}

void 
Matrix::operator= (const double& val) 
{
    if (val == 0) {
        memset(_data, 0, _n*sizeof(*_data));
    } else {
        for (int i = 0; i < _n; i++) {
            _data[i] = val;
        }
    }
}

void 
Matrix::operator= (const Matrix& that) 
{
    if (_n == that._n) {
        _rows = that._rows;
        _cols = that._cols;
        memcpy (_data, that._data, _n*sizeof(*_data));
    } else {
        _delete();
        _alloc(that._rows,that._cols,undef);
        *this = that;
    }
}

bool 
Matrix::isequal (const Matrix& a) const
{
    if (_rows != a._rows) { return false; }
    if (_cols != a._cols) { return false; }
    for (int i = 0; i < _n; i++) {
        if (_data[i] != a._data[i]) { return false; }
    }
    return true;
}

bool 
isequal (const Matrix& a, const Matrix& b)
{
    return a.isequal(b);
}

void 
Matrix::linspace (double a, double b)
{
    if (_n == 0) { return; }
    if (_n == 1) {
        _data[0] = b;
    } else {
        double skip = (b-a) / (_n-1);
        for (int i = 0; i < _n; i++) {
            _data[i] = a + i*skip;
        }
    }
}

void 
Matrix::logspace (double a, double b)
{
    if (_n == 0) { return; }
    if (b == M_PI) { b = ::log10(b); }
    if (_n == 1) {
        _data[0] = ::pow(10,b);
    } else {
        double skip = (b-a) / (_n-1);
        for (int i = 0; i < _n; i++) {
            _data[i] = ::pow (10, a + i*skip);
        }
    }
}

Matrix 
linspace (double a, double b, int n)
{
    n = std::max(1,n);
    Matrix z(n,1,Matrix::undef);
    z.linspace(a,b);
    return z;
}

Matrix logspace (double a, double b, int n)
{
    n = std::max(1,n);
    Matrix z(n,1,Matrix::undef);
    z.logspace(a,b);
    return z;
}

void 
Matrix::transpose () 
{
    if (isvec()) { 
        reshape(_cols,_rows);
        return; 
    }
    if (_rows == _cols) {
        for (int row = 0; row < _rows; row++) {
            for (int col = row+1; col < _cols; col++) {
                int index1 = col*_rows + row;
                int index2 = row*_rows + col;
                std::swap(_data[index1],_data[index2]);
            }
        }
    } else {
        Matrix m (_cols, _rows, Matrix::undef);
        for (int col=0, index=0; col < _cols; col++) {
            for (int row=0; row < _rows; row++, index++) {
                m(col,row) = _data[index];
            }
        }
        reshape(_cols,_rows);
        *this = m;
    }
}

// flip columns
void 
Matrix::fliplr () 
{
    for (int col=0; col < _cols/2; col++) {
        const int col2 = _cols - 1 - col;
        for (int row=0; row < _rows; row++) {
            std::swap((*this)(row,col),(*this)(row,col2));
        }
    }
}

// flip rows
void  
Matrix::flipud () 
{
    for (int row=0; row < _rows/2; row++) {
        const int row2 = _rows - 1 - row;
        for (int col=0; col < _cols; col++) {
            std::swap((*this)(row,col),(*this)(row2,col));
        }
    }
}

// rotate matrix
void  
Matrix::rot90 (int k) 
{
    int n = k % 4;
    if (n < 0) { n += 4; };
    switch (n) {
        case 0: break;
        case 1: transpose(); flipud(); break;
        case 2: flipud(); fliplr(); break;
        case 3: flipud(); transpose(); break;
        default: assert(0);
    }
}

Matrix 
transpose (const Matrix& a)
{
    Matrix z (a);
    z.transpose();
    return z;
}

// could be faster
Matrix 
fliplr (const Matrix& a)
{
    Matrix z (a);
    z.fliplr();
    return z;
}

// could be faster
Matrix 
flipud (const Matrix& a)
{
    Matrix z (a);
    z.flipud();
    return z;
}

// could be faster
Matrix 
rot90 (const Matrix& a, int k)
{
    Matrix z (a);
    z.rot90(k);
    return z;
}

Matrix 
Matrix::repmat (int m, int n) const
{
    m = std::max(0,m);
    n = std::max(0,n);
    Matrix a (_rows*m, _cols*n, Matrix::undef);
    // copy this matrix m times into a
    double* p = a._data;
    for (int col = 0; col < _cols; col++) {
        for (int i = 0; i < m; i++) {
            const double* q = &(*this)(0,col);
            memcpy (p, q, _rows*sizeof(*_data));
            p += _rows;
        }
    }
    // copy the block we just wrote n-1 times
    const int count = _cols * _rows * m;
    for (int j = 1; j < n; j++) {
        memcpy (p, a._data, count*sizeof(*_data));
        p += count;
    }
    return a;
}

Matrix 
repmat (const Matrix& a, int m, int n)
{
    return a.repmat(m,n);
}

// find indices of non-zero elements
Matrix  
Matrix::find () const
{
    // count non-zeros
    int count = 0;
    for (int i=0; i < _n; i++) {
        if (_data[i] != 0) { 
            count++;
        }
    }
    // allocate column vector
    Matrix m (count,1,Matrix::undef);
    // extract indices
    for (int i=0, j=0; i < _n; i++) {
        if (_data[i] != 0) { 
            assert (j < count);
            m._data[j++] = i;
        }
    }
    return m;
}

Matrix 
find (const Matrix& a)
{
    return a.find();
}

Matrix 
Matrix::operator() (const Matrix& indices) const
{
    return gather(indices);
}

Matrix  
Matrix::gather (const Matrix& indices) const
{
    Matrix m (indices._rows,indices._cols,Matrix::undef);
    for (int i = 0; i < indices._n; i++) {
        const int index = (int) indices._data[i];
        if ((unsigned)index >= (unsigned)_n) {
            throw Exception (String (
                "Matrix::gather: index %d exceeds matrix "
                "dimension (%d).", index, _n));
        }
        m._data[i] = _data[index];
    }
    return m;
}

void
Matrix::scatter (const Matrix& indices, const Matrix& values)
{
    if (indices._n != values._n) {
        throw Exception (String (
            "Matrix::scatter: indices and values not the same "
            "length (%d and %d).", indices._n, values._n));
    }
    for (int i = 0; i < indices._n; i++) {
        const int index = (int) indices._data[i];
        if ((unsigned)index >= (unsigned)_n) {
            throw Exception (String (
                "Matrix::scatter: index %d exceeds matrix "
                "dimension (%d).", index, _n));
        }
        _data[index] = values._data[i];
    }
}

void
Matrix::scatter (const Matrix& indices, double value)
{
    for (int i = 0; i < indices._n; i++) {
        const int index = (int) indices._data[i];
        if ((unsigned)index >= (unsigned)_n) {
            throw Exception (String (
                "Matrix::scatter: index %d exceeds matrix "
                "dimension (%d).", index, _n));
        }
        _data[index] = value;
    }
}

Matrix 
scatter (const Matrix& a, const Matrix& indices, const Matrix& values)
{
    Matrix z(a);
    z.scatter(indices,values);
    return z;
} 

Matrix 
scatter (const Matrix& a, const Matrix& indices, double value)
{
    Matrix z(a);
    z.scatter(indices,value);
    return z;
} 

Matrix 
Matrix::operator() (int r1, int r2, int c1, int c2) const
{
    if (r1 < 0 || r1 >= _rows || r2 < 0 || r2 >= _rows 
        || c1 < 0 || c1 >= _cols || c2 < 0 || c2 >= _cols) {
        throw Exception (String (
            "Matrix extract (%d:%d,%d:%d) exceeds matrix dimensions (%d,%d).",
            r1, r2, c1, c2, _rows, _cols));
    }

    int rows = (r1<=r2) ? r2-r1+1 : 0;
    int cols = (c1<=c2) ? c2-c1+1 : 0;
    Matrix m (rows,cols);
    for (int col = 0; col < cols; col++) {
        double* to = &m(0,col);
        const double* from = &(*this)(r1,c1+col);
        memcpy (to, from, rows*sizeof(*_data));
    }
    return m;
}

void 
Matrix::insert (const Matrix& m, int r1, int r2, int c1, int c2)
{
    if (r1 < 0 || r1 >= _rows || r2 < 0 || r2 >= _rows 
        || c1 < 0 || c1 >= _cols || c2 < 0 || c2 >= _cols) {
        throw Exception (String (
            "Matrix insert (%d:%d,%d:%d) exceeds matrix dimensions (%d,%d).",
            r1, r2, c1, c2, _rows, _cols));
    }

    int rows = (r1<=r2) ? r2-r1+1 : 0;
    int cols = (c1<=c2) ? c2-c1+1 : 0;
    for (int col = 0; col < cols; col++) {
        double* to = &(*this)(r1,c1+col);
        const double* from = &m(0,col);
        memcpy (to, from, rows*sizeof(*_data));
    }
}

// not as efficient as possible, but not too bad
Matrix 
insert (const Matrix& a, const Matrix& m, 
        int r1, int r2, int c1, int c2)
{
    Matrix z(a);
    z.insert(m,r1,r2,c1,c2);
    return z;
}

// mask out upper triangle
void  
Matrix::tril (int k) 
{
    for (int col=0, index=0; col<_cols; col++) {
        for (int row=0; row<_rows; row++, index++) {
            if (col-row > k) { 
                _data[index] = 0;
            }
        }
    }
}

// mask out lower triangle
void  
Matrix::triu (int k) 
{
    for (int col=0, index=0; col<_cols; col++) {
        for (int row=0; row<_rows; row++, index++) {
            if (col-row < k) { 
                _data[index] = 0;
            }
        }
    }
}

Matrix 
tril (const Matrix& a, int k)
{
    Matrix z(a);
    z.tril(k);
    return z;
}

Matrix 
triu (const Matrix& a, int k)
{
    Matrix z(a);
    z.triu(k);
    return z;
}

// set diagonal from scalar
void  
Matrix::setdiag (double val, int k) 
{
    const int row = (k<0)*::abs(k);
    const int col = (k>0)*::abs(k);
    const int len = std::min(_rows-row,_cols-col);
    for (int i = 0; i < len; i++) {
        (*this)(row+i,col+i) = val;
    }
}

// set diagonal from vector
void  
Matrix::setdiag (const Matrix& d, int k) 
{
    const int row = (k<0)*::abs(k);
    const int col = (k>0)*::abs(k);
    const int len = std::max(0,std::min(_rows-row,_cols-col));
    if (d.numel() != len) {
        throw Exception (String (
            "Matrix::diag(): diagonal %d of matrix is length %d, "
            "but the diagonal vector is length %d.",
            k, len, d.numel()));
    }
    for (int i = 0; i < len; i++) {
        (*this)(row+i,col+i) = d(i);
    }
}

// get diagonal
Matrix  
Matrix::getdiag (int k) const 
{
    const int row = (k<0)*::abs(k);
    const int col = (k>0)*::abs(k);
    const int len = std::min(_rows-row,_cols-col);
    Matrix d (len,1);
    for (int i = 0; i < len; i++) {
        d(i) = (*this)(row+i,col+i);
    }
    return d;
}

Matrix 
diag (const Matrix& a, int k)
{
    if (a.isvec()) {
        // create diagonal matrix
        const int n = a._n + ::abs(k);
        Matrix z(n,n,Matrix::zeros);
        const int row = (k>0)*::abs(k);
        const int col = (k<0)*::abs(k);
        for (int i = 0; i < a._n; i++) {
            z(row+i,col+i) = a(i);
        }
        return z;
    } else {
        // extract diagonal
        return a.getdiag(k);
    }
}

// or reduction
bool 
Matrix::any () const
{
    for (int i = 0; i < _n; i++) {
        if (_data[i] != 0) { return true; }
    }
    return false;
}

// and reduction
bool 
Matrix::all () const
{
    for (int i = 0; i < _n; i++) {
        if (_data[i] == 0) { return false; }
    }
    return true;
}

// sum reduction
double  
Matrix::sum () const 
{
    double x = 0;
    for (int i = 0; i < _n; i++) {
        x += _data[i];
    }
    return x;
}

// row sums
Matrix  
Matrix::rsum () const 
{
    Matrix m (_rows,1,zeros);
    for (int col=0, index=0; col < _cols; col++) {
        for (int row=0; row < _rows; row++, index++) {
            m._data[row] += _data[index];
        }
    }
    return m;
}

// column sums
Matrix  
Matrix::csum () const 
{
    Matrix m (1,_cols,zeros);
    for (int col=0, index=0; col < _cols; col++) {
        for (int row=0; row < _rows; row++, index++) {
            m._data[col] += _data[index];
        }
    }
    return m;
}
 
// product reduction
double  
Matrix::prod () const 
{
    double x = 1;
    for (int i = 0; i < _n; i++) {
        x *= _data[i];
    }
    return x;
}

// row products
Matrix  
Matrix::rprod () const 
{
    Matrix m (_rows,1,ones);
    for (int col=0, index=0; col < _cols; col++) {
        for (int row=0; row < _rows; row++, index++) {
            m._data[row] *= _data[index];
        }
    }
    return m;
}

// column products
Matrix  
Matrix::cprod () const 
{
    Matrix m (1,_cols,ones);
    for (int col=0, index=0; col < _cols; col++) {
        for (int row=0; row < _rows; row++, index++) {
            m._data[col] *= _data[index];
        }
    }
    return m;
}
 
bool any (const Matrix& a) { return a.any(); }
bool all (const Matrix& a) { return a.all(); }
double sum (const Matrix& a) { return a.sum(); }
Matrix rsum (const Matrix& a) { return a.rsum(); }
Matrix csum (const Matrix& a) { return a.csum(); }
double prod (const Matrix& a) { return a.prod(); }
Matrix rprod (const Matrix& a) { return a.rprod(); }
Matrix cprod (const Matrix& a) { return a.cprod(); }

double  
Matrix::min () const 
{
    if (_n == 0) { 
        throw Exception ("Matrix::min(): empty matrix");
    }
    double x = _data[0];
    for (int i = 1; i < _n; i++) {
        x = std::min(x,_data[i]);
    }
    return x;
}

double  
Matrix::min (int& index) const 
{
    if (_n == 0) { 
        throw Exception ("Matrix::min(): empty matrix");
    }
    double x = _data[0];
    int ind = 0;
    for (int i = 1; i < _n; i++) {
        if (_data[i] < x) {
            x = _data[i];
            ind = i;
        }
    }
    index = ind;
    return x;
}

Matrix  
Matrix::rmin () const 
{
    if (_n == 0) { 
        throw Exception ("Matrix::rmin(): empty matrix");
    }
    Matrix m (_rows,1,undef);
    memcpy(m._data,_data,_rows*(sizeof(*_data)));
    for (int col=0, index=0; col < _cols; col++) {
        for (int row=0; row < _rows; row++, index++) {
            m._data[row] = std::min(m._data[row],_data[index]);
        }
    }
    return m;
}

Matrix  
Matrix::rmin (Matrix& indices) const 
{
    if (_n == 0) { 
        throw Exception ("Matrix::rmin(): empty matrix");
    }
    Matrix m (_rows,1,undef);
    indices = ::zeros(_rows,1);
    memcpy(m._data,_data,_rows*(sizeof(*_data)));
    for (int col=0, index=0; col < _cols; col++) {
        for (int row=0; row < _rows; row++, index++) {
            if (_data[index] < m._data[row]) {
                m._data[row] = _data[index];
                indices._data[row] = col;
            }
        }
    }
    return m;
}

Matrix  
Matrix::cmin () const 
{
    if (_n == 0) { 
        throw Exception ("Matrix::cmin(): empty matrix");
    }
    Matrix m (1,_cols,undef);
    for (int col=0; col < _cols; col++) {
        m._data[col] = (*this)(0,col);
    }
    for (int col=0, index=0; col < _cols; col++) {
        for (int row=0; row < _rows; row++, index++) {
            m._data[col] = std::min(m._data[col],_data[index]);
        }
    }
    return m;
}

Matrix  
Matrix::cmin (Matrix& indices) const 
{
    if (_n == 0) { 
        throw Exception ("Matrix::cmin(): empty matrix");
    }
    Matrix m (1,_cols,undef);
    indices = ::zeros(1,_cols);
    for (int col=0; col < _cols; col++) {
        m._data[col] = (*this)(0,col);
    }
    for (int col=0, index=0; col < _cols; col++) {
        for (int row=0; row < _rows; row++, index++) {
            if (_data[index] < m._data[row]) {
                m._data[row] = _data[index];
                indices._data[row] = col;
            }
        }
    }
    return m;
}

double  
Matrix::max () const 
{
    if (_n == 0) { 
        throw Exception ("Matrix::max(): empty matrix");
    }
    double x = _data[0];
    for (int i = 1; i < _n; i++) {
        x = std::max(x,_data[i]);
    }
    return x;
}

double  
Matrix::max (int& index) const 
{
    if (_n == 0) { 
        throw Exception ("Matrix::max(): empty matrix");
    }
    double x = _data[0];
    int ind = 0;
    for (int i = 1; i < _n; i++) {
        if (_data[i] > x) {
            x = _data[i];
            ind = i;
        }
    }
    index = ind;
    return x;
}

Matrix  
Matrix::rmax () const 
{
    if (_n == 0) { 
        throw Exception ("Matrix::rmax(): empty matrix");
    }
    Matrix m (_rows,1,undef);
    memcpy(m._data,_data,_rows*(sizeof(*_data)));
    for (int col=0, index=0; col < _cols; col++) {
        for (int row=0; row < _rows; row++, index++) {
            m._data[row] = std::max(m._data[row],_data[index]);
        }
    }
    return m;
}

Matrix  
Matrix::rmax (Matrix& indices) const 
{
    if (_n == 0) { 
        throw Exception ("Matrix::rmax(): empty matrix");
    }
    Matrix m (_rows,1,undef);
    indices = ::zeros(_rows,1);
    memcpy(m._data,_data,_rows*(sizeof(*_data)));
    for (int col=0, index=0; col < _cols; col++) {
        for (int row=0; row < _rows; row++, index++) {
            if (_data[index] > m._data[row]) {
                m._data[row] = _data[index];
                indices._data[row] = col;
            }
        }
    }
    return m;
}

Matrix  
Matrix::cmax () const 
{
    if (_n == 0) { 
        throw Exception ("Matrix::cmax(): empty matrix");
    }
    Matrix m (1,_cols,undef);
    for (int col=0; col < _cols; col++) {
        m._data[col] = (*this)(0,col);
    }
    for (int col=0, index=0; col < _cols; col++) {
        for (int row=0; row < _rows; row++, index++) {
            m._data[col] = std::max(m._data[col],_data[index]);
        }
    }
    return m;
}

Matrix  
Matrix::cmax (Matrix& indices) const 
{
    if (_n == 0) { 
        throw Exception ("Matrix::cmax(): empty matrix");
    }
    Matrix m (1,_cols,undef);
    indices = ::zeros(1,_cols);
    for (int col=0; col < _cols; col++) {
        m._data[col] = (*this)(0,col);
    }
    for (int col=0, index=0; col < _cols; col++) {
        for (int row=0; row < _rows; row++, index++) {
            if (_data[index] > m._data[row]) {
                m._data[row] = _data[index];
                indices._data[row] = col;
            }
        }
    }
    return m;
}

double min (const Matrix& a) { return a.min(); }
double min (const Matrix& a, int& index) { return a.min(index); }
Matrix rmin (const Matrix& a) { return a.rmin(); }
Matrix rmin (const Matrix& a, Matrix& indices) { return a.rmin(indices); }
Matrix cmin (const Matrix& a) { return a.cmin(); }
Matrix cmin (const Matrix& a, Matrix& indices) { return a.cmin(indices); }
double max (const Matrix& a) { return a.max(); }
double max (const Matrix& a, int& index) { return a.max(index); }
Matrix rmax (const Matrix& a) { return a.rmax(); }
Matrix rmax (const Matrix& a, Matrix& indices) { return a.rmax(indices); }
Matrix cmax (const Matrix& a) { return a.cmax(); }
Matrix cmax (const Matrix& a, Matrix& indices) { return a.cmax(indices); }

Matrix min (const Matrix& a, const Matrix& b) {
    if (a._rows != b._rows || a._cols != b._cols) {
        throw Exception (String (
            "Matrix size mismatch in binary operation 'min': "
            "(%d,%d) vs. (%d,%d).",
            a._rows, a._cols, b._rows, b._cols));
    }
    Matrix c (a._rows, a._cols, Matrix::undef);
    for (int i = 0; i < a._n; i++) {
        c._data[i] = std::min(a._data[i],b._data[i]);
    }
    return c;
}
Matrix min (const Matrix& a, double b) {
    Matrix c (a._rows, a._cols, Matrix::undef);
    for (int i = 0; i < a._n; i++) {
        c._data[i] = std::min(a._data[i],b);
    }
    return c;
}
Matrix min (double a, const Matrix& b) {
    Matrix c (b._rows, b._cols, Matrix::undef);
    for (int i = 0; i < b._n; i++) {
        c._data[i] = std::min(a,b._data[i]);
    }
    return c;
}

Matrix max (const Matrix& a, const Matrix& b) {
    if (a._rows != b._rows || a._cols != b._cols) {
        throw Exception (String (
            "Matrix size mismatch in binary operation 'max': "
            "(%d,%d) vs. (%d,%d).",
            a._rows, a._cols, b._rows, b._cols));
    }
    Matrix c (a._rows, a._cols, Matrix::undef);
    for (int i = 0; i < a._n; i++) {
        c._data[i] = std::max(a._data[i],b._data[i]);
    }
    return c;
}
Matrix max (const Matrix& a, double b) {
    Matrix c (a._rows, a._cols, Matrix::undef);
    for (int i = 0; i < a._n; i++) {
        c._data[i] = std::max(a._data[i],b);
    }
    return c;
}
Matrix max (double a, const Matrix& b) {
    Matrix c (b._rows, b._cols, Matrix::undef);
    for (int i = 0; i < b._n; i++) {
        c._data[i] = std::max(a,b._data[i]);
    }
    return c;
}

void 
Matrix::ceil () 
{
    for (int i = 0; i < _n; i++) {
        _data[i] = ::ceil(_data[i]);
    }
}

void 
Matrix::floor () 
{
    for (int i = 0; i < _n; i++) {
        _data[i] = ::floor(_data[i]);
    }
}

void 
Matrix::round () 
{
    for (int i = 0; i < _n; i++) {
        _data[i] = ::rint(_data[i]);
    }
}

void 
Matrix::fix () 
{
    for (int i = 0; i < _n; i++) {
        _data[i] = ::trunc(_data[i]);
    }
}

Matrix 
ceil (const Matrix& a)
{
    Matrix z (a._rows, a._cols, Matrix::undef);
    for (int i = 0; i < a._n; i++) {
        z._data[i] = ::ceil(a._data[i]);
    }
    return z;
}

Matrix 
floor (const Matrix& a)
{
    Matrix z (a._rows, a._cols, Matrix::undef);
    for (int i = 0; i < a._n; i++) {
        z._data[i] = ::floor(a._data[i]);
    }
    return z;
}

Matrix 
round (const Matrix& a)
{
    Matrix z (a._rows, a._cols, Matrix::undef);
    for (int i = 0; i < a._n; i++) {
        z._data[i] = ::rint(a._data[i]);
    }
    return z;
}

Matrix 
fix (const Matrix& a)
{
    Matrix z (a._rows, a._cols, Matrix::undef);
    for (int i = 0; i < a._n; i++) {
        z._data[i] = ::trunc(a._data[i]);
    }
    return z;
}

Matrix 
iznan (const Matrix& a)
{
    Matrix b (a._rows, a._cols, Matrix::undef);
    for (int i = 0; i < a._n; i++) {
        b._data[i] = isnan(a._data[i]);
    }
    return b;
}

Matrix 
izinf (const Matrix& a)
{
    Matrix b (a._rows, a._cols, Matrix::undef);
    for (int i = 0; i < a._n; i++) {
        b._data[i] = isinf(a._data[i]);
    }
    return b;
}

Matrix 
izfinite (const Matrix& a)
{
    Matrix b (a._rows, a._cols, Matrix::undef);
    for (int i = 0; i < a._n; i++) {
        b._data[i] = ::finite(a._data[i]);
    }
    return b;
}

void 
Matrix::iznan ()
{
    for (int i = 0; i < _n; i++) {
        _data[i] = isnan(_data[i]);
    }
}

void 
Matrix::izinf ()
{
    for (int i = 0; i < _n; i++) {
        _data[i] = isinf(_data[i]);
    }
}

void 
Matrix::izfinite ()
{
    for (int i = 0; i < _n; i++) {
        _data[i] = ::finite(_data[i]);
    }
}


void 
Matrix::abs () 
{
    for (int i = 0; i < _n; i++) {
        _data[i] = ::fabs(_data[i]);
    }
}

void 
Matrix::sign () 
{
    for (int i = 0; i < _n; i++) {
        const double x = _data[i];
        _data[i] = (x == 0) ? 0 : (x > 0 ? 1 : -1);
    }
}

Matrix  
abs (const Matrix& a)
{
    Matrix z (a._rows, a._cols, Matrix::undef);
    for (int i = 0; i < a._n; i++) {
        z._data[i] = ::fabs(a._data[i]);
    }
    return z;
}

Matrix  
sign (const Matrix& a)
{
    Matrix z (a._rows, a._cols, Matrix::undef);
    for (int i = 0; i < a._n; i++) {
        const double x = a._data[i];
        z._data[i] = (x == 0) ? 0 : (x > 0 ? 1 : -1);
    }
    return z;
}

void 
Matrix::exp () 
{
    for (int i = 0; i < _n; i++) {
        _data[i] = ::exp(_data[i]);
    }
}

void 
Matrix::log () 
{
    for (int i = 0; i < _n; i++) {
        _data[i] = ::log(_data[i]);
    }
}

void 
Matrix::log10 () 
{
    for (int i = 0; i < _n; i++) {
        _data[i] = ::log10(_data[i]);
    }
}

void 
Matrix::log2 () 
{
    for (int i = 0; i < _n; i++) {
        _data[i] = ::log2(_data[i]);
    }
}

void 
Matrix::pow2 () 
{
    for (int i = 0; i < _n; i++) {
        _data[i] = ::pow2(_data[i]);
    }
}

void 
Matrix::sqrt () 
{
    for (int i = 0; i < _n; i++) {
        _data[i] = ::sqrt(_data[i]);
    }
}

#if NEXTPOW2
void 
Matrix::nextpow2 () 
{
    for (int i = 0; i < _n; i++) {
        _data[i] = ::nextpow2(_data[i]);
    }
}
#endif // NEXTPOW2

Matrix 
exp (const Matrix& a)
{
    Matrix z (a._rows, a._cols, Matrix::undef);
    for (int i = 0; i < a._n; i++) {
        z._data[i] = ::exp(a._data[i]);
    }
    return z;
}

Matrix 
log (const Matrix& a)
{
    Matrix z (a._rows, a._cols, Matrix::undef);
    for (int i = 0; i < a._n; i++) {
        z._data[i] = ::log(a._data[i]);
    }
    return z;
}

Matrix 
log10 (const Matrix& a)
{
    Matrix z (a._rows, a._cols, Matrix::undef);
    for (int i = 0; i < a._n; i++) {
        z._data[i] = ::log10(a._data[i]);
    }
    return z;
}

Matrix 
log2 (const Matrix& a)
{
    Matrix z (a._rows, a._cols, Matrix::undef);
    for (int i = 0; i < a._n; i++) {
        z._data[i] = ::log2(a._data[i]);
    }
    return z;
}

Matrix 
pow2 (const Matrix& a)
{
    Matrix z (a._rows, a._cols, Matrix::undef);
    for (int i = 0; i < a._n; i++) {
        z._data[i] = ::pow2(a._data[i]);
    }
    return z;
}

Matrix 
sqrt (const Matrix& a)
{
    Matrix z (a._rows, a._cols, Matrix::undef);
    for (int i = 0; i < a._n; i++) {
        z._data[i] = ::sqrt(a._data[i]);
    }
    return z;
}

#if NEXTPOW2
Matrix 
nextpow2 (const Matrix& a)
{
    Matrix z (a._rows, a._cols, Matrix::undef);
    for (int i = 0; i < a._n; i++) {
        z._data[i] = ::nextpow2(a._data[i]);
    }
    return z;
}
#endif // NEXTPOW2

void Matrix::sin ()
{
    for (int i = 0; i < _n; i++) {
        _data[i] = ::sin(_data[i]);
    }
}

void Matrix::sinh ()
{
    for (int i = 0; i < _n; i++) {
        _data[i] = ::sinh(_data[i]);
    }
}

void Matrix::asin ()
{
    for (int i = 0; i < _n; i++) {
        _data[i] = ::asin(_data[i]);
    }
}

void Matrix::asinh ()
{
    for (int i = 0; i < _n; i++) {
        _data[i] = ::asinh(_data[i]);
    }
}

void Matrix::cos ()
{
    for (int i = 0; i < _n; i++) {
        _data[i] = ::cos(_data[i]);
    }
}

void Matrix::cosh ()
{
    for (int i = 0; i < _n; i++) {
        _data[i] = ::cosh(_data[i]);
    }
}

void Matrix::acos ()
{
    for (int i = 0; i < _n; i++) {
        _data[i] = ::acos(_data[i]);
    }
}

void Matrix::acosh ()
{
    for (int i = 0; i < _n; i++) {
        _data[i] = ::acosh(_data[i]);
    }
}

void Matrix::tan ()
{
    for (int i = 0; i < _n; i++) {
        _data[i] = ::tan(_data[i]);
    }
}

void Matrix::tanh ()
{
    for (int i = 0; i < _n; i++) {
        _data[i] = ::tanh(_data[i]);
    }
}

void Matrix::atan ()
{
    for (int i = 0; i < _n; i++) {
        _data[i] = ::atan(_data[i]);
    }
}

void Matrix::atanh ()
{
    for (int i = 0; i < _n; i++) {
        _data[i] = ::atanh(_data[i]);
    }
}

void Matrix::sec ()
{
    for (int i = 0; i < _n; i++) {
        _data[i] = ::sec(_data[i]);
    }
}

void Matrix::sech ()
{
    for (int i = 0; i < _n; i++) {
        _data[i] = ::sech(_data[i]);
    }
}

void Matrix::asec ()
{
    for (int i = 0; i < _n; i++) {
        _data[i] = ::asec(_data[i]);
    }
}

void Matrix::asech ()
{
    for (int i = 0; i < _n; i++) {
        _data[i] = ::asech(_data[i]);
    }
}

void Matrix::csc ()
{
    for (int i = 0; i < _n; i++) {
        _data[i] = ::csc(_data[i]);
    }
}

void Matrix::csch ()
{
    for (int i = 0; i < _n; i++) {
        _data[i] = ::csch(_data[i]);
    }
}

void Matrix::acsc ()
{
    for (int i = 0; i < _n; i++) {
        _data[i] = ::acsc(_data[i]);
    }
}

void Matrix::acsch ()
{
    for (int i = 0; i < _n; i++) {
        _data[i] = ::acsch(_data[i]);
    }
}

void Matrix::cot ()
{
    for (int i = 0; i < _n; i++) {
        _data[i] = ::cot(_data[i]);
    }
}

void Matrix::coth ()
{
    for (int i = 0; i < _n; i++) {
        _data[i] = ::coth(_data[i]);
    }
}

void Matrix::acot ()
{
    for (int i = 0; i < _n; i++) {
        _data[i] = ::acot(_data[i]);
    }
}

void Matrix::acoth ()
{
    for (int i = 0; i < _n; i++) {
        _data[i] = ::acoth(_data[i]);
    }
}

Matrix 
sin (const Matrix& a)
{
    Matrix z (a._rows, a._cols);
    for (int i = 0; i < a._n; i++) {
        z._data[i] = ::sin(a._data[i]);
    }
    return z;
}

Matrix 
sinh (const Matrix& a)
{
    Matrix z (a._rows, a._cols);
    for (int i = 0; i < a._n; i++) {
        z._data[i] = ::sinh(a._data[i]);
    }
    return z;
}

Matrix 
asin (const Matrix& a)
{
    Matrix z (a._rows, a._cols);
    for (int i = 0; i < a._n; i++) {
        z._data[i] = ::asin(a._data[i]);
    }
    return z;
}

Matrix 
asinh (const Matrix& a)
{
    Matrix z (a._rows, a._cols);
    for (int i = 0; i < a._n; i++) {
        z._data[i] = ::asinh(a._data[i]);
    }
    return z;
}

Matrix 
cos (const Matrix& a)
{
    Matrix z (a._rows, a._cols);
    for (int i = 0; i < a._n; i++) {
        z._data[i] = ::cos(a._data[i]);
    }
    return z;
}

Matrix 
cosh (const Matrix& a)
{
    Matrix z (a._rows, a._cols);
    for (int i = 0; i < a._n; i++) {
        z._data[i] = ::cosh(a._data[i]);
    }
    return z;
}

Matrix 
acos (const Matrix& a)
{
    Matrix z (a._rows, a._cols);
    for (int i = 0; i < a._n; i++) {
        z._data[i] = ::acos(a._data[i]);
    }
    return z;
}

Matrix 
acosh (const Matrix& a)
{
    Matrix z (a._rows, a._cols);
    for (int i = 0; i < a._n; i++) {
        z._data[i] = ::acosh(a._data[i]);
    }
    return z;
}

Matrix 
tan (const Matrix& a)
{
    Matrix z (a._rows, a._cols);
    for (int i = 0; i < a._n; i++) {
        z._data[i] = ::tan(a._data[i]);
    }
    return z;
}

Matrix 
tanh (const Matrix& a)
{
    Matrix z (a._rows, a._cols);
    for (int i = 0; i < a._n; i++) {
        z._data[i] = ::tanh(a._data[i]);
    }
    return z;
}

Matrix 
atan (const Matrix& a)
{
    Matrix z (a._rows, a._cols);
    for (int i = 0; i < a._n; i++) {
        z._data[i] = ::atan(a._data[i]);
    }
    return z;
}

Matrix 
atanh (const Matrix& a)
{
    Matrix z (a._rows, a._cols);
    for (int i = 0; i < a._n; i++) {
        z._data[i] = ::atanh(a._data[i]);
    }
    return z;
}

Matrix 
sec (const Matrix& a)
{
    Matrix z (a._rows, a._cols);
    for (int i = 0; i < a._n; i++) {
        z._data[i] = ::sec(a._data[i]);
    }
    return z;
}

Matrix 
sech (const Matrix& a)
{
    Matrix z (a._rows, a._cols);
    for (int i = 0; i < a._n; i++) {
        z._data[i] = ::sech(a._data[i]);
    }
    return z;
}

Matrix 
asec (const Matrix& a)
{
    Matrix z (a._rows, a._cols);
    for (int i = 0; i < a._n; i++) {
        z._data[i] = ::asec(a._data[i]);
    }
    return z;
}

Matrix 
asech (const Matrix& a)
{
    Matrix z (a._rows, a._cols);
    for (int i = 0; i < a._n; i++) {
        z._data[i] = ::asech(a._data[i]);
    }
    return z;
}

Matrix 
csc (const Matrix& a)
{
    Matrix z (a._rows, a._cols);
    for (int i = 0; i < a._n; i++) {
        z._data[i] = ::csc(a._data[i]);
    }
    return z;
}

Matrix 
csch (const Matrix& a)
{
    Matrix z (a._rows, a._cols);
    for (int i = 0; i < a._n; i++) {
        z._data[i] = ::csch(a._data[i]);
    }
    return z;
}

Matrix 
acsc (const Matrix& a)
{
    Matrix z (a._rows, a._cols);
    for (int i = 0; i < a._n; i++) {
        z._data[i] = ::acsc(a._data[i]);
    }
    return z;
}

Matrix 
acsch (const Matrix& a)
{
    Matrix z (a._rows, a._cols);
    for (int i = 0; i < a._n; i++) {
        z._data[i] = ::acsch(a._data[i]);
    }
    return z;
}

Matrix 
cot (const Matrix& a)
{
    Matrix z (a._rows, a._cols);
    for (int i = 0; i < a._n; i++) {
        z._data[i] = ::cot(a._data[i]);
    }
    return z;
}

Matrix 
coth (const Matrix& a)
{
    Matrix z (a._rows, a._cols);
    for (int i = 0; i < a._n; i++) {
        z._data[i] = ::coth(a._data[i]);
    }
    return z;
}

Matrix 
acot (const Matrix& a)
{
    Matrix z (a._rows, a._cols);
    for (int i = 0; i < a._n; i++) {
        z._data[i] = ::acot(a._data[i]);
    }
    return z;
}

Matrix 
acoth (const Matrix& a)
{
    Matrix z (a._rows, a._cols);
    for (int i = 0; i < a._n; i++) {
        z._data[i] = ::acoth(a._data[i]);
    }
    return z;
}

// computed assignment
#define DEFOP(OP) \
    Matrix& Matrix::operator OP (const double& val) { \
        for (int i = 0; i < _n; i++) { \
            _data[i] OP val; \
        } \
	return *this; \
    } \
    Matrix& Matrix::operator OP (const Matrix& that) { \
	if (_rows != _rows || _cols != that._cols) { \
            throw Exception (String ( \
                "Matrix size mismatch in operation '%s': " \
		"(%d,%d) vs. (%d,%d).", \
                __STRING(OP), _rows, _cols, that._rows, that._cols)); \
	} \
        for (int i = 0; i < _n; i++) { \
            _data[i] OP that._data[i]; \
        } \
	return *this; \
    }
DEFOP(+=);
DEFOP(-=);
DEFOP(*=);
DEFOP(/=);
#undef DEFOP

Matrix& Matrix::operator^= (const double& val) {
    for (int i = 0; i < _n; i++) {
        _data[i] = ::pow(_data[i],val);
    }
    return *this;
}
Matrix& Matrix::operator^= (const Matrix& that) {
    if (_rows != _rows || _cols != that._cols) {
        throw Exception (String (
            "Matrix size mismatch in operation '^=': "
            "(%d,%d) vs. (%d,%d).",
            _rows, _cols, that._rows, that._cols));
    }
    for (int i = 0; i < _n; i++) {
        _data[i] = ::pow(_data[i],that._data[i]);
    }
    return *this;
}

// binary operators
#define DEFOP(OP) \
    Matrix operator OP (const Matrix& a, const Matrix& b) { \
	if (a._rows != b._rows || a._cols != b._cols) { \
            throw Exception (String ( \
                "Matrix size mismatch in binary operation '%s': " \
		"(%d,%d) vs. (%d,%d).", \
                __STRING(OP), a._rows, a._cols, b._rows, b._cols)); \
	} \
        Matrix c (a._rows, a._cols, Matrix::undef); \
        for (int i = 0; i < a._n; i++) { \
            c._data[i] = a._data[i] OP b._data[i]; \
        } \
        return c; \
    } \
    Matrix operator OP (const Matrix& a, double b) { \
        Matrix c (a._rows, a._cols, Matrix::undef); \
        for (int i = 0; i < a._n; i++) { \
            c._data[i] = a._data[i] OP b; \
        } \
        return c; \
    } \
    Matrix operator OP (double a, const Matrix& b) { \
        Matrix c (b._rows, b._cols, Matrix::undef); \
        for (int i = 0; i < b._n; i++) { \
            c._data[i] = a OP b._data[i]; \
        } \
        return c; \
    }
DEFOP(+);
DEFOP(-);
DEFOP(*);
DEFOP(/);
DEFOP(<);
DEFOP(>);
DEFOP(==);
DEFOP(!=);
DEFOP(<=);
DEFOP(>=);
DEFOP(&&);
DEFOP(||);
#undef DEFOP

Matrix operator^ (const Matrix& a, const Matrix& b) {
    if (a._rows != b._rows || a._cols != b._cols) {
        throw Exception (String (
            "Matrix size mismatch in binary operation '^': "
            "(%d,%d) vs. (%d,%d).",
            a._rows, a._cols, b._rows, b._cols));
    }
    Matrix c (a._rows, a._cols, Matrix::undef);
    for (int i = 0; i < a._n; i++) {
        c._data[i] = ::pow(a._data[i],b._data[i]);
    }
    return c;
}
Matrix operator^ (const Matrix& a, double b) {
    Matrix c (a._rows, a._cols, Matrix::undef);
    for (int i = 0; i < a._n; i++) {
        c._data[i] = ::pow(a._data[i],b);
    }
    return c;
}
Matrix operator^ (double a, const Matrix& b) {
    Matrix c (b._rows, b._cols, Matrix::undef);
    for (int i = 0; i < b._n; i++) {
        c._data[i] = ::pow(a,b._data[i]);
    }
    return c;
}

// unary operators
#define DEFOP(OP) \
    Matrix operator OP (const Matrix& a) { \
        Matrix c (a._rows, a._cols, Matrix::undef); \
        for (int i = 0; i < a._n; i++) { \
            c._data[i] = OP a._data[i]; \
        } \
        return c; \
    } 
DEFOP(!);
#undef DEFOP

// misc binary functions
#define DEFOP(OP,FUNC) \
    Matrix OP (const Matrix& a, const Matrix& b) { \
	if (a._rows != b._rows || a._cols != b._cols) { \
            throw Exception (String ( \
                "Matrix size mismatch in %s: (%d,%d) vs. (%d,%d).", \
                __STRING(OP), a._rows, a._cols, b._rows, b._cols)); \
	} \
        Matrix c (a._rows, a._cols, Matrix::undef); \
        for (int i = 0; i < a._n; i++) { \
            c._data[i] = FUNC (a._data[i], b._data[i]); \
        } \
        return c; \
    } \
    Matrix OP (const Matrix& a, double b) { \
        Matrix c (a._rows, a._cols, Matrix::undef); \
        for (int i = 0; i < a._n; i++) { \
            c._data[i] = FUNC (a._data[i], b); \
        } \
        return c; \
    } \
    Matrix OP (double a, const Matrix& b) { \
        Matrix c (b._rows, b._cols, Matrix::undef); \
        for (int i = 0; i < b._n; i++) { \
            c._data[i] = FUNC (a, b._data[i]); \
        } \
        return c; \
    }
DEFOP(rem,::rem);
DEFOP(mod,::mod);
DEFOP(atan2,::atan2);
#undef DEFOP

Matrix mtimes (const Matrix& a, const Matrix& b)
{
    if (a.isscalar()) { return a(0)*b; }
    if (b.isscalar()) { return a*b(0); }
    if (a._cols != b._rows) {
        throw Exception (String (
            "Matrix::mtimes: inner dimensions (%d,%d)x(%d,%d) "
            "don't match.", a._rows, a._cols, b._rows, b._cols));
                         
    }

    Matrix c (a._rows, b._cols, Matrix::zeros);

#ifndef NOBLAS

    char transa='n', transb='n';
    int m=a._rows, n=b._cols, k=b._rows;
    int lda=m, ldb=k, ldc=m;
    double alpha=1, beta=0;
    dgemm_ (&transa, &transb, &m, &n, &k, &alpha, 
            a._data, &lda, b._data, &ldb, &beta, c._data, &ldc);

#else // NOBLAS

    for (int i = 0; i < c._rows; i++) {
        for (int j = 0; j < c._cols; j++) {
            for (int k = 0; k < a._cols; k++) {
                c(i,j) += a(i,k) * b(k,j);
            }
        }
    }

#endif // NOBLAS

    return c;
} 

void 
Matrix::_alloc (int rows, int cols, FillType type) 
{
    assert (rows >= 0);
    assert (cols >= 0);
    _rows = rows;
    _cols = cols;
    _n = rows*cols;
    _wrapped = false;
    switch (type) {
        case undef:
            _data = (double*) malloc (_n * sizeof(*_data));
            break;
        case zeros:
            _data = (double*) calloc (_n, sizeof(*_data));
            break;
        case ones:
            _data = (double*) malloc (_n * sizeof(*_data));
            *this = 1;
            break;
        case eye: {
            _data = (double*) calloc (_n, sizeof(*_data));
            const int mindim = std::min(_rows,_cols);
            for (int i = 0; i < mindim; i++) {
                int index = i*_rows + i;
                _data[index] = 1;
            }
            break;
        }
        case rand:
            _data = (double*) malloc (_n * sizeof(*_data));
            for (int i = 0; i < _n; i++) {
                _data[i] = Random::rand.fp();
            }
            break;
        case randn:
            _data = (double*) malloc (_n * sizeof(*_data));
            for (int i = 0; i < _n; i++) {
                const double x = Random::rand.fp();
                _data[i] = ::sqrt(-::log(x));
                if (Random::rand.fp() > 0.5) {
                    _data[i] = -_data[i];
                }
            }
            break;
        default:
            assert(0);
    }
}

void 
Matrix::_delete () 
{
    assert (_data != NULL);
    if (!_wrapped) { free(_data); }
    _zero();
}

void 
Matrix::_zero () 
{
    _rows = _cols = _n = 0;
    _data = NULL;
    _wrapped = false;
}

