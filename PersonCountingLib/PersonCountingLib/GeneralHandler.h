#ifndef _H_GEN_HANDLER
#define _H_GEN_HANDLER

#include <windef.h>

#include <cstring>
#include <vector>
#include <opencv2/opencv.hpp>
#include <highgui.h>
#include <io.h>
#include <string>
//#include <afx.h>

using namespace std;

#pragma comment(lib,"JF_CY.lib")
char _uir[156] = { 0 };
extern "C"
{
	int __stdcall InitDll(void);//初始化库
	int __stdcall FreeDll(void);//释放库
	int __stdcall Login(char *_ip, DWORD _port, char *_usernam, char *_pwd);//(服务器ip，服务器端口，帐号，密码)
	void __stdcall SetCallBack(int(__stdcall *lp_CallBack)(int Commd_, char* buf_, int len_));//(设置命令回调)
	int __stdcall GetList(char* _uribuf, int _devtype);//获取列表(平台域名，设备类型2-流媒体)
	int __stdcall GetDevChannelName(char* _uribuf, char* _devID);//获取流媒体通道标签(平台域名，流媒体设备ID)
	int __stdcall GetPic(char* _uribuf, char* _devID, int _Chan);//获取图片(平台域名，流媒体设备ID,流媒体的通道号从0开始)
};



typedef struct JF_ListInfo                      //SIP列表信息
{
	char	DeviceTypeId[4];					//设备类型，各数值对应的类型与巡查数据库中的“usertypeinfo”定义保持一致
	char    UserId[65];							//设备ID
	char    LmtNum[65];							//流媒体设备序列号
	char    username[65];						//用户名；
	char	isOnline[2];						//0 不再线；1 在线；
	char	userip_out[17];						//外网IP；
	char	userip_in[17];						//内网IP；
	char	userport_out[7];					//外网端口；
	char	userport_int[7];					//内网端口；
	int		channelNum;							//通道数
}JF_ListInfo;

//当前帧图片;
cv::Mat now_frame;

//当前处理的list的序号。
//int present_list_id;

//存放当前取到的listinfo
JF_ListInfo p_JF_ListInfo;

//存放所有listinfo
vector<JF_ListInfo> listInfo_list;

//存放当前list对应的channl信息；
vector<std::string> chlname_list;


//全局变量，图片获取成功标记。
bool image_ok_flag = false;
//全局变量，登陆成功标记。
bool login_ok_flag = false;

//全局变量，ListInfo是否返回成功
bool listinfo_ok_flag = false;

//全局变量，判断通道标签是否返回成功
bool channel_ok_flag = false;

//登陆返回平台域名信息。
char platform_domain_uir[156];

//主要消息处理函数，所有返回结果都在此处处理。


