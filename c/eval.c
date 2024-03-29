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
	eval.c
*/

#include "include.h"
#include "sfun_argd.h"

struct nil3 { object nil3_self[3]; } three_nils;

#ifdef DEBUG_AVMA
#undef DEBUG_AVMA
unsigned long avma,bot;
#define DEBUG_AVMA unsigned long saved_avma =  avma;
warn_avma()
{ 
  print(list(2,make_simple_string("avma changed"),ihs_top_function_name()),
	Vstandard_output->s.s_dbind);
}
#define CHECK_AVMA if(avma!= saved_avma) warn_avma();
#define DEBUGGING_AVMA  
#else
#define DEBUG_AVMA
#define CHECK_AVMA
#endif

#undef endp

#define	endp(obje)	((enum type)((endp_temp = (obje))->d.t) == t_cons ? \
			 FALSE : endp_temp == Cnil ? TRUE : \
			 (bool)FEwrong_type_argument(Slist, endp_temp))

object endp_temp;

int eval1 = 0;
object c_apply_n();

object siSbreak_points;
object siSbreak_step;


#define SET_TO_APPLY(res,f,n,x) \
 switch(n) {\
 case 0:   res=((f))(); break;\
  case 1:  res=((f))(x[0]); break; \
  case 2:  res=((f))(x[0],x[1]);break; \
  case 3:  res=((f))(x[0],x[1],x[2]);break; \
  case 4:  res=((f))(x[0],x[1],x[2],x[3]);break; \
  case 5:  res=((f))(x[0],x[1],x[2],x[3],x[4]);break; \
  case 6:  res=((f))(x[0],x[1],x[2],x[3],x[4],x[5]);  break;\
  case 7:  res=((f))(x[0],x[1],x[2],x[3],x[4],x[5], x[6]); break;\
  case 8:  res=((f))(x[0],x[1],x[2],x[3],x[4],x[5], x[6],x[7]); break;\
  case 9:  res=((f))(x[0],x[1],x[2],x[3],x[4],x[5],x[6],x[7],x[8]);break;\
  case 10: res=((f))(x[0],x[1],x[2],x[3],x[4],x[5],x[6],x[7],x[8],x[9]);break;\
   default: res=c_apply_n(f,n,x); break;}

/*
#undef SET_TO_APPLY
#define SET_TO_APPLY(res,f,n,x)  res=c_apply_n(f,n,x);
*/

/* for t_sfun,t_gfun with args on vs stack */

quick_call_sfun(fun)
     object fun;
{ DEBUG_AVMA
  int i,n;
  enum ftype restype;
  object *x,res;
  object temp_ar[10];
  i=fun->sfn.sfn_argd;
  n=SFUN_NARGS(i);
  if (n != vs_top -vs_base)
    {check_arg_failed(n);}
  restype = SFUN_RETURN_TYPE(i);
  SFUN_START_ARG_TYPES(i);
  /* for moment just support object and int */
#define COERCE_ARG(a,type)  (type==f_object ? a : (object)(fix(a)))
  if (i==0)
    x=vs_base;
  else
    {int j;
     x=temp_ar;
     for (j=0; j<n ; j++)
       {enum ftype typ=SFUN_NEXT_TYPE(i);
	x[j]=COERCE_ARG(vs_base[j],typ);}}
  SET_TO_APPLY(res,(object (*)())fun->sfn.sfn_self,n,x);
  vs_base[0]=
    (restype==f_object ?  res :
     restype==f_fixnum ? make_fixnum((int)res)
     :(object) FEerror("Bad result type"));
  vs_top=vs_base+1;
  CHECK_AVMA;
  return;}

/* only for sfun not gfun !!  Does not check number of args */
call_sfun_no_check(fun)
     object fun;
{ DEBUG_AVMA
  int n;
  object *base=vs_base;
  n=vs_top - base;
  SET_TO_APPLY(base[0],(object (*)())fun->sfn.sfn_self,n,base);
  vs_top=(vs_base=base)+1;
  CHECK_AVMA;
  return;
}
call_vfun(fun)
     object fun;
{ DEBUG_AVMA
  int n;
  object *base=vs_base;
  n=vs_top - base;
  if (n < fun->vfn.vfn_minargs)
    {FEtoo_few_arguments(base,vs_top); return;}
  if (n > fun->vfn.vfn_maxargs)
    {FEtoo_many_arguments(base,vs_top); return;}
  VFUN_NARGS = n;
  SET_TO_APPLY(base[0],(object (*)())fun->sfn.sfn_self,n,base);
  vs_top=(vs_base=base)+1;
  CHECK_AVMA;
  return;
}

