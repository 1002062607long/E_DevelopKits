unit e;

////////////////////////////////////////////////////////////////////////////////
//
//   ������֧�ֿ⿪����(EDK) for Delphi, 1.1
// ---------------------------------------------
// (2008/8, ����������������������������޹�˾)
//
////////////////////////////////////////////////////////////////////////////////
//
// ��Ȩ������
//     ���ļ���ȨΪ�����������������У�����Ȩ����������������������֧�ֿ⣬��ֹ���������κγ��ϡ�
//
////////////////////////////////////////////////////////////////////////////////


(*******************************************************************************
!!! ע�⣺֧�ֿ��Ǳ�׼��DLL�ļ������ļ����ĺ�׺����̶�Ϊ.FNx������xΪһ������ĸ��Ŀǰ������ĺ�׺�У�
    1����.fne���� ���༭��Ϣ��������֧�ִ����֧�ֿ⣻
    2����.fnl���� ���༭��Ϣ��������֧�ִ����֧�ֿ⣻
    3����.fnr���� �����༭��������Ϣ����������֧�ִ����֧�ֿ⣻
!!! �����ֱ�Ӹ���*.dllΪ*.FNx���ɡ�
*******************************************************************************)

interface

uses sysutils, windows;


// ����ϵͳ���
const
  __OS_WIN    = $80000000;  //֧��Windows����ϵͳ
  __OS_LINUX  = $40000000;  //֧��Linux  ����ϵͳ
  __OS_UNIX   = $20000000;  //֧��Unix   ����ϵͳ

  OS_ALL      = (__OS_WIN or __OS_LINUX or __OS_UNIX);  //֧���������в���ϵͳ

{*
���ڿ����ϵͳ���֧�ֵļ���˵����
  1���°�֧�ֿ���Ҫ˵���������Щ����ϵͳ�汾����֧�ֿ�����������������͡�
     �������ͷ��������������¼�����������������֧�ֵĲ���ϵͳ�������˵����
     Ĭ�ϲ�֧���κβ���ϵͳ!��������Щ��Ϣ���ڸ�֧�ֿ������е����в���ϵͳ��
     ���б���һ�¡�
  2��Ϊ�˺���ǰ��֧�ֿ�����ݣ�����m_nRqSysMajorVer.m_nRqSysMinorVer�汾��
     С��3.6�Ķ�Ĭ��Ϊ֧��Windows����ϵͳ�������ڲ�����������������͡�
     �������ͷ��������������¼��������������ԡ�
  3����������̶����Ժ͹̶��¼���֧�����в���ϵͳ��
  4�����ڴ����߿ⲻ���в���ϵͳ֧�ּ�顣
*}

type
  EBool = ( EFalse = 0, ETrue = 1, _dummy_EBoolValue = $0FFFFFFF); //do NOT use _dummy_*

type
  PEBool  = ^EBool;
  PByteArray = ^TByteArray;
  TByteArray = array[0..32767] of Byte;

type
  DTBOOL   = SmallInt;  // SDT_BOOL���͵�ֵ����
  PDTBOOL  = ^DTBOOL;
const
  BL_TRUE  = -1; // SDT_BOOL���͵���ֵ
  BL_FALSE =  0; // SDT_BOOL���͵ļ�ֵ

type PDATE = ^TDateTime; //???

type
  DATA_TYPE  = LongWord;    // ��������: _SDT_NULL, _SDT_ALL, SDT_BYTE, SDT_SHORT, SDT_INT, SDT_INT64, SDT_FLOAT, SDT_DOUBLE, SDT_BOOL, SDT_DATE_TIME, SDT_TEXT, SDT_BIN, SDT_SUB_PTR ��
  pDATA_TYPE = ^LongWord;   // DATA_TYPE �μ�����ĳ�������

const
  //////////////////////////////////////////////////////////////////////////////
  // ��������ϵͳ����Ļ����������ͣ����ɸ��ġ�(���³�����ֵ�Ķ�����Բ����д�!)
  _SDT_NULL     = 0;           // �հ���������
  _SDT_ALL      = 2147483648;  // ͨ����, ������֧�ֿ������������򷵻�ֵ���������ͣ������ڶ�����������ʱ��_SDT_ALL����ƥ�������������ͣ��������ͱ������Ҫ��
  //_SDT_NUM �ѷ���
  SDT_BYTE      = 2147483905;  // �ֽ���
  SDT_SHORT     = 2147484161;  // ��������
  SDT_INT       = 2147484417;  // ������
  SDT_INT64     = 2147484673;  // ��������
  SDT_FLOAT     = 2147484929;  // С����
  SDT_DOUBLE    = 2147485185;  // ˫����С����
  SDT_BOOL      = 2147483650;  // �߼���
  SDT_DATE_TIME = 2147483651;  // ����ʱ����
  SDT_TEXT      = 2147483652;  // �ı���
  SDT_BIN       = 2147483653;  // �ֽڼ�
  SDT_SUB_PTR   = 2147483654;  // �ӳ���ָ��
  //_SDT_VAR_REF �ѷ���
  SDT_STATMENT  = 2147483656;  // ������ͣ������ڿ��������������������͡������ݳ���Ϊ����INT����һ����¼����ӳ����ַ���ڶ�����¼������������ӳ���ı���ջ�ס�
  // !!! ע����SDT_STATMENT�������������ʱ����������������Խ������л����������ͣ����Ա��������жϴ���
  (*
  �������ӣ�
        if (pArgInf->m_dtDataType == SDT_BOOL)
            return pArgInf->m_bool;

        if (pArgInf->m_dtDataType == SDT_STATMENT)
        {
            DWORD dwEBP = pArgInf->m_statment.m_dwSubEBP;
            DWORD dwSubAdr = pArgInf->m_statment.m_dwStatmentSubCodeAdr;
            DWORD dwECX, dwEAX;

            _asm
            {
                mov eax, dwEBP
                call dwSubAdr
                mov dwECX, ecx
                mov dwEAX, eax
            }

            if (dwECX == SDT_BOOL)
                return dwEAX != 0;

            // �ͷ��ı����ֽڼ�������������ڴ档
            if (dwECX == SDT_TEXT || dwECX == SDT_BIN)
                MFree (( void* )dwEAX);
        }

        GReportError ("�������������жϵ���������ֻ�ܽ����߼�������");
  *)


const
  // ��������ϵͳ���͡��û��Զ������͡��ⶨ����������
  DTM_SYS_DATA_TYPE_MASK  = $80000000;
  DTM_USER_DATA_TYPE_MASK = $40000000;
  DTM_LIB_DATA_TYPE_MASK  = $00000000;

  // ����ϸ���û��Զ�����������
  UDTM_USER_DECLARE_MASK  = $00000000;  // �û��Զ��帴����������
  UDTM_WIN_DECLARE_MASK   = $10000000;  // �û��Զ��崰������

  // �����������е������־�����ĳ��������ֵ��λ��1�����ʾΪ���������͵����顣
  // ����־������������ʱΪ����AS_RECEIVE_VAR_OR_ARRAY��AS_RECEIVE_ALL_TYPE_DATA
  // ��־�Ŀ��������˵����Ϊ�Ƿ�Ϊ�������ݣ��������Ͼ�δʹ�á���������ط���
  // ���Ժ��Ա���־��
  DT_IS_ARY  = $20000000;

  // �����������еĴ�ַ��־�����ĳ��������ֵ��λ��1�����ʾΪ���������͵ı�����ַ��
  // ����־������������ʱΪ����AS_RECEIVE_VAR_OR_OTHER��־�Ŀ��������˵����Ϊ�Ƿ�Ϊ
  // ������ַ���������Ͼ�δʹ�á���������ط������Ժ��Ա���־��
  // ����־���ϱ�־���ܹ��档
  DT_IS_VAR  = $20000000;

  // ����İ汾���ͺ�
  PT_EDIT_VER         = 1; // Ϊ�����༭�İ汾
  PT_DEBUG_RUN_VER    = 2; // ΪDEBUG�������а汾
  PT_RELEASE_RUN_VER  = 3; // ΪRELEASE�������а汾

  
type
  //////////////////////////////////////////////////////////////////////////////
  // ��������Ϣ�����ݽṹ ARG_INFO

  pARG_INFO = ^ARG_INFO;
  ARG_INFO  = record
    m_szName         : PChar;     // ��������
    m_szExplain      : PChar;     // ������ϸ����
    m_shtBitmapIndex : SmallInt;  // �μ� CMD_INFO �е�ͬ����Ա
    m_shtBitmapCount : SmallInt;  // �μ� CMD_INFO �е�ͬ����Ա
    m_dtDataType     : DATA_TYPE; // ��������������
    m_nDefault       : LongWord;  // ����Ĭ��ֵ���������˵��
    m_dwState        : LongWord;  // ״ֵ̬���������˵���ͳ�������

    ////////////////////////////////////////////////////////////////////////////
    //
    // ����, m_nDefault Ϊϵͳ�������Ͳ�����Ĭ��ָ��ֵ���ڱ���ʱ���������Զ�������
    //
    //   1����ֵ�ͣ�ֱ��Ϊ��ֵ����ΪС����ֻ��ָ�����������֣���Ϊ��������ֻ��ָ��������INT��ֵ�Ĳ��֣���
    //   2���߼��ͣ�1 ����'��'��0 ����'��'��
    //   3���ı��ͣ�����Ա��ʱΪPCharָ�룬ָ��Ĭ���ı�����
    //   4�������������Ͳ���һ����Ĭ��ָ��ֵ��
    //
    // ����, m_dwState ����Ϊ 0 ��������ֵ����ϣ���0 ��ʾ�ò���û��Ĭ��ֵ���û������ṩ�ò�����
    //
    //   AS_HAS_DEFAULT_VALUE      = (1 shl 0);  // ��������Ĭ��ֵ��Ĭ��ֵ��m_nDefault��˵�����������ڱ༭����ʱ�ѱ���������ʱ�����ٴ���
    //   AS_DEFAULT_VALUE_IS_EMPTY = (1 shl 1);  // ��������Ĭ��ֵ��Ĭ��ֵΪ�գ����ϱ�־���⡣����ʱ�����ݹ����Ĳ����������Ϳ���Ϊ_SDT_NULL(��ʾû�в�������)��
    //   AS_RECEIVE_VAR            = (1 shl 2);  // Ϊ�������ṩ����ʱֻ���ṩ��һ�������������ṩ�����������顢�������������ֵ������ʱ�����ݹ����Ĳ������ݿ϶������ݲ�Ϊ����ı�����ַ��
    //   AS_RECEIVE_VAR_ARRAY      = (1 shl 3);  // Ϊ�������ṩ����ʱֻ���ṩ�����������飬�������ṩ��һ�������������������ֵ��
    //   AS_RECEIVE_VAR_OR_ARRAY   = (1 shl 4);  // Ϊ�������ṩ����ʱֻ���ṩ��һ�����������������飬�������ṩ�������������ֵ��������д˱�־���򴫵ݸ�������������������ͽ���ͨ��DT_IS_ARY����־���Ƿ�Ϊ���顣
    //   AS_RECEIVE_ARRAY_DATA     = (1 shl 5);  // Ϊ�������ṩ����ʱֻ���ṩ�������ݣ��粻ָ������־��Ĭ��Ϊֻ���ṩ���������ݡ���ָ���˱���־������ʱ�����ݹ����Ĳ������ݿ϶�Ϊ���顣
    //   AS_RECEIVE_ALL_TYPE_DATA  = (1 shl 6);  // Ϊ�������ṩ����ʱ����ͬʱ�ṩ��������������ݣ����ϱ�־���⡣������д˱�־���򴫵ݸ�������������������ͽ���ͨ��DT_IS_ARY����־���Ƿ�Ϊ���顣
    //   AS_RECEIVE_VAR_OR_OTHER   = (1 shl 9);  // Ϊ�������ṩ����ʱ�����ṩ��һ�������������������ֵ�������ṩ���顣������д˱�־���򴫵ݸ�������������������ͽ���ͨ��DT_IS_VAR����־���Ƿ�Ϊ������ַ��
    //
    ////////////////////////////////////////////////////////////////////////////
  end;

const
  //////////////////////////////////////////////////////////////////////////////
  // ���³������� ARG_INFO �ṹ�е� m_dwState ��Ա

  AS_HAS_DEFAULT_VALUE      = (1 shl 0);  // ��������Ĭ��ֵ��Ĭ��ֵ��m_nDefault��˵�����������ڱ༭����ʱ�ѱ���������ʱ�����ٴ���
  AS_DEFAULT_VALUE_IS_EMPTY = (1 shl 1);  // ��������Ĭ��ֵ��Ĭ��ֵΪ�գ����ϱ�־���⡣����ʱ�����ݹ����Ĳ����������Ϳ���Ϊ_SDT_NULL(��ʾû�в�������)��
  AS_RECEIVE_VAR            = (1 shl 2);  // Ϊ�������ṩ����ʱֻ���ṩ��һ�������������ṩ�����������顢�������������ֵ������ʱ�����ݹ����Ĳ������ݿ϶������ݲ�Ϊ����ı�����ַ��
  AS_RECEIVE_VAR_ARRAY      = (1 shl 3);  // Ϊ�������ṩ����ʱֻ���ṩ�����������飬�������ṩ��һ�������������������ֵ��
  AS_RECEIVE_VAR_OR_ARRAY   = (1 shl 4);  // Ϊ�������ṩ����ʱֻ���ṩ��һ�����������������飬�������ṩ�������������ֵ��������д˱�־���򴫵ݸ�������������������ͽ���ͨ��DT_IS_ARY����־���Ƿ�Ϊ���顣
  AS_RECEIVE_ARRAY_DATA     = (1 shl 5);  // Ϊ�������ṩ����ʱֻ���ṩ�������ݣ��粻ָ������־��Ĭ��Ϊֻ���ṩ���������ݡ���ָ���˱���־������ʱ�����ݹ����Ĳ������ݿ϶�Ϊ���顣
  AS_RECEIVE_ALL_TYPE_DATA  = (1 shl 6);  // Ϊ�������ṩ����ʱ����ͬʱ�ṩ��������������ݣ����ϱ�־���⡣������д˱�־���򴫵ݸ�������������������ͽ���ͨ��DT_IS_ARY����־���Ƿ�Ϊ���顣
  AS_RECEIVE_VAR_OR_OTHER   = (1 shl 9);  // Ϊ�������ṩ����ʱ�����ṩ��һ�������������������ֵ�������ṩ���顣������д˱�־���򴫵ݸ�������������������ͽ���ͨ��DT_IS_VAR����־���Ƿ�Ϊ������ַ��

  //////////////////////////////////////////////////////////////////////////////

type
  //////////////////////////////////////////////////////////////////////////////
  // ��������Ϣ�����ݽṹ CMD_INFO

  pCMD_INFO = ^CMD_INFO;
  CMD_INFO  = record
    m_szName         : PChar;     // ������������
    m_szEGName       : PChar;     // ����Ӣ�����ƣ�����Ϊ�ջ�nil
    m_szExplain      : PChar;     // ������ϸ����
    m_shtCategory    : SmallInt;  // ȫ�������������𣬴�1��ʼ����һ���ֵΪָ��LIB_INFO��m_szzCategory��Ա���ṩ��ĳ������ַ���������; �����Ա����Ĵ�ֵΪ-1
    m_wState         : Word;      // ����״̬���������˵�����������ͺ�������
    m_dtRetType      : DATA_TYPE; // ����ֵ���ͣ�ʹ��ǰע��ת��HIWORDΪ0���ڲ���������ֵ��������ʹ�õ���������ֵ��
    m_wReserved      : Word;      // ����������Ϊ0
    m_shtUserLevel   : SmallInt;  // �Ѷȵȼ���ȡֵ1,2,3���ֱ������-��-�ߡ������������˵������������
    m_shtBitmapIndex : SmallInt;  // ָ��ͼ����������1��ʼ��0��ʾ�ޡ���һ���ֵΪָ��֧�ֿ�����Ϊ"LIB_BITMAP"��BITMAP��Դ��ĳһ����16X13λͼ������
    m_shtBitmapCount : SmallInt;  // ͼ����Ŀ(����ΪIDE�ṩ����ͼƬ)
    m_nArgCount      : LongWord;  // ����Ĳ�����Ŀ
    m_pBeginArgInfo  : pARG_INFO; // ָ������Ĳ���������Ϣ����

    ////////////////////////////////////////////////////////////////////////////
    // ����, m_wState ȡ 0 ������ֵ����ϣ���0 ��ʾ������Ϊ�������
    //   CT_IS_HIDED                = (1 shl 2);  // �������Ƿ�Ϊ�������������Ҫ���û�ֱ�����������(��ѭ����������)�򱻷�����Ϊ�˱��ּ�������Ҫ���ڵ����
    //   CT_IS_ERROR                = (1 shl 3);  // �������ڱ����в���ʹ�ã����д˱�־һ����������Ҫ�����ڲ�ͬ���԰汾����ͬ����ʹ�ã�����A������A���԰汾���п�����Ҫʵ�ֲ�ʹ�ã�����B���԰汾���п��ܾͲ���Ҫ�����������ʹ���˾��д˱�־�������ֻ��֧�ָó������ͱ��룬������֧�����С�����д˱�־�����Բ�ʵ�ֱ������ִ�в��֡�
    //   CT_DISABLED_IN_RELEASE_VER = (1 shl 4);  // ���б���־��������������ϵͳ����RELEASE���׳���ʱ������������������������޷���ֵ
    //   CT_ALLOW_APPEND_NEW_ARG    = (1 shl 5);  // �ڱ�����Ĳ������ĩβ�Ƿ��������µĲ������²�����ͬ�ڲ������е����һ������
    //   CT_RETURN_ARRAY_DATA       = (1 shl 6);  // ����˵��m_dtRetType���Ƿ񷵻���������
    //   CT_IS_OBJ_COPY_CMD         = (1 shl 7);
    //   // ˵��������Ϊĳ�������͵ĸ��ƺ���(ִ�н���һͬ���������������ݸ��Ƶ�������ʱ����Ҫ��
    //   // ����������ڱ�����������Ͷ���ĸ�ֵ���ʱ���������ͷŸö����ԭ�����ݣ�Ȼ�����ɵ��ô�
    //   // ����Ĵ��룬�����������������κγ��渳ֵ�����ƴ���)��
    //   // !!! 1����������������һ��ͬ�������Ͳ������Ҳ������κ����ݡ�
    //   //     2��ִ�б�����ʱ�������������Ϊδ��ʼ��״̬�������ڱ��븺���ʼ����ȫ����Ա���ݡ�
    //   //     3�����ṩ�����Ĵ������������Ͳ������ݿ���Ϊȫ��״̬���ɱ������Զ����ɵĶ����ʼ�������ã���
    //   // ����ʱ��Ҫ�Դ��������������
    //   CT_IS_OBJ_FREE_CMD         = (1 shl 8);
    //   // ˵��������Ϊĳ�������͵���������(ִ�е�������������������ʱ����Ҫ��ȫ��������
    //   // �����󳬳�����������ʱ�������������ɵ��ô�����Ĵ��룬�����������κγ������ٴ���)��
    //   // !!! 1�����������û���κβ������Ҳ������κ����ݡ�
    //   //     2�������ִ��ʱ������������ݿ���Ϊȫ��״̬���ɱ������Զ����ɵĶ����ʼ�������ã���
    //   // �ͷ�ʱ��Ҫ�Դ��������������
    //   CT_IS_OBJ_CONSTURCT_CMD    = (1 shl 9);
    //   // ˵��������Ϊĳ�������͵Ĺ��캯��(ִ�е��������������ݳ�ʼ��ʱ����Ҫ��ȫ��������
    //   // !!! 1�����������û���κβ������Ҳ������κ����ݡ�
    //   //     2�������ִ��ʱ�������������Ϊȫ��״̬��
    //   //     3��ָ�����ͳ�Ա�������������ͳ�Ա�������Ա�������밴�ն�Ӧ��ʽ����������һ����ʼ����
    //   _CMD_OS(os) // ˵����������֧�ֵĲ���ϵͳ��ע��_CMD_OS()��һ����������������ָ�������Ƿ�֧��ָ������ϵͳ��
    //
    // ����, m_shtUserLevel ȡ����ֵ֮һ��
    //   LVL_SIMPLE    = 1;               // ����
    //   LVL_SECONDARY = 2;               // �м�
    //   LVL_HIGH      = 3;               // �߼�
    //
    // !!!!! ǧ��ע�⣺�������ֵ����(m_dtRetType)����Ϊ _SDT_ALL ��
    // ���Բ��ܷ�������(��CT_RETURN_ARRAY_DATA��λ)�򸴺��������͵�����(���û�����Զ����������͵����������ڻ�˵���Ԫ)����Ϊ�޷��Զ�ɾ������������������Ķ���ռ�(���ı��ͻ����ֽڼ��ͳ�Ա��)��
    // ����ͨ��������ֻ����ͨ��������أ��������_SDT_ALL���͵�����ֻ����Ϊ�������ϵͳ�������ͻ򴰿�������˵��������͡�
    ////////////////////////////////////////////////////////////////////////////
  end;

  function _CMD_OS(os: LongWord): Word;          // ����ת��os�����Ա���뵽CMD_INFO.m_wState
  function _TEST_CMD_OS(m_wState: Word; os: LongWord): boolean; // ��������ָ�������Ƿ�֧��ָ������ϵͳ

