#ifndef KBI_H
#define KBI_H

#include <stdio.h>

#ifdef  __cplusplus
extern "C" {
#endif

#define BI_LITTLE_ENDIAN
#define BI_ALWAYS_BINARY
#define BI_NOASM
#define BI_BILEN 32
#define BI_utype int
#define BI_unsign32 unsigned int
#define BI_IBITS      32 
#define BI_LBITS      32 

#ifdef KISA_WINMO_32
#define BI_dltype __int64
#define BI_unsign64 unsigned __int64
#else
#define BI_dltype long long
#define BI_unsign64 unsigned long long
#endif

#define WINDOW 4
#define SQR_FASTER_THRESHOLD 5

#define SYS_BASE ((BI_small)1<<(BI_BILEN-1))

#define BI_SPACES 27

#define BI_ROUNDUP(a,b) ((a)-1)/(b)+1

#define BI_SL sizeof(long)
#define BI_SIZE(n) (((sizeof(struct bigtype)+((n)+2)*sizeof(BI_utype))-1)/BI_SL+1)*BI_SL
#define BI_BIG_RESERVE(n,m) ((n)*BI_SIZE(m)+BI_SL)

#ifndef TRUE
  #define TRUE 1
#endif
#ifndef FALSE
  #define FALSE 0
#endif

#define OFF 0
#define ON 1
#define PLUS 1
#define MINUS (-1)

#define BI_MAXDEPTH 24

#define BI_BYTE unsigned char

#define BI_TOBYTE(x) ((BI_BYTE)(x))


typedef unsigned BI_utype BI_small;
#ifdef BI_dltype
	typedef unsigned BI_dltype BI_large;
#endif

#define BI_DIV(a,b)    ((a)/(b))
#define BI_REMAIN(a,b) ((a)%(b))
#define BI_LROUND(a)   ((a))  

typedef unsigned int BI_lentype;

struct bigtype
{
    BI_lentype len;
    BI_small *w;
};                

typedef struct bigtype *BI;

#define BI_MSBIT ((BI_lentype)1<<(BI_IBITS-1))
#define BI_OBITS (BI_MSBIT-1)

#if BI_BILEN >= BI_IBITS
#define BI_TOOBIG (1<<(BI_IBITS-2))
#endif

#define NK   37
#define NJ   24
#define NV   14

#ifdef BI_dltype

#ifdef BI_LITTLE_ENDIAN
#define BI_BOT 0
#define BI_TOP 1
#endif
#ifdef BI_BIG_ENDIAN
#define BI_BOT 1
#define BI_TOP 0
#endif

union doubleword
{
    BI_large d;
    BI_small h[2];
};

#endif

#define TABLESIZE 544
typedef struct {

	BI_small table[TABLESIZE];
    BI n;
    int window;
    int max;
} combpre;

typedef struct {
BI_small base;
int   pack;
int   lg2b;
BI_small base2;
int (*user)(void);

int   nib;
int  check;
int  active;

BI_unsign32 ira[NK]; 
int         rndptr;  
BI_unsign32 borrow;

BI_small ndash;
BI modulus;
BI pR;

BI w0;          
BI w1,w2,w3,w4;
BI w5,w6,w7;
BI w8,w9,w10,w11;
BI w12,w13,w14,w15;
BI one;

int IOBASE;
char *workspace;

} bi;

extern bi *BI_mip;

extern BI_small BI_shiftbits(BI_small,int);
extern BI_small BI_setbase( BI_small);
extern void  BI_lzero(BI);
extern void  BI_padd( BI,BI,BI);
extern void  BI_psub( BI,BI,BI);
extern void  BI_pmul( BI,BI_small,BI);

extern BI_small BI_sdiv( BI,BI_small,BI);

extern void  BI_shift( BI,int,BI);
extern bi *BI_first_alloc(void);
extern void  *BI_alloc( int,int);
extern void  BI_free(void *);

extern int   BI_testbit( BI,int);
extern int   BI_recode( BI ,int ,int ,int );
extern int   BI_window( BI,int,int *,int *,int);
extern int   BI_window2( BI,BI,int,int *,int *);

extern BI_small BI_muldiv(BI_small,BI_small,BI_small,BI_small,BI_small *);
extern BI_small BI_muldvm(BI_small,BI_small,BI_small,BI_small *);

extern BI BI_init_mem_variable(char *,int,int);

extern BI_small BI_sgcd(BI_small,BI_small);
extern void  BI_irand( BI_unsign32);
extern BI_small BI_brand(void );
extern void  BI_zero(BI);
extern void  BI_convert( int,BI);
extern void  BI_uconvert( unsigned int,BI);

extern BI BI_init( int);
extern BI BI_init_mem( char *,int);
extern void  BI_destroy(BI);
extern void  *BI_memalloc( int);
extern void  BI_memkill( char *,int);
extern bi *BI_get_mip(void );

extern bi *BI_setup(int,BI_small);

extern bi *BI_setup_basic(bi *,int,BI_small);
extern void  BI_exit(void );
extern int   BI_exsign(BI);
extern void  BI_insign(int,BI);
extern void  BI_copy(BI,BI);
extern void  BI_negify(BI,BI);
extern int   BI_size(BI);
extern int   BI_compare(BI,BI);
extern void  BI_add( BI,BI,BI);
extern void  BI_subtract( BI,BI,BI);
extern void  BI_incr( BI,int,BI);

extern void  BI_premult( BI,int,BI);
extern int   BI_subdiv( BI,int,BI);
extern int  BI_subdivisible( BI,int);
extern int   BI_remain( BI,int);
extern void  BI_bytes_to_bi( int,const char *,BI);
extern int   BI_bi_to_bytes( int ,BI,char *,int);
extern BI_small BI_normalise( BI,BI);
extern void  BI_multiply( BI,BI,BI);
extern void  BI_divide( BI,BI,BI);
extern void  BI_mad( BI,BI,BI,BI,BI,BI);
int BI_init_bi_from_rom(BI,int,const BI_small *,int ,int *);

extern int   BI_xgcd( BI,BI,BI,BI,BI);
extern int   BI_invmodp( BI,BI,BI);
extern int   BI_logb2( BI);

extern void  BI_expmod( BI,BI,BI,BI);
extern void  BI_expmod2( BI,BI,BI,BI,BI,BI);

extern int  BI_multi_inverse( int,BI*,BI,BI*);

extern void  BI_bigrand( BI,BI);
extern int  BI_combpre_init( combpre *,BI,BI,int,int);
extern void  BI_combpre_end(combpre *);
extern void  BI_exp_combpre( combpre *,BI,BI);

extern BI_small BI_prepare_mont( BI);
extern void  BI_nres( BI,BI);
extern void  BI_redc( BI,BI);

extern void  BI_nres_modmult( BI,BI,BI);
extern void  BI_nres_expmod( BI,BI,BI);

#ifdef  __cplusplus
}
#endif

#endif


