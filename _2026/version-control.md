---
layout: lecture
title: "版本控制与 Git"
description: >
  Learn Git's data model and how to use Git for version control and collaboration.
thumbnail: /static/assets/thumbnails/2026/lec5.png
date: 2026-01-16
ready: true
video:
  aspect: 56.25
  id: 9K8lB61dl3Y
---

**版本控制系统（Version Control Systems, VCSs）**是一类用于记录和管理源代码（或其他文件和文件夹）变更的工具。顾名思义，这些工具可以维护（代码等）修改历史；更重要的是，它们有利于开发人员/团体间的协作。从原理上讲，VCSs 用一系列**快照（snapshots）**来追踪文件夹和其中内容的修改。每个快照包含顶级目录中文件/文件夹的完整状态。VCSs 还能维护元数据，例如快照的创建者、快照的相关信息等。

> 译者注：
[1] [快照](https://en.wikipedia.org/wiki/Snapshot_(computer_storage))，是计算机系统某个时间点的状态。
[2] [元数据](https://en.wikipedia.org/wiki/Metadata)，简要地讲是一群描述数据的各类属性的信息。

为什么版本控制如此有用？即使你独自工作，VCSs 也能让你看到项目的曾经的快照，记录某处改动的原因，支持并行分支（branch）的开发等。与他人合作时，它更是一个有价值的工具，您可以查看到其他合作者对代码的改动，也能解决并行开发时的冲突。

现代版本控制系统可以轻松地（通常是自动地）回答您的一些问题，例如：

- 这个模块是谁写的？
- 特定的文件中某一行是谁，在什么时间，处于何种原因编辑的？
- 在过去的 1000 个版本中，在哪一个版本，什么原因让某个特定的测试单元丧失功能/有 bug ？

尽管有其他 VCSs，**Git** 仍是版本控制领域的业界龙头。这张[XKCD 漫画](https://xkcd.com/1597/)体现了 Git 的名气。

![xkcd 1597](https://imgs.xkcd.com/comics/git.png)

图中的英文意为：
```
- 这是 Git 。它通过一个优美的分布式图论树模型记录项目上的协作。
- 酷。我们怎么用它呢？
- 不知道。只需要记住这些 Shell 命令并输入它们来同步。
  如果你遇到错误，将你的工作保存到其他地方，删除项目，再下载一份新的。
```

> 译者注：[XKCD Comic](https://xkcd.com/)是由美国作家 Randall Munroe 发表的线上漫画网站。这张漫画的名称就为 Git 。

与 Git 的交互方式属于“抽象泄露”（leaky abstraction），如果采用自上而下（即从命令行接口入手）的方式来学习 Git，往往会让人感到困惑。你或许能死记硬背下几条命令，把它们当作某种“咒语”来使用，一旦遇到问题，就只能照着上面那幅漫画里的做法去“解决”。

虽然 Git 的接口确实不够美观，但它底层的设计与理念却非常精巧。糟糕的接口只能靠“死记硬背”，而精妙的设计则可以被“理解”。因此，我们选择采用自下而上的方式来讲解 Git：先从数据模型（data model）讲起，随后再学习命令行如何使用。一旦掌握了数据模型，你就能更好地理解各项命令究竟是如何操作底层数据模型的。

> 译者注：[抽象泄露](https://en.wikipedia.org/wiki/Leaky_abstraction)，是知名软件工程师 Joel Spolsky 在 2002 年提出的概念，所有的非平凡的抽象或多或少是有漏洞的，原话是 “All non-trivial abstractions, to some degree, are leaky”。抽象（Abstraction），你可以理解成把复杂的代码/理念隐藏起来，只需要使用提供的接口就好了。假如你在学习 Git 的时候，遇到了一些诸如不允许提交（commit）或合并（merge）之类的报错信息，你不得不学习更多关于Git的知识，这就是一种抽象泄露的示例。

# Git 的数据模型

Git 的精妙之处在于其构思缜密的数据模型，它实现了版本控制的各项功能，例如保存历史记录、支持分支以及可协作性。

## 快照（snapshot）

Git 将某个顶层目录内一组文件和文件夹的历史记录，建模为一系列“快照”。在 Git 的术语中，文件被称为“blob”（存储对象/数据对象），本质上就是一串字节（byte）；目录/文件夹被称为“树”（tree），它负责将名称映射到 blob 或树上（这样文件夹就可以包含其他子文件夹）。快照就是被记录的顶层树。例如，我们可能会有如下所示的一棵树：

> 译者注：译者认为没有足够简洁且准确的中文来表达blob，也许“数据对象”也不能让您满意，所以下文中仍使用原文。这一词的来源是Jim Starkey 在 Digital Equipment Corporation（迪吉多公司）用来指代不透明的数据实体。更多的关于blob的信息，您可以查看[blob storage](https://en.wikipedia.org/wiki/Object_storage)

```
<root> (tree)
|
+- foo (tree)
|  |
|  + bar.txt (blob, contents = "hello world")
|
+- baz.txt (blob, contents = "git is wonderful")
```

顶层树包含两个元素，一个名为 foo 的树（它自己包含一个元素，一个 blob 文件名为“ bar.txt ”）和一个 blob 文件名为“ baz.txt ”。

## 版本历史建模：关联快照（快照流）

版本控制系统应如何关联各个快照？一种简单的模型是线性历史——即按时间顺序排列的快照列表。出于多种原因，Git 并没有采用这种简单的模型。

在 Git 中，版本历史表现为快照构成的“有向无环图”（Directed Acyclic Graph，**DAG**）。这个术语听起来可能有些深奥，但不必担心，其实很简单：Git 中的每个快照都指向一组“父快照”（parents）（即在该快照上一级的所有快照）。之所以是“一组”父快照（而非线性历史中单一的父快照），是因为某个快照可能源自多个父快照——例如，在合并（merge）两条并行开发的分支时，就会出现这种情况。

Git 将这些快照称为“提交”（commit）。提交历史的可视化呈现大致如下所示：

```
o <-- o <-- o <-- o
            ^
             \
              --- o <-- o
```

在上方的 ASCII 图中，每个 `o` 代表一个提交（即快照）。箭头指向各提交的父提交（这表示“先于”关系，而非“后于”关系）。在第三次提交之后，历史分叉为两条独立的分支。这可能对应于并行开发且相互独立的两个功能。未来，这些分支可以合并，生成一个包含这两个功能的新快照；由此形成的新历史如下所示（其中新创建的合并提交以粗体标出）：

<pre class="highlight">
<code>
o <-- o <-- o <-- o <---- <strong>o</strong>
            ^            /
             \          v
              --- o <-- o
</code>
</pre>

Git 中的提交是不可变的数据结构。但这并不意味着无法修正错误；事实上，对提交历史进行的“编辑”操作，本质上是创建了全新的提交，而引用（详见下文）则会随之更新，指向这些新的提交。（之前的记录会被一直保存，而不能更改，仅可以增加。译者按）

## 数据模型：伪代码（pseudocode）

若能以伪代码形式呈现 Git 的数据模型，或许会很有启发：

```
// 一个文件是一串字节
type blob = array<byte>

// 一个目录是一个数据结构的映射，包含名称和文件或目录
type tree = map<string, tree | blob>

// 一次提交有父提交、元数据和顶层树
type commit = struct {
    parents: array<commit>
    author: string
    message: string
    snapshot: tree
}
```

这是清楚的、简单的历史模型。

> 译者注：一般口语或在工作中，当我们提及提交/commit 的时候，指的是 DAG 的图像中的某一个“圆圈”；而当我们提到快照/snapshot 的时候，我们指的是顶层树。

## 对象（object）与 内容寻址（content-addressing）

一个“对象”可以是一个 blog 或一个树或一次提交：

```
type object = blob | tree | commit
```

在 Git 的数据存储中，所有对象都通过[SHA-1 hash](https://en.wikipedia.org/wiki/SHA-1)其进行内容寻址。

```
objects = map<string, object>

// 存储对象的过程是先计算id，将对象和id写入表中
def store(object):
    id = sha1(object)
    objects[id] = object

// 查找某个id对应的对象
def load(id):
    return objects[id]
```

> 译者注：代码注释是译者添加的，原讲义代码无注释。

blob、树和提交在本质上是统一的：它们统称为“对象”。当它们引用其他对象时，在磁盘上的存储形式中，并不会真正“包含”这些对象，而是通过哈希值来建立引用。

例如，针对[上文](#快照snapshot)中目录结构的树对象（可通过键入 `git cat-file -p 698281bc680d1995c5f4caaf3359721a5a58d48d` 命令查看），其内容如下所示：

```
100644 blob 4448adbf7ecd394f42ae135bbeed9676e894af85    baz.txt
040000 tree c68d233a33c5c06e0340e4c224f0afca87c8ce87    foo
```

这个树对象本身包含指向其所含内容的指针（pointer），即 `baz.txt`（一个blob）和 `foo`（一个树）。如果我们键入 `git cat-file -p 4448adbf7ecd394f42ae135bbeed9676e894af85` 命令，查看 `baz.txt` 对应哈希值所指向的内容，会得到以下结果：

```
git is wonderful
```

## 引用（References）

现在，所有的快照都可以通过其 SHA-1 哈希值来标识。但这并不方便，因为人类很难记住由 40 个十六进制字符组成的字符串。

Git 针对这一问题给出的解决方案是为 SHA-1 哈希值提供人类可读的名称，即“引用”（references）。引用是指向提交（commit）的指针。与不可变的对象（objects）不同，引用是可变的（引用可以更新，使其指向新的提交）。例如，引用 `master` 通常指向开发主分支上的最新提交。

> 译者注：或许你可以粗略地认为references是“别名”的意思，如果你不喜欢“引用”这种正式的翻译。

```
references = map<string, string>

// 更新引用的id，只是将某个名为name的引用的id更改
def update_reference(name, id):
    references[name] = id

// 读取名为name的引用的id
def read_reference(name):
    return references[name]

// 递归解引用
def load_reference(name_or_id):
    if name_or_id in references:
        return load(references[name_or_id])
    else:
        return load(name_or_id)
```

> 译者注：代码注释是译者添加的，原讲义代码无注释。译者强烈建议您深刻理解这部分伪代码。

通过这种方式，Git 可以使用诸如 `master` 这类人类可读的名称来指代历史中的某个特定快照，而不必使用一长串十六进制字符串。

这里有一个细节：我们通常需要明确**当前所处的位置**，以便在创建新快照时，能够确定它是基于什么建立的（即如何设置提交中的 `parents` 字段）。在 Git 中，这个“当前所处的位置”被称为 `HEAD`，它是一个特殊的引用。

## 仓库（Repositories）

最后，我们可以定义什么是 Git **仓库（repository）**：它由数据“对象（objects）”和“引用（references）”组成。

在磁盘上，Git 存储的一切内容归根结底都是对象和引用，这就是 Git 数据模型的全部。所有的 `git` 命令，本质上都是通过添加对象以及创建或更新引用，来对提交的 DAG 进行某种操作。

每当你输入一条命令时，不妨思考一下：该命令对底层的图数据结构进行了怎样的操作？反过来说，如果你想对 DAG 进行某种特定的变更，例如“丢弃未提交的更改，并将 `master` 引用指向提交 `5d83f9e`”。那么通常都会有相应的命令可以实现（例如在本例中，可以使用 `git checkout master; git reset --hard 5d83f9e`）。

# 暂存区（Staging area）

这是另一个与数据模型相互独立的概念，但它属于创建提交这一操作接口的一部分。

你或许会设想通过一种创建快照的指令来实现上述快照功能——即根据工作目录的**当前状态**生成一个新快照。有些版本控制工具确实是这样运作的，但 Git 并非如此。我们通常需要“纯净”的快照，而直接基于当前状态生成的快照未必总是最理想的。

例如，假设你开发了两个独立的功能，并希望创建两次​​独立的提交：第一次提交包含第一个功能，第二次提交包含第二个功能。又或者，假设你在代码各处添加了用于调试的打印语句，同时还修复了一个程序错误；你可能只想提交错误修复的部分，而舍弃掉所有的调试打印语句。

为了应对这类场景，Git 引入了一种称为**暂存区（staging area）**的机制，允许你指定哪些修改应被包含在下一次快照中。

# Git 命令行接口（command-line interface）

为避免信息重复，本讲义不再对下文中的命令进行详细讲解。如需了解更多信息，强烈建议参阅[Pro Git](https://git-scm.com/book/en/v2)，或观看课程视频。

## 基础 (Basics)

- `git help <command>`: 获取某个 git 命令的帮助
- `git init`: 创建一个新的 git 仓库，数据存储在 `.git` 目录中
- `git status`: 告诉你当前的状态
- `git add <filename>`: 将文件添加到暂存区（staging area）
- `git commit`: 创建一个新的提交（commit）
    - 编写[好的提交信息](https://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html)！
    - 更多编写[好的提交信息](https://chris.beams.io/posts/git-commit/)的理由！
- `git log`: 显示扁平化的历史日志
- `git log --all --graph --decorate`: 将历史可视化为 DAG（有向无环图）
- `git diff <filename>`: 显示你相对于暂存区所做的更改
- `git diff <revision> <filename>`: 显示文件在两个快照（snapshots）之间的差异
- `git checkout <revision>`: 更新 HEAD（如果检出的是分支，则更新当前分支）

## 分支与合并 (Branching and merging)

- `git branch`: 显示分支
- `git branch <name>`: 创建一个分支
- `git switch <name>`: 切换到某个分支
- `git checkout -b <name>`: 创建一个分支并切换到该分支
    - 等同于 `git branch <name>; git switch <name>`
- `git merge <revision>`: 合并到当前分支
- `git mergetool`: 使用图形化工具帮助解决合并冲突
- `git rebase`: 将一系列补丁（patches）变基（rebase）到新的基底上

## 远程仓库 (Remotes)

- `git remote`: 列出远程仓库
- `git remote add <name> <url>`: 添加一个远程仓库
- `git push <remote> <local branch>:<remote branch>`: 将对象发送到远程仓库，并更新远程引用
- `git branch --set-upstream-to=<remote>/<remote branch>`: 设置本地分支与远程分支的对应关系
- `git fetch`: 从远程仓库获取对象/引用
- `git pull`: 等同于 `git fetch; git merge`
- `git clone`: 从远程仓库下载仓库

## 撤销 (Undo)

- `git commit --amend`: 编辑提交的内容/信息
- `git reset <file>`: 取消暂存文件
- `git restore`: 丢弃更改

# 进阶 Git (Advanced Git)

- `git config`: Git 是[高度可定制的](https://git-scm.com/docs/git-config)
- `git clone --depth=1`: 浅克隆（shallow clone），不包含完整的版本历史
- `git add -p`: 交互式暂存
- `git rebase -i`: 交互式变基
- `git blame`: 显示每一行最后是谁编辑的
- `git stash`: 临时移除对工作目录的修改
- `git bisect`: 对历史进行二分查找（例如用于查找回归 bug）
- `git revert`: 创建一个新提交来抵消（reverse）之前某个提交的影响
- `git worktree`: 同时检出多个分支
- `.gitignore`: [指定](https://git-scm.com/docs/gitignore)故意不追踪（untracked）而忽略的文件

# 杂项 (Miscellaneous)

- **图形界面（GUIs）**：Git 有许多[图形界面客户端](https://git-scm.com/downloads/guis)。我们个人不使用它们，而是使用命令行界面。
- **Shell 集成**：将 Git 状态作为 shell 提示符的一部分非常方便（[zsh](https://github.com/olivierverdier/zsh-git-prompt)，[bash](https://github.com/magicmonty/bash-git-prompt)）。通常包含在像 [Oh My Zsh](https://github.com/ohmyzsh/ohmyzsh) 这样的框架中。
- **编辑器集成**：与上述类似，与许多功能进行了便捷的集成。[fugitive.vim](https://github.com/tpope/vim-fugitive) 是 Vim 的标准选择。
- **工作流**：我们教了你数据模型，以及一些基础命令；我们没有告诉你在大项目中应该遵循哪些实践（并且有[许多](https://nvie.com/posts/a-successful-git-branching-model/)[不同的](https://www.endoflineblog.com/gitflow-considered-harmful)[方法](https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow)）。
- **GitHub**：Git 不是 GitHub。GitHub 有一种特定的方式向其他项目贡献代码，称为[拉取请求（pull requests）](https://help.github.com/en/github/collaborating-with-issues-and-pull-requests/about-pull-requests)。
- **其他 Git 提供商**：GitHub 并不特殊：有许多 Git 仓库托管服务，比如 [GitLab](https://about.gitlab.com/) 和 [BitBucket](https://bitbucket.org/)。

# 资源 (Resources)

- [Pro Git](https://git-scm.com/book/en/v2) 是**强烈推荐阅读的**。既然你理解了数据模型，通读第 1--5 章应该能教会你熟练使用 Git 所需的大部分知识。后面的章节有一些有趣的进阶材料。
- [Oh Shit, Git!?!](https://ohshitgit.com/) 是一份关于如何从一些常见 Git 错误中恢复的简短指南。
- [Git for Computer Scientists](https://eagain.net/articles/git-for-computer-scientists/) 是 Git 数据模型的简短解释，相比这些讲义，它的伪代码更少，图表更酷炫。
- [Git from the Bottom Up](https://jwiegley.github.io/git-from-the-bottom-up/) 详细解释了 Git 数据模型之外的实现细节，适合好奇的人。
- [如何用简单的话解释 git](https://smusamashah.github.io/blog/2017/10/14/explain-git-in-simple-words)
- [Learn Git Branching](https://learngitbranching.js.org/) 是一个基于浏览器的游戏，教你学习 Git。

# 练习 (Exercises)

1. 如果你以前没有任何 Git 经验，可以尝试阅读 [Pro Git](https://git-scm.com/book/en/v2) 的前几章，或者学习像 [Learn Git Branching](https://learngitbranching.js.org/) 这样的教程。在学习过程中，将 Git 命令与数据模型联系起来。
2. 克隆[课程网站的仓库](https://github.com/missing-semester/missing-semester)。
    - 通过将其可视化为图表来探索版本历史。
    - 谁最后一个修改了 `README.md`？（提示：带参数使用 `git log`）。
    - 最后一次修改 `_config.yml` 的 `collections:` 行时，关联的提交信息是什么？（提示：使用 `git blame` 和 `git show`）。
3. 学习 Git 时一个常见的错误是提交了不应该由 Git 管理的大文件，或者添加了敏感信息。尝试向仓库添加一个文件，进行一些提交，然后从`历史记录`中删除该文件（不仅仅是最近的提交）。你可能想看看[这个](https://help.github.com/articles/removing-sensitive-data-from-a-repository/)。
4. 从 GitHub 克隆一些仓库，并修改其现有的一个文件。当你执行 `git stash` 时会发生什么？运行 `git log --all --oneline` 时你会看到什么？运行 `git stash pop` 来撤销你使用 `git stash` 所做的操作。这在什么场景下可能有用？
5. 像许多命令行工具一样，Git 提供了一个名为 `~/.gitconfig` 的配置文件（或 dotfile）。在 `~/.gitconfig` 中创建一个别名，这样当你运行 `git graph` 时，就能得到 `git log --all --graph --decorate --oneline` 的输出。你可以直接[编辑](https://git-scm.com/docs/git-config#Documentation/git-config.txt-alias) `~/.gitconfig` 文件来完成，或者使用 `git config` 命令来添加别名。关于 git 别名的信息可以在[这里](https://git-scm.com/book/en/v2/Git-Basics-Git-Aliases)找到。
6. 运行 `git config --global core.excludesfile ~/.gitignore_global` 之后，你可以在 `~/.gitignore_global` 中定义全局忽略模式。这设置了 Git 将使用的全局忽略文件的位置，但你仍然需要手动在该路径下创建文件。设置你的全局 gitignore 文件以忽略特定于操作系统或编辑器的临时文件，比如 `.DS_Store`。
7. Fork [课程网站的仓库](https://github.com/missing-semester/missing-semester)，找到一个错别字或者你能做的其他改进，并在 GitHub 上提交一个 pull request（你可能想看看[这个](https://github.com/firstcontributions/first-contributions)）。请只提交有用的 PR（请不要给我们发垃圾信息！）。如果你找不到可以改进的地方，可以跳过这个练习。
8. 通过模拟协作场景来练习解决合并冲突：
    - 使用 `git init` 创建一个新的仓库，并创建一个名为 `recipe.txt` 的文件，包含几行内容（例如，一个简单的食谱）。
    - 提交它，然后创建两个分支：`git branch salty` 和 `git branch sweet`。
    - 在 `salty` 分支中，修改一行（例如，将 "1 cup sugar" 改为 "1 cup salt"）并提交。
    - 在 `sweet` 分支中，以不同的方式修改同一行（例如，将 "1 cup sugar" 改为 "2 cups sugar"）并提交。
    - 现在切换到 `master` 并尝试 `git merge salty`，然后尝试 `git merge sweet`。会发生什么？查看 `recipe.txt` 的内容——`<<<<<<<`、`=======` 和 `>>>>>>>` 这些标记是什么意思？
    - 通过编辑文件来保留你想要的内容，移除冲突标记，并使用 `git add` 和 `git commit`（或 `git merge --continue`）完成合并，从而解决冲突。或者，尝试使用 `git mergetool` 通过图形化或基于终端的合并工具来解决冲突。
    - 使用 `git log --graph --oneline` 可视化你刚刚创建的合并历史。