const
  //////////////////////////////////////////////////////////////////////////////
  // ���³������� CMD_INFO �ṹ�� m_wState �� m_shtUserLevel ��Ա�У�

  // ����״̬(m_wState)
  CT_IS_HIDED                = (1 shl 2);  // �������Ƿ�Ϊ�������������Ҫ���û�ֱ�����������(��ѭ����������)�򱻷�����Ϊ�˱��ּ�������Ҫ���ڵ����
  CT_IS_ERROR                = (1 shl 3);  // �������ڱ����в���ʹ�ã����д˱�־һ����������Ҫ�����ڲ�ͬ���԰汾����ͬ����ʹ�ã�����A������A���԰汾���п�����Ҫʵ�ֲ�ʹ�ã�����B���԰汾���п��ܾͲ���Ҫ�����������ʹ���˾��д˱�־�������ֻ��֧�ָó������ͱ��룬������֧�����С�����д˱�־�����Բ�ʵ�ֱ������ִ�в��֡�
  CT_DISABLED_IN_RELEASE_VER = (1 shl 4);  // ���б���־��������������ϵͳ����RELEASE���׳���ʱ������������������������޷���ֵ
  CT_ALLOW_APPEND_NEW_ARG    = (1 shl 5);  // �ڱ�����Ĳ������ĩβ�Ƿ��������µĲ������²�����ͬ�ڲ������е����һ������
  CT_RETURN_ARRAY_DATA       = (1 shl 6);  // ����˵��m_dtRetType���Ƿ񷵻���������
  CT_IS_OBJ_COPY_CMD         = (1 shl 7);
  // ˵��������Ϊĳ�������͵ĸ��ƺ���(ִ�н���һͬ���������������ݸ��Ƶ�������ʱ����Ҫ��
  // ����������ڱ�����������Ͷ���ĸ�ֵ���ʱ���������ͷŸö����ԭ�����ݣ�Ȼ�����ɵ��ô�
  // ����Ĵ��룬�����������������κγ��渳ֵ�����ƴ���)��
  // !!! 1����������������һ��ͬ�������Ͳ������Ҳ������κ����ݡ�
  //     2��ִ�б�����ʱ�������������Ϊδ��ʼ��״̬�������ڱ��븺���ʼ����ȫ����Ա���ݡ�
  //     3�����ṩ�����Ĵ������������Ͳ������ݿ���Ϊȫ��״̬���ɱ������Զ����ɵĶ����ʼ�������ã���
  // ����ʱ��Ҫ�Դ��������������
  CT_IS_OBJ_FREE_CMD         = (1 shl 8);
  // ˵��������Ϊĳ�������͵���������(ִ�е�������������������ʱ����Ҫ��ȫ��������
  // �����󳬳�����������ʱ�������������ɵ��ô�����Ĵ��룬�����������κγ������ٴ���)��
  // !!! 1�����������û���κβ������Ҳ������κ����ݡ�
  //     2�������ִ��ʱ������������ݿ���Ϊȫ��״̬���ɱ������Զ����ɵĶ����ʼ�������ã���
  // �ͷ�ʱ��Ҫ�Դ��������������
  CT_IS_OBJ_CONSTURCT_CMD    = (1 shl 9);
  // ˵��������Ϊĳ�������͵Ĺ��캯��(ִ�е��������������ݳ�ʼ��ʱ����Ҫ��ȫ��������
  // !!! 1�����������û���κβ������Ҳ������κ����ݡ�
  //     2�������ִ��ʱ�������������Ϊȫ��״̬��
  //     3��ָ�����ͳ�Ա�������������ͳ�Ա�������Ա�������밴�ն�Ӧ��ʽ����������һ����ʼ����

  //_CMD_OS(os) // ˵����������֧�ֵĲ���ϵͳ��ע��_CMD_OS()��һ������������ת��os�����Ա���뵽CMD_INFO.m_wState��

  // ������Ѷȵȼ�(m_shtUserLevel)
  LVL_SIMPLE    = 1;  // ����
  LVL_SECONDARY = 2;  // �м�
  LVL_HIGH      = 3;  // �߼�

  //////////////////////////////////////////////////////////////////////////////

type
  pLIB_DATA_TYPE_ELEMENT = ^LIB_DATA_TYPE_ELEMENT;
  LIB_DATA_TYPE_ELEMENT  = record
    m_dtDataType : DATA_TYPE ; // �����ݳ�Ա���������͡�
    m_pArySpec   : PByte;      // �������ԱΪ���飬�򱾳�Ա�ṩ����ָ�����������ֵΪNULL������ָ�����ĸ�ʽΪ������Ϊһ��Byte��¼�������ά�������Ϊ0��ʾ��Ϊ���飬���ֵΪ0x7f����Ȼ��Ϊ��Ӧ��Ŀ��Integerֵ˳���¼��Ӧά��Ԫ����Ŀ��
    m_szName     : PChar;      // �����ݳ�Ա�����ƣ���������ݳ�Ա��������������ֻ����һ�����ݳ�Ա����ֵӦ��ΪNULL��
    m_szEGName   : PChar;      // �����ݳ�Ա��Ӣ�����ƣ�����Ϊ�ջ�NULL��
    m_szExplain  : PChar;      // �����ݳ�Ա����ϸ˵����

    m_dwState    : LongWord;   // ״ֵ̬��������ĳ������塣
    m_nDefault   : Integer;    // Ĭ��ֵ��!!! ���λ��ö�����������У��򱾳�ԱΪ�����ö����ֵ��

    ////////////////////////////////////////////////////////////////////////////
    //
    // ���У�m_dwState��ȡ����ֵ����ϣ�
    //   LES_HAS_DEFAULT_VALUE = (1 shl 0);  // �����ݳ�Ա��Ĭ��ֵ��Ĭ��ֵ��m_nDefault��˵����
    //   LES_HIDED             = (1 shl 1);  // �������ݳ�Ա�����ء�
    // 
    // �������ݳ�Ա��Ĭ��ֵ(m_nDefault)��
    //
    //   1����ֵ�ͣ�ֱ��Ϊ��ֵ����ΪС����ֻ��ָ�����������֣���Ϊ��������ֻ��ָ��������INT��ֵ�Ĳ��֣���
    //   2���߼��ͣ�1 �����棬0 ����٣�
    //   3���ı��ͣ���������ʱΪPCharָ�룬ָ��Ĭ���ı�����
    //   4�������������Ͳ���һ����Ĭ��ָ��ֵ��
    //
    ////////////////////////////////////////////////////////////////////////////
  end;

const
  //////////////////////////////////////////////////////////////////////////////
  // ���³�������LIB_DATA_TYPE_ELEMENT�ṹ��m_dwState��Ա

  LES_HAS_DEFAULT_VALUE = (1 shl 0);  // �����ݳ�Ա��Ĭ��ֵ��Ĭ��ֵ��m_nDefault��˵����
  LES_HIDED             = (1 shl 1);  // �������ݳ�Ա�����ء�

type
  //////////////////////////////////////////////////////////////////////////////
  // �����ڵ�Ԫ���ԡ���UNIT_PROPERTY

  pUNIT_PROPERTY = ^UNIT_PROPERTY;
  UNIT_PROPERTY  = record
    m_szName     : PChar;     // �������ƣ�ע��Ϊ���������Ա���ͬʱ���ö��������ԣ���ͬ�������Ե��������һ�¡�
    m_szEGName   : PChar;     // Ӣ�����ơ�
    m_szExplain  : PChar;     // ���Խ��͡�
    m_shtType    : SmallInt;  // ���Ե��������ͣ�������ĳ�������
    m_wState     : Word;      // ״ֵ̬��������ĳ������壬ͬʱ����ʹ�ú���_PROP_OS(os)������������֧�ֵĲ���ϵͳ��
    m_szzPickStr : PChar;     // ˳���¼��"\0"�ָ������б�ѡ�ı�������UD_FILE_NAMEΪ��˵���������ʽ���������һ��"\0"��������m_nTypeΪUD_PICK_INT��UD_PICK_TEXT��UD_EDIT_PICK_TEXT��UD_FILE_NAMEʱ����ΪNULL����m_nTypeΪUD_PICK_SPEC_INTʱ��ÿһ�ѡ�ı��ĸ�ʽΪ ��ֵ�ı� + "\0" + ˵���ı� + "\0" ��
  end;

  function _PROP_OS(os: LongWord): Word; //����ת��os�����Ա���뵽m_wState��
  function _TEST_PROP_OS(m_wState: Word; os: LongWord): boolean; //��������ָ�������Ƿ�֧��ָ������ϵͳ��

  //////////////////////////////////////////////////////////////////////////////

const
  //////////////////////////////////////////////////////////////////////////////
  // ���³�������UNIT_PROPERTY�ṹ��m_shtType��m_wState��Ա

  // �����ڵ�Ԫ���ԡ�����������(m_shtType)
  UD_PICK_SPEC_INT    = 1000;  // ����ΪINTֵ���û�ֻ��ѡ�񣬲��ܱ༭��
  UD_INT              = 1001;  // ����ΪINTֵ
  UD_DOUBLE           = 1002;  // ����ΪDOUBLEֵ
  UD_BOOL             = 1003;  // ����ΪBOOLֵ
  UD_DATE_TIME        = 1004;  // ����ΪDATEֵ
  UD_TEXT             = 1005;  // ����Ϊ�ַ���
  UD_PICK_INT         = 1006;  // ����ΪINTֵ���û�ֻ��ѡ�񣬲��ܱ༭��
  UD_PICK_TEXT        = 1007;  // ����Ϊ��ѡ�ַ������û�ֻ��ѡ�񣬲��ܱ༭��
  UD_EDIT_PICK_TEXT   = 1008;  // ����Ϊ��ѡ�ַ������û����Ա༭��
  UD_PIC              = 1009;  // ΪͼƬ�ļ�����
  UD_ICON             = 1010;  // Ϊͼ���ļ�����
  UD_CURSOR           = 1011;  // ��һ��INT��¼���ָ�����ͣ�����ֵ��Windows API��LoadCursor��������Ϊ-1����Ϊ�Զ������ָ�룬��ʱ�����Ӧ���ȵ����ָ���ļ����ݡ�
  UD_MUSIC            = 1012;  // Ϊ�����ļ�����
  UD_FONT             = 1013;  // Ϊһ��LOGFONT���ݽṹ�������ٸġ�
  UD_COLOR            = 1014;  // ����ΪCOLORREFֵ��
  UD_COLOR_TRANS      = 1015;  // ����ΪCOLORREFֵ������͸����ɫ(��CLR_DEFAULT����CLR_DEFAULT��VC++��COMMCTRL.Hͷ�ļ��ж���)��
  UD_FILE_NAME        = 1016;  // ����Ϊ�ļ����ַ�������ʱm_szzPickStr�е�����Ϊ���Ի������ + "\0" + �ļ��������� + "\0" + Ĭ�Ϻ�׺ + "\0" + "1"��ȡ�����ļ�������"0"��ȡ�����ļ�����+ "\0" ��
  UD_COLOR_BACK       = 1017;  // ����ΪCOLORREFֵ������ϵͳĬ�ϱ�����ɫ(��CLR_DEFAULT����)��
  //UD_ODBC_CONNECT_STR = 1021;  // ODBC���������ı�
  //UD_ODBC_SELECT_STR  = 1022;  // ODBC���ݲ�ѯSQL�ı�
  UD_IMAGE_LIST       = 1023;  // ͼƬ�飬���ݽṹΪ
    {  #define	IMAGE_LIST_DATA_MARK	(MAKELONG ('IM', 'LT'))
	/*
	DWORD: ��־���ݣ�Ϊ IMAGE_LIST_DATA_MARK
	COLORREF: ͸����ɫ������ΪCLR_DEFAULT��
	����ΪͼƬ�����ݣ���CImageList::Read��CImageList::Write��д��
	*/
    }
  UD_CUSTOMIZE        = 1024;  // �Զ�����������

  // �����ڵ�Ԫ���ԡ���״ֵ̬(m_wState)
  UW_HAS_INDENT  = (1 shl 0);  // �����Ա�����ʾʱ��������һ�Σ�һ�����������ԡ�
  UW_GROUP_LINE  = (1 shl 1);  // �����Ա��б���������ʾ����׷��ߡ�
  UW_ONLY_READ   = (1 shl 2);  // ֻ�����ԣ����ʱ�����ã�����ʱ����д��
  UW_CANNOT_INIT = (1 shl 3);  // ���ʱ�����ã�������ʱ����������д�����ϱ�־���⡣
  UW_IS_HIDED    = (1 shl 4);  // ���ص����á�3.2 ������
  //_PROP_OS(os)   // ˵����������֧�ֵĲ���ϵͳ��_PROP_OS()��һ������������ת��os�����Ա���뵽m_wState��

  //////////////////////////////////////////////////////////////////////////////

const
  // �̶����Ե���Ŀ
  FIXED_WIN_UNIT_PROPERTY_COUNT = 8;

  // ÿ���̶����Զ���
  FIXED_WIN_UNIT_PROPERTY : array[0..FIXED_WIN_UNIT_PROPERTY_COUNT-1] of UNIT_PROPERTY =
   (( m_szName: PChar('���');     m_szEGName: PChar('left');         m_szExplain: nil; m_shtType: UD_INT;    m_wState: (OS_ALL shr 16); m_szzPickStr: nil ),
    ( m_szName: PChar('����');     m_szEGName: PChar('top');          m_szExplain: nil; m_shtType: UD_INT;    m_wState: (OS_ALL shr 16); m_szzPickStr: nil ),
    ( m_szName: PChar('���');     m_szEGName: PChar('width');        m_szExplain: nil; m_shtType: UD_INT;    m_wState: (OS_ALL shr 16); m_szzPickStr: nil ),
    ( m_szName: PChar('�߶�');     m_szEGName: PChar('height');       m_szExplain: nil; m_shtType: UD_INT;    m_wState: (OS_ALL shr 16); m_szzPickStr: nil ),
    ( m_szName: PChar('���');     m_szEGName: PChar('tag');          m_szExplain: nil; m_shtType: UD_TEXT;   m_wState: (OS_ALL shr 16); m_szzPickStr: nil ),
    ( m_szName: PChar('����');     m_szEGName: PChar('visible');      m_szExplain: nil; m_shtType: UD_BOOL;   m_wState: (OS_ALL shr 16); m_szzPickStr: nil ),
    ( m_szName: PChar('��ֹ');     m_szEGName: PChar('disable');      m_szExplain: nil; m_shtType: UD_BOOL;   m_wState: (OS_ALL shr 16); m_szzPickStr: nil ),
    ( m_szName: PChar('���ָ��'); m_szEGName: PChar('MousePointer'); m_szExplain: nil; m_shtType: UD_CURSOR; m_wState: (OS_ALL shr 16); m_szzPickStr: nil ));

  // ע��(OS_ALL shr 16) �� _PROP_OS(OS_ALL)  // �̶�����֧�����в���ϵͳ
  //////////////////////////////////////////////////////////////////////////////

type
  //////////////////////////////////////////////////////////////////////////////
  // ���¼�������Ϣ��EVENT_ARG_INFO�ṹ //3.2 ���Ժ�ʹ�õڶ����汾EVENT_ARG_INFO2

  pEVENT_ARG_INFO = ^EVENT_ARG_INFO;
  EVENT_ARG_INFO  = record
    m_szName    : PChar;  // ��������
    m_szExplain : PChar;  // ������ϸ����
    m_dwState   : Word;   // ״ֵ̬��������ĳ������壨const EAS_IS_BOOL_ARG = (1 shl 0);��
  end;

const
  //////////////////////////////////////////////////////////////////////////////
  // ���³���������EVENT_ARG_INFO�ṹ��m_dwState��Ա

  EAS_IS_BOOL_ARG = (1 shl 0); // Ϊ�߼��Ͳ��������޴˱�־������Ϊ�������Ͳ���

type
  //////////////////////////////////////////////////////////////////////////////
  // ���¼���Ϣ��EVENT_ARG_INFO�ṹ //3.2 ���Ժ�ʹ�õڶ����汾EVENT_ARG_INFO2

  pEVENT_INFO = ^EVENT_INFO;
  EVENT_INFO  = record
    m_szName        : PChar;           // �¼�����
    m_szExplain     : PChar;           // �¼���ϸ����
    m_dwState       : Longword;        // ״ֵ̬��������ĳ�������������
    m_nArgCount     : Integer;         // �¼��Ĳ�����Ŀ
    m_pEventArgInfo : PEVENT_ARG_INFO; // �¼�����
  end;

  function _EVENT_OS(os: LongWord): LongWord; // ����ת��os�����Ա���뵽m_dwState
  function _TEST_EVENT_OS(m_dwState,os: LongWord): boolean; // ��������ָ���¼��Ƿ�֧��ָ������ϵͳ

  //////////////////////////////////////////////////////////////////////////////

const
  //////////////////////////////////////////////////////////////////////////////
  // ���³�������EVENT_INFO�ṹ��m_dwState��Ա

  EV_IS_HIDED    = (1 shl 0);  // ���¼��Ƿ�Ϊ�����¼��������ܱ�һ���û���ʹ�û򱻷�����Ϊ�˱��ּ�������Ҫ���ڵ��¼�����
  //EV_IS_MOUSE_EVENT = (1 shl 1); //�ѷ���
  EV_IS_KEY_EVENT= (1 shl 2);
  EV_RETURN_INT  = (1 shl 3);  // ���¼��Ĵ����ӳ�����Ҫ����һ������ֵ�����±�־���⡣
  EV_RETURN_BOOL = (1 shl 4);  // ���¼��Ĵ����ӳ�����Ҫ����һ���߼�ֵ�����ϱ�־���⡣
  //_EVENT_OS(os)  // �������¼���֧�ֵĲ���ϵͳ��_EVENT_OS()��һ������������ת��os�����Ա���뵽m_dwState��

  //////////////////////////////////////////////////////////////////////////////

type
  //////////////////////////////////////////////////////////////////////////////
  // ���¼�������Ϣ��EVENT_ARG_INFO2�ṹ //3.2 ���Ժ�ʹ��

  pEVENT_ARG_INFO2 = ^EVENT_ARG_INFO2;
  EVENT_ARG_INFO2  = record
    m_szName    : PChar;      // ��������
    m_szExplain : PChar;      // ������ϸ����
    m_dwState   : Word;       // ״ֵ̬��������ĳ������壨const EAS_BY_REF = (1 shl 1);��
    m_dtDataType: DATA_TYPE;  // ��������
  end;

const
  //////////////////////////////////////////////////////////////////////////////
  // ���³���������EVENT_ARG_INFO2�ṹ��m_dwState��Ա

  EAS_BY_REF = (1 shl 1); // �Ƿ���Ҫ�Բο���ʽ��ֵ�������λ����֧�ֿ����׳��¼��Ĵ������ȷ�����ܹ���ϵͳ�����ʣ��������ڴ�ķ��������ݵĸ�ʽ�������Ҫ�󣩡�

type
  //////////////////////////////////////////////////////////////////////////////
  // ���¼���Ϣ��EVENT_ARG_INFO2�ṹ //3.2 ���Ժ�ʹ��

  pEVENT_INFO2 = ^EVENT_INFO2;
  EVENT_INFO2  = record
    m_szName        : PChar;            // �¼�����
    m_szExplain     : PChar;            // �¼���ϸ����
    m_dwState       : Longword;         // ״ֵ̬��������ĳ�������
    m_nArgCount     : Integer;          // �¼��Ĳ�����Ŀ
    m_pEventArgInfo : PEVENT_ARG_INFO2; // �¼�����
    m_dtRetDataType : DATA_TYPE;        // �¼�����ֵ���ͣ�//!!! ��������������ж����������Ҫ�ͷţ���Ҫ��֧�ֿ����׳��¼��Ĵ��븺�����ͷš�
  end;

  //function _EVENT_OS(os: LongWord): LongWord; // ����ת��os�����Ա���뵽m_dwState
  //function _TEST_EVENT_OS(m_dwState,os: LongWord): boolean; // ��������ָ���¼��Ƿ�֧��ָ������ϵͳ
  //////////////////////////////////////////////////////////////////////////////

const
  //////////////////////////////////////////////////////////////////////////////
  // ���³�������EVENT_INFO2�ṹ��m_dwState��Ա

  //EV_IS_HIDED    = (1 shl 0);  // ���¼��Ƿ�Ϊ�����¼��������ܱ�һ���û���ʹ�û򱻷�����Ϊ�˱��ּ�������Ҫ���ڵ��¼�����
  //EV_IS_KEY_EVENT= (1 shl 2);
  //����������(����EVENT_INFO��ʹ��)ǰ���Ѷ���
  EV_IS_VER2       = (1 shl 31); // ��ʾ���ṹΪEVENT_INFO2��!!!ʹ�ñ��ṹʱ������ϴ�״ֵ̬��
  //_EVENT_OS(os)  // �������¼���֧�ֵĲ���ϵͳ��_EVENT_OS()��һ������������ת��os�����Ա���뵽m_dwState��

  //////////////////////////////////////////////////////////////////////////////


