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

	reference.c

	Reference in Constants and Variables
*/

#include "include.h"

Lfboundp()
{
	object sym;

	check_arg(1);
	sym = vs_base[0];
	if (type_of(sym) != t_symbol)
		not_a_symbol(sym);
	if (sym->s.s_sfdef != NOT_SPECIAL)
		vs_base[0] = Ct;
	else if (sym->s.s_gfdef == OBJNULL)
		vs_base[0]= Cnil;
	else
		vs_base[0]= Ct;
}

object
symbol_function(sym)
object sym;
{
/*
	if (type_of(sym) != t_symbol)
		not_a_symbol(sym);
*/
	if (sym->s.s_sfdef != NOT_SPECIAL || sym->s.s_mflag)
		FEinvalid_function(sym);
	if (sym->s.s_gfdef == OBJNULL)
		FEundefined_function(sym);
	return(sym->s.s_gfdef);
}

/*
	Symbol-function returns
                function-closure		for function
		(macro . function-closure)	for macros
		(special . address)		for special forms.
*/
Lsymbol_function()
{
	object sym;

	check_arg(1);
	sym = vs_base[0];
	if (type_of(sym) != t_symbol)
		not_a_symbol(sym);
	if (sym->s.s_sfdef != NOT_SPECIAL) {
		vs_push(make_fixnum((int)(sym->s.s_sfdef)));
		vs_base[0] = Sspecial;
		stack_cons();
		return;
	}
	if (sym->s.s_gfdef==OBJNULL)
		FEundefined_function(sym);
	if (sym->s.s_mflag) {
		vs_push(sym->s.s_gfdef);
		vs_base[0] = Smacro;
		stack_cons();
		return;
	}
	vs_base[0] = sym->s.s_gfdef;
}

Fquote(form)
object form;
{
	if (endp(form))
		FEtoo_few_argumentsF(form);
	if (!endp(MMcdr(form)))
		FEtoo_many_argumentsF(form);
	vs_base = vs_top;
	vs_push(MMcar(form));
}

Ffunction(form)
object form;
{
	object fun;
	object fd;
	if (endp(form))
		FEtoo_few_argumentsF(form);
	if (!endp(MMcdr(form)))
		FEtoo_many_argumentsF(form);
	fun = MMcar(form);
	if (type_of(fun) == t_symbol) {
		fd = lex_fd_sch(fun);
		if (MMnull(fd) || MMcadr(fd) != Sfunction)
			if (fun->s.s_gfdef == OBJNULL || fun->s.s_mflag)
				FEundefined_function(fun);
			else {
				vs_base = vs_top;
				vs_push(fun->s.s_gfdef);
			}
		else {
			vs_base = vs_top;
			vs_push(MMcaddr(fd));
		}
	} else if (type_of(fun) == t_cons && MMcar(fun) == Slambda) {
		vs_base = vs_top;
		vs_push(MMcdr(fun));
		vs_base[0] = MMcons(lex_env[2], vs_base[0]);
		vs_base[0] = MMcons(lex_env[1], vs_base[0]);
		vs_base[0] = MMcons(lex_env[0], vs_base[0]);
		vs_base[0] = MMcons(Slambda_closure, vs_base[0]);
	} else
		FEinvalid_function(fun);
}

Lsymbol_value()
{
	object sym;
	check_arg(1);
	sym = vs_base[0];
	if (type_of(sym) != t_symbol)
		not_a_symbol(sym);
	if (sym->s.s_dbind == OBJNULL)
		FEunbound_variable(sym);
	else
		vs_base[0] = sym->s.s_dbind;
}

Lboundp()
{
	object sym;
	check_arg(1);
	sym=vs_base[0];
	if (type_of(sym) != t_symbol)
		not_a_symbol(sym);
	if (sym->s.s_dbind == OBJNULL)
		vs_base[0] = Cnil;
	else
		vs_base[0] = Ct;
}

Lmacro_function()
{
	check_arg(1);
	if (type_of(vs_base[0]) != t_symbol)
		not_a_symbol(vs_base[0]);
	if (vs_base[0]->s.s_gfdef != OBJNULL && vs_base[0]->s.s_mflag)
		vs_base[0] = vs_base[0]->s.s_gfdef;
	else
		vs_base[0] = Cnil;
}

Lspecial_form_p()
{
	check_arg(1);
	if (type_of(vs_base[0]) != t_symbol)
		not_a_symbol(vs_base[0]);
	if (vs_base[0]->s.s_sfdef != NOT_SPECIAL)
		vs_base[0] = Ct;
	else
		vs_base[0] = Cnil;
}

init_reference()
{
	make_function("SYMBOL-FUNCTION", Lsymbol_function);
	make_function("FBOUNDP", Lfboundp);
	make_special_form("QUOTE", Fquote);
	Sfunction = make_special_form("FUNCTION", Ffunction);
	make_function("SYMBOL-VALUE", Lsymbol_value);
	make_function("BOUNDP", Lboundp);
	make_function("MACRO-FUNCTION", Lmacro_function);
	make_function("SPECIAL-FORM-P", Lspecial_form_p);
}

