
extern "C" int vc_add(int x, int y); //�˺�������һ����̬��vclib1.lib�ж���, �˴�ֻ������

//������������õ�����һ����̬���ж���ĺ���, ������ʱ����֮
//����, ���������е���vc_sumʱ, ����ָ��vc_sum����������vclib2.lib֮��, ��Ҫָ������������vclib1.lib

extern "C" int vc_sum(int x, int y , int z)
{
	return vc_add(x, vc_add(y, z));
}
