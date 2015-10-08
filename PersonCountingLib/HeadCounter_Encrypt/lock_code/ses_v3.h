/*
// file:			ses_v3.h
// description:		header file for C compiler supporting SES of xcos2.3
// 			for Keil C51, SDCC 8051 C and Raisonance XA compiler
// version:			3.1
// copyright:		Beijing Senslock corp
// date:			12/30/2004
*/

#ifndef __SES_V3_H__
#define __SES_V3_H__

#if (!defined __C51__ && !defined SDCC_mcs51 && !defined __RCXA__)
#error "this file can't be used on your compiler!"
#endif

#pragma save

#ifdef __C51__
#pragma REGPARMS
#endif


#ifdef SDCC_mcs51
#ifdef SDCC_STACK_AUTO
#error "the ses functions are not reentrant"
#endif
#endif

#ifdef __RCXA__

#include <math.h>
#include <string.h>
#include <alloc.h>

#ifndef __PAGEZERO_MODEL__
#define __PAGEZERO_MODEL__		1
#endif //__PAGEZERO_MODEL__

#ifndef __NONPAGEZERO_MODEL__
#define __NONPAGEZERO_MODEL__	0
#endif //__NONPAGEZERO_MODEL__

#ifndef __MEMORY_MODELS__
#define __MEMORY_MODELS__
#define __TINY__				0
#define __SMALL__				1
#define __COMPACT__				2
#define __MEDIUM__				3
#define __LARGE__				4
#define __HUGE__				5
#endif

#if (__PAGEZEROMODE__ != __NONPAGEZERO_MODEL__)
#error "you must select non page zero model!"
#endif

#if (__MEMORY_MODEL__ != __LARGE__)
#error "you must select large memory model!"
#endif

#pragma USERFCT
#pragma REGPARMS
#pragma GENERIC
#pragma NOEXTONTRAP

#define	xdata		idata

#ifndef	__S4_MEMORY_TYPE__
#define __S4_MEMORY_TYPE__
#define	RAM_EXT		xdata
#define RAM_INT_DE	data
#define RAM_INT_ID	idata
#define ROM			code
#endif	//__S4_MEMORY_TYPE__

#ifndef DEFINE_AT
#define DEFINE_AT(TYPE, NAME, ADDRESS, MEMORY)		at ADDRESS TYPE MEMORY NAME
#endif	//DEFINE_AT

#else	//__RCXA__

#ifndef	__MEMORY_SPACE_TYPE__
#define __MEMORY_SPACE_TYPE__
#define	RAM_EXT		xdata
#define RAM_INT_DE	data
#define RAM_INT_ID	idata
#define ROM			code
#endif

#ifdef	__C51__
#ifndef DEFINE_AT
#define DEFINE_AT(TYPE, NAME, ADDRESS, MEMORY)		TYPE MEMORY NAME _at_ ADDRESS
#endif	//DEFINE_AT
#endif	//__C51__

#ifdef	SDCC_mcs51
#ifndef	DEFINE_AT
#define DEFINE_AT(TYPE, NAME, ADDRESS, MEMORY)		MEMORY at ADDRESS TYPE NAME
#endif	//DEFINE_AT
#endif	//SDCC_mcs51


#endif	//__RCXA__

/*
//	const define
*/

/* define return value for SES functions	*/
#define SES_SUCCESS				0x00			/* ses function success					*/
#define SES_PARA				0x02			/* invalid parameter					*/
#define SES_EEPROM				0x03			/* write eeprom failed					*/
#define SES_RAM					0x04			/* ram out of range						*/
#define SES_XCOS				0x05			/* unknown error						*/

#define SES_FILEID				0x11			/* file not found						*/
#define SES_FILE_ACCESS			0x12			/* access file failed					*/
#define SES_FILE_SELECT			0x13			/* select file error					*/
#define SES_HANDLE				0x14			/* invalid file handle					*/
#define SES_RANGE				0x15			/* out of file range					*/
#define SES_FILE_SPACE			0x16			/* SES no enough space to create new file*/
#define SES_FILE_EXISTING		0x17			/* SES file ID has been used			*/

