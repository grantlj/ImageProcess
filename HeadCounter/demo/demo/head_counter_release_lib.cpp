//
// MATLAB Compiler: 5.2 (R2014b)
// Date: Mon May 25 09:43:18 2015
// Arguments: "-B" "macro_default" "-W" "cpplib:head_counter_release_lib" "-T"
// "link:lib" "-d"
// "D:\Matlab\ImageProcess\HeadCounter\head_counter_release_lib\for_testing"
// "-v" "D:\Matlab\ImageProcess\HeadCounter\head_counter_release.m" "-a"
// "D:\Matlab\ImageProcess\HeadCounter\cnn_mnist_naive_SVM_model.mat" "-a"
// "D:\Matlab\ImageProcess\HeadCounter\data_mean.mat" "-a" "C:\Program
// Files\MATLAB\R2014b\toolbox\libsvm-3.18\matlab\libsvmread.c" "-a"
// "C:\Program
// Files\MATLAB\R2014b\toolbox\libsvm-3.18\matlab\libsvmread.mexa64" "-a"
// "C:\Program
// Files\MATLAB\R2014b\toolbox\libsvm-3.18\matlab\libsvmread.mexw64" "-a"
// "C:\Program Files\MATLAB\R2014b\toolbox\libsvm-3.18\matlab\libsvmwrite.c"
// "-a" "C:\Program
// Files\MATLAB\R2014b\toolbox\libsvm-3.18\matlab\libsvmwrite.mexa64" "-a"
// "C:\Program
// Files\MATLAB\R2014b\toolbox\libsvm-3.18\matlab\libsvmwrite.mexw64" "-a"
// "C:\Program Files\MATLAB\R2014b\toolbox\libsvm-3.18\matlab\make.m" "-a"
// "C:\Program Files\MATLAB\R2014b\toolbox\libsvm-3.18\matlab\Makefile" "-a"
// "D:\Matlab\ImageProcess\HeadCounter\net-epoch-100.mat" "-a" "C:\Program
// Files\MATLAB\R2014b\toolbox\libsvm-3.18\matlab\README" "-a" "C:\Program
// Files\MATLAB\R2014b\toolbox\libsvm-3.18\matlab\svm_model_matlab.c" "-a"
// "C:\Program
// Files\MATLAB\R2014b\toolbox\libsvm-3.18\matlab\svm_model_matlab.h" "-a"
// "C:\Program Files\MATLAB\R2014b\toolbox\libsvm-3.18\matlab\svmpredict.c"
// "-a" "C:\Program
// Files\MATLAB\R2014b\toolbox\libsvm-3.18\matlab\svmpredict.mexa64" "-a"
// "C:\Program
// Files\MATLAB\R2014b\toolbox\libsvm-3.18\matlab\svmpredict.mexw64" "-a"
// "C:\Program Files\MATLAB\R2014b\toolbox\libsvm-3.18\matlab\svmtrain.c" "-a"
// "C:\Program Files\MATLAB\R2014b\toolbox\libsvm-3.18\matlab\svmtrain.mexa64"
// "-a" "C:\Program
// Files\MATLAB\R2014b\toolbox\libsvm-3.18\matlab\svmtrain.mexw64" "-a"
// "C:\Program
// Files\MATLAB\R2014b\toolbox\matconvnet-1.0-beta11\matlab\vl_argparse.m" "-a"
// "C:\Program
// Files\MATLAB\R2014b\toolbox\matconvnet-1.0-beta11\matlab\vl_compilenn.m"
// "-a" "C:\Program
// Files\MATLAB\R2014b\toolbox\matconvnet-1.0-beta11\matlab\mex\vl_imreadjpeg.me
// xw64" "-a" "C:\Program
// Files\MATLAB\R2014b\toolbox\matconvnet-1.0-beta11\matlab\vl_nnbnorm.m" "-a"
// "C:\Program
// Files\MATLAB\R2014b\toolbox\matconvnet-1.0-beta11\matlab\mex\vl_nnconv.mexw64
// " "-a" "C:\Program
// Files\MATLAB\R2014b\toolbox\matconvnet-1.0-beta11\matlab\vl_nndropout.m"
// "-a" "C:\Program
// Files\MATLAB\R2014b\toolbox\matconvnet-1.0-beta11\matlab\vl_nnloss.m" "-a"
// "C:\Program
// Files\MATLAB\R2014b\toolbox\matconvnet-1.0-beta11\matlab\vl_nnnoffset.m"
// "-a" "C:\Program
// Files\MATLAB\R2014b\toolbox\matconvnet-1.0-beta11\matlab\mex\vl_nnnormalize.m
// exw64" "-a" "C:\Program
// Files\MATLAB\R2014b\toolbox\matconvnet-1.0-beta11\matlab\vl_nnpdist.m" "-a"
// "C:\Program
// Files\MATLAB\R2014b\toolbox\matconvnet-1.0-beta11\matlab\mex\vl_nnpool.mexw64
// " "-a" "C:\Program
// Files\MATLAB\R2014b\toolbox\matconvnet-1.0-beta11\matlab\vl_nnrelu.m" "-a"
// "C:\Program
// Files\MATLAB\R2014b\toolbox\matconvnet-1.0-beta11\matlab\vl_nnsigmoid.m"
// "-a" "C:\Program
// Files\MATLAB\R2014b\toolbox\matconvnet-1.0-beta11\matlab\vl_nnsoftmax.m"
// "-a" "C:\Program
// Files\MATLAB\R2014b\toolbox\matconvnet-1.0-beta11\matlab\vl_nnsoftmaxloss.m"
// "-a" "C:\Program
// Files\MATLAB\R2014b\toolbox\matconvnet-1.0-beta11\matlab\vl_nnspnorm.m" "-a"
// "C:\Program
// Files\MATLAB\R2014b\toolbox\matconvnet-1.0-beta11\matlab\vl_rootnn.m" "-a"
// "C:\Program
// Files\MATLAB\R2014b\toolbox\matconvnet-1.0-beta11\matlab\vl_setupnn.m" "-a"
// "C:\Program
// Files\MATLAB\R2014b\toolbox\matconvnet-1.0-beta11\matlab\vl_simplenn.m" "-a"
// "C:\Program
// Files\MATLAB\R2014b\toolbox\matconvnet-1.0-beta11\matlab\vl_simplenn_diagnose
// .m" "-a" "C:\Program
// Files\MATLAB\R2014b\toolbox\matconvnet-1.0-beta11\matlab\vl_simplenn_display.
// m" "-a" "C:\Program
// Files\MATLAB\R2014b\toolbox\matconvnet-1.0-beta11\matlab\vl_simplenn_move.m" 
//

