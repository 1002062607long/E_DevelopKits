#include <reg52.h> //包含单片机操作头文件
unsigned char flag,tmp;//定义变量
void main()
{
REN=1;
TMOD=0x20;//定时器工作方式
TH1=0xfd;//设置串行口波特率9600
TL1=0xfd;//设置串行口波特率9600
	TR1=1;//启动计时器1(启动串行口)
	SM0=0;
	SM1=1;
	EA=1;////CPU开中断
	ES=1;////CPU开中断
		while(1)//设置一个循环
		{
	 		 if(flag==1)//代表收到了数据
	 			 {
					ES=0;
					flag=0;
					P1=tmp;//点亮发光二极管
					SBUF=tmp;//把值重新写入缓冲区，相当于从串口发送数据，电脑就可以接收到数据
					while(!TI);
					TI=0;
 					ES=1;
				 }
       }
}

void ser() interrupt 4 //中断，等待数据到来触发
{
	RI=0;
	tmp=SBUF;//取得数据到变量
	flag=1;
}
