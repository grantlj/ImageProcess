// PersonCountingLib.cpp : 定义控制台应用程序的入口点。
//

#include "stdafx.h"
#include <iostream>
#include <string>
#include "ErrorOperator.h"
#include "SenseLockEncryptor.h"  //加密狗程序
#include "GeneralHandler.h"      //佳发公司底层协议
#include <Windows.h>
#include <stdio.h>
#include <cv.h>
#include <highgui.h>
#include <fstream>
#include "SOAPUploader.cpp"     //大屏幕显示SOAP通讯模块（多线程封装）
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
	char* chRtn = (char*)malloc((len * 2 + 1)*sizeof(char));//CString的长度中汉字算一个长度   
	memset(chRtn, 0, 2 * len + 1);
	USES_CONVERSION;
	strcpy((LPSTR)chRtn, OLE2A(str.LockBuffer()));
	return chRtn;
}


//载入设置
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
	//加密狗验证
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
	//加密狗验证完毕，载入佳法公司底层通信驱动。
	if (!InitDll())
	{
		cout << "JF dll module loading failed." << endl;
		system("pause");
		exit(0);
	}

	//设置回调函数。
	SetCallBack(callback);

	//登陆,处理逻辑见回调函数。
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
		//三次尝试失败，退出。
		std::cout << "Login failed..." << endl;
		system("pause");
		exit(0);
	}

	std::cout << "Login succeed." << endl;
}

CString GetDomainName()
{
	//获取域名，以下所有函数都会用到stmp
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
//信息存放在JFListInfo结构体中。
	while (listinfo_ok_flag != true)
	{
		cout << "Getting list info..." << endl;
		listInfo_list.clear();
		GetList(CString2char(stmp), 2);
		Sleep(3000);  //一定要注意时间间隔。
	}


	listinfo_ok_flag = false;  //ready for next time.
	//获取列表完成，准备获取channel name。
	//cout << "list info get..." << endl;
}

bool GetChannelInfo(CString stmp, JF_ListInfo tmplist)
{
	//开始遍历channel，即每个教室,获取通道标签。
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
		Sleep(3000);  //一定要注意时间间隔。
	
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

//启动检测程序
void initDetectCore()
{
	string cmd = "core_count.exe";
	WinExec(cmd.c_str(), SW_SHOW);
}

//调用核心检测程序
void do_detection_and_update(string filename, string output_bbx_file_name, string tmplist_username, string chlname)
{
	//写入任务文件todo.tmp，供core_count调用。
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

	//读入结果文件。

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
    //将结果传递消息给SOAPMain函数。
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
	LockerVerify();                       //验证加密狗 
	load_settings();
	initDetectCore();                       //初始化检测核心程序
	initAndLogin();                         //初始化并登录
	
	//启动大屏幕SOAP传输线程；
	HSOAPMainThread = CreateThread(NULL, 0, (LPTHREAD_START_ROUTINE)SOAPMain, NULL, 0, &SOAPMainThreadID);

	CString stmp = GetDomainName();         //获取全局SIP域名
    //主循环开始
	while (1)
	{
		//STEP 1:获取列表。
		//首先清空list vector
		
		GetListInfo(stmp);
		

		//STEP 2: 遍历列表中的每一个机柜。
		for (int i = 0; i < listInfo_list.size(); i++)
		{
			//每个机柜的处理逻辑开始。
			
			JF_ListInfo tmplist = listInfo_list[i];
			cout << tmplist.username;

			if (tmplist.isOnline == 0)
			{
				//当前机柜offline,跳过。
				cout << "---offline, skip..." << endl;
				continue;
			}

			cout << endl;

			
			if (!GetChannelInfo(stmp, tmplist))
			{
				//获取通道标签信息失败。
				cout << "***Get Channel Info timeout..." << endl;
			}

			//STEP 3:获取通道标签成功，开始处理单张图片。
			for (int j = 0; j < chlname_list.size(); j++)
			{
				if (!GetSingleImage(stmp, tmplist, j)) continue;
                
				//保存原始图片
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
	
     LockerVerify();  //每一轮都要验证加密狗

	}

	system("pause");
}
