#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <time.h>
#include <assert.h>
#include <float.h>

#include <string>
using namespace std;

#include "convert.h"

#define d 256
#define kk 10
#define K 5000

typedef struct
{
	float x,y;
	int t;
	float w;
	float u, v;
} vfeat;
	
float data[d];
float ctrs[K][d];
float dist[K];

int main(int argc, char** argv)
{
	if(argc != 5)
	{
		fprintf(stderr, "%s ctr_file ctr_count data_file output\n", argv[0]);
		exit(-1);
	}

	FILE *fpIn, *fpCtrs, *fpOut;
	vfeat f;
	int i, j, l;
	char tmp[65536];
	char *ptr1, *ptr2;
	float mindist;
	int bestctr;

	fpCtrs = fopen(argv[1], "r");
	assert(fpCtrs);
	int k = -1;
	sscanf(argv[2], "%d", &k);
	assert( k > 0 );
	

	bool zipped = false;
	int len = strlen(argv[3]);
	string tp_file = string(argv[3]) + ".txt";
	if( argv[3][len - 3] == '.' && argv[3][len - 2] == 'g' && argv[3][len - 1] == 'z' ){
		gzip2txt(argv[3], tp_file.c_str());
		zipped = true;
		fpIn = fopen(tp_file.c_str(), "r");
	}else{
		fpIn = fopen(argv[3], "r");
	}

	assert(fpIn);
	
	fpOut = fopen(argv[4], "w");
	assert(fpOut);


	printf("read centroid file\n");
	for(i=0; i<k; i++)
	{
		fgets(tmp, 65535, fpCtrs);
		ptr1 = tmp;
		for(j=0; j<d; j++)
		{
			ctrs[i][j] = atof(ptr1);
			ptr2 = strchr(ptr1, ' ');
			if(ptr2 != NULL)
				ptr1 = ptr2 + 1;
		}
	}


	printf("processing %s\n", argv[3]);
	
	l = 0;
	while(fgets(tmp, 65535, fpIn) != NULL)
	{
		l++;
		ptr1 = tmp;
		f.x = atof(ptr1);

		ptr2 = strchr(ptr1, ' ');
		ptr1 = ptr2+1;
		f.y = atof(ptr1);

		ptr2 = strchr(ptr1, ' ');
		ptr1 = ptr2+1;
		f.t = atoi(ptr1);

		ptr2 = strchr(ptr1, ' ');
		ptr1 = ptr2+1;
		f.w = atof(ptr1);

		ptr2 = strchr(ptr1, ' ');
		ptr1 = ptr2+1;
		f.u = atof(ptr1);

		ptr2 = strchr(ptr1, ' ');
		ptr1 = ptr2+1;
		f.v = atof(ptr1);

		ptr2 = strchr(ptr1, ' ');
		ptr1 = ptr2+1;
		for(i=0; i<d; i++)
		{
			data[i] = atof(ptr1);
			ptr2 = strchr(ptr1, ' ');
			if(ptr2 == NULL && i+1 != d)
			{
				fprintf(stderr, "format error in line %d(%d-D)!!\n", l, i);
				return -1;
			}
			ptr1 = ptr2+1;
		}

		if(i != d)
		{
			l--;
			continue;
		}
		
		for(i=0; i<k; i++)
		{
			float cdist = 0.0;
			
			for(j=0; j<d; j++)
			{
				cdist += (data[j]-ctrs[i][j])*(data[j]-ctrs[i][j]);
				//printf("%f\n", cdist);
			}
			dist[i] = cdist;
		}

		fprintf(fpOut, "%d %f %f %f %f %f", f.t, f.x, f.y, f.u, f.v, f.w);
		
		float mindist;
		int minindex = 0;
		for(i=0; i<kk; i++)
		{
			mindist = FLT_MAX;
			for(j=0; j<k; j++)
			{
				if(dist[j] == -1)
					continue;
				if(dist[j] <= mindist)
				{
					mindist = dist[j];
					minindex = j;
				}
			}
			dist[minindex] = -1;
			//fprintf(fpOut, " %d:%f", minindex, mindist);
			//distance is not used, ignore..save space
			fprintf(fpOut, " %d", minindex);
		}
		fprintf(fpOut, "\n");
	}
	printf("%d feature points\n", l);	

	fclose(fpCtrs);
	fclose(fpIn);
	fclose(fpOut);	

	if( zipped == true ){
		string cmd = string("rm -rf ") + tp_file;
		system(cmd.c_str());
	}	

	return 0;
}
