
#include <stdlib.h>
#include <malloc.h>
#include <windows.h>
#include <windef.h>
#include <tchar.h>
#include "CompilerPluginsPublic.h"


BOOL APIENTRY DllMain( HANDLE hModule, 
                       DWORD  ul_reason_for_call, 
                       LPVOID lpReserved
					 )
{
    return TRUE;
}


// 本插件代码针对"CompilerPluginsSample.e"文件进行编译前处理
BOOL WINAPI CompileProcessor (const COMPILE_PROCESSOR_INFO* pInf)
{
    if (_tcsicmp (pInf->m_szPurePrgFileName, _T("CompilerPluginsSample")) != 0)  // 不为指定的易语言程序名?
        return FALSE;  // 返回失败

    // 复制一份用作修改
    COMPILE_PROCESSOR_PRG_INFO infPrg;
    memcpy (&infPrg, &pInf->m_infPrg, sizeof (COMPILE_PROCESSOR_PRG_INFO));

    // 修改对应的程序设置信息
    infPrg.m_szPrgName = _T("插件测试程序");
    infPrg.m_szAuthor = _T("飞扬软件工作室");

    // 通知编译器修改待编译程序信息
    pInf->m_fnCallBack (pInf->m_pCallBackData, PCFN_SET_PRG_INFO, (DWORD)&infPrg, 0);

    // 修改所指定的数值常量
    const TCHAR* ps = _T("num");
    pInf->m_fnCallBack (pInf->m_pCallBackData, PCFN_SET_PRG_NUM_CONST, (DWORD)ps, 123);

    // 修改所指定的日期时间常量
    ps = _T("date");
    DATE dt = 42204;  // 2015/7/19
    pInf->m_fnCallBack (pInf->m_pCallBackData, PCFN_SET_PRG_DATE_TIME_CONST, (DWORD)ps, (DWORD)&dt);

    // 修改所指定的逻辑值常量
    ps = _T("bool");
    pInf->m_fnCallBack (pInf->m_pCallBackData, PCFN_SET_PRG_BOOL_CONST, (DWORD)ps, TRUE);

    // 修改所指定的文本型常量
    ps = _T("text");
    const TCHAR* szText = _T("编译前插件测试");
    pInf->m_fnCallBack (pInf->m_pCallBackData, PCFN_SET_PRG_TEXT_CONST, (DWORD)ps, (DWORD)szText);

    // 修改所指定的图片资源
    ps = _T("pic1");
    INT bin [] = { 4, 1234567 };
    pInf->m_fnCallBack (pInf->m_pCallBackData, PCFN_SET_PRG_BIN_CONST, (DWORD)ps, (DWORD)bin);

    return TRUE;  // 返回成功
}