type HUNIT = LongWord;

type PFN_INTERFACE = procedure(); stdcall;  // ͨ�ýӿ�ָ��


const
  //////////////////////////////////////////////////////////////////////////////
  // ���ڵ�Ԫ����ӿ�ID

  ITF_CREATE_UNIT             = 1;  // �������

  // ���������ӿڽ��ڿ��ӻ���ƴ��ڽ���ʱʹ�á�
  ITF_PROPERTY_UPDATE_UI      = 2;  // ˵������Ŀǰ�ɷ��޸�
  ITF_DLG_INIT_CUSTOMIZE_DATA = 3;  // ʹ�öԻ��������Զ�������

  ITF_NOTIFY_PROPERTY_CHANGED = 4;  // ֪ͨĳ�������ݱ��޸�
  ITF_GET_ALL_PROPERTY_DATA   = 5;  // ȡȫ����������
  ITF_GET_PROPERTY_DATA       = 6;  // ȡĳ��������
  ITF_GET_ICON_PROPERTY_DATA  = 7;  // ȡ���ڵ�ͼ���������ݣ������ڴ��ڣ�
  ITF_IS_NEED_THIS_KEY        = 8;  // ѯ�ʵ�Ԫ�Ƿ���Ҫָ���İ�����Ϣ���������ڵ�Ԫ�ػ���Ĭ��Ϊ����ʱ��������İ�������TAB��SHIFT+TAB��UP��DOWN�ȡ�
  ITF_LANG_CNV                = 9;  // �����������ת��
  //û��10
  ITF_MSG_FILTER              = 11; // ��Ϣ����
  ITF_GET_NOTIFY_RECEIVER     = 12; // ȡ����ĸ���֪ͨ������(PFN_ON_NOTIFY_UNIT)

type

  PFN_GET_INTERFACE = function (nInterfaceNO: Integer) : PFN_INTERFACE; stdcall;

  //////////////////////////////////////////////////////////////////////////////
  // �ӿڣ�

  // ������Ԫ���ɹ�ʱ����HUNIT��ʧ�ܷ���NULL��
  PFN_CREATE_UNIT = function (
    pAllPropertyData     : PByte;      // ָ�򱾴��ڵ�Ԫ�������������ݣ��ɱ����ڵ�Ԫ��
    nAllPropertyDataSize : Integer;    // �ṩpAllPropertyData��ָ�����ݵĳߴ磬���û����Ϊ0��
    dwStyle        : LongWord;         // Ԥ�����õĴ��ڷ��
    hParentWnd     : LongWord;         // �����ھ����
    uID            : LongWord;         // �ڸ������е�ID��
    hMenu          : LongWord;         // δʹ�á�
    x, y           : Integer;          // λ��
    cx, cy         : Integer;          // �ߴ�
    dwWinFormID    : LongWord;         // �����ڵ�Ԫ���ڴ��ڵ�ID������֪ͨ��ϵͳ��
    dwUnitID       : LongWord;         // �����ڵ�Ԫ��ID������֪ͨ��ϵͳ��
    hDesignWnd     : LongWord = 0;     // ���blInDesignModeΪ�棬��hDesignWnd�ṩ����ƴ��ڵĴ��ھ����
    blInDesignMode : EBool = EFalse    // ˵���Ƿ�������IDE�����Խ��п��ӻ���ƣ�����ʱΪ�١�
  ) : LongWord; stdcall;

  //�����������ת�������ذ���ת����������ݵ�HGLOBAL(LongWord)�����ʧ�ܷ���nil��
  PFN_CNV = procedure (
    ps      : PChar;
    dwState : LongWord;
    nParam  : Integer
  ); stdcall;

const
  // ����ָ��PFN_CNV�е�dwState��������Ϊ����ֵ����ϡ�
  CNV_NULL     = 0;
  CNV_FONTNAME = 1;  // Ϊת��������������(���ڿ��ܱ䳤��ps�б��뱣֤���㹻�Ŀռ���ת�����������)��

type
  // �����������ת�������ذ���ת����������ݵ�HGLOBAL(LongWord)�����ʧ�ܷ���nil��
  PFN_LANG_CNV = function (
    pAllData      : PByte;
    pnAllDataSize : PInteger;
    fnCnv         : PFN_CNV;
    nParam        : Integer  // nParam����ԭֵ���ݸ�fnCnv�Ķ�Ӧ������
  ) : LongWord; stdcall;

  // ���º����������ʱʹ�á�

  // ���ָ������Ŀǰ���Ա������������棬���򷵻ؼ١�
  PFN_PROPERTY_UPDATE_UI = function (
    hUnit          : LongWord;         // ��PFN_CREATE_UNIT���ص��Ѵ������ڵ�Ԫ�ľ������ͬ��
    nPropertyIndex : Integer           // ����Ҫ��ѯ���Ե�����ֵ����ͬ��
  ) : EBool; stdcall;

  // ������������ΪUD_CUSTOMIZE�ĵ�Ԫ���ԡ������Ҫ���´����õ�Ԫ�����޸ĵ�Ԫ���Σ��뷵���档
  PFN_DLG_INIT_CUSTOMIZE_DATA = function (
    hUnit          : LongWord;
    nPropertyIndex : Integer;
    pblModified    : PEBool= nil;   // ���pblModified��Ϊnil���������з����Ƿ��û������޸ģ�����������IDE����UNDO��¼����
    pReserved      : Pointer = nil     // ����δ�á�LPVOID
  ) : EBool; stdcall;

type
  // ��ʱ�ṹ������UNIT_PROPERTY_VALUE�ṹ�����ڶ���m_data��Ա
  T_UNIT_PROPERTY_VALUE__m_data  = record
    m_pData     : PByte;
    m_nDataSize : Integer;
  end;

  // ������¼ĳ���Եľ�������ֵ�� (In C/C++, UNIT_PROPERTY_VALUE is defined as an UNION)
  pUNIT_PROPERTY_VALUE = ^UNIT_PROPERTY_VALUE;
  UNIT_PROPERTY_VALUE  = record
    case Integer of
      0: (m_int        : Integer);   // ��Ӧ���������UD_INT��UD_PICK_INT����ͬ��
      1: (m_double     : Double);    // UD_DOUBLE
      3: (m_bool       : EBool);     // UD_BOOL
      4: (m_dtDateTime : TDateTime); // UD_DATE_TIME
      5: (m_clr        : Longword);  // UD_COLOR��UD_COLOR_TRANS��UD_COLOR_BACK
      6: (m_szText     : PChar);     // UD_TEXT��UD_PICK_TEXT��UD_EDIT_PICK_TEXT��UD_ODBC_CONNECT_STR��UD_ODBC_SELECT_STR
      7: (m_szFileName : PChar);     // UD_FILE_NAME
      8: (m_data : T_UNIT_PROPERTY_VALUE__m_data); // UD_PIC��UD_ICON��UD_CURSOR��UD_MUSIC��UD_FONT��UD_CUSTOMIZE��UD_IMAGE_LIST
  end;

  // ֪ͨĳ���ԣ���UD_CUSTOMIZE������ԣ����ݱ��û��޸ģ���Ҫ���ݸ��޸���Ӧ�����ڲ����ݼ����Σ����ȷʵ��Ҫ���´��������޸ĵ�Ԫ���Σ��뷵���档ע�⣺�������������ֵ�ĺϷ���У�顣
  PFN_NOTIFY_PROPERTY_CHANGED = function (
    hUnit          : LongWord;
    nPropertyIndex : Integer;               // �ڼ������Ա��޸ģ���0��ʼ(���ƻ�������)����ͬ
    pPropertyValue : PUNIT_PROPERTY_VALUE;  // �����޸ĵ���Ӧ�������ݡ�
    ppszTipText    : PPChar = nil           // Ŀǰ��δʹ�á�LPTSTR*
  ) : EBool; stdcall;

  // ȡĳ�������ݵ�pPropertyValue�У��ɹ������棬���򷵻ؼ١�ע�⣺��������ʱ���ɵ���PFN_CREATE_UNITʱ��blInDesignMode������������pPropertyValue���뷵�����洢��ֵ�����������ʱ��blInDesignModeΪ�٣������뷵��ʵ�ʵĵ�ǰʵʱֵ������˵���༭�򴰿ڵ�Ԫ�ġ����ݡ����ԣ����ʱ���뷵���ڲ��������ֵ��������ʱ�ͱ������GetWindowTextȥʵʱ��ȡ��
  PFN_GET_PROPERTY_DATA = function (
    hUnit          : LongWord;
    nPropertyIndex : Integer;
    pPropertyValue : pUNIT_PROPERTY_VALUE  // ������������ȡ���Ե����ݡ�
  ) : EBool; stdcall;

  // ���ر����ڵ�Ԫ��ȫ���������ݣ��ɸô��ڵ�Ԫ��ʵ�ִ���������Ƹ�ʽ����������������ϵ�һ�𡣴˴��ڵ�Ԫ��PFN_CREATE_UNIT�ӿڱ����ܹ���ȷ��������ݡ�
  PFN_GET_ALL_PROPERTY_DATA = function (hUnit : LongWord) : LongWord; stdcall;  // ��Delphi��, HGLOBAL=THandle=LongWord;

  // ȡ���ڵ�ͼ���������ݣ������ڴ��ڣ�
  PFN_GET_ICON_PROPERTY_DATA = function (pAllData:PByte; nAllDataSize:Integer): LongWord; stdcall;

  // ѯ�ʵ�Ԫ�Ƿ���Ҫָ���İ�����Ϣ�������Ҫ�������棬���򷵻ؼ١�
  PFN_IS_NEED_THIS_KEY = function (hUnit : LongWord; wKey : Word) : EBool; stdcall;

  // ��Ϣ����(������Ϣ���˴��������Ч,������LDT_MSG_FILTER_CONTROL���)�������˵������棬���򷵻ؼ١�
  PFN_MESSAGE_FILTER = function (pMsg: Pointer): EBool; // Windows����ϵͳ��pMsgΪָ��TMsg��ָ�롣

  // ����֪ͨ������, ����nMsgȡֵΪ NU_* ϵͳ����
	PFN_ON_NOTIFY_UNIT = function (nMsg: Integer; dwParam1: DWord = 0; dwParam2: DWord = 0): Integer; stdcall;

const
  // ���¶��� PFN_ON_NOTIFY_UNIT �ɽ��յ�ֵ֪ͨ�������ֵ
	NU_GET_CREATE_SIZE_IN_DESIGNER = 0; // ȡ���ʱ������������õ�������ʱ��Ĭ�ϴ����ߴ硣dwParam1: ����: INT*, ���ؿ��(��λ����); dwParam2: ����: INT*, ���ظ߶�(��λ����)���ɹ�����1,ʧ�ܷ���0��

const

  UNIT_BMP_SIZE       = 24;       // ��Ԫ��־λͼ�Ŀ�Ⱥ͸߶ȡ�
  UNIT_BMP_BACK_COLOR = $C0C0C0;  // ��Ԫ��־λͼ�ı�����ɫ(��ɫ): RGB(192,192,192)=$C0C0C0=12632256

type
  //////////////////////////////////////////////////////////////////////////////
  // ���ⶨ���������͡� LIB_DATA_TYPE_INFO

  pLIB_DATA_TYPE_INFO = ^LIB_DATA_TYPE_INFO;
  LIB_DATA_TYPE_INFO  = record
    m_szName      : PChar;     // ����
    m_szEGName    : PChar;     // Ӣ�����ƣ���Ϊ�ջ�nil
    m_szExplain   : PChar;     // ��ϸ���ͣ��������Ϊnil

    m_nCmdCount   : Integer;   // ���������ͳ�Ա��������Ŀ����Ϊ0��
    m_pnCmdsIndex : PInteger;  // ˳���¼�����������г�Ա����������֧�ֿ�������е�����ֵ����ΪNULL��
    m_dwState     : LongWord;  // ״ֵ̬���������˵�����������ͺ�������

    // ���³�Աֻ����Ϊ���ڵ�Ԫ���˵�ʱ����Ч��
    m_dwUnitBmpID    : LongWord;       // ָ����֧�ֿ��еĵ�Ԫͼ����ԴID��ע�ⲻͬ�������ͼ����������0Ϊ�ޡ��ߴ����Ϊ24*24 ��������ɫΪRGB(192,192,192) ��
    m_nEventCount    : Integer;        // ����Ԫ���¼���Ŀ
    m_pEventBegin    : pEVENT_INFO ;   // ���屾��Ԫ�������¼�
    m_nPropertyCount : Integer;        // ����Ԫ��������Ŀ
    m_pPropertyBegin : pUNIT_PROPERTY; // ���屾��Ԫ����������

    // �����ṩ�����ڵ�Ԫ�����нӿڡ�
    m_pfnGetInterface : PFN_GET_INTERFACE;

    // ���³�Աֻ���ڲ�Ϊ���ڵ�Ԫ���˵�ʱ����Ч��
    m_nElementCount : Integer;                 // �������������ӳ�Ա����Ŀ����Ϊ0������Ϊ���ڡ��˵���Ԫ���˱���ֵ��Ϊ0��
    m_pElementBegin : pLIB_DATA_TYPE_ELEMENT;  // ָ���ӳ�Ա������׵�ַ��

    ////////////////////////////////////////////////////////////////////////////
    //
    // ���У�m_dwState ����Ϊ���³���ֵ�ͺ���ֵ����ϣ�
    //   LDT_IS_HIDED             = (1 shl 0);  // �������Ƿ�Ϊ�������ͣ����������û�ֱ��������������ͣ��类������Ϊ�˱��ּ�������Ҫ���ڵ����ͣ�
    //   LDT_IS_ERROR             = (1 shl 1);  // �������ڱ����в���ʹ�ã����д˱�־һ����������ʹ���д˱�־�������͵���������Ҳ�����������塣
    //   LDT_MSG_FILTER_CONTROL   = (1 shl 5);  // �Ƿ�Ϊ��Ϣ���������
    //   LDT_WIN_UNIT             = (1 shl 6);  // �Ƿ�Ϊ���ڵ�Ԫ����˱�־��λ��m_nElementCount��Ϊ0
    //   LDT_IS_CONTAINER         = (1 shl 7);  // �Ƿ�Ϊ�����ʹ��ڵ�Ԫ�����д˱�־��LDT_WIN_UNIT������λ��
    //   LDT_IS_FUNCTION_PROVIDER = (1 shl 15); // �Ƿ�Ϊ�������ṩ���ܵĴ��ڵ�Ԫ����ʱ�ӣ�����˱�־��λ��LDT_WIN_UNIT����λ�����д˱�־�ĵ�Ԫ������ʱ�޿������Ρ�
    //   LDT_CANNOT_GET_FOCUS     = (1 shl 16); // ���������ڵ�Ԫ����˱�־��λ���ʾ�˵�Ԫ���ܽ������뽹�㣬����TAB��ͣ����
    //   LDT_DEFAULT_NO_TABSTOP   = (1 shl 17); // ���������ڵ�Ԫ����˱�־��λ���ʾ�˵�Ԫ���Խ������뽹�㣬��Ĭ�ϲ�ͣ��TAB��������־���ϱ�־���⡣
    //   LDT_BAR_SHAPE            = (1 shl 20); // �Ƿ�Ϊ��Ҫ�Ե���λ�û�ߴ����״���ڵ�Ԫ���繤������״̬���ȣ������ھ��д˱�־�ĵ�Ԫ�����ڴ��ڳߴ�ı������������ʱ�������Զ����͸�WU_SIZE_CHANGED��Ϣ��ע�⣺��״���ڵ�Ԫ�����Ҫ�Զ��������������� CCS_TOP ���ڷ�������Ҫ�Զ��ײ����������� CCS_BOTTOM ���ڷ��
    //   LDT_ENUM                 = (1 shl 22); // �Ƿ�Ϊö���������͡�3.7������
    //   _DT_OS(os)   //����������������֧�ֵĲ���ϵͳ��_DT_OS()��һ������������ת��os�����Ա���뵽m_dwState��
    //
    // ���� m_dwState����LDT_BAR_SHAPE��־�ĵ�Ԫ�����ڴ��ڳߴ�ı������������ʱ�������Զ����͸�WU_SIZE_CHANGED��Ϣ��
    // ע�⣬��״���ڵ�Ԫ�����Ҫ�Զ���������������CCS_TOP���ڷ�������Ҫ�Զ��ײ�����������CCS_BOTTOM���ڷ��
    //
    ////////////////////////////////////////////////////////////////////////////
  end;

  function _DT_OS(os: LongWord): LongWord;  // ����ת��os�����Ա���뵽m_dwState
  function _TEST_DT_OS(m_dwState,os: LongWord): boolean; // ��������ָ�����������Ƿ�֧��ָ������ϵͳ

const
  //////////////////////////////////////////////////////////////////////////////
  // ���³�������LIB_DATA_TYPE_INFO�ṹ��m_dwState��Ա��

  LDT_IS_HIDED             = (1 shl 0);  // �������Ƿ�Ϊ�������ͣ����������û�ֱ��������������ͣ��类������Ϊ�˱��ּ�������Ҫ���ڵ����ͣ�
  LDT_IS_ERROR             = (1 shl 1);  // �������ڱ����в���ʹ�ã����д˱�־һ����������ʹ���д˱�־�������͵���������Ҳ�����������塣

  LDT_MSG_FILTER_CONTROL   = (1 shl 5);  // �Ƿ�Ϊ��Ϣ���������
  LDT_WIN_UNIT             = (1 shl 6);  // �Ƿ�Ϊ���ڵ�Ԫ����˱�־��λ��m_nElementCount��Ϊ0
  LDT_IS_CONTAINER         = (1 shl 7);  // �Ƿ�Ϊ�����ʹ��ڵ�Ԫ�����д˱�־��LDT_WIN_UNIT������λ��

  LDT_IS_FUNCTION_PROVIDER = (1 shl 15); // �Ƿ�Ϊ�������ṩ���ܵĴ��ڵ�Ԫ����ʱ�ӣ�����˱�־��λ��LDT_WIN_UNIT����λ�����д˱�־�ĵ�Ԫ������ʱ�޿������Ρ�
  LDT_CANNOT_GET_FOCUS     = (1 shl 16); // ���������ڵ�Ԫ����˱�־��λ���ʾ�˵�Ԫ���ܽ������뽹�㣬����TAB��ͣ����
  LDT_DEFAULT_NO_TABSTOP   = (1 shl 17); // ���������ڵ�Ԫ����˱�־��λ���ʾ�˵�Ԫ���Խ������뽹�㣬��Ĭ�ϲ�ͣ��TAB��������־���ϱ�־���⡣

  // �°���û����LDT_BAR_SHAPE�Ķ��壬��֪�����⻹�����⡣�˴���Ȼ�����Լ��ݾɰ档
  LDT_BAR_SHAPE            = (1 shl 20); // �Ƿ�Ϊ��Ҫ�Ե���λ�û�ߴ����״���ڵ�Ԫ���繤������״̬���ȣ������ھ��д˱�־�ĵ�Ԫ�����ڴ��ڳߴ�ı������������ʱ�������Զ����͸�WU_SIZE_CHANGED��Ϣ��ע�⣺��״���ڵ�Ԫ�����Ҫ�Զ���������������CCS_TOP���ڷ�������Ҫ�Զ��ײ�����������CCS_BOTTOM���ڷ��
  LDT_ENUM                 = (1 shl 22); // �Ƿ�Ϊö���������͡�3.7������

  //_DT_OS(os)  // ����������������֧�ֵĲ���ϵͳ��_DT_OS()��һ������������ת��os�����Ա���뵽m_dwState��

  //////////////////////////////////////////////////////////////////////////////

type

  //////////////////////////////////////////////////////////////////////////////
  // ���ⳣ�������ݽṹ Lib_Const_Info

  pLIB_CONST_INFO = ^LIB_CONST_INFO;
  LIB_CONST_INFO  = record

    m_szName       : PChar;     // ��������
    m_szEGName     : PChar;     // ����Ӣ�����ƣ�����Ϊ�ջ�nil
    m_szExplain    : PChar;     // ��ϸ����

    m_shtReserved  : Smallint;  // ����Ϊ 1 ��
    m_shtType      : Smallint;  // �������ͣ�ȡֵΪCT_NULL,CT_NUM,CT_BOOL,CT_TEXT֮һ���������˵���ͳ�������
    m_szText       : PChar;     // �ı�����m_shtTypeȡֵΪCT_TEXTʱ��
    m_dbValue      : Double;    // ��ֵ����m_shtTypeȡֵΪCT_NUM��CT_BOOLʱ��
    ////////////////////////////////////////////////////////////////////////////
    // ���У�m_shtType ����ȡ���³���ֵ֮һ��
    //   CT_NULL  = 0;  // ��ֵ
    //   CT_NUM   = 1;  // ��ֵ�ͣ���: 3.14159
    //   CT_BOOL  = 2;  // �߼��ͣ���: 1       ( 1����'��'; 0����'��')
    //   CT_TEXT  = 3;  // �ı��ͣ���: 'abc'
    ////////////////////////////////////////////////////////////////////////////
  end;

