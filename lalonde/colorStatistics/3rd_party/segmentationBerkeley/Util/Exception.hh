
#ifndef __Exception_hh__
#define __Exception_hh__

// A simple exception class that contains an error message.

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

#include <iostream>

class Exception 
{
public:

    // Always construct exception with a message, so we can print
    // a useful error/log message.
    Exception (const char* msg);

    // We need to implement the copy constructor so that rethrowing
    // works.
    Exception (const Exception& that);

    virtual ~Exception ();

    // Retrieve the message that this exception carries.
    virtual const char* msg () const;

protected:

    char* _msg;

};

// write to output stream
inline std::ostream& operator<< (std::ostream& out, const Exception& e) {
    out << e.msg();
    return out;
}

#endif // __Exception_hh__
