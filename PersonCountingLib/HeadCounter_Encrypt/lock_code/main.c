#include "ses_v3.h"

void bubble_sort(unsigned char*p, int len)
{
   int i,j;
   unsigned char tmp;
   for (i=0;i<len-1;i++)
   {
   		for (j=0;j<len-i-1;j++)
		{
			if (p[j]<p[j+1])
			{
				tmp=p[j];
				p[j]=p[j+1];
				p[j+1]=tmp;
		    }
		}
	}
}


void main()
{
	unsigned char *test=pbInBuff;   //a pointer pointing to the input buffer.
	int len=bInLen;					//buffer length.

	bubble_sort(test,len);

	_set_response(len,test);	   //send out.
	_exit();
}

