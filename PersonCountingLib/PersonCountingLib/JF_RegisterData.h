#ifndef _H_JFREGDATA
#define _H_JFREGDATA
#include <cstring>
typedef struct JF_RegisterData  //注册数据包
{
	char Sipuri[65];//SIP用域名，转发在域名第一个节点后加上“zf“字符串，客户端用账号
	char Pswd[25];//SIP，转发用MD5，客户端用密码
	char Sipname[65];//用别名、用户名
	char DogNum[19];//软件狗序列号
	char  Sip_version[255];//版本信息/客户端版本号
	char  Database_version[20];//数据库版本信息
} JF_RegisterData;

#endif
