// txt2gzip.cpp will gzip the txtFile
#include <stdio.h>
#include <stdlib.h>
#include "convert.h"

int main(int argc, char* argv[])
{
	if (argc < 3)
	{
		printf("Usage: %s txtFile gzipFile\n", argv[0]);
		exit(-1);
	}
	char* txtFile = argv[1];
	char* gzipFile = argv[2];

	txt2gzip(txtFile, gzipFile);
	return 0;
}
