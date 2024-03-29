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
#include "mp.h"

object Seq;
object Seql;
object Sequal;

object Ksize;
object Krehash_size;
object Krehash_threshold;


unsigned int
hash_eql(x)
object x;
{
	unsigned int h = 0;

	switch (type_of(x)) {
	case t_fixnum:
		return(fix(x));

	case t_bignum:
		{ GEN u = MP(x);
		  int l = lg(u) - 2;
		  u += 2;
		  h += l;
		  if (l > 5) l = 5;
		  while (-- l >= 0)
		    { h += *u++;}
		  return(h);
		}

	case t_ratio:
   		return(hash_eql(x->rat.rat_num) + hash_eql(x->rat.rat_den));

	case t_shortfloat:
		return(*((int *) &(sf(x))));

	case t_longfloat:
		{int *y = (int *) &lf(x);
		return( *y + *(y+1));}

	case t_complex:
		return(hash_eql(x->cmp.cmp_real) + hash_eql(x->cmp.cmp_imag));

	case t_character:
		return(char_code(x));

	default:
		return((unsigned int)x / 4);
	}
}

unsigned int
hash_equal(x,depth)
object x;
int depth;
{
	unsigned int h = 0;
	int i;
	char *s;

	cs_check(x);

BEGIN:
	if (depth++ >3) return h;
	switch (type_of(x)) {
	case t_cons:
		h += hash_equal(x->c.c_car,depth);
		x = x->c.c_cdr;
		goto BEGIN;

	case t_string:
		for (i = x->st.st_fillp, s = x->st.st_self;  i > 0;  --i, s++)
			h += (*s & 0377)*12345 + 1;
		return(h);
	case t_symbol:
		/* case t_string could share this code--wfs */
		{int len=x->st.st_fillp;
		 s=x->st.st_self;
		 switch(len) {
		 case 0: break;
		 default:
		 case 4: h+= s[--len] << 24;
		 case 3: h+= s[--len]<< 16;
		 case 2: h+= s[1] << 8;
		 case 1: h+= s[0] ;
		   
		   
		 }
		 return(h);
	       }
		   
        case t_package:  return h;
	case t_bitvector:
        {static char ar[10];
	 i = x->bv.bv_fillp;
	 h = h + i;
	 i = i/8;
	 if (i > 10) i= 10;
	 s = x->bv.bv_self;
	 if (x->bv.bv_offset)
	   {int k,j;
	    int e = i;
	    s = ar;
	    /* 8 should be CHAR_SIZE but this needs to be changed
	       everywhere .. */
	    e = e * 8;
	    bzero(ar,sizeof(ar));
	    for (k = x->bv.bv_offset, j = 0;  k < e;  k++, j++)
	      if (x->bv.bv_self[k/8]&(0200>>k%8))
		ar[j/8]  |= 0200>>j%8;
	  }
	 for (;  i > 0;  --i, s++)
	   h += (*s & 0377)*12345 + 1;

	 return(h);
       }
	case t_pathname:
		h += hash_equal(x->pn.pn_host,depth);
		h += hash_equal(x->pn.pn_device,depth);
		h += hash_equal(x->pn.pn_directory,depth);
		h += hash_equal(x->pn.pn_name,depth);
		h += hash_equal(x->pn.pn_type,depth);
		h += hash_equal(x->pn.pn_version,depth);
		return(h);
/*  CLTLII says don't descend into structures
	case t_structure:
		{unsigned char *s_type;
		 struct s_data *def;
		 def=S_DATA(x->str.str_def);
		 s_type= & SLOT_TYPE(x->str.str_def,0);
		 h += hash_equal(def->name,depth);
		 for (i = 0;  i < def->length;  i++)
		   if (s_type[i]==0)
		     h += hash_equal(x->str.str_self[i],depth);
		   else
		     h += ((int)x->str.str_self[i]) + depth++;
		 return(h);}
*/

	default:
		return(h + hash_eql(x));
	}
}
		
struct htent *
gethash(key, hashtable)
object key;
object hashtable;
{
	enum httest htest;
	int hsize;
	struct htent *e;
	object hkey;
	int i, j = -1, k; /* k added by chou */
	bool b;

	htest = (enum httest)hashtable->ht.ht_test;
	hsize = hashtable->ht.ht_size;
	if (htest == htt_eq)
		i = (int)key / 4;
	else if (htest == htt_eql)
		i = hash_eql(key);
	else if (htest == htt_equal)
		i = hash_equal(key,0);
	i &= 0x7fffffff;
	for (i %= hsize, k = 0; k < hsize;  i = (i + 1) % hsize, k++) { /* k added by chou */
		e = &hashtable->ht.ht_self[i];
		hkey = e->hte_key;
		if (hkey == OBJNULL) {
			if (e->hte_value == OBJNULL)
				if (j < 0)
					return(e);
				else
					return(&hashtable->ht.ht_self[j]);
			else
				if (j < 0)
					j = i;
				else if (j==i)
				  /* this was never returning --wfs
				     but looping around with j=0 */
				  return(e) 
					;
			continue;
		}
		if (htest == htt_eq)
		    	b = key == hkey;
		else if (htest == htt_eql)
			b = eql(key, hkey);
		else if (htest == htt_equal)
			b = equal(key, hkey);
		if (b)
			return(&hashtable->ht.ht_self[i]);
	}
	return(&hashtable->ht.ht_self[j]);	/* added by chou */
}

