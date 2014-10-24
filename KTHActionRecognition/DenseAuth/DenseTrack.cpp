#include "DenseTrack.h"
#include "Initialize.h"
#include "Descriptors.h"
#include "OpticalFlow.h"

#include <time.h>

using namespace cv;

int show_track = 0; // set show_track = 1, if you want to visualize the trajectories

int main(int argc, char** argv)
{
	VideoCapture capture;
	char* video = "D:\Matlab\ImageProcess\KTHActionRecognition\dense_trajectory_release_v1.2\test_sequences\person01_boxing_d1_uncomp.avi";
	int flag = arg_parse(argc, argv);

	//打开视频
	capture.open(video);     

	if(!capture.isOpened()) {
		fprintf(stderr, "Could not initialize capturing..\n");
		return -1;
	}


	//计算的帧数，根据start_frame和end_frame来计算
	int frame_num = 0;

	//Track的参数，是一个基本量。
	TrackInfo trackInfo;

	//描述子信息
	DescInfo hogInfo, hofInfo, mbhInfo;

	//三种同时做：HOG,HOF,MBH
	InitTrackInfo(&trackInfo, track_length, init_gap);
	InitDescInfo(&hogInfo, 8, false, patch_size, nxy_cell, nt_cell);
	InitDescInfo(&hofInfo, 9, true, patch_size, nxy_cell, nt_cell);
	InitDescInfo(&mbhInfo, 8, false, patch_size, nxy_cell, nt_cell);

	//定义视频序列信息，整个视频的长宽高帧数等等
	SeqInfo seqInfo;
	InitSeqInfo(&seqInfo, video);

	//如果人为定义过参数了，我们就把视频的帧数手工卡死为我们需要获取的那部分长度
	if(flag)
		seqInfo.length = end_frame - start_frame + 1;

//	fprintf(stderr, "video size, length: %d, width: %d, height: %d\n", seqInfo.length, seqInfo.width, seqInfo.height);

	//需要显示跟踪轨迹
	if(show_track == 1)
		namedWindow("DenseTrack", 0);

	Mat image, prev_grey, grey;  //当前帧，灰度帧，前一帧的灰度化

	std::vector<float> fscales(0);
	std::vector<Size> sizes(0);

	std::vector<Mat> prev_grey_pyr(0), grey_pyr(0), flow_pyr(0);
	std::vector<Mat> prev_poly_pyr(0), poly_pyr(0); // for optical flow

	std::vector<std::list<Track> > xyScaleTracks;
	int init_counter = 0; // indicate when to detect new feature points
	while(true) {
		Mat frame;
		int i, j, c;

		// get a new frame
		capture >> frame;
		if(frame.empty())
			break;

		if(frame_num < start_frame || frame_num > end_frame) {
			frame_num++;
			continue;
		}


		//进入需要检测的第一帧
		if(frame_num == start_frame) {
			image.create(frame.size(), CV_8UC3);        //3通道彩图：   原始帧
			grey.create(frame.size(), CV_8UC1);         //单通道灰度：  灰度帧
			prev_grey.create(frame.size(), CV_8UC1);    //单通道灰度：  前一帧的灰度帧

			InitPry(frame, fscales, sizes);

			BuildPry(sizes, CV_8UC1, prev_grey_pyr);
			BuildPry(sizes, CV_8UC1, grey_pyr);

			BuildPry(sizes, CV_32FC2, flow_pyr);
			BuildPry(sizes, CV_32FC(5), prev_poly_pyr);
			BuildPry(sizes, CV_32FC(5), poly_pyr);

			xyScaleTracks.resize(scale_num);

			frame.copyTo(image);
			cvtColor(image, prev_grey, CV_BGR2GRAY);         //image转灰度图

			for(int iScale = 0; iScale < scale_num; iScale++) {  //好了，开始填每个尺度的信息了
				if(iScale == 0)
					prev_grey.copyTo(prev_grey_pyr[0]);   //原始尺度？
				else
					resize(prev_grey_pyr[iScale-1], prev_grey_pyr[iScale], prev_grey_pyr[iScale].size(), 0, 0, INTER_LINEAR);  //调整大小，INTER线性差值？

				// dense sampling feature points
				std::vector<Point2f> points(0);      //保存点的信息
				DenseSample(prev_grey_pyr[iScale], points, quality, min_distance);   //Dense采样

				// save the feature points
				std::list<Track>& tracks = xyScaleTracks[iScale];
				for(i = 0; i < points.size(); i++)                        //压入栈，保存每个点的trackInfo，hogInfo，hofInfo，mbhInfo
					tracks.push_back(Track(points[i], trackInfo, hogInfo, hofInfo, mbhInfo));
			}

			// compute polynomial expansion
			my::FarnebackPolyExpPyr(prev_grey, prev_poly_pyr, fscales, 7, 1.5);

			frame_num++;
			continue;
		}

		//非第一帧情况处理结束
		init_counter++;   //帧数控制，用来和L比较
		frame.copyTo(image);
		cvtColor(image, grey, CV_BGR2GRAY);

		// compute optical flow for all scales once
		//计算光流信息
		my::FarnebackPolyExpPyr(grey, poly_pyr, fscales, 7, 1.5);
		my::calcOpticalFlowFarneback(prev_poly_pyr, poly_pyr, flow_pyr, 10, 2);

		for(int iScale = 0; iScale < scale_num; iScale++) {
			if(iScale == 0)
				grey.copyTo(grey_pyr[0]);
			else
				resize(grey_pyr[iScale-1], grey_pyr[iScale], grey_pyr[iScale].size(), 0, 0, INTER_LINEAR);

			int width = grey_pyr[iScale].cols;
			int height = grey_pyr[iScale].rows;

			// compute the integral histograms

			//计算Hog，Hof，mbh的直方图（每个跟踪点）
			DescMat* hogMat = InitDescMat(height+1, width+1, hogInfo.nBins);
			HogComp(prev_grey_pyr[iScale], hogMat->desc, hogInfo);

			DescMat* hofMat = InitDescMat(height+1, width+1, hofInfo.nBins);
			HofComp(flow_pyr[iScale], hofMat->desc, hofInfo);

			DescMat* mbhMatX = InitDescMat(height+1, width+1, mbhInfo.nBins);
			DescMat* mbhMatY = InitDescMat(height+1, width+1, mbhInfo.nBins);
			MbhComp(flow_pyr[iScale], mbhMatX->desc, mbhMatY->desc, mbhInfo);

			// track feature points in each scale separately
			std::list<Track>& tracks = xyScaleTracks[iScale];
			for (std::list<Track>::iterator iTrack = tracks.begin(); iTrack != tracks.end();) {
				int index = iTrack->index;
				Point2f prev_point = iTrack->point[index];

				//这里的越界处理：由于我们还需要获取周边的hog信息，所以跟踪点是不可以越界的，要用max，min框一下
				int x = std::min<int>(std::max<int>(cvRound(prev_point.x), 0), width-1);
				int y = std::min<int>(std::max<int>(cvRound(prev_point.y), 0), height-1);

				Point2f point;
				point.x = prev_point.x + flow_pyr[iScale].ptr<float>(y)[2*x];      //flow_pry:iscale的光流
				point.y = prev_point.y + flow_pyr[iScale].ptr<float>(y)[2*x+1];
 
				if(point.x <= 0 || point.x >= width || point.y <= 0 || point.y >= height) {
					iTrack = tracks.erase(iTrack);
					continue;
				}

				//获取当前scale下的hog，hof，mbh信息
				// get the descriptors for the feature point
				RectInfo rect;
				GetRect(prev_point, rect, width, height, hogInfo);
				GetDesc(hogMat, rect, hogInfo, iTrack->hog, index);
				GetDesc(hofMat, rect, hofInfo, iTrack->hof, index);
				GetDesc(mbhMatX, rect, mbhInfo, iTrack->mbhX, index);
				GetDesc(mbhMatY, rect, mbhInfo, iTrack->mbhY, index);
				iTrack->addPoint(point);

				// draw the trajectories at the first scale
				// 在第一个scale大小下，画跟踪图
				if(show_track == 1 && iScale == 0)
					DrawTrack(iTrack->point, iTrack->index, fscales[iScale], image);

				// if the trajectory achieves the maximal length，就是那个L=14，我们需要重新找点啦！防止漂移！
				if(iTrack->index >= trackInfo.length) {
					std::vector<Point2f> trajectory(trackInfo.length+1);
					for(int i = 0; i <= trackInfo.length; ++i)
						trajectory[i] = iTrack->point[i]*fscales[iScale];
				
					float mean_x(0), mean_y(0), var_x(0), var_y(0), length(0);
					if(IsValid(trajectory, mean_x, mean_y, var_x, var_y, length)) {
						printf("%d\t%f\t%f\t%f\t%f\t%f\t%f\t", frame_num, mean_x, mean_y, var_x, var_y, length, fscales[iScale]);

						// for spatio-temporal pyramid
						printf("%f\t", std::min<float>(std::max<float>(mean_x/float(seqInfo.width), 0), 0.999));
						printf("%f\t", std::min<float>(std::max<float>(mean_y/float(seqInfo.height), 0), 0.999));
						printf("%f\t", std::min<float>(std::max<float>((frame_num - trackInfo.length/2.0 - start_frame)/float(seqInfo.length), 0), 0.999));
					
						// output the trajectory
						for (int i = 0; i < trackInfo.length; ++i)
							printf("%f\t%f\t", trajectory[i].x,trajectory[i].y);
		
						PrintDesc(iTrack->hog, hogInfo, trackInfo);
						PrintDesc(iTrack->hof, hofInfo, trackInfo);
						PrintDesc(iTrack->mbhX, mbhInfo, trackInfo);
						PrintDesc(iTrack->mbhY, mbhInfo, trackInfo);
						printf("\n");
					}

					iTrack = tracks.erase(iTrack);
					continue;
				}
				++iTrack;
			}
			ReleDescMat(hogMat);
			ReleDescMat(hofMat);
			ReleDescMat(mbhMatX);
			ReleDescMat(mbhMatY);

			if(init_counter != trackInfo.gap)
				continue;

			// detect new feature points every initGap frames
			std::vector<Point2f> points(0);
			for(std::list<Track>::iterator iTrack = tracks.begin(); iTrack != tracks.end(); iTrack++)
				points.push_back(iTrack->point[iTrack->index]);

			DenseSample(grey_pyr[iScale], points, quality, min_distance);
			// save the new feature points
			for(i = 0; i < points.size(); i++)
				tracks.push_back(Track(points[i], trackInfo, hogInfo, hofInfo, mbhInfo));
		} //scale循环结束

		init_counter = 0;
		grey.copyTo(prev_grey);
		for(i = 0; i < scale_num; i++) {
			grey_pyr[i].copyTo(prev_grey_pyr[i]);
			poly_pyr[i].copyTo(prev_poly_pyr[i]);
		}

		frame_num++;

		if( show_track == 1 ) {
			imshow( "DenseTrack", image);
			c = cvWaitKey(3);
			if((char)c == 27) break;
		}
	}  //死循环结束

	if( show_track == 1 )
		destroyWindow("DenseTrack");

	return 0;
}
