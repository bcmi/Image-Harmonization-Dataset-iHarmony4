
#include <math.h>
#include <assert.h>
#include <iostream>
#include "Exception.hh"
#include "Matrix.hh"
#include "Timer.hh"

using std::ostream;
using std::cerr;
using std::endl;

// tests for Matrix class

// g++ -g -Wall -o test test.cc build/ix86_linux/libutil.a -lm

ostream& operator<< (ostream& os, const Matrix& a) {
    for (int i = 0; i < a.nrows(); i++) {
        for (int j = 0; j < a.ncols(); j++) {
            os.width(10);
            os.precision(5);
            //os.setf(0,std::ios::floatfield);
            os << a(i,j);
            os << " ";
        }
        os << endl;
    }
    return os;
}

int 
main ()
{
    try {

    { // find
        Matrix a(5,5,Matrix::rand);
        Matrix b = a(find(a>0.5));
        assert (all(b>0.5));
    }
    { // constructors and properties
        assert (all(zeros(5)==zeros(5,5)));
        assert (all(ones(5)==ones(5,5)));
        assert (all(eye(5)==eye(5,5)));
        Matrix a (4,5);
        assert (nrows(a)==4);
        assert (ncols(a)==5);
        assert (numel(a)==20);
        assert (issize(a,4,5));
        assert (!isvec(a));
        assert (!isrowvec(a));
        assert (!iscolvec(a));
        assert (!isempty(a));
        assert (!isscalar(a));
        Matrix b (4,1);
        assert (isvec(b));
        assert (iscolvec(b));
        assert (!isrowvec(b));
        Matrix c (1,4);
        assert (isvec(c));
        assert (!iscolvec(c));
        assert (isrowvec(c));
        Matrix d (0,3);
        assert (nrows(d)==0);
        assert (ncols(d)==3);
        assert (isempty(d));
        assert (!isvec(d));
        assert (!isscalar(d));
        Matrix e (1,1);
        assert (isscalar(e));
        assert (isvec(e));
        assert (isrowvec(e));
        assert (iscolvec(e));
        Matrix f (4,4,Matrix::zeros);
        assert (all(f==0.0));
        assert (sum(f)==0);
        Matrix g (4,4,Matrix::ones);
        assert (all(g==1.0));
        assert (sum(g)==nrows(g)*ncols(g));
        Matrix h (4,4,Matrix::eye);
        assert (numel(find(h==1.0)) == nrows(h));
        assert (sum(h) == nrows(h));
        assert (all(diag(h)));
        Matrix i (100,100,Matrix::rand);
        assert (all(i>=0.0) && all(i<=1.0));
        Matrix j (100,100,Matrix::randn);
        assert (fabs(sum(j)/numel(j)) < 0.05);
        Matrix k;
        assert (numel(k)==0);
        assert (isempty(k));
        Matrix l(j);
        assert (all(l==j));
        assert (all((l-j)==0.0));
        Matrix m(k);
        assert (all(m==k));
        {
            double* p = new double [16];
            {
                Matrix n(4,4,p); 
                assert (n.iswrapped());
                assert (iswrapped(n));
            }
            delete[] p;
        }
        Matrix o(-1,3);
        assert (!iswrapped(o));
        assert (nrows(o)==0);
        assert (ncols(o)==3);
        assert (isempty(o));
        Matrix p(3,-1);
        assert (nrows(p)==3);
        assert (ncols(p)==0);
        assert (isempty(p));
    }
    { // reshape
        Matrix a (1,12,Matrix::rand);
        Matrix b = reshape(a,2,6);
        Matrix c = reshape(b,3,4);
        Matrix d = reshape(c,6,2);
        Matrix e = reshape(d,12,1);
        try {
            assert (all(a==e));
            assert (0);
        } catch (Exception e) {}
        assert (all(transpose(a)==e));
    }
    { // element access
        Matrix a (3,3);
        a(0,0) = 1; a(0,1) = 2; a(0,2) = 3;
        a(1,0) = 4; a(1,1) = 5; a(1,2) = 6;
        a(2,0) = 7; a(2,1) = 8; a(2,2) = 9;
        a.transpose();
        for (int i = 0; i < numel(a); i++) {
            assert (a(i)==i+1);
        }
        try { a(-1u,1); assert(0); } catch (Exception e) {}
        try { a(1,-1u); assert(0); } catch (Exception e) {}
        try { a(1,4); assert(0); } catch (Exception e) {}
        try { a(4,1); assert(0); } catch (Exception e) {}
    }
    { // submatrix 
        Matrix a (10,10,Matrix::rand);
        Matrix b (10,10);
        assert (!all(b==a));
        b.insert(a(0,4,0,4),0,4,0,4);
        assert (!all(b==a));
        b.insert(a(5,9,0,4),5,9,0,4);
        assert (!all(b==a));
        b = insert(b,a(0,4,5,9),0,4,5,9);
        assert (!all(b==a));
        b = insert(b,a(5,9,5,9),5,9,5,9);
        assert (all(b==a));
    }
    { // assignment
        Matrix a = rand(5,5);
        a = 3;
        assert (sum(a) == numel(a)*3);
        Matrix b = rand(5,5);
        assert (any(b!=a));
        b = a;
        assert (all(b==a));
    }
    { // filling
        Matrix a = linspace(-5,5,123);
        assert (isvec(a));
        assert (numel(a)==123);
        Matrix b = linspace(5,-5,123);
        assert (all(a==flipud(b)));
        Matrix c = a+b;
        assert (c(0)==0);
        assert (!any(c));
        Matrix d = logspace(1,3,15);
        assert (d(0)==10);
        assert (d(14)==1000);
        Matrix e = logspace(3,1,15);
        assert (all(abs(d-flipud(e))<1e-12));
        Matrix f = logspace(2,M_PI,15);
        assert (f(0)==100);
        assert (f(14)==M_PI);
        Matrix g = logspace(0,M_PI,15);
        assert (g(0)==1);
        assert (g(14)==M_PI);
    }
    { // element shuffling
        Matrix a (100,100,Matrix::rand);
        assert (!all(a==transpose(a)));
        Matrix b (100,100,Matrix::eye);
        assert (all(b==transpose(b)));
        Matrix c = a + transpose(a);
        assert (all(c==transpose(c)));
        Matrix d (12,19);
        assert (all(d==transpose(transpose(d))));
        assert (all(d==fliplr(fliplr(d))));
        assert (all(d==flipud(flipud(d))));
        assert (all(d==rot90(d,0)));
        assert (all(transpose(d)==fliplr(rot90(d,-1))));
        for (int i = 0; i < 10; i++) {
            assert (all(d==rot90(rot90(d,i),-i)));
        }
    }
    { // repmat
        Matrix a (10,5,Matrix::rand);
        Matrix b = repmat(a,2,2);
        assert (all(a==b(0,9,0,4)));
        assert (all(a==b(10,19,0,4)));
        assert (all(a==b(0,9,5,9)));
        assert (all(a==b(10,19,5,9)));
    }
    { // find
        Matrix a(5,5,Matrix::rand);
        Matrix b = a(find(a>0.5));
        assert (all(b>0.5));
    }
    { // gather/scatter
        Matrix a(5,5,Matrix::rand);
        Matrix b(5,5);
        b.scatter(find(a>0.5),a(find(a>0.5)));
        b = scatter(b,find(a<=0.5),a(find(a<=0.5)));
        assert (all(a==b));
        Matrix c = scatter(a,find(a>0.3&&a<0.7),-1);
        assert (all(c(find(a>0.3&&a<0.7))==-1));
        assert (all(c(find(a<=0.3))!=-1));
        assert (all(c(find(a>=0.7))!=-1));
    }
    { // masking
        Matrix a(5,5,Matrix::rand);
        for (int i = -10; i <= 10; i++) {
            assert (all( a == tril(a,i) + triu(a,i+1)) );
        }
        Matrix b(6,4,Matrix::rand);
        for (int i = -10; i <= 10; i++) {
            assert (all(b == tril(b,i) + triu(b,i+1)));
        }
        Matrix c(4,6,Matrix::rand);
        for (int i = -10; i <= 10; i++) {
            assert (all( c == tril(c,i) + triu(c,i+1)) );
        }
    }
    { // diagonal
        Matrix a(5,5);
        for (int i = -10; i <= 10; i++) { a.setdiag(i,i); }
        Matrix b(5,5);
        for (int i = -10; i <= 10; i++) { b.setdiag(Matrix(5-abs(i),1)+i,i); }
        assert (all(a==b));
        for (int i = -10; i <= 10; i++) { 
            assert (all( b.getdiag(i) == i+Matrix(5-abs(i),1)) );
            assert (all( diag(b,i) == i+Matrix(5-abs(i),1)) );
        }
        Matrix c (10,10,Matrix::eye);
        for (int i = -20; i <= 20; i++) {
            if (i == 0) { assert (all( diag(c) == ones(10,1)) ); }
            if (i != 0) { assert (all( diag(c,i) == zeros(10-abs(i),1)) ); }
        }
    }
    { // reductions
        Matrix a (5,5,Matrix::rand);
        assert (all(a==a));
        assert (any(a==a));
        assert (!any(a-a));
        assert (!all(a-a));
        Matrix b = ones(5,5)*2;
        assert (sum(b) == 2*numel(b));
        assert (all( rsum(b) == 2*ones(5,1)*5) );
        assert (all( csum(b) == 2*ones(1,5)*5) );
        assert (prod(b) == pow(2,numel(b)));
        assert (all( rprod(b) == ones(5,1)*pow(2,5)) );
        assert (all( cprod(b) == ones(1,5)*pow(2,5)) );
    }
    { // sign
        Matrix a = randn(50,50);
        Matrix b = abs(a);
        assert (all( b == a*((a<0)*-1) + a*(a>0)) );
        Matrix c = sign(a);
        assert (all( c == -1*(a<0) + (a>0)) );
        assert (all( abs(a) == a*sign(a)) );
    }
    { // rounding
        Matrix a = randn(50,50);
        a = ceil(a);
        a = floor(a);
        a = round(a);
        a = fix(a);
    }
    { // exponentials
        Matrix a = randn(50,50);
        a = exp (a);
        a = log (a);
        a = log10 (a);
        a = log2 (a);
        a = pow2 (a);
        a = sqrt (a);
        a = nextpow2 (a);
        Matrix b = rand(5,5) * 100;
        Matrix c = nextpow2(b);
        assert (all( 2^c > b ));
        assert (all( 2^(c-1) < b ));
    }
    { // trigonometric functions
        Matrix a = 10*randn(50,50);
        Matrix b = a;
        b = sin (a);
        b = sinh (a);
        b = asin (a);
        b = asinh (a);
        b = cos (a);
        b = cosh (a);
        b = acos (a);
        b = acosh (a);
        b = tan (a);
        b = tanh (a);
        b = atan (a);
        b = atanh (a);
        b = sec (a);
        b = sech (a);
        b = asec (a);
        b = asech (a);
        b = csc (a);
        b = csch (a);
        b = acsc (a);
        b = acsch (a);
        b = cot (a);
        b = coth (a);
        b = acot (a);
        b = acoth (a);
    }
    { // computed assignment
        Matrix a = 10*randn(50,50);
        a += a;
        a -= a;
        a *= a;
        a /= a;
        a ^= a;
        a += 3.0;
        a -= 3.0;
        a *= 3.0;
        a /= 3.0;
        a ^= 3.0;
    }
    { // binary operators
        Matrix a = 10*randn(50,50);
        Matrix b = a;
        b = 5.0 + ((a + a) + 5.0);
        b = 5.0 - ((a - a) - 5.0);
        b = 5.0 * ((a * a) * 5.0);
        b = 5.0 / ((a / a) / 5.0);
        b = 5.0 ^ ((a ^ a) ^ 5.0);
        b = 5.0 < ((a < a) < 5.0);
        b = 5.0 > ((a > a) > 5.0);
        b = 5.0 == ((a == a) == 5.0);
        b = 5.0 != ((a != a) != 5.0);
        b = 5.0 <= ((a <= a) <= 5.0);
        b = 5.0 >= ((a >= a) >= 5.0);
        b = 5.0 && ((a && a) && 5.0);
        b = 5.0 || ((a || a) || 5.0);
    }
    { // unary operators
        Matrix a = 10*randn(50,50);
        a = !a;
    }
    { // misc binary functions
        Matrix a = 10*randn(50,50);
        Matrix b = 10*randn(50,50);
        Matrix c = a;
        c = rem(a,b);
        c = rem(a,5.0);
        c = rem(5.0,a);
        c = mod(a,b);
        c = mod(a,5.0);
        c = mod(5.0,a);
        c = atan2(a,b);
        c = atan2(a,5.0);
        c = atan2(5.0,a);
    } 
    { // matrix multiplication
        {
            Matrix a = randn(1,1);
            Matrix b = randn(1,10);
            Matrix c = mtimes(a,b);
        }
        {
            Matrix a = randn(1,5);
            Matrix b = randn(5,10);
            Matrix c = mtimes(a,b);
        }
        {
            Matrix a = randn(10,5);
            Matrix b = randn(5,10);
            Matrix c = mtimes(a,b);
        }
        {
            Matrix a = randn(10,5);
            Matrix b = randn(5,1);
            Matrix c = mtimes(a,b);
        }
        {
            Matrix a = randn(10,1);
            Matrix b = randn(1,1);
            Matrix c = mtimes(a,b);
        }
        {
            Matrix a = randn(10,1);
            Matrix b = randn(1,10);
            Matrix c = mtimes(a,b);
            assert (issize(c,10,10));
        }
        {
            Matrix a = randn(1,10);
            Matrix b = randn(10,1);
            Matrix c = mtimes(a,b);
            assert (issize(c,1,1));
        }
        // timing tests
        {
            Timer t;
            int n = 1000;
            Matrix a = rand(n);
            t.start();
            Matrix b = mtimes(a,a);
            t.stop(); 
            float mflops = 2.0*n*n*n/t.cpu() * 1e-6;
            cerr << "matrix-matrix multiply: " << mflops << " MFLOPS" << endl;
        }
        {
            Timer t;
            int n = 2000;
            Matrix a = rand(n);
            Matrix v = rand(1,n);
            t.start();
            Matrix b = mtimes(v,a);
            t.stop(); 
            float mflops = 2.0*n*n/t.cpu() * 1e-6;
            cerr << "vector-matrix multiply: " << mflops << " MFLOPS" << endl;
        }
        {
            Timer t;
            int n = 2000;
            Matrix a = rand(n);
            Matrix v = rand(n,1);
            t.start();
            Matrix b = mtimes(a,v);
            t.stop(); 
            float mflops = 2.0*n*n/t.cpu() * 1e-6;
            cerr << "matrix-vector multiply: " << mflops << " MFLOPS" << endl;
        }
    }

    } catch (Exception e) {
        cerr << "ERROR: " << e << endl;
        return 1;
    }

    cerr << "All tests passed." << endl;
    return 0;
}