sethash(key, hashtable, value)
object key, hashtable, value;
{
	int i;
	bool over;
	struct htent *e;
	
	i = hashtable->ht.ht_nent + 1;
	if (type_of(hashtable->ht.ht_rhthresh) == t_fixnum)
		over = i >= fix(hashtable->ht.ht_rhthresh);
	else if (type_of(hashtable->ht.ht_rhthresh) == t_shortfloat)
		over =
		i >= hashtable->ht.ht_size * sf(hashtable->ht.ht_rhthresh);
	else if (type_of(hashtable->ht.ht_rhthresh) == t_longfloat)
		over =
		i >= hashtable->ht.ht_size * lf(hashtable->ht.ht_rhthresh);
	if (over)
		extend_hashtable(hashtable);
	e = gethash(key, hashtable);
	if (e->hte_key == OBJNULL)
		hashtable->ht.ht_nent++;
	e->hte_key = key;
	e->hte_value = value;
}
	
extend_hashtable(hashtable)
object hashtable;
{
	object old;
	int new_size, i;

	if (type_of(hashtable->ht.ht_rhsize) == t_fixnum)
		new_size = 
		hashtable->ht.ht_size + fix(hashtable->ht.ht_rhsize);
	else if (type_of(hashtable->ht.ht_rhsize) == t_shortfloat)
		new_size = 
		hashtable->ht.ht_size * sf(hashtable->ht.ht_rhsize);
	else if (type_of(hashtable->ht.ht_rhsize) == t_longfloat)
		new_size = 
		hashtable->ht.ht_size * lf(hashtable->ht.ht_rhsize);
	old = alloc_object(t_hashtable);
	old->ht = hashtable->ht;
	vs_push(old);
	hashtable->ht.ht_self = NULL;
	hashtable->ht.ht_size = new_size;
	if (type_of(hashtable->ht.ht_rhthresh) == t_fixnum)
		hashtable->ht.ht_rhthresh =
		make_fixnum(fix(hashtable->ht.ht_rhthresh) +
			    (new_size - old->ht.ht_size));
	hashtable->ht.ht_self =
	(struct htent *)alloc_relblock(new_size * sizeof(struct htent));
	for (i = 0;  i < new_size;  i++) {
		hashtable->ht.ht_self[i].hte_key = OBJNULL;
		hashtable->ht.ht_self[i].hte_value = OBJNULL;
	}
	for (i = 0;  i < old->ht.ht_size;  i++) {
		if (old->ht.ht_self[i].hte_key != OBJNULL)
			sethash(old->ht.ht_self[i].hte_key,
				hashtable,
				old->ht.ht_self[i].hte_value);
	}
	hashtable->ht.ht_nent = old->ht.ht_nent;
	vs_pop;
}


@(defun make_hash_table (&key (test Seql)
			      (size `make_fixnum(1024)`)
			      (rehash_size
			       `make_shortfloat((shortfloat)1.5)`)
			      (rehash_threshold
			       `make_shortfloat((shortfloat)0.7)`)
			 &aux h)
	enum httest htt;
	int i;
@
	if (test == Seq || test == Seq->s.s_gfdef)
		htt = htt_eq;
	else if (test == Seql || test == Seql->s.s_gfdef)
		htt = htt_eql;
	else if (test == Sequal || test == Sequal->s.s_gfdef)
		htt = htt_equal;
	else
		FEerror("~S is an illegal hash-table test function.",
			1, test);
  	if (type_of(size) != t_fixnum || 0 < fix(size))
		;
	else
		FEerror("~S is an illegal hash-table size.", 1, size);
	if (type_of(rehash_size) == t_fixnum && 0 < fix(rehash_size) ||
	    type_of(rehash_size) == t_shortfloat && 1.0 < sf(rehash_size) ||
	    type_of(rehash_size) == t_longfloat && 1.0 < lf(rehash_size))
		;
	else
		FEerror("~S is an illegal hash-table rehash-size.",
			1, rehash_size);
	if (type_of(rehash_threshold) == t_fixnum &&
	    0 < fix(rehash_threshold) && fix(rehash_threshold) < fix(size) ||
	    type_of(rehash_threshold) == t_shortfloat &&
	    0.0 < sf(rehash_threshold) && sf(rehash_threshold) < 1.0 ||
	    type_of(rehash_threshold) == t_longfloat &&
	    0.0 < lf(rehash_threshold) && lf(rehash_threshold) < 1.0)
		;
	else
		FEerror("~S is an illegal hash-table rehash-threshold.",
			1, rehash_threshold);
	h = alloc_object(t_hashtable);
	h->ht.ht_test = (short)htt;
	h->ht.ht_size = fix(size);
	h->ht.ht_rhsize = rehash_size;
	h->ht.ht_rhthresh = rehash_threshold;
        h->ht.ht_nent = 0;
	h->ht.ht_self = NULL;
	h->ht.ht_self = (struct htent *)
	alloc_relblock(fix(size) * sizeof(struct htent));
	for(i = 0;  i < fix(size);  i++) {
		h->ht.ht_self[i].hte_key = OBJNULL;
		h->ht.ht_self[i].hte_value = OBJNULL;
	}
	@(return h)
@)

