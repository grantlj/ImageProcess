
// demoDlg.cpp : 实现文件
//

#include "stdafx.h"
#include "demo.h"
#include "demoDlg.h"
#include "afxdialogex.h"
#include "opencv2/objdetect/objdetect.hpp"
#include "opencv2/highgui/highgui.hpp"
#include "opencv2/imgproc/imgproc.hpp"
#include "opencv2/ml/ml.hpp"
#include <fstream>
#include <iostream>
#include <stdio.h>
#include <iostream>
#include <Windows.h>
#include "head_counter_release_lib.h"
#include "Resource.h"
#include <mmsystem.h> 
#include <string>
#pragma comment(lib,"head_counter_release_lib.lib")
#pragma comment(lib, "mclmcr.lib")
#pragma comment(lib, "mclmcrrt.lib")
#pragma comment(lib, "winmm.lib")
using namespace std;
using namespace cv;

#ifdef _DEBUG
#define new DEBUG_NEW
#endif



//定义路径

//存放级联检测器bounding box信息
const static string bdx_root_path = "D:\\bounding_1\\";

//存放原始图片信息
const static string raw_image_root_path = "D:\\raw_image\\";

//全局变量，当前处理的图片的bdx信息；
static string now_handling_bdx_path;

//全局变量，当前处理的图片的raw_image信息；
static string now_handling_raw_image_path;

//全局变量，全自动线程id
static LPDWORD automatic_id;

//全局变量，全自动线程handle
static HANDLE automatic_handle;

//全局变量，级联检测器文件名
const static String cascadeName = "cascadebest.xml";
//CdemoDlg dlg;

//全局变量，定义教室总数
const static int class_count = 50;

//全局变量，进程监测信号量

static bool detecting = false;

void detectAndDraw(IplImage*img, CascadeClassifier& cascade, double scale);



class CAboutDlg : public CDialogEx
{
public:
	CAboutDlg();

// 对话框数据
	enum { IDD = IDD_ABOUTBOX };

	protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV 支持

// 实现
protected:
	DECLARE_MESSAGE_MAP()
};

CAboutDlg::CAboutDlg() : CDialogEx(CAboutDlg::IDD)
{
}

void CAboutDlg::DoDataExchange(CDataExchange* pDX)
{
	CDialogEx::DoDataExchange(pDX);
}

BEGIN_MESSAGE_MAP(CAboutDlg, CDialogEx)
END_MESSAGE_MAP()


// CdemoDlg 对话框




CdemoDlg::CdemoDlg(CWnd* pParent /*=NULL*/)
	: CDialogEx(CdemoDlg::IDD, pParent)
{
	m_hIcon = AfxGetApp()->LoadIcon(IDR_MAINFRAME);
}

void CdemoDlg::DoDataExchange(CDataExchange* pDX)
{
	CDialogEx::DoDataExchange(pDX);
}

BEGIN_MESSAGE_MAP(CdemoDlg, CDialogEx)
	ON_WM_SYSCOMMAND()
	ON_WM_PAINT()
	ON_WM_QUERYDRAGICON()
	ON_BN_CLICKED(IDC_BUTTON1, &CdemoDlg::OnBnClickedButton1)
	ON_BN_CLICKED(IDC_BUTTON2, &CdemoDlg::OnBnClickedButton2)
	ON_BN_CLICKED(IDC_BUTTON3, &CdemoDlg::OnBnClickedButton3)
	ON_NOTIFY(LVN_ITEMCHANGED, IDC_LIST2, &CdemoDlg::OnLvnItemchangedList2)
	ON_WM_CLOSE()
END_MESSAGE_MAP()


// CdemoDlg 消息处理程序