static object temporary;

funcall(fun)
object fun;
{
	object x;
	 object * VOL top;
	object *lex;
	bds_ptr old_bds_top;
	VOL bool b;
	bool c;
	DEBUG_AVMA
      TOP:
	if (fun == OBJNULL)
		FEerror("Undefined function.", 0);
	switch (type_of(fun)) {
	case t_cfun:
		MMcall(fun);
		CHECK_AVMA; return;
	case t_gfun:	
	case t_sfun:
		ihs_check;ihs_push(fun);
		quick_call_sfun(fun);
		ihs_pop();
		return;
        case t_vfun:
		ihs_check;ihs_push(fun);
		call_vfun(fun);
		ihs_pop();
		return;
	case t_cclosure:
	{
		object *top, *base, l;

		if (fun->cc.cc_turbo != NULL) {
			MMccall(fun, fun->cc.cc_turbo);
			CHECK_AVMA; return;
		}
		top = vs_top;
		base = vs_base;
		for (l = fun->cc.cc_env;  !endp(l);  l = l->c.c_cdr)
			vs_push(l);
		vs_base = vs_top;
		while (base < top)
			vs_push(*base++);
		MMccall(fun, top);
		CHECK_AVMA; return;
	}
		
        case t_dclosure:
		(*(fun)->dc.dc_self)(fun->dc.dc_env);
		CHECK_AVMA; return;
	case t_symbol:
	     {object x = fun->s.s_gfdef;
	      if (x) { fun = x; goto TOP;}
	      else
		FEundefined_function(fun);
	      }

	case t_cons:
		break;

	default:
		FEinvalid_function(fun);
	}

	/*
		This part is the same as that of funcall_no_event.
	*/

	/* we may have pushed the calling form if this is called invoked from 
	   eval.   A lambda call requires vs_push's, so we can tell
	   if we pushed by vs_base being the same.
	   */
      { VOL int not_pushed = 0;
	if (vs_base != 	ihs_top->ihs_base){
	  ihs_check;
	  ihs_push(fun);
	}
	else
	  not_pushed = 1;

	ihs_top->ihs_base = lex_env;
	x = MMcar(fun);
	top = vs_top;
	lex = lex_env;
	old_bds_top = bds_top;

	/* maybe digest this lambda expression
	   (lambda-block-expand name ..) has already been
	   expanded.    The value of lambda-block-expand may
	   be a compiled function in which case we say expand
	   with it)
	 */

	if (x == siSlambda_block_expanded) {

	  b = TRUE;
	  c = FALSE;
	  fun = fun->c.c_cdr;

	}else if (x == Slambda_block) {
	  b = TRUE;
	  c = FALSE;
	  if(type_of(siSlambda_block_expanded->s.s_dbind) == t_sfun)
	    fun = ifuncall1(siSlambda_block_expanded->s.s_dbind,fun);

	  fun = fun->c.c_cdr;


	
	} else if (x == Slambda_closure) {
		b = FALSE;
		c = TRUE;
		fun = fun->c.c_cdr;
	} else if (x == Slambda) {
		b = c = FALSE;
		fun = fun->c.c_cdr;
	} else if (x == Slambda_block_closure) {
		b = c = TRUE;
		fun = fun->c.c_cdr;
	} else
		b = c = TRUE;
	if (c) {
		vs_push(kar(fun));
		fun = fun->c.c_cdr;
		vs_push(kar(fun));
		fun = fun->c.c_cdr;
		vs_push(kar(fun));
		fun = fun->c.c_cdr;
	} else {
		*(struct nil3 *)vs_top = three_nils;
		vs_top += 3;
	}
	if (b) {
		x = kar(fun);  /* block name */
		fun = fun->c.c_cdr;
	}
	lex_env = top;
	vs_push(fun);
    	lambda_bind(top);
	ihs_top->ihs_base = lex_env;
	if (b) {
		fun = temporary = alloc_frame_id();
		/*  lex_block_bind(x, temporary);  */
		temporary = MMcons(temporary, Cnil);
		temporary = MMcons(Sblock, temporary);
		temporary = MMcons(x, temporary);
		lex_env[2] = MMcons(temporary, lex_env[2]);
		frs_push(FRS_CATCH, fun);
		if (nlj_active) {
			nlj_active = FALSE;
			goto END;
		}
	}
	x = top[3];  /* body */
	if(endp(x)) {
		vs_base = vs_top;
		vs_push(Cnil);
	} else {
		top = vs_top;
		for (;;) {
			eval(MMcar(x));
			x = MMcdr(x);
			if (endp(x))
				break;
			vs_top = top;
		}
	}
END:
	if (b)
		frs_pop();
	bds_unwind(old_bds_top);
	lex_env = lex;
	if (not_pushed == 0) {ihs_pop();}
	CHECK_AVMA;
}}


