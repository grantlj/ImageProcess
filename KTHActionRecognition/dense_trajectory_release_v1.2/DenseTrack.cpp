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
	char* video = argv[1];
	int flag = arg_parse(argc, argv);
	capture.open(video);

	if(!capture.isOpened()) {
		fprintf(stderr, "Could not initialize capturing..\n");
		return -1;
	}

	int frame_num = 0;
	TrackInfo trackInfo;
	DescInfo hogInfo, hofInfo, mbhInfo;



	//void InitDescInfo(DescInfo* descInfo, int nBins, bool isHof, int size, int nxy_cell, int nt_cell)
	InitTrackInfo(&trackInfo, track_length, init_gap);
	InitDescInfo(&hogInfo, 8, false, patch_size, nxy_cell, nt_cell);
	InitDescInfo(&hofInfo, 9, true, patch_size, nxy_cell, nt_cell);
	InitDescInfo(&mbhInfo, 8, false, patch_size, nxy_cell, nt_cell);

	SeqInfo seqInfo;
	InitSeqInfo(&seqInfo, video);

	if(flag)
		seqInfo.length = end_frame - start_frame + 1;

//	fprintf(stderr, "video size, length: %d, width: %d, height: %d\n", seqInfo.length, seqInfo.width, seqInfo.height);

	if(show_track == 1)
		namedWindow("DenseTrack", 0);

	Mat image, prev_grey, grey;

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

		if(frame_num == start_frame) {

			//������ʼ֡
			image.create(frame.size(), CV_8UC3);
			grey.create(frame.size(), CV_8UC1);
			prev_grey.create(frame.size(), CV_8UC1);

			InitPry(frame, fscales, sizes);

			//����������
			BuildPry(sizes, CV_8UC1, prev_grey_pyr);
			BuildPry(sizes, CV_8UC1, grey_pyr);

			BuildPry(sizes, CV_32FC2, flow_pyr);
			BuildPry(sizes, CV_32FC(5), prev_poly_pyr);
			BuildPry(sizes, CV_32FC(5), poly_pyr);

			xyScaleTracks.resize(scale_num);

			frame.copyTo(image);
			cvtColor(image, prev_grey, CV_BGR2GRAY);


			//��ͬsclse�Ľ�����
			for(int iScale = 0; iScale < scale_num; iScale++) {
				if(iScale == 0)
					prev_grey.copyTo(prev_grey_pyr[0]);
				else
					//����scale������С
					resize(prev_grey_pyr[iScale-1], prev_grey_pyr[iScale], prev_grey_pyr[iScale].size(), 0, 0, INTER_LINEAR);

				// dense sampling feature points
				std::vector<Point2f> points(0);

				//�ܼ��������浽��point����
				DenseSample(prev_grey_pyr[iScale], points, quality, min_distance);

				// save the feature points

				//��ÿ���㿪ʼ��trackInfo,hogInfo,hofInfo,mbhInfo.
				std::list<Track>& tracks = xyScaleTracks[iScale];
				//��ͬ�߶��µ�һ��track����tracks��tracks����������е��info������Track��
				for(i = 0; i < points.size(); i++)

					//push ÿ���㣬��������Ӧ����������Ϣ�Ĳ���
					tracks.push_back(Track(points[i], trackInfo, hogInfo, hofInfo, mbhInfo));
			}

			// compute polynomial expansion
			my::FarnebackPolyExpPyr(prev_grey, prev_poly_pyr, fscales, 7, 1.5);

			frame_num++;
			continue;
		}  //end of for


		//��һ��for(iscale�����ˣ����õ��˲�ͬscale�µĸ��ٵ㣬�͸��ٵ��Ӧ��������info

		init_counter++;
		frame.copyTo(image);
		cvtColor(image, grey, CV_BGR2GRAY);


		//�����
		// compute optical flow for all scales once
		my::FarnebackPolyExpPyr(grey, poly_pyr, fscales, 7, 1.5);
		my::calcOpticalFlowFarneback(prev_poly_pyr, poly_pyr, flow_pyr, 10, 2);



		//�ڶ���forѭ����ÿ��scale������������
		for(int iScale = 0; iScale < scale_num; iScale++) {
			if(iScale == 0)
				grey.copyTo(grey_pyr[0]);
			else
				resize(grey_pyr[iScale-1], grey_pyr[iScale], grey_pyr[iScale].size(), 0, 0, INTER_LINEAR);


			//ÿ�ж��ٸ��㣬ÿ�ж��ٸ���
			int width = grey_pyr[iScale].cols;
			int height = grey_pyr[iScale].rows;

			// compute the integral histograms
			//DescMat* InitDescMat(int height, int width, int nBins)
			//��ʼ��ֱ��ͼ(hog,hof,mbhx,mbhy

			DescMat* hogMat = InitDescMat(height+1, width+1, hogInfo.nBins);

			//����hog����������hogInfo�Ĳ������ã�����ŵ�hogMat��desc����Ū
			//void HogComp(const Mat& img, float* desc, DescInfo& descInfo)
			HogComp(prev_grey_pyr[iScale], hogMat->desc, hogInfo);


			//���Ҳ�ǲ��
			DescMat* hofMat = InitDescMat(height+1, width+1, hofInfo.nBins);
			HofComp(flow_pyr[iScale], hofMat->desc, hofInfo);

			//���
			DescMat* mbhMatX = InitDescMat(height+1, width+1, mbhInfo.nBins);
			DescMat* mbhMatY = InitDescMat(height+1, width+1, mbhInfo.nBins);
			MbhComp(flow_pyr[iScale], mbhMatX->desc, mbhMatY->desc, mbhInfo);



			//������ͷ���Ѿ�������һ֡ͼ�� ���е��HOG,HOF,MBH�ȵȶ����ˣ����ڸ��ݹ켣����feature



			// track feature points in each scale separately
			std::list<Track>& tracks = xyScaleTracks[iScale];
			for (std::list<Track>::iterator iTrack = tracks.begin(); iTrack != tracks.end();) {
				int index = iTrack->index;
				Point2f prev_point = iTrack->point[index];
				int x = std::min<int>(std::max<int>(cvRound(prev_point.x), 0), width-1);
				int y = std::min<int>(std::max<int>(cvRound(prev_point.y), 0), height-1);

				Point2f point;

				//���ݹ�������һ�����λ��
				point.x = prev_point.x + flow_pyr[iScale].ptr<float>(y)[2*x];
				point.y = prev_point.y + flow_pyr[iScale].ptr<float>(y)[2*x+1];
                 
				//����Ͷ���
				if(point.x <= 0 || point.x >= width || point.y <= 0 || point.y >= height) {
					iTrack = tracks.erase(iTrack);
					continue;
				}

				// get the descriptors for the feature point
				//���ݵ�ǰ������λ�ã����ǰ���Ѿ��е�HOG,HOF,MBH��Щ����������������feature
				RectInfo rect;
				GetRect(prev_point, rect, width, height, hogInfo);  //����������ڵľ���

				//����������ھ������������feature

				//// get a descriptor from the integral histogram
				//void GetDesc(const DescMat* descMat, RectInfo& rect, DescInfo descInfo, std::vector<float>& desc, const int index)
				GetDesc(hogMat, rect, hogInfo, iTrack->hog, index);  
				GetDesc(hofMat, rect, hofInfo, iTrack->hof, index);
				GetDesc(mbhMatX, rect, mbhInfo, iTrack->mbhX, index);
				GetDesc(mbhMatY, rect, mbhInfo, iTrack->mbhY, index);

				//�������ѹ��track�켣�Ҳ����˵��������Ƿ���itrack��imianle
				iTrack->addPoint(point);



				//��ͼ�����к��ԡ���������
				// draw the trajectories at the first scale
				if(show_track == 1 && iScale == 0)
					DrawTrack(iTrack->point, iTrack->index, fscales[iScale], image);

				// if the trajectory achieves the maximal length
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

			//�ͷ��ڴ�
			ReleDescMat(hogMat);
			ReleDescMat(hofMat);
			ReleDescMat(mbhMatX);
			ReleDescMat(mbhMatY);

			if(init_counter != trackInfo.gap)
				continue;

			// detect new feature points every initGap frames

			//��������²ɵ�ô����֤�̶�50����ͬʱL=15?
			std::vector<Point2f> points(0);
			for(std::list<Track>::iterator iTrack = tracks.begin(); iTrack != tracks.end(); iTrack++)
				points.push_back(iTrack->point[iTrack->index]);

			DenseSample(grey_pyr[iScale], points, quality, min_distance);
			// save the new feature points
			for(i = 0; i < points.size(); i++)
				tracks.push_back(Track(points[i], trackInfo, hogInfo, hofInfo, mbhInfo));
		}

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
	}

	if( show_track == 1 )
		destroyWindow("DenseTrack");

	return 0;
}
