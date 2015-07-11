#ifndef _H_GENPACKET
#define _H_GENPACKET
#pragma pack(1)
typedef struct GeneralPacket
{
	long CmdLen;
	char DeviceId = 2;
	char SubID = 8;
	char ProtocolVer = 0x09;
	char DataType = 0;
	unsigned long CommandID;
	char* Information;
    int infosize;
};
#endif