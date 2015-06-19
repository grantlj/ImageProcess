
// demoDlg.h : ͷ�ļ�
//
#include "CvvImage.h"  
#include <opencv2/core/core.hpp>  
#include <opencv2/highgui/highgui.hpp> 
#pragma once


// CdemoDlg �Ի���
class CdemoDlg : public CDialogEx
{
int ShowMat(cv::Mat img, HWND hWndDisplay);//��ʾMat 
// ����
public:
	CdemoDlg(CWnd* pParent = NULL);	// ��׼���캯��

// �Ի�������
	enum { IDD = IDD_DEMO_DIALOG };

	protected:
	virtual void DoDataExchange(CDataExchange* pDX);	// DDX/DDV ֧��


// ʵ��
protected:
	HICON m_hIcon;

	// ���ɵ���Ϣӳ�亯��
	virtual BOOL OnInitDialog();
	afx_msg void OnSysCommand(UINT nID, LPARAM lParam);
	afx_msg void OnPaint();
	afx_msg HCURSOR OnQueryDragIcon();
	DECLARE_MESSAGE_MAP()
public:
	afx_msg void OnBnClickedButton1();
    void DrawPicToHDC(IplImage *img, UINT ID);
//	void detectAndDraw( IplImage*img, CascadeClassifier& cascade, double scale);
	IplImage *image1;
	afx_msg void OnBnClickedButton2();
	afx_msg void OnStnClickedStatic2();
	afx_msg void OnBnClickedButton3();
	afx_msg void OnLbnSelchangeList2();
	afx_msg void OnLvnItemchangedList3(NMHDR *pNMHDR, LRESULT *pResult);
	static DWORD WINAPI automatic_detection(LPVOID lpParam);
	afx_msg void OnLbnSelchangeList1();
	afx_msg void OnLvnItemchangedList2(NMHDR *pNMHDR, LRESULT *pResult);
//	afx_msg void OnClose();
	afx_msg void OnBnClickedCancel();
	afx_msg void OnBnClickedOk();
	afx_msg void OnClose();
};
