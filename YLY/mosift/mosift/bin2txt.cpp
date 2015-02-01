// bin2txt.cpp has the functions which change from binary file to text file and vice versa
//
#include <stdlib.h>
#include <stdio.h>
#include "convert.h"

// Convert binary file to text file
int main(int argc, char* argv[])
{
	if (argc != 3)
	{
		printf("Usage: %s binFile txtFile\n", argv[0]);
		return 0;
	}
	char* binFile = argv[1];
	char* txtFile = argv[2];

	bin2txt(binFile, txtFile);
	return 0;
}