//获取当前时间
string getTimeStamp()
{
	CTime time = CTime::GetCurrentTime();
	CString m_strTime = time.Format("%Y-%m-%d %H:%M:%S");
	return string(m_strTime);
}
BOOL CdemoDlg::OnInitDialog()
{
	CDialogEx::OnInitDialog();
	//dlg = this;
	
	CListCtrl *mlist =  (CListCtrl*) GetDlgItem(IDC_LIST2);

	//添加列表框的网格线
	DWORD dwStyle = mlist->GetExtendedStyle();                    
    dwStyle |= LVS_EX_FULLROWSELECT;
	dwStyle |= LVS_EX_GRIDLINES;

	mlist->SetExtendedStyle(dwStyle);
    mlist->InsertColumn(0, _T("教室编号"), LVCFMT_CENTER, 100);              
	mlist->InsertColumn(1, _T("检测人数"), LVCFMT_CENTER, 100);
	mlist->InsertColumn(2, _T("更新时间"), LVCFMT_CENTER, 200);
	mlist->InsertColumn(3, _T("检测时长(ms)"), LVCFMT_CENTER, 100);

	//初始化列表
	for (int i = 0; i < class_count; i++)
	{
		int id =class_count-i;
		char temp[4];
		sprintf(temp, "%d", id);
		int nIndex = mlist->InsertItem(0, string(temp).c_str());
		sprintf(temp, "%d", 0);
		mlist->SetItemText(nIndex, 1, string(temp).c_str());
		mlist->SetItemText(nIndex, 2, getTimeStamp().c_str());
		mlist->SetItemText(nIndex, 3, string(temp).c_str());
		
	}
	

	// 将“关于...”菜单项添加到系统菜单中。

	// IDM_ABOUTBOX 必须在系统命令范围内。
	//ASSERT((IDM_ABOUTBOX & 0xFFF0) == IDM_ABOUTBOX);
	//ASSERT(IDM_ABOUTBOX < 0xF000);

	/*
	CMenu* pSysMenu = GetSystemMenu(FALSE);
	if (pSysMenu != NULL)
	{
		BOOL bNameValid;
		CString strAboutMenu;
		bNameValid = strAboutMenu.LoadString(IDS_ABOUTBOX);
		ASSERT(bNameValid);
		if (!strAboutMenu.IsEmpty())
		{
			pSysMenu->AppendMenu(MF_SEPARATOR);
			pSysMenu->AppendMenu(MF_STRING, IDM_ABOUTBOX, strAboutMenu);
		}
	}
	*/

	// 设置此对话框的图标。当应用程序主窗口不是对话框时，框架将自动
	//  执行此操作
	SetIcon(m_hIcon, TRUE);			// 设置大图标
	SetIcon(m_hIcon, FALSE);		// 设置小图标

	// TODO: 在此添加额外的初始化代码

	//初始化matlab处理单元
	if (!mclInitializeApplication(NULL, 0))
	{
		std::cerr << "Could not initialize the application properly."
			<< std::endl;
		system("pause");
		//return -1;
	}
	// Initialize the Vigenere library
	if (!head_counter_release_libInitialize())
	{
		std::cerr << "Could not initialize the library properly."
			<< std::endl;
		system("pause");
		//return -1;
	}
	std::cout << "Initialization finished..." << std::endl;

	return TRUE;  // 除非将焦点设置到控件，否则返回 TRUE
}

void CdemoDlg::OnSysCommand(UINT nID, LPARAM lParam)
{
	/*
	if ((nID & 0xFFF0) == IDM_ABOUTBOX)
	{
		CAboutDlg dlgAbout;
		dlgAbout.DoModal();
	}
	else
	{
		CDialogEx::OnSysCommand(nID, lParam);
	}
	*/
}

// 如果向对话框添加最小化按钮，则需要下面的代码
//  来绘制该图标。对于使用文档/视图模型的 MFC 应用程序，
//  这将由框架自动完成。

