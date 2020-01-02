#include "windows.h"

//函数调用约定为 stdcall; 内部调用Win32 API函数MessageBoxA

void __stdcall vc_msgbox(const char* msg)
{
	MessageBoxA(0, msg, "from vc6", MB_OK);
}