#define SES_KEYID				0x21			/* key not found							*/
#define SES_KEY_ACCESS			0x22			/* access key failed					*/
#define SES_SHA1				0x23			/* hash failed							*/
#define SES_RAND				0x24			/* get random data failed						*/
#define SES_RSA					0x25			/* RSA calculation failed					*/
#define SES_RSAVERIFY			0x26			/* digest signature verification failed	*/

#define SES_INVALID_POINTER		0x30			/* invalid pointer 						*/
#define SES_INVALID_SIZE		0x31			/* invalid size							*/

#define SES_REAL_TIME			0x40			/* read clock module error				*/
#define SES_REAL_TIME_POWER		0x41			/* the clock module has been power down */


/* RSA calculate model			*/
#define RSA_CALC_NORMAL			0x00			/* crypt directly			*/
#define RSA_CALC_HASH			0x01			/* hash first(signature)	*/
#define RSA_CALC_PKCS			0x02			/* pkcs standard			*/

/* RSA calculation mode : for compatibility with old version only		*/
/* RSA encrypt or decrypt		*/
#define RSA_CRYPT_NOPKCS		RSA_CALC_NORMAL
#define RSA_CRYPT_PKCS			RSA_CALC_PKCS
/* RSA signature				*/
#define RSA_SIGN_NOPH			RSA_CALC_NORMAL
#define RSA_SIGN_HASH			RSA_CALC_HASH
#define RSA_SIGN_PKCS			RSA_CALC_PKCS
#define RSA_SIGN_PH				(RSA_CALC_HASH|RSA_CALC_PKCS)
/* RSA verification digital signature	*/
#define RSA_VERI_NOPKCS			RSA_CALC_NORMAL
#define RSA_VERI_PKCS			RSA_CALC_PKCS

/* timer running model			*/
#define TIMER_MODE_NOCYCLE		0x00			/* no cycle model			*/
#define TIMER_MODE_CYCLE		0x01			/* cycle model				*/
#define TIMER_MODE_RELOAD		0x02			/* cycle reload model		*/

/* create file flag				*/
#define CREATE_OPEN_ALWAYS		0x00			/* open if file already exists, create a new file if not existing	*/
#define CREATE_FILE_NEW			0x01			/* create a new file and open it									*/
#define CREATE_OPEN_EXISTING	0x02			/* open a file exist												*/

/* create file type				*/
#define SES_FILE_TYPE_EXE		0x00			/* executable file			*/
#define SES_FILE_TYPE_EXE_DATA	0x01			/* data file				*/
#define SES_FILE_TYPE_RSA_PUB	0x02			/* RSA public key file		*/
#define SES_FILE_TYPE_RSA_SEC	0x03			/* RSA secret key file		*/

/* get global data flag			*/
#define GLOBAL_SERIAL_NUMBER	0x00
#define GLOBAL_CLIENT_NUMBER	0x01


/*
//	data type define
*/

#ifndef	_BYTE_DEFINED
#define _BYTE_DEFINED
typedef unsigned char BYTE;
#endif

#ifndef _WORD_DEFINED
#define _WORD_DEFINED
typedef unsigned short WORD;
#endif

#ifndef _DWORD_DEFINED
#define _DWORD_DEFINED
typedef unsigned long DWORD;
#endif

#ifndef _HANDLE_DEFINED							/* file handle of ses		*/
#define _HANDLE_DEFINED
typedef unsigned char HANDLE;
typedef HANDLE *PHANDLE;
#endif

#ifndef _TIME_T_DEFINED							/* standard time_t, start at 1/1/1970 0:0:0(UTC)	*/
#define _TIME_T_DEFINED
typedef long time_t;
#endif

