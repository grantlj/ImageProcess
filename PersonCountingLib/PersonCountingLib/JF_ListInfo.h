#ifndef _H_JFLISTINFO
#define _H_JFLISTINFO
typedef struct JF_ListInfo //设备列表结构体
{
	char DeviceTypeId[4]；//设备类型，各数值对应的类型与巡查数据库中的“usertypeinfo”定义保持一致
	char   UserId[65];//设备ID
	char    LmtNum[65];//流媒体设备序列号
	char   username[65];//用户名；
	char isOnline[2];//0 不再线；1 在线；
	char userip_out[17];//外网IP；
	char userip_in[17];//内网IP；
	char userport_out[7];//外网端口；
	char userport_int[7];//内网端口；
	int channelNum;// 通道数
}


#endif