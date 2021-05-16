---
layout: page
title: Solution-课程概览与 shell
solution: true
---

1. 在 /tmp 下新建一个名为 missing 的文件夹。
    ![1.png]({{site.url}}/2020/solutions/images/1/1.png)
2. 用 man 查看程序 touch 的使用手册。  
    `man touch`
    ![2.png]({{site.url}}/2020/solutions/images/1/2.png)
 3. 用 touch 在 missing 文件夹中新建一个叫 semester 的文件。  
    `touch semester`
 4. 将以下内容一行一行地写入 semester 文件：     
    ```
    #!/bin/sh
    curl --head --silent https://missing.csail.mit.edu
    ```
    第一行可能有点棘手， `#` 在Bash中表示注释，而 `!` 即使被双引号（`"`）包裹也具有特殊的含义。  单引号（`'`）则不一样，此处利用这一点解决输入问题。更多信息请参考  [Bash quoting](https://www.gnu.org/software/bash/manual/html_node/Quoting.html)手册
    ![3.png]({{site.url}}/2020/solutions/images/1/3.png)
5. 尝试执行这个文件。例如，将该脚本的路径（`./semester`）输入到您的shell中并回车。如果程序无法执行，请使用 ls 命令来获取信息并理解其不能执行的原因。
    ![4.png]({{site.url}}/2020/solutions/images/1/4.png)
6. 查看 chmod 的手册(例如，使用 `man chmod` 命令)
    ![5.png]({{site.url}}/2020/solutions/images/1/5.png)
7. 使用 chmod 命令改变权限，使 `./semester` 能够成功执行，不要使用 sh semester 来执行该程序。您的 shell 是如何知晓这个文件需要使用 sh 来解析呢？更多信息请参考：[shebang](https://en.wikipedia.org/wiki/Shebang_(Unix))
    ![6.png]({{site.url}}/2020/solutions/images/1/6.png)
8. 使用 `|` 和 `>` ，将 semester 文件输出的最后更改日期信息，写入主目录下的 `last-modified.txt` 的文件中
    ![7.png]({{site.url}}/2020/solutions/images/1/7.png)
9. 写一段命令来从 /sys 中获取笔记本的电量信息，或者台式机 CPU 的温度。注意：macOS 并没有 sysfs，所以 Mac 用户可以跳过这一题。






