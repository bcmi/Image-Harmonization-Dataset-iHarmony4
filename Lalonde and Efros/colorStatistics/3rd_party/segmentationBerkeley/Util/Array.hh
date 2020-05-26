
#ifndef __Array_hh__
#define __Array_hh__

// Arrays that reduce bugs by:
//  - Being allocatable on the stack, so destructors get called 
//    automatically.
//  - Doing bounds checking.
//  - Providing easy initialization.
//  - Encapsulating the address calculation.

// The arrays are allocated as single blocks so that all elements are
// contiguous in memory.  Latter indices change more quickly than
// former indices.  Clients can rely on this ordering.

// Copyright (C) 2003 David R. Martin <dmartin@eecs.berkeley.edu>
//
// This program is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public License as
// published by the Free Software Foundation; either version 2 of the
// License, or (at your option) any later version.
// 
// This program is distributed in the hope that it will be useful, but
// WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// General Public License for more details.
// 
// You should have received a copy of the GNU General Public License
// along with this program; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA
// 02111-1307, USA, or see http://www.gnu.org/copyleft/gpl.html.

#include <string.h>
#include <assert.h>

template <class Elem>
class Array1D 
{
public:

    Array1D () {
        _alloc(0);
    }
    Array1D (unsigned n) {
        _alloc(n);
    }
    ~Array1D () {
        _delete();
    }
    void resize (unsigned n) {
        if (!issize(n)) {
            _delete();
            _alloc(n);
        }
    }
    void init (const Elem& elem) {
        for (unsigned i = 0; i < _n; i++) {
            _array[i] = elem;
        }
    }
    bool issize (unsigned n) const {
        return (_n == n);
    }
    int size () const {
        return _n;
    }
    Elem* data () {
        return _array; 
    }
    Elem& operator() (unsigned i) {
        assert (i < _n);
        return _array[i];
    }
    const Elem& operator() (unsigned i) const {
        assert (i < _n);
        return _array[i];
    }

private:

    void _alloc (unsigned n) {
        _n = n;
        _array = new Elem [_n];
    }
    void _delete () {
        assert (_array != NULL);
        delete [] _array;
        _array = NULL;
    }

    unsigned _n;
    Elem* _array;

}; // class Array1D

template <class Elem>
class Array2D
{
public:

    Array2D () {
        _alloc(0,0);
    }
    Array2D (unsigned d0, unsigned d1) {
        _alloc(d0,d1);
    }
    ~Array2D () {
        _delete();
    }
    void resize (unsigned d0, unsigned d1) {
        if (!issize(d0,d1)) {
            _delete();
            _alloc(d0,d1);
        }
    }
    void init (const Elem& elem) {
        for (unsigned i = 0; i < _n; i++) {
            _array[i] = elem;
        }
    }
    bool issize (unsigned d0, unsigned d1) const {
        return (_dim[0] == d0 && _dim[1] == d1);
    }
    int size (unsigned d) const {
        assert (d < 2);
        return _dim[d];
    }
    Elem* data () { 
        return _array; 
    }
    Elem& operator() (unsigned i, unsigned j) {
        assert (i < _dim[0]);
        assert (j < _dim[1]);
        unsigned index = i * _dim[1] + j;
        assert (index < _n);
        return _array[index];
    }
    const Elem& operator() (unsigned i, unsigned j) const {
        assert (i < _dim[0]);
        assert (j < _dim[1]);
        unsigned index = i * _dim[1] + j;
        assert (index < _n);
        return _array[index];
    }

private:

    void _alloc (unsigned d0, unsigned d1) {
        _n = d0 * d1;
        _dim[0] = d0;
        _dim[1] = d1;
        _array = new Elem [_n];
    }
    void _delete () {
        assert (_array != NULL);
        delete [] _array;
        _array = NULL;
    }

    unsigned _n;
    Elem* _array;
    unsigned _dim[2];

}; // class Array2D

template <class Elem>
class Array3D 
{
public:

