# 总结
## The Shell
linux终端为shell的主要的文本接口
shell中可执行命令
（ls man mkdir touch rm cat）
可用管道将命令组合使用
## Vim
i进入编辑模式
:输入命令（w保存 q退出）
## 数据整理
常用命令 sed grep sort tail
## Git
### 基础
    git help <command>: 获取 git 命令的帮助信息
    git init: 创建一个新的 git 仓库，其数据会存放在一个名为 .git 的目录下
    git status: 显示当前的仓库状态
    git add <filename>: 添加文件到暂存区
    git commit: 创建一个新的提交
        如何编写 良好的提交信息!
        为何要 编写良好的提交信息
    git log: 显示历史日志
    git log --all --graph --decorate: 可视化历史记录（有向无环图）
    git diff <filename>: 显示与暂存区文件的差异
    git diff <revision> <filename>: 显示某个文件两个版本之间的差异
    git checkout <revision>: 更新 HEAD 和目前的分支
### 分支和合并
    git branch: 显示分支
    git branch <name>: 创建分支
    git checkout -b <name>: 创建分支并切换到该分支
        相当于 git branch <name>; git checkout <name>
    git merge <revision>: 合并到当前分支
    git mergetool: 使用工具来处理合并冲突
    git rebase: 将一系列补丁变基（rebase）为新的基线
### 远端操作
    git remote: 列出远端
    git remote add <name> <url>: 添加一个远端
    git push <remote> <local branch>:<remote branch>: 将对象传送至远端并更新远端引用
    git branch --set-upstream-to=<remote>/<remote branch>: 创建本地和远端分支的关联关系
    git fetch: 从远端获取对象/索引
    git pull: 相当于 git fetch; git merge
    git clone: 从远端下载仓库
### 撤销
    git commit --amend: 编辑提交的内容或信息
    git reset HEAD <file>: 恢复暂存的文件
    git checkout -- <file>: 丢弃修改
## 感想
    一门课程过后，对别人所云“从入门到放弃”深有体会。虽然我在很多方面不太理解，但收获颇丰，至少不是一个小白，不会报错都不看不搜就把拍照扔群里，不会再在Vim编辑器的使用方法中挣扎……
    我仍对后面的学习充满期待，毕竟兴趣从未消减。


