
extern "C" int vc_add(int x, int y); //此函数在另一个静态库vclib1.lib中定义, 此处只是声明

//下面这个函数用到了另一个静态库中定义的函数, 即链接时依赖之
//所以, 在易语言中调用vc_sum时, 除了指定vc_sum自身所属的vclib2.lib之外, 还要指定它所依赖的vclib1.lib

extern "C" int vc_sum(int x, int y , int z)
{
	return vc_add(x, vc_add(y, z));
}
