
#ifndef __Random_hh__
#define __Random_hh__

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
#include <stdlib.h>
#include <math.h>
#include <stdio.h>

// All random numbers are generated from a single seed.  This is true
// even when private random streams (seperate from the global
// Random::rand stream) are spawned from existing streams, since the new
// streams are seeded automatically from the parent's random stream.
// Any random stream can be reset so that a sequence of random values
// can be replayed.

// If seed==0, then the seed is generated from the system clock.

class Random
{
public:

    static Random rand;

    // These are defined in <limits.h> as the limits of int, but
    // here we need the limits of int32_t.
    static const int32_t int32_max = 2147483647;
    static const int32_t int32_min = -int32_max-1;
    static const u_int32_t u_int32_max = 4294967295u;

    // Seed from the system clock.
    Random ();

    // Specify seed.  
    // If zero, seed from the system clock.
    Random (u_int64_t seed);

    // Spawn off a new random stream seeded from the parent's stream.
    Random (Random& that);

    // Restore initial seed so we can replay a random sequence.
    void reset ();	

    // Set the seed.
    // If zero, seed from the system clock.
    void reseed (u_int64_t seed);

    // double in [0..1) or [a..b)
    inline double fp ();                      
    inline double fp (double a, double b);    

    // 32-bit signed integer in [-2^31,2^31) or [a..b]
    inline int32_t i32 ();                    
    inline int32_t i32 (int32_t a, int32_t b);    

    // 32-bit unsigned integer in [0,2^32) or [a..b]
    inline u_int32_t ui32 ();                    
    inline u_int32_t ui32 (u_int32_t a, u_int32_t b);  

protected:

    void _init (u_int64_t seed);

    // The original seed for this random stream.
    u_int64_t 	_seed;

    // The current state for this random stream.
    u_int16_t 	_xsubi[3];

};

inline u_int32_t 
Random::ui32 () 
{ 
    return ui32(0,u_int32_max);
}

inline u_int32_t 
Random::ui32 (u_int32_t a, u_int32_t b)
{
    assert (a <= b);
    double x = fp ();
    return (u_int32_t) floor (x * ((double)b - (double)a + 1) + a);
}

inline int32_t 
Random::i32 () 
{ 
    return i32(int32_min,int32_max);
}

inline int32_t 
Random::i32 (int32_t a, int32_t b)
{
    assert (a <= b);
    double x = fp ();
    return (int32_t) floor (x * ((double)b - (double)a + 1) + a);
}

inline double 
Random::fp ()
{
    return erand48 (_xsubi);
}

inline double 
Random::fp (double a, double b)
{
    assert (a < b);
    return erand48 (_xsubi) * (b - a) + a;
}

#endif // __Random_hh__

