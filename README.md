# 内存马调试
## 0x00 动机

仓库主要分享一下调试内存马以来的成果：

主要是借鉴项目：

https://github.com/bitterzzZZ/MemoryShellLearn

https://github.com/birdhan/Memory

感谢这两位大佬！

## 0x01 Filter型内存马

![](https://github.com/NikolaGareth/MemoryShell/blob/master/img/addfilter.png)

## 0x02 Listener型内存马

![](https://github.com/NikolaGareth/MemoryShell/blob/master/img/addlistener.png)

## 0x03 更新三个linux可用的内存马
### 1.filter类型

+ 将filter.jsp文件放到tomcat根目录下，通过浏览器访问，可创建内存马。

+ 任意路径访问，添加参数cmd=whoami，即可。

### 2.servlet类型

+ 将servlet.jsp文件放到tomcat根目录下，通过浏览器访问，可创建内存马。

+ 访问/RockS?cmd=whoami。即可。

### 3.listener类型

+ 将listener.jsp文件放到tomcat根目录下，通过浏览器访问，可创建内存马。

+ 任意路径访问，添加参数cmd=whoami，即可。

### 4.tomcat.jsp

+ 提供内存马检测功能。