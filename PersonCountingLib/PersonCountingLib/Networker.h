#ifndef _H_NETWORKER
#define _H_NETWORKER

#include <WinSock2.h>
#pragma comment(lib, "ws2_32.lib")
#include <Windows.h>
#include <string>
#include "GeneralPacket.h"
using namespace std;

class Networker
{
public:
	Networker(string IPAddress, int port);
	//bool InitSocketConnection();
	bool SendData(const char* data, const int size);
	bool SendGeneralPacket(const GeneralPacket gen_pack);
	bool RecvGeneralPacket(GeneralPacket& gen_pack);
	//bool SendData(const GeneralPacket gen_pack);
	//bool RecvData(GeneralPacket& gen_pack);
	bool RecvData(char*& data, const int size);
	
private:
	Networker();
	bool SetupWSA();
	bool EstablishConnection();
	static bool instance_exist;
	string serverip;
	int port;
	SOCKET sockClient;
};
#endif
