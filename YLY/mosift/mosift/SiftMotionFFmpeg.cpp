#define _CRT_SECURE_NO_WARNINGS 1
#define _CRT_SECURE_CPP_OVERLOAD_STANDARD_NAMES 1

// SiftMotionFFmpeg.cpp : Defines the entry point for the console application.
//

/*
   This program detects image features using SIFT keypoints. For more info,
   refer to:

   Lowe, D. Distinctive image features from scale-invariant keypoints.
   International Journal of Computer Vision, 60, 2 (2004), pp.91--110.

   Copyright (C) 2006-2007  Rob Hess <hess@eecs.oregonstate.edu>

Note: The SIFT algorithm is patented in the United States and cannot be
used in commercial products without a license from the University of
British Columbia.  For more information, refer to the file LICENSE.ubc
that accompanied this distribution.

Version: 1.1.1-20070913
*/

#ifdef WIN32
#include "stdafx.h"
#else
#include <stdio.h>
#include <stdarg.h>
#include <sys/time.h>
#include <libgen.h>
int GetTickCount() {
	struct timeval tmp;
	gettimeofday(&tmp, NULL);
	return (tmp.tv_sec*1000+tmp.tv_usec/1000);}
#endif

#include "Motion_SIFT_feature.h"
#include "AFGVideo.FF.h"
#include "convert.h"

#include <cv.h>
#include <cxcore.h>
#include <highgui.h>

#include <unistd.h>
#include <limits.h>
#include <stdlib.h>
#include <time.h>
#include <string>

