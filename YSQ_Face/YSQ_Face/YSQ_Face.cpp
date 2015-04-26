// YSQ_Face.cpp : 定义控制台应用程序的入口点。
//

#include "stdafx.h"
#include <opencv2/opencv.hpp>
#include <iostream>
#include <string>
#include <Windows.h>
using namespace std;
using namespace cv;


#include "facedetect-dll.h"
#pragma comment(lib,"libfacedetect.lib")

using namespace cv;
int _tmain(int argc, _TCHAR* argv[])
{
	
	
	//load an image and convert it to gray (single-channel)
	Mat gray = imread("test.jpg", CV_LOAD_IMAGE_GRAYSCALE);
	if (gray.empty())
	{
		fprintf(stderr, "Can not load the image file.\n");
		system("pause");
		return -1;
	}

	int * pResults = NULL;

	///////////////////////////////////////////
	// frontal face detection 
	// it's fast, but cannot detect side view faces
	//////////////////////////////////////////
	//!!! The input image must be a gray one (single-channel)
	//!!! DO NOT RELEASE pResults !!!
	pResults = facedetect_frontal((unsigned char*)(gray.ptr(0)), gray.cols, gray.rows, gray.step,
		1.2f, 2, 24);
	printf("%d frontal faces detected.\n", (pResults ? *pResults : 0));
	//print the detection results
	for (int i = 0; i < (pResults ? *pResults : 0); i++)
	{
		short * p = ((short*)(pResults + 1)) + 6 * i;
		int x = p[0];
		int y = p[1];
		int w = p[2];
		int h = p[3];
		int neighbors = p[4];

		printf("face_rect=[%d, %d, %d, %d], neighbors=%d\n", x, y, w, h, neighbors);
	}

	///////////////////////////////////////////
	// multiview face detection 
	// it can detection side view faces, but slower than the frontal face detection.
	//////////////////////////////////////////
	//!!! The input image must be a gray one (single-channel)
	//!!! DO NOT RELEASE pResults !!!
	pResults = facedetect_multiview((unsigned char*)(gray.ptr(0)), gray.cols, gray.rows, gray.step,
		1.2f, 2, 24);
	printf("%d faces detected.\n", (pResults ? *pResults : 0));

	//print the detection results
	for (int i = 0; i < (pResults ? *pResults : 0); i++)
	{
		short * p = ((short*)(pResults + 1)) + 6 * i;
		int x = p[0];
		int y = p[1];
		int w = p[2];
		int h = p[3];
		int neighbors = p[4];
		int angle = p[5];

		printf("face_rect=[%d, %d, %d, %d], neighbors=%d, angle=%d\n", x, y, w, h, neighbors, angle);
	}


	system("pause");
	return 0;

	

	
}