Lhash_table_p()
{
	check_arg(1);

	if(type_of(vs_base[0]) == t_hashtable)
		vs_base[0] = Ct;
	else   
		vs_base[0] = Cnil;
}

Lgethash()
{
	int narg;
	struct htent *e;
	
	narg = vs_top - vs_base;
	if (narg < 2)
		too_few_arguments();
	else if (narg == 2)
		vs_push(Cnil);
	else if (narg > 3)
		too_many_arguments();
	check_type_hash_table(&vs_base[1]);
	e = gethash(vs_base[0], vs_base[1]);
	if (e->hte_key != OBJNULL) {
		vs_base[0] = e->hte_value;
		vs_base[1] = Ct;
	} else {
		vs_base[0] = vs_base[2];
		vs_base[1] = Cnil;
	}
	vs_pop;
}

siLhash_set()
{
	check_arg(3);

	check_type_hash_table(&vs_base[1]);
	sethash(vs_base[0], vs_base[1], vs_base[2]);
	vs_base += 2;
}
	
Lremhash()
{
	struct htent *e;

	check_arg(2);
	check_type_hash_table(&vs_base[1]);
	e = gethash(vs_base[0], vs_base[1]);
	if (e->hte_key != OBJNULL) {
		e->hte_key = OBJNULL;
		e->hte_value = Cnil;
		vs_base[1]->ht.ht_nent--;
		vs_base[0] = Ct;
	} else
		vs_base[0] = Cnil;
	vs_top = vs_base + 1;
}

Lclrhash()
{
	int i;

	check_arg(1);
	check_type_hash_table(&vs_base[0]);
	for(i = 0; i < vs_base[0]->ht.ht_size; i++) {
		vs_base[0]->ht.ht_self[i].hte_key = OBJNULL;
		vs_base[0]->ht.ht_self[i].hte_value = OBJNULL;
	}
	vs_base[0]->ht.ht_nent = 0;
}

Lhash_table_count()
{
	object z;

	check_arg(1);
	check_type_hash_table(&vs_base[0]);
	vs_base[0] = make_fixnum(vs_base[0]->ht.ht_nent);
}


Lsxhash()
{
	check_arg(1);

	vs_base[0] = make_fixnum(hash_equal(vs_base[0],0) & 0x7fffffff);
}

Lmaphash()
{
	object *base = vs_base;
        object hashtable;
	int i;

	check_arg(2);
	check_type_hash_table(&vs_base[1]);
	hashtable = vs_base[1];
	for (i = 0;  i < hashtable->ht.ht_size;  i++) {
		if(hashtable->ht.ht_self[i].hte_key != OBJNULL)
			ifuncall2(base[0],
				  hashtable->ht.ht_self[i].hte_key,
				  hashtable->ht.ht_self[i].hte_value);
	}
	vs_base[0] = Cnil;
	vs_pop;
}


init_hash()
{
	Seq = make_ordinary("EQ");
	Seql = make_ordinary("EQL");
	Sequal = make_ordinary("EQUAL");
	Ksize = make_keyword("SIZE");
	Ktest = make_keyword("TEST");
	Krehash_size = make_keyword("REHASH-SIZE");
	Krehash_threshold = make_keyword("REHASH-THRESHOLD");
	
	make_function("MAKE-HASH-TABLE", Lmake_hash_table);
	make_function("HASH-TABLE-P", Lhash_table_p);
	make_function("GETHASH", Lgethash);
	make_function("REMHASH", Lremhash);
   	make_function("MAPHASH", Lmaphash);
	make_function("CLRHASH", Lclrhash);
	make_function("HASH-TABLE-COUNT", Lhash_table_count);
   	make_function("SXHASH", Lsxhash);
	make_si_sfun("HASH-EQUAL",hash_equal,ARGTYPE2(f_object,f_fixnum)
						| RESTYPE(f_fixnum));
	make_si_function("HASH-SET", siLhash_set);
}
