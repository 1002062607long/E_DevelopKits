
/*
    ��Ȩ������
    ���ļ���ȨΪ�����������������У�����Ȩ����������������������֧�ֿ⣬��ֹ���������κγ��ϡ�
*/


// ʹ��ָ���ı����ݽ����׳�����ʹ�õ��ı����ݡ�
char* CloneTextData (char* ps)
{
    if (ps == NULL || *ps == '\0')
        return NULL;

    INT nTextLen = strlen (ps);
    char* pd = (char*)NotifySys (NRS_MALLOC, (DWORD)(nTextLen + 1), 0);
    memcpy (pd, ps, nTextLen);
    pd [nTextLen] = '\0';
    return pd;
}

// ʹ��ָ���ı����ݽ����׳�����ʹ�õ��ı����ݡ�
//   nTextLen����ָ���ı����ֵĳ��ȣ������������㣩��
// ���Ϊ-1����ȡps��ȫ�����ȡ�
char* CloneTextData (char* ps, INT nTextLen)
{
    if (nTextLen <= 0)
        return NULL;

    char* pd = (char*)NotifySys (NRS_MALLOC, (DWORD)(nTextLen + 1), 0);
    memcpy (pd, ps, nTextLen);
    pd [nTextLen] = '\0';
    return pd;
}

// ʹ��ָ�����ݽ����׳�����ʹ�õ��ֽڼ����ݡ�
LPBYTE CloneBinData (LPBYTE pData, INT nDataSize)
{
    if (nDataSize == 0)
        return NULL;

    LPBYTE pd = (LPBYTE)NotifySys (NRS_MALLOC, (DWORD)(sizeof (INT) * 2 + nDataSize), 0);
    *(LPINT)pd = 1;
    *(LPINT)(pd + sizeof (INT)) = nDataSize;
    memcpy (pd + sizeof (INT) * 2, pData, nDataSize);
    return pd;
}

// ��������ʱ����
void GReportError (char* szErrText)
{
    NotifySys (NRS_RUNTIME_ERR, (DWORD)szErrText, 0);
}

