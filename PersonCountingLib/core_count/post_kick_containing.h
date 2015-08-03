//后处理，提出重复包含bounding box
#ifndef _H_POST_CONTAIN
#define _H_POST_CONTAIN

#include "opencv2/objdetect/objdetect.hpp"
#include "opencv2/highgui/highgui.hpp"
#include "opencv2/imgproc/imgproc.hpp"
#include "opencv2/ml/ml.hpp"
#include <fstream>
#include <iostream>
#include <stdio.h>
#include <afxwin.h>
#include <vector>

#ifndef _BBX_
#define _BBX_
typedef struct BBX
{
	int x, y, w, h;
} BBX;
#endif

class position
{
public:
	int X;
	int Y;
	int W;
	int H;

public:
	position(int x, int y, int w, int h)
	{
		X = x;
		Y = y;
		W = w;
		H = h;

	}
};

vector<BBX> post_process_kick_contain(vector<BBX> in_bbxlist)
{
	vector<BBX> out_bbxlist;
	
	vector<position> pos1;
	vector<position> pos2;

	for (int i = 0; i < in_bbxlist.size(); i++)
	{
		position S(in_bbxlist[i].x, in_bbxlist[i].y, in_bbxlist[i].w, in_bbxlist[i].h);
		pos1.push_back(S);
		pos2.push_back(S);
	}

	//依次比较，删除重复。
	for (int m = 0; m < pos1.size(); m++)
	{
		int flag = 0;
		position& s1 = pos1.at(m);
		for (int n = 0; n < pos2.size(); n++)
		{
			position& s2 = pos2.at(n);
			if (((s1.X<s2.X) && (s1.Y <= s2.Y) && ((s1.X + s1.W) >= (s2.X + s2.W)) && ((s1.Y + s1.H) >= (s2.Y + s2.H))))
			{
				flag = 1;
			}
		}
		if (flag == 0)
		{
			BBX tmp;
			tmp.x = s1.X; tmp.y = s1.Y; tmp.w = s1.W; tmp.h = s1.H;
			out_bbxlist.push_back(tmp);
			
		}
	}

	return out_bbxlist;
}

#endif