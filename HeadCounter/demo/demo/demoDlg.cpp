
// demoDlg.cpp : ʵ���ļ�
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



//����·��

//��ż��������bounding box��Ϣ
const static string bdx_root_path = "D:\\bounding_1\\";

//���ԭʼͼƬ��Ϣ
const static string raw_image_root_path = "D:\\raw_image\\";

//ȫ�ֱ�������ǰ�����ͼƬ��bdx��Ϣ��
static string now_handling_bdx_path;

//ȫ�ֱ�������ǰ�����ͼƬ��raw_image��Ϣ��
static string now_handling_raw_image_path;

//ȫ�ֱ�����ȫ�Զ��߳�id
static LPDWORD automatic_id;

//ȫ�ֱ�����ȫ�Զ��߳�handle
static HANDLE automatic_handle;

//ȫ�ֱ���������������ļ���
const static String cascadeName = "cascadebest.xml";
//CdemoDlg dlg;

//ȫ�ֱ����������������
const static int class_count = 50;

//ȫ�ֱ��������̼���ź���

static bool detecting = false;

void detectAndDraw(IplImage*img, CascadeClassifier& cascade, double scale);



class CAboutDlg : public CDialogEx
{
public:
	CAboutDlg();

// �Ի�������
	enum { IDD = IDD_ABOUTBOX };

	protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV ֧��

// ʵ��
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


// CdemoDlg �Ի���




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


// CdemoDlg ��Ϣ�������

//��ȡ��ǰʱ��
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

	//����б���������
	DWORD dwStyle = mlist->GetExtendedStyle();                    
    dwStyle |= LVS_EX_FULLROWSELECT;
	dwStyle |= LVS_EX_GRIDLINES;

	mlist->SetExtendedStyle(dwStyle);
    mlist->InsertColumn(0, _T("���ұ��"), LVCFMT_CENTER, 100);              
	mlist->InsertColumn(1, _T("�������"), LVCFMT_CENTER, 100);
	mlist->InsertColumn(2, _T("����ʱ��"), LVCFMT_CENTER, 200);
	mlist->InsertColumn(3, _T("���ʱ��(ms)"), LVCFMT_CENTER, 100);

	//��ʼ���б�
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
	

	// ��������...���˵�����ӵ�ϵͳ�˵��С�

	// IDM_ABOUTBOX ������ϵͳ���Χ�ڡ�
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

	// ���ô˶Ի����ͼ�ꡣ��Ӧ�ó��������ڲ��ǶԻ���ʱ����ܽ��Զ�
	//  ִ�д˲���
	SetIcon(m_hIcon, TRUE);			// ���ô�ͼ��
	SetIcon(m_hIcon, FALSE);		// ����Сͼ��

	// TODO: �ڴ���Ӷ���ĳ�ʼ������

	//��ʼ��matlab����Ԫ
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

