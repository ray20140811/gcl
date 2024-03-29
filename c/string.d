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
	string.d

	string routines
*/

#include "include.h"

object Kstart1;
object Kend1;
object Kstart2;
object Kend2;
object Kinitial_element;

object
alloc_simple_string(l)
int l;
{
	object x;

	x = alloc_object(t_string);
	x->st.st_hasfillp = FALSE;
	x->st.st_adjustable = FALSE;
	x->st.st_displaced = Cnil;
	x->st.st_dim = x->st.st_fillp = l;
	x->st.st_self = NULL;
	return(x);
}

/*
	Make_simple_string(s) makes a simple string from C string s.
*/
object
make_simple_string(s)
char *s;
{
	int l, i;
	char *p;
	object x;
	vs_mark;

	for (l = 0;  s[l] != '\0';  l++)
		;
	x = alloc_simple_string(l);
	vs_push(x);
	p = alloc_relblock(l);
	for (i = 0;  i < l;  i++)
		p[i] = s[i];
	x->st.st_self = p;
	vs_reset;
	return(x);
}

/*
	This correponds to string= (just the string equality).
*/
bool
string_eq(x, y)
object x, y;
{
	int i, j;

/*
	if (type_of(x) != t_string || type_of(y) != t_string)
		error("string expected");
*/
	i = x->st.st_fillp;
	j = y->st.st_fillp;
	if (i != j)
		return(FALSE);
	for (i = 0;  i < j;  i++)
		if (x->st.st_self[i] != y->st.st_self[i])
			return(FALSE);
	return(TRUE);
}

/*
	This corresponds to string-equal
	(string equality ignoring the case).
*/
bool
string_equal(x, y)
object x, y;
{
	int i, j;
	char *p, *q;

/*
	if (type_of(x) != t_string || type_of(y) != t_string)
		error("string expected");
*/
	i = x->st.st_fillp;
	j = y->st.st_fillp;
	if (i != j)
		return(FALSE);
	p = x->st.st_self;
	q = y->st.st_self;
	for (i = 0;  i < j;  i++)
		if ((isLower(p[i]) ? p[i] - ('a' - 'A') : p[i])
		 != (isLower(q[i]) ? q[i] - ('a' - 'A') : q[i]))
			return(FALSE);
	return(TRUE);
}

/*
	Copy_simple_string(x) copies string x to a simple string.
*/
object
copy_simple_string(x)
object x;
{
	object y;
	int i;
	vs_mark;

	vs_push(x);
/*
	if (type_of(x) != t_string)
		error("string expected");
*/
	y = alloc_object(t_string);
	y->st.st_dim = y->st.st_fillp = x->st.st_fillp;
	y->st.st_hasfillp = FALSE;
	y->st.st_adjustable = FALSE;
	y->st.st_displaced = Cnil;
	y->st.st_self = NULL;
	vs_push(y);
	y->st.st_self = alloc_relblock(x->st.st_fillp);
	for (i = 0;  i < x->st.st_fillp;  i++)
		y->st.st_self[i] = x->st.st_self[i];
	vs_reset;
	return(y);
}

object
coerce_to_string(x)
object x;
{
	object y;
	int i;
	vs_mark;

	switch (type_of(x)) {
	case t_symbol:
		y = alloc_simple_string(x->s.s_fillp);
		vs_push(y);
		if (x->s.s_self < heap_end)
			y->st.st_self = x->s.s_self;
		else {
			y->st.st_self = alloc_relblock(x->s.s_fillp);
			for (i = 0;  i < x->s.s_fillp;  i++)
				y->st.st_self[i] = x->s.s_self[i];
		}
		vs_reset;
		return(y);

	case t_fixnum:
		x = coerce_to_character(x);
		vs_push(x);

	case t_character:
		y = alloc_simple_string(1);
		vs_push(y);
		y->st.st_self = alloc_relblock(1);
		y->st.st_self[0] = char_code(x);
		vs_reset;
		return(y);

	case t_string:
		return(x);
	}
	FEerror("~S cannot be coerced to a string.", 1, x);
}

@(defun char (s i)
	int j;
@
	check_type_string(&s);
	if (type_of(i) != t_fixnum)
		illegal_index(s, i);
	if ((j = fix(i)) < 0 || j >= s->st.st_fillp)
		illegal_index(s, i);
	@(return `code_char(s->ust.ust_self[j])`)
@)

