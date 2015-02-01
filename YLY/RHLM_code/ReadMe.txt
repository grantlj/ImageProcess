*************************************
The code for 'Multi-Feature Fusion via Hierarchical Regression for Multimedia Analysis'
14:01 2012-8-24

*************************************
1. The package contains 4 files, semisupervised.h, semiMultiViewGen.h, Laplacian_GK.h and evaluationMAP.m.

2. semisupervised(viewsTr, viewsTest, U, labelTr, labelnp) is the main function. 
% viewsTr is the training data cell. In our paper, since we have two views, viewsTr contains two elements, viewsTr{1} and viewsTr{2}, which are  m1*n1 and m2*n1 respectively.  n1��ѵ��������
����view��m1,m2��ɶ��
% viewsTest{1} is m1*n2, which is the testing data cell.    n2����������
% U is n*n, please refer to the paper to see how to construct U.   u��һ���ԽǾ��������i��������label��Uii=inf��������0
% labelTr is n1*c, which is the training label.    ѵ�������ı�ǩ��
% labelnp is n2*c, which is the testing lable.     ���������ı�ǩ��
% where n1 is the size of training data, and n2 is the size of test data