funcall_no_event(fun)
object fun;
{ DEBUG_AVMA
	if (fun == OBJNULL)
		FEerror("Undefined function.", 0);
	switch (type_of(fun)) {
	case t_cfun:
		(*fun->cf.cf_self)();
		break;

	case t_cclosure:
	{
		object *top, *base, l;

		if (fun->cc.cc_turbo != NULL) {
			(*fun->cc.cc_self)(fun->cc.cc_turbo);
			break;
		}
		top = vs_top;
		base = vs_base;
		for (l = fun->cc.cc_env;  !endp(l);  l = l->c.c_cdr)
			vs_push(l);
		vs_base = vs_top;
		while (base < top)
			vs_push(*base++);
		(*fun->cc.cc_self)(top);
		break;
	}

	case t_sfun:
		call_sfun_no_check(fun); return;
        case t_gfun:
		quick_call_sfun(fun); return;
        case t_vfun:
		call_vfun(fun); return;
        case t_dclosure:
		(*(fun)->dc.dc_self)(fun->dc.dc_env);
		CHECK_AVMA; return;

	default:
		funcall(fun);
		
	}
}

lispcall(funp, narg)
object *funp;
int narg;
{ DEBUG_AVMA
	object fun = *funp;

	vs_base = funp + 1;
	vs_top = vs_base + narg;

	if (fun == OBJNULL)
		FEerror("Undefined function.", 0);
	switch (type_of(fun)) {
	case t_cfun:
		MMcall(fun);
		break;

	case t_cclosure:
	{
		object *top, *base, l;

		if (fun->cc.cc_turbo != NULL) {
			MMccall(fun, fun->cc.cc_turbo);
			break;
		}
		top = vs_top;
		base = vs_base;
		for (l = fun->cc.cc_env;  !endp(l);  l = l->c.c_cdr)
			vs_push(l);
		vs_base = vs_top;
		while (base < top)
			vs_push(*base++);
		MMccall(fun, top);
		break;
	}

	      default:
		funcall(fun);

	}
  CHECK_AVMA;
}

lispcall_no_event(funp, narg)
object *funp;
int narg;
{        DEBUG_AVMA
	object fun = *funp;

	vs_base = funp + 1;
	vs_top = vs_base + narg;

	if (fun == OBJNULL)
		FEerror("Undefined function.", 0);
	switch (type_of(fun)) {
	case t_cfun:
		(*fun->cf.cf_self)();
		break;

	case t_cclosure:
	{
		object *top, *base, l;

		if (fun->cc.cc_turbo != NULL) {
			(*fun->cc.cc_self)(fun->cc.cc_turbo);
			break;
		}
		top = vs_top;
		base = vs_base;
		for (l = fun->cc.cc_env;  !endp(l);  l = l->c.c_cdr)
			vs_push(l);
		vs_base = vs_top;
		while (base < top)
			vs_push(*base++);
		(*fun->cc.cc_self)(top);
		break;
	}


	default:
		funcall(fun);

	}
	 CHECK_AVMA;
}

symlispcall(sym, base, narg)
object sym, *base;
int narg;
{       DEBUG_AVMA
	object fun = symbol_function(sym);

	vs_base = base;
	vs_top = vs_base + narg;

	if (fun == OBJNULL)
		FEerror("Undefined function.", 0);
	switch (type_of(fun)) {
	case t_cfun:
		MMcall(fun);
		break;

	case t_cclosure:
	{
		object *top, *base, l;

		if (fun->cc.cc_turbo != NULL) {
			MMccall(fun, fun->cc.cc_turbo);
			break;
		}
		top = vs_top;
		base = vs_base;
		for (l = fun->cc.cc_env;  !endp(l);  l = l->c.c_cdr)
			vs_push(l);
		vs_base = vs_top;
		while (base < top)
			vs_push(*base++);
		MMccall(fun, top);
		break;
	}

	default:
		funcall(fun);
	}
	CHECK_AVMA;
}