#define OPTIONS ":o:s:e:t:k:p:bzfdruh"

	/*************************** Function Prototypes *****************************/

	void usage( char* );
	void arg_parse( int,  char* argv[]);
	void fatal_error(const char* format, ...);
	std::string move_to_temp_file(char* original_file);

	/******************************** Globals ************************************/

	char* pname = NULL;
	char* video_file_name = NULL;
	char* feature_file_name = NULL;
	char* out_video_name = NULL;

	int intvls = SIFT_INTVLS_MSIFT;
	double sigma = SIFT_SIGMA_MSIFT;
	double contr_thr = SIFT_CONTR_THR_MSIFT;
	int curv_thr = SIFT_CURV_THR_MSIFT;
	int img_dbl = SIFT_IMG_DBL_MSIFT;
	int descr_width = SIFT_DESCR_WIDTH_MSIFT;
	int descr_hist_bins = SIFT_DESCR_HIST_BINS_MSIFT;

	bool display = false;
	bool movie   = false;
	int start_frame = 1;
	int end_frame = INT_MAX;
	int step    = 1;
	int skip = 0;
	bool binary = false;
	bool gzip = false;
	bool rotation = false;
	double ratio = 0.005;

	/********************************** Main *************************************/

	int main(int argc, char* argv[]) {
		IplImage* img;
		struct feature_MSIFT* features;
		double tim = 0.0; // seconds
		int inc = 1;
		double pos;
		char whence[10];
		char plus[10];
		int n = 0;
		FILE* fp;

		// Parse the input arguments
		arg_parse( argc, argv );

		// Open the input video
		AFGvideo *ff = new AFGvideo((char*)video_file_name, PIX_FMT_BGR24);
		if (ff->hr < 0) {
			fprintf(stderr, "AFGvideo (avcodec) failed to initialize\n%s '%s'\n",
					ff->hrs, video_file_name);
		}

		// Open the key file
		fp = fopen(feature_file_name, "w");
		if (fp == NULL)	{
			fprintf(stderr, "Open file %s failed!\n", feature_file_name);
			exit(-1);
		}

		int width  = ff->width;
		int height = ff->height;
		double fps = ff->fps;
		IplImage *ipl_color_header = cvCreateImageHeader (cvSize(width, height), IPL_DEPTH_8U, 3);
		IplImage *ipl_color;
		IplImage *ipl_color_next;

		// Read the first frame
		ff->Seek(tim);
		pos = ff->nat_pts;
		sprintf(whence, "%08.3f", pos);
		ipl_color_header->imageDataOrigin = (char *)ff->buf();
		ipl_color_header->imageData = ipl_color_header->imageDataOrigin;
		ipl_color = cvCloneImage(ipl_color_header);

		// Write the video if needed
		CvVideoWriter *Writer;
		if (movie) {
			Writer = cvCreateVideoWriter(out_video_name,
					// ??
					//                                            CV_FOURCC('P', 'I', 'M', '1'),
					// ??
					//                                            CV_FOURCC('M', 'J', 'P', 'G'),
					// rawvideo, bgr24
					//                                            CV_FOURCC('D', 'I', 'B', ' '),
					// rawvideo, bgr24,
					0,
					// msvideo1, rgb555
					//                                            CV_FOURCC('M', 'S', 'V', 'C'),
					// mpeg4 YUV420p
					//                                            CV_FOURCC('F', 'F', 'D', 'S'),
					fps,
					cvSize(width, height),
					1);
			if (Writer == NULL) {
				fprintf(stderr, "cvCreateVideoWriter failed to initialize file %s\n", out_video_name);
				exit(-1);
			}
		}

		// Display the result if needed
		if (display)
			cvNamedWindow("MoSIFT");

		// Iteratively seek the frame
		fprintf(stderr, "processing video file %s ...\n", video_file_name);
		while (1) {
			// Seek the frames provided
			if (start_frame > inc) {
				inc++;
				ff->Next(1);
				pos = ff->nat_pts;
				sprintf(whence, "%08.3f", pos);
				ipl_color_header->imageDataOrigin = (char *)ff->buf();
				ipl_color_header->imageData = ipl_color_header->imageDataOrigin;
				cvReleaseImage(&ipl_color);
				ipl_color = cvCloneImage(ipl_color_header);
				continue;
			}
			if (end_frame <= inc)
				break;

			// Seek the next step frame
			ff->Next(step);
			inc += step;
			pos = ff->nat_pts;
			sprintf(plus, "%08.3f", pos);
			ipl_color_header->imageDataOrigin = (char *)ff->buf();
			ipl_color_header->imageData = ipl_color_header->imageDataOrigin;
			ipl_color_next = cvCloneImage(ipl_color_header);
			img = ipl_color;
			if( ! img )
				fatal_error( "unable to load image from %s", video_file_name );

			if( inc % 100 == 0 ){
				fprintf(stderr, "Finding SIFT features... %s vs %s, frame %d.  THIS IS NOT SHOWN FOR EVERY FRAME!!\n", whence, plus, inc);
			}

			// Extract the MoSIFT feature from two consequent frames
			CMotion_SIFT_feature MSF;
			
			n = MSF.motion_sift_features( ipl_color, ipl_color_next, &features);

			// Save the feature
			MSF.export_video_features( fp, features, n, inc-step );

			//fprintf( stderr, "Found %d features Time %.3f seconds\n",
			//		n, ((double)(GetTickCount()-StartTickCount))/1000);
			// Show the MoSIFT feature if needed
			if (display) {
				MSF.draw_features( ipl_color, features, n );
				cvShowImage("MoSIFT", ipl_color);
				cvWaitKey(10);
			}

			// Save the image with MoSIFT feature if needed
			if (movie) {
				cvWriteFrame(Writer, ipl_color);
			}

			// Stop if reach the end of video
			if (pos >= ff->len_sec)
				break;
			
			// Update the image
			cvReleaseImage(&ipl_color);
			ipl_color = ipl_color_next;
			strcpy(whence, plus);

			// Skip certain number of frames
			int skip_t = skip;
			int skip_end = 0;
			while (skip_t > 0) {
				skip_t--;
				inc++;
				ff->Next(1);
				pos = ff->nat_pts;
				sprintf(whence, "%08.3f", pos);
				ipl_color_header->imageDataOrigin = (char *)ff->buf();
				ipl_color_header->imageData = ipl_color_header->imageDataOrigin;
				cvReleaseImage(&ipl_color);
				ipl_color = cvCloneImage(ipl_color_header);
			}

			free(features);
			
			// Stop if reach the end of video
			if (pos >= ff->len_sec)
				break;
		}
		fprintf(stderr, "Done!!\n");
		cvReleaseImage(&ipl_color);
		cvReleaseImageHeader(&ipl_color_header);
		if (movie)
			cvReleaseVideoWriter(&Writer);
		fclose(fp);


		if (binary) {
			fprintf(stderr, "Compress into binary file!\n");
			std::string tp_file = move_to_temp_file(feature_file_name);
			txt2bin(tp_file.c_str(), feature_file_name);
			remove(tp_file.c_str());
		}
		if (gzip) {
			fprintf(stderr, "gzip the feature file!\n");
			std::string tp_file = move_to_temp_file(feature_file_name);
			txt2gzip(tp_file.c_str(), feature_file_name);
			remove(tp_file.c_str());
		}
		if (display)
			cvDestroyWindow("MoSIFT");
		delete ff;
		return 0;
	}

std::string move_to_temp_file(char* original){
	srand(time(0));
	char* temp_file = (char*)malloc(sizeof(char) * (strlen(feature_file_name) + 100));
	sprintf(temp_file, "%s_temp_%d", original, (int)random());
	std::string tp_file(temp_file);
	free(temp_file);
#ifdef _WIN32
	std::string cmd = string("move /Y ") + std::string(original) + " " + tp_file;
	system(cmd.c_str());
#else

	std::string cmd = std::string("mv ") + std::string(original) + " " + tp_file;
	system(cmd.c_str());
#endif
	return tp_file;
}

