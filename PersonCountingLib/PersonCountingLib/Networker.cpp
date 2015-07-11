
#include "stdafx.h"
#include "Networker.h"
#include <iostream>
using namespace std;
//Ensure that there always exist ONLY one socket connection.
bool Networker::instance_exist = false;



//Send General Packet.
bool Networker::SendGeneralPacket(const GeneralPacket gen_pack)
{
	try
    {
		this->SendData((char*)(&gen_pack.CmdLen), sizeof(gen_pack.CmdLen));
		this->SendData((char*)(&gen_pack.DeviceId), sizeof(gen_pack.DeviceId));
		this->SendData((char*)(&gen_pack.SubID),sizeof(gen_pack.SubID));
		this->SendData((char*)(&gen_pack.ProtocolVer),sizeof(gen_pack.ProtocolVer));
		this->SendData((char*)(&gen_pack.DataType),sizeof(gen_pack.DataType));
		this->SendData((char*)(&gen_pack.CommandID),sizeof(gen_pack.CommandID));
		this->SendData(gen_pack.Information, gen_pack.infosize);
	}
	catch (exception)
	{
		throw "Send General Packet Error.";
		return false;
	}
	return true;
}

//Recv General Packet.
bool Networker::RecvGeneralPacket(GeneralPacket& gen_pack)
{
	char* tmpstr=new char[16];
	try
	{
		cout<<this->RecvData(tmpstr, sizeof(gen_pack.CmdLen));
		gen_pack.CmdLen = (long) tmpstr;
		cout << "Cmd Len is:" << gen_pack.CmdLen<< endl;
	}
	catch (exception)
	{
		throw "Recv Genreal Packet Error.";
		return false;
	}

	return true;
}
//Send data with byte array.
bool Networker::SendData(const char* data, const int size)
{
	//cout << data << "send..."<<endl;
	try
	{
		if (send(sockClient, data, size, 0) < 0)
			cout<<"Error occur while sending data:"<<WSAGetLastError()<<endl;
		return true;
	}
	catch (exception)
	{
		throw "Error occur while sending data.";
		return false;
	}
}



//Recv data with byte array.
bool Networker::RecvData(char*& data, const int size)
{
	try
	{
		cout << "need to recving:" << size << endl;
		return recv(sockClient, data, size, 0);
		cout << "OK" << endl;
	}
	catch (exception)
	{
		throw "Error occur while recving data.";
		return false;
	}
	
	return true;
}


//Constructor.
Networker::Networker(string IPAddress, int port)
{
	if (instance_exist)
		throw "Socket Error. An socket has already been established.";
	
	this->serverip = IPAddress;
	this->port = port;

	//Setup WSA.
	this->SetupWSA();

	//Establish socket connection.
	this->EstablishConnection();
}

//SetupWSA;
bool Networker::SetupWSA()
{
	WORD wVersionRequested;
	WSAData wsaData;
	int err;
	wVersionRequested = MAKEWORD(2, 2);
	err = WSAStartup(wVersionRequested, &wsaData);
	if (err != 0)
	{
		/* Tell the user that we could not find a usable */
		/* WinSock DLL.                                  */
		throw ("WSA start up failed! Code:"+err);
		return false;
	}

	if (LOBYTE(wsaData.wVersion) != 2 ||
		HIBYTE(wsaData.wVersion) != 2) {
		/* Tell the user that we could not find a usable */
		/* WinSock DLL.                                  */
		WSACleanup();
		throw ("Can't find a usable winsock dll.");
		return false;
	}

	return true;

}

//EstablishConnection.
bool Networker::EstablishConnection()
{
	sockClient = socket(AF_INET, SOCK_STREAM, 0);
	if (sockClient == INVALID_SOCKET)
	{
		throw("socket called failed! Code:" + WSAGetLastError());
		return false;
	}

	SOCKADDR_IN addrServer;
    
	addrServer.sin_addr.S_un.S_addr = inet_addr(serverip.c_str());//set IP Address. 
	addrServer.sin_family = AF_INET;
	addrServer.sin_port = htons(port);//set port number. 
    
	int err;
	err = connect(sockClient, (SOCKADDR*)&addrServer, sizeof(SOCKADDR));
	if (err == SOCKET_ERROR)
	{
		throw ("Connection called failed. Code:" + WSAGetLastError());
		return false;
	}

	return true;


}

