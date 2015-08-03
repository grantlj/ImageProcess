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
		return in_bbxlist;  //模板不存在 直接返回
	
	vector<BBX> out_bbxlist;
	
	ifstream fin1(template_filename, ios_base::in);  //template input.
	
	//read in the template, define each pixel's size, etc.
	positionCollect s;
	int x1, y1, wmin, hmin, wmax, hmax, wmean, hmean;
	while (fin1)
	{
		fin1 >> x1;
		fin1 >> y1;
		fin1 >> wmin;
		fin1 >> hmin;
		fin1 >> wmax;
		fin1 >> hmax;
		fin1 >> wmean;
		fin1 >> hmean;
		position1 s1(x1, y1, wmin, wmax, wmean, hmin, hmax, hmean);
		s.Add1(s1);
	}
   fin1.close(); //close template info.


   //开始进行模板匹配
   for (int i = 0; i < in_bbxlist.size(); i++)
   {
	   //依次取出每个bounding box
	   int x = in_bbxlist[i].x; int y = in_bbxlist[i].y; int width = in_bbxlist[i].w; int height = in_bbxlist[i].h;
	  
	   CvPoint pt3;

	   pt3.x = (x + width / 2);
	   pt3.y = (y + height / 2);
	   for (int t = 0; t < s.pos1.size(); t++)
	   {
		   position1& s2 = s.pos1.at(t);   //容器的某一行放入到结构体 
		   if ((abs(s2.m_x - pt3.x) < 25) && (abs(s2.m_y - pt3.y)<25))
		   {
			   if ((width>0.5*s2.m_wmean) && (width<1.3*s2.m_wmean) && (height>0.5*s2.m_hmean) && (height < 1.3*s2.m_hmean))
			   {
				   //是有效的bounding box
				   out_bbxlist.push_back(in_bbxlist[i]);
				   break;
			   }  //end of inner if
		   } //end of outer if.
	   }  //end of t

   }//end of i
   
   return out_bbxlist;
}

#endif