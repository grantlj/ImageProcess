// vc_test.cpp : 定义控制台应用程序的入口点。
//

#include "stdafx.h"
#include <iostream>
#include <Windows.h>
#include "head_counter_release_lib.h"
#pragma comment(lib,"head_counter_release_lib.lib")
int _tmain(int argc, _TCHAR* argv[])
{
	// Initialize the MATLAB Compiler Runtime global state
	if (!mclInitializeApplication(NULL, 0))
	{
		std::cerr << "Could not initialize the application properly."
			<< std::endl;
		system("pause");
		return -1;
	}
	// Initialize the Vigenere library
	if (!head_counter_release_libInitialize())
	{
		std::cerr << "Could not initialize the library properly."
			<< std::endl;
		system("pause");
		return -1;
	}


	std::cout << "Initialization finished..." << std::endl;

	//head_counter_release(int nargout, mwArray& bdx_label_mat, const mwArray& img_path, const mwArray& bdx_path);
	mwArray bdx_path("D:\\1.txt");
	mwArray img_path("D:\\1.jpg");
	mwArray bdx_label_mat;
	head_counter_release(1, bdx_label_mat, img_path, bdx_path);

	head_counter_release_libTerminate();
	mclTerminateApplication();
    std::cout << "Terminated..." << std::endl;
	system("pause");
	return 0;
}

