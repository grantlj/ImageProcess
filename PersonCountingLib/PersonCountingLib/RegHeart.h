#ifndef _H_REGHEART
#define _H_REGHEART
#include "GeneralPacket.h"
#include "JF_RegisterData.h"

#include <iostream>
using namespace std;
GeneralPacket GenerateRegisterPacket(
	string sipuri_s,
	string pswd_s,
	string dognum_s,
	string sip_ver_s,
	string database_ver)
{
	GeneralPacket gpack;

	//register request id.
	gpack.CommandID = 0x90000000;

	JF_RegisterData jf_pack;

	//save datas.
	strcpy_s(jf_pack.Sipuri,sipuri_s.c_str());
	strcpy_s(jf_pack.Pswd,pswd_s.c_str());
	strcpy_s(jf_pack.DogNum,dognum_s.c_str());
	strcpy_s(jf_pack.Sip_version,dognum_s.c_str());
	strcpy_s(jf_pack.Database_version,database_ver.c_str());

	
//	memcpy(info, &jf_pack, sizeof(JF_RegisterData));
	//cout << "jf pack:" << strlen(info) << endl;
    
	gpack.Information = new char[sizeof(JF_RegisterData)];
	memcpy(gpack.Information, &jf_pack, sizeof(JF_RegisterData));
	
	gpack.infosize = sizeof(JF_RegisterData);

	//计算包大小，要把指针的剪掉 再加上jf_pack的实际大小。
	gpack.CmdLen = sizeof(gpack) / 4 - 1 + sizeof(jf_pack) / 4;
	//gpack.CmdLen = 1;
	//cout << sizeof(gpack.Information) << endl;
	return gpack;
}

#endif