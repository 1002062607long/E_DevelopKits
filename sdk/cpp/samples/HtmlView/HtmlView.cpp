
/*
    ��Ȩ������
    ���ļ���ȨΪ�����������������У�����Ȩ����������������������֧�ֿ⣬��ֹ���������κγ��ϡ�
*/

#include "stdafx.h"
#include "resource.h"
#include "HtmlView.h"
#include "lib2.h"
#include "lang.h"
#include "hhctrl.h"
#include "fnshare.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

/////////////////////////////////////////////////////////////////////////////
// CHtmlViewApp

BEGIN_MESSAGE_MAP(CHtmlViewApp, CWinApp)
	//{{AFX_MSG_MAP(CHtmlViewApp)
		// NOTE - the ClassWizard will add and remove mapping macros here.
		//    DO NOT EDIT what you see in these blocks of generated code!
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CHtmlViewApp construction

CHtmlViewApp::CHtmlViewApp()
{
}

/////////////////////////////////////////////////////////////////////////////
// The one and only CHtmlViewApp object

#ifndef __E_STATIC_LIB

CHtmlViewApp theApp;

#endif

/////////////////////////////////////////////////////////////////////////////

INT g_nLastNotifyResult;
PFN_NOTIFY_SYS g_fnNotifySys = NULL;

INT WINAPI NotifySys (INT nMsg, DWORD dwParam1, DWORD dwParam2)
{
	ASSERT (g_fnNotifySys != NULL);
	if (g_fnNotifySys != NULL)
		return g_nLastNotifyResult = g_fnNotifySys (nMsg, dwParam1, dwParam2);
	else
		return g_nLastNotifyResult = 0;
}

#include "fnshare.cpp"

/////////////////////////////////////////////////////////////////////////////


#ifndef __E_STATIC_LIB

INT s_nHtmlViewerElementCmdIndex [] =
{
	0, 1, 2, 3, 4
};

extern UNIT_PROPERTY g_HtmlViewerProperty [];
extern INT g_HtmlViewerPropertyCount;
extern EVENT_INFO g_HtmlViewerEvent [];
extern INT g_HtmlViewerEventCount;

// ����Ķ���˳����Բ��ɸĶ���
static LIB_DATA_TYPE_INFO s_DataType[] = 
{
	{
/*m_szName*/					_WT("���ı������"),
/*m_szEgName*/					_WT("HtmlViewer"),
/*m_szExplain*/					_WT("�ṩ��HTMLҳ������֧��"),
/*m_nCmdCount*/					sizeof (s_nHtmlViewerElementCmdIndex) / sizeof (s_nHtmlViewerElementCmdIndex [0]),
/*m_pnCmdsIndex*/				s_nHtmlViewerElementCmdIndex,
/*m_dwState*/					LDT_WIN_UNIT,
/*m_dwUnitBmpID*/				IDB_HTMLVIEWER_BITMAP,
/*m_nEventCount*/				g_HtmlViewerEventCount,
/*m_pEventBegin*/				(PEVENT_INFO2)g_HtmlViewerEvent,
/*m_nPropertyCount*/			g_HtmlViewerPropertyCount,
/*m_pPropertyBegin*/			g_HtmlViewerProperty,
/*m_pfnGetInterface*/			htmlview_GetInterface_HtmlViewer,
/*m_nElementCount*/				0,
/*m_pElementBegin*/				NULL,
	},
};

///////////////////////////////////

//*** �������Ϣ:

ARG_INFO s_ArgInfo[] =
{
//****** ִ������	**	0
	{
/*name*/	_WT("��ִ�е�����"),
/*explain*/	_WT("ָ����ִ����������ͣ�Ϊ���³���ֵ֮һ�� "
			"0: #ǰ���� "
			"1: #���ˣ� "
			"2: #����ҳ�� "
			"3: #������ҳ�� "
			"4: #ˢ�£� "
			"5: #ֹͣ�� "
			"6: #���Ϊ�� "
			"7: #��ӡ�� "
			"8: #��ӡԤ���� "
			"9: #ҳ������"),
/*bmp inx*/	0,
/*bmp num*/	0,
/*type*/	SDT_INT,
/*default*/	0,
/*state*/	NULL,
	},
//****** ��ת	**	1
	{
/*name*/	_WT("�����ĵ���ַ"),
/*explain*/	_WT("ָ���ĵ�λ�ڻ������򱾻��ϵĵ�ַ"),
/*bmp inx*/	0,
/*bmp num*/	0,
/*type*/	SDT_TEXT,
/*default*/	0,
/*state*/	NULL,
	}, {
/*name*/	_WT("CHM�ļ�����"),
/*explain*/	_WT("��������ĵ����� .CHM �ļ��ڣ��������ṩ�� CHM �ļ������ơ�"
		"�����������ʡ�ԣ�Ĭ��ֵΪ���ı�"),
/*bmp inx*/	0,
/*bmp num*/	0,
/*type*/	SDT_TEXT,
/*default*/	0,
/*state*/	AS_DEFAULT_VALUE_IS_EMPTY,
	}, {
/*name*/	_WT("Ŀ�괰������"),
/*explain*/	_WT("ָ���ĵ��Ƿ��ڵ��������д򿪣���ͬ������ָ����ͬ�Ĵ��ڡ�"
		"�������������ڲ��򿪣��ṩ���ı�����ֵ���ɡ�"
		"�����������ʡ�ԣ�Ĭ��ֵΪ���ı�"),
/*bmp inx*/	0,
/*bmp num*/	0,
/*type*/	SDT_TEXT,
/*default*/	0,
/*state*/	AS_DEFAULT_VALUE_IS_EMPTY,
	}
};