/* IEEE-floatpoint format
//         BYTE0     BYTE1     BYTE2     BYTE3     BYTE4     BYTE5     BYTE6     BYTE7
// real4  SXXXXXXX  XMMMMMMM  MMMMMMMM  MMMMMMMM
// real8  SXXXXXXX  XXXXMMMM  MMMMMMMM  MMMMMMMM  MMMMMMMM  MMMMMMMM  MMMMMMMM  MMMMMMMM
// S represents the sign bit, the X`s are the exponent bits, and the M`s are the mantissa bits.
*/
/* attention: DOUBLE_T use little-endian format, as INTEL x86	*/
typedef struct _DOUBLE_T
{
	BYTE	mantL0;
	BYTE	mantL1;
	BYTE	mantL2;
	BYTE	mantL3;
	BYTE	mantH0;
	BYTE	mantH1;
	BYTE	mantH2:4, expL:4;
	BYTE	expH:7,   sign:1;
}DOUBLE_T;

/* RTC (Real-Time Clock) format		*/
typedef struct _RTC_TIME_T {
	BYTE	second;								/* second (0-59)					*/
	BYTE	minute;								/* minute (0-59)					*/
	BYTE	hour;								/* hour (0-23)						*/
	BYTE	day;								/* day of month (1-31)				*/
	BYTE	week;								/* day of week (0-6, sunday is 0)	*/
	BYTE	month;								/* month (0-11)						*/
	WORD	year;								/* year (0- 138, 1900 - 2038)		*/
}RTC_TIME_T;


typedef struct _HASH_CONTEXT
{
	DWORD	h[5];								/* temporary value of hash calculate		*/
	WORD	wTotalLength;						/* the length of calculated data			*/
	BYTE	bRemainLength;						/* the length of remained data				*/
	BYTE	pbRemainBuff[64];					/* the remained data						*/
}HASH_CONTEXT;

typedef HASH_CONTEXT HashContext;
typedef HashContext  *pHashContext;


/*
//	macro function definition
*/

// convert data format, little-endian(LE) low byte first, big-endian(BE) high byte first (CC mean C Compiler)	*/
#define _swap_u16(__x__)    			_invert(__x__, 2)
#define _swap_u32(__x__)    			_invert(__x__, 4)

#ifdef __C51__

#define LE16_TO_CC(__x__)				_swap_u16(__x__)
#define LE32_TO_CC(__x__)				_swap_u32(__x__)

#define CC_TO_LE16(__x__)				_swap_u16(__x__)
#define CC_TO_LE32(__x__)				_swap_u32(__x__)

#define BE16_TO_CC(__x__)				0
#define BE32_TO_CC(__x__)				0

#define CC_TO_BE16(__x__)				0
#define CC_TO_BE32(__x__)				0

#endif

#if (defined SDCC_mcs51 || defined __RCXA__)

#define LE16_TO_CC(__x__)				0
#define LE32_TO_CC(__x__)				0

#define CC_TO_LE16(__x__)				0
#define CC_TO_LE32(__x__)				0

#define BE16_TO_CC(__x__)				_swap_u16(__x__)
#define BE32_TO_CC(__x__)				_swap_u32(__x__)

#define CC_TO_BE16(__x__)				_swap_u16(__x__)
#define CC_TO_BE32(__x__)				_swap_u32(__x__)

#endif

/*
// data and buffer define
*/
#if (defined SDCC_mcs51 || defined __C51__)

#ifndef	bInLen
#define bInLen							(*(BYTE xdata *)0x0800)					/* length of the inputted data							*/
#endif

#ifndef pbInBuff
#define	pbInBuff						((BYTE xdata *)0x0801)					/* inputted data											*/
#endif

#elif defined __RCXA__

#ifndef	bInLen
#define bInLen							(*(BYTE xdata *)0x1000)					/* length of the inputted data							*/
#endif

