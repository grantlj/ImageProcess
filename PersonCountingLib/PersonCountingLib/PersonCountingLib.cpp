// PersonCountingLib.cpp : �������̨Ӧ�ó������ڵ㡣
//

#include "stdafx.h"
#include <iostream>
#include <string>
#include "Networker.h"
#include "RegHeart.h"
#include "ErrorOperator.h"
#include "GeneralPacket.h"
using namespace std;

Networker* worker;
int _tmain(int argc, _TCHAR* argv[])
{
	//Establish socket connection.
	//worker = new Networker("222.177.140.97", 9909);
	  worker = new Networker("222.177.140.120", 9902);
	//Register to the server.
	//ע���������
	GeneralPacket register_send_pack = GenerateRegisterPacket("zlkhd", "123456", "zlkhd", "00000000000000", "aaaa");
	worker->SendGeneralPacket(register_send_pack);

	//ע�᷵�ذ���
	GeneralPacket register_recv_pack;
	worker->RecvGeneralPacket(register_recv_pack);

	//worker->SendData(register_send_pack);


	system("pause");
}

////�����׽��ֿ�  
//

//WORD wVersionRequested;
//WSAData wsaData;
//int err;

//printf("This is a Client side application!\n");

//wVersionRequested = MAKEWORD(2, 2);

//err = WSAStartup(wVersionRequested, &wsaData);
//if (err != 0)
//{
//	/* Tell the user that we could not find a usable */
//	/* WinSock DLL.                                  */
//	printf("WSAStartup() called failed!\n");
//	return -1;
//}
//else
//{
//	printf("WSAStartup() called successful!\n");
//}

//if (LOBYTE(wsaData.wVersion) != 2 ||
//	HIBYTE(wsaData.wVersion) != 2) {
//	/* Tell the user that we could not find a usable */
//	/* WinSock DLL.                                  */
//	WSACleanup();
//	return -1;
//}

///* The WinSock DLL is acceptable. Proceed. */

////�����׽���  
//SOCKET sockClient = socket(AF_INET, SOCK_STREAM, 0);
//if (sockClient == INVALID_SOCKET)
//{
//	printf("socket() called failed! ,error code is: %d", WSAGetLastError());
//	return -1;
//}
//else
//{
//	printf("socket() called successful!\n");
//}

////��Ҫ���ӵķ�����׽��ֽṹ��Ϣ  
//SOCKADDR_IN addrServer;
//addrServer.sin_addr.S_un.S_addr = inet_addr(SERVERIP);//�趨��������IP��ַ  
//addrServer.sin_family = AF_INET;
//addrServer.sin_port = htons(SERVERPORT);//�趨�������Ķ˿ں�(ʹ�������ֽ���)  

////�������������������  
//err = connect(sockClient, (SOCKADDR*)&addrServer, sizeof(SOCKADDR));
//if (err == SOCKET_ERROR)
//{
//	printf("connect() called failed! The error code is: %d\n", WSAGetLastError());
//	return -1;
//}
//else
//{
//	printf("connect() called successful\n");
//}

////��������  
//char recvBuf[100] = { 0 };
//recv(sockClient, recvBuf, 100, 0);
//printf("receive data from server side is: %s\n", recvBuf);

////��������  
//send(sockClient, "This is a client side!\n", strlen("This is a client side!\n") + 1, 0);

////�ر��׽���  
//closesocket(sockClient);

////��ֹ�׽��ֿ��ʹ��  
//WSACleanup();
//
//return 0;