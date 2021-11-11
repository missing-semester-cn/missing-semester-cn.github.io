### 回退版本：

#### 结果会使得历史修改的:

1: git reset (--soft/mixed(默认)/hard) [HEAD~n(回退到上n+1次提交的版本),ID]

加--hard参数会更改工作区内容

![reset](C:\Users\86187\Desktop\reset.png)

2:git rebase -i [HEAD~n(回退到上n+1次提交的版本)/ID]

作用相当于reset --hard

![rebase](C:\Users\86187\Desktop\rebase.png)

#### 结果不会使得历史修改的:

1:git revert [HEAD~n(回退到上n+1次提交的版本)/ID]

作用是	'重置'	该次版本的操作  结果相当于重写 会产生新的提交

![revert](C:\Users\86187\Desktop\revert.png)

2: git commit --amend

该操作的作用相当于	'补充'	你在目前版本库下的任何添加到暂存区的文件 都会	'添加到'	上一次提交的文件中  并且结果为重新提交上一次的提交

![amend](C:\Users\86187\Desktop\amend.png)