void CdemoDlg::OnPaint()
{
	if (IsIconic())
	{
		CPaintDC dc(this); // 用于绘制的设备上下文

		SendMessage(WM_ICONERASEBKGND, reinterpret_cast<WPARAM>(dc.GetSafeHdc()), 0);

		// 使图标在工作区矩形中居中
		int cxIcon = GetSystemMetrics(SM_CXICON);
		int cyIcon = GetSystemMetrics(SM_CYICON);
		CRect rect;
		GetClientRect(&rect);
		int x = (rect.Width() - cxIcon + 1) / 2;
		int y = (rect.Height() - cyIcon + 1) / 2;

		// 绘制图标
		dc.DrawIcon(x, y, m_hIcon);
	}
	else
	{
		CDialogEx::OnPaint();
	}
}

//当用户拖动最小化窗口时系统调用此函数取得光标
//显示。
HCURSOR CdemoDlg::OnQueryDragIcon()
{
	return static_cast<HCURSOR>(m_hIcon);
}


int CdemoDlg::ShowMat(cv::Mat img, HWND hWndDisplay)   
{   
	if (img.channels()<3 ) { return -1; }   
	//构造将要显示的Mat版本图片   
	RECT rect;   
	::GetClientRect(hWndDisplay, &rect);   
	cv::Mat imgShow( abs(rect.top - rect.bottom), abs(rect.right - rect.left), CV_8UC3 );   
	resize( img, imgShow, imgShow.size() );   
	//在控件上显示要用到的CImage类图片   
	ATL::CImage CI;  
	int w=imgShow.cols;//宽   
	int h=imgShow.rows;//高   
	int channels=imgShow.channels();//通道数   
	CI.Create( w, h, 8*channels); //CI像素的复制   
	uchar *pS; uchar *pImg=(uchar *)CI.GetBits();//得到CImage数据区地址   
	int step=CI.GetPitch();   
	for(int i=0;i<h;i++)   
	{   
		pS=imgShow.ptr<uchar>(i);  
		for(int j=0;j<w;j++)   
		{   
			for(int k=0;k<3;k++)   
				*(pImg+i*step+j*3+k)=pS[j*3+k]; //注意到这里的step不用乘以3   
		}   
	}   
	//在控件显示图片   
	HDC dc ;   
	dc = ::GetDC(hWndDisplay);   
	CI.Draw( dc, 0, 0 );   
	::ReleaseDC( hWndDisplay, dc);   
	CI.Destroy();   
	return 0;   
}  


void CdemoDlg::OnBnClickedButton1()  //打开图片，将image1加载进去
{  
	// TODO: 在此添加控件通知处理程序代码  
	CString FilePath;   
	CFileDialog FileDlg(TRUE);   
	if (IDOK == FileDlg.DoModal())
	{
		//获取FileOpen对话框返回的路径名  
		FilePath = FileDlg.GetPathName();
		//GetPathName返回的是CString类型，要经过转换为string类型才能使用imread打开图片   
		std::string pathName(FilePath.GetBuffer());
		//读取图片   
		cv::Mat orgImg = cv::imread(pathName);
		//显示图片   
		ShowMat(orgImg, GetDlgItem(IDC_STATIC1)->GetSafeHwnd());


		//	 TODO: 在此添加控件通知处理程序代码
		// TODO: 在此添加控件通知处理程序代码
		CString filePath;
		CFileDialog dlg(
			TRUE,
			_T("*.jpg"),
			NULL,
			OFN_FILEMUSTEXIST | OFN_PATHMUSTEXIST | OFN_HIDEREADONLY,
			_TEXT("图像文件 (*.jpg; *.bmp)|*.jpg; *.bmp|所有文件 (*.*) |*.*||"),
			NULL
			);

		dlg.m_ofn.lpstrTitle = _T("选择图像");// 打开文件对话框的标题名

		if (dlg.DoModal() == IDOK)// 判断是否获得图片
		{
			filePath = dlg.GetPathName();// 获取图片路径
		}

	}
	else
		return;
}

void CdemoDlg::DrawPicToHDC(IplImage *img, UINT ID) //显示图片
{
	CDC *pDC = GetDlgItem(ID)->GetDC();
	HDC hDC = pDC->GetSafeHdc();
	CRect rect;
	GetDlgItem(ID)->GetClientRect(&rect);
	CvvImage cimg;
	cimg.CopyOf(img); // 复制图片
	cimg.DrawToHDC(hDC, &rect); // 将图片绘制到显示控件的指定区域内
	ReleaseDC(pDC);
}


