title: "Big,Little Endian"
date: 2015-03-21 20:43:15
tags: [Main-Memmory, Operating-System]
categories: Computer Science
---

(内容基本来源于网络,个人摘抄整理)
#一.大端,小端的来源
“大端”和“小端”可以追溯到1726年的Jonathan Swift的《格列佛游记》，其中一篇讲到有两个国家因为吃鸡蛋究竟是先打破较大的一端还是先打破较小的一端而争执不休，甚至爆发了战争。1981年10 月，Danny Cohen的文章《论圣战以及对和平的祈祷》（On holy wars and a plea for peace）将这一对词语引入了计算机界。这么看来，所谓大端和小端，也就是big-endian和little-endian，其实是从描述鸡蛋的部位 而引申到计算机地址的描述，也可以说，是从一个俚语衍化来的计算机术语。稍有些英语常识的 人都会知道，如果单靠字面意思来理解俚语，那是很难猜到它的正确含义的。在计算机里，对于地址的描述，很少用“大”和“小”来形容；对应地，用的更多的是 “高”和“低”；很不幸地，这对术语直接按字面翻译过来就成了“大端”和“小端”，让人产生迷惑也不是很奇怪的事了。
![image](http://ingwii.aliapp.com/wp-content/uploads/2015/03/biglittleendian.png)
#二.何为大端,小端

```
     大端: 低地址在高(大)位
     小端: 低地址在低(小)位,高地址在高位
```
#三.为什么会有大小端模式之分呢？

因为在计算机系统中，我们是以字节为单位的，每个地址单元都对应着一个字节，一个字节为 8bit。但是在C语言中除了8bit的char之外，还有16bit的short型，32bit的long型（要看具体的编译器），另外，对于位数大于 8位的处理器，例如16位或者32位的处理器，由于寄存器宽度大于一个字节，那么必然存在着一个如果将多个字节安排的问题。因此就导致了大端存储模式和小端存储模式。例如一个16bit的short型x，在内存中的地址为0x0010，x的值为0x1122，那么0x11为高字节，0x22为低字节。对于 大端模式，就将0x11放在低地址中，即0x0010中，0x22放在高地址中，即0x0011中。小端模式，刚好相反。我们常用的X86结构是小端模 式，而KEIL C51则为大端模式。很多的ARM，DSP都为小端模式。有些ARM处理器还可以由硬件来选择是大端模式还是小端模式,PowerPC 通常是Big endian.
 

#四.如何编程判断cpu采用的是Big-endian or Little-endian?
##方法一:
---
将一个字节（CHAR/BYTE 类型）的数据和一个整型数据存放于同样的内存开始地址，通过读取整型数据，分析CHAR/BYTE 数据在整型数据的高位还是低位来判断CPU 工作于Little-endian 还是Big-endian 模式。得出如下的答案：

```
	typedef unsigned char BYTE;
	int main(int argc, char* argv[]){
	   	unsigned int num,*p;
		p = &num;
		num = 0;
        *(BYTE *)p = 0xff;
        if(num == 0xff){
    		printf("little\n");
		}
		else //num == 0xff000000{
			printf("big\n");
		}
	return 0;
	}
```

##方法二:
---
union 的成员本身就被存放在相同的内存空间（共享内存，正是union 发挥作用、做贡献的去处），因此，我们可以将一个CHAR/BYTE 数据和一个整型数据同时作为一个union 的成员，得出如下答案：

```
	int checkCPU(){
		union w{
			int a;
			char b;
		} c;
		c.a = 1;
		return (c.b == 1);
	}
```
##方法三 (Linux源码):
---
实现同样的功能，我们来看看Linux 操作系统中相关的源代码是怎么做的：

```
	union {
      	static char c[4];
      	unsigned long mylong;
	} endian_test = { 'l', '?', '?', 'b' };
	#define ENDIANNESS ((char)endian_test.mylong)
```

// 解释 - Wii
// endia_test初始化后 内存 低->高 = ' l ? ? b';
// 用unsigned long 取出来以后 若为小端则mylong的值为  'b??l';
//利用(char)强转后,去掉高位,保留低位值,则为'l' 即,小端;
Linux 的内核作者们仅仅用一个union 变量和一个简单的宏定义就实现了一大段代码同样的功能！由以上一段代码我们可以深刻领会到Linux 源代码的精妙之处！(如果ENDIANNESS=’l’表示系统为little endian,
为’b’表示big endian ) 

          
