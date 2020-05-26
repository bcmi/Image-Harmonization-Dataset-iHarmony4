
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

#include <stdlib.h>
#include <string.h>
#include "Exception.hh"

Exception::Exception (const char* msg)
    : _msg (strdup (msg))
{
}

Exception::Exception (const Exception& that)
    : _msg (strdup (that._msg))
{
}

Exception::~Exception ()
{
    free (_msg);
}

const char*
Exception::msg () const
{
    return _msg;
}

