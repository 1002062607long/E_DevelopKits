
/*
    ��Ȩ������
    ���ļ���ȨΪ�����������������У�����Ȩ����������������������֧�ֿ⣬��ֹ���������κγ��ϡ�
*/

#ifndef __FN_SHARE_H
#define __FN_SHARE_H

char* CloneTextData (char* ps);
char* CloneTextData (char* ps, INT nTextLen);
LPBYTE CloneBinData (LPBYTE pData, INT nDataSize);
void GReportError (char* szErrText);

#endif