//生成标注bounding box 之后的图片

int generate_annoted_image(mwArray bdx_label_mat, IplImage* imagenow,IplImage*& img_to_show)
{
	const static Scalar colors[] = { CV_RGB(0, 0, 255),
		CV_RGB(0, 128, 255),
		CV_RGB(0, 255, 255),
		CV_RGB(0, 255, 0),
		CV_RGB(255, 128, 0),
		CV_RGB(255, 255, 0),
		CV_RGB(255, 0, 0),
		CV_RGB(255, 0, 255) };
	//char txtfilename[256]; 
	//输入cnnboundingbox
	//sprintf(txtfilename, "D:\\raw_image\\1.jpg"); 
	//ifstream fin(txtfilename,ios_base::in); 
	Mat qimg(imagenow, 0);
	CvPoint pt3, pt4;
	int x1, y1, width1, height1;

	int m, n;
	//get row and column count.
	m = (bdx_label_mat.GetDimensions())(1);
	//n = (bdx_label_mat.GetDimensions())(2);

	for (int i = 0; i < m; i++)
	{
		x1 = (int)bdx_label_mat(i + 1, 1);
		y1 = (int)bdx_label_mat(i + 1, 2);
		width1 = (int)bdx_label_mat(i + 1, 3);
		height1 = (int)bdx_label_mat(i + 1, 4);
		pt3.x = x1;
		pt4.x = (x1 + width1);
		pt3.y = y1;
		pt4.y = (y1 + height1);
		rectangle(qimg, pt3, pt4, colors[6 % 8], 0.5, 8, 0);
	}

	img_to_show = cvCloneImage(&(IplImage)qimg);
	return m; //m为总人头数
}

void CdemoDlg::OnBnClickedButton2()//Adaboost+cnn
{
	//// TODO: 在此添加控件通知处理程序代码
	//String cascadeName = "cascadebest.xml"; 
	//CascadeClassifier cascade, nestedCascade;
	//double scale = 0.75;
	//if( !cascade.load( cascadeName ) )
	//{
	//	cerr << "ERROR: Could not load classifier cascade" << endl;
	//}
	//    //char name[100];
	//    //sprintf(name, "D:\\raw_image\\1.jpg");//将原始图放到该路径下
	//    //cvSave(name, image1);
	//	detectAndDraw( image1, cascade, scale );//得到Adaboost处理后的boundingbox.txt
	//
	////	waitKey(0);

	//mwArray bdx_path("D:\\bounding_1\\bounding_1.txt");
	//mwArray img_path("D:\\raw_image\\1.jpg");
	//mwArray bdx_label_mat;
	//head_counter_release(1, bdx_label_mat, img_path, bdx_path);

	////head_counter_release_libTerminate();
	////mclTerminateApplication();

	//
	//IplImage *img_to_show;
	//generate_annoted_image(bdx_label_mat, image1, img_to_show);
 //   DrawPicToHDC(img_to_show, IDC_STATIC2);
}