#ifndef pbInBuff
#define	pbInBuff	 					((BYTE xdata *)0x1001)					/* inputted data											*/
#endif

#endif
/*
//	function declaration
*/

/* system function					*/
extern void _exit(void);														/* exit program											*/
extern BYTE _set_response(BYTE bLen, BYTE *pbdata);								/* set return data										*/

/* file function					*/
extern BYTE _open(WORD wFid, HANDLE *phandle);									/* open a file according to file ID						*/
extern BYTE _close(HANDLE handle);												/* close an opened file									*/
extern BYTE _read(HANDLE handle, WORD wOffset, BYTE bLen, BYTE *pbData);		/* read an opened file									*/
extern BYTE _write(HANDLE handle, WORD wOffset, BYTE bLen, BYTE *pbData);		/* write an opened file									*/

/* single DES crypt function		*/
extern BYTE _des_enc(BYTE *pbKey, BYTE bLen, BYTE *pbData);						/* single DES encryption using inputted key					*/
extern BYTE _des_dec(BYTE *pbKey, BYTE bLen, BYTE *pbData);						/* single DES decryption using inputted key					*/
/*
// triple DES crypt function
//
// these triple function using 16 BYTES key 
// Ka is the first 8 bytes of the key
// Kb is the following 8 bytes of the key
// c is ciphertext
// m is plain text
// c = EN( Ka, DE( Kb, EN(Ka, m) ) )
// m = DE( Ka, EN( Kb, DE(Ka, C) ) )
*/
extern BYTE _tdes_enc(BYTE *pbKey, BYTE bLen, BYTE *pbData);					/* triple DES encrypt using inputted key					*/
extern BYTE _tdes_dec(BYTE *pbKey, BYTE bLen, BYTE *pbData);					/* triple DES decrypt using inputted key					*/
/*
// hash function
// using SHA1 algorithm
*/
/* the following eight interfaces used for compatibility with hardware version 1.x only	*/
extern BYTE _sha1(BYTE bLen, BYTE *pbData);										/* hash single block data, bLen < 64 bytes				*/
extern BYTE _sha1_first_block(BYTE *pbData);									/* hash first block data, must be 64 bytes long			*/
extern BYTE _sha1_mid_block(BYTE *pbData);										/* hash middle block data, must be 64 bytes long		*/
extern BYTE _sha1_final_block(BYTE bLen, BYTE *pbData);							/* hash last block data, (bLen < 64)					*/

extern BYTE _sha1_only(BYTE *pbData, BYTE bLen);								/* hash single block data, bLen can be any value		*/
extern BYTE _sha1_first(BYTE *pbData, BYTE bLen);								/* hash first block data, bLen must be multiple of 64	*/
extern BYTE _sha1_mid(BYTE *pbData, BYTE bLen);									/* hash middle block data, bLen must be multiple of 64	*/
extern BYTE _sha1_last(BYTE *pbData, BYTE bLen);								/* hash last block data, Blen can be any value			*/

/* standard hash interface			*/
extern BYTE _sha1_init(pHashContext pContext);									/* hash initialize context								*/
extern BYTE _sha1_update(pHashContext pContext, BYTE *pbData, BYTE bLen);		/* hash update data										*/
extern BYTE _sha1_final(pHashContext pContext, BYTE* pbResult);					/* hash final, getting hash result						*/

/* RSA calculation function			*/
extern BYTE _rsa_enc(BYTE bMode, WORD wFid, BYTE bLen, BYTE* pbData);			/* RSA encrypt											*/
extern BYTE _rsa_dec(BYTE bMode, WORD wFid, BYTE bLen, BYTE* pbData);			/* RSA decrypt											*/
extern BYTE _rsa_sign(BYTE bMode, WORD wFid, BYTE bLen, BYTE* pbData);			/* RSA digital signature								*/
extern BYTE _rsa_veri(BYTE bMode, WORD wFid, BYTE bLen, BYTE* pbData);			/* RSA digital signature verification					*/

