// PersonCountingLib.cpp : �������̨Ӧ�ó������ڵ㡣
//

#include "stdafx.h"
#include <iostream>
#include <string>
#include "ErrorOperator.h"
#include "SenseLockEncryptor.h"  //���ܹ�����
#include "GeneralHandler.h"      //�ѷ���˾�ײ�Э��
#include <Windows.h>
#include <stdio.h>
#include <cv.h>
#include <highgui.h>
#include <fstream>
#include "SOAPUploader.cpp"     //����Ļ��ʾSOAPͨѶģ�飨���̷߳�װ��
//#include "detect_core.h"
using namespace std;


// default setting parameters.
//web: admin 123456
//Login("222.177.140.97", 9909, "test", "123456");
//Server IP Address.

const string setting_file = "setting.dat";


string serv_ip = "222.177.140.97";
int serv_port = 9909;
string username = "dev";
string userpwd = "940414";
string raw_image_root_path = "D:\\test\\";
string out_image_root_path = "D:\\test_out\\";
string template_root_path = "D:\\templates\\";

HANDLE HSOAPMainThread;
DWORD  SOAPMainThreadID;

/*
string serv_ip = "222.177.140.120";
int serv_port = 9902;
string username = "zlkhd";
string userpwd = "123456";
string raw_image_root_path = "D:\\test\\";
string out_image_root_path = "D:\\test_out\\";
*/

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


//��������
void load_settings()
{
	if ((_access(setting_file.c_str(), 0)) == -1)
		return;  //setting file not exist.
	cout << "Loading setting file." << endl;
	ifstream fin(setting_file);
	getline(fin, serv_ip);
	string tmpstr_port;
	getline(fin, tmpstr_port);
	stringstream stream(tmpstr_port);
	stream >> serv_port;
	getline(fin, username);
	getline(fin, userpwd);
	getline(fin, raw_image_root_path);
	getline(fin, out_image_root_path);
	getline(fin, template_root_path);


}

void LockerVerify()
{
	//���ܹ���֤
	if (!LockerTester())
	{
	 	cout << "Locker test failed. Please check whether you have plugged in your locker." << endl;
		system("pause");
		exit(0);
	}

	cout << "Sense Locker verify passed..." << endl;
}

void initAndLogin()
{
	//���ܹ���֤��ϣ�����ѷ���˾�ײ�ͨ��������
	if (!InitDll())
	{
		cout << "JF dll module loading failed." << endl;
		system("pause");
		exit(0);
	}

	//���ûص�������
	SetCallBack(callback);

	//��½,�����߼����ص�������
	int login_try_count = 0;
	while ((login_try_count++) <= 4 && login_ok_flag == false)
	{
		char c_serv_ip[1024] = {0}; strcpy(c_serv_ip, serv_ip.c_str());
		char c_username[1024] = { 0 }; strcpy(c_username, username.c_str());
		char c_userpwd[1024] = { 0 }; strcpy(c_userpwd, userpwd.c_str());
		cout << "trying to login..." << endl;
		Login(c_serv_ip, serv_port, c_username, c_userpwd);
		//Login("222.177.140.120", 9902, "zlkhd", "123456");
		Sleep(3000);
	}


	if (login_ok_flag == false)
	{
		//���γ���ʧ�ܣ��˳���
		std::cout << "Login failed..." << endl;
		system("pause");
		exit(0);
	}

	std::cout << "Login succeed." << endl;
}

CString GetDomainName()
{
	//��ȡ�������������к��������õ�stmp
	CString  stmp(platform_domain_uir);
	int pos = stmp.Find(_T("#"));
	if (pos>0)
	{
		stmp = stmp.Mid(pos + 1);
	}
	pos = stmp.Find(_T(" "));
	if (pos>0)
	{
		stmp = stmp.Left(pos);
	}

	return stmp;

}

void GetListInfo(CString stmp)
{
//��Ϣ�����JFListInfo�ṹ���С�
	while (listinfo_ok_flag != true)
	{
		cout << "Getting list info..." << endl;
		listInfo_list.clear();
		GetList(CString2char(stmp), 2);
		Sleep(3000);  //һ��Ҫע��ʱ������
	}


	listinfo_ok_flag = false;  //ready for next time.
	//��ȡ�б���ɣ�׼����ȡchannel name��
	//cout << "list info get..." << endl;
}

bool GetChannelInfo(CString stmp, JF_ListInfo tmplist)
{
	//��ʼ����channel����ÿ������,��ȡͨ����ǩ��
	//present_list_id = i;
	int channel_try_count = 0;
	while (channel_ok_flag != true)
	{
		cout << "Getting channel info..." << endl;
		chlname_list.clear();
		channel_try_count++;
		if (channel_try_count > 8)
		{
			channel_ok_flag = false;
			return false;
		}
		GetDevChannelName(CString2char(stmp), tmplist.UserId);
		Sleep(3000);  //һ��Ҫע��ʱ������
	
	}

	channel_ok_flag = false;

	return true;

}