symlispcall_no_event(sym, base, narg)
object sym, *base;
int narg;
{       DEBUG_AVMA
	object fun = symbol_function(sym);

	vs_base = base;
	vs_top = vs_base + narg;

	if (fun == OBJNULL)
		FEerror("Undefined function.", 0);
	switch (type_of(fun)) {
	case t_cfun:
		(*fun->cf.cf_self)();
		break;

	case t_cclosure:
	{
		object *top, *base, l;

		if (fun->cc.cc_turbo != NULL) {
			(*fun->cc.cc_self)(fun->cc.cc_turbo);
			break;
		}
		top = vs_top;
		base = vs_base;
		for (l = fun->cc.cc_env;  !endp(l);  l = l->c.c_cdr)
			vs_push(l);
		vs_base = vs_top;
		while (base < top)
			vs_push(*base++);
		(*fun->cc.cc_self)(top);
		break;
	}

	default:
		funcall(fun);

	}
	CHECK_AVMA;
}

object
simple_lispcall(funp, narg)
object *funp;
int narg;
{       DEBUG_AVMA
	object fun = *funp;
	object *sup = vs_top;

	vs_base = funp + 1;
	vs_top = vs_base + narg;

	if (fun == OBJNULL)
		FEerror("Undefined function.", 0);
	switch (type_of(fun)) {
	case t_cfun:
		MMcall(fun);
		break;

	case t_cclosure:
	{
		object *top, *base, l;

		if (fun->cc.cc_turbo != NULL) {
			MMccall(fun, fun->cc.cc_turbo);
			break;
		}
		top = vs_top;
		base = vs_base;
		for (l = fun->cc.cc_env;  !endp(l);  l = l->c.c_cdr)
			vs_push(l);
		vs_base = vs_top;
		while (base < top)
			vs_push(*base++);
		MMccall(fun, top);
		break;
	}

	default:
		funcall(fun);
	}
	vs_top = sup;
	CHECK_AVMA;
	return(vs_base[0]);
	
}

object
simple_lispcall_no_event(funp, narg)
object *funp;
int narg;
{       DEBUG_AVMA 
	object fun = *funp;
	object *sup = vs_top;

	vs_base = funp + 1;
	vs_top = vs_base + narg;

	if (fun == OBJNULL)
		FEerror("Undefined function.", 0);
	switch (type_of(fun)) {
	case t_cfun:
		(*fun->cf.cf_self)();
		break;

	case t_cclosure:
	{
		object *top, *base, l;

		if (fun->cc.cc_turbo != NULL) {
			(*fun->cc.cc_self)(fun->cc.cc_turbo);
			break;
		}
		top = vs_top;
		base = vs_base;
		for (l = fun->cc.cc_env;  !endp(l);  l = l->c.c_cdr)
			vs_push(l);
		vs_base = vs_top;
		while (base < top)
			vs_push(*base++);
		(*fun->cc.cc_self)(top);
		break;
	}

	default:
		funcall(fun);

	}
	vs_top = sup;
	CHECK_AVMA;
	return(vs_base[0]);
}

object
simple_symlispcall(sym, base, narg)
object sym, *base;
int narg;
{       DEBUG_AVMA
	object fun = symbol_function(sym);
	object *sup = vs_top;

	vs_base = base;
	vs_top = vs_base + narg;

	if (fun == OBJNULL)
		FEerror("Undefined function.", 0);
	switch (type_of(fun)) {
	case t_cfun:
		MMcall(fun);
		break;

	case t_cclosure:
	{
		object *top, *base, l;

		if (fun->cc.cc_turbo != NULL) {
			MMccall(fun, fun->cc.cc_turbo);
			break;
		}
		top = vs_top;
		base = vs_base;
		for (l = fun->cc.cc_env;  !endp(l);  l = l->c.c_cdr)
			vs_push(l);
		vs_base = vs_top;
		while (base < top)
			vs_push(*base++);
		MMccall(fun, top);
		break;
	}

	default:
		funcall(fun);

	}
	vs_top = sup;
	CHECK_AVMA;
	return(vs_base[0]);
}

object
simple_symlispcall_no_event(sym, base, narg)
object sym, *base;
int narg;
{       DEBUG_AVMA
	object fun = symbol_function(sym);
	object *sup = vs_top;

	vs_base = base;
	vs_top = vs_base + narg;

	if (fun == OBJNULL)
		FEerror("Undefined function.", 0);
	switch (type_of(fun)) {
	case t_cfun:
		(*fun->cf.cf_self)();
		break;

	case t_cclosure:
	{
		object *top, *base, l;

		if (fun->cc.cc_turbo != NULL) {
			(*fun->cc.cc_self)(fun->cc.cc_turbo);
			break;
		}
		top = vs_top;
		base = vs_base;
		for (l = fun->cc.cc_env;  !endp(l);  l = l->c.c_cdr)
			vs_push(l);
		vs_base = vs_top;
		while (base < top)
			vs_push(*base++);
		(*fun->cc.cc_self)(top);
		break;
	}

	default:
		funcall(fun);
	}
	vs_top = sup;
	CHECK_AVMA;
	return(vs_base[0]);
}