siLchar_set()
{
	int j;

	check_arg(3);
	check_type_string(&vs_base[0]);
	if (type_of(vs_base[1]) != t_fixnum)
		illegal_index(vs_base[0], vs_base[1]);
	if ((j = fix(vs_base[1])) < 0 || j >= vs_base[0]->st.st_fillp)
		illegal_index(vs_base[0], vs_base[1]);
	check_type_character(&vs_base[2]);
	vs_base[0]->st.st_self[j] = char_code(vs_base[2]);
	vs_base += 2;
}

get_string_start_end(string, start, end, ps, pe)
object string, start, end;
int *ps, *pe;
{
	if (start == Cnil)
		*ps = 0;
	else if (type_of(start) != t_fixnum)
		goto E;
	else {
		*ps = fix(start);
		if (*ps < 0)
			goto E;
	}
	if (end == Cnil) {
		*pe = string->st.st_fillp;
		if (*pe < *ps)
			goto E;
	} else if (type_of(end) != t_fixnum)
		goto E;
	else {
		*pe = fix(end);
		if (*pe < *ps || *pe > string->st.st_fillp)
			goto E;
	}
	return;

E:
	FEerror("~S and ~S are illegal as :START and :END~%\
for the string ~S.", 3, start, end, string);
}

@(defun string_eq (string1 string2
		   &key start1 end1 start2 end2)
	int s1, e1, s2, e2;
@
	string1 = coerce_to_string(string1);
	string2 = coerce_to_string(string2);
	get_string_start_end(string1, start1, end1, &s1, &e1);
	get_string_start_end(string2, start2, end2, &s2, &e2);
	if (e1 - s1 != e2 - s2)
		@(return Cnil)
	while (s1 < e1)
		if (string1->st.st_self[s1++] !=
		    string2->st.st_self[s2++])
			@(return Cnil)
	@(return Ct)
@)

@(defun string_equal (string1 string2
		      &key start1 end1 start2 end2)
	int s1, e1, s2, e2;
	int i1, i2;
@
	string1 = coerce_to_string(string1);
	string2 = coerce_to_string(string2);
	get_string_start_end(string1, start1, end1, &s1, &e1);
	get_string_start_end(string2, start2, end2, &s2, &e2);
	if (e1 - s1 != e2 - s2)
		@(return Cnil)
	while (s1 < e1) {
		i1 = string1->st.st_self[s1++];
		i2 = string2->st.st_self[s2++];
		if (isLower(i1))
			i1 -= 'a' - 'A';
		if (isLower(i2))
			i2 -= 'a' - 'A';
		if (i1 != i2)
			@(return Cnil)
	}
	@(return Ct)
@)


static int sign, boundary;

@(defun string_cmp (string1 string2
		    &key start1 end1 start2 end2)
	int s1, e1, s2, e2;
	int i1, i2;
	int s;
@
	string1 = coerce_to_string(string1);
	string2 = coerce_to_string(string2);
	get_string_start_end(string1, start1, end1, &s1, &e1);
	get_string_start_end(string2, start2, end2, &s2, &e2);
	while (s1 < e1) {
		if (s2 == e2)
			@(return `sign>0 ? Cnil : make_fixnum(s1)`)
		i1 = string1->ust.ust_self[s1];
		i2 = string2->ust.ust_self[s2];
		if (sign == 0) {
			if (i1 != i2)
				@(return `make_fixnum(s1)`)
		} else {
			s = sign*(i2-i1);
			if (s > 0)
				@(return `make_fixnum(s1)`)
			if (s < 0)
				@(return Cnil)
		}
		s1++;
		s2++;
	}
	if (s2 == e2)
		@(return `boundary==0 ? make_fixnum(s1) : Cnil`)
	@(return `sign>=0 ? make_fixnum(s1) : Cnil`)
@)

Lstring_l()  { sign =  1;  boundary = 1;  Lstring_cmp(); }
Lstring_g()  { sign = -1;  boundary = 1;  Lstring_cmp(); }
Lstring_le() { sign =  1;  boundary = 0;  Lstring_cmp(); }
Lstring_ge() { sign = -1;  boundary = 0;  Lstring_cmp(); }
Lstring_neq() { sign = 0;  boundary = 1;  Lstring_cmp(); }

