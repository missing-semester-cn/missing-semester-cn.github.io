---
layout: lecture
title: "版本控制与 Git"
description: >
  了解 Git 的数据模型以及如何使用 Git 进行版本控制和协作。
thumbnail: /static/assets/thumbnails/2026/lec5.png
date: 2026-01-16
ready: true
video:
  aspect: 56.25
  id: 9K8lB61dl3Y
---

版本控制系统（VCS）是用于跟踪源代码（或其他文件和文件夹集合）变更的工具。顾名思义，这些工具帮助维护变更历史；此外，它们还促进协作。
从逻辑上讲，VCS 通过一系列 _快照_ 来跟踪文件夹及其内容的变更，每个快照都封装了顶级目录内所有文件/文件夹的完整状态。VCS 还维护元数据，如谁创建了每个快照、与每个快照关联的消息等。

为什么版本控制有用？即使你独自工作，它也能让你查看项目的旧快照，记录为什么进行某些变更，在并行开发分支上工作，等等。当与他人协作时，它是查看其他人变更以及解决并发开发冲突的宝贵工具。

现代 VCS 还能让你轻松（且通常是自动地）回答以下问题：

- 谁编写了这个模块？
- 这个文件的这一行是什么时候编辑的？由谁编辑？为什么编辑？
- 在最近 1000 次修订中，某个单元测试是什么时候/为什么停止工作的？