const
  //////////////////////////////////////////////////////////////////////////////
  // ���³����� LIB_CONST_INFO �ṹ���õ�

  CT_NULL  = 0;  // ��ֵ
  CT_NUM   = 1;	 // ��ֵ�ͣ���: 3.14159
  CT_BOOL  = 2;	 // �߼��ͣ���: 1       ( 1����'��'; 0����'��')
  CT_TEXT  = 3;	 // �ı��ͣ���: 'abc'

  //////////////////////////////////////////////////////////////////////////////

type
  //////////////////////////////////////////////////////////////////////////////
  // �������ݽṹ��

  // �����ֵ������
  pSYS_NUM_VALUE = ^SYS_NUM_VALUE;
  SYS_NUM_VALUE  = record
    case Integer of
      0: ( m_byte   : Byte);
      1: ( m_short  : SmallInt);
      2: ( m_int    : Integer);
      3: ( m_int64  : Int64);
      4: ( m_float  : Single);
      5: ( m_double : Double);
  end;

  // ��ʶ���ڵ�Ԫ
  pMUNIT = ^MUNIT;
  MUNIT  = record
    m_dwFormID  : LongWord;
    m_dwUnitID  : Longword;
  end;

  //�����
  pSTATMENT_CALL_DATA = ^STATMENT_CALL_DATA;
  STATMENT_CALL_DATA  = record
      m_dwStatmentSubCodeAdr : LongWord;   // ��¼���ص�������ӳ������Ľ����ַ��
      m_dwSubEBP             : LongWord;   // ��¼������������ӳ����EBPָ�룬�Ա���ʸ��ӳ����еľֲ�������
  end;


  // ��ʱ�ṹ������MDATA_INF�����ڶ���m_Value��Ա
  T_MDATA_INF_Data = packed record
    case Integer of
       // ��һ���֡�ע�⣺����Ӧ��������AS_RECEIVE_VAR��AS_RECEIVE_VAR_ARRAY��AS_RECEIVE_VAR_OR_ARRAY��־����ʱ��ʹ������ĵڶ����֡�
    0: ( m_byte          : Byte);        // SDT_BYTE �������͵����ݣ���ͬ��
    1: ( m_short         : SmallInt);    // SDT_SHORT
    2: ( m_int           : Integer);     // SDT_INT
    3: ( m_uint          : Longword);    // (DWORD)SDT_INT, �޷���������
    4: ( m_int64         : Int64);       // SDT_INT64
    5: ( m_float         : Single);      // SDT_FLOAT
    6: ( m_double        : Double);      // SDT_DOUBLE
    7: ( m_date          : TDateTime);   // SDT_DATE_TIME   (��VC��: typedef double DATE; ��Delphi��: type TDateTime = type Double;)
    8: ( m_bool          : EBool);    // SDT_BOOL  (��VC��: typedef int BOOL;)
    9: ( m_pText         : PChar);       // SDT_TEXT������ϵͳԤ������ʹ�ǿ��ı�����ָ��ֵҲ����Ϊnil���Ա��ڴ���ָ����ָ�����ݵĸ�ʽ��ǰ���������!!!Ϊ�˱����޸ĵ�������(m_pText�п��ܻ�ָ���׳�����������)�е����ݣ�ֻ�ɶ�ȡ�����ɸ������е����ݣ���ͬ��
    10:( m_pBin          : PBYTE);       // SDT_BIN������ϵͳԤ������ʹ�ǿ��ֽڼ�����ָ��ֵҲ����Ϊnil���Ա��ڴ���ָ����ָ�����ݵĸ�ʽ��ǰ���������!!!ֻ�ɶ�ȡ�����ɸ������е����ݡ�
    11:( m_dwSubCodeAdr  : LongWord);    // SDT_SUB_PTR��Ϊ�ӳ�������ַָ�롣
    12:( m_statment      : STATMENT_CALL_DATA); // ����䡣SDT_STATMENT�������͡�
    13:( m_unit          : MUNIT);       // ���ڵ�Ԫ���˵��������͵����ݡ�
    14:( m_pCompoundData : Pointer);     // ����������������ָ�룬ָ����ָ�����ݵĸ�ʽ��ǰ���������!!! ֻ�ɶ�ȡ�����ɸ������е����ݡ�
    15:( m_pAryData      : Pointer);     // ��������ָ�룬ָ����ָ�����ݵĸ�ʽ��ǰ���������ע�����Ϊ�ı����ֽڼ����飬���Ա����ָ�����ΪNULL��!!! ֻ�ɶ�ȡ�����ɸ������е����ݡ�

       // �ڶ����֡�Ϊָ�������ַ��ָ�룬������������AS_RECEIVE_VAR��AS_RECEIVE_VAR_ARRAY��AS_RECEIVE_VAR_OR_ARRAY��־ʱ�ű�ʹ�á�
    16:( m_pByte          : ^Byte);      // SDT_BYTE �������ͱ����ĵ�ַ����ͬ��
    17:( m_pShort         : ^SmallInt);  // SDT_SHORT
    18:( m_pInt           : ^Integer);   // SDT_INT
    19:( m_pUint          : ^Longword);  // (DWORD)SDT_INT, �޷���������
    20:( m_pInt64         : ^Int64);     // SDT_INT64
    21:( m_pFloat         : ^Single);    // SDT_FLOAT
    22:( m_pDouble        : ^Double);    // SDT_DOUBLE
    23:( m_pDate          : ^TDateTime); // SDT_DATE_TIME
    24:( m_pBool          : ^EBool);  // SDT_BOOL
    25:( m_ppText         : PPChar);     // SDT_TEXT��ע��*m_ppText����ΪNULL��������ı�����д����ֵ֮ǰ�����ͷ�ǰֵ�����䣺NotifySys (NRS_MFREE, (DWORD)*m_ppText)��!!!����ֱ�Ӹ���*m_ppText��ָ������ݣ�ֻ���ͷ�ԭָ���������NULL�����ı�����ʹ��NRS_MALLOC֪ͨ��������ڴ��ַָ�루��ͬ����
    26:( m_ppBin          : ^PByte);     // SDT_BIN��ע��*m_ppBin����ΪNULL��������ֽڼ�����д����ֵ֮ǰ�����ͷ�ǰֵ�����䣺NotifySys (NRS_MFREE, (DWORD)*m_ppBin)��!!!����ֱ�Ӹ���*m_ppBin��ָ������ݣ�ֻ���ͷ�ԭָ���������NULL�����ֽڼ�������ָ�롣
    27:( m_pdwSubCodeAdr  : ^LongWord);  // SDT_SUB_PTR���ӳ�������ַ������ַ��
    28:( m_pStatment      : pSTATMENT_CALL_DATA); // ����䡣SDT_STATMENT�������͡�
    29:( m_pUnit          : ^MUNIT);     // ���ڵ�Ԫ���˵��������ͱ�����ַ��
    30:( m_ppCompoundData : ^Pointer);   // �����������ͱ�����ַ��!!!ע��д����ֵ֮ǰ����ʹ��NRS_MFREE֪ͨ��һ�ͷ����г�Ա������SDT_TEXT��SDT_BIN�������������ͳ�Ա����ԭ��ַָ�롣!!!����ֱ�Ӹ���*m_ppCompoundData��ָ������ݣ�ֻ���ͷ�ԭָ�����������ָ�롣
    31:( m_ppAryData      : ^Pointer);   // �������ݱ�����ַ��ע�⣺ 1��д����ֵ֮ǰ�����ͷ�ԭֵ�����䣺NotifySys (NRS_FREE_ARY,m_dtDataType, (DWORD)*m_ppAryData)��ע�⣺������ֻ������m_dtDataTypeΪϵͳ������������ʱ����������Ϊ�����������ͣ���������䶨����Ϣ��һ�ͷš�2�����Ϊ�ı����ֽڼ����飬�����г�Ա������ָ�����ΪNULL��!!!����ֱ�Ӹ���*m_ppAryData��ָ������ݣ�ֻ���ͷ�ԭָ�����������ָ�롣
  end;

  // MDATA_INF������¼����ָ��PFN_EXECUTE_CMD(����ʵ�ֺ���)�ķ���ֵ�Ͳ�����Ϣ
  pMDATA_INF = ^MDATA_INF;
  MDATA_INF  = packed record          // Note: packed record, it's important.
    m_Value      : T_MDATA_INF_Data;  // �������ݣ�Pascal�е�record����Ƕ�ף�����һ�ֱ�ͨ��
    m_dtDataType : DATA_TYPE;         // �������ͣ��������˵��

    ////////////////////////////////////////////////////////////////////////////
    // ���� m_dtDataType ��˵����
    //
    //  1�����������ݲ�������ʱ������ò�������AS_RECEIVE_VAR_OR_ARRAY��
    //     AS_RECEIVE_ALL_TYPE_DATA��־����Ϊ�������ݣ��������־DT_IS_ARY��
    //     ��Ҳ��DT_IS_ARY��־��Ψһʹ�ó��ϡ�
    //     DT_IS_ARY �Ķ���Ϊ��const DT_IS_ARY = $20000000;
    //  2�����������ݲ�������ʱ�����Ϊ�հ����ݣ���Ϊ_SDT_NULL��
    //
    ////////////////////////////////////////////////////////////////////////////
  end;
  // !!! ASSERT(sizeof(MDATA_INF)==sizeof(DWORD)*3); �ṹMDATA_INF�ĳߴ�������12�ֽڡ�

  ArgArray = array of MDATA_INF;  // ͨ������ȫ�������ʵ�ִ�����, ������ȡ����ֵ��
  //�硰ArgArray(pArgInf)[0].m_Value.m_int���ɷ��ʵ�һ�������е�integerֵ��


  //////////////////////////////////////////////////////////////////////////////
  // ֪ͨ�����ݽṹ��

  // ֧�ֿ����֪ͨ�ױ༭����(IDE)�������л���(RUNTIME)����ֵ��

  PMDATA = ^MDATA;
  MDATA  = record
    m_pData     : PByte;
    m_nDataSize : Integer;
  end;
  //���ڳ�ʼ��MDATA�ṹ��������C++�Ľṹ�п��Դ����캯������Pascal��record�����ԡ���ͬ����
  procedure Init_MDATA(var m: MDATA; pData: PByte; nDataSize: Integer);

type
  // ��¼�¼�����Դ
  pEVENT_NOTIFY = ^EVENT_NOTIFY;
  EVENT_NOTIFY  = record
    m_dwFormID    : LongWord;  // ����ITF_CREATE_UNIT�ӿ������ݹ�������������ID��dwWinFormID������
    m_dwUnitID    : Longword;  // ����ITF_CREATE_UNIT�ӿ������ݹ����Ĵ��ڵ�ԪID��dwUnitID������
    m_nEventIndex : Integer;   // �¼��������ڴ��ڵ�Ԫ������ϢLIB_DATA_TYPE_INFO��m_pPropertyBegin��Ա�е�λ�ã�
    m_nArgCount   : Integer;   // ���¼������ݵĲ�����Ŀ����� 5 ����
    m_nArgValue   : array[0..4] of Integer; // ��¼������ֵ��SDT_BOOL�Ͳ���ֵΪ 1 �� 0��

    //!!! ע������������Ա��û�ж��巵��ֵ���¼�����Ч����ֵ����Ϊ����ֵ��
    m_blHasReturnValue : EBool; // �û��¼������ӳ���������¼����Ƿ��ṩ�˷���ֵ��
    m_nReturnValue     : Integer;  // �û��¼������ӳ���������¼���ķ���ֵ���߼�ֵ����ֵ 0���٣� �� 1���棩 ���ء�
  end;
  //���ڳ�ʼ��EVENT_NOTIFY�ṹ������
  procedure Init_EVENT_NOTIFY(var e: EVENT_NOTIFY;dwFormID, dwUnitID: LongWord; nEventIndex: Integer);

type
  //�¼��Ĳ���ֵ
  pEVENT_ARG_VALUE = ^EVENT_ARG_VALUE;
  EVENT_ARG_VALUE  = record
    m_inf     : MDATA_INF;  // ���ڱ�ʶm_inf���Ƿ�Ϊָ�����ݡ�
    m_dwState : LongWord;   // !!! ע����� m_inf.m_dtDataType Ϊ�ı��͡��ֽڼ��͡��ⶨ���������ͣ��������ڵ�Ԫ���˵��������ͣ������봫��ָ�룬������Ǳ�����λ��
    ////////////////////////////////////////////////////////////////////////////
    // ���У�m_dwState ����ȡ���³���ֵ��ϣ�
    //   EAV_IS_POINTER = (1 shl 0)  // ��ʾEVENT_ARG_VALUE.m_inf��Ϊָ������
    //   EAV_IS_WINUNIT = (1 shl 1)  // ����˵��m_inf.m_dtDataType���������Ƿ�Ϊ���ڵ�Ԫ��!!!ע�����m_inf.m_dtDataTypeΪ���ڵ�Ԫ���˱�Ǳ�����λ��
    ////////////////////////////////////////////////////////////////////////////
  end;
const
  //���³�������EVENT_ARG_VALUE�ṹ�е�m_dwState��Ա
  EAV_IS_POINTER = (1 shl 0);  // ��ʾEVENT_ARG_VALUE.m_inf��Ϊָ������
  EAV_IS_WINUNIT = (1 shl 1);  // ����˵��m_inf.m_dtDataType���������Ƿ�Ϊ���ڵ�Ԫ��!!!ע�����m_inf.m_dtDataTypeΪ���ڵ�Ԫ���˱�Ǳ�����λ��

type
  // ��¼�¼�����Դ���°棩
  pEVENT_NOTIFY2 = ^EVENT_NOTIFY;
  EVENT_NOTIFY2  = record
    m_dwFormID    : LongWord;  // ����ITF_CREATE_UNIT�ӿ������ݹ�������������ID��dwWinFormID������
    m_dwUnitID    : Longword;  // ����ITF_CREATE_UNIT�ӿ������ݹ����Ĵ��ڵ�ԪID��dwUnitID������
    m_nEventIndex : Integer;   // �¼��������ڴ��ڵ�Ԫ������ϢLIB_DATA_TYPE_INFO��m_pPropertyBegin��Ա�е�λ�ã�
    m_nArgCount   : Integer;   // ���¼������ݵĲ�����Ŀ����� 12 ����
    m_nArgValue   : array[0..11] of EVENT_ARG_VALUE; // ��¼������ֵ

    //!!! ע������������Ա��û�ж��巵��ֵ���¼�����Ч����ֵ����Ϊ����ֵ��
    m_blHasReturnValue : EBool;  // �û��¼������ӳ���������¼����Ƿ��ṩ�˷���ֵ��
    m_infRetData       : MDATA_INF; // �û��¼������ӳ���������¼���ķ���ֵ
  end;
  //���ڳ�ʼ��EVENT_NOTIFY2�ṹ������
  procedure Init_EVENT_NOTIFY2(var e: EVENT_NOTIFY2;dwFormID, dwUnitID: LongWord; nEventIndex: Integer);

type
  //����ͼ��
  pAPP_ICON = ^APP_ICON;
  APP_ICON  = record
    m_hBigIcon   : LongWord;  // ��ͼ����
    m_hSmallIcon : LongWord;  // Сͼ����
  end;

const
  //////////////////////////////////////////////////////////////////////////////
  // ��Ϣ�������� (��Ϣ��)
  //
  // ע�⣺��ϵͳ������Ϣ��ʹ�ñ���Ԫ�ж����NotifySys����
  // function NotifySys (nMsg: Integer; dwParam1,dwParam2: Longword): Integer;

  // NES_ ��ͷ�ĳ���Ϊ�����ױ༭����(IDE)�����֪ͨ(��Ϣ��)��[NES: Notify Edit System]
  NES_GET_MAIN_HWND = 1;  // ȡ�ױ༭���������ڵľ����������֧�ֿ��AddIn������ʹ�á�
  NES_RUN_FUNC = 2;       // ֪ͨ�ױ༭��������ָ���Ĺ��ܣ�����һ��BOOLֵ��dwParam1Ϊ���ܺţ�dwParam2Ϊһ��˫DWORD����ָ��,�ֱ��ṩ���ܲ���1��2��

  // NAS_ ��ͷ�ĳ���Ϊ�ȱ��ױ༭�����ֱ������л��������֪ͨ(��Ϣ��)��[NAS: Notify All System]
  NAS_GET_APP_ICON           = 1000;  // ֪ͨϵͳ���������س����ͼ�ꡣdwParam1ΪpAPP_ICONָ�롣
  NAS_GET_LIB_DATA_TYPE_INFO = 1002;  // ����ָ���ⶨ���������͵�pLIB_DATA_TYPE_INFO������Ϣָ�롣dwParam1Ϊ����ȡ��Ϣ����������DATA_TYPE�����������������Ч���߲�Ϊ�ⶨ���������ͣ��򷵻�nil�����򷵻�pLIB_DATA_TYPE_INFOָ�롣
  NAS_GET_HBITMAP            = 1003;  // ����HBITMAP�����dwParam1ΪͼƬ����ָ�룬dwParam2ΪͼƬ���ݳߴ硣����ɹ����ط�NULL��HBITMAP�����ע��ʹ����Ϻ��ͷţ������򷵻�NULL��
  NAS_GET_LANG_ID            = 1004;  // ���ص�ǰϵͳ�����л�����֧�ֵ�����ID
  NAS_GET_VER                = 1005;  // ���ص�ǰϵͳ�����л����İ汾�ţ�LOWORDΪ���汾�ţ�HIWORDΪ�ΰ汾�š�
  NAS_GET_PATH               = 1006;  // ���ص�ǰ���������л�����ĳһ��Ŀ¼���ļ�����Ŀ¼���ԡ�\��������
    (* NAS_GET_PATH���ò�����
       dwParam1: ָ������Ҫ��Ŀ¼������Ϊ����ֵ��
         A�����������л����¾���Ч��Ŀ¼:
            1: ���������л���ϵͳ������Ŀ¼��
         B��������������Ч��Ŀ¼(��������������Ч):
            1001: ϵͳ���̺�֧�ֿ���������Ŀ¼��
            1002: ϵͳ��������Ŀ¼
            1003: ϵͳ������Ϣ����Ŀ¼
            1004: �������еǼǵ�ϵͳ����ģ���Ŀ¼
            1005: ֧�ֿ����ڵ�Ŀ¼
            1006: ��װ��������Ŀ¼
         C�����л�������Ч��Ŀ¼(�����л�������Ч):
            2001: �û�EXE�ļ�����Ŀ¼��
            2002: �û�EXE�ļ�����
       dwParam2: ���ջ�������ַ���ߴ����ΪMAX_PATH��
    *)

  NAS_CREATE_CWND_OBJECT_FROM_HWND   = 1007; // ͨ��ָ��HWND�������һ��CWND���󣬷�����ָ�룬��ס��ָ�����ͨ������NRS_DELETE_CWND_OBJECT���ͷš�dwParam1ΪHWND������ɹ�����CWnd*ָ�룬ʧ�ܷ���NULL
  NAS_DELETE_CWND_OBJECT             = 1008; // ɾ��ͨ��NRS_CREATE_CWND_OBJECT_FROM_HWND������CWND����dwParam1Ϊ��ɾ����CWnd����ָ��
  NAS_DETACH_CWND_OBJECT             = 1009; // ȡ��ͨ��NRS_CREATE_CWND_OBJECT_FROM_HWND������CWND����������HWND�İ󶨡�dwParam1ΪCWnd����ָ�롣�ɹ�����HWND,ʧ�ܷ���0
  NAS_GET_HWND_OF_CWND_OBJECT        = 1010; // ��ȡͨ��NRS_CREATE_CWND_OBJECT_FROM_HWND������CWND�����е�HWND��dwParam1ΪCWnd����ָ�롣�ɹ�����HWND,ʧ�ܷ���0
  NAS_ATTACH_CWND_OBJECT             = 1011; // ��ָ��HWND��ͨ��NRS_CREATE_CWND_OBJECT_FROM_HWND������CWND�����������dwParam1ΪHWND��dwParam2ΪCWnd����ָ�롣�ɹ�����1,ʧ�ܷ���0
  NAS_IS_EWIN                        = 1014; // ���ָ������Ϊ�����Դ��ڻ�����������������棬���򷵻ؼ١� dwParam1Ϊ�����Ե�HWND.
  
  // NRS_ ��ͷ�ĳ���Ϊ���ܱ������л��������֪ͨ(��Ϣ��)��[NRS: Notify Runtime System]
  NRS_UNIT_DESTROIED     = 2000; // ֪ͨϵͳָ���ĵ�Ԫ�Ѿ������١�dwParam1ΪdwFormID��dwParam2ΪdwUnitID��
  NRS_CONVERT_NUM_TO_INT = 2001; // ת��������ֵ��ʽ��������dwParam1ΪpMDATA_INFָ�룬��m_dtDataType����Ϊ��ֵ�͡�����ת���������ֵ��
  NRS_GET_CMD_LINE_STR   = 2002; // ȡ��ǰ�������ı��������������ı�ָ�룬�п���Ϊ�մ���
  NRS_GET_EXE_PATH_STR   = 2003; // ȡ��ǰִ���ļ�����Ŀ¼���ƣ����ص�ǰִ���ļ�����Ŀ¼�ı�ָ�롣
  NRS_GET_EXE_NAME       = 2004; // ȡ��ǰִ���ļ����ƣ����ص�ǰִ���ļ������ı�ָ�롣
  NRS_GET_UNIT_PTR       = 2006; // ȡ��Ԫ����ָ�롣dwParam1ΪWinForm��ID��dwParam2ΪWinUnit��ID���ɹ�������Ч�ĵ�Ԫ����CWnd*ָ�룬ʧ�ܷ���nil��
  NRS_GET_AND_CHECK_UNIT_PTR        = 2007; // ȡ��Ԫ����ָ�룬������ָ�롣dwParam1ΪWinForm��ID��dwParam2ΪWinUnit��ID���ɹ�������Ч�ĵ�Ԫ����CWnd*ָ�룬ʧ���Զ���������ʱ���������˳�����
  NRS_EVENT_NOTIFY                  = 2008; // ֪ͨϵͳ�������¼���dwParam1ΪPEVENT_NOTIFYָ�롣�������0����ʾ���¼��ѱ�ϵͳ�����������ʾϵͳ�Ѿ��ɹ����ݴ��¼����û��¼������ӳ���
  //NRS_STOP_PROCESS_EVENT_NOTIFY     = 2009; // ֪ͨϵͳ��ͣ�����¼�֪ͨ��
  //NRS_CONTINUE_PROCESS_EVENT_NOTIFY = 2010; // ֪ͨϵͳ���������¼�֪ͨ��
  NRS_DO_EVENTS          = 2018; // ֪ͨWindowsϵͳ�������������¼���
  NRS_GET_UNIT_DATA_TYPE = 2022; // ȡ��Ԫ�������͡�dwParam1ΪWinForm��ID��dwParam2ΪWinUnit��ID���ɹ�������Ч��DATA_TYPE��ʧ�ܷ���0��
  NRS_FREE_ARY           = 2023; // �ͷ�ָ���������ݡ�dwParam1Ϊ�����ݵ�DATA_TYPE��ֻ��Ϊϵͳ�����������ͣ�dwParam2Ϊָ����������ݵ�ָ�롣
  NRS_MALLOC             = 2024; // ����ָ���ռ���ڴ棬�������׳��򽻻����ڴ涼����ʹ�ñ�֪ͨ���䡣dwParam1Ϊ�������ڴ��ֽ�����dwParam2��Ϊ0�����������ʧ�ܾ��Զ���������ʱ���˳������粻Ϊ0�����������ʧ�ܾͷ���nil�������������ڴ���׵�ַ��
  NRS_MFREE              = 2025; // �ͷ��ѷ����ָ���ڴ档dwParam1Ϊ���ͷ��ڴ���׵�ַ��
  NRS_MREALLOC           = 2026; // ���·����ڴ档dwParam1Ϊ�����·����ڴ�ߴ���׵�ַ��dwParam2Ϊ�����·�����ڴ��ֽ��������������·����ڴ���׵�ַ��ʧ���Զ���������ʱ���˳�����
  NRS_RUNTIME_ERR        = 2027; // ֪ͨϵͳ�Ѿ���������ʱ����dwParam1Ϊchar*ָ�룬˵�������ı���
  NRS_EXIT_PROGRAM       = 2028; // ֪ͨϵͳ�˳��û�����dwParam1Ϊ�˳����룬�ô��뽫�����ص�����ϵͳ��
  //
  NRS_GET_PRG_TYPE       = 2030; // ���ص�ǰ�û���������ͣ�Ϊ2�����԰棩��3�������棩��
  NRS_EVENT_NOTIFY2      = 2031; // �Եڶ��෽ʽ֪ͨϵͳ�������¼���dwParam1ΪPEVENT_NOTIFY2ָ�롣������� 0 ����ʾ���¼��ѱ�ϵͳ�����������ʾϵͳ�Ѿ��ɹ����ݴ��¼����û��¼������ӳ���
  NRS_GET_WINFORM_COUNT  = 2032; // ���ص�ǰ����Ĵ�����Ŀ��
  NRS_GET_WINFORM_HWND   = 2033; // ����ָ������Ĵ��ھ��������ô�����δ�����룬����NULL��dwParam1Ϊ����������
  NRS_GET_BITMAP_DATA    = 2034; // ����ָ��HBITMAP��ͼƬ���ݣ��ɹ����ذ���BMPͼƬ���ݵ�HGLOBAL�����ʧ�ܷ���NULL��dwParam1Ϊ����ȡ��ͼƬ���ݵ�HBITMAP��
  NRS_FREE_COMOBJECT     = 2035; // ֪ͨϵͳ�ͷ�ָ����DTP_COM_OBJECT����COM����dwParam1Ϊ��COM����ĵ�ַָ�롣

  //////////////////////////////////////////////////////////////////////////////
  // �ױ༭����(IDE)�������л���(RUNTIME)����֪֧ͨ�ֿ����ֵ(��Ϣ��)��

  NL_SYS_NOTIFY_FUNCTION = 1;    // ��֪֧�ֿ�֪ͨϵͳ�õĺ���ָ�룬��װ��֧�ֿ�ǰ֪ͨ�������ж�Σ�����֪ͨ��ֵӦ�ø���ǰ����֪ͨ��ֵ�������Է���ֵ����ɽ��˺���ָ�루dwParam1: PFN_NOTIFY_SYS����¼�����Ա�����Ҫʱʹ����֪ͨ��Ϣ��ϵͳ��
  NL_FREE_LIB_DATA       = 6;  // ֪֧ͨ�ֿ��ͷ���Դ׼���˳����ͷ�ָ���ĸ������ݡ�
  //////////////////////////////////////////////////////////////////////////////

