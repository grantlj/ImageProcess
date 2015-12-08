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
	int __stdcall InitDll(void);//��ʼ����
	int __stdcall FreeDll(void);//�ͷſ�
	int __stdcall Login(char *_ip, DWORD _port, char *_usernam, char *_pwd);//(������ip���������˿ڣ��ʺţ�����)
	void __stdcall SetCallBack(int(__stdcall *lp_CallBack)(int Commd_, char* buf_, int len_));//(��������ص�)
	int __stdcall GetList(char* _uribuf, int _devtype);//��ȡ�б�(ƽ̨�������豸����2-��ý��)
	int __stdcall GetDevChannelName(char* _uribuf, char* _devID);//��ȡ��ý��ͨ����ǩ(ƽ̨��������ý���豸ID)
	int __stdcall GetPic(char* _uribuf, char* _devID, int _Chan);//��ȡͼƬ(ƽ̨��������ý���豸ID,��ý���ͨ���Ŵ�0��ʼ)
};



typedef struct JF_ListInfo                      //SIP�б���Ϣ
{
	char	DeviceTypeId[4];					//�豸���ͣ�����ֵ��Ӧ��������Ѳ�����ݿ��еġ�usertypeinfo�����屣��һ��
	char    UserId[65];							//�豸ID
	char    LmtNum[65];							//��ý���豸���к�
	char    username[65];						//�û�����
	char	isOnline[2];						//0 �����ߣ�1 ���ߣ�
	char	userip_out[17];						//����IP��
	char	userip_in[17];						//����IP��
	char	userport_out[7];					//�����˿ڣ�
	char	userport_int[7];					//�����˿ڣ�
	int		channelNum;							//ͨ����
}JF_ListInfo;

//��ǰ֡ͼƬ;
cv::Mat now_frame;

//��ǰ�����list����š�
//int present_list_id;

//��ŵ�ǰȡ����listinfo
JF_ListInfo p_JF_ListInfo;

//�������listinfo
vector<JF_ListInfo> listInfo_list;

//��ŵ�ǰlist��Ӧ��channl��Ϣ��
vector<std::string> chlname_list;


//ȫ�ֱ�����ͼƬ��ȡ�ɹ���ǡ�
bool image_ok_flag = false;
//ȫ�ֱ�������½�ɹ���ǡ�
bool login_ok_flag = false;

//ȫ�ֱ�����ListInfo�Ƿ񷵻سɹ�
bool listinfo_ok_flag = false;

//ȫ�ֱ������ж�ͨ����ǩ�Ƿ񷵻سɹ�
bool channel_ok_flag = false;

//��½����ƽ̨������Ϣ��
char platform_domain_uir[156];

//��Ҫ��Ϣ�����������з��ؽ�����ڴ˴�����


int __stdcall callback(int Commd_, char* buf_, int len_)
{
	int err = 0;  //���ؽ��
	int lev = 0;//Ȩ�޼���
	//char buf[65*1024]={0}; //��������
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
	case 100: //��¼����


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


		//tmp.Format(LPCWSTR("\r\n��½����--err:%d,lve:%d,_uir:%s\r\n", err, lev, _uir));
		//OutputDebugString(tmp);
		break;
	case 101://�б���
		memcpy(wuri, buf_, 65);
		

		memcpy(&ltype, buf_ + 65, 4);
		memcpy(&num, buf_ + 65 + 4, 4);

		//num ���������б���������������ȡ�����ŵ�vector��
		for (int i = 0; i < num; i++)
		{
			memcpy(listinfo, buf_ + 65 + 4 + 4+i*sizeof(p_JF_ListInfo), sizeof(p_JF_ListInfo));
			memcpy(&p_JF_ListInfo, listinfo, sizeof(p_JF_ListInfo));
			listInfo_list.push_back(p_JF_ListInfo);
		}

		//�ж��Ƿ�ȡ���ɹ���
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
			if (tmpstr != "����")
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
			memcpy(wuri, buf_, 65);//Ѳ��ƽ̨����
			memcpy(wuserid, buf_ + 65, 65);//�豸ID
			memcpy(&chan, buf_ + 65 + 65, 4);//ͨ����
			memcpy(&ret, buf_ + 65 + 65 + 4, 4);//���ؽ��
			



			if (ret == 0)
			{
				memcpy(&lenn, buf_ + 65 + 65 + 4 + 4, 4);//ͼƬ�ܳ���
				memcpy(&packs, buf_ + 65 + 65 + 4 + 4 + 4, 4);//�ܰ�������ʾ���ֳɶ��ٸ���
				memcpy(&packstype, buf_ + 65 + 65 + 4 + 4 + 4 + 4, 4);//0-��ʼ����1-�м����2-������
				memcpy(&pack, buf_ + 65 + 65 + 4 + 4 + 4 + 4 + 4, 4);//��ʾ�ð��ǵڼ�����
				memcpy(listinfo, buf_ + 65 + 65 + 4 + 4 + 4 + 4 + 4 + 4, (len_)-(65 + 65 + 4 + 4 + 4 + 4 + 4 + 4));//��ʾͼƬ����
				
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

				//��������
				if (packstype == 2)
				{
					now_frame = cv::imread("tmp.jpg");
					image_ok_flag = true;
				}
			}  //end of getting.
			else
			{
				image_ok_flag = false;  //˵������ûȡ����
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