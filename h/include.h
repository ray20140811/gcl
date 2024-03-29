/*
 Copyright (C) 1994 M. Hagiya, W. Schelter, T. Yuasa

This file is part of GNU Common Lisp, herein referred to as GCL

GCL is free software; you can redistribute it and/or modify it under
the terms of the GNU LIBRARY GENERAL PUBLIC LICENSE as published by
the Free Software Foundation; either version 2, or (at your option)
any later version.

GCL is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Library General Public 
License for more details.

You should have received a copy of the GNU Library General Public License 
along with GCL; see the file COPYING.  If not, write to the Free Software
Foundation, 675 Mass Ave, Cambridge, MA 02139, USA.

*/

/*
	include.h
*/

#include "options.h"
#include "config.h"

#ifdef __GNUC__
#ifndef alloca
#define alloca __builtin_alloca
#endif
#endif

#include <stdio.h>
#include <setjmp.h>

#ifdef UNIX
#include <ctype.h>
#define	isalphanum(x)	isalnum(x)
#endif


#include "../h/object.h"
#include "../h/vs.h"
#include "../h/symbol.h"
#include "../h/bds.h"
#include "../h/frame.h"
#include "../h/lex.h"
#include "../h/eval.h"

#include "../h/att_ext.h"
/*#ifdef ATT   
#include "../h/att_ext.h"
#else
#include "../h/external.h"
#endif
*/

#include "../h/rgbc.h"