super_funcall(fun)
object fun;
{
	if (type_of(fun) == t_symbol) {
		if (fun->s.s_sfdef != NOT_SPECIAL || fun->s.s_mflag)
			FEinvalid_function(fun);
		if (fun->s.s_gfdef == OBJNULL)
			FEundefined_function(fun);
		fun = fun->s.s_gfdef;
	}
	funcall(fun);
}

super_funcall_no_event(fun)
object fun;
{
#ifdef DEBUGGING_AVMA
  funcall_no_event(fun); return;
#endif 
   if (type_of(fun)==t_cfun){(*fun->cf.cf_self)();return;}
   if (type_of(fun)==t_sfun){call_sfun_no_check(fun); return;}
   if (type_of(fun)==t_gfun)
       {quick_call_sfun(fun); return;}
   if (type_of(fun)==t_vfun)
       {call_vfun(fun); return;}
   if (type_of(fun) == t_symbol) {
	  if (fun->s.s_sfdef != NOT_SPECIAL || fun->s.s_mflag)
			FEinvalid_function(fun);
		if (fun->s.s_gfdef == OBJNULL)
			FEundefined_function(fun);
		fun = fun->s.s_gfdef;
		if (type_of(fun)==t_cfun){(*fun->cf.cf_self)();
					  return;}
	}
	funcall_no_event(fun);
}

eval(form)
object form;
{       DEBUG_AVMA
	object fun, x;
	object *top;
	object *base;
	object orig_form;

	cs_check(form);

EVAL:

	vs_check;

	if (Vevalhook->s.s_dbind != Cnil && eval1 == 0)
	{
		bds_ptr old_bds_top = bds_top;
		object hookfun = symbol_value(Vevalhook);
		/*  check if Vevalhook is unbound  */

		bds_bind(Vevalhook, Cnil);
		vs_base = vs_top;
		vs_push(form);
		vs_push(lex_env[0]);
		vs_push(lex_env[1]);
		vs_push(lex_env[2]);
		vs_push(Cnil);
		stack_cons();
		stack_cons();
		stack_cons();
		super_funcall(hookfun);
		bds_unwind(old_bds_top);
		return;
	} else
		eval1 = 0;

	if (type_of(form) == t_cons)
		goto APPLICATION;

	if (type_of(form) != t_symbol) {
		vs_base = vs_top;
		vs_push(form);
		return;
	}

SYMBOL:
	switch (form->s.s_stype) {
	case stp_constant:
		vs_base = vs_top;
		vs_push(form->s.s_dbind);
		return;

	case stp_special:
		if(form->s.s_dbind == OBJNULL)
			FEunbound_variable(form);
		vs_base = vs_top;
		vs_push(form->s.s_dbind);
		return;

	default:
		/*  x = lex_var_sch(form);  */
		for (x = lex_env[0];  type_of(x) == t_cons;  x = x->c.c_cdr)
			if (x->c.c_car->c.c_car == form) {
				x = x->c.c_car->c.c_cdr;
				if (endp(x))
					break;
				vs_base = vs_top;
				vs_push(x->c.c_car);
				return;
			}
		if(form->s.s_dbind == OBJNULL)
			FEunbound_variable(form);
		vs_base = vs_top;
		vs_push(form->s.s_dbind);
		return;
	}

APPLICATION:
	/* Hook for possibly stopping at forms in the break point
	   list.  Also for stepping.  We only want to check
	   one form each time round, so we do *breakpoints*
	   */
	if (siSbreak_points->s.s_dbind != Cnil)
	  { if (siSbreak_step->s.s_dbind == Cnil ||
		ifuncall2(siSbreak_step->s.s_dbind,form,
			  list(3,lex_env[0],lex_env[1],lex_env[2])) == Cnil)
	      {object* bpts = siSbreak_points->s.s_dbind->v.v_self;
	       int i = siSbreak_points->s.s_dbind->v.v_fillp;
	       while (--i >= 0)
		 { if((*bpts)->c.c_car == form)
		     {ifuncall2(siSbreak_points->s.s_gfdef,form,
				list(3,lex_env[0],lex_env[1],lex_env[2]));

		      break;}
		   bpts++;}
	     }}
	
