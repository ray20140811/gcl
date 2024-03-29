#ifndef NeXT
#define NeXT
#endif
#include "bsd.h"
#include "mc68k.h"
#undef SFASL
#undef HAVE_AOUT

#define PAGEWIDTH 12

/* The following value determines the running process size. */
#define BIG_HEAP_SIZE   0x1000000

#undef SET_REAL_MAXPAGE
#define SET_REAL_MAXPAGE \
{ extern int mach_maplimit; sbrk(0); real_maxpage = mach_maplimit/PAGESIZE; }

#define sbrk my_sbrk

#define ADDITIONAL_FEATURES \
	ADD_FEATURE("MACH"); \
	ADD_FEATURE("NeXT"); \
	ADD_FEATURE("MC68040"); \
        ADD_FEATURE("TURBO-CLOSURE"); \
        ADD_FEATURE("TURBO-CLOSURE-ENV-SIZE")

#define CLEAR_CACHE	asm("trap #2");
#define UNIXSAVE	"NeXTunixsave.c"
#define UNIXFASL	"NeXTunixfasl.c"

#define SEEK_TO_END_OFILE seek_to_end_ofile

#define	MC68040
#define	IEEEFLOAT

  /* we can use the system malloc without interference with
     lisp storage allocation */
#define DONT_NEED_MALLOC  

#ifdef IN_MAIN
#include <fcntl.h>
#include <sys/stat.h>
#endif
char *find_executable();




/* Begin for cmpinclude */

#define HAVE_ALLOCA

#ifdef __GNUC__
#undef __BUILTIN_VA_ARG_INCR
#endif



/* End for cmpinclude */