const
  NR_OK  =  0;
  NR_ERR = -1;
type
  // �˺��������ױ༭����(IDE)�������л���(RUNTIME)֪֧ͨ�ֿ��й��¼���
  PFN_NOTIFY_LIB = function(nMsg:Integer; dwParam1:LongWord=0; dwParam2:LongWord=0) :Integer; stdcall; // ����dwParam1,dwParam2�����ʹ������0

  // �˺�������֧�ֿ�֪ͨ�ױ༭����(IDE)�������л���(RUNTIME)�й��¼���
  PFN_NOTIFY_SYS = function(nMsg:Integer; dwParam1:LongWord=0; dwParam2:LongWord=0) :Integer; stdcall; // ����dwParam1,dwParam2�����ʹ������0

  //////////////////////////////////////////////////////////////////////////////
  // ��������ͷ���ʵ�ֺ�����ԭ�� PFN_EXECUTE_CMD
  //
  // ˵�����£�
  //   1��������CDECL���÷�ʽ��
  //   2��pRetData�����������ݣ�
  //   3��!!!���ָ����������������Ͳ�Ϊ_SDT_ALL������
  //      ����� pRetData->m_dtDataType�����Ϊ_SDT_ALL���������д��
  //   4��pArgInf�ṩ�������ݱ�����ָ���MDATA_INF��¼ÿ�������������Ŀ��ͬ��nArgCount��
  //////////////////////////////////////////////////////////////////////////////
  PFN_EXECUTE_CMD    = procedure(pRetData:pMDATA_INF; nArgCount:Integer; pArgInf:pMDATA_INF); cdecl;
  PPFN_EXECUTE_CMD = ^PFN_EXECUTE_CMD;

  // ����֧�ֿ���ADDIN���ܵĺ���
  PFN_RUN_ADDIN_FN   = function(nAddInFnIndex:Integer) :Integer; stdcall;

  // ���������ṩ�ĳ���ģ�����ĺ���
  PFN_SUPER_TEMPLATE = function(nTemplateIndex:Integer) :Integer; stdcall;

////////////////////////////////////////////////////
const
  LIB_FORMAT_VER = 20000101; // ���ʽ�š���LIB_INFO�ṹ��ʹ�á�


type
  (*                    ***************                                       *)
  (**********************   LIB_INFO  *****************************************)
  (*                    ***************                                       *)
  //////////////////////////////////////////////////////////////////////////////
  // ��֧�ֿ���Ϣ�����ݽṹ LIB_INFO

  pLIB_INFO = ^LIB_INFO;
  LIB_INFO  = record
    m_dwLibFormatVer         : LongWord;   // ���ʽ�ţ�Ӧ�õ���LIB_FORMAT_VER
    m_szGuid                 : PChar;      // ��Ӧ�ڱ����ΨһGUID��������ΪNULL��գ���ͬ������к����汾�˴���Ӧ��ͬ��ע�⣬��GUID�ִ�����ʹ��ר�ù����������(��Delphi�ڣ�����ͨ����ϼ�[Ctrl+Shift+G]����һ��GUID�ִ�)���Է�ֹ�����ظ���

    m_nMajorVersion          : Integer;    // ��������汾�ţ��������0
    m_nMinorVersion          : Integer;    // ����Ĵΰ汾��
    m_nBuildNumber           : Integer;    // �����汾�š����汾�Ž�����������ͬ��ʽ�汾�ŵ�ϵͳ�����Ʃ������޸��˼��� BUG����ֵ��������ʽ�汾��ϵͳ��������κι��������û�ʹ�õİ汾�乹���汾�Ŷ�Ӧ�ò�һ������ֵʱӦ��˳�������

    m_nRqSysMajorVer         : Integer;    // ����Ҫ������ϵͳ�����汾�ţ�ĿǰӦ��Ϊ 3
    m_nRqSysMinorVer         : Integer;    // ����Ҫ������ϵͳ�Ĵΰ汾�ţ�ĿǰӦ��Ϊ 0
    m_nRqSysKrnlLibMajorVer  : Integer;    // ����Ҫ��ϵͳ����֧�ֿ�����汾�ţ�ĿǰӦ��Ϊ 3
    m_nRqSysKrnlLibMinorVer  : Integer;    // ����Ҫ��ϵͳ����֧�ֿ�Ĵΰ汾�ţ�ĿǰӦ��Ϊ 0

    m_szName                 : PChar;      // ����������Ϊnil���
    m_nLanguage              : Integer;    // ������֧�ֵ����ԣ�ĿǰӦ��Ϊ LT_CHINESE (=1)���������˵���ͳ������塣
    m_szExplain              : PChar;      // �йر������ϸ����
    m_dwState                : LongWord;   // ֧�ֿ�״̬�������µ�˵�����������ͺ�������

    m_szAuthor               : PChar;      // ��������
    m_szZipCode              : PChar;      // �ʱ�
    m_szAddress              : PChar;      // ��ַ
    m_szPhoto                : PChar;      // �绰
    m_szFax                  : PChar;      // ����
    m_szEmail                : PChar;      // �����ʼ�
    m_szHomePage             : PChar;      // ��վ��ҳ
    m_szOther                : PChar;      // ����������Ϣ

    m_nDataTypeCount         : Integer;             // �������Զ����������͵���Ŀ���������m_pDataType��ָ�������Ա����Ŀ
    m_pDataType              : pLIB_DATA_TYPE_INFO; // �����������Զ����������͵Ķ�����Ϣ
    m_nCategoryCount         : Integer;             // ȫ�����������Ŀ�������ͬ������m_szzCategory��Ա��ʵ���ṩ����Ŀ
    m_szzCategory            : PChar;               // ȫ���������˵����ÿ��Ϊһ�ַ�����ǰ��λ���ֱ�ʾͼ�������ţ���1��ʼ��0��ʾ�ޣ�����һ���ֵΪָ��֧�ֿ�����Ϊ"LIB_BITMAP"��BITMAP��Դ��ĳһ����16X13λͼ��������
    m_nCmdCount              : Integer;             // �������ṩ����������(ȫ��������󷽷�)����Ŀ(������Ϊ0)
    m_pBeginCmdInfo          : pCMD_INFO;           // ָ��������������Ķ�����Ϣ����(��m_nCmdCountΪ0,��Ϊnil)
    m_pCmdsFunc              : PPFN_EXECUTE_CMD;    // ָ��ÿ�������ʵ�ִ����׵�ַ��(��m_nCmdCountΪ0,��Ϊnil)
    m_pfnRunAddInFn          : PFN_RUN_ADDIN_FN;    // ����Ϊ������IDE�ṩ���ӹ��ܣ���Ϊnil
    m_szzAddInFnInfo         : PChar;               // �й�AddIn���ܵ�˵���������ַ���˵��һ�����ܡ���һ��Ϊ�������ƣ���20�ַ������ڶ���Ϊ������ϸ���ܣ���60�ַ���������������մ�������
    m_pfnNotify              : PFN_NOTIFY_LIB;      // �ṩ��������������IDE�����л���֪ͨ��Ϣ�ĺ���������Ϊnil

    m_pfnSuperTemplate       : PFN_SUPER_TEMPLATE;  // ����ģ�壬��ʱ�������ã�Ϊnil
    m_szzSuperTemplateInfo   : PChar;               // Ϊnil

    m_nLibConstCount         : Integer;             // ������Ŀ
    m_pLibConst              : pLIB_CONST_INFO;     // ָ������������
    m_szzDependFiles         : PChar;               // ����������������Ҫ�����������ļ�����������װ���ʱ�����Զ�������Щ�ļ�����Ϊnil��

    ////////////////////////////////////////////////////////////////////////////
    // ���У�m_nLanguage ��ȡ����ֵ֮һ��
    //   __GBK_LANG_VER     =  1;  // GBK  ��������
    //   __ENGLISH_LANG_VER =  2;  // ENGLISH  Ӣ��
    //   __BIG5_LANG_VER    =  3;  // BIG5 ��������
    //
    // ���У�m_dwState ��ȡ����ֵ����ϣ�
    //   LBS_FUNC_NO_RUN_CODE = (1 shl 2);  // �����Ϊ�����⣬û�ж�Ӧ���ܵ�֧�ִ��룬��˲������С�
    //   LBS_NO_EDIT_INFO     = (1 shl 3);  // �������޹��༭�õ���Ϣ���༭��Ϣ��ҪΪ���������ơ������ַ����ȣ����޷���������IDE���أ������ṩ���׳��������֧�֡�
    //   LBS_IS_DB_LIB        = (1 shl 5);  // ����Ϊ���ݿ����֧�ֿ⡣
    //   _LIB_OS(os)   // ����������֧�ֵĲ���ϵͳ��_LIB_OS()��һ������������ת��os�����Ա���뵽m_dwState��
    ////////////////////////////////////////////////////////////////////////////
  end;

  function _LIB_OS(os: LongWord): LongWord; // ����ת��os�����Ա���뵽m_dwState
  function _TEST_LIB_OS(m_dwState,os: LongWord): boolean; //��������֧�ֿ��Ƿ����ָ������ϵͳ�İ汾

const
  //////////////////////////////////////////////////////////////////////////////
  // ���³����� LIB_INFO �ṹ��m_dwState��m_nLanguage��Ա��ʹ��

  // ֧�ֿ�����
  __GBK_LANG_VER      = 1;  // GBK  ��������
  __ENGLISH_LANG_VER  = 2;  // ENGLISH  Ӣ��
  __BIG5_LANG_VER     = 3;  // BIG5 ��������

  // ֧�ֿ�״ֵ̬(m_dwState)
  LBS_FUNC_NO_RUN_CODE = (1 shl 2);  // �����Ϊ�����⣬û�ж�Ӧ���ܵ�֧�ִ��룬��˲������С�
  LBS_NO_EDIT_INFO     = (1 shl 3);  // �������޹��༭�õ���Ϣ���༭��Ϣ��ҪΪ���������ơ������ַ����ȣ����޷���������IDE���أ������ṩ���׳��������֧�֡�
  LBS_IS_DB_LIB        = (1 shl 5);  // ����Ϊ���ݿ����֧�ֿ⡣
  //_LIB_OS(os)   // ����������֧�ֵĲ���ϵͳ��_LIB_OS()��һ������������ת��os�����Ա���뵽m_dwState��

  ////////////////////////////////////////////////////////////////////////////////


type

  PFN_GET_LIB_INFO = function() : pLIB_INFO; stdcall; // GetNewInf�ĺ���ԭ��
  PFN_ADD_IN_FUNC  = function() : Integer; cdecl;     // m_pfnRunAddInFn�ĺ���ԭ��


const
  ////////////////////////////////////////////////////////////////////////////////
  FUNCNAME_GET_LIB_INFO = 'GetNewInf';   // ȡ��֧�ֿ��PLIB_INFOָ��������������

  LIB_BMP_RESOURCE = 'LIB_BITMAP';  // ֧�ֿ����ṩ��ͼ����Դ������
  LIB_BMP_CX       = 16;            // ÿһͼ����Դ�Ŀ��
  LIB_BMP_CY       = 13;            // ÿһͼ����Դ�ĸ߶�
  LIB_BMP_BKCOLOR  = $FFFFFF;       // ͼ����Դ�ĵ�ɫ(��ɫ): RGB(255, 255, 255)=$FFFFFF=16777215


  
  { ����ʱʹ�� }  WM_APP = $8000;        // ������VC�е�WinUser.h���������������WINVER>=$0400����Windows95�����ϰ汾��
  WU_GET_WND_PTR         = (WM_APP + 2); // ����֧�ִ��ڵ�Ԫ�¼�������
  //WU_SIZE_CHANGED        = (WM_APP + 3); // �����ڴ��ڳߴ�ı��֪ͨ������״���ڵ�Ԫ��
  //WU_PARENT_RELAYOUT_BAR = (WM_APP + 4); // ����֪ͨ���㴰�����²������е� bar ��Ԫ��ͨ���� bar ��Ԫ�ı�������ߴ��ʹ�á�

  WU_INIT  = (WM_APP + 111); //���ڴ�����Ϻ��������ÿһ��������������ڷ��ʹ���Ϣ

  //���ڴ�����Ϻ�,����Ϣ�����͸�������������������Ҫ�������������ϵĳ�ʼ������.
  //����Ϣ��WU_INIT������Ϊ���ڱ���Ϣ������������д�����windows��Ϣ����õ�����
  //����WU_INIT������������д�����windows��Ϣ���ᱻ���Ρ�
  WU_INIT2  = (WM_APP + 118);

const
  //////////////////////////////////////////////////////////////////////////////
  // ���³����ں���GetDataTypeType���õ�����Ϊ����ֵ����
  DTT_IS_NULL_DATA_TYPE  = 0;
  DTT_IS_SYS_DATA_TYPE   = 1;
  DTT_IS_USER_DATA_TYPE  = 2;
  DTT_IS_LIB_DATA_TYPE   = 3;


//////////////////////////////////////////////////////////////////////////////
// ���³���Ϊϵͳ���Ŀ��е�������壬�������û�֧�ֿ������ú��Ŀ��е���������
//
const
  DTC_WIN_FORM     = 1;
  //û��2
  DTC_MENU         = 3;
  DTC_FONT         = 4;
  DTC_EDIT         = 5;
  DTC_PIC_BOX      = 6;
  DTC_SHAPE_BOX    = 7;
  DTC_DRAW_PANEL   = 8;
  DTC_GROUP_BOX     = 9;
  DTC_LABEL        = 10;
  DTC_BUTTON       = 11;
  DTC_CHECK_BOX    = 12;
  DTC_RADIO_BOX    = 13;
  DTC_COMBO_BOX    = 14;
  DTC_LIST_BOX     = 15;
  DTC_CHKLIST_BOX  = 16;
  DTC_HSCROLL_BAR  = 17;
  DTC_VSCROLL_BAR  = 18;
  DTC_PROCESS_BAR  = 19;
  DTC_SLIDER_BAR   = 20;
  DTC_TAB               = 21;
  DTC_ANIMATE           = 22;
  DTC_DATE_TIME_PICKER  = 23;
  DTC_MONTH_CALENDAR    = 24;
  DTC_DRIVER_BOX        = 25;
  DTC_DIR_BOX           = 26;
  DTC_FILE_BOX          = 27;
  DTC_COLOR_PICKER      = 28;
  DTC_HYPER_LINKER      = 29;
  DTC_SPIN              = 30;
  DTC_COMMON_DLG        = 31;
  DTC_TIMER             = 32;
  DTC_PRINTER           = 33;
  DTC_FIELD_INF         = 34;
  DTC_HTML_VIEWER       = 35;
  DTC_UDP               = 36;
  DTC_SOCK_CLIENT       = 37;
  DTC_SOCK_SERVER       = 38;
  DTC_SERIAL_PORT       = 39;
  DTC_PRINT_INF         = 40;
  DTC_GRID              = 41;
  DTC_DATA_SOURCE       = 42;
  DTC_NPROVIDER         = 43;
  DTC_DBPROVIDER        = 44;
  DTC_RGN_BUTTON        = 45;
  DTC_ODBC_DB           = 46;
  DTC_ODBCPROVIDER      = 47;
  DTC_COM_OBJECT        = 48;
  DTC_VARIANT           = 49;
  //over
  