	fun = MMcar(form);
	if (type_of(fun) != t_symbol)
		goto LAMBDA;
	if (fun->s.s_sfdef != NOT_SPECIAL) {
		ihs_check;
		ihs_push(form);
		ihs_top->ihs_base = lex_env;
		(*fun->s.s_sfdef)(MMcdr(form));
		CHECK_AVMA;
		ihs_pop();
		return;
	}
	/*  x = lex_fd_sch(fun);  */
	for (x = lex_env[1];  type_of(x) == t_cons;  x = x->c.c_cdr)
		if (x->c.c_car->c.c_car == fun) {
			x = x->c.c_car;
			if (MMcadr(x) == Smacro) {
				x = MMcaddr(x);
				goto EVAL_MACRO;
			}
			x = MMcaddr(x);
			goto EVAL_ARGS;
		}

GFDEF:
	if ((x = fun->s.s_gfdef) == OBJNULL)
		FEundefined_function(fun);

	if (fun->s.s_mflag) {
	EVAL_MACRO:
		top = vs_top;
		macro_expand1(x, form);
		form = vs_base[0];
		vs_top = top;
		vs_push(form);
		goto EVAL;
	}

	  
	
EVAL_ARGS:
	vs_push(x);
	ihs_check;
	ihs_push(form);
	ihs_top->ihs_base = lex_env;
	form = form->c.c_cdr;
	base = vs_top;
	top = vs_top;
	while(!endp(form)) {
		eval(MMcar(form));
		top[0] = vs_base[0];
		vs_top = ++top;
		form = MMcdr(form);
	}
	vs_base = base;
	if (Vapplyhook->s.s_dbind != Cnil) {
		call_applyhook(fun);
		return;
	}
	ihs_top->ihs_function = x;
	ihs_top->ihs_base = vs_base;
	if (type_of(x) == t_cfun) 
	  (*(x)->cf.cf_self)();
	else
	  funcall_no_event(x);
	CHECK_AVMA;
	ihs_pop();
	return;

LAMBDA:
	if (type_of(fun) == t_cons && MMcar(fun) == Slambda) {
		temporary = make_cons(lex_env[2], fun->c.c_cdr);
		temporary = make_cons(lex_env[1], temporary);
		temporary = make_cons(lex_env[0], temporary);
		x = make_cons(Slambda_closure, temporary);
		vs_push(x);
		goto EVAL_ARGS;
	}
	FEinvalid_function(fun);
}	

call_applyhook(fun)
object fun;
{
	object ah;
	object *v;

	ah = symbol_value(Vapplyhook);
	v = vs_base + 1;
	vs_push(Cnil);
	while (vs_top > v)
		stack_cons();
	vs_push(vs_base[0]);
	vs_base[0] = fun;
	vs_push(lex_env[0]);
	vs_push(lex_env[1]);
	vs_push(lex_env[2]);
	vs_push(Cnil);
	stack_cons();
	stack_cons();
	stack_cons();
	super_funcall(ah);
}

Lfuncall()
{
	if (vs_top-vs_base < 1)
		too_few_arguments();
	vs_base++;
	super_funcall(vs_base[-1]);
}

Lapply()
{
	object lastarg;
	if (vs_top-vs_base < 2)
		too_few_arguments();
	lastarg = vs_pop;
	while (!endp(lastarg)) {
		vs_push(MMcar(lastarg));
		lastarg = MMcdr(lastarg);
	}
	vs_base++;
	super_funcall(vs_base[-1]);
}

Leval()
{
	object *lex = lex_env;

	check_arg(1);
	lex_new();
	eval(vs_base[0]);
	lex_env = lex;
}

Levalhook()
{
	object env;
	bds_ptr old_bds_top = bds_top;
	object *lex = lex_env;
	int n = vs_top - vs_base;

	lex_env = vs_top;
	if (n < 3)
		too_few_arguments();
	else if (n == 3) {
		*(struct nil3 *)vs_top = three_nils;
		vs_top += 3;
	} else if (n == 4) {
		env = vs_base[3];
		vs_push(car(env));
		env = cdr(env);
		vs_push(car(env));
		env = cdr(env);
		vs_push(car(env));
	} else
		too_many_arguments();
	bds_bind(Vevalhook, vs_base[1]);
	bds_bind(Vapplyhook, vs_base[2]);
	eval1 = 1;
	eval(vs_base[0]);
	lex_env = lex;
	bds_unwind(old_bds_top);
}

Lapplyhook()
{
	object env;
	bds_ptr old_bds_top = bds_top;
	object *lex = lex_env;
	int n = vs_top - vs_base;
	object l, *z;

	lex_env = vs_top;
	if (n < 4)
		too_few_arguments();
	else if (n == 4) {
		*(struct nil3 *)vs_top = three_nils;
		vs_top += 3;
	} else if (n == 5) {
		env = vs_base[4];
		vs_push(car(env));
		env = cdr(env);
		vs_push(car(env));
		env = cdr(env);
		vs_push(car(env));
	} else
		too_many_arguments();
	bds_bind(Vevalhook, vs_base[2]);
	bds_bind(Vapplyhook, vs_base[3]);
	z = vs_top;
	for (l = vs_base[1];  !endp(l);  l = l->c.c_cdr)
		vs_push(l->c.c_car);
	l = vs_base[0];
	vs_base = z;
	super_funcall(l);
	lex_env = lex;
	bds_unwind(old_bds_top);
}

