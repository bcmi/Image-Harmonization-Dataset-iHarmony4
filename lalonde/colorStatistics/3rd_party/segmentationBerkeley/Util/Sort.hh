
#ifndef __Sort_hh__
#define __Sort_hh__

//
// A fast in-place sorting routine that can be customized to a
// specific type with all swap and compare operations inlined.
//
// For arrays of types for which assignment, > and < exist (such as
// int,float,etc. or appropriately-defined user types), the usage is
// simple:
//
//   double* a = new double [100];
//   sort(a,100);
// 
// This will sort the array into increasing order.  To sort in another
// order, or to sort more complex types, you must provide compare and
// swap routines:
//
//   sortSwap(cl,i,j) 
//	- Swap elements i and j.
//
//   sortCmp(cl,i,j) 
//	- Compare elements i and j, returning -1,0,1 for <,=,>.
// 
// The argument 'cl' is a closure.  Note that the sorting routine does
// not evaluate cl in any context other than these two routines.
//
// The postcondition of sort() is (sortCmp(cl,i,j) <= 0) for 
// all 0 <= i < j < n, i.e. increasing order.
//
// Here is an example of how to sort an array of points by x
// coordinate in decreasing order:
//
// struct Point { int x, y; };
// static inline void sortSwap (Point* a, int i, int j) {
//	swap(a[i],a[j]);
// }
// static inline int sortCmp (Point* a, int i, int j) {
//	return a[j].x - a[i].x;
// }
// Point* points = new Point [100];
// sort(points,100);
//

// Copyright (C) 2002 David R. Martin <dmartin@eecs.berkeley.edu>
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

#include <assert.h>

// Public routines for sorting arrays of simple values that have
// assignment, < and > defined.
template <class T>
static inline void sortSwap (T* a, int i, int j) {
    T tmp = a[i]; a[i] = a[j]; a[j] = tmp;
}
template <class T>
static inline int sortCmp (T* a, int i, int j) {
    if (a[i] < a[j]) { return -1; }
    if (a[i] > a[j]) { return 1; }
    return 0;
}

// Private routine.
// Sort elements [start,start+n) using insertion sort.
template <class Closure>
void
__insertionSort (Closure cl, int start, int n)
{
    for (int i = start; i < start+n-1; i++) {
        for (int j = i+1; j > start; j--) {
            if (sortCmp(cl,j-1,j) <= 0) { break; }
            sortSwap(cl,j-1,j);
        }
    }
}

// Private routine.
// Sort elements [start,start+n) using selection sort.
template <class Closure>
void
__selectionSort1 (Closure cl, int start, int n)
{
    for (int i = start; i < start + n - 1; i++) {
    	// Skip over duplicate elements.
	if (i > start && sortCmp(cl,i,i-1) == 0) { continue; }
    	// Find the smallest element in [i,end] and move it to the front.
	int minLoc = i;
	for (int j = i + 1; j < start + n; j++) {
	    if (sortCmp(cl,j,minLoc) < 0) {
		minLoc = j;
	    }
	}
	if (minLoc > i) {
	    sortSwap (cl, i, minLoc);
	}
    }
}

// Private routine.
// Sort elements [start,start+n) using double-ended selection sort.
template <class Closure>
void
__selectionSort2 (Closure cl, int start, int n)
{
    int i = start;
    int j = start + n - 1;
    while (i < j) {
        // Skip over duplicate elements.
	if (i > start && sortCmp(cl,i,i-1) == 0) { i++; continue; }
	if (j < start+n-1 && sortCmp(cl,j,j+1) == 0) { j--; continue; }
        // Find the min and max elements in [i,j].
        int minLoc=i, maxLoc=i;
        for (int k = i + 1; k <= j; k++) {
            if (sortCmp(cl,k,minLoc) < 0) { minLoc = k; }
            if (sortCmp(cl,k,maxLoc) > 0) { maxLoc = k; }
        }
        // Move the min element to the front and the max element to
        // the back.
        if (minLoc == maxLoc) { break; }
        if (minLoc > maxLoc) { 
            sortSwap(cl,minLoc,maxLoc); 
            int tmp=minLoc; minLoc=maxLoc; maxLoc=tmp;
        }
        if (minLoc > i) { sortSwap(cl,i,minLoc); }
        if (maxLoc < j) { sortSwap(cl,j,maxLoc); }
        i++; j--;
    }
}