const               // MakeLong(XXX, 1);
  DTP_LABEL         = (DTC_LABEL        or (1 shl 16));
  DTP_WIN_FORM      = (DTC_WIN_FORM     or (1 shl 16));
  DTP_MENU          = (DTC_MENU         or (1 shl 16));
  DTP_FONT          = (DTC_FONT         or (1 shl 16));
  DTP_TAB           = (DTC_TAB          or (1 shl 16));
  DTP_DRAW_PANEL    = (DTC_DRAW_PANEL   or (1 shl 16));
  DTP_PIC_BOX       = (DTC_PIC_BOX      or (1 shl 16));
  DTP_FIELD_INF     = (DTC_FIELD_INF    or (1 shl 16));
  DTP_PRINT_INF     = (DTC_PRINT_INF    or (1 shl 16));
  DTP_ODBC_DB       = (DTC_ODBC_DB      or (1 shl 16));
  DTP_ODBCPROVIDER  = (DTC_ODBCPROVIDER or (1 shl 16));
  DTP_UDP           = (DTC_UDP          or (1 shl 16));
  DTP_SOCK_CLIENT   = (DTC_SOCK_CLIENT  or (1 shl 16));
  DTP_SOCK_SERVER   = (DTC_SOCK_SERVER  or (1 shl 16));
  DTP_SERIAL_PORT   = (DTC_SERIAL_PORT  or (1 shl 16));
  DTP_DATA_SOURCE   = (DTC_DATA_SOURCE  or (1 shl 16));
  DTP_PRINTER       = (DTC_PRINTER      or (1 shl 16));
  DTP_COM_OBJECT    = (DTC_COM_OBJECT   or (1 shl 16));
  DTP_VARIANT       = (DTC_VARIANT      or (1 shl 16));

////////////////////////////////////////////////////////////////////////////////


//==============================================================================
// ����ȫ�ֺ���
//==============================================================================
  
// ����������IDE��֪ͨ���Ի�ú���ָ��g_fnNotifySys(ȫ�ֱ���)���ɽ��������ĵ�ַ��ֵ��LIB_INFO�ṹ��m_pfnNotify��Ա��
function DefaultProcessNotifyLib (nMsg:Integer; dwParam1:LongWord=0; dwParam2:LongWord=0) :Integer; stdcall;

// ����IDEϵͳ������Ϣ (ʹ��ȫ�ֺ���ָ��g_fnNotifySys)
function NotifySys (nMsg: Integer; dwParam1: Longword = 0; dwParam2: Longword = 0): Integer;

// ����û�в����ͷ���ֵ���������¼�
procedure NotifySimpleEvent(dwFormID, dwUnitID: LongWord; nEventIndex: Integer);

// �ϳ�RGB��ɫֵ
//function RGB(r, g, b: Byte): LongWord;

// ʹ��ָ���ı����ݽ����׳�����ʹ�õ��ı����ݡ�
function CloneTextData (ps: PChar) : PChar; overload;

// ʹ��ָ���ı����ݽ����׳�����ʹ�õ��ı����ݡ�nTextLen����ָ���ı����ֵĳ��ȣ������������㣩�����Ϊ-1����ȡps��ȫ�����ȡ�
function CloneTextData (ps: PChar; nTextLen: Integer): PChar; overload;

// ʹ��ָ�����ݽ����׳�����ʹ�õ��ֽڼ����ݡ�
function CloneBinData (pData: PByte; nDataSize: Integer): PByte;

// ����IDE��������ʱ����
procedure GReportError (szErrText: PChar);

// ����IDE�����ڴ�
function MMalloc (nSize: Integer): Pointer;

// �ͷŴ���IDE���������ڴ�
procedure MFree (p: Pointer);

// ������������ݲ����׵�ַ����Ա��Ŀ��
function GetAryElementInf (pAryData: Pointer; var pnElementCount: Integer): PByte;

// ȡ���������͵����
function GetDataTypeType (dtDataType: DATA_TYPE): Integer;


//��ָ�����ݿ��ж�ȡ��index��������indexȡֵ��0��ʼ��
function GetIntByIndex(pData : Pointer; index : Integer) : Integer;

//�޸�ָ�����ݿ��е�index��������indexȡֵ��0��ʼ��
procedure SetIntByIndex(pData : Pointer; index : Integer; value : Integer);


////////////////////////////////////////////////////////////////////////////////
//
//
//
////////////////////////////////////////////////////////////////////////////////


function GetLibInfo(): pLIB_INFO;

type PFN_FREE_LIB_DATA = procedure(); //only used in delphi

procedure DefineLib(szName,szGuid,szExplain: PChar;
                    nMajorVersion,nMinorVersion,nBuildNumber,nLanguage: Integer;
                    dwState: LongWord;
                    szAuthor,szHomePage,szOther: PChar;
                    nCategoryCount: Integer; szzCategory: PChar;
                    pfnRunAddInFn: PFN_RUN_ADDIN_FN = nil; szzAddInFnInfo: PChar = nil;
                    pfnNotifyLib: PFN_NOTIFY_LIB = nil; //default to DefaultProcessNotifyLib
                    szzDependFiles: PChar = nil;
                    pfnFreeLibData: PFN_FREE_LIB_DATA = nil);

procedure DefineConst(szName,szEGName,szExplain: PChar;
                      shtType: SmallInt;
                      dbValue: Double = 0.0; szTextValue: PChar = nil);
procedure DefineIntConst(szName,szEGName,szExplain: PChar; value: Integer);
procedure DefineDoubleConst(szName,szEGName,szExplain: PChar; value: Double);
procedure DefineBoolConst(szName,szEGName,szExplain: PChar; value: EBool);
procedure DefineTextConst(szName,szEGName,szExplain: PChar; value: PChar);

function DefineCommand(cmdFunc: PFN_EXECUTE_CMD; args: array of ARG_INFO;
                       szName,szEGName,szExplain: PChar;
                       dtRetType: DATA_TYPE; wState: Word;
                       shtUserLevel: SmallInt = LVL_SIMPLE; shtCategory: SmallInt = 0;
                       shtBitmapIndex: SmallInt = 0; shtBitmapCount: SmallInt = 0;
                       version: DWORD = 0) : Integer;

function DefineCommand_NoArg(cmdFunc: PFN_EXECUTE_CMD;
                             szName,szEGName,szExplain: PChar;
                             dtRetType: DATA_TYPE; wState: Word;
                             shtUserLevel: SmallInt = LVL_SIMPLE; shtCategory: SmallInt = 0;
                             shtBitmapIndex: SmallInt = 0; shtBitmapCount: SmallInt = 0;
                             version: DWORD = 0) : Integer;

function DefineDatatype(szName,szEGName,szExplain: PChar; dwState: LongWord = 0) : Integer;

function DefineEnumDatatype(szName,szEGName,szExplain: PChar; dwState: LongWord = 0) : Integer;

function DefineUIDatatype(szName,szEGName,szExplain: PChar;
                          dwState,dwUnitBmpID: LongWord;
                          pfnGetInterface: PFN_GET_INTERFACE = nil;
                          onCreateUnit: PFN_CREATE_UNIT = nil;
                          onGetPropertyValue: PFN_GET_PROPERTY_DATA = nil;
                          onSetPropertyValue: PFN_NOTIFY_PROPERTY_CHANGED = nil;
                          onGetAllPropertiesValue: PFN_GET_ALL_PROPERTY_DATA = nil;
                          onPropertyUpdateUI: PFN_PROPERTY_UPDATE_UI = nil;
                          onInitDlgCustomData: PFN_DLG_INIT_CUSTOMIZE_DATA = nil;
                          onGetIconPropertyValue: PFN_GET_ICON_PROPERTY_DATA = nil;
                          onIsNeedThisKey: PFN_IS_NEED_THIS_KEY = nil;
                          onLanguageConv: PFN_LANG_CNV = nil;
                          onMsgFilter: PFN_MESSAGE_FILTER = nil;
                          onNotifyUnit: PFN_ON_NOTIFY_UNIT = nil ) : Integer;

function DefineMethod(datatypeIndex: Integer; {datatypeIndex must exist}
                      cmdFunc: PFN_EXECUTE_CMD; args: array of ARG_INFO;
                      szName,szEGName,szExplain: PChar;
                      dtRetType: DATA_TYPE; wState: Word;
                      shtUserLevel: SmallInt = LVL_SIMPLE; shtCategory: SmallInt = -1;
                      shtBitmapIndex: SmallInt = 0; shtBitmapCount: SmallInt = 0;
                      version: DWORD = 0) : Integer;

function DefineMethod_NoArg(datatypeIndex: Integer; {datatypeIndex must exist}
                            cmdFunc: PFN_EXECUTE_CMD;
                            szName,szEGName,szExplain: PChar;
                            dtRetType: DATA_TYPE; wState: Word;
                            shtUserLevel: SmallInt = LVL_SIMPLE; shtCategory: SmallInt = -1;
                            shtBitmapIndex: SmallInt = 0; shtBitmapCount: SmallInt = 0;
                            version: DWORD = 0) : Integer;

procedure DefineElement(datatypeIndex: Integer; {datatypeIndex must exist}
                        szName,szEGName,szExplain: PChar;
                        dtDataType: DATA_TYPE; pArySpec: PByte = nil;
                        dwState: LongWord = 0; nDefault: Integer = 0);

procedure DefineEnumElement(datatypeIndex: Integer; {datatypeIndex must exist}
                            szName,szEGName,szExplain: PChar;
                            nValue: Integer; dwState: LongWord = 0);

procedure DefineEvent(datatypeIndex: Integer; {datatypeIndex must exist}
                      szName,szExplain: PChar; dwState: LongWord;
                      args: array of EVENT_ARG_INFO2;
                      dtRetDataType: DATA_TYPE);

procedure DefineProperty(datatypeIndex: Integer; {datatypeIndex must exist}
                         szName,szEGName,szExplain: PChar;
                         shtType: SmallInt; wState: Word;
                         szzPickStr: PChar);


//procedure DefineHiddenConst(nRepeatCount: Integer = 1); //cann't hide consts
procedure DefineHiddenCommand(nRepeatCount: Integer = 1; version: DWORD = 0);
procedure DefineHiddenDatatype(nRepeatCount: Integer = 1);
procedure DefineHiddenElement(datatypeIndex: Integer; nRepeatCount: Integer = 1);
procedure DefineHiddenMethod(datatypeIndex: Integer; nRepeatCount: Integer = 1; version: DWORD = 0);
procedure DefineHiddenProperty(datatypeIndex: Integer; nRepeatCount: Integer = 1);
procedure DefineHiddenEvent(datatypeIndex: Integer; nRepeatCount: Integer = 1);


////////////////////////////////////////////////////////////////////////////////

implementation

type

  //δ�󶨵ķ���
  UnbindingMethod = record
    version: DWORD;
    datatypeIndex: Integer; //-1, if not a method
    cmdInfo: CMD_INFO;
    cmdFunc: PFN_EXECUTE_CMD;
    cmdArgs: array of ARG_INFO;
    bound: boolean;
  end;

  ADatatypeData = record
    methodCount: Integer;
    methodIndexes: array of Integer;

    eventCount: Integer;
    eventInfos: array of EVENT_INFO2; //their args refers to egdata.eventArgInfos

    propertyCount: Integer;
    propertyInfos: array of UNIT_PROPERTY;

    elementCount: Integer;
    elementInfos: array of LIB_DATA_TYPE_ELEMENT;

    interfaces: array[ITF_CREATE_UNIT{1} .. ITF_GET_NOTIFY_RECEIVER{12}] of PFN_INTERFACE;
    interfaceGetterCodes: array[0..31] of Byte; //see ECreateDatetypeInterfaceGetterFunction
  end;

  //���ڴ洢ȫ������
  ELibGlobalData = record

    //libinfo
    libInfo: LIB_INFO;

    //consts
    constCount, constInfoGrowLength: Integer;
    constInfos: array of LIB_CONST_INFO;

    //commands and it's args
    cmdCount, cmdInfoGrowLength: Integer;
    cmdInfos: array of CMD_INFO;
    cmdFuncs: array of PFN_EXECUTE_CMD;
    argCount, argInfoGrowLength: Integer;
    argInfos: array of ARG_INFO;

    //datatypes
    datatypeCount, datatypeInfoGrowLength: Integer;
    datatypeInfos: array of LIB_DATA_TYPE_INFO;
    datatypeDatas: array of ADatatypeData;
    eventArgCount, eventArgInfoGrowLength: Integer;
    eventArgInfos: array of EVENT_ARG_INFO2; //share all over the library

    //others
    fnNotifySys: PFN_NOTIFY_SYS;
    nLastNotifySysResult: Integer;
    fnFreeLibData: PFN_FREE_LIB_DATA;
    hasFixedLibInfo: boolean;

    unbindingMethodCount: Integer;
    unbindingMethods: array of UnbindingMethod;
  end;

var
  //���ڲ�ʹ��, ��羡����Ҫʹ��
  //���ڴ洢�ڲ����ݵ�Ψһȫ�ֱ��� (ʹ�þ������ٵ�ȫ�ֱ���)
  //���� egdata ȫ�ֱ�����ʹ��, ��ο� DefineLib(), DefineCommand(), DefineConst(), DefineDatatype(), ...
  egdata: ELibGlobalData; 


function DefaultProcessNotifyLib (nMsg:Integer; dwParam1:LongWord=0; dwParam2:LongWord=0) :Integer; stdcall;
  var ReturnValue: Integer;
begin
  ReturnValue := NR_OK;
  case nMsg of
    NL_SYS_NOTIFY_FUNCTION:
      egdata.fnNotifySys := PFN_NOTIFY_SYS(dwParam1);
    NL_FREE_LIB_DATA:
    begin
      if Assigned(egdata.fnFreeLibData) then
        egdata.fnFreeLibData(); //invoke user procedure
    end;
    else ReturnValue := NR_ERR;
  end;
  Result := ReturnValue;
end;

// ����IDEϵͳ������Ϣ��ʧ�ܷ���0��
function NotifySys (nMsg: Integer; dwParam1,dwParam2: Longword): Integer;
var
  EVT: PEVENT_NOTIFY2;
begin
  Result := 0;
  Assert(Assigned(egdata.fnNotifySys), 'fnNotifySys can not be nil');
  if nMsg = NRS_EVENT_NOTIFY2 then
  begin
    EVT := PEVENT_NOTIFY2(dwParam1);
    Assert(EVT <> nil, 'dwParam1 can''t be 0!');
    if not Assigned(EVT) then exit;
    //Assert((EVT.m_dwFormID <> 0) and (EVT.m_dwUnitID <> 0), 'Form id and unit id must not be 0!');
    if (EVT.m_dwFormID = 0) or (EVT.m_dwUnitID = 0) then exit;
  end;
  if Assigned(egdata.fnNotifySys) then
    Result := egdata.fnNotifySys(nMsg, dwParam1, dwParam2);

  egdata.nLastNotifySysResult := Result;
end;

//��ʼ��MDATA�ṹ����
procedure Init_MDATA(var m: MDATA; pData: PByte; nDataSize: Integer);
begin
  m.m_pData := nil;
  m.m_nDataSize := 0;
end;

//��ʼ��EVENT_NOTIFY�ṹ����
procedure Init_EVENT_NOTIFY(var e: EVENT_NOTIFY;dwFormID, dwUnitID: LongWord; nEventIndex: Integer);
begin
  with e do begin
    m_dwFormID         := dwFormID;
    m_dwUnitID         := dwUnitID;
    m_nEventIndex      := nEventIndex;
    m_nArgCount        := 0;
    m_blHasReturnValue := EFalse;
    m_nReturnValue := 0;
  end;
end;

//��ʼ��EVENT_NOTIFY2�ṹ����
procedure Init_EVENT_NOTIFY2(var e: EVENT_NOTIFY2; dwFormID, dwUnitID: LongWord; nEventIndex: Integer);
var
  I: Integer;
begin
  with e do begin
    m_dwFormID         := dwFormID;
    m_dwUnitID         := dwUnitID;
    m_nEventIndex      := nEventIndex;
    m_nArgCount        := 0;
    m_blHasReturnValue := EFalse;
    m_infRetData.m_dtDataType := _SDT_NULL;
    m_infRetData.m_Value.m_double := 0;
    for I := Low(m_nArgValue) to High(m_nArgValue) do
    with m_nArgValue[I] do
    begin
      m_dwState := 0;
      m_inf.m_dtDataType := _SDT_NULL;
      m_inf.m_Value.m_double := 0;
    end;
  end;
end;

//����û�в����ͷ���ֵ���������¼�
procedure NotifySimpleEvent(dwFormID, dwUnitID: LongWord; nEventIndex: Integer);
var
  event: EVENT_NOTIFY2;
begin
  Init_EVENT_NOTIFY2(event, dwFormID, dwUnitID, nEventIndex);
  NotifySys(NRS_EVENT_NOTIFY2, Cardinal(@event), 0);
end;

// ʹ��ָ���ı����ݽ����׳�����ʹ�õ��ı����ݡ�
function CloneTextData (ps: PChar) : PChar;
var
  nTextLen: Integer;
  pd: PChar;
