  /* Copyright William F. Schelter 1991
   Bignum routines.


   
num_arith.c: add_int_big
num_arith.c: big_minus
num_arith.c: big_plus
num_arith.c: big_quotient_remainder
num_arith.c: big_sign
num_arith.c: big_times
num_arith.c: complement_big
num_arith.c: copy_big
num_arith.c: div_int_big
num_arith.c: mul_int_big
num_arith.c: normalize_big
num_arith.c: normalize_big_to_object
num_arith.c: stretch_big
num_arith.c: sub_int_big
num_comp.c: big_compare
num_comp.c: big_sign
num_log.c: big_sign
num_log.c: copy_to_big
num_log.c: normalize_big
num_log.c: normalize_big_to_object
num_log.c: stretch_big
num_pred.c: big_sign
number.c: big_to_double
predicate.c: big_compare
typespec.c: big_sign
print.d: big_minus
print.d: big_sign
print.d: big_zerop
print.d: copy_big
print.d: div_int_big
read.d: add_int_big
read.d: big_to_double
read.d: complement_big
read.d: mul_int_big
read.d: normalize_big
read.d: normalize_big_to_object

 */



#define remainder gclremainder
#include "include.h"
#include "mp.h"




#define BCOPY_BODY(x,y) \
do { int *ucop = (int *)(x); \
    int *vcop = (int *) (y); \
  {int j = lgef(ucop); \
    while(--j >= 0) \
      { *vcop++ = *ucop++;}}}while (0)

bcopy_body(x,y)
    GEN x,y;
{BCOPY_BODY(x,y);}




/* coerce a pari GEN to a bignum or fixnum */

object
make_integer(u)
GEN u;
{ int l = lgef(u);
  if (l > (MP_CODE_WORDS+1) ||
      ( l == (MP_CODE_WORDS+1)  &&
       (MP_ONLY_WORD(u) & (1<<31)) != 0
       && (MP_ONLY_WORD(u) == ( 1<<31) ? signe(u) > 0 : 1)))
    { object ans ;
      GEN w;
      big_register_1->big.big_length = lg(u);
      big_register_1->big.big_self = u;
      ans = alloc_object(t_bignum);
      ans->big.big_self = 0;
      w = (GEN)alloc_relblock(l*sizeof(int));
      /* may have been relocated */
      u =   big_register_1->big.big_self ;
      ans->big.big_self = w;
      ans->big.big_length = l;
      BCOPY_BODY(u , w);
      setlg(w,l);
      return ans;
    }
  else
    if (signe(u) > 0) return make_fixnum(MP_ONLY_WORD(u));
  else
    if (signe(u) < 0) return make_fixnum(-MP_ONLY_WORD(u));
  else
    return(small_fixnum(0));
 }


object
make_bignum(u)
GEN u;
    { object ans = alloc_object(t_bignum);
      GEN w;
      ans->big.big_length = lg(u);
      /* save u */
      ans->big.big_self = u;
      w = (GEN)alloc_relblock(lg(u)*sizeof(int));
      /* restore  u */
      u = ans->big.big_self ;
      ans->big.big_self = w;
      BCOPY_BODY(u ,  ans->big.big_self);
      return ans;
     }

big_zerop(x)
 object x;
{ return (signe(MP(x))== 0);}

big_compare(x, y)
     object x,y;
{return cmpii(MP(x),MP(y));}

object
big_minus(x)
     object x;
{ object y; 
  setsigne(MP(x),-(signe(MP(x))));
  y = make_integer(MP(x));
  setsigne(MP(x),-(signe(MP(x))));
  return  y;
}

gcopy_to_big(res,x)
     GEN res;
     object x;
{int l = (x)->big.big_length;
 int lgres = lg(res);
 if (l< lgres)
    { 
      big_register_1->big.big_length = lgres;
      big_register_1->big.big_self = res;
      (x)->big.big_self = (GEN) alloc_relblock(lgres*sizeof(int));
      (x)->big.big_length = lgres; 
      res =    big_register_1->big.big_self ;
     }
 BCOPY_BODY(res,(x)->big.big_self);
  if (l>lgres)
    { setlg((x)->big.big_self, l);}
} 
	    

add_int_big(i, x)
int i;
object x;
{
       MPOP_DEST(x,addsi,i,MP(x));
}


sub_int_big(i, x)
int i;
object x;
{ MPOP_DEST(x,subsi,i,MP(x));
}

mul_int_big(i, x)
int i;
object x;
{ MPOP_DEST(x,mulsi,i,MP(x));
}    

/*
	Div_int_big(i, x) destructively divides non-negative bignum x
	by positive int i.
	X will hold the quotient from  the division.
	Div_int_big(i, x) returns the remainder of the division.
	I should be positive.
	X should be non-negative.
*/

div_int_big(i, x)
int i;
object x;
{ save_avma;
  GEN res = divis(MP(x),i);
  gcopy_to_big(res,x);
  restore_avma;
  return hiremainder;
}


object
big_plus(x, y)
object x,y;
{ MPOP(return,addii,MP(x),MP(y));
}

object
big_times(x, y)
object x,y;
{ MPOP(return,mulii,MP(x),MP(y));
}



big_quotient_remainder(x0, y0, qp, rp)
     object x0,y0,*qp,*rp;
{
  GEN res,quot;
  save_avma;
  res = dvmdii(MP(x0),MP(y0),&quot);
  *qp = make_integer(res);
  *rp = make_integer(quot);
  restore_avma;
  return;

}

	
double
big_to_double(x)
     object x;
{
	double d, e;
	GEN u = MP(x);
	unsigned int *w;
	int l;
	e =  4.294967296e9;