#include <stdio.h>
#define EXPORTING_head_counter_release_lib 1
#include "head_counter_release_lib.h"

static HMCRINSTANCE _mcr_inst = NULL;


#if defined( _MSC_VER) || defined(__BORLANDC__) || defined(__WATCOMC__) || defined(__LCC__)
#ifdef __LCC__
#undef EXTERN_C
#endif
#include <windows.h>

static char path_to_dll[_MAX_PATH];

BOOL WINAPI DllMain(HINSTANCE hInstance, DWORD dwReason, void *pv)
{
    if (dwReason == DLL_PROCESS_ATTACH)
    {
        if (GetModuleFileName(hInstance, path_to_dll, _MAX_PATH) == 0)
            return FALSE;
    }
    else if (dwReason == DLL_PROCESS_DETACH)
    {
    }
    return TRUE;
}
#endif
#ifdef __cplusplus
extern "C" {
#endif

static int mclDefaultPrintHandler(const char *s)
{
  return mclWrite(1 /* stdout */, s, sizeof(char)*strlen(s));
}

#ifdef __cplusplus
} /* End extern "C" block */
#endif

#ifdef __cplusplus
extern "C" {
#endif

static int mclDefaultErrorHandler(const char *s)
{
  int written = 0;
  size_t len = 0;
  len = strlen(s);
  written = mclWrite(2 /* stderr */, s, sizeof(char)*len);
  if (len > 0 && s[ len-1 ] != '\n')
    written += mclWrite(2 /* stderr */, "\n", sizeof(char));
  return written;
}

#ifdef __cplusplus
} /* End extern "C" block */
#endif

/* This symbol is defined in shared libraries. Define it here
 * (to nothing) in case this isn't a shared library. 
 */
#ifndef LIB_head_counter_release_lib_C_API
#define LIB_head_counter_release_lib_C_API /* No special import/export declaration */
#endif

LIB_head_counter_release_lib_C_API 
bool MW_CALL_CONV head_counter_release_libInitializeWithHandlers(
    mclOutputHandlerFcn error_handler,
    mclOutputHandlerFcn print_handler)
{
    int bResult = 0;
  if (_mcr_inst != NULL)
    return true;
  if (!mclmcrInitialize())
    return false;
  if (!GetModuleFileName(GetModuleHandle("head_counter_release_lib"), path_to_dll, _MAX_PATH))
    return false;
    {
        mclCtfStream ctfStream = 
            mclGetEmbeddedCtfStream(path_to_dll);
        if (ctfStream) {
            bResult = mclInitializeComponentInstanceEmbedded(   &_mcr_inst,
                                                                error_handler, 
                                                                print_handler,
                                                                ctfStream);
            mclDestroyStream(ctfStream);
        } else {
            bResult = 0;
        }
    }  
    if (!bResult)
    return false;
  return true;
}

LIB_head_counter_release_lib_C_API 
bool MW_CALL_CONV head_counter_release_libInitialize(void)
{
  return head_counter_release_libInitializeWithHandlers(mclDefaultErrorHandler, 
                                                        mclDefaultPrintHandler);
}

LIB_head_counter_release_lib_C_API 
void MW_CALL_CONV head_counter_release_libTerminate(void)
{
  if (_mcr_inst != NULL)
    mclTerminateInstance(&_mcr_inst);
}

LIB_head_counter_release_lib_C_API 
void MW_CALL_CONV head_counter_release_libPrintStackTrace(void) 
{
  char** stackTrace;
  int stackDepth = mclGetStackTrace(&stackTrace);
  int i;
  for(i=0; i<stackDepth; i++)
  {
    mclWrite(2 /* stderr */, stackTrace[i], sizeof(char)*strlen(stackTrace[i]));
    mclWrite(2 /* stderr */, "\n", sizeof(char)*strlen("\n"));
  }
  mclFreeStackTrace(&stackTrace, stackDepth);
}


LIB_head_counter_release_lib_C_API 
bool MW_CALL_CONV mlxHead_counter_release(int nlhs, mxArray *plhs[], int nrhs, mxArray 
                                          *prhs[])
{
  return mclFeval(_mcr_inst, "head_counter_release", nlhs, plhs, nrhs, prhs);
}

LIB_head_counter_release_lib_CPP_API 
void MW_CALL_CONV head_counter_release(int nargout, mwArray& bdx_label_mat, const 
                                       mwArray& img_path, const mwArray& bdx_path)
{
  mclcppMlfFeval(_mcr_inst, "head_counter_release", nargout, 1, 2, &bdx_label_mat, &img_path, &bdx_path);
}

