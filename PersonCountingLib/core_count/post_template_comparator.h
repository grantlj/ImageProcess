//后处理：模板匹配模块。
#ifndef _H_POST_TEMPLATE
#define _H_POST_TEMPLATE


#include "opencv2/objdetect/objdetect.hpp"
#include "opencv2/highgui/highgui.hpp"
#include "opencv2/imgproc/imgproc.hpp"
#include "opencv2/ml/ml.hpp"
#include <fstream>
#include <iostream>
#include <stdio.h>
#include <io.h>
#include <afxwin.h>
//#include "common_constants.h"

using namespace std;
using namespace cv;

#ifndef _BBX_
#define _BBX_
typedef struct BBX
{
	int x, y, w, h;
} BBX;
#endif

class position1
{
public:
	int m_x;
	int m_y;
	int m_wmin;
	int m_hmin;
	int m_wmax;
	int m_hmax;
	int m_wmean;
	int m_hmean;
public:
	position1(int x, int y, int wmin, int hmin, int wmax, int hmax, int wmean, int hmean)
	{
		m_x = x;
		m_y = y;
		m_wmin = wmin;
		m_hmin = hmin;
		m_wmax = wmax;
		m_hmax = hmax;
		m_wmean = wmean;
		m_hmean = hmean;
	}
};


class positionCollect
{
public: vector<position1> pos1;
public:
	void Add1(position1 &S)
	{
		pos1.push_back(S);
	}
};


vector<BBX> post_process_template_comparator(string template_filename, vector<BBX> in_bbxlist)
{
	if (_access(template_filename.c_str(), 0) == -1)
	{
		cout << "template not exist..." << template_filename << endl;
		return in_bbxlist;  //模板不存在 直接返回
	}
	vector<BBX> out_bbxlist;
	
	ifstream fin1(template_filename, ios_base::in);  //template input.
	
	//read in the template, define each pixel's size, etc.
	
	int x1, y1, x2, y2, x3, y3, x4, y4;
	CPoint PT[4];
	CRgn rgn;
	if (fin1)
	{
		fin1 >> x1;
		fin1 >> y1;
		fin1 >> x2;
		fin1 >> y2;
		fin1 >> x3;
		fin1 >> y3;
		fin1 >> x4;
		fin1 >> y4;
		PT[0].x = x1;
		PT[0].y = y1;
		PT[1].x = x2;
		PT[1].y = y2;
		PT[2].x = x3;
		PT[2].y = y3;
		PT[3].x = x4;
		PT[3].y = y4;//定义的四个点
		rgn.CreatePolygonRgn(PT, 4, WINDING);
	}

	fin1.close();



   //开始进行模板匹配
   for (int i = 0; i < in_bbxlist.size(); i++)
   {
	   //依次取出每个bounding box
	   int x = in_bbxlist[i].x; int y = in_bbxlist[i].y; int width = in_bbxlist[i].w; int height = in_bbxlist[i].h;
	  
	   CvPoint pt3;

	   pt3.x = (x + width / 2);
	   pt3.y = (y + height / 2);
	  
	   if (PtInRegion(rgn,pt3.x,pt3.y))
	
		 //是有效的bounding box
	     out_bbxlist.push_back(in_bbxlist[i]);

   }//end of i
   
   return out_bbxlist;
}

#endif