string detectAndDraw( IplImage*img,
	CascadeClassifier& cascade, 
	double scale,
	int id)
{
	//char name1[256]; 
	//sprintf_s(name1, "D:\\bounding_1\\bounding_1.txt" );
	char temp[4];
	sprintf(temp, "%d", id);
	string bdx_filename = bdx_root_path + (string(temp)) + ".txt";
	ofstream fout(bdx_filename.c_str()); 
	Mat pimg(img,0);
	int i = 0;
	double t = 0;
	int  s=0;
	vector<Rect> faces;
	const static Scalar colors[] =  {  CV_RGB(0,0,255),
		CV_RGB(0,128,255),
		CV_RGB(0,255,255),
		CV_RGB(0,255,0),
		CV_RGB(255,128,0),
		CV_RGB(255,255,0),
		CV_RGB(255,0,0),
		CV_RGB(255,0,255)} ;

	Mat gray, smallImg( cvRound (pimg.rows/scale), cvRound(pimg.cols/scale), CV_8UC1 );

	cvtColor( pimg, gray, COLOR_BGR2GRAY );
	resize( gray, smallImg, smallImg.size(), 0, 0, INTER_LINEAR );
	equalizeHist( smallImg, smallImg );

	//t = (double)getTickCount();
	cascade.detectMultiScale( smallImg, faces,1.1, 2, 0
		//|CV_HAAR_FIND_BIGGEST_OBJECT
		//|CV_HAAR_DO_ROUGH_SEARCH
		|CV_HAAR_SCALE_IMAGE,Size(24,24) );
   //t = (double)getTickCount() - t;
   //printf( "detection time = %g ms\n", t/((double)getTickFrequency()*1000.) );
	for( vector<Rect>::const_iterator r = faces.begin(); r != faces.end(); r++, i++ )
	{

		double R,B,G;
		double R1,B1,G1;
		int count=0;
		float ratio;
		CvPoint pt1, pt2;
		CvMat im = pimg;
		pt1.x = r->x*scale;
		pt2.x = (r->x+r->width)*scale;
		pt1.y = r->y*scale;
		pt2.y = (r->y+r->height)*scale;
		for(int m=pt1.y; m<pt2.y ;m++)  
		{  
			for(int n=pt1.x;n<pt2.x;n++)  
			{  

				CvScalar pixel = cvGet2D(&im, m, n);
				B=pixel.val[0];
				G=pixel.val[1];
				R=pixel.val[2];	
				if((B<70)&&(G<70)&&(R<70))count=count+1;
			} 			 
		}
		if(count!=0)ratio=float(((pt2.y-pt1.y)*(pt2.x-pt1.x)))/float(count); 
		CvScalar pixel1 = cvGet2D(&im, (pt1.y+r->height*scale/2), (pt1.x+r->width*scale/2));
		B1=pixel1.val[0];
		G1=pixel1.val[1];
		R1=pixel1.val[2];
		if((r->width*r->height)*scale*scale<4500)
		{

	//		rectangle( pimg, pt1, pt2, colors[6%8], 0.5, 8, 0 );
			s=s+1;
			 fout<<int(r->x*scale);
			    fout<<"\t";
			    fout<<int(r->y*scale);
			    fout<<"\t";
			    fout<<int(r->width*scale);
			    fout<<"\t";
			    fout<<int(r->height*scale)<<endl;
		}
	//	printf( "people = %d ",s);		
	}

	return bdx_filename;
}

//线程中更新前台图片
void thread_draw_pic(CdemoDlg *pp, IplImage* imagenow, UINT ID)
{
	CDC *pDC = pp->GetDlgItem(ID)->GetDC();
	HDC hDC = pDC->GetSafeHdc();
	CRect rect;
	pp->GetDlgItem(ID)->GetClientRect(&rect);
	CvvImage cimg;
	cimg.CopyOf(imagenow); // 复制图片
	cimg.DrawToHDC(hDC, &rect); // 将图片绘制到显示控件的指定区域内
	pp->ReleaseDC(pDC);
}

