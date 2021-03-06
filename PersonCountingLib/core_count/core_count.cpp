// core_count.cpp : 定义控制台应用程序的入口点。
//

#include "stdafx.h"
#include "detect_core.h"
#include <ostream>
#include <fstream>
#include <iostream>
#include <io.h>
#include <vector>
#include "opencv2/stitching/stitcher.hpp"
using namespace std;

//DetectResult re = do_detect(now_frame, filename, tmplist.username, chlname_list[j]);

//parameter list: image_file_name, output_bbx_file_name, tmplist.username, chlname_list[j]


//图像拼接
cv::Mat do_concate(cv::Mat img_object, cv::Mat img_scene)
{
	Mat combine(max(img_object.size().height, img_scene.size().height), img_object.size().width + img_scene.size().width, CV_8UC3);
	Mat left_roi(combine, Rect(0, 0, img_object.size().width, img_object.size().height));
	img_object.copyTo(left_roi);
	Mat right_roi(combine, Rect(img_object.size().width, 0, img_scene.size().width, img_scene.size().height));
	img_scene.copyTo(right_roi);

	return combine;
}

//画bounding box
void draw_bounding_box(cv::Mat& out_img, vector<BBX> bbxlist)
{
	const static Scalar colors[] = { CV_RGB(0, 0, 255),
		CV_RGB(0, 128, 255),
		CV_RGB(0, 255, 255),
		CV_RGB(0, 255, 0),
		CV_RGB(255, 128, 0),
		CV_RGB(255, 255, 0),
		CV_RGB(255, 0, 0),
		CV_RGB(255, 0, 255) };

	for (int i = 0; i < bbxlist.size(); i++)
	{

		//画图
		CvPoint pt3, pt4;
		int x = (int)bbxlist[i].x;
		int y = (int)bbxlist[i].y;
		int w = (int)bbxlist[i].w;
		int h = (int)bbxlist[i].h;
		pt3.x = x;
		pt4.x = x + w;
		pt3.y = y;
		pt4.y = y + h;
		rectangle(out_img, pt3, pt4, colors[6 % 8], 0.5, 8, 0);
	}
}

//核心处理程序，完成检测,画图和输出三个步骤
void Handler()
{
	//todo.tmp 和主程序交互，得到当前任务。
	string image_file_name, output_bbx_file_name, list_username, chlname,out_image_root,template_root_path;
	ifstream infile("todo.tmp");

	//传入任务参数。
	if (infile.is_open())
	{
		infile >> image_file_name; infile >> output_bbx_file_name; infile >> list_username; infile >> chlname;
		infile >> out_image_root;
		infile >> template_root_path;
		infile.close();
	}

	cout << "New task:" << list_username << " " << chlname << endl;


	//读入图片，调用检测程序。
	cv::Mat image = imread(image_file_name);

	DetectResult ret = do_detect(image, image_file_name, list_username, chlname, template_root_path);

	cout << "Detection finished..." << endl;

	//save to file.


	if (_access(output_bbx_file_name.c_str(), 0) != -1)
		remove(output_bbx_file_name.c_str());
	
	ofstream outfile(output_bbx_file_name);

	if (outfile.is_open())
	{
		//outfile << ret.bbxlist.size() << endl;
		outfile << ret.time_stamp << endl;
		outfile << ret.person_count << endl;

		for (int i = 0; i < ret.bbxlist.size(); i++)
			outfile << ret.bbxlist[i].x << " " << ret.bbxlist[i].y << " " << ret.bbxlist[i].w << " " << ret.bbxlist[i].h << endl;

		outfile.close();
	}

	//开始画图。
	cv::Mat out_img = image.clone();

	//Draw the result.
	//Step 1: Draw result with adaboost result.
	draw_bounding_box(image, ret.ada_bbxlist);

	//Step 2: Draw result with CNN result.
	draw_bounding_box(out_img, ret.bbxlist);
    
	//cv::Mat concated = do_concate(image, out_img);
	string out_path = out_image_root + list_username + "_" + chlname + "_RESULT.jpg";
	cout << out_path << endl;
	imwrite(out_path.c_str(), out_img);

	
} 

int _tmain(int argc, char* argv[])
{
	
	cout << "Initializing core recognition program..." << endl;
	if ((_access("todo.tmp", 0)) != -1)
	{
		cout << "exist" << endl;
		DeleteFile(_T("todo.tmp"));//delete legacy file
	}
	head_counter_release_libInitialize();

	cout << "Initializing finished..." << endl;
	

	for (;;)
	{

		while ((_access("todo.tmp", 0)) == -1)
		{
			Sleep(30);
		} //waiting for tasklist.

		Sleep(10);
		Handler();
		DeleteFile(_T("todo.tmp"));
	}
	return 0;
}

