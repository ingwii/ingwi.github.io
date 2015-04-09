#!/bin/bash
#用来发布我的博客. 
#1.发布博客到master分支
#2.将源文件备份到source分支
echo "发布一个正式版本会更改您git中的两个分支,会更新网站和source备份文件."
echo "你确定要发布吗?(y/n):"

function process(){
	hexo clean
	hexo generate
	hexo deploy
	sleep 1
	git add --all
	git commit -m -a
	git push origin source
}

read flag
if [ "y" == $flag ];then
	process
elif [ "n" == $flag ];then
	echo Bye~	
else 
	echo Please input 'y' or 'n';
	./$0
fi