/* timer function					*/
extern BYTE _start_timer();														/* start timer											*/
extern BYTE _stop_timer();														/* stop timer											*/
extern BYTE _set_timer(BYTE bMode, DWORD* pdwCount);							/* initialize timer										*/
extern BYTE _get_timer(DWORD* pdwCount);										/* read timer value										*/

/*
// float calculation function
// using to increase float calculation speed
*/

#if (defined SDCC_mcs51 || defined __C51__)

extern float _addf(float x, float y);											/* return x + y											*/
extern float _subf(float x, float y);											/* return x - y											*/
extern float _multf(float x, float y);											/* return x * y											*/
extern float _divf(float x, float y);											/* return x	/ y											*/

extern float _sinf(float x);													/* return sin(x)										*/
extern float _cosf(float x);													/* return cos(x)										*/
extern float _tanf(float x);													/* return tan(x)										*/
extern float _asinf(float x);													/* return asin(x)										*/
extern float _acosf(float x);													/* return acos(x)										*/
extern float _atanf(float x);													/* return atan(x)										*/
extern float _sinhf(float x);													/* return sinh(x)										*/
extern float _coshf(float x);													/* return cosh(x)										*/
extern float _tanhf(float x);													/* return tanh(x)										*/
extern float _atan2f(float x, float y);											/* return atan2(x, y)									*/
extern float _ceilf(float x);													/* return ceil(x)										*/
extern float _floorf(float x);													/* return floor(x)										*/
extern float _absf(float x);													/* return abs(x)										*/
extern float _fmodf(float x, float y);											/* return fmod(x, y)									*/
extern float _expf(float x);													/* return exp(x)										*/
extern float _logf(float x);													/* return log(x)										*/
extern float _log10f(float x);													/* return log10(x)										*/
extern float _sqrtf(float x);													/* return sqrt(x)										*/
extern float _powf(float x, float y);											/* return pow(x)										*/

#elif defined __RCXA__

#define _addf(x, y)						((x) + (y))								/* x+y													*/
#define _subf(x, y)						((x) - (y))								/* x-y													*/
#define _multf(x, y)					((x) * (y))								/* x*y													*/
#define _divf(x, y)						((x) / (y))								/* x/y													*/

#define _sinf(x)						sinf(x)									/* return  sin(x)										*/
#define _cosf(x)						cosf(x)									/* return  cos(x)										*/
#define _tanf(x)						tanf(x)									/* return  tan(x)										*/
#define _asinf(x)						asinf(x)								/* return  asin(x)										*/
#define _acosf(x)						acosf(x)								/* return  acos(x)										*/
#define _atanf(x)						atanf(x)								/* return  atan(x)										*/
#define _sinhf(x)						sinhf(x)								/* return  sinh(x)										*/
#define _coshf(x)						coshf(x)								/* return  cosh(x)										*/
#define _tanhf(x)						tanhf(x)								/* return  tanh(x)										*/
#define _atan2f(x, y)					atan2f(x, y)							/* return  atan2(x, y)									*/
#define _ceilf(x)						ceilf(x)								/* return  ceil(x)										*/
#define _floorf(x)						floorf(x)								/* return  floor(x)										*/
#define _absf(x)						fabsf(x)									/* return  abs(x)										*/
#define _fmodf(x, y)					fmodf(x, y)								/* return  fmod(x, y)									*/
#define _expf(x)						expf(x)									/* return  exp(x)										*/
#define _logf(x)						logf(x)									/* return  log(x)										*/
#define _log10f(x)						log10f(x)								/* return  log10(x)										*/
#define _sqrtf(x)						sqrtf(x)								/* return  sqrt(x)										*/
#define _powf(x, y)						powf(x, y)								/* return  pow(x, y)									*/

