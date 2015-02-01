文件说明：
1. feature_generator、get_feat_single_video、lagrange: 提取训练集/测试集video特征(选每个video的关键帧第二帧，跑Object bank的partless版本；再拉格朗日插值成20帧）

2、lsvm_generator: 迭代生成我们的svm model（保存在lsvm_model目录下）（详细注释）

3、run_lsvm_test_engine（调用lsvm_test_engine)显示test结果。（详细注释）