
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


// ������������"CompilerPluginsSample.e"�ļ����б���ǰ����
BOOL WINAPI CompileProcessor (const COMPILE_PROCESSOR_INFO* pInf)
{
    if (_tcsicmp (pInf->m_szPurePrgFileName, _T("CompilerPluginsSample")) != 0)  // ��Ϊָ���������Գ�����?
        return FALSE;  // ����ʧ��

    // ����һ�������޸�
    COMPILE_PROCESSOR_PRG_INFO infPrg;
    memcpy (&infPrg, &pInf->m_infPrg, sizeof (COMPILE_PROCESSOR_PRG_INFO));

    // �޸Ķ�Ӧ�ĳ���������Ϣ
    infPrg.m_szPrgName = _T("������Գ���");
    infPrg.m_szAuthor = _T("�������������");

    // ֪ͨ�������޸Ĵ����������Ϣ
    pInf->m_fnCallBack (pInf->m_pCallBackData, PCFN_SET_PRG_INFO, (DWORD)&infPrg, 0);

    // �޸���ָ������ֵ����
    const TCHAR* ps = _T("num");
    pInf->m_fnCallBack (pInf->m_pCallBackData, PCFN_SET_PRG_NUM_CONST, (DWORD)ps, 123);

    // �޸���ָ��������ʱ�䳣��
    ps = _T("date");
    DATE dt = 42204;  // 2015/7/19
    pInf->m_fnCallBack (pInf->m_pCallBackData, PCFN_SET_PRG_DATE_TIME_CONST, (DWORD)ps, (DWORD)&dt);

    // �޸���ָ�����߼�ֵ����
    ps = _T("bool");
    pInf->m_fnCallBack (pInf->m_pCallBackData, PCFN_SET_PRG_BOOL_CONST, (DWORD)ps, TRUE);

    // �޸���ָ�����ı��ͳ���
    ps = _T("text");
    const TCHAR* szText = _T("����ǰ�������");
    pInf->m_fnCallBack (pInf->m_pCallBackData, PCFN_SET_PRG_TEXT_CONST, (DWORD)ps, (DWORD)szText);

    // �޸���ָ����ͼƬ��Դ
    ps = _T("pic1");
    INT bin [] = { 4, 1234567 };
    pInf->m_fnCallBack (pInf->m_pCallBackData, PCFN_SET_PRG_BIN_CONST, (DWORD)ps, (DWORD)bin);

    return TRUE;  // ���سɹ�
}