	return TRUE;  // ���ǽ��������õ��ؼ������򷵻� TRUE
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

// �����Ի��������С����ť������Ҫ����Ĵ���
//  �����Ƹ�ͼ�ꡣ����ʹ���ĵ�/��ͼģ�͵� MFC Ӧ�ó���
//  �⽫�ɿ���Զ���ɡ�

void CdemoDlg::OnPaint()
{
	if (IsIconic())
	{
		CPaintDC dc(this); // ���ڻ��Ƶ��豸������

		SendMessage(WM_ICONERASEBKGND, reinterpret_cast<WPARAM>(dc.GetSafeHdc()), 0);

		// ʹͼ���ڹ����������о���
		int cxIcon = GetSystemMetrics(SM_CXICON);
		int cyIcon = GetSystemMetrics(SM_CYICON);
		CRect rect;
		GetClientRect(&rect);
		int x = (rect.Width() - cxIcon + 1) / 2;
		int y = (rect.Height() - cyIcon + 1) / 2;

		// ����ͼ��
		dc.DrawIcon(x, y, m_hIcon);
	}
	else
	{
		CDialogEx::OnPaint();
	}
}

//���û��϶���С������ʱϵͳ���ô˺���ȡ�ù��
//��ʾ��
HCURSOR CdemoDlg::OnQueryDragIcon()
{
	return static_cast<HCURSOR>(m_hIcon);
}


int CdemoDlg::ShowMat(cv::Mat img, HWND hWndDisplay)   
{   
	if (img.channels()<3 ) { return -1; }   
	//���콫Ҫ��ʾ��Mat�汾ͼƬ   
	RECT rect;   
	::GetClientRect(hWndDisplay, &rect);   
	cv::Mat imgShow( abs(rect.top - rect.bottom), abs(rect.right - rect.left), CV_8UC3 );   
	resize( img, imgShow, imgShow.size() );   
	//�ڿؼ�����ʾҪ�õ���CImage��ͼƬ   
	ATL::CImage CI;  
	int w=imgShow.cols;//��   
	int h=imgShow.rows;//��   
	int channels=imgShow.channels();//ͨ����   
	CI.Create( w, h, 8*channels); //CI���صĸ���   
	uchar *pS; uchar *pImg=(uchar *)CI.GetBits();//�õ�CImage��������ַ   
	int step=CI.GetPitch();   
	for(int i=0;i<h;i++)   
	{   
		pS=imgShow.ptr<uchar>(i);  
		for(int j=0;j<w;j++)   
		{   
			for(int k=0;k<3;k++)   
				*(pImg+i*step+j*3+k)=pS[j*3+k]; //ע�⵽�����step���ó���3   
		}   
	}   
	//�ڿؼ���ʾͼƬ   
	HDC dc ;   
	dc = ::GetDC(hWndDisplay);   
	CI.Draw( dc, 0, 0 );   
	::ReleaseDC( hWndDisplay, dc);   
	CI.Destroy();   
	return 0;   
}  


void CdemoDlg::OnBnClickedButton1()  //��ͼƬ����image1���ؽ�ȥ
{  
	// TODO: �ڴ���ӿؼ�֪ͨ����������  
	CString FilePath;   
	CFileDialog FileDlg(TRUE);   
	if (IDOK == FileDlg.DoModal())
	{
		//��ȡFileOpen�Ի��򷵻ص�·����  
		FilePath = FileDlg.GetPathName();
		//GetPathName���ص���CString���ͣ�Ҫ����ת��Ϊstring���Ͳ���ʹ��imread��ͼƬ   
		std::string pathName(FilePath.GetBuffer());
		//��ȡͼƬ   
		cv::Mat orgImg = cv::imread(pathName);
		//��ʾͼƬ   
		ShowMat(orgImg, GetDlgItem(IDC_STATIC1)->GetSafeHwnd());


		//	 TODO: �ڴ���ӿؼ�֪ͨ����������
		// TODO: �ڴ���ӿؼ�֪ͨ����������
		CString filePath;
		CFileDialog dlg(
			TRUE,
			_T("*.jpg"),
			NULL,
			OFN_FILEMUSTEXIST | OFN_PATHMUSTEXIST | OFN_HIDEREADONLY,
			_TEXT("ͼ���ļ� (*.jpg; *.bmp)|*.jpg; *.bmp|�����ļ� (*.*) |*.*||"),
			NULL
			);

		dlg.m_ofn.lpstrTitle = _T("ѡ��ͼ��");// ���ļ��Ի���ı�����

		if (dlg.DoModal() == IDOK)// �ж��Ƿ���ͼƬ
		{
			filePath = dlg.GetPathName();// ��ȡͼƬ·��
		}

	}
	else
		return;
}

void CdemoDlg::DrawPicToHDC(IplImage *img, UINT ID) //��ʾͼƬ
{
	CDC *pDC = GetDlgItem(ID)->GetDC();
	HDC hDC = pDC->GetSafeHdc();
	CRect rect;
	GetDlgItem(ID)->GetClientRect(&rect);
	CvvImage cimg;
	cimg.CopyOf(img); // ����ͼƬ
	cimg.DrawToHDC(hDC, &rect); // ��ͼƬ���Ƶ���ʾ�ؼ���ָ��������
	ReleaseDC(pDC);
}


//���ɱ�עbounding box ֮���ͼƬ

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
	//����cnnboundingbox
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
	return m; //mΪ����ͷ��
}

