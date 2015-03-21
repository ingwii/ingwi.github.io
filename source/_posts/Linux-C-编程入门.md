title: "Linux C 编程入门"
date: 2015-03-21 20:36:00
tags: [Linux, C]
categories: Computer Science
---
#C_Linux编程

##一、linux程序开发环境
###1. linux开发环境的构成
	1. 编辑器： vi	//linux/unix上都有的编辑器，语法规则相似。
	2. 编译器： gnu c/c++ (gcc) 
	3. 调试器： gdb
	4. 函数库： glibc
	5. 系统头文件：glibc_header
	//6.linux图形界面：GNOME/KDE
	//7.IDE(集成开发环境)：Kylix,Kdevelop,RHIDE

###GCC编译器
1. `linux command`:
		
		＃ gcc -o helloexcute hello.c	// 编译hello.c生成可执行文件helloexcute
		＃ ./hello					//执行hello执行文件
2. 参数：   
		
		-o		//要求编译器生成可执行文件 
		-c		//要求编译器输出目标代码，不必生成可执行文件
		-g		//要求编译器提供进行调试的信息->gdb调试时需要使用
		
###GDB调试器
1. 生成可调式的执行文件:
		
		# gcc -g -o testrun *.c		//生成可调试的执行文件
		
		
###Glibc / Glibc_header

1. glibc的两种安装方式
	1. 安装成测试用的函数库
			在编译时用不同的选项来使用新的函数库
	2. 安装成主要的c函数库
			所有编译程序均调用的函数库
2. gblibc时提供系统跳用饿基本函数的C库
3. 利用rpm包(redhatLinux)快速安装c环境(具体包名见视频：2－01 40min)
4. `linux command`

		＃ ls /lib/libc-*	//查看glibc的版本
		＃ gcc --version		//查看gcc版本号
5. 开发流程：
	1. 使用vi等编辑器编写源程序。
	2. 保存为*.c
	3. 使用gcc编译成二进制可执行文件
	4. ＃ ./a.out  执行
	5. 有问题则用gdb进行调试

###Linux基础知识
1. `linux command －－关机`
		
		poweroff
		shutdown -h now 	//关机，推荐
		shutdown -r now		//重启，推荐
		reboot				//快速重启，跳过sync(同步)过程
		init 0				//关机
		init 6				//重启
		halt				//系统停机
2. linux系统结构  
	硬件 － Kernel(驱动) － Shell(命令解释) － 外层应用程序	(内层 到 外层)
3. linux目录结构
	1. 目录级别
		
			1.	2.	3.	4.
			/
				/bin
				/usr
					/bin
					/local
					/src
					/rc.d
						/rc3.d
						/rc5.d
						/init.d
				/sbin
				/etc			//配置文件文件的目录
				/tmp			//临时文件
				/lib			//库文件
				/var
					/named
					/httpd
					/ftp
						/bin
						/etc
						/pub
				/home
				/opt			//安装大的应用
	2. /bin /sbin /usr/bin /usr/sbin /usr/local/bin //存放命令的目录,应用的可执行文件
	3. /boot	//内核及其他系统启动需要的文件
	4. /root	//超级用户主目录
	5. /lost+found	//系统恢复的文件
	6. /dev		//设备目录
	7. `linux command`
	
			cd ..	//返回上级目录
			ls -l 查看设备类型，看看首字符
			b -- block 设备    
			c -- character 设备

	8. /etc 配置文件所在的目录
		1. 启动引导程序
			
				/etc/lilo.conf
				/etc/grub.conf
		2. 启动控制模式
				
				/etc/inittab	// 图形 or 文本登录
		3. 文件配置系统
			
				/etc/fstab
		4. 修改环境变量
		
				/etc/profile
		5. ... ...
	9. /etc/inittab
	
			# init 3	//以文本方式登录linux
			# init 5	//以图形界面方式登录linux
			# init 1	//or # init single 单用户模式:不允许其他用户访问linux
	10. /home		
		1. /home/username	//用户主目录
		2. `linux command`
		
				# useradd username
				# passwd username
		3. /etc/passwd		//普通用户能读,系统能识别的用户清单
		4. /etc/shadow 		//超级用户才能读
	11. /mnt 装载目录
		1. 装/卸载光驱
			
				mount -t 文件类型 设备文件 挂载目录
				
				# mount -e iso9600 /dev/cdrom /mnt/cdrom
				# umount /mnt/cdrom
4. `linux command`

		man ls		//查看ls的指令信息
		info ls		//作用同上
		cd /		//跳转根目录
		cd ..		//..代替上级目录，跳转到上级目录
		pwd			//查看当前目录的当前绝对路径
		uname -a	//linux版本查看
		clear		//清屏
		fdisk -l	//查看磁盘分区情况 
		df -h		//磁盘使用情况
		du -sh		//查看当前目录磁盘使用情况 
		fsck		//修复模式下 修复磁盘
		find /etc -name lilo.conf	//etc目录下递归按照文件名查找文件lilo.conf
		find 起始目录 -size 文件名
		find /etc *.conf	//*，通配符。 查找所有.conf结尾的文件
		logout 		// 退出登录
		mkdir newfilename	//创建目录
		rmdir		//删除空目录
		rm -r -f	//删除目录及其下面的所有文件
		more filename	//查看文件内容
		less filename	//查看文件内容
		cat	filename	//查看文件内容，接受用户的标准输入并原样输出
		cat < filename	// '<' or '>' 重定向符号(可理解为输入输出流)
		ls -l 2> a.txt	//有错误就输出到a.txt
		ls -i	//索引节点，索引号
		mv ［当前路径文件名/绝对路径文件名］ ［拷去路径文件夹/绝对路径文件夹］ 
		cp ［当前路径文件名/绝对路径文件名］ ［拷去路径文件夹/绝对路径文件夹］ 
		diff  ［当前路径文件名/绝对路径文件名］ ［拷去路径文件名/绝对路径文件名］//比较不同
		cmp	 ［当前路径文件名/绝对路径文件名］ ［拷去路径文件夹/绝对路径文件夹］ //比较相同 
		chmod u+x a.out	//修改权限,添加拥有者用户对于该文件的x(执行)权限
		chmod u-x a.out	//修改权限,减去拥有者用户x(执行)权限
		chmod u=x a.out	//修改权限,拥有者用户只拥有x(执行)权限
			u:拥有者用户 g:主用户 o:其他用户 a:所有用户
		chmod 751 a.out	//三个十进制数转换成二进制分别对应rwx的开关
		chmod 777 a.out	//三个类型的用户所有权限全开
		ln [路径] [路径/文件名]	//硬超级链接，不允许硬链接到目录，文件夹
		ln -s [路径] ［路径/文件名，目录]	//软超级链接
		ifconfig
		netstat		//网络状况
		tar -cvf [包名字].tar [路径]	//打包路径下目录或文件
		tar -xvf [包名字].tar	//解包文件
		tar -tvf [包名字].tar	//查看包文件
		tar -czvf [包名字].tar.gz [路径]	//压缩打包文件
		tar -xzvf [包名字].tar.gz	//解压缩包文件
		userdel -r isername		//删除用户，－r并删除用户主目录
		usermod -i WII2 WII1	//将WII1更名为WII2
		group wii2	//删除用户组
		su username		//切换用户
		sudo -s	//获得root权限
		mv test test_rename		//重命名,将文件改名转换到当前路径