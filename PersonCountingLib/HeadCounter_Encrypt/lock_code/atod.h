/*
// file:		atod.h
// description:	convert a float string to a double value
//			used init the double value
// date:		2004-4-9 9:06
// copyright	Bejing Senselock Corp.
*/

#ifndef	__ATOD_H__
#define	__ATOD_H__

#pragma SAVE
#pragma GENERIC

/*
// C prototype:		BYTE _atod(DOUBLE_T presult, char *pstr)
// parameter:		[OUT]	presult - return the double value
// 					[IN]	pstr - input the float string terminate with '\0'such as "3.1415926"
// return value:	0 - success, others - error
// remark:			
*/
BYTE _atod(DOUBLE_T* presult, char *pstr);

#pragma RESTORE

#endif	//__ATOD_H__