	l = lgef(u);
	MP_START_HIGH(w,(unsigned int *) u,l);
	l = l - MP_CODE_WORDS;

	if (l == 0) return 0.0;

	d = (double) MP_NEXT_DOWN(w);
	while (--l > 0)
	  {d = e*d + (double)(MP_NEXT_DOWN(w));}
	if (signe(u)>0) return d;
	  else return -d;
      }
	

object
normalize_big_to_object(x)
 object x;
{ return make_integer(MP(x));}
  

object copy_big(x)
     object x;
{
  if (type_of(x)==t_bignum)
    return make_bignum(MP(x));
  else FEerror("bignum expected",0);

}


object
copy_to_big(x)
     object x;
{object y;

	if (type_of(x) == t_fixnum) {
	  save_avma;
	  y = make_bignum(stoi(fix(x)));
	  restore_avma;
	} else if (type_of(x) == t_bignum)
		y = copy_big(x);
	else
		FEerror("integer expected",0);
	return(y);
      }
  

/* return the power of x */
GEN
powerii(x,y)
     GEN x, y;
{  GEN ans = gun;
   if (signe(y) < 0) FEerror("bad");
   while (lgef(y) > 2){
     if (MP_LOW(y,lgef(y)) & 1)
       { ans = mulii(ans,x);}
     x = mulii(x,x);
     y = shifti(y,-1);}
   return ans;
 }

object integ_temp;


replace_copy1(x,y)
     GEN y,x;
{ int j = lgef(x);
 if (y && j <= lg(y))
    { x++; y++;
      while (--j >0)
      {*y++ = *x++;}
     return 0;}
 END:
 return j*2*sizeof(GEN);
}

/* doubles the length ! */
GEN
replace_copy2(x,y)
     GEN y,x;
{GEN yp = y;  
 int k,j = lgef(x);
 k = j;
 while (--j >=0)
   {*yp++ = *x++;}
 y[0] = INT_FLAG + k*2;
 return y;}

#define STOI(x,y) do{ \
  if (x ==0) { y[1]=2;} \
  else if((x)>0) {y[1]=0x1000003;y[2]=x;} \
                  else{y[1]=0xff000003;y[2]= -x;}}while (0)

/* actually y == 0 is not supposed to happen !*/
		    
obj_replace_copy1(x,y)
     object x;
     GEN y;
{ int j ;
  GEN xp;
  { if (type_of(x) == t_bignum)
      {   j = lgef(MP(x));
	  if (y && j <= lg(y))
	    { xp=MP(x);
	      xp++; y++;
	      while (--j >0)
		{*y++ = *xp++;}
	      return 0;}}
  else
    { if (y==0) return 3*2*sizeof(GEN) ;
      STOI(fix(x),y); return 0;}}
 END:
 return j*2*sizeof(GEN);
}

/* doubles the length ! */
GEN
obj_replace_copy2(x,y)
     object x;
     GEN y;
{GEN yp = y;
 GEN xp;
 int k,j;
 if (type_of(x) == t_bignum)
   { j = lgef(MP(x));
     k = j;
     xp = MP(x);
     while (--j >=0)
       {*yp++ = *xp++;}
     y[0] = INT_FLAG + k*2;}
 else  {STOI(fix(x),yp); y[0] = INT_FLAG+3*2;}
 return y;}


GEN
otoi(x)
     object x;
{if (type_of(x)==t_fixnum) return stoi(fix(x));
 if (type_of(x)==t_bignum)
   return (MP(x));
 FEwrong_type_argument(Sinteger,x);
 return 0;
}

object
alloc_bignum_static(len)
int len;
    { object ans = alloc_object(t_bignum);
      GEN w;
      ans->big.big_length = len;
      ans->big.big_self = 0;
      w = (GEN)AR_ALLOC(alloc_contblock,len,unsigned long);
      ans->big.big_self = w;
      w[0] = INT_FLAG + len;
      return ans;
     }


GEN
setq_io(x,all,val)
     GEN x;
     object val;
     object *all;
{int n= obj_replace_copy1(val,x);
 if (n)
   { *all = alloc_bignum_static(n/sizeof(int));
     return obj_replace_copy2(val,MP(*all));
   }
 else return x;}


GEN
setq_ii(x,all,val)
     GEN x;
     GEN val;
     object *all;
{int n= replace_copy1(val,x);
 if (n)
   { *all = alloc_bignum_static(n/sizeof(int));
     return replace_copy2(val,MP(*all));
   }
 else return x;}


 

void
isetq_fix(var,s)
     GEN var;
     int s;
{/* if (var==0) FEerror("unitialized integer var"); */
 STOI(s,var);
}

GEN
icopy_bignum(a,y)
     object a;
     GEN y;
{ int *ucop = (int *)MP(a); 
  int *vcop = (int *) (y);
  int j = lgef(ucop);
  {while(--j >= 0) 
     { *vcop++ = *ucop++;}
   setlg(y,a->big.big_length);
   return y;}}
     

GEN
icopy_fixnum(a,y)
     object a;
     GEN y;
       
{ int x= fix(a);
  if(!x) return gzero;
  y[0]=INT_FLAG+3;
  if(x>0) {y[1]=0x1000003;y[2]=x;}
  else{y[1]=0xff000003;y[2]= -x;}
  return y;
}
     


     


  