static CMD_INFO s_CmdInfo[] =
{
/////////////////////////////////// ���ı������

//****** ִ�������Ա��	** 0
	{
/*ccname*/	_WT("ִ������"),
/*egname*/	_WT("Execute"),
/*explain*/	_WT("ִ��ָ�������������"),
/*category*/-1,
/*state*/	NULL,
/*ret*/		_SDT_NULL,
/*reserved*/0,
/*level*/	LVL_SIMPLE,
/*bmp inx*/	0,
/*bmp num*/	0,
/*ArgCount*/1,
/*arg lp*/	s_ArgInfo,
	},
//****** ��ת����Ա��	** 1
	{
/*ccname*/	_WT("��ת"),
/*egname*/	_WT("Navigate"),
/*explain*/	_WT("�򿪻��������߱�����ָ��λ�ô����ĵ�"),
/*category*/-1,
/*state*/	NULL,
/*ret*/		_SDT_NULL,
/*reserved*/0,
/*level*/	LVL_SIMPLE,
/*bmp inx*/	0,
/*bmp num*/	0,
/*ArgCount*/3,
/*arg lp*/	&s_ArgInfo [1],
	},
//****** ȡ�ĵ����ͣ���Ա��	** 2
	{
/*ccname*/	_WT("ȡ�ĵ�����"),
/*egname*/	_WT("GetType"),
/*explain*/	_WT("���س��ı�������������ĵ��������ı�"),
/*category*/-1,
/*state*/	NULL,
/*ret*/		SDT_TEXT,
/*reserved*/0,
/*level*/	LVL_SIMPLE,
/*bmp inx*/	0,
/*bmp num*/	0,
/*ArgCount*/0,
/*arg lp*/	NULL,
	},
//****** �Ƿ��������أ���Ա��	** 3
	{
/*ccname*/	_WT("�Ƿ���������"),
/*egname*/	_WT("GetBusy"),
/*explain*/	_WT("�����ǰ���������ĵ���ִ��ҳ����ת�������棬���򷵻ؼ�"),
/*category*/-1,
/*state*/	NULL,
/*ret*/		SDT_BOOL,
/*reserved*/0,
/*level*/	LVL_SIMPLE,
/*bmp inx*/	0,
/*bmp num*/	0,
/*ArgCount*/0,
/*arg lp*/	NULL,
	},
//****** �Ƿ��������Ա��	** 4
	{
/*ccname*/	_WT("�Ƿ����"),
/*egname*/	_WT("IsReady"),
/*explain*/	_WT("��������ǰ�Ѿ�׼�������������棬���򷵻ؼ�"),
/*category*/-1,
/*state*/	NULL,
/*ret*/		SDT_BOOL,
/*reserved*/0,
/*level*/	LVL_SIMPLE,
/*bmp inx*/	0,
/*bmp num*/	0,
/*ArgCount*/0,
/*arg lp*/	NULL,
	},

};

#endif

///////////////////////////////////
extern "C"
void htmlview_fnExecute (PMDATA_INF pRetData, INT nArgCount, PMDATA_INF pArgInf)
{
	CHHCtrl* pUnit = (CHHCtrl*)GetWndPtr (pArgInf);

	switch (pArgInf [1].m_int)
	{
	case 0:
		pUnit->GoForward ();
		break;
	case 1:
		pUnit->GoBack ();
		break;
	case 2:
		pUnit->GoHome ();
		break;
	case 3:
		pUnit->GoSearch ();
		break;
	case 4:
		pUnit->Refresh ();
		break;
	case 5:
		pUnit->Stop ();
		break;
	case 6:
		pUnit->RunCmd (OLECMDID_SAVEAS);
		break;
	case 7:
		pUnit->RunCmd (OLECMDID_PRINT);
		break;
	case 8:
		pUnit->RunCmd (OLECMDID_PRINTPREVIEW);
		break;
	case 9:
		pUnit->RunCmd (OLECMDID_PAGESETUP);
		break;
	}
}

