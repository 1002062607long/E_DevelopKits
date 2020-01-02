#include <time.h>

//由于此函数是定义在cpp文件中, C++编译器编译时经过"名称修饰(Name mangling)", 会把函数符号名称修改为 ?vc_time@@YAHXZ 之类, 不利于在其它编程语言中使用
//使用 extern "C" 的目的是要求C++编译器按照C编译器的行为生成函数符号名称, 此时生成的函数符号为 _vc_time, 仅在函数名称前加下划线(_), 更易于其它编程语言使用

extern "C" int vc_time()
{
	return (int) time(NULL);
}


//由于上面所说的原因, 此函数被VC6编译后得到的函数符号名称为 ?vc_time2@@YAHXZ
//在易语言中也可以调用它, 但其它编程语言能否调用就不好说了

int vc_time2()
{
	return (int) time(NULL);
}
