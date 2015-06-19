
// demoDlg.h : 头文件
//
#include "CvvImage.h"  
#include <opencv2/core/core.hpp>  
#include <opencv2/highgui/highgui.hpp> 
#pragma once


// CdemoDlg 对话框
class CdemoDlg : public CDialogEx
{
int ShowMat(cv::Mat img, HWND hWndDisplay);//显示Mat 
// 构造
public:
	CdemoDlg(CWnd* pParent = NULL);	// 标准构造函数

// 对话框数据
	enum { IDD = IDD_DEMO_DIALOG };

	protected:
	virtual void DoDataExchange(CDataExchange* pDX);	// DDX/DDV 支持


// 实现
protected:
	HICON m_hIcon;

	// 生成的消息映射函数
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
