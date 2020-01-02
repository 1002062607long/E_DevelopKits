
#ifndef __MACRO_H__
#define __MACRO_H__

// 编译时宏处理器接口

//----------------------------------------------------------------------------

// 宏数据类型
#define		MDT_INT			1	// 整数
#define		MDT_INT64		2	// 长整数
#define		MDT_FLOAT		3	// 单精度小数
#define		MDT_DOUBLE		4	// 双精度小数
#define		MDT_BOOL		5	// 逻辑
#define		MDT_DATE_TIME	6	// 日期时间
#define		MDT_TEXT		7	// 文本
#define		MDT_BIN			8	// 字节集
#define		MDT_CODE		9	// 代码字节集(宏处理器所接收到参数不会为此数据类型,仅在其返回处理结果数据时使用)

typedef unsigned int MACRO_DATA_TYPE;
typedef MACRO_DATA_TYPE* PMACRO_DATA_TYPE;

// 用作记录宏所使用的立即数据
typedef union
{
    // m_blIsAry为假时:
	int		m_int;			 // MDT_INT 记录整数数值
    __int64 m_int64;         // MDT_INT64 记录长整数数值
	float	m_float;		 // MDT_FLOAT 记录单精度数值
	double	m_double;		 // MDT_DOUBLE 记录双精度数值
	int 	m_bool;		     // MDT_BOOL 记录逻辑值: TRUE/FALSE
	double	m_dtDateTime;	 // MDT_DATE_TIME 记录日期时间数据. 注:实际为MFC内的DATE数据类型
	char*	m_szText;		 // MDT_TEXT 记录以'\0'字符结束的文本数据
	unsigned char* m_pData;  //   MDT_BIN,MDT_CODE 记录字节集数据。数据格式为：首先为一个INT记录数据长度（此值也可能为0），
							 // 后跟相应长度的数据。

    // m_blIsAry为真时:
    //   记录常数数组数据。数据格式为：首先为一个INT记录成员数目（此值也可能为0），
    // 后跟顺序排列的相应数目各成员数据本身
	unsigned char* m_pAryData;
}
MACRO_IMM_VAULE, *PMACRO_IMM_VAULE;

// 用作记录立即数据及其数据类型
typedef struct
{
	MACRO_DATA_TYPE m_dtDataType;  // 数据类型
	int m_blIsAry;				   // 是否为数组数据 TRUE/FALSE
    MACRO_IMM_VAULE m_imm;
}
IMM_VALUE_WITH_DATA_TYPE;

// 处理所提供的所有立即数参数数据,处理成功返回NULL,否则返回非NULL具体错误信息文本指针.
//   apImmArgs, nNumImmArgs: 提供用户所提供的所有立即数参数数据及其个数
//   pProcessResult: 如果本处理器函数返回成功,则需要在其中填入具体的返回数据. 返回数据中所
//      涉及到使用的外部内存(譬如文本/字节集/数组)需要由插件自行分配并保持其有效,这些内存在
//      本函数中可以重复使用. 即当下一次调用本函数时,上一次调用所分配的外部内存即不再需要,
//      可以被释放或再次使用.
typedef const char* (WINAPI *FN_MACRO_PROCESSOR) (const IMM_VALUE_WITH_DATA_TYPE* apImmArgs,
        int nNumImmArgs, IMM_VALUE_WITH_DATA_TYPE* pProcessResult);

// 插件DLL中宏处理器输出函数的名称
#define MACRO_PROCESSOR_EXPORT_NAME  "MacroProcessor"

// 开发易语言编译器插件的方法:
//   开发一个dll,其输出一个名为MACRO_PROCESSOR_EXPORT_NAME的函数,用作在易语言程序编译过程中处理来自"宏"命令的输入数据,
// 处理完毕后输出合适的数据,该数据将被整合进易语言程序的编译结果中.
//   注意: 所编译出来的插件dll文件必须放在易语言系统的"plugins"子目录下才能被编译器所使用

#endif
