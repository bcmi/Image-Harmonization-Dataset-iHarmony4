
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
#include <assert.h>
#include "String.hh"

String::String ()
{
    _length = 0;
    _size = defaultMinSize + 1;
    _text = new char [_size];
    _text[_length] = '\0';
}

String::String (const String& that)
{
    _length = that._length;
    _size = that._size;
    _text = new char [_size];
    memcpy (_text, that._text, _length + 1);
}

String::String (const char* fmt, ...)
{
    assert (fmt != NULL);

    _length = 0;
    _size = strlen (fmt) + 1;
    _text = new char [_size];
    _text[_length] = '\0';

    va_list ap;
    va_start (ap, fmt);
    _append (fmt, ap);
    va_end (ap);
}

String::~String ()
{
    assert (_text != NULL);
    delete [] _text;
}

String& 
String::operator= (const String& that)
{
    if (&that == this) { return *this; }
    clear();
    append ("%s", that.text());
    return *this;
}

String& 
String::operator= (const char* s)
{
    clear();
    if (s != NULL) {
        append ("%s", s);
    }
    return *this;
}

void
String::clear ()
{
    _length = 0;
    _text[0] = '\0';
}

void
String::append (char c)
{
    _append (1, (const char*)&c);
}

void 
String::append (unsigned length, const char* s) 
{
    _append (length, s);
}

void
String::append (const char* fmt, ...)
{
    assert (fmt != NULL);
    va_list ap;
    va_start (ap, fmt);
    _append (fmt, ap);
    va_end (ap);
}

const char& 
String::operator[] (unsigned i) const
{
    assert (i < _length);
    return _text[i];
}

bool
String::nextLine (FILE* fp)
{
    assert (fp != NULL);

    const int bufLen = 128;
    char buf[bufLen];

    clear ();

    while (fgets (buf, bufLen, fp) != NULL) {
	_append (strlen (buf), buf);
	if (_text[_length - 1] == '\n') {
	    _length--;
	    _text[_length] = '\0';
	    return true;
	}
    }

    if (_length > 0) {
	assert (_text[_length - 1] != '\n');
	return true;
    } else {
	return false;
    }
}

void
String::_append (unsigned length, const char* s)
{
    _grow (length + _length + 1);
    if (length > 0) {
	memcpy (_text + _length, s, length);
	_length += length;
	_text[_length] = '\0';
    }
}

// On solaris and linux, vsnprintf returns the number of characters needed
// to format the entire string.
// On irix, vsnprintf returns the number of characters written.  This is
// at most length(buf)-1.
// On some sytems, vsnprintf returns -1 if there wasn't enough space.
void
String::_append (const char* fmt, va_list ap)
{
    int bufLen = 128;
    char* buf;

    while (1) {
	buf = new char [bufLen];
	int cnt = vsnprintf (buf, bufLen, fmt, ap);
	if (cnt < 0 || cnt >= bufLen - 1) {
	    delete [] buf;
	    bufLen *= 2;
	    continue;
	} else {
	    break;
	}
    }

    _append (strlen (buf), buf);
    delete [] buf;
}

void	
String::_grow (unsigned minSize)
{
    if (minSize > _size) {
	char* old = _text;
	_size += minSize;
	_text = new char [_size];
	memcpy (_text, old, _length + 1);
	delete [] old;
    }
}

