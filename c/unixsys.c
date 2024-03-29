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

#include "include.h"

#ifdef ATT3B2
#include <signal.h>
int
system(command)
char *command;
{
	char buf[4];
	extern sigint();

	signal(SIGINT, SIG_IGN);
	write(4, command, strlen(command)+1);
	read(5, buf, 1);
	signal(SIGINT, sigint);
	return(buf[0]<<8);
}
#endif

#ifdef E15
#include <signal.h>
int
system(command)
char *command;
{
	char buf[4];
	extern sigint();

	signal(SIGINT, SIG_IGN);
	write(4, command, strlen(command)+1);
	read(5, buf, 1);
	signal(SIGINT, sigint);
	return(buf[0]<<8);
}
#endif

Lsystem()
{
	char command[1024];
	int i;

	check_arg(1);
	check_type_string(&vs_base[0]);
	if (vs_base[0]->st.st_fillp >= 1024)
		FEerror("Too long command line: ~S.", 1, vs_base[0]);
	for (i = 0;  i < vs_base[0]->st.st_fillp;  i++)
		command[i] = vs_base[0]->st.st_self[i];
	command[i] = '\0';
	vs_base[0] = make_fixnum(system(command) >> 8);
}

init_unixsys()
{
	make_function("SYSTEM", Lsystem);
}