#endif

/*
// memory operation
// used to increase memory operation speed
*/
#if (defined SDCC_mcs51 || defined __C51__)

extern BYTE _mem_copy(void *pDest, void *pSrc,BYTE bLen);						/* memcpy												*/
extern BYTE _mem_move(void *pDest, void *pSrc,BYTE bLen);						/* memmove												*/
extern BYTE _mem_set(void *pDest, BYTE bFill, BYTE bLen);						/* memset												*/

#elif defined __RCXA__

#define _mem_copy(pDest, pSrc, bLen)	(memcpy(pDest, pSrc, bLen), 0)			/* memcpy									*/
#define _mem_move(pDest, pSrc, bLen)	(memmove(pDest, pSrc, bLen), 0)			/* memmove									*/
#define _mem_set(pDest, bFill, bLen)	(memset(pDest, bFill, bLen), 0)			/* memset									*/

#endif

/*
// dynamic memory allocation
*/
#if (defined SDCC_mcs51 || defined __C51__)

extern BYTE  _mempool_init(void* pStart, WORD wSize);							/* initialize a memory pool for dynamic	allocation		*/
extern void* _malloc(WORD wSize);												/* malloc												*/
extern void* _calloc(WORD wNobj, WORD wSize);									/* calloc												*/
extern void* _realloc(void *pointer, WORD wSize);								/* realloc												*/
extern BYTE  _free(void *pointer);												/* free													*/

#elif defined __RCXA__

#define _mempool_init(pStart, wSize)	(mempool_init((dynamic_allocator_struct allocmem*)pStart, wSize), 0)		/* initialize a memory pool for dynamic	allocation		*/
#define _malloc(wSize)					malloc(wSize)							/* malloc												*/
#define _calloc(wNobj, wSize)			calloc(wNobj, wSize)					/* calloc												*/
#define _realloc(pointer, wSize)		realloc(pointer, wSize)					/* realloc												*/
#define _free(pointer)					(free(pointer), 0)						/* free													*/

#endif

/* assistant function				*/
extern BYTE _invert(void* pvdata, BYTE blen);									/* convert byte order									*/
extern BYTE _rand(BYTE bLen, BYTE* pbRand);										/* get rand number										*/

/* ------------------------------------------------------------------------- */
/*
// the following functions supported by hardware of version 2.3 or larger
*/
/*
// memory operation
// used to increase memory operation speed
*/

extern char _mem_cmp(void* pdest, void* psrc, BYTE length);						/* memcmp												*/

/* file function					*/
extern BYTE _create(WORD fid, WORD size, BYTE bFileType, BYTE bFlag, BYTE* pbHandle);   /* create a file								*/
extern BYTE _enable_exe(WORD fid);												/* enable a executable file								*/

/* real time function				*/
extern BYTE _time(time_t *ptime);												/* read real time start at 1/1/1970 0:0:0(UTC)			*/
extern BYTE _mktime(time_t* ptime_t, RTC_TIME_T* ptm);							/* convert RTC_TIME_T struct to time_t (UTC)			*/
extern BYTE _gmtime(time_t* ptime_t,  RTC_TIME_T* ptm);							/* convert time_t to RTC_TIME_T (UTC)					*/

/* double float calculation	function		*/
extern BYTE _add(DOUBLE_T* presult, DOUBLE_T* px, DOUBLE_T* py);				/* result = x + y										*/
extern BYTE _sub(DOUBLE_T* presult, DOUBLE_T* px, DOUBLE_T* py);				/* result = x - y										*/
extern BYTE _mult(DOUBLE_T* presult, DOUBLE_T* px, DOUBLE_T* py);				/* result = x * y										*/
extern BYTE _div(DOUBLE_T* presult, DOUBLE_T* px, DOUBLE_T* py);				/* result = x * y										*/

