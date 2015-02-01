// txt2bin.cpp has the functions which change from binary file to text file and vice versa
//
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "convert.h"

// Convert text file to binary file
int main(int argc, char* argv[])
{
	if (argc < 3)
	{
		printf("Usage: %s txtFile binFile\n", argv[0]);
		return 0;
	}
	char* txtFile = argv[1];
	char* binFile = argv[2];

	txt2bin(txtFile, binFile);
	return 0;
}
