#include "windows.h"

//��������Լ��Ϊ stdcall; �ڲ�����Win32 API����MessageBoxA

void __stdcall vc_msgbox(const char* msg)
{
	MessageBoxA(0, msg, "from vc6", MB_OK);
}
