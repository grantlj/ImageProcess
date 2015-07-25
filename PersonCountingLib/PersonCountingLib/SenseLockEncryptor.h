#include <stdlib.h>
#include <stdio.h>
#include <conio.h>
#include "sense4.h"
#include <cmath>
void bubble_sort(unsigned char*p, int len)
{
	int i, j;
	unsigned char tmp;
	for (i = 0; i<len - 1; i++)
	{
		for (j = 0; j<len - i - 1; j++)
		{
			if (p[j]>p[j + 1])
			{
				tmp = p[j];
				p[j] = p[j + 1];
				p[j + 1] = tmp;
			}
		}
	}
}

bool LockerTester()
{
	//unsigned char test[] = { 4, 3, 8, 2, 9, 7, 1, 5, 0, 6 };
	//int len = sizeof(test);
	
	int len = abs(rand()%15) + 5;
	unsigned char* test = new unsigned char(len);
	unsigned char* org = new unsigned char(len);
	for (int i = 0; i < len; i++)
	{
		test[i] = abs(rand() % 40) + 5;
		org[i] = test[i];
		//printf("%4d\n", org[i]);
	}

	SENSE4_CONTEXT ctx = { 0 }; SENSE4_CONTEXT *pctx = NULL;
	unsigned long size = 0;
	unsigned long ret = 0;
	unsigned char fid[] = "aaaa";
	
	int i;
	S4Enum(pctx, &size);
	if (size==0)
	{
		printf("EliteIV not found!\n");
		return false;
	}

	pctx = (SENSE4_CONTEXT*)malloc(size);
	if (pctx == NULL)
	{
		printf("Not enough memory!\n");
		return false;
	}
	
	ret = S4Enum(pctx, &size);
	if (ret != S4_SUCCESS)
	{
		printf("Enumerate EliteIV error!\n");
		free(pctx);
		return false;
	}

	memcpy(&ctx, pctx, sizeof(SENSE4_CONTEXT));
	free(pctx);
	pctx = NULL;

	/*open device*/
	ret = S4Open(&ctx);
	if (ret != S4_SUCCESS)
	{
		printf("Open EliteIV failed!\n");
		return false;
	}

	/*switch to root path*/
	ret = S4ChangeDir(&ctx, "\\");
	if (ret != S4_SUCCESS)
	{
		printf("No root directory found!\n");
		S4Close(&ctx);
		return false;
	}

	/*Verify user pin*/
	ret = S4VerifyPin(&ctx, (byte*)"62461520", 8, S4_USER_PIN);
	if (ret != S4_SUCCESS)
	{
		printf("Verify user PIN failed!\n");
		S4Close(&ctx);
		return false;
	}

	/*Execute the bubble sorting to test array */
	ret = S4Execute(&ctx, (LPCSTR)fid, test, len, test, len, &size);
	if (ret != S4_SUCCESS)
	{
		printf("Execute EliteIV exe failed!\n");
		S4Close(&ctx);
		return false;
	}

	S4Close(&ctx);
	
	
    /*Execute the bubble sorting to our own array. */
	bubble_sort(org, len);

	/*Verify*/
	bool flag = true;
	for (int i = 0; i < len;i++)
	if (test[i] != org[len - i-1])
	{
		flag = false;
		printf("Return value verify failed...");
		break;
	}
	return flag;
}





