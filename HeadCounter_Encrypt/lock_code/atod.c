/*
// file:		atod.c
// description:	convert a float string to a double value
//			used init the double value
// date:		2004-4-9 9:06
// copyright	Bejing Senselock Corp.
*/
#include <string.h>
#include <stdlib.h>
#include <ctype.h>
#include "ses_v3.h"
#include "strtod.h"

/*
// C prototype:		BYTE _atod(DOUBLE_T presult, char *pstr)
// parameter:		[OUT]	presult - return the double value
// 					[IN]	pstr - input the float string terminate with '\0'such as "3.1415926"
// return value:	0 - success, others - error
// remark:			
*/
BYTE _atod(DOUBLE_T* presult, char *pstr)
{
	DOUBLE_T td1, td2;
	long tl;
	char sign;
	BYTE bRet;
	
	
	// set presult 0.0
	memset(presult, 0x00, 8);
	// skip the space ahead pstr
	while(*pstr == ' ')
		pstr++;

	// get the sign
	if( *pstr == '-')
	{
		sign = 1;
		pstr++;
	}
	else
	{
		sign = 0;
		if (*pstr == '+')
			pstr++;
	}
	// set td1 10.0
	memcpy(&td1, "\x00\x00\x00\x00\x00\x00\x24\x40", 8);
	
	// get integer part
	while(*pstr >= '0' && *pstr <= '9')
	{
		if(SES_SUCCESS != (bRet =_mult(presult, presult, &td1)))
			return bRet;
		tl = (long)(*pstr-'0');
		if(SES_SUCCESS != (bRet = _altod(&td2, &tl)))
			return bRet;
		
		if(SES_SUCCESS != (bRet = _add(presult, presult, &td2)))
			return bRet;
		pstr++;
	}
	
	// get fraction part
	if(*pstr == '.')
	{
		// set td1 0.1
		memcpy(&td1, "\x9A\x99\x99\x99\x99\x99\xB9\x3F", 8);
		pstr++;
		while(isdigit(*pstr))
		{
			tl = (long)(*pstr-'0');
			if(SES_SUCCESS != (bRet = _altod(&td2, &tl)))
				return bRet;
			
			if(SES_SUCCESS != (bRet = _mult(&td2, &td2, &td1)))
				return bRet;
			
			if(SES_SUCCESS != (bRet = _add(presult, presult, &td2)))
				return bRet;
			
			memcpy(&td2, "\x9A\x99\x99\x99\x99\x99\xB9\x3F", 8);
			if(SES_SUCCESS != (bRet = _mult(&td1, &td1, &td2)))
				return bRet;
			
			pstr++;
		}
	}
	// finally, get exponent part
	if(toupper(*pstr) == 'E')
	{
		pstr++;
		// set td1 10.0
		memcpy(&td1, "\x00\x00\x00\x00\x00\x00\x24\x40", 8);
		tl = (long)atoi(pstr);
		if(tl < 0)
		{
			tl = -tl;
			memcpy(&td1, "\x9A\x99\x99\x99\x99\x99\xB9\x3F", 8);
		}
		else
		{
			memcpy(&td1, "\x00\x00\x00\x00\x00\x00\x24\x40", 8);
		}
		while(tl > 0)
		{
			if(SES_SUCCESS != (bRet = _mult(presult, presult, &td1)))
				return bRet;
			tl--;
		}
	}
	
	// set sign
	if(sign == 1)
	{
		memset(&td1, 0x00, 8);
		if(SES_SUCCESS != (bRet = _sub(presult, &td1, presult)))
			return bRet;
	}
	return 0;
}