extern BYTE _sin(DOUBLE_T* presult, DOUBLE_T* px);								/* result = sin(x)										*/
extern BYTE _cos(DOUBLE_T* presult, DOUBLE_T* px);								/* result = cos(x)										*/
extern BYTE _tan(DOUBLE_T* presult, DOUBLE_T* px);								/* result = tan(x)										*/
extern BYTE _asin(DOUBLE_T* presult, DOUBLE_T* px);								/* result = asin(x)										*/
extern BYTE _acos(DOUBLE_T* presult, DOUBLE_T* px);								/* result = acos(x)										*/
extern BYTE _atan(DOUBLE_T* presult, DOUBLE_T* px);								/* result = atan(x)										*/
extern BYTE _sinh(DOUBLE_T* presult, DOUBLE_T* px);								/* result = sinh(x)										*/
extern BYTE _cosh(DOUBLE_T* presult, DOUBLE_T* px);								/* result = cosh(x)										*/
extern BYTE _tanh(DOUBLE_T* presult, DOUBLE_T* px);								/* result = tanh(x)										*/
extern BYTE _atan2(DOUBLE_T* presult, DOUBLE_T* px, DOUBLE_T* py);				/* result = atan2(x, y)									*/

extern BYTE _ceil(DOUBLE_T* presult, DOUBLE_T* px);								/* result = ceil(x)										*/
extern BYTE _floor(DOUBLE_T* presult, DOUBLE_T* px);							/* result = floor(x)									*/
extern BYTE _abs(DOUBLE_T* presult, DOUBLE_T* px);								/* result = abs(x)										*/

extern BYTE _fmod(DOUBLE_T* presult, DOUBLE_T* px, DOUBLE_T* py);				/* result = fmod(x, y)									*/

extern BYTE _exp(DOUBLE_T* presult, DOUBLE_T* px);								/* result = exp(x)										*/
extern BYTE _log(DOUBLE_T* presult, DOUBLE_T* px);								/* result = log(x)										*/
extern BYTE _log10(DOUBLE_T* presult, DOUBLE_T* px);							/* result = log10(x)									*/
extern BYTE _sqrt(DOUBLE_T* presult, DOUBLE_T* px);								/* result = sqrt(x)										*/
extern BYTE _pow(DOUBLE_T* presult, DOUBLE_T* px, DOUBLE_T* py);				/* result = pow(x, y)									*/

extern BYTE _modf(DOUBLE_T* presult, DOUBLE_T* px, DOUBLE_T* intptr);			/* result = modf(x, intptr)								*/

extern BYTE _frexp(DOUBLE_T* presult, DOUBLE_T* px, int *expptr);				/* result = frexp(x, expptr)								*/
extern BYTE _ldexp(DOUBLE_T* presult, DOUBLE_T* px, int exp);					/* result = ldexp(x, exp)								*/

extern char _fdcmp(DOUBLE_T* px, DOUBLE_T* py);									/* compare two double data								*/
extern BYTE _dtof(float* presult, DOUBLE_T* px);								/* double to float										*/
extern BYTE _ftod(DOUBLE_T* presult, float* px);								/* float to double										*/
extern BYTE _dtol(long* presult, DOUBLE_T* px);									/* double to signed long								*/
extern BYTE _altod(DOUBLE_T* presult, long* px);								/* signed long to double								*/
extern BYTE _lltod(DOUBLE_T* presult, DWORD* px);								/* unsigned long to double								*/

/* ------------------------------------------------------------------------- */
/* ------------------------------------------------------------------------- */
/*
// the following functions supported by hardware of version 2.31 or larger
*/
#if	(defined __C51__ || defined SDCC_mcs51)
extern BYTE _get_gbdata(BYTE bFlag, BYTE* pbData, BYTE bLen);
extern BYTE _set_lic(BYTE bNum);
#endif //(defined __C51__ || defined SDCC_mcs51)


#pragma restore

#endif /* __SES_V3_H__ */
