#ifndef _H_JFLISTINFO
#define _H_JFLISTINFO
typedef struct JF_ListInfo //�豸�б�ṹ��
{
	char DeviceTypeId[4]��//�豸���ͣ�����ֵ��Ӧ��������Ѳ�����ݿ��еġ�usertypeinfo�����屣��һ��
	char   UserId[65];//�豸ID
	char    LmtNum[65];//��ý���豸���к�
	char   username[65];//�û�����
	char isOnline[2];//0 �����ߣ�1 ���ߣ�
	char userip_out[17];//����IP��
	char userip_in[17];//����IP��
	char userport_out[7];//�����˿ڣ�
	char userport_int[7];//�����˿ڣ�
	int channelNum;// ͨ����
}


#endif