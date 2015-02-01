// gzip2txt.cpp will gunzip the gzip file to txt file
#include <stdlib.h>
#include <stdio.h>
#include "convert.h"

int main(int argc, char* argv[])
{
	if (argc < 3)
	{
		printf("Usage: %s gzipFile txtFile\n");
		exit(-1);
	}
	char* gzipFile = argv[1];
	char* txtFile = argv[2];

	gzip2txt(gzipFile, txtFile);
	return 0;
}