    Array3D () {
        _alloc(0,0,0);
    }
    Array3D (unsigned d0, unsigned d1, unsigned d2) {
        _alloc(d0,d1,d2);
    }
    ~Array3D () {
        _delete();
    }
    void resize (unsigned d0, unsigned d1, unsigned d2) {
        if (!issize(d0,d1,d2)) {
            _delete();
            _alloc(d0,d1,d2);
        }
    }
    void init (const Elem& elem) {
        for (unsigned i = 0; i < _n; i++) {
            _array[i] = elem;
        }
    }
    bool issize (unsigned d0, unsigned d1, unsigned d2) const {
        return (_dim[0] == d0 && _dim[1] == d1 && _dim[2] == d2);
    }
    int size (unsigned d) const {
        assert (d < 3);
        return _dim[d];
    }
    Elem* data () { 
        return _array; 
    }
    Elem& operator() (unsigned i, unsigned j, unsigned k) {
        assert (i < _dim[0]);
        assert (j < _dim[1]);
        assert (k < _dim[2]);
        unsigned index = (i * _dim[1] + j) * _dim[2] + k;
        assert (index < _n);
        return _array[index];
    }
    const Elem& operator() (unsigned i, unsigned j, unsigned k) const {
        assert (i < _dim[0]);
        assert (j < _dim[1]);
        assert (k < _dim[2]);
        unsigned index = (i * _dim[1] + j) * _dim[2] + k;
        assert (index < _n);
        return _array[index];
    }

private:

    void _alloc (unsigned d0, unsigned d1, unsigned d2) {
        _n = d0 * d1 * d2;
        _array = new Elem [_n];
        _dim[0] = d0;
        _dim[1] = d1;
        _dim[2] = d2;
    }
    void _delete () {
        assert (_array != NULL);
        delete [] _array;
        _array = NULL;
    }

    unsigned _n;
    Elem* _array;
    unsigned _dim[3];

}; // class Array3D

template <class Elem>
class Array4D 
{
public:

    Array4D () {
        _alloc(0,0,0,0);
    }
    Array4D (unsigned d0, unsigned d1, unsigned d2, unsigned d3) {
        _alloc(d0,d1,d2,d3);
    }
    ~Array4D () {
        _delete();
    }
    void resize (unsigned d0, unsigned d1, unsigned d2, unsigned d3) {
        if (!issize(d0,d1,d2,d3)) {
            _delete();
            _alloc(d0,d1,d2,d3);
        }
    }
    void init (const Elem& elem) {
        for (unsigned i = 0; i < _n; i++) {
            _array[i] = elem;
        }
    }
    bool issize (unsigned d0, unsigned d1, unsigned d2, unsigned d3) const {
        return (_dim[0] == d0 && _dim[1] == d1 && _dim[2] == d2 && _dim[3] == d3);
    }
    int size (unsigned d) const {
        assert (d < 4);
        return _dim[d];
    }
    Elem* data () { 
        return _array; 
    }
    Elem& operator() (unsigned i, unsigned j, unsigned k, unsigned m) {
        assert (i < _dim[0]);
        assert (j < _dim[1]);
        assert (k < _dim[2]);
        assert (m < _dim[3]);
        unsigned index = ((i * _dim[1] + j) * _dim[2] + k) * _dim[3] + m;
        assert (index < _n);
        return _array[index];
    }
    const Elem& operator() (unsigned i, unsigned j, unsigned k, unsigned m) const {
        assert (i < _dim[0]);
        assert (j < _dim[1]);
        assert (k < _dim[2]);
        assert (m < _dim[3]);
        unsigned index = ((i * _dim[1] + j) * _dim[2] + k) * _dim[3] + m;
        assert (index < _n);
        return _array[index];
    }

private:

    void _alloc (unsigned d0, unsigned d1, unsigned d2, unsigned d3) {
        _n = d0 * d1 * d2 * d3;
        _array = new Elem [_n];
        _dim[0] = d0;
        _dim[1] = d1;
        _dim[2] = d2;
        _dim[3] = d3;
    }
    void _delete () {
        assert (_array != NULL);
        delete [] _array;
        _array = NULL;
    }

    unsigned _n;
    Elem* _array;
    unsigned _dim[4];

}; // class Array4D

#endif // __Array_hh__
