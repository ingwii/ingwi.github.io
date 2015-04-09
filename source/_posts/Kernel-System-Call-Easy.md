title: "Kernel-System Call-Easy"
date: 2015-04-09 17:51:29
tags: [Kernel, Operationg System]
categories: Computer Science
---
#Linux Kernel System Call Easy Trial
本人能力有限,如果文章中有错误,或需要优化的地方请联系我michaelwii@163.com

---
##Reference 参考资料

```
	1.操作原理李继云老师提供的ppt
	2.http://blog.chinaunix.net/uid-28392723-id-3520177.html
	3.http://rpmfind.net/linux/rpm2html/search.php?query=ncurses-devel
	4.kernel3.4.106: https://www.kernel.org/pub/linux/kernel/v3.x/linux-3.4.106.tar.xz
	5.http://www.jb51.net/LINUXjishu/34604.html
	6.vim查找: http://blog.csdn.net/hitustc/article/details/5585101: 
	7.内核调试: http://bbs.chinaunix.net/thread-3610322-1-1.html
	8.printfk: http://blog.csdn.net/hunanchenxingyu/article/details/7964517
	9.printfk: http://blog.chinaunix.net/uid-28253945-id-3672651.html
```
##Compile Kernel 编译内核

>前言:编程后的步骤是,编译->链接->执行. 所以进行内核编程后的关键步骤就是编译链接内核.需要说明的是,本次试验我采用的是Debian 7.8,其中内核版本为3.2. 然后我在Kernel.org上下载了3.4.106的kernel版本,并更新了Debian7.8的内核.SystemCall的试验也是在该版本的内核源码下修改的.`参考资料`提供了相关发行版和内核的下载链接.有需要的朋友可以收下~如果是初学者,建议使用相同环境学习.这样可以避免很多不必要的麻烦.

####Kernel Simple Summary 内核简述:
Linux的内核中Makefile采用自顶向下,类似树的方式编译内核.所以make操作一定要在源代码/根目录下操作.`以下的根目录都指的是源代码下的根目录`


####Check Kernel Version 查看内核版本:
这是需要学会的, 一般情况是不可以降级内核的(我没有试过).因为内核上层的应用中可能会调用新版本内核中的接口等,而旧版本内核是不支持的.所以一般情况都是升级.本次升级内核是3.2->3.4

```
	//三选一吧~
	cat /proc/version 
	uname -r
	uname -a
```

####Download Kernel Source 下载内核源码,解压缩.xz.tar
下载大家都会的,wget,迅雷都行.主要是讲一下怎么解压.tar.xz的文件.kernel.org上下载下来的文件只有50M,可是解压缩以后就有400+M, 这个.xz的压缩格式要厉害啊~ 因为不是重点,这里我没有仔细去研究,感兴趣的朋友可以研究一下压缩算法什么的,研究好以后email我呗~哈哈

```
	//压缩命令如下,依次使用
	xz -d xxxxx.tar.xz
	tar xvf xxxxx.tar
```
解压在`/usr/src/`
####First Compiling - Details 第一次编译内核详细步骤

```
	#make mrproper	//清楚编译痕迹, 会删除.config文件
	#make menuconfig	//还可以采用xconfig等,生成.config配置文件
	/*
		注意:如果提示没有ncurses的话,那么在Ubuntu/Debian环境下可以执行
		#apt-get install libncurses5-dev
		安装结束后,在执行menuconfig
	 */
	#make bzImage
	#make modules
	#make modules_install
	#make install
	#reboot	//grub引导重启, 选择新的内核版本
```
按照上述步骤,依次编译后,就会在`/boot/`下生成三个文件

```
	config-3.4.106
	System.map-3.4.106
	vmlinuz-3.4.106
```
然后查看`/boot/grub/grub.cfg`,就会多出下面一段代码(install时自动添加的)

