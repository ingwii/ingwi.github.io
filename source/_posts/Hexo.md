title: "Hexo"
date: 2015-03-21 20:48:42
tags: Hexo
categories: Computer Science
---
#####创建新的文章 ---通常, 使用下面命令创建时就创建一个新的Markdown文件:```    $ hexo new "a new article"```为文章添加 Tag、Category 属性,文章模版的属性信息如下：```    title: Hexo 搭建个人博客 · 进阶篇    # 文章显示标题    date: 2014-08-30 13:07:26         # 文章创建日期	tags: hexo                        # Tag 属性，如果多个 Tag 使用：[Tag 1, Tag 2 ...]    categories: hexo                  # Category 属性，多个时使用：[Category 1, ...]；默认是没有这个的，下面有介绍	--- ```
####ERROR Deployer not found: github
hexo 更新到3.0之后, /_config中的deploy的type: 

```	github需要改成git
```
然后执行

```	npm install hexo-deployer-git --save
``` 