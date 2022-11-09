---
attachments: [1.jpg, 2.jpg, 3.jpg, 4.jpg, merge1.jpg, merge2.jpg, merge3.jpg, merge4.jpg, merge5.jpg, merge6.jpg, rebase1.jpg, rebase2.jpg, rebase3.jpg]
tags: [Import-15eb]
title: Kr3hy 's git_Doc
created: '2022-11-03T12:11:52.321Z'
modified: '2022-11-03T13:05:14.403Z'
---

## Kr3hy 's git_Doc

1. 若你已经修改了部分文件、并且将其中的一部分加入了暂存区，应该如何回退这些修改，恢复到修改前最后一次提交的状态？给出至少两种不同的方式
我使用了自己用于练习的空仓库 `test_Linux` 。
- 第一种方法：`git checkout [filename]`
	新建文件demo.txt，随便打几个字母。之后add,commit操作添加到暂存区。之后再在工作区对demo.txt进行修改（但是没有把此时的版本add到暂存区），此时可以使用git checkout demo.txt命令，让工作区的demo.txt回退到上一次commit的版本。
<div align='center'>
<img src="..\attachments\1.jpg" width="400" height="400" alt=" "/>
</div>
<p></p>

- 第二种方法：`git reset --hard [commit id]`
	依然使用demo.txt，我们随便删掉一行，add,commit到暂存区。之后使用git log，就可以得到commit的历史，上面有一个commit id，40位长的十六进制字符串。选择最后一个commit的it，复制（我这里是6f3382...）。之后我们再把工作区的demo.txt内容清空，之后使用git reset --hard 6f3382
	再次查看，文件内容恢复到上次提交的版本。
<div align='center'>
<img src="..\attachments\2.jpg" width="400" height="400" alt=" "/>
</div>
<p></p>
---

2. 若你已经提交了一个新版本，需要回退该版本，应该如何操作？分别给出不修改历史或修改历史的至少两种不同的方式
- 修改历史：`git reset HEAD~`
	新建一个demo2.txt，进行两次不同版本的add,commit，之后git log查看提交历史，再使用git reset HEAD~ ，最后一次的commit就会在暂存区被删除。

<div align='center'>
<img src="..\attachments\3.jpg" width="400" height="400" alt=" "/>
</div>
<p></p>

- 不修改历史：`git revert [commit id]`
	查询资料得知，git reset 将会修改提交历史。多人协作的仓库，如果已经把代码 push 到远程仓库之后，最好不要使用 git reset 来回退修改。此处使用git revert。把本地文件demo2.txt修改两次并进行两次commit之后（new 1st/new2nd）,git log查看commit id，之后复制new 2nd的commit id，进行一个git revert ba14b43。本地文件即可回到提交new 2nd这次commit之前的版本。
		<div align='center'>
<img src="..\attachments\4.jpg" width="400" height="400" alt=" "/>
</div>
<p></p>

---
	
3. 我们已经知道了合并分支可以使用 merge，但这不是唯一的方法，给出至少两种不同的合并分支的方式
- `rebase`
基本命令
```bash
git checkout branch_name_1 #切换到对应分支
git rebase branch_name_2  #进行一个base的re，具体看图
```
遵循不造论子的原则，用一些网上的图
<div align='center'>
<img src="..\attachments\rebase1.jpg" width="400" height="400" alt=" "/>
</div>

假设我们面对这种情况，此时如果使用 `git pull origin master` 

那么会变成下图这样，在我们的开发分支弄出一个集成版本。
<div align='center'>
<img src="..\attachments\rebase2.jpg" width="400" height="400" alt=" "/>
</div>

但如果想让自己的开发分支看起来没有merge过。那么

```bash
git checkout mywork
git rebase origin
```

<div align='center'>
<img src="..\attachments\rebase3.jpg" width="400" height="400" alt=" "/>
</div>
就会变成如图所示。

过程中如果遇到冲突，可以使用 `git status` 以及 `git add/commit` 去解决。（把冲突的内容修改后再次提交）

<p></p>
<p></p> 

- `merge`

  基本命令

```bash
git checkout branch_name #切换到对应分支
git merge branch_name #在当前分支与branch_name的分支合并
git branch -d branch_name #删除提到的分支
```

同上，没有自己去绘图（造轮子），从网上 copy了配图。
<div align='center'>
<img src="..\attachments\merge1.jpg" width="400" height="400" alt=" "/>
</div>
如图，git的提交结构类似上面这样。（类似于链表）
下面分为两种情况
<p></p> 

- 暂停master的迭代，直接切换到dev（开发分支）

<div align='center'>
<img src="..\attachments\merge2.jpg" width="400" height="400" alt=" "/>
</div>
由于在B2（master的最新版本）开启dev分支，所以dev一开始指向B2。这种情况下，分支呈现的结构是一条线。也就意味着，dev提交的过程，以及分支merge的时候，只需要进行指针右侧移动。如下图所示
<div align='center'>
<img src="..\attachments\merge3.jpg" width="400" height="400" alt=" "/>
</div>

<div align='center'>
<img src="..\attachments\merge4.jpg" width="400" height="400" alt=" "/>
</div>

- master迭代的同时，进行dev分支的提交

<div align='center'>
<img src="..\attachments\merge5.jpg" width="400" height="400" alt=" "/>
</div>

此时可以简单这样理解，master已经提交到了B4版本，而dev分支提交的最新版本是B3，形成一个类似branch的结构。
这里又分为两种情况。

1. B3/4两个版本修改的文件不是同一份或修改了同一份文件的不同部分

    这种情况下，一般不会发生合并冲突。

    merge此时要做的事情，就是建立一个三方合并。执行之后master指针再次移动到最新版B5。

    <div align='center'>
    <img src="..\attachments\merge6.jpg" width="400" height="400" alt=" "/>
    </div>

    合并完成，此时可以删除dev分支， `git branch -D dev` 。

2. B3/4两个版本修改了同一份文件的同一部分

    此时去merge是失败的，会产生冲突。

    使用 `git status` 查看那些冲突的文件。

    举例，如果有段这样的输出

    ```bash
    This is test-1.
    update test-1.
    add test-1.
    <<<<<<< HEAD
    test master.
    =======
    test dev.
    >>>>>>> dev
    ```

    其中 `=====` 分割的内容就是两个分支中test-1文件的不同之处。

    一种可操作的处理方式是在那个文件对应的位置把两个分支不同的内容取并集。

    在原文件 `test-1` 做如下修改

    ```bash
    test master
    test dev
    ```

    然后再 `add,commit` 这个test-1，此时merge可以成功执行。