/* Usage for MoSIFT */
void usage(char* name) {
	fprintf(stderr, "Usage: %s [options] <video_file> <feature_file>\n", name);
	fprintf(stderr, "Options:\n");
	fprintf(stderr, "  -o <out_video>   Output video with MoSIFT feature\n");
	fprintf(stderr, "  -b               Store feature file as binary file\n");
	fprintf(stderr, "  -z               Store feature_file as gzip format\n");
	fprintf(stderr, "  -s <start_frame> Start frame number (default 1)\n");
	fprintf(stderr, "  -e <end_frame>   End frame number (default INT_MAX)\n");
	fprintf(stderr, "  -t <step>        Step taken to compute MoSIFT (default 1)\n");
	fprintf(stderr, "  -k <skip>        The number of frames skipped (default 0)\n");
	fprintf(stderr, "  -p <ratio>       Ratio of motion with respect to image size (default 0.005)\n");
	fprintf(stderr, "  -d               Toggle image doubling (default %s)\n",
			SIFT_IMG_DBL_MSIFT == 0 ? "off" : "on");
	fprintf(stderr, "  -r               rotate optical flow with respect SIFT (default no)\n");
	fprintf(stderr, "  -h               Display this message and exit\n");
}


/*
   arg_parse() parses the command line arguments, setting appropriate globals.

   argc and argv should be passed directly from the command line
   */
void arg_parse( int argc,  char* argv[] ) {
	//extract program name from command line (remove path, if present)
	pname = basename( argv[0] );

	//parse commandline options
	while( 1 ) {
		int arg = getopt( argc, argv, OPTIONS );
		if( arg == -1 )
			break;

		switch( arg ) {
			// catch unsupplied required arguments and exit
			case ':':
				fatal_error( "-%c option requires an argument\n"		\
						"Try '%s -h' for help.", optopt, pname );
				exit(-1);
				break;

				// read out_video_name
			case 'o':
				if( ! optarg )
					fatal_error( "error parsing arguments at -%c\n"	\
							"Try '%s -h' for help.", arg, pname );
				out_video_name = optarg;
				movie = true;
				break;

				// read start_frame
			case 's':
				if( ! optarg )
					fatal_error( "error parsing arguments at -%c\n"	\
							"Try '%s -h' for help.", arg, pname );
				start_frame = atoi(optarg);
				break;

				// read end_frame
			case 'e':
				if( ! optarg )
					fatal_error( "error parsing arguments at -%c\n"	\
							"Try '%s -h' for help.", arg, pname );
				end_frame = atoi(optarg);
				break;

				// read the step
			case 't':
				if( ! optarg )
					fatal_error( "error parsing arguments at -%c\n"	\
							"Try '%s -h' for help.", arg, pname );
				step = atoi(optarg);
				break;

				// read the skip
			case 'k':
				if( ! optarg )
					fatal_error( "error parsing arguments at -%c\n"	\
							"Try '%s -h' for help.", arg, pname );
				skip = atoi(optarg);
				break;

				// read the ratio of mation
			case 'p':
				if( ! optarg )
					fatal_error( "error parsing arguments at -%c\n"	\
							"Try '%s -h' for help.", arg, pname );
				ratio = atof(optarg);
				break;

				// output the binary file
			case 'b' :
				if (gzip)
					fatal_error( "cannot use binary mode and gzip mode simultaneously" );
				binary = true;
				break;

				// output the gzip file
			case 'z' :
				if (binary)
					fatal_error( "cannot use binary mode and gzip mode simultaneously" );
				gzip = true;
				break;

				// display the feature
			case 'f':
				display = true;
				break;

				// read double_image
			case 'd' :
				img_dbl = ( img_dbl == 1 )? 0 : 1;
				break;

				// rotate optical flow with respect to SIFT
			case 'r' :
				rotation = true;
				break;

				// user asked for help
			case 'h':
				usage( pname );
				exit(0);
				break;

				// catch invalid arguments
			default:
				fatal_error( "-%c: invalid option.\nTry '%s -h' for help.",
						optopt, pname );
		}
	}

	// make sure there are at least two arguments
	if( argc - optind != 2 )
		fatal_error( "Wrong number of input arguments.\nTry '%s -h' for help.", pname );

	// copy image file name from command line argument
	video_file_name = argv[optind];
	feature_file_name = argv[optind+1];
}

void fatal_error(const char* format, ...) {
	va_list ap;

	fprintf( stderr, "Error: ");

	va_start( ap, format );
	vfprintf( stderr, format, ap );
	va_end( ap );
	fprintf( stderr, "\n" );
	exit(-1);
}
