
/*
    ��Ȩ������
    ���ļ���ȨΪ�����������������У�����Ȩ����������������������֧�ֿ⣬��ֹ���������κγ��ϡ�
*/

#ifndef __UNTSHARE_H
#define	__UNTSHARE_H

class CPropertyInfo
{
public:
	CPropertyInfo ()
	{
		init ();
	}

	virtual void init ()  { }
	virtual BOOL Serialize (CArchive& ar)
	{
		if (ar.IsLoading () == TRUE)
			init ();
		return TRUE;
	}

	HGLOBAL SaveData ();
	BOOL LoadData (LPBYTE pData, INT nDataSize);
};

COLORREF ProcessSysBackColor (COLORREF clr);
BOOL CreateImageList (CImageList* pimgList, LPBYTE p, INT nSize);
void ChangeBorder (CWnd* pUnit, INT nBorderType);

CWnd* GetWndPtr (PMDATA_INF parg);
BOOL MyCreateFont (CFont& font, LOGFONT* pLogFont);
void ModiUnitStyle (CWnd* pUnit, DWORD dwAddStyle, DWORD dwRemoveStyle);
void SetUnitStyle (CWnd* pUnit, BOOL blSet, DWORD dwStyle);
void SerializeCString (CString& str, CArchive& ar);
void SetStr (CString& str, LPTSTR szText);

#endif