int __stdcall callback(int Commd_, char* buf_, int len_)
{
	int err = 0;  //返回结果
	int lev = 0;//权限级别
	//char buf[65*1024]={0}; //返回类容
	char wuri[65] = { 0 };
	char wuserid[65];
	int  ltype;
	int num;
	int  gtyep;
	char listinfo[200 * 1024] = { 0 };
	//char pa[2*1024]={0};
	int chan;
	int ret;
	int lenn;
	char channelname[32] = { 0 };
	CFile myf;
	CString tmp;
	int packs, packstype, pack;
	switch (Commd_)
	{
	case 100: //登录返回


		memcpy(&err, buf_, 4);

		memcpy(&lev, buf_ + 4, 4);
		memcpy(_uir, buf_ + 4 + 4, len_ - 4 - 4);

		cout << "Login response, err code:" << err<<", user level:" << lev << endl;
		if (err == 0)
		{
			login_ok_flag = true;
			strcpy_s(platform_domain_uir, _uir);
			//_uir = "123";
			//cout << platform_domain_uir << "((" << endl;
		}

		else
			login_ok_flag = false;


		//tmp.Format(LPCWSTR("\r\n登陆返回--err:%d,lve:%d,_uir:%s\r\n", err, lev, _uir));
		//OutputDebugString(tmp);
		break;
	case 101://列表返回
		memcpy(wuri, buf_, 65);
		

		memcpy(&ltype, buf_ + 65, 4);
		memcpy(&num, buf_ + 65 + 4, 4);

		//num 在这里是列表数量，我们依次取出，放到vector里
		for (int i = 0; i < num; i++)
		{
			memcpy(listinfo, buf_ + 65 + 4 + 4+i*sizeof(p_JF_ListInfo), sizeof(p_JF_ListInfo));
			memcpy(&p_JF_ListInfo, listinfo, sizeof(p_JF_ListInfo));
			listInfo_list.push_back(p_JF_ListInfo);
		}

		//判断是否取出成功。
		if (p_JF_ListInfo.username != "")
		{
			//cout << p_JF_ListInfo.username << endl;
			listinfo_ok_flag = true;
		}
		break;
	case 102:

		memcpy(wuri, buf_, 65);
		memcpy(wuserid, buf_ + 65, 65);
		memcpy(&num, buf_ + 65 + 65, 4);


		for (int i = 0; i < num; i++)
		{
			memcpy(listinfo, buf_ + 65 + 65 + 4 + i*32, 32);
			memcpy(channelname, listinfo, 32);
			std::string tmpstr(channelname);
			if (tmpstr != "备用")
			  chlname_list.push_back(tmpstr);
			//cout << channelname << endl;
			
		}
		//memcpy(listinfo, buf_ + 65 + 65 + 4, len_ - 65 - 65 - 4);
		//memcpy(channelname, listinfo, 32);
		
		
		
		if (channelname != "")
		{
		//	cout <<channelname << endl;
			channel_ok_flag = true;
		}
		break;

	case 103:
		try
		{
			/*
			//Legacy code which may cause errors.
			memcpy(wuri, buf_, 65);
			memcpy(wuserid, buf_ + 65, 65);
			memcpy(&chan, buf_ + 65 + 65, 4);
			memcpy(&ret, buf_ + 65 + 65 + 4, 4);
			memcpy(&lenn, buf_ + 65 + 65 + 4 + 4, 4);

			memcpy(listinfo, buf_ + 65 + 65 + 4 + 4 + 4, lenn);
			*/


			//New code.
			memcpy(wuri, buf_, 65);//巡查平台域名
			memcpy(wuserid, buf_ + 65, 65);//设备ID
			memcpy(&chan, buf_ + 65 + 65, 4);//通道号
			memcpy(&ret, buf_ + 65 + 65 + 4, 4);//返回结果
			



			if (ret == 0)
			{
				memcpy(&lenn, buf_ + 65 + 65 + 4 + 4, 4);//图片总长度
				memcpy(&packs, buf_ + 65 + 65 + 4 + 4 + 4, 4);//总包数，表示共分成多少个包
				memcpy(&packstype, buf_ + 65 + 65 + 4 + 4 + 4 + 4, 4);//0-开始包，1-中间包，2-结束包
				memcpy(&pack, buf_ + 65 + 65 + 4 + 4 + 4 + 4 + 4, 4);//表示该包是第几个包
				memcpy(listinfo, buf_ + 65 + 65 + 4 + 4 + 4 + 4 + 4 + 4, (len_)-(65 + 65 + 4 + 4 + 4 + 4 + 4 + 4));//表示图片数据
				
				char tmpfilename[1024];
				sprintf_s(tmpfilename, "tmp.jpg");
				if ((_access("tmp.jpg", 0)) != -1 && packstype==0)
					DeleteFile(_T("tmp.jpg"));
				/*
				char tmpfilename[1024];
				sprintf_s(tmpfilename, "tmp.jpg");
				if ((_access("tmp.jpg", 0)) != -1)
					DeleteFile(_T("tmp.jpg"));
				if (myf.Open(CString(tmpfilename), CFile::modeCreate | CFile::modeWrite))
				{
					myf.Write(listinfo, lenn);
					OutputDebugString(_T("\r\n"));
					OutputDebugString(tmp);
					myf.Close();
				}
				now_frame = cv::imread("tmp.jpg");
				//cvSetData(now_frame, listinfo, 704 * 3);
				image_ok_flag = true;
				//Legacy code.
				*/ 

				if (packstype == 0 || pack == 1)
				{
					if (myf.Open(CString(tmpfilename), CFile::modeCreate | CFile::modeWrite))
					{
						myf.Write(listinfo, len_ - (65 + 65 + 4 + 4 + 4 + 4 + 4 + 4));
						//OutputDebugString("\r\n");
						//OutputDebugString(tmp);
						myf.Close();
					}
				}
				else
				{
					if (myf.Open(CString(tmpfilename), CFile::modeWrite))
					{
						myf.SeekToEnd();
						myf.Write(listinfo, len_ - (65 + 65 + 4 + 4 + 4 + 4 + 4 + 4));
						//OutputDebugString("\r\n");
						//OutputDebugString(tmp);
						myf.Close();
					}
				}

				//结束包。
				if (packstype == 2)
				{
					now_frame = cv::imread("tmp.jpg");
					image_ok_flag = true;
				}
			}  //end of getting.
			else
			{
				image_ok_flag = false;  //说明根本没取到。
				cout << "Fetch image err:" << ret << endl;
			}
		}
		catch (const char *err_msg)
			{
			cout << "Fetch image err:" << err_msg << endl;
			    image_ok_flag = false;
			}
		
		//tmp.Format("D:\\test\\%d.jpg", chan);
		/*
		char tmpfilename[1024];
		sprintf(tmpfilename, "D:\\test\\%d.jpg", chan);
		if (myf.Open(CString(tmpfilename), CFile::modeCreate | CFile::modeWrite))
		{
			myf.Write(listinfo, lenn);
			OutputDebugString(LPCWSTR("\r\n"));
			OutputDebugString(tmp);
			myf.Close();
		}
		*/

		break;
	default://error
		cout << "Handler Error..." << endl;
		OutputDebugString(_T("\r\nerror id"));
		break;
	}
	return 1;
}


#endif