
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

#include <stdio.h>
#include <string.h>
#include <math.h>
#include "Timer.hh"

typedef unsigned long long uint64;

void
Timer::_compute ()
{
    // Compute elapsed time.
    long sec = _elapsed_stop.tv_sec - _elapsed_start.tv_sec;
    long usec = _elapsed_stop.tv_usec - _elapsed_start.tv_usec;
    if (usec < 0) {
	sec -= 1;
	usec += 1000000;
    }
    _elapsed += (double) sec + usec / 1e6;

    // Computer CPU user and system times.
    _user += (double) (_cpu_stop.tms_utime - _cpu_start.tms_utime) 
             / sysconf(_SC_CLK_TCK);
    _system += (double) (_cpu_stop.tms_stime - _cpu_start.tms_stime) 
               / sysconf(_SC_CLK_TCK);
}

// Convert time in seconds into a nice human-friendly format: h:mm:ss.ss
// Return a pointer to a static buffer.
const char* 
Timer::formatTime (double sec, int precision)
{
    static char buf[128];

    // Limit range of precision for safety and sanity.
    precision = (precision < 0) ? 0 : precision;
    precision = (precision > 9) ? 9 : precision;
    uint64 base = 1;
    for (int digit = 0; digit < precision; digit++) { base *= 10;}

    bool neg = (sec < 0);
    uint64 ticks = (uint64) rint (fabs (sec) * base);
    uint64 rsec = ticks / base;		// Rounded seconds.
    uint64 frac = ticks % base;

    uint64 h = rsec / 3600;
    uint64 m = (rsec / 60) % 60;
    uint64 s = rsec % 60;

    sprintf (buf, "%s%llu:%02llu:%02llu", 
	     neg ? "-" : "", h, m, s);

    if (precision > 0) {
	static char fmt[10];
	sprintf (fmt, ".%%0%dlld", precision);
	sprintf (buf + strlen (buf), fmt, frac);
    }

    return buf;
}