Lconstantp()
{
	enum type x;
	check_arg(1);

	x = type_of(vs_base[0]);
	if(x == t_cons)
		if(vs_base[0]->c.c_car == Squote)
			vs_base[0] = Ct;
		else	vs_base[0] = Cnil;
	else if(x == t_symbol)
		if((enum stype)vs_base[0]->s.s_stype == stp_constant)
			vs_base[0] = Ct;
		else
			vs_base[0] = Cnil;
	else
			vs_base[0] = Ct;
}

object
ieval(x)
object x;
{
	object *old_vs_base;
	object *old_vs_top;

	old_vs_base = vs_base;
	old_vs_top = vs_top;
	eval(x);
	x = vs_base[0];
	vs_base = old_vs_base;
	vs_top = old_vs_top;
	return(x);
}

object
ifuncall1(fun, arg1)
object fun, arg1;
{
	object *old_vs_base;
	object *old_vs_top;
	object x;

	old_vs_base = vs_base;
	old_vs_top = vs_top;
	vs_base = vs_top;
	vs_push(arg1);
	super_funcall(fun);
	x = vs_base[0];
	vs_top = old_vs_top;
	vs_base = old_vs_base;
	return(x);
}

object
ifuncall2(fun, arg1, arg2)
object fun, arg1, arg2;
{
	object *old_vs_base;
	object *old_vs_top;
	object x;

	old_vs_base = vs_base;
	old_vs_top = vs_top;
	vs_base = vs_top;
	vs_push(arg1);
	vs_push(arg2);
	super_funcall(fun);
	x = vs_base[0];
	vs_top = old_vs_top;
	vs_base = old_vs_base;
	return(x);
}

object
ifuncall3(fun, arg1, arg2, arg3)
object fun, arg1, arg2, arg3;
{
	object *old_vs_base;
	object *old_vs_top;
	object x;

	old_vs_base = vs_base;
	old_vs_top = vs_top;
	vs_base = vs_top;
	vs_push(arg1);
	vs_push(arg2);
	vs_push(arg3);
	super_funcall(fun);
	x = vs_base[0];
	vs_top = old_vs_top;
	vs_base = old_vs_base;
	return(x);
}

funcall_with_catcher(fname, fun)
object fname, fun;
{
	int n = vs_top - vs_base;
	if (n > 64) n = 64;
	frs_push(FRS_CATCH, make_cons(fname, make_fixnum(n)));
	if (nlj_active)
		nlj_active = FALSE;
	else
		funcall(fun);
	frs_pop();
}

#include <varargs.h>

object 
fcalln_cclosure(ap)
va_list ap;
{int i=fcall.argd;
 {object *base=vs_top;
  DEBUG_AVMA
    vs_base=base;
    switch(i){
    case 10: *(base++)=va_arg(ap,object);
    case 9: *(base++)=va_arg(ap,object);
    case 8: *(base++)=va_arg(ap,object);
    case 7: *(base++)=va_arg(ap,object);
    case 6: *(base++)=va_arg(ap,object);
    case 5: *(base++)=va_arg(ap,object);
    case 4: *(base++)=va_arg(ap,object);
    case 3: *(base++)=va_arg(ap,object);
    case 2: *(base++)=va_arg(ap,object);
    case 1: *(base++)=va_arg(ap,object);
    case 0: break;
    default:
      FEerror(0,"bad args");
    } vs_top=base;
      base=base -i;
  	do{object fun=fcall.fun;
		object *top, *base, l;

		if (fun->cc.cc_turbo != NULL) {
			(*fun->cc.cc_self)(fun->cc.cc_turbo);
			break;
		}
		top = vs_top;
		base = vs_base;
		for (l = fun->cc.cc_env;  !endp(l);  l = l->c.c_cdr)
			vs_push(l);
		vs_base = vs_top;
		while (base < top)
			vs_push(*base++);
		(*fcall.fun->cc.cc_self)(top);
		break;
	}while (0);
       vs_top=base;
       CHECK_AVMA;
       return(vs_base[0]);
}}

