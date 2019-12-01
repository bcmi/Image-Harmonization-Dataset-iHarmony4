
#ifndef __String_hh__
#define __String_hh__

// Class that makes it easy to construct strings in a safe manner.
// The main bonus is the printf-style interface for creating and
// appending strings.

// This class implements strings so that they behave like intrinsic
// types, i.e. assignment creates a copy, passing by value in a
// function call creates a copy.

// NOTE: Calling a constructor or append() method with a plain char*
// is dangerous, since the string is interpreted by sprintf.  To be
// safe, always do append("%s",s) instead of append(s).

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
#include <stdarg.h>
#include <string.h>
#include <iostream>

class String 
{
public:
    
    // Constructors.    
    String (); 
    String (const String& that); 
    String (const char* fmt, ...); 

    // Destructor.
    ~String ();

    // Assignment operators.
    String& operator= (const String& that);
    String& operator= (const char* s);

    // Accessors.
    unsigned length () const { return _length; }
    const char* text () const { return _text; }
    const char& operator[] (unsigned i) const;

    // Modifiers.
    void clear ();
    void append (char c);
    void append (unsigned length, const char* s);
    void append (const char* fmt, ...);

    // Load next line from file; newline is discarded.
    // Return true if new data; false on EOF.
    bool nextLine (FILE* fp);

    // Implicit convertion to const char* is useful so that other
    // modules that take strings as arguments don't have to know about
    // the String class, and the caller doesn't have to explicitly
    // call the text() method.
    operator const char* () const { return text(); }

private:

    static const unsigned defaultMinSize = 16;

    void _append (unsigned length, const char* s);
    void _append (const char* fmt, va_list ap);

    void _grow (unsigned minSize);
    
    unsigned	_length;
    unsigned	_size;
    char*	_text;

};

// == operator
inline int operator== (const String& x, const String& y) 
{ return strcmp (x, y) == 0; }
inline int operator== (const String& x, const char* y)
{ return strcmp (x, y) == 0; }
inline int operator== (const char* x, const String& y)
{ return strcmp (x, y) == 0; }

// != operator
inline int operator!= (const String& x, const String& y)
{ return strcmp (x, y) != 0; }
inline int operator!= (const String& x, const char* y)
{ return strcmp (x, y) != 0; }
inline int operator!= (const char* x, const String& y)
{ return strcmp (x, y) != 0; }

// < operator
inline int operator< (const String& x, const String& y) 
{ return strcmp (x, y) < 0; }
inline int operator< (const String& x, const char* y)
{ return strcmp (x, y) < 0; }
inline int operator< (const char* x, const String& y)
{ return strcmp (x, y) < 0; }

// > operator
inline int operator> (const String& x, const String& y) 
{ return strcmp (x, y) > 0; }
inline int operator> (const String& x, const char* y)
{ return strcmp (x, y) > 0; }
inline int operator> (const char* x, const String& y)
{ return strcmp (x, y) > 0; }
    
// <= operator
inline int operator<= (const String& x, const String& y) 
{ return strcmp (x, y) <= 0; }
inline int operator<= (const String& x, const char* y)
{ return strcmp (x, y) <= 0; }
inline int operator<= (const char* x, const String& y)
{ return strcmp (x, y) <= 0; }

// >= operator
inline int operator>= (const String& x, const String& y) 
{ return strcmp (x, y) >= 0; }
inline int operator>= (const String& x, const char* y)
{ return strcmp (x, y) >= 0; }
inline int operator>= (const char* x, const String& y)
{ return strcmp (x, y) >= 0; }

// write to output stream
inline std::ostream& operator<< (std::ostream& out, const String& s) {
    out << (const char*)s;
    return out;
}

#endif // __String_hh__