void CdemoDlg::OnBnClickedButton2()//Adaboost+cnn
{
	//// TODO: �ڴ���ӿؼ�֪ͨ����������
	//String cascadeName = "cascadebest.xml"; 
	//CascadeClassifier cascade, nestedCascade;
	//double scale = 0.75;
	//if( !cascade.load( cascadeName ) )
	//{
	//	cerr << "ERROR: Could not load classifier cascade" << endl;
	//}
	//    //char name[100];
	//    //sprintf(name, "D:\\raw_image\\1.jpg");//��ԭʼͼ�ŵ���·����
	//    //cvSave(name, image1);
	//	detectAndDraw( image1, cascade, scale );//�õ�Adaboost������boundingbox.txt
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

//�߳��и���ǰ̨ͼƬ
void thread_draw_pic(CdemoDlg *pp, IplImage* imagenow, UINT ID)
{
	CDC *pDC = pp->GetDlgItem(ID)->GetDC();
	HDC hDC = pDC->GetSafeHdc();
	CRect rect;
	pp->GetDlgItem(ID)->GetClientRect(&rect);
	CvvImage cimg;
	cimg.CopyOf(imagenow); // ����ͼƬ
	cimg.DrawToHDC(hDC, &rect); // ��ͼƬ���Ƶ���ʾ�ؼ���ָ��������
	pp->ReleaseDC(pDC);
}

//ȫ�Զ�����̣߳�ģ����ң�
 DWORD WINAPI CdemoDlg::automatic_detection(LPVOID lpParam)
{
	 CdemoDlg *pp = (CdemoDlg *)CWnd::FromHandle((HWND)lpParam); //ͨ�����ھ���õ����ڵĶ���ָ��
	 CListCtrl *mlist = (CListCtrl*)pp->GetDlgItem(IDC_LIST2);
	 //���뼶������������ļ���
	
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
			 tmpstr.Format(_T("��ǰ����ID=%d,�����..."), (i+1));
			 detecting = true;
			 
			 pp->GetDlgItem(IDC_MAIN_LABEL)->SetWindowText(_T(tmpstr)); //ͨ�����ڶ��󣬸��½���
			 char temp[64];
			 sprintf(temp, "%d", (i+1));
			 string filename = raw_image_root_path;
			 filename = filename+(string(temp))+".jpg";

			 DWORD t1, t2;      //����duration
			 t1 = timeGetTime();


			 IplImage* image1;
			 //����ͼƬ
			 image1 = cvLoadImage(filename.c_str());

			 
			 //��ͼ�����ԭʼͼ���棺
			 thread_draw_pic(pp, image1, IDC_STATIC1);
			 

			 string bdx_filename=detectAndDraw(image1, cascade, scale,i+1);//�õ�Adaboost������boundingbox.txt

			 //����CNN������
			 mwArray mw_bdx_path(bdx_filename.c_str());
			 mwArray mw_img_path(filename.c_str());
			 mwArray mw_bdx_label_mat;
			 head_counter_release(1, mw_bdx_label_mat, mw_img_path, mw_bdx_path);


			 t2 = timeGetTime();

			 IplImage *img_to_show;

			 //���ɼ��ͼ�����ؼ������
			 int people_count=generate_annoted_image(mw_bdx_label_mat, image1, img_to_show);
			 detecting = false;
			 mlist->DeleteItem(i);  //ɾ��ԭ���У���������
			 mlist->InsertItem(i, string(temp).c_str());
			 sprintf(temp, "%d", people_count);
			 mlist->SetItemText(i, 1, string(temp).c_str());
			 mlist->SetItemText(i, 2, getTimeStamp().c_str());

			 sprintf(temp, "%ld", t2 - t1);
			 mlist->SetItemText(i, 3, string(temp).c_str());
			 thread_draw_pic(pp, img_to_show, IDC_STATIC2);

			 
			 //�����·�ͳ�Ʊ�
		 }
	 
	 //end of one round.
	 }
	return 0;
}

void CdemoDlg::OnBnClickedButton3()
{
	// TODO:  �ڴ���ӿؼ�֪ͨ����������
	CButton  *btn3;
	//btn1 = (CButton*)GetDlgItem(IDC_BUTTON1);
	//btn2 = (CButton*)GetDlgItem(IDC_BUTTON2);
	btn3 = (CButton*)GetDlgItem(IDC_BUTTON3);

	CString btn3_text;
    btn3->GetWindowTextA(btn3_text);
	if (btn3_text=="��ʼ���")
	{
		//����ȫ�Զ�ģʽ���رհ�ť1����Ŧ2��ѡ��ͼƬʹ�ܣ�
		//btn1->EnableWindow(FALSE);
		//btn2->EnableWindow(FALSE);

		btn3->SetWindowTextA("ֹͣ���");
        
		//��ȡ�������������Զ�����̡߳�
		HWND nowhwnd = this->GetSafeHwnd();
		automatic_handle=CreateThread(NULL, 0, automatic_detection, nowhwnd, 0, automatic_id);
	}


	else
	{
		//�˳�ȫ�Զ�ģʽ
		//btn1->EnableWindow(TRUE);
		//btn2->EnableWindow(TRUE);

		//��ֹ�Զ�����̡߳�
		while (detecting)
		{
		}
		TerminateThread(automatic_handle, 0);
		btn3->SetWindowTextA("��ʼ���");
	}
	//btn3->SetWindowTextA("123");
	
}




void CdemoDlg::OnLbnSelchangeList1()
{
	// TODO:  �ڴ���ӿؼ�֪ͨ����������
}


void CdemoDlg::OnLvnItemchangedList2(NMHDR *pNMHDR, LRESULT *pResult)
{
	LPNMLISTVIEW pNMLV = reinterpret_cast<LPNMLISTVIEW>(pNMHDR);
	// TODO:  �ڴ���ӿؼ�֪ͨ����������
	*pResult = 0;
}


void CdemoDlg::OnClose()
{
	// TODO:  �ڴ������Ϣ�����������/�����Ĭ��ֵ
	ExitProcess(0);
	CDialogEx::OnClose();
}
