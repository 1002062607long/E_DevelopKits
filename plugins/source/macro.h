
#ifndef __MACRO_H__
#define __MACRO_H__

// ����ʱ�괦�����ӿ�

//----------------------------------------------------------------------------

// ����������
#define		MDT_INT			1	// ����
#define		MDT_INT64		2	// ������
#define		MDT_FLOAT		3	// ������С��
#define		MDT_DOUBLE		4	// ˫����С��
#define		MDT_BOOL		5	// �߼�
#define		MDT_DATE_TIME	6	// ����ʱ��
#define		MDT_TEXT		7	// �ı�
#define		MDT_BIN			8	// �ֽڼ�
#define		MDT_CODE		9	// �����ֽڼ�(�괦���������յ���������Ϊ����������,�����䷵�ش���������ʱʹ��)

typedef unsigned int MACRO_DATA_TYPE;
typedef MACRO_DATA_TYPE* PMACRO_DATA_TYPE;

// ������¼����ʹ�õ���������
typedef union
{
    // m_blIsAryΪ��ʱ:
	int		m_int;			 // MDT_INT ��¼������ֵ
    __int64 m_int64;         // MDT_INT64 ��¼��������ֵ
	float	m_float;		 // MDT_FLOAT ��¼��������ֵ
	double	m_double;		 // MDT_DOUBLE ��¼˫������ֵ
	int 	m_bool;		     // MDT_BOOL ��¼�߼�ֵ: TRUE/FALSE
	double	m_dtDateTime;	 // MDT_DATE_TIME ��¼����ʱ������. ע:ʵ��ΪMFC�ڵ�DATE��������
	char*	m_szText;		 // MDT_TEXT ��¼��'\0'�ַ��������ı�����
	unsigned char* m_pData;  //   MDT_BIN,MDT_CODE ��¼�ֽڼ����ݡ����ݸ�ʽΪ������Ϊһ��INT��¼���ݳ��ȣ���ֵҲ����Ϊ0����
							 // �����Ӧ���ȵ����ݡ�

    // m_blIsAryΪ��ʱ:
    //   ��¼�����������ݡ����ݸ�ʽΪ������Ϊһ��INT��¼��Ա��Ŀ����ֵҲ����Ϊ0����
    // ���˳�����е���Ӧ��Ŀ����Ա���ݱ���
	unsigned char* m_pAryData;
}
MACRO_IMM_VAULE, *PMACRO_IMM_VAULE;

// ������¼�������ݼ�����������
typedef struct
{
	MACRO_DATA_TYPE m_dtDataType;  // ��������
	int m_blIsAry;				   // �Ƿ�Ϊ�������� TRUE/FALSE
    MACRO_IMM_VAULE m_imm;
}
IMM_VALUE_WITH_DATA_TYPE;

// �������ṩ��������������������,����ɹ�����NULL,���򷵻ط�NULL���������Ϣ�ı�ָ��.
//   apImmArgs, nNumImmArgs: �ṩ�û����ṩ�������������������ݼ������
//   pProcessResult: ������������������سɹ�,����Ҫ�������������ķ�������. ������������
//      �漰��ʹ�õ��ⲿ�ڴ�(Ʃ���ı�/�ֽڼ�/����)��Ҫ�ɲ�����з��䲢��������Ч,��Щ�ڴ���
//      �������п����ظ�ʹ��. ������һ�ε��ñ�����ʱ,��һ�ε�����������ⲿ�ڴ漴������Ҫ,
//      ���Ա��ͷŻ��ٴ�ʹ��.
typedef const char* (WINAPI *FN_MACRO_PROCESSOR) (const IMM_VALUE_WITH_DATA_TYPE* apImmArgs,
        int nNumImmArgs, IMM_VALUE_WITH_DATA_TYPE* pProcessResult);

// ���DLL�к괦�����������������
#define MACRO_PROCESSOR_EXPORT_NAME  "MacroProcessor"

// ���������Ա���������ķ���:
//   ����һ��dll,�����һ����ΪMACRO_PROCESSOR_EXPORT_NAME�ĺ���,�����������Գ����������д�������"��"�������������,
// ������Ϻ�������ʵ�����,�����ݽ������Ͻ������Գ���ı�������.
//   ע��: ����������Ĳ��dll�ļ��������������ϵͳ��"plugins"��Ŀ¼�²��ܱ���������ʹ��

#endif
