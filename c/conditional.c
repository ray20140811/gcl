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

	conditional.c

	conditionals
*/

#include "include.h"

object Sotherwise;

Fif(form)
object form;
{
	object *top = vs_top;

	if (endp(form) || endp(MMcdr(form)))
		FEtoo_few_argumentsF(form);
	if (!endp(MMcddr(form)) && !endp(MMcdddr(form)))
		FEtoo_many_argumentsF(form);
	eval(MMcar(form));
	if (vs_base[0] == Cnil)
		if (endp(MMcddr(form))) {
			vs_top = vs_base = top;
			vs_push(Cnil);
		} else {
			vs_top = top;
			eval(MMcaddr(form));
		}
	else {
		vs_top = top;
		eval(MMcadr(form));
	}
}

Fcond(args)
object args;
{
	object *top = vs_top;
	object clause;
	object conseq;

	while (!endp(args)) {
		clause = MMcar(args);
		if (type_of(clause) != t_cons)
			FEerror("~S is an illegal COND clause.",1,clause);
		eval(MMcar(clause));
		if (vs_base[0] != Cnil) {
			conseq = MMcdr(clause);
			if (endp(conseq)) {
				vs_top = vs_base+1;
				return;
			}
			while (!endp(conseq)) {
				vs_top = top;
				eval(MMcar(conseq));
				conseq = MMcdr(conseq);
			}
			return;
		}
		vs_top = top;
		args = MMcdr(args);
	}
	vs_base = vs_top = top;
	vs_push(Cnil);
}

Fcase(arg)
object arg;
{
	object *top = vs_top;
	object clause;
	object key;
	object conseq;

	if (endp(arg))
		FEtoo_few_argumentsF(arg);
	eval(MMcar(arg));
	vs_top = top;
	vs_push(vs_base[0]);
	arg = MMcdr(arg);
	while (!endp(arg)) {
		clause = MMcar(arg);
		if (type_of(clause) != t_cons)
			FEerror("~S is an illegal CASE clause.",1,clause);
		key = MMcar(clause);
		conseq = MMcdr(clause);
		if (type_of(key) == t_cons)
			do {
				if (eql(MMcar(key),top[0]))
					goto FOUND;
				key = MMcdr(key);
			} while (!endp(key));
		else if (key == Cnil)
			;
		else if (key == Ct || key == Sotherwise || eql(key,top[0]))
			goto FOUND;
		arg = MMcdr(arg);
	}
	vs_base = vs_top = top;
	vs_push(Cnil);
	return;

FOUND:
	if (endp(conseq)) {
		vs_base = vs_top = top;
		vs_push(Cnil);
	} else
		 do {
			vs_top = top;
			eval(MMcar(conseq));
			conseq = MMcdr(conseq);
		} while (!endp(conseq));
	return;
}

Fwhen(form)
object form;
{
	object *top = vs_top;

	if (endp(form))
		FEtoo_few_argumentsF(form);
	eval(MMcar(form));
	if (vs_base[0] == Cnil) {
		vs_base = vs_top = top;
		vs_push(Cnil);
	} else {
		form = MMcdr(form);
		if (endp(form)) {
			vs_base = vs_top = top;
			vs_push(Cnil);
		} else
			do {
				vs_top = top;
				eval(MMcar(form));
				form = MMcdr(form);
			} while (!endp(form));
	}
}

Funless(form)
object form;
{
	object *top = vs_top;

	if (endp(form))
		FEtoo_few_argumentsF(form);
	eval(MMcar(form));
	if (vs_base[0] == Cnil) {
		vs_top = top;
		form = MMcdr(form);
		if (endp(form)) {
			vs_base = vs_top = top;
			vs_push(Cnil);
		} else
			do {
				vs_top = top;
				eval(MMcar(form));
				form = MMcdr(form);
			} while (!endp(form));
	} else {
		vs_base = vs_top = top;
		vs_push(Cnil);
	}
}

init_conditional()
{
	make_special_form("IF",Fif);
	make_special_form("COND",Fcond);
	make_special_form("CASE",Fcase);
	make_special_form("WHEN",Fwhen);
	make_special_form("UNLESS",Funless);

	Sotherwise = make_ordinary("OTHERWISE");
	enter_mark_origin(&Sotherwise);
}
