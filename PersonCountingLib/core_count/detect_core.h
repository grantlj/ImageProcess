#ifndef _H_DETECT_CORE
#define _H_DETECT_CORE
#include <afx.h>
#include <windef.h>
#include <opencv2/opencv.hpp>
#include <highgui.h>
#include <string>
#include <vector>
#include <iostream>

#include <Windows.h>
#include "head_counter_release_lib.h"
#include  <stdlib.h>
using namespace std;
using namespace cv;

#pragma comment(lib, "mclmcrrt.lib")
#pragma comment(lib, "mclmcr.lib")
#pragma comment(lib, "head_counter_release_lib.lib")

//�������б�ʶ��
bool run_for_first_time = true;

//�����������
CascadeClassifier cascade;

//�߶ȳ�����
const double scale = 0.75;

//������ļ�����
const string cascadeName = "cascadebest.xml";


//����bounding box�ṹ��
typedef struct BBX
{
	int x, y, w, h;
} BBX;


//���������ṹ��
typedef struct DetectResult
{
	cv::Mat rawimage; //ԭʼͼƬ
	cv::Mat reimage;  //�궨��ͼƬ
	int person_count; //������
	vector<BBX> bbxlist; //bounding box ��Ϣ
	string time_stamp;  //ʱ����Ϣ
} DetectResult;



//��ȡ��ǰʱ��
CString getTimeStamp()
{
	CTime time = CTime::GetCurrentTime();
	CString m_strTime = time.Format("%Y-%m-%d %H:%M:%S");
	return m_strTime;
}


//��������������
vector <BBX> detectWithCascade(cv::Mat pimg, const double scale)
{
	cout << "Detect with cascaded classifier." << endl;
	vector<BBX> ret;
	
	int i = 0;
	double t = 0;
	int  s = 0;
	vector<Rect> faces;
	const static Scalar colors[] = { CV_RGB(0, 0, 255),
		CV_RGB(0, 128, 255),
		CV_RGB(0, 255, 255),
		CV_RGB(0, 255, 0),
		CV_RGB(255, 128, 0),
		CV_RGB(255, 255, 0),
		CV_RGB(255, 0, 0),
		CV_RGB(255, 0, 255) };

	Mat gray;
	Mat smallImg(cvRound(pimg.rows / scale), cvRound(pimg.cols / scale), CV_8UC1);

	cvtColor(pimg, gray, COLOR_BGR2GRAY);
	resize(gray, smallImg, smallImg.size(), 0, 0, INTER_LINEAR);
	equalizeHist(smallImg, smallImg);

	cascade.detectMultiScale(smallImg, faces, 1.1, 2, 0
		//|CV_HAAR_FIND_BIGGEST_OBJECT
		//|CV_HAAR_DO_ROUGH_SEARCH
		| CV_HAAR_SCALE_IMAGE, Size(24, 24));

	for (vector<Rect>::const_iterator r = faces.begin(); r != faces.end(); r++, i++)
	{

		double R, B, G;
		double R1, B1, G1;
		int count = 0;
		float ratio;
		CvPoint pt1, pt2;
		CvMat im = pimg;
		pt1.x = r->x*scale;
		pt2.x = (r->x + r->width)*scale;
		pt1.y = r->y*scale;
		pt2.y = (r->y + r->height)*scale;
		for (int m = pt1.y; m<pt2.y; m++)
		{
			for (int n = pt1.x; n<pt2.x; n++)
			{

				CvScalar pixel = cvGet2D(&im, m, n);
				B = pixel.val[0];
				G = pixel.val[1];
				R = pixel.val[2];
				if ((B<70) && (G<70) && (R<70))count = count + 1;
			}
		}
		if (count != 0)ratio = float(((pt2.y - pt1.y)*(pt2.x - pt1.x))) / float(count);
		CvScalar pixel1 = cvGet2D(&im, (pt1.y + r->height*scale / 2), (pt1.x + r->width*scale / 2));
		B1 = pixel1.val[0];
		G1 = pixel1.val[1];
		R1 = pixel1.val[2];
		if ((r->width*r->height)*scale*scale<4500)
		{
			BBX tmpbbx;
			tmpbbx.x = round(r->x*scale);
			tmpbbx.y = round(r->y*scale);
			tmpbbx.w = round(r->width*scale);
			tmpbbx.h = round(r->height*scale);
			ret.push_back(tmpbbx);
		}	
	}

	return ret;

}


mwArray load_mw_input_data(const vector<BBX> bbxlist)
{
	mwArray ret(bbxlist.size(), 4, mxDOUBLE_CLASS);
	cout << "bbx size" << bbxlist.size() << endl;
	for (int i = 0; i < bbxlist.size(); i++)
	{
		ret(i + 1, 1) = bbxlist[i].x; ret(i + 1, 2) = bbxlist[i].y;
		ret(i + 1, 3) = bbxlist[i].w; ret(i + 1, 4) = bbxlist[i].h;
	}
	return ret;
}

vector<BBX> parse_mw_output_data(const mwArray bdx_label_mat)
{
	vector<BBX> ret;
	int m;
	//get row and column count.
	m = (bdx_label_mat.GetDimensions())(1);
	//cout << "out dimension" << m;
	for (int i = 0; i < m; i++)
	{
		BBX tmpbbx;
		tmpbbx.x = (int)bdx_label_mat(i + 1, 1);
		tmpbbx.y = (int)bdx_label_mat(i + 1, 2);
		tmpbbx.w = (int)bdx_label_mat(i + 1, 3);
		tmpbbx.h = (int)bdx_label_mat(i + 1, 4);
		
		ret.push_back(tmpbbx);
		
	}

	return ret;
}

//���������
//raw_image: ԭͼ
//filename:  ԭͼ·��
//listname   ��ǰ������������
//channelname ��ǰ��������

//���أ�DetectResult�ṹ��

//CString convert to char.
char* CString2char(CString &str)
{
	int len = str.GetLength();
	char* chRtn = (char*)malloc((len * 2 + 1)*sizeof(char));//CString�ĳ����к�����һ������   
	memset(chRtn, 0, 2 * len + 1);
	USES_CONVERSION;
	strcpy((LPSTR)chRtn, OLE2A(str.LockBuffer()));
	return chRtn;
}


DetectResult do_detect(cv::Mat raw_image, std::string filename, string listname, string channelname)
{
	if (run_for_first_time)
	{
		if (!cascade.load(cascadeName))
		{
			cout << "ERROR: Could not load cascade classifier." << endl;
			system("pause");
			exit(0);
		}
	}

	DetectResult ret;

	//first, detect with cascade classifer.
	vector<BBX> bbxlist = detectWithCascade(raw_image, scale);

	//Second, further detect with CNN.
	
	mwArray mw_img_path(filename.c_str());
	mwArray mw_input_bbxlist=load_mw_input_data(bbxlist); mwArray mw_output_bbxlist;


	cout << "Detect with CNN." << endl;
	head_counter_release(1, mw_output_bbxlist, mw_img_path, mw_input_bbxlist);

	bbxlist = parse_mw_output_data(mw_output_bbxlist);
	
	ret.rawimage = raw_image;
	ret.reimage = raw_image;
	ret.person_count = bbxlist.size();
	ret.time_stamp = CString2char(getTimeStamp());
	ret.bbxlist = bbxlist;
	return ret;
}
#endif 