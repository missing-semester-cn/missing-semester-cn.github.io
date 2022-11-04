# 学习总结

## shell

### 部分命令

1. `date`：打印当前的日期和时间。

2. `echo`：参数打印。   例：`echo`  “hello world”

3. `pwd`：打印当前工作目录的路径。

4. `cd`：切换目录，后加路径。 例：`cd`  ./home

5. `ls`：查看指定目录下包含哪些文件

6. `--help`：打印帮助信息，以便了解有哪些可用的标记或选项。格式为命令 +  `--help`。例：`ls` --help

7. `mv`：用于重命名或移动文件。

8. `cp`：拷贝文件。

9. `mkdir`：新建文件夹。

10. `tee`：写入文件。

11. `chmod`：改变文件的权限。修改（`w`），例如，添加或删除文件夹中的文件。可执行（`x`），为了进入某个文件夹或执行某个文件。读权限（`r`），列出文件或文件夹所包含的内容。

12. `touch`：新建文件。格式为touch + 文件名。

13. `grep`：筛选工具。例：`grep`  ‘hello’，筛选所有包含”hello“的行。还有很多选项可以通过`man`或`--help`获取。

14. `^Z`：暂停进程。`fg`：在前台继续进程。`bg`：在后台继续进程。

15. `sed`：一个基于文本编辑器ed构建的”流编辑器” 。格式：`sed` + 操作命令+正则表达式。例：

    ```shell
    sed 's/.*from//'	# 将from及其之前的内容替换为空白
    ```

    *注意：在`sed`中不是直接操作文件的内容，而是操作文件的拷贝。*

16. `journalctl`：打印系统日志。

### 重定向

`< file`和` > file`。这两个命令可以将程序的输入输出流分别重定向到文件。

`>>`： 来向一个文件追加内容。

*注意：`>>` 和 `>`不同，前者为追加，后者会将要输入的内容覆盖到之前的文件中*

`|`操作符：将一个程序的输出和另外一个程序的输入连接起来

```shell
echo hello | tee hello.txt
```

将echo的输入“hello”连接到tee的输入中，将“hello”写入文件hello.txt

## Vim

`vimtutor`：Vim自带的教程，大部分操作都可以通过`vimtutor`学习。

## shell脚本

### 设置解释器

```shell
#!/usr/bin/env bash
#!/bin/bash
#!/usr/bin/env python
#!/bin/python
```

### 一些变量

- `$0`：脚本名
- `$1` 到 `$9`：脚本的参数。 `$1` 是第一个参数，依此类推。
- `$@`：所有参数
- `$#`：参数个数
- `$?`：前一个命令的返回值
- `$$`：当前脚本的进程识别码
- `!!`：完整的上一条命令，包括参数。常见应用：当你因为权限不足执行命令失败时，可以使用 `sudo !!`再尝试一次。
- `$_`：上一条命令的最后一个参数。如果你正在使用的是交互式 shell，你可以通过按下 `Esc` 之后键入 . 来获取这个值。

## 正则表达式

- `.`： 除换行符之外的”任意单个字符”
- `*` ：匹配前面字符零次或多次
- `+` ：匹配前面字符一次或多次
- `[abc]` ：匹配 `a`, `b` 和 `c` 中的任意一个
- `(RX1|RX2)`： 任何能够匹配`RX1` 或 `RX2`的结果
- `^` ：行首
- `$` ：行尾

## Git

### Git的部分命令

### 基础

1. `git help <command>`: 获取 git 命令的帮助信息。
2. `git init`: 创建一个新的 git 仓库，其数据会存放在一个名为 .git 的目录下。
3. `git status`: 显示当前的仓库状态。
4. `git add <filename>`: 添加文件到暂存区。
5. `git commit`: 创建一个新的提交。
6. `git log`: 显示历史日志。
7. `git log --all --graph --decorate`: 可视化历史记录（有向无环图）。
8. `git diff <filename>`: 显示与暂存区文件的差异。
9. `git diff <revision> <filename>`: 显示某个文件两个版本之间的差异。
10. `git checkout <revision>`: 更新 HEAD 和目前的分支。

### 分支和合并

1. `git branch`: 显示分支。

2. `git branch <name>`: 创建分支。

3. `git checkout -b <name>`: 创建分支并切换到该分支。

   相当于` git branch <name>`;

   ​		 `git checkout <name>`

4. `git merge <revision>`: 合并到当前分支。

5. `git mergetool`: 使用工具来处理合并冲突。

### 远程操作

1. `git remote`: 列出远端
2. `git remote add <name> <url>`: 添加一个远端
3. `git push <remote> <local branch>:<remote branch>`: 将对象传送至远端并更新远端引用
4. `git branch --set-upstream-to=<remote>/<remote branch>`: 创建本地和远端分支的关联关系
5. `git fetch`: 从远端获取对象/索引
6. `git pull`: 相当于 `git fetch`; `git merge`
7. `git clone`: 从远端下载仓库

### 撤销

1. `git commit --amend`: 编辑提交的内容或信息
2. `git reset HEAD <file>`: 恢复暂存的文件
3. `git checkout -- <file>`: 丢弃修改
4. `git restore`: git2.32版本后取代git reset 进行许多撤销操作