虽然存在其他 VCS，但 **Git** 是版本控制的事实标准。
这幅 [XKCD 漫画](https://xkcd.com/1597/) 捕捉了 Git 的声誉：

![xkcd 1597](https://imgs.xkcd.com/comics/git.png)

由于 Git 的接口是一个有漏洞的抽象（leaky abstraction），自上而下学习 Git（从其接口/命令行界面开始）可能会导致很多困惑。
人们可能会记住一些命令并将它们视为魔法咒语，每当出现问题时就按照上面的漫画方法来处理。

虽然 Git 的界面 admittedly（诚然）很丑陋，但其底层设计和思想是优美的。丑陋的界面需要 _记忆_，而优美的设计可以被 _理解_。因此，我们采用自下而上的方式解释 Git，从它的数据模型开始，然后涵盖命令行界面。一旦理解了数据模型，就能更好地理解命令是如何操作底层数据模型的。

# Git 的数据模型

Git 的巧妙之处在于其精心设计的数据模型，它实现了版本控制的所有优良特性，如维护历史、支持分支和促进协作。

## 快照

Git 将某个顶级目录内的一组文件和文件夹的历史建模为一系列快照。在 Git 术语中，文件被称为"blob"，它只是一堆字节。目录被称为"tree"，它将名称映射到 blob 或 tree（因此目录可以包含其他目录）。快照是被跟踪的顶级 tree。例如，我们可能有如下 tree：

```
<root> (tree)
|
+- foo (tree)
|  |
|  + bar.txt (blob, contents = "hello world")
|
+- baz.txt (blob, contents = "git is wonderful")
```

顶级 tree 包含两个元素：一个 tree "foo"（它本身包含一个元素，blob "bar.txt"）和一个 blob "baz.txt"。

## 建模历史：关联快照

版本控制系统应该如何关联快照？一个简单的模型是线性历史。历史将是按时间顺序排列的快照列表。出于许多原因，Git 不使用这样简单的模型。

在 Git 中，历史是有向无环图（DAG）的快照。这听起来可能像是一个花哨的数学术语，但不要被吓到。这仅仅意味着 Git 中的每个快照都指向一组"父"快照，即先于它的快照。这是一组父而不是单个父（如线性历史中的情况），因为快照可能源自多个父，例如由于合并（merging）两个并行开发分支。

Git 将这些快照称为"提交"（commits）。可视化提交历史可能看起来像这样：

```
o <-- o <-- o <-- o
            ^
             \
              --- o <-- o
```

在上面的 ASCII 图中，`o` 对应于单个提交（快照）。箭头指向每个提交的父（这是"在之前"的关系，而不是"在之后"）。在第三次提交后，历史分成两个独立的分支。这可能对应于例如两个独立的功能并行开发，彼此独立。将来，这些分支可以合并以创建一个包含这两个功能的新快照，产生一个新的历史，如下所示，新创建的合并提交以粗体显示：

<pre class="highlight">
<code>
o <-- o <-- o <-- o <---- <strong>o</strong>
            ^            /
             \          v
              --- o <-- o
</code>
</pre>

Git 中的提交是不可变的。然而，这并不意味着错误无法纠正；只是对提交历史的"编辑"实际上是创建全新的提交，而引用（见下文）会被更新以指向新的提交。

## 数据模型，以伪代码表示

将 Git 的数据模型用伪代码写下来可能是有启发性的：

```
// 文件是一堆字节
type blob = array<byte>

// 目录包含命名文件和目录
type tree = map<string, tree | blob>

// 提交包含父节点、元数据和顶级 tree
type commit = struct {
    parents: array<commit>
    author: string
    message: string
    snapshot: tree
}
```

这是一个干净、简单的历史模型。

## 对象和内容寻址

"对象"是 blob、tree 或 commit：

```
type object = blob | tree | commit
```

在 Git 的数据存储中，所有对象都通过其 [SHA-1
哈希](https://en.wikipedia.org/wiki/SHA-1) 进行内容寻址。

```
objects = map<string, object>

def store(object):
    id = sha1(object)
    objects[id] = object

def load(id):
    return objects[id]
```

Blob、tree 和 commit 以这种方式统一：它们都是对象。当它们引用其他对象时，它们实际上并不在其磁盘表示中 _包含_ 它们，而是通过哈希引用它们。

例如，上面示例目录结构的 tree（使用 `git cat-file -p 698281bc680d1995c5f4caaf3359721a5a58d48d` 可视化），看起来像这样：

```
100644 blob 4448adbf7ecd394f42ae135bbeed9676e894af85    baz.txt
040000 tree c68d233a33c5c06e0340e4c224f0afca87c8ce87    foo
```

Tree 本身包含指向其内容的指针，`baz.txt`（一个 blob）和 `foo`（一个 tree）。如果我们查看由对应于 baz.txt 的哈希寻址的内容，使用 `git cat-file -p 4448adbf7ecd394f42ae135bbeed9676e894af85`，我们得到以下内容：

```
git is wonderful
```

## 引用

现在，所有快照都可以通过其 SHA-1 哈希来识别。这很不方便，因为人类不善于记住 40 个十六进制字符的字符串。

Git 对这个问题的解决方案是为 SHA-1 哈希提供人类可读的名称，称为"引用"。引用是指向提交的指针。与不可变的对象不同，引用是可变的（可以更新以指向新的提交）。
例如，`master` 引用通常指向开发主分支中的最新提交。

```
references = map<string, string>

def update_reference(name, id):
    references[name] = id

def read_reference(name):
    return references[name]

def load_reference(name_or_id):
    if name_or_id in references:
        return load(references[name_or_id])
    else:
        return load(name_or_id)
```

有了这些，Git 可以使用人类可读的名称如"master"来引用历史中的特定快照，而不是长长的十六进制字符串。

一个细节是，我们通常需要知道历史中"我们当前在哪里"，这样当我们创建新快照时，我们就知道它相对于什么（我们如何设置提交的 `parents` 字段）。在 Git 中，那个"我们当前在哪里"是一个称为 "HEAD" 的特殊引用。

## 仓库

最后，我们可以定义什么是 Git _仓库_：它是数据 `objects` 和 `references`。

在磁盘上，Git 存储的所有内容都是对象和引用：这就是 Git 数据模型的全部。所有 `git` 命令都映射到通过添加对象和添加/更新引用来对提交 DAG 进行某种操作。

每当你输入任何命令时，想想该命令对底层图数据结构进行了什么操作。反之，如果你想对提交 DAG 进行特定类型的更改，例如"丢弃未提交的更改并使 'master' 引用指向提交 `5d83f9e`"，可能有一个命令可以做到这一点（例如在这种情况下，`git checkout master; git reset --hard 5d83f9e`）。

# 暂存区

这是另一个与数据模型正交的概念，但它是创建提交接口的一部分。

你可能想象的一种实现上述快照的方式是有一个"创建快照"命令，它基于工作目录的 _当前状态_ 创建新快照。一些版本控制工具是这样工作的，但 Git 不是。我们想要干净的快照，从当前状态创建快照并不总是理想的。例如，想象一个场景，你已经实现了两个独立的功能，你想创建两个独立的提交，第一个引入第一个功能，下一个引入第二个功能。或者想象一个场景，你在代码中到处添加了调试打印语句，以及一个错误修复；你想提交错误修复但丢弃所有打印语句。

Git 通过允许你通过称为"暂存区"（staging area）的机制指定哪些修改应包含在下一个快照中来适应这种场景。

# Git 命令行接口

为避免重复信息，我们不会在这些讲义中详细解释以下命令。查看强烈推荐的 [Pro Git](https://git-scm.com/book/en/v2) 获取更多信息，或观看讲座视频。

## 基础

- `git help <command>`: 获取 git 命令的帮助
- `git init`: 创建新的 git 仓库，数据存储在 `.git` 目录中
- `git status`: 告诉你发生了什么
- `git add <filename>`: 将文件添加到暂存区
- `git commit`: 创建新提交
    - 编写[良好的提交信息](https://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html)！
    - 更多编写[良好提交信息](https://chris.beams.io/posts/git-commit/)的理由！
- `git log`: 显示扁平化的历史日志
- `git log --all --graph --decorate`: 将历史可视化为 DAG
- `git diff <filename>`: 显示相对于暂存区的更改
- `git diff <revision> <filename>`: 显示快照之间文件的差异
- `git checkout <revision>`: 更新 HEAD（如果检出分支则更新当前分支）

## 分支和合并

- `git branch`: 显示分支
- `git branch <name>`: 创建分支
- `git switch <name>`: 切换到分支
- `git checkout -b <name>`: 创建分支并切换到它
    - 等同于 `git branch <name>; git switch <name>`
- `git merge <revision>`: 合并到当前分支
- `git mergetool`: 使用高级工具帮助解决合并冲突
- `git rebase`: 将一组补丁变基到新基础

## 远程

- `git remote`: 列出远程
- `git remote add <name> <url>`: 添加远程
- `git push <remote> <local branch>:<remote branch>`: 发送对象到远程，并更新远程引用
- `git branch --set-upstream-to=<remote>/<remote branch>`: 设置本地分支与远程分支之间的对应关系
- `git fetch`: 从远程检索对象/引用
- `git pull`: 等同于 `git fetch; git merge`
- `git clone`: 从远程下载仓库

## 撤销

- `git commit --amend`: 编辑提交的内容/消息
- `git reset <file>`: 取消暂存文件
- `git restore`: 丢弃更改

# 高级 Git

- `git config`: Git 是[高度可定制的](https://git-scm.com/docs/git-config)
- `git clone --depth=1`: 浅克隆，不包含完整版本历史
- `git add -p`: 交互式暂存
- `git rebase -i`: 交互式变基
- `git blame`: 显示谁最后编辑了哪一行
- `git stash`: 临时移除对工作目录的修改
- `git bisect`: 二分搜索历史（例如用于回归测试）
- `git revert`: 创建新提交以撤销先前提交的效果
- `git worktree`: 同时检出多个分支
- `.gitignore`: [指定](https://git-scm.com/docs/gitignore)故意未跟踪的文件以忽略

# 杂项

- **GUI**：有许多适用于 Git 的 [GUI 客户端](https://git-scm.com/downloads/guis)。我们个人不使用它们，而是使用命令行界面。
- **Shell 集成**：在 shell 提示符中包含 Git 状态非常方便（[zsh](https://github.com/olivierverdier/zsh-git-prompt)、[bash](https://github.com/magicmonty/bash-git-prompt)）。通常包含在 [Oh My Zsh](https://github.com/ohmyzsh/ohmyzsh) 等框架中。
- **编辑器集成**：与上面类似，有许多方便的集成功能。[fugitive.vim](https://github.com/tpope/vim-fugitive) 是 Vim 的标准集成工具。
- **工作流**：我们教你数据模型和一些基本命令；我们没有告诉你在大型项目中应该遵循什么实践（有[许多](https://nvie.com/posts/a-successful-git-branching-model/)[不同的](https://www.endoflineblog.com/gitflow-considered-harmful)[方法](https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow)）。
- **GitHub**：Git 不是 GitHub。GitHub 有一种特定的向其他项目贡献代码的方式，称为 [pull requests](https://help.github.com/en/github/collaborating-with-issues-and-pull-requests/about-pull-requests)。
- **其他 Git 提供商**：GitHub 并不特殊：有许多 Git 仓库托管服务，如 [GitLab](https://about.gitlab.com/) 和 [BitBucket](https://bitbucket.org/)。

# 资源

- [Pro Git](https://git-scm.com/book/en/v2) 是**强烈推荐阅读的**。既然你已经理解了数据模型，阅读第 1-5 章应该能教会你熟练使用 Git 所需的大部分知识。后面的章节有一些有趣的高级材料。
- [Oh Shit, Git!?!](https://ohshitgit.com/) 是一份关于如何从一些常见 Git 错误中恢复的简短指南。
- [Git for Computer Scientists](https://eagain.net/articles/git-for-computer-scientists/) 是对 Git 数据模型的简短解释，比这些讲义有更少的伪代码和更多精美的图表。
- [Git from the Bottom Up](https://jwiegley.github.io/git-from-the-bottom-up/) 是对 Git 实现细节的详细解释，不仅仅是数据模型，适合好奇者阅读。
- [How to explain git in simple words](https://smusamashah.github.io/blog/2017/10/14/explain-git-in-simple-words)
- [Learn Git Branching](https://learngitbranching.js.org/) 是一个基于浏览器的游戏，教你 Git。

# 练习

1. 如果你没有任何 Git 经验，尝试阅读 [Pro Git](https://git-scm.com/book/en/v2) 的前几章或学习 [Learn Git Branching](https://learngitbranching.js.org/) 等教程。在学习过程中，将 Git 命令与数据模型联系起来。
1. 克隆[课程网站仓库](https://github.com/missing-semester/missing-semester)。
    1. 通过将其可视化为图来探索版本历史。
    1. 谁是最后一个修改 `README.md` 的人？（提示：使用带参数的 `git log`）。
    1. 与 `_config.yml` 的 `collections:` 行最后一次修改相关的提交消息是什么？（提示：使用 `git blame` 和 `git show`）。
1. 学习 Git 时一个常见的错误是提交不应由 Git 管理的大文件或添加敏感信息。尝试向仓库添加一个文件，进行一些提交，然后从 _历史_（不仅仅是最新提交）中删除该文件。你可能想查看[这个](https://help.github.com/articles/removing-sensitive-data-from-a-repository/)。
1. 从 GitHub 克隆一些仓库，并修改其中一个现有文件。当你执行 `git stash` 时会发生什么？运行 `git log --all --oneline` 时你看到什么？运行 `git stash pop` 以撤销你用 `git stash` 所做的操作。在什么场景下这可能有用？
1. 与许多命令行工具一样，Git 提供了一个配置文件（或 dotfile）称为 `~/.gitconfig`。在 `~/.gitconfig` 中创建一个别名，这样当你运行 `git graph` 时，你会得到 `git log --all --graph --decorate --oneline` 的输出。你可以通过直接[编辑](https://git-scm.com/docs/git-config#Documentation/git-config.txt-alias) `~/.gitconfig` 文件，或使用 `git config` 命令添加别名。有关 git 别名的信息可以在[这里](https://git-scm.com/book/en/v2/Git-Basics-Git-Aliases)找到。
1. 运行 `git config --global core.excludesfile ~/.gitignore_global` 后，你可以在 `~/.gitignore_global` 中定义全局忽略模式。这设置了 Git 将使用的全局忽略文件的位置，但你仍然需要手动在该路径创建文件。设置你的全局 gitignore 文件以忽略操作系统特定或编辑器特定的临时文件，如 `.DS_Store`。
1. Fork [课程网站仓库](https://github.com/missing-semester/missing-semester)，找到一个拼写错误或其他你可以改进的地方，并在 GitHub 上提交 pull request（你可能想查看[这个](https://github.com/firstcontributions/first-contributions)）。请只提交有用的 PR（请不要发送垃圾信息！）。如果你找不到可以改进的地方，可以跳过这个练习。
1. 通过模拟协作场景练习解决合并冲突：
    1. 使用 `git init` 创建新仓库并创建一个名为 `recipe.txt` 的文件，包含几行内容（例如，一个简单的食谱）。
    1. 提交它，然后创建两个分支：`git branch salty` 和 `git branch sweet`。
    1. 在 `salty` 分支中，修改一行（例如，将 "1 cup sugar" 改为 "1 cup salt"）并提交。
    1. 在 `sweet` 分支中，以不同的方式修改同一行（例如，将 "1 cup sugar" 改为 "2 cups sugar"）并提交。
    1. 现在切换到 `master` 并尝试 `git merge salty`，然后 `git merge sweet`。会发生什么？查看 `recipe.txt` 的内容 - `<<<<<<<`、`=======` 和 `>>>>>>>` 标记是什么意思？
    1. 通过编辑文件以保留你想要的内容、移除冲突标记并使用 `git add` 和 `git commit`（或 `git merge --continue`）完成合并来解决冲突。或者，尝试使用 `git mergetool` 使用图形或终端合并工具解决冲突。
    1. 使用 `git log --graph --oneline` 可视化你刚刚创建的合并历史。
