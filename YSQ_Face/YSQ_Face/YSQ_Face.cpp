// YSQ_Face.cpp : �������̨Ӧ�ó������ڵ㡣
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


int* getFaces(Mat gray)
{
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

	return pResults;
}
int _tmain(int argc, _TCHAR* argv[])
{
	
	
	/*

	Legacy code for READ single frame image.


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

	*/

	//cvNamedWindow("Example", CV_WINDOW_AUTOSIZE);//��������Զ����ڴ�С�Ĵ���Example1
	CvCapture *capture = cvCreateFileCapture("D://test2.avi");//��ȡavi��ʽ��ӰƬ
	IplImage*frame;
	while (1)
	{
		
		frame = cvQueryFrame(capture);

		cvWaitKey(15);
		if (!frame) break;

		IplImage* img1 = cvCreateImage(cvGetSize(frame), IPL_DEPTH_8U, 1);//����Ŀ��ͼ��  
		cvCvtColor(frame, img1, CV_BGR2GRAY);


		//cvShowImage("frame", frame);

		Mat gray(img1, CV_LOAD_IMAGE_GRAYSCALE);
		imshow("frame", gray);
		if (gray.empty())
			cout << "ERR FRAME..." << endl;
		else
		{
			getFaces(gray);
		}
		

	
	}

	system("pause");
	return 0;

	

	
}