object 
fcalln_general(ap)
va_list ap;
{int i=fcall.argd;
 object fun=fcall.fun;
 {int n= SFUN_NARGS(i);
  /*  object *old_vs_base=vs_base; */
  object *old_vs_top=vs_top;
  object x;
  enum ftype typ,restype=SFUN_RETURN_TYPE(i);
  vs_top =  vs_base = old_vs_top;
  SFUN_START_ARG_TYPES(i);
  if (i==0)
    while (n-- > 0)
      { typ= SFUN_NEXT_TYPE(i);
	x =
	  (typ==f_object ?	va_arg(ap,object):
	   typ==f_fixnum ? make_fixnum(va_arg(ap,fixnum)):
	   (object) FEerror("bad type",0));
	*(vs_top++) = x;}
  else
    {object *base=vs_top;
     while (n-- > 0)
       { *(base++) = va_arg(ap,object);}
     vs_top=base;}
  funcall(fcall.fun);
  x= vs_base[0];
  vs_top=old_vs_top;
  /* vs_base=old_vs_base; */
  return (restype== f_object ? x :
	  restype== f_fixnum ? (object) (fix(x)):
	  (object) FEerror("bad type",0));
}}
object
fcalln_vfun(vl)
  va_list vl;
{object *new,res;
 DEBUG_AVMA
 COERCE_VA_LIST(new,vl,fcall.argd);
 res = c_apply_n(fcall.fun->vfn.vfn_self,fcall.argd,new);
 CHECK_AVMA;
 return res; 
}

object 
fcalln(va_alist)
va_dcl
{  va_list ap;
   object fun=fcall.fun;
   DEBUG_AVMA
   va_start(ap);
   if(type_of(fun)==t_cfun)
     {object *base=vs_top;
      int i=fcall.argd;
      vs_base=base;
      switch(i){
      case 10: *(base++)=va_arg(ap,object);
      case 9: *(base++)=va_arg(ap,object);
      case 8: *(base++)=va_arg(ap,object);
      case 7: *(base++)=va_arg(ap,object);
      case 6: *(base++)=va_arg(ap,object);
      case 5: *(base++)=va_arg(ap,object);
      case 4: *(base++)=va_arg(ap,object);
      case 3: *(base++)=va_arg(ap,object);
      case 2: *(base++)=va_arg(ap,object);
      case 1: *(base++)=va_arg(ap,object);
      case 0: break;
      default:
	FEerror(0,"bad args");
      }  vs_top=base;
      base=base -i;
      (*fcall.fun->cf.cf_self)();
      vs_top=base;
      CHECK_AVMA;
      return(vs_base[0]);
    }
   if(type_of(fun)==t_cclosure)
     return(fcalln_cclosure(ap));
   if(type_of(fun)==t_vfun)
     return(fcalln_vfun(ap));
   return(fcalln_general(ap));
  va_end(ap);
 }

/* call a cfun eg funcall_cfun(Lmake_hash_table,2,Ktest,Seq) */
typedef void (*funcvoid)();

object
funcall_cfun(fn,n,va_alist)
     int n;
     funcvoid fn;
     va_dcl
{object *old_top = vs_top;
 object *old_base= vs_base;
 object result;
 va_list ap;
 DEBUG_AVMA
 vs_base=vs_top;
 va_start(ap);
 while(n-->0) vs_push(va_arg(ap,object));
 va_end(ap);
 (*fn)();
 if(vs_top>vs_base) result=vs_base[0];
 else result=Cnil;
 vs_top=old_top;
 vs_base=old_base;
 CHECK_AVMA;
 return result;}
 

init_eval()
{

        make_constant("CALL-ARGUMENTS-LIMIT", make_fixnum(64));

	Sapply = make_function("APPLY", Lapply);
	enter_mark_origin(&Sapply);
	Sfuncall = make_function("FUNCALL", Lfuncall);
	enter_mark_origin(&Sfuncall);

	Vevalhook = make_special("*EVALHOOK*", Cnil);
	Vapplyhook = make_special("*APPLYHOOK*", Cnil);

	temporary = Cnil;
	enter_mark_origin(&temporary);

	three_nils.nil3_self[0] = Cnil;
	three_nils.nil3_self[1] = Cnil;
	three_nils.nil3_self[2] = Cnil;

	make_function("EVAL", Leval);
	make_function("EVALHOOK", Levalhook);
	make_function("APPLYHOOK", Lapplyhook);
	siSlambda_block_expanded=make_si_special("LAMBDA-BLOCK-EXPANDED",Cnil);
	make_function("CONSTANTP", Lconstantp);
	siSbreak_points = make_si_special("*BREAK-POINTS*",Cnil);
	siSbreak_step = make_si_special("*BREAK-STEP*",Cnil);

	
}