// Private routine.
// Return the median of the 3 arguments as defined by cmp##NAME.
// Used internally in qsort to pick a pivot.
template <class Closure>
int 
__3median (Closure cl, int x, int y, int z) 
{
    return sortCmp(cl,x,y) > 0 
    		? (sortCmp(cl,y,z) > 0 
       			? y : (sortCmp(cl,x,z) > 0 ? z : x)) 
		: (sortCmp(cl,y,z) < 0 
	   		? y : (sortCmp(cl,x,z) < 0 ? z : x));
}

// Private routine.
// Sort elements [start,start+n) using quick sort.
template <class Closure>
void
__quickSort (Closure cl, int start, int n)
{
    // Use selection-sort for small arrays.
    if (n < 16) { 
	__insertionSort (cl, start, n); 
	//__selectionSort1 (cl, start, n); 
	//__selectionSort2 (cl, start, n); 
	return; 
    }

    // Pick the median of elements n/4, n/2, 3n/4 as the pivot, and
    // move it to the front.
    int x = start + (n >> 2);
    int y = start + (n >> 1);
    int z = x + (n >> 1);
    int pivotLoc = __3median (cl, x, y, z);
    sortSwap (cl, start, pivotLoc);

    // Segregate array elements into three groups.  Those equal to the
    // pivot (=), those less than the pivot (<), and those greater
    // than the pivot (>).  After this loop, the array will look like
    // this:
    //     	S   P    RL                                                 	
    //     	=====<<<<<>>>>>                                             	
    //
    // Where S=start P=pivot R=right L=left.                           	
    //
    int pivot = start;
    int left = start + 1;
    int right = start + n - 1;
    while (1) {
      restart:
	while (left <= right) {
 	    int c = sortCmp (cl, left, pivot);
            if (c > 0) { break; }
	    if (c < 0) { left++; continue; }
	    if (left != pivot+1) { sortSwap (cl, left, pivot+1); }
	    pivot++; left++;
	}
	while (left <= right) {
	    int c = sortCmp (cl, right, pivot);
	    if (c < 0) { break; }
	    if (c > 0) { right--; continue; }
            assert (left < right);
	    sortSwap (cl, left, right);
	    if (left != pivot+1) { sortSwap (cl, left, pivot+1); }
	    pivot++; left++; right--;
	    goto restart;
	}
	if (left > right) { break; }
	sortSwap (cl, left, right);
    }
    assert (pivot >= start);
    assert (right >= pivot);
    assert (left == right + 1);
    assert (left <= start + n);

    int numEq = pivot - start + 1;
    int numLt = right - pivot;
    int numLe = left - start;
    int numGt = n - numLe;
    assert (numEq + numLt + numGt == n);

    // Copy pivot values into middle.                                  	
    int count = (numEq < numLt) ? numEq : numLt;
    int dist = numLe - count;
    for (int i = 0; i < count; i++) {
	sortSwap (cl, start + i, start + i + dist); 
    }

    // Recursively sort the < and > chunks.                            	
    if (numLt > 0) { __quickSort (cl, start, numLt); }
    if (numGt > 0) { __quickSort (cl, left, numGt); }
}

// Public sort routine.
template <class Closure>
inline void
sort (Closure cl, int n)
{
    __quickSort (cl, 0, n); 
    // Check the postcondition.
    for (int i = 1; i < n; i++) { 
	assert (sortCmp (cl, i-1, i) <= 0); 
    } 
}

#endif // __Sort_hh__
