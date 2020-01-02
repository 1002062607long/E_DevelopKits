
#include <stdlib.h>
#include <malloc.h>
#include <windows.h>
#include <windef.h>
#include "macro.h"

static void* s_pBuffer = NULL;

BOOL APIENTRY DllMain (HANDLE hModule, DWORD ul_reason_for_call, LPVOID lpReserved)
{
    if (ul_reason_for_call == DLL_PROCESS_ATTACH)
    {
    }
    else if (ul_reason_for_call == DLL_PROCESS_DETACH)
    {
        // �ͷ������ֵ��ڴ�
        if (s_pBuffer != NULL)
            free (s_pBuffer);
    }

    return TRUE;
}

//--------------------------------------------------------------------

//   �����û��ʵ���Ե�����,���������Ա������Ĵ������,��������ݽ����Ĳ������������䶯�󷵻�,
// �Բ��Բ����Ľ��������Ƿ���ȷ,����ʾ��ν��ղ����ͷ�������.
const char* WINAPI MacroProcessor (const IMM_VALUE_WITH_DATA_TYPE* apImmArgs,
        int nNumImmArgs, IMM_VALUE_WITH_DATA_TYPE* pProcessResult)
{
    // �ͷ���һ�ε�����ʹ�õ��ڴ�
    if (s_pBuffer != NULL)
    {
        free (s_pBuffer);
        s_pBuffer = NULL;
    }

    //---------------------------------------------------------------------

    const char* szErrorMessage = NULL;  // �������ش�����Ϣ

    do
    {
        if (nNumImmArgs != 1)  // ������Ŀ��Ϊ1(�����ֻ�ܴ���һ������)?
        {
            szErrorMessage = "������Ŀ����";
            break;
        }

        // ��õ�һ����������
        const IMM_VALUE_WITH_DATA_TYPE* pImmArg = &apImmArgs [0];

        // �������������ݵ��������ͺ���������
        pProcessResult->m_dtDataType = pImmArg->m_dtDataType;   // ��������һ��
        pProcessResult->m_blIsAry = pImmArg->m_blIsAry;  // ��������Ҳһ��

        if (!pImmArg->m_blIsAry)  // �������ݲ�Ϊ����?
        {
            switch (pImmArg->m_dtDataType)
            {
            case MDT_INT:  // ����
                pProcessResult->m_imm.m_int = pImmArg->m_imm.m_int + 1;  // +1΢��һ��. ��ͬ
                break;

            case MDT_INT64:  // ������
                pProcessResult->m_imm.m_int64 = pImmArg->m_imm.m_int64 + 1;
                break;

            case MDT_FLOAT:  // ������С��
                pProcessResult->m_imm.m_float = pImmArg->m_imm.m_float + 1.0f;
                break;

            case MDT_DOUBLE:  // ˫����С��
                pProcessResult->m_imm.m_double = pImmArg->m_imm.m_double + 1.0;
                break;

            case MDT_BOOL:  // �߼�
                pProcessResult->m_imm.m_bool = !pImmArg->m_imm.m_bool;
                break;

            case MDT_DATE_TIME:  // ����ʱ��
                pProcessResult->m_imm.m_dtDateTime = pImmArg->m_imm.m_dtDateTime + 1000.0;
                break;

            case MDT_TEXT:  // �ı�
                s_pBuffer = malloc (9 + strlen (pImmArg->m_imm.m_szText) + 1);  // 9Ϊ"e_plugin_"�ı��ĳ���
                strcpy ((char*)s_pBuffer, "e_plugin_");  // ����һ��ǰ׺�ı�"e_plugin_"
                strcpy ((char*)s_pBuffer + 9, pImmArg->m_imm.m_szText);
                pProcessResult->m_imm.m_szText = (char*)s_pBuffer;
                break;

            case MDT_BIN:  {  // �ֽڼ�
                const int nBinSize = *(int*)pImmArg->m_imm.m_pData;  // ���ԭ�ֽڼ�����
                s_pBuffer = malloc (sizeof (int) + 1 + nBinSize);  // ����������һ���ֽڵ��ֽڼ������ڴ�

                unsigned char* pb = (unsigned char*)s_pBuffer;
                *(int*)pb = 1 + nBinSize;  // ��¼�µ��ֽڼ�����
                pb += sizeof (int);
                *pb++ = 123;  // ���ֽڼ��ײ�����һ���ֽ�123
                memcpy (pb, pImmArg->m_imm.m_pData + sizeof (int), nBinSize);  // �ټ���ԭ�ֽڼ�����

                pProcessResult->m_imm.m_pData = (unsigned char*)s_pBuffer;
                break;  }

            default:
                szErrorMessage = "��Ч�Ĳ�����������";
                break;
            }
        }
        else  // ��������Ϊ����
        {
            int nNumElements = *(int*)pImmArg->m_imm.m_pAryData;  // ��������Ա����Ŀ
            const unsigned char* pbSrc = pImmArg->m_imm.m_pAryData + sizeof (int);  // ������������׵�ַ

            switch (pImmArg->m_dtDataType)
            {
            case MDT_INT:  {  // ��������
                s_pBuffer = malloc (sizeof (int) + sizeof (int) * nNumElements);  // �������������ڴ�ռ�
                pProcessResult->m_imm.m_pAryData = (unsigned char*)s_pBuffer;  // ��¼��������ָ��
                *(int*)s_pBuffer = nNumElements;  // ��¼��Ա��Ŀ
                
                // ��ÿ�������Աֵ+1
                int* pDest = (int*)s_pBuffer + 1;  // ���Ŀ�����ݵ�ַ
                for (int nElementIndex = 0; nElementIndex < nNumElements; nElementIndex++, pbSrc += sizeof (int), pDest++)
                    *pDest = *(int*)pbSrc + 1;  // �����޸�ֵ1
                break;  }

            case MDT_INT64:  {  // ����������
                s_pBuffer = malloc (sizeof (int) + sizeof (__int64) * nNumElements);  // �������������ڴ�ռ�
                pProcessResult->m_imm.m_pAryData = (unsigned char*)s_pBuffer;  // ��¼��������ָ��
                *(int*)s_pBuffer = nNumElements;  // ��¼��Ա��Ŀ
                
                // ��ÿ�������Աֵ+1
                __int64* pDest = (__int64*)((int*)s_pBuffer + 1);  // ���Ŀ�����ݵ�ַ
                for (int nElementIndex = 0; nElementIndex < nNumElements; nElementIndex++, pbSrc += sizeof (__int64), pDest++)
                    *pDest = *(__int64*)pbSrc + 1;  // �����޸�ֵ1
                break;  }

            case MDT_FLOAT:  {  // ������С������
                s_pBuffer = malloc (sizeof (int) + sizeof (float) * nNumElements);  // �������������ڴ�ռ�
                pProcessResult->m_imm.m_pAryData = (unsigned char*)s_pBuffer;  // ��¼��������ָ��
                *(int*)s_pBuffer = nNumElements;  // ��¼��Ա��Ŀ
                
                // ��ÿ�������Աֵ+1
                float* pDest = (float*)((int*)s_pBuffer + 1);  // ���Ŀ�����ݵ�ַ
                for (int nElementIndex = 0; nElementIndex < nNumElements; nElementIndex++, pbSrc += sizeof (float), pDest++)
                    *pDest = *(float*)pbSrc + 1.0f;  // �����޸�ֵ1
                break;  }

            case MDT_DOUBLE:  {  // ˫����С������
                s_pBuffer = malloc (sizeof (int) + sizeof (double) * nNumElements);  // �������������ڴ�ռ�
                pProcessResult->m_imm.m_pAryData = (unsigned char*)s_pBuffer;  // ��¼��������ָ��
                *(int*)s_pBuffer = nNumElements;  // ��¼��Ա��Ŀ
                
                // ��ÿ�������Աֵ+1
                double* pDest = (double*)((int*)s_pBuffer + 1);  // ���Ŀ�����ݵ�ַ
                for (int nElementIndex = 0; nElementIndex < nNumElements; nElementIndex++, pbSrc += sizeof (double), pDest++)
                    *pDest = *(double*)pbSrc + 1.0f;  // �����޸�ֵ1
                break;  }

            case MDT_BOOL:  {  // �߼�����
                s_pBuffer = malloc (sizeof (int) + sizeof (int) * nNumElements);  // �������������ڴ�ռ�
                pProcessResult->m_imm.m_pAryData = (unsigned char*)s_pBuffer;  // ��¼��������ָ��
                *(int*)s_pBuffer = nNumElements;  // ��¼��Ա��Ŀ
                
                // ��ÿ�������Աֵ+1
                int* pDest = (int*)((int*)s_pBuffer + 1);  // ���Ŀ�����ݵ�ַ
                for (int nElementIndex = 0; nElementIndex < nNumElements; nElementIndex++, pbSrc += sizeof (int), pDest++)
                    *pDest = !*(int*)pbSrc;  // ��תԭ�߼�ֵ
                break;  }

            case MDT_DATE_TIME:  {  // ����ʱ������
                s_pBuffer = malloc (sizeof (int) + sizeof (double) * nNumElements);  // �������������ڴ�ռ�
                pProcessResult->m_imm.m_pAryData = (unsigned char*)s_pBuffer;  // ��¼��������ָ��
                *(int*)s_pBuffer = nNumElements;  // ��¼��Ա��Ŀ
                
                // ��ÿ�������Աֵ+1
                double* pDest = (double*)((int*)s_pBuffer + 1);  // ���Ŀ�����ݵ�ַ
                for (int nElementIndex = 0; nElementIndex < nNumElements; nElementIndex++, pbSrc += sizeof (double), pDest++)
                    *pDest = *(double*)pbSrc + 1000.0;  // �����޸�ʱ��ֵ1000
                break;  }

            case MDT_TEXT:  {  // �ı�����
                // �����ܹ�����Ҫ���ݿռ�ĳߴ�
                int nAryDataSize = sizeof (int);
                const char* psSrc = (const char*)pbSrc;
                int nElementIndex;
                for (nElementIndex = 0; nElementIndex < nNumElements; nElementIndex++)
                {
                    const int nLen = strlen (psSrc) + 1;  // ��������0�ַ�
                    psSrc += nLen;
                    nAryDataSize += 9 + nLen;  // 9Ϊ"e_plugin_"�ı��ĳ���
                }

                s_pBuffer = malloc (nAryDataSize);  // �������������ڴ�ռ�
                pProcessResult->m_imm.m_pAryData = (unsigned char*)s_pBuffer;  // ��¼��������ָ��

                unsigned char* pbDest = (unsigned char*)s_pBuffer;
                *(int*)pbDest = nNumElements;  // ��¼��Ա��Ŀ
                pbDest += sizeof (int);

                // ����ÿһ�������Ա
                psSrc = (const char*)pbSrc;
                for (nElementIndex = 0; nElementIndex < nNumElements; nElementIndex++)
                {
                    strcpy ((char*)pbDest, "e_plugin_");  // ����һ��ǰ׺�ı�
                    strcpy ((char*)pbDest + 9, psSrc);
                    
                    const int nLen = strlen (psSrc) + 1;  // ��������0�ַ�
                    psSrc += nLen;
                    pbDest += 9 + nLen;
                }
                break;  }

            case MDT_BIN:  {  // �ֽڼ�����
                // �����ܹ�����Ҫ���ݿռ�ĳߴ�
                const unsigned char* pbSrc2 = pbSrc;
                int nElementIndex;
                for (nElementIndex = 0; nElementIndex < nNumElements; nElementIndex++)
                    pbSrc2 += sizeof (int) + *(int*)pbSrc2;

                const int nAryDataSize = sizeof (int) + pbSrc2 - pbSrc + nNumElements;  // ÿ����Ա�ײ�����һ���ֽ�
                s_pBuffer = malloc (nAryDataSize);  // �������������ڴ�ռ�
                pProcessResult->m_imm.m_pAryData = (unsigned char*)s_pBuffer;  // ��¼��������ָ��

                unsigned char* pbDest = (unsigned char*)s_pBuffer;
                *(int*)pbDest = nNumElements;  // ��¼��Ա��Ŀ
                pbDest += sizeof (int);

                // ����ÿһ�������Ա
                pbSrc2 = pbSrc;
                for (nElementIndex = 0; nElementIndex < nNumElements; nElementIndex++)
                {
                    const int nBinSize = *(int*)pbSrc2;
                    pbSrc2 += sizeof (int);

                    *(int*)pbDest = nBinSize + 1;
                    pbDest += sizeof (int);
                    *pbDest++ = 123;  // ���ײ�����һ���ֽ�
                    memcpy (pbDest, pbSrc2, nBinSize);

                    pbDest += nBinSize;
                    pbSrc2 += nBinSize;
                }
                break;  }

            default:
                szErrorMessage = "��Ч�Ĳ�����������";
                break;
            }
        }
    }
    while (FALSE);

    return szErrorMessage;
}