```
menuentry 'Debian GNU/Linux, with Linux 3.4.106' --class debian --class gnu-linux --class gnu --class os {
        load_video
        insmod gzio
        insmod part_msdos
        insmod ext2
        set root='(hd0,msdos1)'
        search --no-floppy --fs-uuid --set=root f957a2b6-9dfc-486f-a2ba-eb499fa462e9
        echo    'Loading Linux 3.4.106 ...'
        linux   /boot/vmlinuz-3.4.106 root=UUID=f957a2b6-9dfc-486f-a2ba-eb499fa462e9 ro  quiet
        echo    'Loading initial ramdisk ...'
        initrd  /boot/initrd.img-3.4.106
}
menuentry 'Debian GNU/Linux, with Linux 3.4.106 (recovery mode)' --class debian --class gnu-linux --class gnu --class os {
        load_video
        insmod gzio
        insmod part_msdos
        insmod ext2
        set root='(hd0,msdos1)'
        search --no-floppy --fs-uuid --set=root f957a2b6-9dfc-486f-a2ba-eb499fa462e9
        echo    'Loading Linux 3.4.106 ...'
        linux   /boot/vmlinuz-3.4.106 root=UUID=f957a2b6-9dfc-486f-a2ba-eb499fa462e9 ro single
        echo    'Loading initial ramdisk ...'
        initrd  /boot/initrd.img-3.4.106
}
```
这是grub引导linux内核的配置信息.`/boot`下还有老版本的三个文件,可以删掉.`/boot/grub/grub.cfg`中还会有老版本内核的引导信息,也可以删掉.另外,生成bzImage和modules的时候十分缓慢,但是可以使用多线程的方式尽可能的所以编译时间,后面会讲.

####Multi-Thread Compiling 多线程编译内核
其实就是如下的一个命令,N可以代表线程数,我参考百度的资料另N=15,基本可以使得cpu的利用率达到100%.

```
	#make -jN xxx	//xxx是其他在Makefile中描述的规则
```
#####Use Cmd top to Check Cpu 使用top查看cpu使用情况
`第三行`就是描述cpu使用情况的数据,其中(当有多个CPU时，这些内容可能会超过两行):

```
	$top
	//Cpu(s): 
	//0.3% 	us	用户空间占用CPU百分比
	//1.0% 	sy	内核空间占用CPU百分比
	//0.0% 	ni	用户进程空间内改变过优先级的进程占用CPU百分比
	//98.7% id	空闲CPU百分比
	//0.0% 	wa	等待输入输出的CPU时间百分比
```
更多内容参考参考资料5

##System Call 系统调用
####Summary 概述
	系统调用的原理非常简单,当用户空间的程序需要调用内核程序时, 是通过一张表(即系统调用表),联系起来的.具体知识请看书啦~下面是如何在内核源码中修改相关信息,来达成系统调用的功能.
#####为什么要系统调用呢? (个人理解)
	最主要的是,系统调用封装出了接口供上层软件使用.在对底层硬件或内核机制进行管理的时候非常复杂.从硬件角度讲,需要扎实的硬件知识.从内核实现上说,例如进程控制,调度等是操作系统的核心,核心程序不能有过多的bug,需要非常严谨.所以哪怕是linux的维护者们, 在修改kernel中的.c文件时,哪怕只有非常小的改动都是需要长时间研究,看看其对整个内核影响,会不会造成bug等.所以普通的用户是不需要,也不能去修改系统调用的.所以,这里有着这个操作系统最大的权限,甚至可以控制整个操作系统.也正是因为如此,我们需要在这里编程,更深层次的个性化这个操作系统.
####Trial 实验部分

#####Step 1: 声明
为我们的函数,在系统调用的头文件中声明一下,在`/include/linux/syscalls.h`文件末尾的#endif前添加我们的函数声明:

```
	asmlinkage int sys_HelloWorldCall(void);
```
#####Step 2: 添加系统调用表
将我们的函数添加进函数调用表,该版本内核分别支持32,64位机器.所以要添加两个.在`arch/x86/syscalls/syscall_64.tbl`找到最后一个64为系统调用表,在其后添加64位系统调用号:

```
	312  	64  	helloworld  	sys_HelloWorldCall
```
`arch/x86/syscalls/syscall_32.tbl`添加32位系统调用号

```
    349  	i386	helloworld		sys_HelloWorldCall
```
#####Step 3: 实现
在根目录下创建文件夹和文件:`/helloworld/helloworld.c`.内容:

