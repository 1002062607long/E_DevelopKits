
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
        // 释放所保持的内存
        if (s_pBuffer != NULL)
            free (s_pBuffer);
    }

    return TRUE;
}

//--------------------------------------------------------------------

//   本插件没有实际性的作用,仅用作测试编译插件的处理机制,会把所传递进来的参数数据稍作变动后返回,
// 以测试参数的进出机制是否正确,并演示如何接收参数和返回数据.
const char* WINAPI MacroProcessor (const IMM_VALUE_WITH_DATA_TYPE* apImmArgs,
        int nNumImmArgs, IMM_VALUE_WITH_DATA_TYPE* pProcessResult)
{
    // 释放上一次调用所使用的内存
    if (s_pBuffer != NULL)
    {
        free (s_pBuffer);
        s_pBuffer = NULL;
    }

    //---------------------------------------------------------------------

    const char* szErrorMessage = NULL;  // 用作返回错误信息

    do
    {
        if (nNumImmArgs != 1)  // 参数数目不为1(本插件只能处理一个参数)?
        {
            szErrorMessage = "参数数目错误";
            break;
        }

        // 获得第一个参数数据
        const IMM_VALUE_WITH_DATA_TYPE* pImmArg = &apImmArgs [0];

        // 设置所返回数据的数据类型和数组类型
        pProcessResult->m_dtDataType = pImmArg->m_dtDataType;   // 数据类型一致
        pProcessResult->m_blIsAry = pImmArg->m_blIsAry;  // 数组类型也一致

        if (!pImmArg->m_blIsAry)  // 参数数据不为数组?
        {
            switch (pImmArg->m_dtDataType)
            {
            case MDT_INT:  // 整数
                pProcessResult->m_imm.m_int = pImmArg->m_imm.m_int + 1;  // +1微调一下. 下同
                break;

            case MDT_INT64:  // 长整数
                pProcessResult->m_imm.m_int64 = pImmArg->m_imm.m_int64 + 1;
                break;

            case MDT_FLOAT:  // 单精度小数
                pProcessResult->m_imm.m_float = pImmArg->m_imm.m_float + 1.0f;
                break;

            case MDT_DOUBLE:  // 双精度小数
                pProcessResult->m_imm.m_double = pImmArg->m_imm.m_double + 1.0;
                break;

            case MDT_BOOL:  // 逻辑
                pProcessResult->m_imm.m_bool = !pImmArg->m_imm.m_bool;
                break;

            case MDT_DATE_TIME:  // 日期时间
                pProcessResult->m_imm.m_dtDateTime = pImmArg->m_imm.m_dtDateTime + 1000.0;
                break;

            case MDT_TEXT:  // 文本
                s_pBuffer = malloc (9 + strlen (pImmArg->m_imm.m_szText) + 1);  // 9为"e_plugin_"文本的长度
                strcpy ((char*)s_pBuffer, "e_plugin_");  // 加上一个前缀文本"e_plugin_"
                strcpy ((char*)s_pBuffer + 9, pImmArg->m_imm.m_szText);
                pProcessResult->m_imm.m_szText = (char*)s_pBuffer;
                break;

            case MDT_BIN:  {  // 字节集
                const int nBinSize = *(int*)pImmArg->m_imm.m_pData;  // 获得原字节集长度
                s_pBuffer = malloc (sizeof (int) + 1 + nBinSize);  // 分配增加了一个字节的字节集数据内存

                unsigned char* pb = (unsigned char*)s_pBuffer;
                *(int*)pb = 1 + nBinSize;  // 记录新的字节集长度
                pb += sizeof (int);
                *pb++ = 123;  // 在字节集首部加入一个字节123
                memcpy (pb, pImmArg->m_imm.m_pData + sizeof (int), nBinSize);  // 再加入原字节集数据

                pProcessResult->m_imm.m_pData = (unsigned char*)s_pBuffer;
                break;  }

            default:
                szErrorMessage = "无效的参数数据类型";
                break;
            }
        }
        else  // 参数数据为数组
        {
            int nNumElements = *(int*)pImmArg->m_imm.m_pAryData;  // 获得数组成员的数目
            const unsigned char* pbSrc = pImmArg->m_imm.m_pAryData + sizeof (int);  // 获得数组数据首地址

            switch (pImmArg->m_dtDataType)
            {
            case MDT_INT:  {  // 整数数组
                s_pBuffer = malloc (sizeof (int) + sizeof (int) * nNumElements);  // 分配数组数据内存空间
                pProcessResult->m_imm.m_pAryData = (unsigned char*)s_pBuffer;  // 记录数组数据指针
                *(int*)s_pBuffer = nNumElements;  // 记录成员数目
                
                // 将每个数组成员值+1
                int* pDest = (int*)s_pBuffer + 1;  // 获得目的数据地址
                for (int nElementIndex = 0; nElementIndex < nNumElements; nElementIndex++, pbSrc += sizeof (int), pDest++)
                    *pDest = *(int*)pbSrc + 1;  // 加入修改值1
                break;  }

            case MDT_INT64:  {  // 长整数数组
                s_pBuffer = malloc (sizeof (int) + sizeof (__int64) * nNumElements);  // 分配数组数据内存空间
                pProcessResult->m_imm.m_pAryData = (unsigned char*)s_pBuffer;  // 记录数组数据指针
                *(int*)s_pBuffer = nNumElements;  // 记录成员数目
                
                // 将每个数组成员值+1
                __int64* pDest = (__int64*)((int*)s_pBuffer + 1);  // 获得目的数据地址
                for (int nElementIndex = 0; nElementIndex < nNumElements; nElementIndex++, pbSrc += sizeof (__int64), pDest++)
                    *pDest = *(__int64*)pbSrc + 1;  // 加入修改值1
                break;  }

            case MDT_FLOAT:  {  // 单精度小数数组
                s_pBuffer = malloc (sizeof (int) + sizeof (float) * nNumElements);  // 分配数组数据内存空间
                pProcessResult->m_imm.m_pAryData = (unsigned char*)s_pBuffer;  // 记录数组数据指针
                *(int*)s_pBuffer = nNumElements;  // 记录成员数目
                
                // 将每个数组成员值+1
                float* pDest = (float*)((int*)s_pBuffer + 1);  // 获得目的数据地址
                for (int nElementIndex = 0; nElementIndex < nNumElements; nElementIndex++, pbSrc += sizeof (float), pDest++)
                    *pDest = *(float*)pbSrc + 1.0f;  // 加入修改值1
                break;  }

            case MDT_DOUBLE:  {  // 双精度小数数组
                s_pBuffer = malloc (sizeof (int) + sizeof (double) * nNumElements);  // 分配数组数据内存空间
                pProcessResult->m_imm.m_pAryData = (unsigned char*)s_pBuffer;  // 记录数组数据指针
                *(int*)s_pBuffer = nNumElements;  // 记录成员数目
                
                // 将每个数组成员值+1
                double* pDest = (double*)((int*)s_pBuffer + 1);  // 获得目的数据地址
                for (int nElementIndex = 0; nElementIndex < nNumElements; nElementIndex++, pbSrc += sizeof (double), pDest++)
                    *pDest = *(double*)pbSrc + 1.0f;  // 加入修改值1
                break;  }

            case MDT_BOOL:  {  // 逻辑数组
                s_pBuffer = malloc (sizeof (int) + sizeof (int) * nNumElements);  // 分配数组数据内存空间
                pProcessResult->m_imm.m_pAryData = (unsigned char*)s_pBuffer;  // 记录数组数据指针
                *(int*)s_pBuffer = nNumElements;  // 记录成员数目
                
                // 将每个数组成员值+1
                int* pDest = (int*)((int*)s_pBuffer + 1);  // 获得目的数据地址
                for (int nElementIndex = 0; nElementIndex < nNumElements; nElementIndex++, pbSrc += sizeof (int), pDest++)
                    *pDest = !*(int*)pbSrc;  // 反转原逻辑值
                break;  }

            case MDT_DATE_TIME:  {  // 日期时间数组
                s_pBuffer = malloc (sizeof (int) + sizeof (double) * nNumElements);  // 分配数组数据内存空间
                pProcessResult->m_imm.m_pAryData = (unsigned char*)s_pBuffer;  // 记录数组数据指针
                *(int*)s_pBuffer = nNumElements;  // 记录成员数目
                
                // 将每个数组成员值+1
                double* pDest = (double*)((int*)s_pBuffer + 1);  // 获得目的数据地址
                for (int nElementIndex = 0; nElementIndex < nNumElements; nElementIndex++, pbSrc += sizeof (double), pDest++)
                    *pDest = *(double*)pbSrc + 1000.0;  // 加入修改时间值1000
                break;  }

            case MDT_TEXT:  {  // 文本数组
                // 计算总共所需要数据空间的尺寸
                int nAryDataSize = sizeof (int);
                const char* psSrc = (const char*)pbSrc;
                int nElementIndex;
                for (nElementIndex = 0; nElementIndex < nNumElements; nElementIndex++)
                {
                    const int nLen = strlen (psSrc) + 1;  // 包括结束0字符
                    psSrc += nLen;
                    nAryDataSize += 9 + nLen;  // 9为"e_plugin_"文本的长度
                }

                s_pBuffer = malloc (nAryDataSize);  // 分配数组数据内存空间
                pProcessResult->m_imm.m_pAryData = (unsigned char*)s_pBuffer;  // 记录数组数据指针

                unsigned char* pbDest = (unsigned char*)s_pBuffer;
                *(int*)pbDest = nNumElements;  // 记录成员数目
                pbDest += sizeof (int);

                // 处理每一个数组成员
                psSrc = (const char*)pbSrc;
                for (nElementIndex = 0; nElementIndex < nNumElements; nElementIndex++)
                {
                    strcpy ((char*)pbDest, "e_plugin_");  // 加上一个前缀文本
                    strcpy ((char*)pbDest + 9, psSrc);
                    
                    const int nLen = strlen (psSrc) + 1;  // 包括结束0字符
                    psSrc += nLen;
                    pbDest += 9 + nLen;
                }
                break;  }

            case MDT_BIN:  {  // 字节集数组
                // 计算总共所需要数据空间的尺寸
                const unsigned char* pbSrc2 = pbSrc;
                int nElementIndex;
                for (nElementIndex = 0; nElementIndex < nNumElements; nElementIndex++)
                    pbSrc2 += sizeof (int) + *(int*)pbSrc2;

                const int nAryDataSize = sizeof (int) + pbSrc2 - pbSrc + nNumElements;  // 每个成员首部增加一个字节
                s_pBuffer = malloc (nAryDataSize);  // 分配数组数据内存空间
                pProcessResult->m_imm.m_pAryData = (unsigned char*)s_pBuffer;  // 记录数组数据指针

                unsigned char* pbDest = (unsigned char*)s_pBuffer;
                *(int*)pbDest = nNumElements;  // 记录成员数目
                pbDest += sizeof (int);

                // 处理每一个数组成员
                pbSrc2 = pbSrc;
                for (nElementIndex = 0; nElementIndex < nNumElements; nElementIndex++)
                {
                    const int nBinSize = *(int*)pbSrc2;
                    pbSrc2 += sizeof (int);

                    *(int*)pbDest = nBinSize + 1;
                    pbDest += sizeof (int);
                    *pbDest++ = 123;  // 在首部加入一个字节
                    memcpy (pbDest, pbSrc2, nBinSize);

                    pbDest += nBinSize;
                    pbSrc2 += nBinSize;
                }
                break;  }

            default:
                szErrorMessage = "无效的参数数据类型";
                break;
            }
        }
    }
    while (FALSE);

    return szErrorMessage;
}
