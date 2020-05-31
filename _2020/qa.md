---
layout: lecture
title: "提问&回答"
date: 2019-01-30
ready: false
video:
  aspect: 56.25
  id: Wz50FvGG6xU
---

最后一节课，我们回答学生提出的问题:

- [学习操作系统相关话题的推荐，比如 进程，虚拟内存，中断，内存管理等](#学习操作系统相关话题的推荐，比如 进程，虚拟内存，中断，内存管理等)   
- [你会优先学习的工具有那些?](#你会优先学习的工具有那些？) 
- [使用Python  VS  Bash脚本  VS 其他语言?](#使用Python  VS  Bash脚本  VS 其他语言?)
- [`source script.sh` 和`./script.sh`有什么区别](#`source script.sh` 和`./script.sh`有什么区别) 
- [各种软件包和工具存储在哪里？ 引用过程是怎样的？ `/bin` 或 `/lib` 是什么？](#各种软件包和工具存储在哪里？ 引用过程是怎样的？ `/bin` 或 `/lib` 是什么？)
- [我应该用`apt-get install`还是`pip install`  去下载包呢?](#我应该用`apt-get install`还是`pip install`  去下载包呢) 
- [提高代码性能的最简单和最好的性能分析工具是什么?](#提高代码性能的最简单和最好的性能分析工具是什么)
- [你使用那些浏览器插件?](#你使用那些浏览器插件) 
- [有哪些有用的数据整理工具？](#有哪些有用的数据整理工具)
- [Docker 和 虚拟机 有什么区别?](#Docker 和 虚拟机 有什么区别) 
- [每种OS的优缺点是什么，我们如何选择（比如如何选择针对我们目的的最好Linux发行版）？](#每种OS的优缺点是什么，我们如何选择（比如如何选择针对我们目的的最好Linux发行版）)
- [Vim 编辑器vs Emacs编辑器?](#Vim 编辑器vs Emacs编辑器?)
- [机器学习应用的提示或技巧?](#机器学习应用的提示或技巧?)
-  [还有更多的Vim提示吗？](#还有更多的Vim提示吗？)
- [2FA是什么，为什么我需要使用它?](#2FA是什么，为什么我需要使用它?)
- [对于不同的Web浏览器有什么评价??](#对于不同的Web浏览器有什么评价?)


## 学习操作系统相关话题的推荐，比如 进程，虚拟内存，中断，内存管理等



首先，不清楚你是不是真的需要熟悉这些 更底层的话题。
当你开始编写更加底层的代码比如 实现或修改 内核 的时候，这些很重要。
除了其他课程中简要介绍过的进程和信号量之外，大部分话题都不相关。


学习这些话题的资源：

- [MIT's 6.828 class](https://pdos.csail.mit.edu/6.828/) - Graduate level class on Operating System Engineering. Class materials are publicly available.  研究生阶段的操作系统课程（课程资料是公开的）
- Modern Operating Systems (4th ed) -  Andrew S. Tanenbaum is a good overview of many of the mentioned concepts. **对很多上述概念都有很好的描述**
- The Design and Implementation of the FreeBSD Operating System - 关于FreeBSD OS 的好资源(注意，FreeBSD OS不是Linux)
- 其他的指南例如 [Writing an OS in Rust](https://os.phil-opp.com/) where people implement a kernel step by step in various languages, mostly for teaching purposes.这里用不同的语言 逐步实现了内核，主要用于教学的目的。


## 你会优先学习的工具有那些？



值得优先学习的话题：

- 学着更多去使用键盘而不是鼠标。这可以通过快捷键，更换接口等等。

- 学好编辑器。作为程序员你的大部分时间都是在编辑文件，因此学好这些技能会给你带来回报。

- 学习怎样去自动化或简化工作流程中的重复任务。因为这会节省大量的时间。

- 学习版本控制工具如Git 并且知道如何使用它与GitHub结合，在现代的软件项目中协同工作。

- Learning how to use your keyboard more and your mouse less. This can be through **keyboard shortcuts, changing interfaces, &c**.


## 使用Python  VS  Bash脚本  VS 其他语言?



通常来说，当你仅想要运行一系列的命令的时候，Bash 脚本对于简短的一次性脚本有用。Bash 脚本有一些比较奇怪的地方，这使得大型程序或脚本难以用Bash实现：

- Bash 可以获取简单的用例，但是很难获得全部可能的输入。例如，脚本参数中的空格会导致Bash 脚本出错。
- Bash 对于 代码重用并不友好。因此，重用你先前已经写好代码部分很困难。Bash 中没有软件库的概念。
- Bash依赖于一些 像`$?` 或 `$@`的特殊字符指代特殊的值。其他的语言会显式地引用，比如`exitCode` 或`sys.args`。

因此，对于大型或者更加复杂地脚本我们推荐使用更加成熟的脚本语言例如 Python 和 Ruby。
你可以找到数不胜数的在线库，有人已经写好了去解决常见的问题用这种语言。
你可以在网上找到很多用这些语言写的解决常见问题的库。
如果你发现某种语言实现了你需要的特定功能的库，最好的方式就是直接去用那种语言


## `source script.sh` 和`./script.sh`有什么区别
两种情况下 `script.sh` 都会在bash会话种被读取和执行，不同点在于那个会话在执行这个命令。
对于`source`命令来说，命令是在当前的bash会话种执行的，因此当`source`执行完毕，对当前环境的任何更改（例如更改目录或是自定义函数）都会保存在当前会话中。
当像`./script.sh`这样独立运行脚本时，当前的bash会话将启动新的bash实例，并在该实例中运行命令`script.sh`。因此，如果`script.sh`更改目录，新的bash实例会更改目录，但是一旦退出并将控制权返回给父bash会话，父会话仍然留在先前的位置（不会有目录的更改）。
同样，如果`script.sh`定义了要在终端中访问的函数，需要用`source`命令在使得在当前bash会话中定义这个函数。否则，如果您运行`./script.sh`，只有新的bash进程才能执行定义的函数，而当前的shell不能。



## 各种软件包和工具存储在哪里？ 引用过程是怎样的？ `/bin` 或 `/lib` 是什么？
根据你在命令行中运行的程序，这些包和工具会在`PATH`环境变量所列出的目录中找到 并且 你可以使用 `which`命令(或是`type`命令)来检查你的shell在哪里发现了特定的程序。
一般来说，特定种类的文件存储有一定的规范，[文件系统，层次结构标准（Filesystem, Hierarchy Standard）](https://en.wikipedia.org/wiki/Filesystem_Hierarchy_Standard)可以查到我们讨论内容的详细列表

- `/bin` - 基本命令二进制文件
- `/sbin` - 基本的系统二进制文件，通常是root运行的
- `/dev` -  设备文件，通常是硬件设备接口文件
- `/etc` - 主机特定的系统配置文件
- `/home` - 系统用户的家目录
- `/lib` - 系统软件通用库
- `/opt` - 可选的应用软件
- `/sys` - 包含系统的信息和配置( [第一堂课](/2020/course-shell/)介绍的)
- `/tmp` - 临时文件 (`/var/tmp`) 通常在重启之间删除
- `/usr/` -   只读的用户数据
  + `/usr/bin` -  非必须的命令二进制文件
  + `/usr/sbin` -  非必须的系统二进制文件，通常是由root运行的
  + `/usr/local/bin` -  用户编译程序的二进制文件
- `/var` -变量文件 像日志或缓存

## 我应该用`apt-get install`还是`pip install`  去下载包呢?

这个问题没有普遍的答案。这与使用系统程序包管理器还是特定语言的程序包管理器来安装软件这一更普遍的问题有关。需要考虑的几件事：

- 通用软件包可以通过这两种方法获得，但是不太流行的软件包或较新的软件包可能不在系统程序包管理器中。在这种情况下，使用特定语言的工具的情况是更好的选择。
- 同样，特定语言的程序包管理器相比系统程序包管理器更多的最新版本的程序包。
- 当使用系统软件包管理器时，将在系统范围内安装库。这意味着，如果出于开发目的需要不同版本的库，则系统软件包管理器可能不能满足你的需要。对于这种情况，大多数编程语言都提供了隔离或虚拟环境，因此您可以安装不同版本的库而不会发生冲突。对于Python，有virtualenv，对于Ruby，有RVM。
- 根据操作系统和硬件体系结构，其中一些软件包可能会附带二进制文件或可能需要编译。例如，在树莓派（Raspberry Pi）之类的ARM架构计算机中，在软件附带二进制文件和需要编译的情况下，使用系统包管理器比特定语言包管理器更好。这在很大程度上取决于您的特定设置。
你应该仅使用一种解决方案，而不同时使用两种方法，因为这可能会导致难以调试的冲突。我们的建议是尽可能使用特定语言的程序包管理器，并使用隔离的环境（例如Python的virtualenv）以避免影响全局环境。



## 提高代码性能的最简单和最好的性能分析工具是什么?
性能分析方面最有用和简单工具是[print timing](/2020/debugging-profiling/#timing)。你只需手动计算代码不同部分之间花费的时间。通过重复执行此操作，你可以有效地对代码进行二分法搜索，并找到花费时间最长的代码段。

对于更高级的工具，Valgrind的 [Callgrind](http://valgrind.org/docs/manual/cl-manual.html)可让你运行程序并计算一切的时间花费以及所有调用堆栈，即哪个函数调用了另一个函数。然后，它会生成程序源代码的带注释的版本，其中包含每行花费的时间。但是，它会使程序速度降低一个数量级，并且不支持线程。对于其他情况，[`perf`](http://www.brendangregg.com/perf.html)工具和其他特定语言的采样性能分析器可以非常快速地输出有用的数据。[Flamegraphs](http://www.brendangregg.com/flamegraphs.html) 是对于采样分析器输出很好的可视化工具。你还应该使用针对编程语言或任务的特定的工具。例如，对于Web开发，Chrome和Firefox内置的开发工具具有出色的性能分析器。

有时，代码中最慢的部分是系统等待磁盘读取或网络数据包之类的事件。在这些情况下，值得检查的是，关于硬件功能的理论速度的后验计算与实际读数没有偏差。
**粗略计算理论速度，根据实际读数与硬件容量偏差不大**   也有专门的工具来分析系统调用中的等待时间。这些工具包括执行用户程序内核跟踪的[eBPF](http://www.brendangregg.com/blog/2019-01-01/learn-ebpf-tracing.html) 之类的工具。如果需要低级的性能分析，[`bpftrace`](https://github.com/iovisor/bpftrace) 值得一试。


Sometimes the slow part of your code will be because your system is waiting for an event like a disk read or a network packet. In those cases, it is worth checking that back-of-the-envelope calculations about the theoretical speed in terms of hardware capabilities do not deviate from the actual readings. There are also specialized tools to analyze the wait times in system calls. These include tools like [eBPF](http://www.brendangregg.com/blog/2019-01-01/learn-ebpf-tracing.html) that perform kernel tracing of user programs. In particular [`bpftrace`](https://github.com/iovisor/bpftrace) is worth checking out if you need to perform this sort of low level profiling.


## 你使用那些浏览器插件?

我们钟爱的插件主要与安全性与可用性有关：
- [uBlock Origin](https://github.com/gorhill/uBlock) - 是一个[wide-spectrum](https://github.com/gorhill/uBlock/wiki/Blocking-mode)不仅可以拦截广告，还可以拦截第三方的页面。这也会覆盖内部的脚本和其他种类的加载资源。如果你打算花更多的时间去配置，前往[medium mode](https://github.com/gorhill/uBlock/wiki/Blocking-mode:-medium-mode)或者 [hard mode](https://github.com/gorhill/uBlock/wiki/Blocking-mode:-hard-mode)。这些会使得一些网站停止工作直到你调整好了这些设置，这会显著提高你的网络安全。另外， [easy mode](https://github.com/gorhill/uBlock/wiki/Blocking-mode:-easy-mode)已经很好了，可以拦截大部分的广告和跟踪，你也可以自定义规则来拦截网站对象。

- [Stylus](https://github.com/openstyles/stylus/) -Stylish的分支（不要使用Stylish，它会 [窃取浏览记录](https://www.theregister.co.uk/2018/07/05/browsers_pull_stylish_but_invasive_browser_extension/))），这个插件可让你将自定义CSS样式表侧面加载到网站。使用Stylus，你可以轻松地自定义和修改网站的外观。可以删除侧边栏，更改背景颜色，甚至更改文字大小或字体样式。这可以使你得经常访问的网站更具可读性。此外，Stylus可以找到其他用户编写并发布在[userstyles.org](https://userstyles.org/)中的样式。例如，大多数常见的网站都有一个或几个深色主题样式。

- 全页屏幕捕获-内置于Firefox和 [Chrome 扩展程序](https://chrome.google.com/webstore/detail/full-page-screen-capture/fdpohaocaechififmbbbbbknoalclacl?hl=en)中。这些插件提供完整的网站截图，通常比打印要好用。

- [多账户容器](https://addons.mozilla.org/en-US/firefox/addon/multi-account-containers/) -该插件使你可以将Cookie分为“容器”，从而允许你以不同的身份浏览web网页 并且/或 确保网站无法在它们之间共享信息。
- 密码集成管理器-大多数密码管理器都有浏览器插件，这些插件帮你将登录凭据输入网站的过程不仅方便，而且更加安全。与简单复制粘贴用户名和密码相比，这些插件将首先检查网站域是否与列出的条目相匹配，以防止冒充著名网站的网络钓鱼攻击窃取登录凭据。


## 有哪些有用的数据整理工具？
在数据整理课程中，我们没有时间讨论的一些数据整理工具包括`jq`或`pup`分别是用于JSON和HTML数据的专用解析器。Perl语言是用于更高级的数据整理管道的另一个很好的工具。另一个技巧是使用`column -t`命令， 可用于将空格文本（不一定对齐）转换为正确的列对齐文本。

一般来说，vim和Python是两个不常规的数据整理工具。对于某些复杂的多行转换，vim宏可以是非常宝贵的工具。你可以记录一系列操作，并根据需要重复执行多次，例如，在编辑的 [讲义](/2020/editors/#macros) (去年 [视频](/2019/editors/))中，有一个示例就是使用vim宏将XML格式的文件转换为JSON。


对于通常以CSV格式显示的表格数据， Python [pandas](https://pandas.pydata.org/) 库是一个很棒的工具。不仅因为它使定义复杂的操作（如分组依据，联接或过滤器）变得非常容易；而且 而且还很容易绘制数据的不同属性。它还支持导出为多种表格格式，包括XLS，HTML或LaTeX。另外，R语言(一种理论上[不好](http://arrgh.tim-smith.us/)的语言）具有很多功能，可以计算数据的统计数据，在管道的最后一步中非常有用。 [ggplot2](https://ggplot2.tidyverse.org/)是R中很棒的绘图库。




## Docker 和 虚拟机 有什么区别?

Docker 基于更加普遍的概念，称为容器。关于容器和虚拟机之间最大的不同是 虚拟机会执行整个的 **OS 栈，包括内核（即使这个内核和主机内核相同）**。与虚拟机不同，容器避免运行其他内核实例 反而是与主机分享内核。在Linux环境中，有LXC机制来实现，并且这能使一系列分离的主机好像是使用自己的硬件启动程序，而实际上是共享主机的硬件和内核。因此容器的开销小于完整的虚拟机。

另一方面，容器的隔离性较弱而且只有在主机运行相同的内核时才能正常工作。例如如果你在macOS上运行Docker，Docker需要启动Linux虚拟机去获取初始的Linux内核，这样开销仍然很大。最后，Docker是容器的特定实现，它是为软件部署定制的。基于这些，它有一些奇怪之处：例如，默认情况下，Docker容器在重启之间不会维持以任何形式的存储。



## 每种OS的优缺点是什么，我们如何选择（比如如何选择针对我们目的的最好Linux发行版）

关于Linux发行版，尽管有很多版本，但大部分发行版在大多数使用情况下的表现是相同的。
可以在任何发行版中学习Linux和UNIX的特性和其内部工作原理。
发行版之间的根本区别是发行版如何处理软件包更新。
某些版本，例如Arch Linux采用滚动更新策略，用了最前沿的技术（bleeding-edge），但软件可能并不稳定。另外一些发行版（如Debian，CentOS或Ubuntu LTS）其更新要保守得多，因此更新会更稳定，但不能使用一些新功能。我们建议你使用Debian或Ubuntu来获得简单稳定的台式机和服务器体验。

Mac OS是介于Windows和Linux之间的一个很好的中间OS，它有很漂亮的界面。但是，Mac OS是基于BSD而不是Linux，因此系统的某些部分和命令是不同的。
另一种值得体验的是FreeBSD。虽然某些程序不能在FreeBSD上运行，但与Linux相比，BSD生态系统的碎片化程度要低得多，并且说明文档更加友好。
除了开发Windows应用程序或需要某些在Windows上更好功能（例如对游戏的良好驱动程序支持）外，我们不建议使用Windows。

对于双启动系统，我们认为最有效的实现是macOS的bootcamp，从长远来看，任何其他组合都可能会出现问题，尤其是当你结合了其他功能比如磁盘加密。




## Vim 编辑器vs Emacs编辑器?
我们三个都使用vim作为我们的主要编辑器。但是Emacs也是一个不错的选择，你可以两者都尝试，看看那个更适合你。Emacs不遵循vim的模式编辑，但是这些功能可以通过Emacs插件  [Evil](https://github.com/emacs-evil/evil) 或 [Doom Emacs](https://github.com/hlissner/doom-emacs)来实现。Emacs的优点是可以用Lisp语言进行扩展（Lisp比vim默认的脚本语言vimscript要更好）。

## 机器学习应用的提示或技巧?

课程的一些经验可以直接用于机器学习程序。

就像许多科学学科一样，在机器学习中，你经常要进行一系列实验，并检查哪些数据有效，哪些无效。

你可以使用Shell轻松快速地搜索这些实验结果，并且以明智的方式汇总。这意味着在需要在给定的时间范围或在使用特定数据集的情况下，检查所有实验结果。通过使用JSON文件记录实验的所有相关参数，使用我们在本课程中介绍的工具，这件事情可以变得非常简单。

最后，如果你不使用集群提交你的GPU作业，那你应该研究如何使该过程自动化，因为这是一项非常耗时的任务，会消耗你的精力。

## 还有更多的Vim提示吗？

更多的提示：

- 插件 - 花时间去探索插件。有很多不错的插件解决vim的缺陷或者增加了与现有vim 工作流很好结合的新功能。这部分内容，资源是[VimAwesome](https://vimawesome.com/) 和其他程序员的dotfiles

- 标记 - 在vim里你可以使用 `m<X>` 为字母 `X`做标记，之后你可以通过 `'<X>`回到标记位置。这可以让你快速导航到文件内或跨文件间的特定位置。

- 导航 - `Ctrl+O` and `Ctrl+I` 使你在最近访问位置向后向前移动。

- 撤销树 - vim 有不错的机制跟踪（文件）更改，不同于其他的编辑器，vim存储变更树，因此即使你撤销后做了一些修改，你仍然可以通过撤销树的导航回到初始状态。一些插件比如 [gundo.vim](https://github.com/sjl/gundo.vim) 和 [undotree](https://github.com/mbbill/undotree)通过图形化来展示撤销树 

- 时间的撤销 - `:earlier` 和 `:later`命令使得你可以用时间参考而不是某一时刻的更改。

- [持续撤销](https://vim.fandom.com/wiki/Using_undo_branches#Persistent_undo)是一个默认未开启的vim的内置功能，在vim启动之间保存撤销历史，通过设置 在 `.vimrc`目录下的`undofile` 和 `undodir`,  vim会保存每个文件的修改历史。

- 领导按键 - 领导按键是一个用于用户配置自定义命令的特殊的按键。这种模式通常是按下后释放这个按键（通常是空格键）和其他的按键去执行特殊的命令。插件会用这些按键增加他们的功能，例如 插件UndoTree使用 `<Leader> U` 去打开撤销树。
- 高级文本对象 - 文本对象像搜索也可以用vim命令构成，例如`d/<pattern>`会删除下一处匹配pattern的位置 ，**`cgn`会改变最后搜索到的字符串的下一个存在。**




## 2FA是什么，为什么我需要使用它?
双因子验证（Two Factor Authentication  2FA）在密码之上为帐户增加了一层额外的保护。为了登录，您不仅需要知道一些密码，还必须以某种方式“证明”可以访问某些硬件设备。最简单的情形，可以通过在接收手机的SMS来实现（尽管SMS 2FA 存在 [已知问题](https://www.kaspersky.com/blog/2fa-practical-guide/24219/)）。我们推荐使用[YubiKey](https://www.yubico.com/)之类的[U2F](https://en.wikipedia.org/wiki/Universal_2nd_Factor)方案。



## 对于不同的Web浏览器有什么评价?

2020的浏览器现状是，大部分的浏览器都与Chrome 类似，因为他们都使用同样的引擎(Blink)。 Microsoft Edge同样基于 Blink，至于Safari 基于 WebKit(与Blink类似的引擎)，这些浏览器仅仅是更糟糕的Chorme版本。不管是在性能还是可用性上，Chorme都是一款好的浏览器。如果你想要替代品，我们推荐Firefox。Firefox与Chorme的在各方面不相上下，并且在隐私方面更加出色。有一款目前还没有完成Flow的浏览器**浏览器目前还没有完成**，它实现了全新的渲染引擎(rendering engine)，可以保证比现有引擎快。