@(defun string_compare (string1 string2
			&key start1 end1 start2 end2)
	int s1, e1, s2, e2;
	int i1, i2;
	int s;
@
	string1 = coerce_to_string(string1);
	string2 = coerce_to_string(string2);
	get_string_start_end(string1, start1, end1, &s1, &e1);
	get_string_start_end(string2, start2, end2, &s2, &e2);
	while (s1 < e1) {
		if (s2 == e2)
			@(return `sign>0 ? Cnil : make_fixnum(s1)`)
		i1 = string1->ust.ust_self[s1];
		if (isLower(i1))
			i1 -= 'a' - 'A';
		i2 = string2->ust.ust_self[s2];
		if (isLower(i2))
			i2 -= 'a' - 'A';
		if (sign == 0) {
			if (i1 != i2)
				@(return `make_fixnum(s1)`)
		} else {
			s = sign*(i2-i1);
			if (s > 0)
				@(return `make_fixnum(s1)`)
			if (s < 0)
				@(return Cnil)
		}
		s1++;
		s2++;
	}
	if (s2 == e2)
		@(return `boundary==0 ? make_fixnum(s1) : Cnil`)
	@(return `sign>=0 ? make_fixnum(s1) : Cnil`)
@)

Lstring_lessp()         { sign =  1; boundary = 1;  Lstring_compare(); }
Lstring_greaterp()      { sign = -1; boundary = 1;  Lstring_compare(); }
Lstring_not_greaterp()  { sign =  1; boundary = 0;  Lstring_compare(); }
Lstring_not_lessp()     { sign = -1; boundary = 0;  Lstring_compare(); }
Lstring_not_equal()	{ sign =  0; boundary = 1;  Lstring_compare(); }


@(defun make_string (size
		     &key (initial_element `code_char(' ')`)
		     &aux x)
	int i;
@
	while (type_of(size) != t_fixnum || fix(size) < 0)
		size
		= wrong_type_argument(TSnon_negative_integer, size);
		/*  bignum not allowed, this is PRACTICAL!!  */
	while (type_of(initial_element) != t_character ||
	       char_bits(initial_element) != 0 ||
	       char_font(initial_element) != 0)
		initial_element
		= wrong_type_argument(Sstring_char, initial_element);
	x = alloc_simple_string(fix(size));
	x->st.st_self = alloc_relblock(fix(size));
	for (i = 0;  i < fix(size);  i++)
		x->st.st_self[i] = char_code(initial_element);
	@(return x)
@)

bool
member_char(c, char_bag)
int c;
object char_bag;
{
	int i, f;

	switch (type_of(char_bag)) {
	case t_symbol:
	case t_cons:
		while (!endp(char_bag)) {
			if (type_of(char_bag->c.c_car) == t_character
 			    &&	c == char_code(char_bag->c.c_car))
				return(TRUE);
			char_bag = char_bag->c.c_cdr;
		}
		return(FALSE);

	case t_vector:
		for (i = 0, f = char_bag->v.v_fillp;  i < f;  i++) {
			if (type_of(char_bag->v.v_self[i]) != t_character
			  && c == char_code(char_bag->v.v_self[i]))
				return(TRUE);
		}
		return(FALSE);

	case t_string:
		for (i = 0, f = char_bag->st.st_fillp;  i < f;  i++) {
			if (c == char_bag->st.st_self[i])
				return(TRUE);
		}
		return(FALSE);

	case t_bitvector:
		return(FALSE);

	default:
		FEerror("~S is not a sequence.", 1, char_bag);
	}
}

static bool left_trim;
static bool right_trim;

Lstring_trim() { left_trim = right_trim = TRUE; Lstring_trim0(); }
Lstring_left_trim() { left_trim = TRUE; right_trim = FALSE; Lstring_trim0(); }
Lstring_right_trim() { left_trim = FALSE; right_trim = TRUE; Lstring_trim0();}

@(defun string_trim0 (char_bag strng &aux res)
	int i, j, k;
@
	strng = coerce_to_string(strng);
	i = 0;
	j = strng->st.st_fillp - 1;
	if (left_trim)
		for (;  i <= j;  i++)
			if (!member_char(strng->st.st_self[i], char_bag))
				break;
	if (right_trim)
		for (;  j >= i;  --j)
			if (!member_char(strng->st.st_self[j], char_bag))
				break;
	k = j - i + 1;
	res = alloc_simple_string(k);
	res->st.st_self = alloc_relblock(k);
	for (j = 0;  j < k;  j++)
		res->st.st_self[j] = strng->st.st_self[i + j];
	@(return res)
@)

static char_upcase(c, bp)
int c, *bp;
{
	if (isLower(c))
		return(c - ('a' - 'A'));
	else
		return(c);
}

static char_downcase(c, bp)
int c, *bp;
{
	if (isUpper(c))
		return(c + ('a' - 'A'));
	else
		return(c);
}