extern "C"
void htmlview_fnNavigate (PMDATA_INF pRetData, INT nArgCount, PMDATA_INF pArgInf)
{
	CHHCtrl* pUnit = (CHHCtrl*)GetWndPtr (pArgInf);

	LPCTSTR szDocument = (LPCTSTR)pArgInf [1].m_pText;
	LPTSTR szChmFileName = pArgInf [2].m_dtDataType == _SDT_NULL ? NULL :
			(LPTSTR)pArgInf [2].m_pText;
	LPTSTR szWinName = pArgInf [3].m_dtDataType == _SDT_NULL ? NULL :
			(LPTSTR)pArgInf [3].m_pText;

	if (szChmFileName == NULL || *szChmFileName == '\0')
		pUnit->Navigate (szDocument, 0, szWinName);
	else
		pUnit->NavigateChm (szChmFileName, szDocument, szWinName);
}

extern "C"
void htmlview_fnGetType (PMDATA_INF pRetData, INT nArgCount, PMDATA_INF pArgInf)
{
    pRetData->m_pText = CloneTextData ((LPTSTR)(LPCTSTR)
            ((CHHCtrl*)GetWndPtr (pArgInf))->GetType ());
}

extern "C"
void htmlview_fnGetBusy (PMDATA_INF pRetData, INT nArgCount, PMDATA_INF pArgInf)
{
	pRetData->m_bool = ((CHHCtrl*)GetWndPtr (pArgInf))->GetBusy ();
}

extern "C"
void htmlview_fnIsReady (PMDATA_INF pRetData, INT nArgCount, PMDATA_INF pArgInf)
{
	pRetData->m_bool = ((CHHCtrl*)GetWndPtr (pArgInf))->GetReadyState () ==
			READYSTATE_COMPLETE;
}

//*** ����ʵ����Ϣ:
#ifndef __E_STATIC_LIB
PFN_EXECUTE_CMD s_RunFunc [] =	// ����Ӧ��s_CmdInfo�е������˳���Ӧ
{
	htmlview_fnExecute,
	htmlview_fnNavigate,
	htmlview_fnGetType,
	htmlview_fnGetBusy,
	htmlview_fnIsReady
};

static const char* const g_CmdNames[] = 
{
	"htmlview_fnExecute",
	"htmlview_fnNavigate",
	"htmlview_fnGetType",
	"htmlview_fnGetBusy",
	"htmlview_fnIsReady",
};

///////////////////////////////////

//*** ����������Ϣ:

// !!! ע�ⳣ��ֵ�����Ѿ����õ������У����Ծ��Բ��ܸĶ���
// ˳��ֵ���ܸĶ�

LIB_CONST_INFO s_ConstInfo [] =
{
	{	_WT("ǰ��"),	NULL,	NULL,	LVL_SIMPLE,	CT_NUM,	NULL,	0,	},
	{	_WT("����"),	NULL,	NULL,	LVL_SIMPLE,	CT_NUM,	NULL,	1,	},
	{	_WT("����ҳ"),	NULL,	NULL,	LVL_SIMPLE,	CT_NUM,	NULL,	2,	},
	{	_WT("������ҳ"),NULL,	NULL,	LVL_SIMPLE,	CT_NUM,	NULL,	3,	},
	{	_WT("ˢ��"),	NULL,	NULL,	LVL_SIMPLE,	CT_NUM,	NULL,	4,	},
	{	_WT("ֹͣ"),	NULL,	NULL,	LVL_SIMPLE,	CT_NUM,	NULL,	5,	},
	{	_WT("���Ϊ"),	NULL,	NULL,	LVL_SIMPLE,	CT_NUM,	NULL,	6,	},
	{	_WT("��ӡ"),	NULL,	NULL,	LVL_SIMPLE,	CT_NUM,	NULL,	7,	},
	{	_WT("��ӡԤ��"),NULL,	NULL,	LVL_SIMPLE,	CT_NUM,	NULL,	8,	},
	{	_WT("ҳ������"),NULL,	NULL,	LVL_SIMPLE,	CT_NUM,	NULL,	9,	},

};

#endif

/////////////////////////////////////////////////////////////////////////////