//全自动检测线程（模拟教室）
 DWORD WINAPI CdemoDlg::automatic_detection(LPVOID lpParam)
{
	 CdemoDlg *pp = (CdemoDlg *)CWnd::FromHandle((HWND)lpParam); //通过窗口句柄得到窗口的对象指针
	 CListCtrl *mlist = (CListCtrl*)pp->GetDlgItem(IDC_LIST2);
	 //载入级联检测器配置文件；
	
	 CascadeClassifier cascade, nestedCascade;
	 double scale = 0.75;
	 if (!cascade.load(cascadeName))
	 {
		 cerr << "ERROR: Could not load classifier cascade" << endl;
		 return -1;
	 }

	 while (1)
	 {
		 for (int i = 0; i < class_count; i++)
		 {
			 CString tmpstr;
			 tmpstr.Format(_T("当前教室ID=%d,检测中..."), (i+1));
			 detecting = true;
			 
			 pp->GetDlgItem(IDC_MAIN_LABEL)->SetWindowText(_T(tmpstr)); //通过窗口对象，更新界面
			 char temp[64];
			 sprintf(temp, "%d", (i+1));
			 string filename = raw_image_root_path;
			 filename = filename+(string(temp))+".jpg";

			 DWORD t1, t2;      //计算duration
			 t1 = timeGetTime();


			 IplImage* image1;
			 //载入图片
			 image1 = cvLoadImage(filename.c_str());

			 
			 //绘图至左侧原始图界面：
			 thread_draw_pic(pp, image1, IDC_STATIC1);
			 

			 string bdx_filename=detectAndDraw(image1, cascade, scale,i+1);//得到Adaboost处理后的boundingbox.txt

			 //运行CNN检测程序
			 mwArray mw_bdx_path(bdx_filename.c_str());
			 mwArray mw_img_path(filename.c_str());
			 mwArray mw_bdx_label_mat;
			 head_counter_release(1, mw_bdx_label_mat, mw_img_path, mw_bdx_path);


			 t2 = timeGetTime();

			 IplImage *img_to_show;

			 //生成检测图，返回检测人数
			 int people_count=generate_annoted_image(mw_bdx_label_mat, image1, img_to_show);
			 detecting = false;
			 mlist->DeleteItem(i);  //删除原有行，更新数据
			 mlist->InsertItem(i, string(temp).c_str());
			 sprintf(temp, "%d", people_count);
			 mlist->SetItemText(i, 1, string(temp).c_str());
			 mlist->SetItemText(i, 2, getTimeStamp().c_str());

			 sprintf(temp, "%ld", t2 - t1);
			 mlist->SetItemText(i, 3, string(temp).c_str());
			 thread_draw_pic(pp, img_to_show, IDC_STATIC2);

			 
			 //更新下方统计表
		 }
	 
	 //end of one round.
	 }
	return 0;
}

void CdemoDlg::OnBnClickedButton3()
{
	// TODO:  在此添加控件通知处理程序代码
	CButton  *btn3;
	//btn1 = (CButton*)GetDlgItem(IDC_BUTTON1);
	//btn2 = (CButton*)GetDlgItem(IDC_BUTTON2);
	btn3 = (CButton*)GetDlgItem(IDC_BUTTON3);

	CString btn3_text;
    btn3->GetWindowTextA(btn3_text);
	if (btn3_text=="开始监测")
	{
		//进入全自动模式，关闭按钮1，按纽2，选择图片使能；
		//btn1->EnableWindow(FALSE);
		//btn2->EnableWindow(FALSE);

		btn3->SetWindowTextA("停止监测");
        
		//获取自身句柄，创建自动检测线程。
		HWND nowhwnd = this->GetSafeHwnd();
		automatic_handle=CreateThread(NULL, 0, automatic_detection, nowhwnd, 0, automatic_id);
	}


	else
	{
		//退出全自动模式
		//btn1->EnableWindow(TRUE);
		//btn2->EnableWindow(TRUE);

		//终止自动检测线程。
		while (detecting)
		{
		}
		TerminateThread(automatic_handle, 0);
		btn3->SetWindowTextA("开始监测");
	}
	//btn3->SetWindowTextA("123");
	
}




void CdemoDlg::OnLbnSelchangeList1()
{
	// TODO:  在此添加控件通知处理程序代码
}


void CdemoDlg::OnLvnItemchangedList2(NMHDR *pNMHDR, LRESULT *pResult)
{
	LPNMLISTVIEW pNMLV = reinterpret_cast<LPNMLISTVIEW>(pNMHDR);
	// TODO:  在此添加控件通知处理程序代码
	*pResult = 0;
}


void CdemoDlg::OnClose()
{
	// TODO:  在此添加消息处理程序代码和/或调用默认值
	ExitProcess(0);
	CDialogEx::OnClose();
}