begin
  Result := nil;
  if (ps = nil) or (ps[0] = #0) then exit;
  nTextLen := StrLen(ps);
  pd := PChar(MMalloc(nTextLen + 1));
  Assert(pd <> nil);
  SysUtils.StrLCopy(pd, ps, nTextLen + 1);
  Result := pd;
end;

// ʹ��ָ���ı����ݽ����׳�����ʹ�õ��ı����ݡ�nTextLen����ָ���ı����ֵĳ��ȣ������������㣩�����Ϊ-1����ȡps��ȫ�����ȡ�
function CloneTextData (ps: PChar; nTextLen: Integer): PChar;
var pd: PChar;
begin
  Result := nil;
  if nTextLen <= 0 then exit;
  pd := PChar(MMalloc(nTextLen + 1));
  Assert(pd <> nil);
  SysUtils.StrLCopy(pd, ps, nTextLen);
  pd[nTextLen] := #0;
  Result := pd;
end;

// ʹ��ָ�����ݽ����׳�����ʹ�õ��ֽڼ����ݡ�
function CloneBinData (pData: PByte; nDataSize: Integer): PByte;
var pd: PByte;
begin
  Result := nil;
  if nDataSize=0 then exit;
  pd:= PByte(MMalloc(sizeof(Integer) * 2 + nDataSize));
  Assert(pd <> nil);
  PInteger(pd)^ := 1;
  PInteger(Integer(pd)+sizeof(Integer))^ := nDataSize;
  CopyMemory(Pointer(Integer(pd)+sizeof(Integer)*2), PChar(pData), nDataSize);
  Result:= pd;
end;

// ����IDE��������ʱ����
procedure GReportError (szErrText: PChar);
begin
  NotifySys(NRS_RUNTIME_ERR,LongWord(szErrText), 0);
end;

// ����IDE�����ڴ�
function MMalloc (nSize: Integer): Pointer;
begin
  Result:= Pointer(NotifySys(NRS_MALLOC, LongWord(nSize), 0));
end;

// �ͷŴ���IDE���������ڴ�
procedure MFree (p: Pointer);
begin
  NotifySys(NRS_MFREE,LongWord(p), 0);
end;

// ������������ݲ����׵�ַ����Ա��Ŀ��
function GetAryElementInf (pAryData: Pointer; var pnElementCount: Integer): PByte;
var
  pnData : PInteger;
  nArys, nElementCount : Integer;
begin
  pnData:= PInteger(pAryData);
  nArys:= pnData^;  // ȡ��ά����
  Inc(pnData);
  nElementCount:= 1;  // �����Ա��Ŀ��
  while (nArys > 0) do begin
    nElementCount:= nElementCount * pnData^;
    Inc(pnData);
    Dec(nArys);
  end;
  pnElementCount:= nElementCount;
  Result:= PByte(pnData);
end;

// ȡ���������͵����
function GetDataTypeType (dtDataType: DATA_TYPE): Integer;
var dw: Longword;
begin
  if dtDataType= _SDT_NULL then begin
    Result:= DTT_IS_NULL_DATA_TYPE;
    exit;
  end;
  dw:= dtDataType and $C0000000;
  if dw=DTM_SYS_DATA_TYPE_MASK then
    Result:= DTT_IS_SYS_DATA_TYPE
  else if dw=DTM_USER_DATA_TYPE_MASK then
    Result:= DTT_IS_USER_DATA_TYPE
  else
    Result:=DTT_IS_LIB_DATA_TYPE;
end;

{  //CWnd��MFC�е�һ����
// ���Բ��᷵��NULL���ߴ��ھ����Ч��CWnd*ָ�롣
CWnd* GetWndPtr (PMDATA_INF pInf)
begin
    return (CWnd*)NotifySys (NRS_GET_AND_CHECK_UNIT_PTR,
            pInf [0].m_unit.m_dwFormID, pInf [0].m_unit.m_dwUnitID);
end;
}

//------------------------------------------------------------------------------
// ���º����Ƕԡ�����ϵͳ���͡��Ĳ��������е�os������Ϊ__OS_WIN,__OS_LINUX,__OS_UNIX����ϣ���OS_ALL��
// ���º�����Ӧ��C++��֧�ֿ⿪���ӿ��е�ͬ�����ꡱ��

// ����ת��os�����Ա���뵽CMD_INFO.m_wState
function _CMD_OS(os: LongWord): Word;
begin
  Result:= ((os) shr 16);
end;

// ��������ָ�������Ƿ�֧��ָ������ϵͳ
function _TEST_CMD_OS(m_wState: Word; os: LongWord): boolean;
begin
  Result:= ((_CMD_OS(os) and m_wState) <> 0);
end;

// ����ת��os�����Ա���뵽UNIT_PROPERTY.m_wState
function _PROP_OS(os: LongWord): Word;
begin
  Result:= ((os) shr 16);
end;

// ��������ָ�������Ƿ�֧��ָ������ϵͳ
function _TEST_PROP_OS(m_wState: Word; os: LongWord): boolean;
begin
  Result:= ((_PROP_OS(os) and m_wState) <> 0);
end;

// ����ת��os�����Ա���뵽EVENT_INFO.m_dwState��EVENT_INFO2.m_dwState
function _EVENT_OS(os: LongWord): LongWord;
begin
  Result:= ((os) shr 1);
end;

// ��������ָ���¼��Ƿ�֧��ָ������ϵͳ
function _TEST_EVENT_OS(m_dwState,os: LongWord): boolean;
begin
  Result:= ((_EVENT_OS (os) and m_dwState) <> 0)
end;

// ����ת��os�����Ա���뵽LIB_DATA_TYPE_INFO.m_dwState
function _DT_OS(os: LongWord): LongWord;
begin
  Result:= os;
end;

// ��������ָ�����������Ƿ�֧��ָ������ϵͳ
function _TEST_DT_OS(m_dwState,os: LongWord): boolean;
begin
  Result:= ((_DT_OS (os) and m_dwState) <> 0);
end;

// ����ת��os�����Ա���뵽m_dwState
function _LIB_OS(os: LongWord): LongWord;
begin
  Result:= os;
end;

//��������֧�ֿ��Ƿ����ָ������ϵͳ�İ汾
function _TEST_LIB_OS(m_dwState,os: LongWord): boolean;
begin
  Result:= ((_LIB_OS (os) and m_dwState) <> 0);
end;

//------------------------------------------------------------------------------


//��ָ�����ݿ��ж�ȡ��index��������indexȡֵ��0��ʼ��
function GetIntByIndex(pData : Pointer; index : Integer) : Integer;
begin
  result := PInteger(DWORD(pData) + DWORD(sizeof(Integer)*index))^;
end;

//�޸�ָ�����ݿ��е�index��������indexȡֵ��0��ʼ��
procedure SetIntByIndex(pData : Pointer; index : Integer; value : Integer);
begin
  PInteger(DWORD(pData) + DWORD(sizeof(Integer)*index))^ := value;
end;


////////////////////////////////////////////////////////////////////////////////
//
// �����������˴����Ĺ���, ���ڼ�������֧�ֿ⿪��
//
////////////////////////////////////////////////////////////////////////////////

// ���� procedure/function ��, û���� interface ��������, �����ڲ�ʹ��


procedure FillLibInfo(out libInfo: LIB_INFO;
                      szName,szGuid,szExplain: PChar;
                      nMajorVersion,nMinorVersion,nBuildNumber,nLanguage: Integer;
                      dwState: LongWord;
                      szAuthor,szHomePage,szOther: PChar;
                      nCategoryCount: Integer; szzCategory: PChar;
                      nCmdCount: Integer; pBeginCmdInfo: pCMD_INFO; pCmdsFunc: PPFN_EXECUTE_CMD;
                      nLibConstCount: Integer; pLibConst: pLIB_CONST_INFO;
                      nDataTypeCount: Integer; pDataType: pLIB_DATA_TYPE_INFO;
                      pfnRunAddInFn: PFN_RUN_ADDIN_FN; szzAddInFnInfo: PChar;
                      pfnNotify: PFN_NOTIFY_LIB;
                      szzDependFiles: PChar);
begin
  with libInfo do begin
    m_dwLibFormatVer := LIB_FORMAT_VER;
    m_szGuid := szGuid;
    m_nMajorVersion := nMajorVersion;
    m_nMinorVersion := nMinorVersion;
    m_nBuildNumber := nBuildNumber;
    m_nRqSysMajorVer := 4;
    m_nRqSysMinorVer := 0;
    m_nRqSysKrnlLibMajorVer := 4;
    m_nRqSysKrnlLibMinorVer := 5;
    m_szName := szName;
    m_nLanguage := nLanguage;
    m_szExplain := szExplain;
    m_dwState := dwState;

    m_szAuthor := szAuthor;
    m_szZipCode := nil;
    m_szAddress := nil;
    m_szPhoto := nil;
    m_szFax := nil;
    m_szEmail := nil;
    m_szHomePage := szHomePage;
    m_szOther := szOther;

    m_nDataTypeCount := nDataTypeCount;
    m_pDataType := pDataType;
    m_nCategoryCount := nCategoryCount;
    m_szzCategory := szzCategory;
    m_nCmdCount := nCmdCount;
    m_pBeginCmdInfo := pBeginCmdInfo;
    m_pCmdsFunc := pCmdsFunc;
    m_pfnRunAddInFn := pfnRunAddInFn;
    m_szzAddInFnInfo := szzAddInFnInfo;
    m_pfnNotify := pfnNotify;
    m_pfnSuperTemplate:=nil;
    m_szzSuperTemplateInfo:=nil;
    m_nLibConstCount := nLibConstCount;
    m_pLibConst := pLibConst;
    m_szzDependFiles:=nil;
  end;
end;

procedure FillCmdInfo(out cmdInfo: CMD_INFO;
                      szName,szEGName,szExplain: PChar;
                      dtRetType: DATA_TYPE; wState: Word;
                      shtUserLevel,shtCategory: SmallInt;
                      nArgCount: Integer; pBeginArgInfo: pARG_INFO;
                      shtBitmapIndex,shtBitmapCount: SmallInt);
begin
  with cmdInfo do begin
    m_szName := szName;
    m_szEGName := szEGName;
    m_szExplain := szExplain;
    m_shtCategory := shtCategory;
    m_wState := wState;
    m_dtRetType := dtRetType;
    m_wReserved := 0;
    m_shtUserLevel := shtUserLevel;
    m_shtBitmapIndex := shtBitmapIndex;
    m_shtBitmapCount := shtBitmapCount;
    m_nArgCount := nArgCount;
    m_pBeginArgInfo := pBeginArgInfo;
  end;
end;

procedure FillArgInfo(out argInfo: ARG_INFO;
                      szName,szExplain: PChar;
                      dtDataType: DATA_TYPE;
                      dwState,nDefault: LongWord;
                      shtBitmapIndex,shtBitmapCount: SmallInt);
begin
  with argInfo do begin
    m_szName := szName;
    m_szExplain := szExplain;
    m_shtBitmapIndex := shtBitmapIndex;
    m_shtBitmapCount := shtBitmapCount;
    m_dtDataType := dtDataType;
    m_nDefault := nDefault;
    m_dwState := dwState;
  end;
end;

procedure FillConstInfo(out constInfo: LIB_CONST_INFO;
                        szName,szEGName,szExplain: PChar;
                        shtType: SmallInt;
                        dbValue: Double; szTextValue: PChar);
begin
  with constInfo do begin
    m_szName := szName;
    m_szEGName := szEGName;
    m_szExplain := szExplain;
    m_shtReserved := 1;
    m_shtType := shtType;
    m_szText := szTextValue;
    m_dbValue := dbValue;
  end;
end;

procedure FillDatatypeInfo(out datatypeInfo: LIB_DATA_TYPE_INFO;
                           szName,szEGName,szExplain: PChar;
                           dwState,dwUnitBmpID: LongWord;
                           nCmdCount: Integer; pnCmdsIndex: PInteger;
                           nEventCount: Integer; pEventBegin: pEVENT_INFO;
                           nPropertyCount: Integer; pPropertyBegin: pUNIT_PROPERTY;
                           nElementCount: Integer; pElementBegin: pLIB_DATA_TYPE_ELEMENT;
                           pfnGetInterface: PFN_GET_INTERFACE);
begin
  with datatypeInfo do begin
    m_szName := szName;
    m_szEGName := szEGName;
    m_szExplain := szExplain;
    m_nCmdCount := nCmdCount;
    m_pnCmdsIndex := pnCmdsIndex;
    m_dwState := dwState;
    m_dwUnitBmpID := dwUnitBmpID;
    m_nEventCount := nEventCount;
    m_pEventBegin := pEventBegin;
    m_nPropertyCount := nPropertyCount;
    m_pPropertyBegin := pPropertyBegin;
    m_pfnGetInterface := pfnGetInterface;
    m_nElementCount := nElementCount;
    m_pElementBegin := pElementBegin;
  end;
end;

procedure FillEventInfo(out eventInfo: EVENT_INFO;
                        szName,szExplain: PChar;
                        dwState: LongWord;
                        nArgCount: Integer; pEventArgInfo: PEVENT_ARG_INFO);
begin
  with eventInfo do begin
    m_szName := szName;
    m_szExplain := szExplain;
    m_dwState := dwState;
    m_nArgCount := nArgCount;
    m_pEventArgInfo := pEventArgInfo;
  end;
end;

procedure FillEventArgInfo(out eventArgInfo: EVENT_ARG_INFO;
                           szName,szExplain: PChar;
                           dwState: LongWord);
begin
  with eventArgInfo do begin
    m_szName := szName;
    m_szExplain := szExplain;
    m_dwState := dwState;
  end;
end;

procedure FillEventInfo2(out eventInfo: EVENT_INFO2;
                         szName,szExplain: PChar;
                         dwState: LongWord;
                         nArgCount: Integer; pEventArgInfo: PEVENT_ARG_INFO2;
                         dtRetDataType: DATA_TYPE);
begin
  with eventInfo do begin
    m_szName := szName;
    m_szExplain := szExplain;
    m_dwState := (dwState or LongWord(EV_IS_VER2));
    m_nArgCount := nArgCount;
    m_pEventArgInfo := pEventArgInfo;
    m_dtRetDataType := dtRetDataType;
  end;
end;

procedure FillEventArgInfo2(out eventArgInfo: EVENT_ARG_INFO2;
                            szName,szExplain: PChar;
                            dwState: LongWord;
                            dtDataType: DATA_TYPE);
begin
  with eventArgInfo do begin
    m_szName := szName;
    m_szExplain := szExplain;
    m_dwState := dwState;
    m_dtDataType := dtDataType;
  end;
end;

procedure FillPropertyInfo(out propertyInfo: UNIT_PROPERTY;
                           szName,szEGName,szExplain: PChar;
                           shtType: SmallInt; wState: Word;
                           szzPickStr: PChar);
begin
  with propertyInfo do begin
    m_szName := szName;
    m_szEGName := szEGName;
    m_szExplain := szExplain;
    m_shtType := shtType;
    m_wState := wState;
    m_szzPickStr := szzPickStr;
  end;
end;

procedure FillElementInfo(out elementInfo: LIB_DATA_TYPE_ELEMENT;
                          szName,szEGName,szExplain: PChar;
                          dtDataType: DATA_TYPE; pArySpec: PByte;
                          dwState: LongWord; nDefault: Integer);
begin
  with elementInfo do begin
    m_dtDataType := dtDataType;
    m_pArySpec := pArySpec;
    m_szName := szName;
    m_szEGName := szEGName;
    m_szExplain := szExplain;
    m_dwState := dwState;
    m_nDefault := nDefault;
  end;
end;

//------------------------------------------------------------------------------

//if count > 0, returns the first element's memory address, or returns nil.
function GetMemAddressOfArray(const anArray; count: Integer) : Pointer;
begin
  if count > 0 then
    //'�������Ƽ����׳�Ա��ַ', �Ѿ���������֤, ���������ȷ֤ʵ. 
    result := Pointer(anArray) //@(anArray[0])
  else
    result := nil;
end;

//only used by FixLibInfo()
procedure FixDatatypeInfo();
var 
  i, j: Integer;
  pCallOp: PDWORD;
begin

  with egdata do begin
  
    libInfo.m_nDataTypeCount := datatypeCount;
    libInfo.m_pDataType := GetMemAddressOfArray(datatypeInfos, datatypeCount);
    if datatypeCount = 0 then 
      exit; //no datatype

    for i := 0 to libInfo.m_nDataTypeCount - 1 do begin
      with datatypeInfos[i], datatypeDatas[i] do begin
        //methods
        m_nCmdCount := methodCount;
        m_pnCmdsIndex := GetMemAddressOfArray(methodIndexes, methodCount);

        //properties
        m_nPropertyCount := propertyCount;
        m_pPropertyBegin := GetMemAddressOfArray(propertyInfos, propertyCount);

        //elements
        m_nElementCount := elementCount;
        m_pElementBegin := GetMemAddressOfArray(elementInfos, elementCount);

        //events
        m_nEventCount := eventCount;
        if eventCount = 0 then begin
          m_pEventBegin := nil;
        end else begin
          m_pEventBegin := @(eventInfos[0]);
          //see DefineEventInfo()
          for j := 0 to eventCount - 1 do begin
            if eventInfos[j].m_nArgCount < 0 then begin
              eventInfos[j].m_nArgCount := 0 - eventInfos[j].m_nArgCount;
              eventInfos[j].m_pEventArgInfo := pEVENT_ARG_INFO2(@(eventArgInfos[Integer(eventInfos[j].m_pEventArgInfo)]));
            end;
          end;
        end;
        //end events

        //m_pfnGetInterface
        //fix the CALL instruction's param of the auto-generated-function , see ECreateDatetypeInterfaceGetterFunction()
        if interfaceGetterCodes[0] <> 0 then begin
          pCallOp := @interfaceGetterCodes[10];
          pCallOp^ := pCallOp^ - DWORD(@interfaceGetterCodes[14]);
          m_pfnGetInterface := @interfaceGetterCodes;
        end;
        
      end; //end of with datatypeInfos[i], datatypeDatas[i]
    end; //end of for

  end; //end of with
end;

//only used by DefineMethod() DefineMethod_NoArg() and FixUnbindingMethods()
procedure BindCommandToDatatype(datatypeIndex, cmdIndex: Integer);
begin
  with egdata.datatypeDatas[datatypeIndex] do begin
    Inc(methodCount);
    SetLength(methodIndexes, methodCount); //todo: buffered
    methodIndexes[methodCount - 1] := cmdIndex;
  end;
end;

procedure FixUnbindingMethods();
var
  i: Integer;
  indexOfMinVersionMethod: Integer;
  cmdIndexOfMethod: Integer;
  minVersion: DWORD;
begin
  with egdata do begin

    if unbindingMethodCount = 0 then exit;

    indexOfMinVersionMethod := 0;
    while indexOfMinVersionMethod <> -1 do begin

      //find the index of the unbinding Method that has the minimum version
      indexOfMinVersionMethod := -1;
      minVersion := 0;
      for i := 0 to unbindingMethodCount - 1 do begin
        if unbindingMethods[i].bound = true then continue;

        if minVersion = 0 then begin
          minVersion := unbindingMethods[i].version;
          indexOfMinVersionMethod := i;
          continue;
        end;
        if unbindingMethods[i].version < minVersion then begin
          minVersion := unbindingMethods[i].version;
          indexOfMinVersionMethod := i;
        end
      end;

      if indexOfMinVersionMethod <> -1 then begin
        with unbindingMethods[indexOfMinVersionMethod] do begin
          cmdIndexOfMethod := DefineCommand(cmdFunc, cmdArgs,
                                            cmdInfo.m_szName, cmdInfo.m_szEGName, cmdInfo.m_szExplain,
                                            cmdInfo.m_dtRetType, cmdInfo.m_wState,
                                            cmdInfo.m_shtUserLevel, cmdInfo.m_shtCategory,
                                            cmdInfo.m_shtBitmapIndex, cmdInfo.m_shtBitmapCount,
                                            0 {version} );
          if datatypeIndex <> -1 then
            BindCommandToDatatype(datatypeIndex, cmdIndexOfMethod);

          bound := true; //don't bind me next time
        end;
      end;
    end; //end of while

  end; //end of with egdtat
end;

//fix libinfo if necessary (only once)
//will invoke it in GetNewInf(), or anywhere before GetNewInf() returns.
//must be invoked after FillLibInfo()
procedure FixLibInfo();
var i: Integer;
begin

  with egdata do begin

      if hasFixedLibInfo then exit; //fix it only once
      hasFixedLibInfo := true;

      FixUnbindingMethods();

      //constCount, constInfos
      libInfo.m_nLibConstCount := constCount;
      libInfo.m_pLibConst := GetMemAddressOfArray(constInfos, constCount);
      
      //cmdCount, cmdInfos and cmdFuncs
      libInfo.m_nCmdCount := cmdCount;
      libInfo.m_pBeginCmdInfo := GetMemAddressOfArray(cmdInfos, cmdCount);
      libInfo.m_pCmdsFunc := GetMemAddressOfArray(cmdFuncs, cmdCount);

      //fix commands' argcount and arginfo, see DefineCommand()
      for i := 0 to cmdCount - 1 do begin
        if Integer(cmdInfos[i].m_nArgCount) < 0 then begin
          cmdInfos[i].m_nArgCount := 0 - Integer(cmdInfos[i].m_nArgCount);
          cmdInfos[i].m_pBeginArgInfo := @(argInfos[Integer(cmdInfos[i].m_pBeginArgInfo)]);
        end;
      end;

      //datatypeInfo
      FixDatatypeInfo();
      
  end; //end of with egdata do ...
  
end;

function GetLibInfo(): pLIB_INFO;
begin
  FixLibInfo(); //fix libinfo if necessary (only once)
  result := @(egdata.libInfo);
end;

procedure DefineLib(szName,szGuid,szExplain: PChar;
                    nMajorVersion,nMinorVersion,nBuildNumber,nLanguage: Integer;
                    dwState: LongWord;
                    szAuthor,szHomePage,szOther: PChar;
                    nCategoryCount: Integer; szzCategory: PChar;
                    pfnRunAddInFn: PFN_RUN_ADDIN_FN = nil; szzAddInFnInfo: PChar = nil;
                    pfnNotifyLib: PFN_NOTIFY_LIB = nil; //default to DefaultProcessNotifyLib
                    szzDependFiles: PChar = nil;
                    pfnFreeLibData: PFN_FREE_LIB_DATA = nil);
begin

  if not Assigned(pfnNotifyLib) then 
    pfnNotifyLib := @DefaultProcessNotifyLib;

  egdata.fnFreeLibData := pfnFreeLibData;

  FillLibInfo(egdata.libInfo,
              szName, szGuid, szExplain,
              nMajorVersion, nMinorVersion, nBuildNumber, nLanguage,
              dwState or _LIB_OS(__OS_WIN),
              szAuthor, szHomePage, szOther,
              nCategoryCount, szzCategory,
              0, nil, nil, //nCmdCount, pBeginCmdInfo, pCmdsFunc
              0, nil, //nLibConstCount, pLibConst
              0, nil, //nDataTypeCount, pDataType
              pfnRunAddInFn, szzAddInFnInfo,
              pfnNotifyLib, szzDependFiles,
             );

  //�����ݲ���� pBeginCmdInfo,pCmdsFunc,pLibConst,pDataType����˾Ͳ�������DefineLib()��DefineMethod()�ȵĵ���˳��
  //FixLibInfo()����ʣ��Ĺ���

end;

procedure DefineConst(szName,szEGName,szExplain: PChar;
                      shtType: SmallInt;
                      dbValue: Double = 0.0; szTextValue: PChar = nil);
begin
  Inc(egdata.constCount);
  SetLength(egdata.constInfos, egdata.constCount); //todo: buffered
  FillConstInfo(egdata.constInfos[egdata.constCount-1],
                szName, szEGName, szExplain, shtType, dbValue, szTextValue);
end;

procedure DefineIntConst(szName,szEGName,szExplain: PChar; value: Integer);
begin
  DefineConst(szName, szEGName, szExplain, CT_NUM, value);
end;

procedure DefineDoubleConst(szName,szEGName,szExplain: PChar; value: Double);
begin
  DefineConst(szName, szEGName, szExplain, CT_NUM, value);
end;

procedure DefineBoolConst(szName,szEGName,szExplain: PChar; value: EBool);
var v: Double;
begin
  if value = ETrue then v := 1 else v := 0;
  DefineConst(szName, szEGName, szExplain, CT_BOOL, v);
end;

procedure DefineTextConst(szName,szEGName,szExplain: PChar; value: PChar);
begin
  DefineConst(szName, szEGName, szExplain, CT_TEXT, 0.0, value);
end;

{procedure DefineHiddenConst(nRepeatCount: Integer = 1);
var i: Integer;
begin
  for i := 1 to nRepeatCount do begin
    DefineConst('', '', '', CT_NULL); //CT_NULL������δ֪��, ������������
  end;
end;}

//only used by DefineCommand_NoArg()
function IsValidCommandUserLevel(shtUserLevel: SmallInt) : bool;
begin
  result := ((shtUserLevel = LVL_SIMPLE) or (shtUserLevel = LVL_SECONDARY) or (shtUserLevel = LVL_HIGH))
end;

procedure DelayDefineCommand(cmdFunc: PFN_EXECUTE_CMD; args: array of ARG_INFO;
                             szName,szEGName,szExplain: PChar;
                             dtRetType: DATA_TYPE; wState: Word;
                             shtUserLevel: SmallInt = LVL_SIMPLE; shtCategory: SmallInt = 0;
                             shtBitmapIndex: SmallInt = 0; shtBitmapCount: SmallInt = 0;
                             version: DWORD = 0);
var i: Integer;
begin
  with egdata do begin
    Inc(unbindingMethodCount);
    SetLength(unbindingMethods, unbindingMethodCount);

    unbindingMethods[unbindingMethodCount - 1].version := version;
    unbindingMethods[unbindingMethodCount - 1].datatypeIndex := -1; //is command, not method

    FillCmdInfo(unbindingMethods[unbindingMethodCount - 1].cmdInfo,
                szName, szEGName, szExplain,
                dtRetType, wState or _CMD_OS(__OS_WIN),
                shtUserLevel, shtCategory,
                0, nil, {nArgCount, pBeginArgInfo}
                shtBitmapIndex, shtBitmapCount);

    unbindingMethods[unbindingMethodCount - 1].cmdFunc := cmdFunc;

    SetLength(unbindingMethods[unbindingMethodCount - 1].cmdArgs, Length(args));
    for i := 0 to High(args) do begin
      unbindingMethods[unbindingMethodCount - 1].cmdArgs[i] := args[i];
    end;

  end; //end of with egdata
end;

function DefineCommand(cmdFunc: PFN_EXECUTE_CMD; args: array of ARG_INFO;
                       szName,szEGName,szExplain: PChar;
                       dtRetType: DATA_TYPE; wState: Word;
                       shtUserLevel: SmallInt = LVL_SIMPLE; shtCategory: SmallInt = 0;
                       shtBitmapIndex: SmallInt = 0; shtBitmapCount: SmallInt = 0;
                       version: DWORD = 0) : Integer;
var
  i, baseIndex: integer;
begin

  if version = 0 then begin

    //return the command's index
    result :=  DefineCommand_NoArg(cmdFunc,
                                   szName, szEGName, szExplain,
                                   dtRetType, wState,
                                   shtUserLevel, shtCategory,
                                   shtBitmapIndex, shtBitmapCount);

    if length(args) = 0 then exit;

    //store args to global data.
    //ע: ��ʹargs��һ������(const)��̬����, Ҳ���ܻᱻ��ǰ�ͷ�! --���ݽ�����еĲ²�, ����֤.
    //���Խ�����������Ϣ����һ�ݱ��������Ǳ�Ҫ��.

    Inc(egdata.argCount, Length(args));
    SetLength(egdata.argInfos, egdata.argCount);
    baseIndex := egdata.argCount - Length(args);
    for i := 0 to High(args) do begin
      egdata.argInfos[baseIndex + i] := args[i];
    end;

    //����������д��ֵ(��Ϊ���), ������Ϣ�׵�ַ��д����egdata.argInfos�еĳ�Ա����. FixLibInfo()�н�����֮.
    //(��Ϊegdata.argInfos����֮��, �ڴ��ַ�ܿ��ܷ����仯, ���ھ�ȡ��ĳ����Ա���ڴ��ַ�ǲ����ǵ�)
    egdata.cmdInfos[egdata.cmdCount-1].m_nArgCount := 0 - Length(args);
    egdata.cmdInfos[egdata.cmdCount-1].m_pBeginArgInfo := pARG_INFO(baseIndex);

  end else begin

    DelayDefineCommand(cmdFunc, args,
                       szName, szEGName, szExplain,
                       dtRetType, wState, shtUserLevel, shtCategory,
                       shtBitmapIndex, shtBitmapCount,
                       version);
    result := -1;

  end;
end;

function DefineCommand_NoArg(cmdFunc: PFN_EXECUTE_CMD;
                             szName,szEGName,szExplain: PChar;
                             dtRetType: DATA_TYPE; wState: Word;
                             shtUserLevel: SmallInt = LVL_SIMPLE; shtCategory: SmallInt = 0;
                             shtBitmapIndex: SmallInt = 0; shtBitmapCount: SmallInt = 0;
                             version: DWORD = 0) : Integer;
begin

  if version = 0 then begin

    Inc(egdata.cmdCount);
    SetLength(egdata.cmdInfos, egdata.cmdCount); //todo: buffered
    SetLength(egdata.cmdFuncs, egdata.cmdCount); //todo: buffered

    if not IsValidCommandUserLevel(shtUserLevel) then
      shtUserLevel := LVL_SIMPLE;

    FillCmdInfo(egdata.cmdInfos[egdata.cmdCount-1],
                szName, szEGName, szExplain,
                dtRetType, wState or _CMD_OS(__OS_WIN),
                shtUserLevel, shtCategory,
                0, nil, //nArgCount, pBeginArgInfo
                shtBitmapIndex, shtBitmapCount);

    egdata.cmdFuncs[egdata.cmdCount-1] := cmdFunc;

    result := egdata.cmdCount - 1;

  end else begin

    DelayDefineCommand(cmdFunc, [],
                       szName, szEGName, szExplain,
                       dtRetType, wState, shtUserLevel, shtCategory,
                       shtBitmapIndex, shtBitmapCount,
                       version);
    result := -1;

  end;
end;

procedure DefineHiddenCommand(nRepeatCount: Integer = 1; version: DWORD = 0);
var i: Integer;
begin
  for i := 1 to nRepeatCount do begin
    DefineCommand_NoArg(nil, '', '', '', _SDT_NULL, CT_IS_HIDED, LVL_SIMPLE,
                        0, 0, 0, version);
  end;
end;

//return the new datatype's index
function DefineDatatype(szName,szEGName,szExplain: PChar; dwState: LongWord = 0) : Integer;
begin
  Inc(egdata.datatypeCount);
  SetLength(egdata.datatypeInfos, egdata.datatypeCount); //todo: buffered
  SetLength(egdata.datatypeDatas, egdata.datatypeCount); //todo: buffered

  with egdata.datatypeInfos[egdata.datatypeCount - 1] do begin
    m_szName := szName;
    m_szEGName := szEGName;
    m_szExplain := szExplain;
    m_dwState := dwState or _DT_OS(__OS_WIN);
  end;

  //other infos, such as methods/properties/events/elements,
  //will be filled in FixLibInfo(), or really in FixDatatypeInfo(), invoked by the former.

  result := egdata.datatypeCount - 1;
end;

procedure DefineHiddenDatatype(nRepeatCount: Integer = 1);
var i: Integer;
begin
  for i := 1 to nRepeatCount do begin
    DefineDatatype('', '', '', LDT_IS_HIDED);
  end;
end;

//return the new datatype's index
function DefineEnumDatatype(szName,szEGName,szExplain: PChar; dwState: LongWord = 0) : Integer;
begin
  result := DefineDatatype(szName, szEGName, szExplain, (dwState or LDT_ENUM));
end;

////////////////////////////////////////////////////////////////////////////////

//only used by DefineUIDatatype()
procedure DefineFixedProperties(datatypeIndex: Integer {datatypeIndex must exist});
begin
  DefineProperty(datatypeIndex, '���', 'left', nil, UD_INT, _PROP_OS(OS_ALL), nil);
  DefineProperty(datatypeIndex, '����', 'top', nil, UD_INT, _PROP_OS(OS_ALL), nil);
  DefineProperty(datatypeIndex, '���', 'width', nil, UD_INT, _PROP_OS(OS_ALL), nil);
  DefineProperty(datatypeIndex, '�߶�', 'height', nil, UD_INT, _PROP_OS(OS_ALL), nil);
  DefineProperty(datatypeIndex, '���', 'tag', nil, UD_TEXT, _PROP_OS(OS_ALL), nil);
  DefineProperty(datatypeIndex, '����', 'visible', nil, UD_BOOL, _PROP_OS(OS_ALL), nil);
  DefineProperty(datatypeIndex, '��ֹ', 'disable', nil, UD_BOOL, _PROP_OS(OS_ALL), nil);
  DefineProperty(datatypeIndex, '���ָ��', 'MousePointer', nil, UD_CURSOR, _PROP_OS(OS_ALL), nil);
end;

//only used by EInterfaceGetterTempletCodes
function GetInterfaceOfDatatype(nDatatypeIndex, nInterfaceNO: Integer): PFN_INTERFACE;
begin
  result := nil;
  if (nInterfaceNO < ITF_CREATE_UNIT) or (nInterfaceNO > ITF_GET_NOTIFY_RECEIVER) then
    exit;
  result := PFN_INTERFACE( egdata.datatypeDatas[nDatatypeIndex].interfaces[nInterfaceNO] );
end;

{
function EInterfaceGetterTempletCodes(nInterfaceNO: Integer): PFN_INTERFACE; stdcall;
begin
  result := GetInterfaceOfDatatype(<datatypeIndex>, nInterfaceNO);
end;
}
const EInterfaceGetterTempletCodes: array[0..16] of Byte = (
    $8B, $54, $24, $04,      //mov edx, [esp+$04]
    $B8, $00, $00, $00, $00, //mov eax, <datatypeIndex>
    $E8, $00, $00, $00, $00, //call <GetInterfaceOfDatatype>
    $C2, $04, $00            //ret $0004;
  );

//copy from EInterfaceGetterTempletCodes, and fill in <datatypeIndex> and <GetInterfaceOfDatatype>
//the size of codesBuffer must be enought to fill in EInterfaceGetterTempletCodes
procedure ECreateDatetypeInterfaceGetterFunction(var codesBuffer: array of Byte; datatypeIndex: Integer);
var
  pDatatypeIndex: PInteger;
  pGetInterfaceOfDatatype: PDWORD;
begin
  CopyMemory(@codesBuffer[0], @EInterfaceGetterTempletCodes, Length(EInterfaceGetterTempletCodes));
  pDatatypeIndex := PInteger(@(codesBuffer[5]));
  pDatatypeIndex^ := Integer(datatypeIndex); //<datatypeIndex>
  pGetInterfaceOfDatatype := PDWORD(@(codesBuffer[10]));
  pGetInterfaceOfDatatype^ := DWORD(@GetInterfaceOfDatatype); //<GetInterfaceOfDatatype>
end;

////////////////////////////////////////////////////////////////////////////////

//return the new datatype's index
function DefineUIDatatype(szName,szEGName,szExplain: PChar;
                          dwState,dwUnitBmpID: LongWord;
                          pfnGetInterface: PFN_GET_INTERFACE = nil;
                          onCreateUnit: PFN_CREATE_UNIT = nil;
                          onGetPropertyValue: PFN_GET_PROPERTY_DATA = nil;
                          onSetPropertyValue: PFN_NOTIFY_PROPERTY_CHANGED = nil;
                          onGetAllPropertiesValue: PFN_GET_ALL_PROPERTY_DATA = nil;
                          onPropertyUpdateUI: PFN_PROPERTY_UPDATE_UI = nil;
                          onInitDlgCustomData: PFN_DLG_INIT_CUSTOMIZE_DATA = nil;
                          onGetIconPropertyValue: PFN_GET_ICON_PROPERTY_DATA = nil;
                          onIsNeedThisKey: PFN_IS_NEED_THIS_KEY = nil;
                          onLanguageConv: PFN_LANG_CNV = nil;
                          onMsgFilter: PFN_MESSAGE_FILTER = nil;
                          onNotifyUnit: PFN_ON_NOTIFY_UNIT = nil ) : Integer;
var
  datatypeIndex: Integer;
begin

  datatypeIndex := DefineDatatype(szName, szEGName, szExplain, (dwState or LDT_WIN_UNIT));
  result := datatypeIndex;

  with egdata.datatypeInfos[datatypeIndex] do begin
    m_dwUnitBmpID := dwUnitBmpID;
    m_pfnGetInterface := pfnGetInterface;
  end;

  DefineFixedProperties(datatypeIndex);

  if Assigned(pfnGetInterface) then exit;

  //����, Ϊ LIB_DATA_TYPE_INFO.m_pfnGetInterface �Զ�������Ӧ����, ���: ECreateDatetypeInterfaceGetterFunction()
  //���� FixLibData() ���������ɵĴ���, ����� LIB_DATA_TYPE_INFO.m_pfnGetInterface
  ECreateDatetypeInterfaceGetterFunction(egdata.datatypeDatas[datatypeIndex].interfaceGetterCodes, datatypeIndex);

  with egdata.datatypeDatas[datatypeIndex] do begin
    interfaces[{1} ITF_CREATE_UNIT] := PFN_INTERFACE(onCreateUnit);
    interfaces[{2} ITF_PROPERTY_UPDATE_UI] := PFN_INTERFACE(onPropertyUpdateUI);
    interfaces[{3} ITF_DLG_INIT_CUSTOMIZE_DATA] := PFN_INTERFACE(onInitDlgCustomData);
    interfaces[{4} ITF_NOTIFY_PROPERTY_CHANGED] := PFN_INTERFACE(onSetPropertyValue);
    interfaces[{5} ITF_GET_ALL_PROPERTY_DATA] := PFN_INTERFACE(onGetAllPropertiesValue);
    interfaces[{6} ITF_GET_PROPERTY_DATA] := PFN_INTERFACE(onGetPropertyValue);
    interfaces[{7} ITF_GET_ICON_PROPERTY_DATA] := PFN_INTERFACE(onGetIconPropertyValue);
    interfaces[{8} ITF_IS_NEED_THIS_KEY] := PFN_INTERFACE(onIsNeedThisKey);
    interfaces[{9} ITF_LANG_CNV] := PFN_INTERFACE(onLanguageConv);
    interfaces[10] := nil;
    interfaces[{11} ITF_MSG_FILTER] := PFN_INTERFACE(onMsgFilter);
    interfaces[{12} ITF_GET_NOTIFY_RECEIVER] := PFN_INTERFACE(onNotifyUnit);
  end;

end;

procedure DelayDefineMethod(datatypeIndex: Integer; {datatypeIndex must exist}
                            cmdFunc: PFN_EXECUTE_CMD; args: array of ARG_INFO;
                            szName,szEGName,szExplain: PChar;
                            dtRetType: DATA_TYPE; wState: Word;
                            shtUserLevel: SmallInt = LVL_SIMPLE; shtCategory: SmallInt = -1;
                            shtBitmapIndex: SmallInt = 0; shtBitmapCount: SmallInt = 0;
                            version: DWORD = 0);
begin

  DelayDefineCommand(cmdFunc, args,
                     szName, szEGName, szExplain,
                     dtRetType, wState,
                     shtUserLevel, -1{shtCategory},
                     shtBitmapIndex, shtBitmapCount,
                     version);

  with egdata do begin
    unbindingMethods[unbindingMethodCount - 1].datatypeIndex := datatypeIndex;
  end;

end;

function DefineMethod(datatypeIndex: Integer; {datatypeIndex must exist}
                      cmdFunc: PFN_EXECUTE_CMD; args: array of ARG_INFO;
                      szName,szEGName,szExplain: PChar;
                      dtRetType: DATA_TYPE; wState: Word;
                      shtUserLevel: SmallInt = LVL_SIMPLE; shtCategory: SmallInt = -1;
                      shtBitmapIndex: SmallInt = 0; shtBitmapCount: SmallInt = 0;
                      version: DWORD = 0) : Integer;
var cmdIndex: Integer;
begin

  if version = 0 then begin
    cmdIndex :=  DefineCommand(cmdFunc, args,
                               szName, szEGName, szExplain,
                               dtRetType, wState,
                               shtUserLevel, -1{shtCategory},
                               shtBitmapIndex, shtBitmapCount);

    BindCommandToDatatype(datatypeIndex, cmdIndex);

    result := cmdIndex; //return the method's index (of all commands in the library)

  end else begin

    DelayDefineMethod(datatypeIndex, cmdFunc, args,
                      szName, szEGName, szExplain,
                      dtRetType, wState, shtUserLevel, -1{shtCategory},
                      shtBitmapIndex, shtBitmapCount,
                      version);
    result := -1;

  end;
end;

function DefineMethod_NoArg(datatypeIndex: Integer; {datatypeIndex must exist}
                            cmdFunc: PFN_EXECUTE_CMD;
                            szName,szEGName,szExplain: PChar;
                            dtRetType: DATA_TYPE; wState: Word;
                            shtUserLevel: SmallInt = LVL_SIMPLE; shtCategory: SmallInt = -1;
                            shtBitmapIndex: SmallInt = 0; shtBitmapCount: SmallInt = 0;
                            version: DWORD = 0) : Integer;
var cmdIndex: Integer;
begin
  if version = 0 then begin

    cmdIndex :=  DefineCommand_NoArg(cmdFunc,
                                     szName, szEGName, szExplain,
                                     dtRetType, wState,
                                     shtUserLevel, -1{shtCategory},
                                     shtBitmapIndex, shtBitmapCount);

    BindCommandToDatatype(datatypeIndex, cmdIndex);

    result := cmdIndex; //return the method's index (of all commands)

  end else begin

    DelayDefineMethod(datatypeIndex, cmdFunc, [],
                      szName, szEGName, szExplain,
                      dtRetType, wState, shtUserLevel, -1{shtCategory},
                      shtBitmapIndex, shtBitmapCount,
                      version);
    result := -1;

  end;
end;

procedure DefineHiddenMethod(datatypeIndex: Integer; {datatypeIndex must exist}
                             nRepeatCount: Integer = 1; version: DWORD = 0);
var i: Integer;
begin
  for i := 1 to nRepeatCount do begin
    DefineMethod_NoArg(datatypeIndex, nil, '', '', '', _SDT_NULL, CT_IS_HIDED,
                       LVL_SIMPLE, -1, 0, 0, version);
  end;
end;

procedure DefineElement(datatypeIndex: Integer; {datatypeIndex must exist}
                        szName,szEGName,szExplain: PChar;
                        dtDataType: DATA_TYPE; pArySpec: PByte = nil;
                        dwState: LongWord = 0; nDefault: Integer = 0);
begin

  with egdata.datatypeDatas[datatypeIndex] do begin
    Inc(elementCount);
    SetLength(elementInfos, elementCount);
    FillElementInfo(elementInfos[elementCount - 1],
                    szName, szEGName, szExplain,
                    dtDataType, pArySpec,
                    dwState, nDefault);
  end;
end;

procedure DefineHiddenElement(datatypeIndex: Integer; {datatypeIndex must exist}
                              nRepeatCount: Integer = 1);
var i: Integer;
begin
  for i := 1 to nRepeatCount do begin
    DefineElement(datatypeIndex, '', '', '', SDT_INT, nil, LES_HIDED, 0);
  end;
end;

procedure DefineEnumElement(datatypeIndex: Integer; {datatypeIndex must exist}
                            szName,szEGName,szExplain: PChar;
                            nValue: Integer; dwState: LongWord = 0);
begin
  DefineElement(datatypeIndex,
                szName, szEGName, szExplain,
                SDT_INT, nil, {must be SDT_INT and nil in Enum datatype}
                dwState, nValue);
end;

procedure DefineEvent(datatypeIndex: Integer; {datatypeIndex must exist}
                      szName,szExplain: PChar; dwState: LongWord;
                      args: array of EVENT_ARG_INFO2;
                      dtRetDataType: DATA_TYPE);
var
  nArgCount, i, baseIndex: Integer;
begin

  nArgCount := Length(args);

  with egdata, datatypeDatas[datatypeIndex] do begin

    Inc(eventCount);
    SetLength(eventInfos, eventCount); //todo: buffered

    if nArgCount > 0 then begin
      //store args to global data, see DefineCommand()
      baseIndex := eventArgCount;
      Inc(eventArgCount, nArgCount);
      SetLength(eventArgInfos, eventArgCount); //todo: buffered
      for i := 0 to nArgCount - 1 do begin
        eventArgInfos[baseIndex + i] := args[i];
      end;
    end else begin
      baseIndex := 0; //nil
    end;

    FillEventInfo2(eventInfos[eventCount - 1],
                   szName, szExplain, (dwState or _EVENT_OS(__OS_WIN)),
                   0 - nArgCount, pEVENT_ARG_INFO2(baseIndex), //�����������븺ֵ, ������Ϣ��ַ��������. see DefineCommand(). FixLibInfo() will fix this.
                   dtRetDataType);
  end;
end;

procedure DefineHiddenEvent(datatypeIndex: Integer; {datatypeIndex must exist}
                            nRepeatCount: Integer = 1);
var i: Integer;
begin
  for i := 1 to nRepeatCount do begin
    DefineEvent(datatypeIndex, '', '', EV_IS_HIDED, [], _SDT_NULL);
  end;
end;

procedure DefineProperty(datatypeIndex: Integer; {datatypeIndex must exist}
                         szName,szEGName,szExplain: PChar;
                         shtType: SmallInt; wState: Word;
                         szzPickStr: PChar);
begin
  with egdata, datatypeDatas[datatypeIndex] do begin

    Inc(propertyCount);
    SetLength(propertyInfos, propertyCount); //todo: buffered

    FillPropertyInfo(propertyInfos[propertyCount - 1],
                     szName, szEGName, szExplain,
                     shtType, (wState or _PROP_OS(__OS_WIN)),
                     szzPickStr);

  end; //end of with
end;

procedure DefineHiddenProperty(datatypeIndex: Integer; {datatypeIndex must exist}
                               nRepeatCount: Integer = 1);
var i: Integer;
begin
  for i := 1 to nRepeatCount do begin
    DefineProperty(datatypeIndex, '', '', '', UD_INT, UW_IS_HIDED, nil);
  end;
end;

////////////////////////////////////////////////////////////////////////////////
//
// ������:
//
//     Good Luck!
//
////////////////////////////////////////////////////////////////////////////////

end.