bool GetSingleImage(CString stmp, JF_ListInfo tmplist, int j)
{
	//704*576.
	int capture_try_count = 0;
	GetPic(CString2char(stmp), tmplist.UserId, j);
	//GetPic(CString2char(stmp), tmplist.UserId, j);
	while (image_ok_flag != true)
	{
		capture_try_count++;
		if (capture_try_count>5) break;
		cout << "Getting image of:" << chlname_list[j] << endl;

		Sleep(4000);
	}

	if (!image_ok_flag)
	{
		cout << "*** Request time out..." << endl;
		image_ok_flag = false;
		return false;
	}

	image_ok_flag = false;
	return true;
}

//����������
void initDetectCore()
{
	string cmd = "core_count.exe";
	WinExec(cmd.c_str(), SW_SHOW);
}

//���ú��ļ�����
void do_detection_and_update(string filename, string output_bbx_file_name, string tmplist_username, string chlname)
{
	//д�������ļ�todo.tmp����core_count���á�
	cout << output_bbx_file_name << endl;
	if (_access(output_bbx_file_name.c_str(), 0) != -1)
		remove(output_bbx_file_name.c_str());
		
	
	while ((_access("todo.tmp", 0)) != -1)
	{
		Sleep(10);
	};  //waiting for tasklist.

	ofstream outfile("todo.tmp");
	outfile << filename << endl;
	outfile << output_bbx_file_name << endl;
	outfile << tmplist_username << endl;
	outfile << chlname << endl;
	outfile << out_image_root_path << endl;
	outfile << template_root_path << endl;

	outfile.close();

	//�������ļ���

	while ((_access(output_bbx_file_name.c_str(), 0)) == -1)
	{
		Sleep(10);
	};  //waiting for result file.

	Sleep(50);
	ifstream re_file(output_bbx_file_name);

	string updateTime, roomNo=chlname;
	int studentCount;
	getline(re_file, updateTime);   //time stamp.
	re_file >> studentCount;        //student count.
    re_file.close();

	//do_soap_upload(chlname, studentCount, updateTime);
    //�����������Ϣ��SOAPMain������
	upload_data_package* now_data = new upload_data_package;
	now_data->chlname = chlname; now_data->studentCount = studentCount; now_data->updateTime = updateTime;
	while (PostThreadMessage(SOAPMainThreadID, 0, int(now_data), 0) == false)
	{
		Sleep(10);
	}
}


int _tmain(int argc, _TCHAR* argv[])
{
	cout << "Welcome to use!" << endl;
	LockerVerify();                       //��֤���ܹ� 
	load_settings();
	initDetectCore();                       //��ʼ�������ĳ���
	initAndLogin();                         //��ʼ������¼
	
	//��������ĻSOAP�����̣߳�
	HSOAPMainThread = CreateThread(NULL, 0, (LPTHREAD_START_ROUTINE)SOAPMain, NULL, 0, &SOAPMainThreadID);

	CString stmp = GetDomainName();         //��ȡȫ��SIP����
    //��ѭ����ʼ
	while (1)
	{
		//STEP 1:��ȡ�б�
		//�������list vector
		
		GetListInfo(stmp);
		

		//STEP 2: �����б��е�ÿһ������
		for (int i = 0; i < listInfo_list.size(); i++)
		{
			//ÿ������Ĵ����߼���ʼ��
			
			JF_ListInfo tmplist = listInfo_list[i];
			cout << tmplist.username;

			if (tmplist.isOnline == 0)
			{
				//��ǰ����offline,������
				cout << "---offline, skip..." << endl;
				continue;
			}

			cout << endl;

			
			if (!GetChannelInfo(stmp, tmplist))
			{
				//��ȡͨ����ǩ��Ϣʧ�ܡ�
				cout << "***Get Channel Info timeout..." << endl;
			}

			//STEP 3:��ȡͨ����ǩ�ɹ�����ʼ������ͼƬ��
			for (int j = 0; j < chlname_list.size(); j++)
			{
				if (!GetSingleImage(stmp, tmplist, j)) continue;
                
				//����ԭʼͼƬ
				std::string filename = raw_image_root_path + std::string(tmplist.username)+"_"+chlname_list[j] + ".jpg";
				//DetectResult re = do_detect(now_frame,filename,tmplist.username,chlname_list[j]);
				cv::imwrite(filename, now_frame);

				//Do detection task with outer exe file detect_core.exe
				//parameter list: image_file_name, output_bbx_file_name, tmplist.username, chlname_list[j]
				string output_bbx_file_name = out_image_root_path + std::string(tmplist.username) + "_" + chlname_list[j] + "_bbx_list.txt";
				do_detection_and_update(filename,output_bbx_file_name,tmplist.username,chlname_list[j]);
				//string cmd = "core_count.exe " + filename + " " + output_bbx_file_name + " " + tmplist.username + " " + chlname_list[j];
				//cout << cmd << " is cmd" << endl;
				//system(cmd.c_str());
             } //end of each channel.
        }  //end of each list element.
	
     LockerVerify();  //ÿһ�ֶ�Ҫ��֤���ܹ�

	}

	system("pause");
}