INT WINAPI ProcessNotifyLib (INT nMsg, DWORD dwParam1, DWORD dwParam2)
{
	INT nRet = NR_OK;
	switch (nMsg)
	{
	case NL_SYS_NOTIFY_FUNCTION:
		g_fnNotifySys = (PFN_NOTIFY_SYS)dwParam1;
		break;
	default:
		nRet = NR_ERR;
		break;
	}

	return nRet;
}

EXTERN_C INT WINAPI htmlview_ProcessNotifyLib (INT nMsg, DWORD dwParam1, DWORD dwParam2)
{
#ifndef __E_STATIC_LIB
	if(nMsg == NL_GET_CMD_FUNC_NAMES)
		return (INT) g_CmdNames;
	else if(nMsg == NL_GET_NOTIFY_LIB_FUNC_NAME)
		return (INT) "htmlview_ProcessNotifyLib";
	else if(nMsg == NL_GET_DEPENDENT_LIBS)
		return NULL;
#endif
	return ProcessNotifyLib(nMsg, dwParam1, dwParam2);
}

#ifndef __E_STATIC_LIB
/////////////////////////////////////////////////////////////////////////////

//////////// �ⶨ�忪ʼ
static LIB_INFO s_LibInfo =
{
/*Lib Format Ver*/		LIB_FORMAT_VER,		// ����δ�á�

// ��֧�ֿ��GUID����
// guid: {5014D8FA-6DCA-40b6-8FA6-26D8183666EB}
#define		LI_LIB_GUID_STR	"5014D8FA6DCA40b68FA626D8183666EB"
/*guid str*/			_T (LI_LIB_GUID_STR),

/*m_nMajorVersion*/		2,
/*m_nMinorVersion*/		0,

//!!!	ע�⣺������ɾ��������������������������͡�������Ϣ�ȣ�ֻҪ�԰���
//!!! �ļ����ɻ����Ӱ�죬�����������汾�ţ�������ֻ�޸�BuildNumber��
//!!!   �Ķ����������汾��!!!
/*m_nBuildNumber*/		51,	// 1: 2.5;  2: 2.5���Ű�; 3: 3.0��;  50: 3.39; 51: 4.11
		// �����汾�ţ�����Դ˰汾�����κδ���
		//   ���汾�Ž�����������ͬ��ʽ�汾�ŵĿ⣨Ʃ������޸��˼��� BUG����
		// �κι��������û�ʹ�õİ汾��˰汾�Ŷ�Ӧ�ò�һ����
		//   ��ֵʱӦ��˳�������

/*m_nRqSysMajorVer*/		3,
/*m_nRqSysMinorVer*/		0,
/*m_nRqSysKrnlLibMajorVer*/	3,
/*m_nRqSysKrnlLibMinorVer*/	0,

/*name*/				_T ("���ı������֧�ֿ�"),
/*lang*/				__GBK_LANG_VER,
/*explain*/				_WT("��֧�ֿ�ʵ���˶Գ��ı�����򴰿������֧�֡�"),
/*dwState*/				NULL,

/*szAuthor*/	_WT("�������������������˾"),
/*szZipCode*/	_WT("116001"),
/*szAddress*/	_WT("����ʡ��������ɽ������·55����̫���ʽ�������"),
/*szPhoto*/		_WT("+86(0411)39895831"),
/*szFax*/		_WT("+86(0411)39895834"),
/*szEmail*/		_WT("service@dywt.com.cn"),
/*szHomePage*/	_WT("http://www.eyuyan.com"),
/*szOther*/		_WT("ף��һ����˳�������³ɣ�"),

/*type count*/			sizeof (s_DataType) / sizeof (s_DataType[0]),
/*PLIB_DATA_TYPE_INFO*/	s_DataType,

/*CategoryCount*/ 0,	// ���������Ӵ�ֵ��
/*category*/_WT("\0"	// ���˵����ÿ��Ϊһ�ַ���,ǰ��λ���ֱ�ʾͼ��������(��1��ʼ,0��).
				"\0"),
/*CmdCount*/				sizeof (s_CmdInfo) / sizeof (s_CmdInfo [0]),
/*BeginCmd*/				s_CmdInfo,
/*m_pCmdsFunc*/             s_RunFunc,
/*pfnRunAddInFn*/			NULL,
/*szzAddInFnInfo*/			NULL,

/*pfnNotify*/				htmlview_ProcessNotifyLib,

/*pfnRunSuperTemplate*/		NULL,
/*szzSuperTemplateInfo*/	NULL,

/*nLibConstCount*/			sizeof (s_ConstInfo) / sizeof (s_ConstInfo [0]),
/*pLibConst*/				s_ConstInfo,

/*szzDependFiles*/			NULL,
};

PLIB_INFO WINAPI GetNewInf ()
{
	return &s_LibInfo;
}
#endif

