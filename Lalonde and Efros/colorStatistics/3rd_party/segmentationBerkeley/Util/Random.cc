
#include <sys/time.h>
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "Random.hh"
#include "String.hh"
#include "Exception.hh"

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

Random Random::rand;

Random::Random ()
{
    reseed (0);
}

Random::Random (u_int64_t seed)
{
    reseed (seed);
}

Random::Random (Random& that)
{
    u_int64_t a = that.ui32 ();
    u_int64_t b = that.ui32 ();
    u_int64_t seed = (a << 32) | b;
    _init (seed);
}

void 
Random::reset ()
{
    _init (_seed);
}

void 
Random::reseed (u_int64_t seed)
{
    if (seed == 0) {
	struct timeval t;
	gettimeofday (&t, NULL);
	u_int64_t a = (t.tv_usec >> 3) & 0xffff;
	u_int64_t b = t.tv_sec & 0xffff;
	u_int64_t c = (t.tv_sec >> 16) & 0xffff;
	seed = a | (b << 16) | (c << 32);
    }
    _init (seed);
}

void
Random::_init (u_int64_t seed)
{
    _seed = seed & 0xffffffffffffull;
    _xsubi[0] = (seed >>  0) & 0xffff;
    _xsubi[1] = (seed >> 16) & 0xffff;
    _xsubi[2] = (seed >> 32) & 0xffff;
}

