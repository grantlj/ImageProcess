#ifndef _H_JFREGDATA
#define _H_JFREGDATA
#include <cstring>
typedef struct JF_RegisterData  //ע�����ݰ�
{
	char Sipuri[65];//SIP��������ת����������һ���ڵ����ϡ�zf���ַ������ͻ������˺�
	char Pswd[25];//SIP��ת����MD5���ͻ���������
	char Sipname[65];//�ñ������û���
	char DogNum[19];//��������к�
	char  Sip_version[255];//�汾��Ϣ/�ͻ��˰汾��
	char  Database_version[20];//���ݿ�汾��Ϣ
} JF_RegisterData;

#endif