static char_capitalize(c, bp)
int c, *bp;
{
	if (isLower(c)) {
		if (*bp)
			c -= 'a' - 'A';
		*bp = FALSE;
	} else if (isUpper(c)) {
		if (!*bp)
			c += 'a' - 'A';
		*bp = FALSE;
	} else if (!isDigit(c))
		*bp = TRUE;
	return(c);
}

static (*casefun)();


@(defun string_case (strng &key start end &aux conv)
	int s, e, i;
	bool b;
@
	strng = coerce_to_string(strng);
	get_string_start_end(strng, start, end, &s, &e);
	conv = copy_simple_string(strng);
	b = TRUE;
	for (i = s;  i < e;  i++)
		conv->st.st_self[i] =
		(*casefun)(conv->st.st_self[i], &b);
	@(return conv)
@)

Lstring_upcase()     { casefun =     char_upcase;  Lstring_case(); }
Lstring_downcase()   { casefun =   char_downcase;  Lstring_case(); }
Lstring_capitalize() { casefun = char_capitalize;  Lstring_case(); }


@(defun nstring_case (strng &key start end)
	int s, e, i;
	bool b;
@
	check_type_string(&strng);
	get_string_start_end(strng, start, end, &s, &e);
	b = TRUE;
	for (i = s;  i < e;  i++)
		strng->st.st_self[i] =
		(*casefun)(strng->st.st_self[i], &b);
	@(return strng)
@)

Lnstring_upcase()     { casefun =     char_upcase;  Lnstring_case(); }
Lnstring_downcase()   { casefun =   char_downcase;  Lnstring_case(); }
Lnstring_capitalize() { casefun = char_capitalize;  Lnstring_case(); }


@(defun string (x)
@
	@(return `coerce_to_string(x)`)
@)

siLstring_concatenate()
{
	int narg, i, l, m;
	object *v;

	narg = vs_top - vs_base;
	for (i = 0, l = 0;  i < narg;  i++) {
		vs_base[i] = coerce_to_string(vs_base[i]);
		l += vs_base[i]->st.st_fillp;
	}
	v = vs_top;
	vs_push(alloc_simple_string(l));
	(*v)->st.st_self = alloc_relblock(l);
	for (i = 0, l = 0;  i < narg;  i++)
		for (m = 0;  m < vs_base[i]->st.st_fillp;  m++)
			(*v)->st.st_self[l++]
			= vs_base[i]->st.st_self[m];
	vs_base[0] = *v;
	vs_top = vs_base + 1;
}

init_string_function()
{
	Kstart1 = make_keyword("START1");
	Kend1 = make_keyword("END1");
	Kstart2 = make_keyword("START2");
	Kend2 = make_keyword("END2");
	Kinitial_element = make_keyword("INITIAL-ELEMENT");
	Kstart = make_keyword("START");
	Kend = make_keyword("END");

	make_function("CHAR", Lchar);
	make_si_function("CHAR-SET", siLchar_set);
	make_function("SCHAR", Lchar);
	make_si_function("SCHAR-SET", siLchar_set);
	make_function("STRING=", Lstring_eq);
	make_function("STRING-EQUAL", Lstring_equal);
	make_function("STRING<", Lstring_l);
	make_function("STRING>", Lstring_g);
	make_function("STRING<=", Lstring_le);
	make_function("STRING>=", Lstring_ge);
	make_function("STRING/=", Lstring_neq);
	make_function("STRING-LESSP", Lstring_lessp);
	make_function("STRING-GREATERP", Lstring_greaterp);
	make_function("STRING-NOT-LESSP", Lstring_not_lessp);
	make_function("STRING-NOT-GREATERP", Lstring_not_greaterp);
	make_function("STRING-NOT-EQUAL", Lstring_not_equal);
	make_function("MAKE-STRING", Lmake_string);
	make_function("STRING-TRIM", Lstring_trim);
	make_function("STRING-LEFT-TRIM", Lstring_left_trim);
	make_function("STRING-RIGHT-TRIM", Lstring_right_trim);
	make_function("STRING-UPCASE", Lstring_upcase);
	make_function("STRING-DOWNCASE", Lstring_downcase);
	make_function("STRING-CAPITALIZE", Lstring_capitalize);
	make_function("NSTRING-UPCASE", Lnstring_upcase);
	make_function("NSTRING-DOWNCASE", Lnstring_downcase);
	make_function("NSTRING-CAPITALIZE", Lnstring_capitalize);
	make_function("STRING", Lstring);

	make_si_function("STRING-CONCATENATE",
			 siLstring_concatenate);
}