```
	//程序内容
	//1.输出hello world
	//2.输出当前所有进程的进程名, pid, 状态
	#include <linux/kernel.h>
	#include <linux/init.h>
	#include <linux/sched.h>
	#include <linux/syscalls.h>
	asmlinkage int sys_lsproc(void) {
		struct task_struct *p;
		printk("Hello World\n");
		pr_info("\tProcess\tPid\tState");
		for_each_process(p)
		{
			pr_info("%15s\t%u\t%ld", p->comm, task_pid_nr(p), p->state);
		}
		return 0x19950411;//正好四个字节 嘿嘿
	}
```
#####Step 4: Makefile
我们自己斜号了一个源文件,但是Makefile并不知道怎么编译我们的源文件,也不知道我们在哪里,所以我们需要写好我们自己的Makefile,还要在/根目录下的Makefile中描述我们的位置. 新建`/helloworld/Makefile`,在里面添加一句

```
	obj-y := helloworld.c
```
然后修改`/Makefile`.

```
	找到 core-y += kernel/ mm/ fs/ ipc/ security/ crypto/ block/
	然后再最后添加一个helloworld/
	变成 core-y += kernel/ mm/ fs/ ipc/ security/ crypto/ block/ lsproc/
```
(ps:在根目录找查找到这句话也挺费劲,所以要用到vim的查找功能,本文后面再讲)
#####Step 5: Test System Call
自己建一个.c,然后gcc执行以下代码:

```
	#include <stdio.h>
	#include <unistd.h>
	int main(int argc, char *argv[]) {
		int ret;
		ret = syscall(312);
		if (ret < 0){
			perror("HelloWorld Error");
		}
		else{
			printf("System Call Return Val:%d", ret);
		}
		return 0;
	}
	//注：312为例子中64位调用号，若为32位环境，可用前述的349
```
(执行这段程序可能只能看到了Return的Val,这时表示,你已经成功完成系统调用啦~但是没有好像系统调用函数没有输出啊?为什么呢?详情请看文章后面内容.)
####内核调试
这部分内容十分困难,每次修改源代码以后都要重新编译内核,虽然修改的部分少,但是编译还是很慢.用上多线程以后速度有所提升,但是还是不理想.我也没有研究有什么解决方案. 调试的话,也只能使用printk输出,采用最原始的调试方法.但是可以参考一下参考资料7,8.参考资料8提供了插入内核模块的方式测试单个模块文件
####Others
#####vim中的查找
命令模式下，按`/`，然后输入要查找的字符. `？`和 `/`的区别是，一个向前（下）找，一个向后（上）.更多内容请百度,或者看参考资料6
#####解决printk不从终端输出的问题:
######原因1:日志级别太低

```
　　日志级别一共有8个级别，printk的日志级别定义如下（在include/linux/kernel.h中）：

　　#define KERN_EMERG 0	/*紧急事件消息，系统崩溃之前提示，表示系统不可用*/

　　#define KERN_ALERT 1	/*报告消息，表示必须立即采取措施*/

　　#define KERN_CRIT 2		/*临界条件，通常涉及严重的硬件或软件操作失败*/

　　#define KERN_ERR 3		/*错误条件，驱动程序常用KERN_ERR来报告硬件的错误*/

　　#define KERN_WARNING 4	/*警告条件，对可能出现问题的情况进行警告*/

　　#define KERN_NOTICE 5	/*正常但又重要的条件，用于提醒*/

　　#define KERN_INFO 6		/*提示信息，如驱动程序启动时，打印硬件信息*/

　　#define KERN_DEBUG 7	/*调试级别的消息*/
```

用printk，内核会根据日志级别，可能把消息打印到当前控制台上，这个控制台通常是一个字符模式的终端、一个串口打印机或是一个并口打印机。这些消息正常输出的前提是──日志输出级别小于console_loglevel（在内核中数字越小优先级越高）。

　　没有指定日志级别的printk语句默认采用的级别是 DEFAULT_ MESSAGE_LOGLEVEL（这个默认级别一般为<4>,即与KERN_WARNING在一个级别上），其定义在linux26/kernel/printk.c中可以找到

```
	//可用下面的命令设置当前日志级别：
	# echo 8 > /proc/sys/kernel/printk
```
######原因2: klogd和syslogd守护进程阻止内核消息(具体内容不是很清楚)