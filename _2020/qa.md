---
layout: lecture
title: "提问&回答"
date: 2022-10-26
ready: true
sync: true
syncdate: 2021-04-24
video:
  aspect: 56.25
  id: Wz50FvGG6xU
---

最后一节课，我们回答学生提出的问题:


- [学习操作系统相关内容的推荐，比如进程，虚拟内存，中断，内存管理等](#学习操作系统相关内容的推荐比如进程虚拟内存中断内存管理等) 
- [你会优先学习的工具有那些?](#你会优先学习的工具有那些) 
- [使用 Python VS Bash脚本 VS 其他语言?](#使用-python-vs-bash脚本-vs-其他语言)
- [ `source script.sh` 和 `./script.sh` 有什么区别？](#source-scriptsh-和-scriptsh-有什么区别) 
- [各种软件包和工具存储在哪里？引用过程是怎样的? `/bin` 或 `/lib` 是什么？](#各种软件包和工具存储在哪里引用过程是怎样的-bin-或-lib-是什么)
- [我应该用 `apt-get install` 还是 `pip install` 去下载软件包呢?](#我应该用-apt-get-install-还是-pip-install-去下载软件包呢) 
- [用于提高代码性能，简单好用的性能分析工具有哪些?](#用于提高代码性能简单好用的性能分析工具有哪些)
- [你使用那些浏览器插件?](#你使用那些浏览器插件) 
- [有哪些有用的数据整理工具？](#有哪些有用的数据整理工具)
- [Docker和虚拟机有什么区别?](#Docker和虚拟机有什么区别) 
- [不同操作系统的优缺点是什么，我们如何选择（比如选择最适用于我们需求的Linux发行版）？](#不同操作系统的优缺点是什么我们如何选择比如选择最适用于我们需求的Linux发行版)
- [使用 Vim 编辑器 VS Emacs 编辑器?](#使用-vim-编辑器-vs-emacs-编辑器)
- [机器学习应用的提示或技巧?](#机器学习应用的提示或技巧)
- [还有更多的 Vim 小窍门吗？](#还有更多的-vim-小窍门吗)
- [2FA是什么，为什么我需要使用它?](#2FA是什么为什么我需要使用它)
- [对于不同的 Web 浏览器有什么评价?](#对于不同的-Web-浏览器有什么评价)


## 学习操作系统相关内容的推荐，比如进程，虚拟内存，中断，内存管理等



首先，不清楚你是不是真的需要了解这些更底层的话题。
当你开始编写更加底层的代码，比如实现或修改内核的时候，这些内容是很重要的。除了其他课程中简要介绍过的进程和信号量之外，大部分话题都不相关。

学习资源：

- [MIT's 6.828 class](https://pdos.csail.mit.edu/6.828/) - 研究生阶段的操作系统课程（课程资料是公开的）。
- 现代操作系统 第四版（*Modern Operating Systems 4th ed*） - 作者是Andrew S. Tanenbaum 这本书对上述很多概念都有很好的描述。
- FreeBSD的设计与实现（*The Design and Implementation of the FreeBSD Operating System*） - 关于FreeBSD OS 不错的资源(注意，FreeBSD OS 不是 Linux)。
- 其他的指南例如 [用 Rust 写操作系统](https://os.phil-opp.com/) 这里用不同的语言逐步实现了内核，主要用于教学的目的。


## 你会优先学习的工具有那些？

值得优先学习的内容：

- 多去使用键盘，少使用鼠标。这一目标可以通过多加利用快捷键，更换界面等来实现。
- 学好编辑器。作为程序员你大部分时间都是在编辑文件，因此值得学好这些技能。
- 学习怎样去自动化或简化工作流程中的重复任务。因为这会节省大量的时间。
- 学习像 Git 之类的版本控制工具并且知道如何与 GitHub 结合，以便在现代的软件项目中协同工作。

## 使用 Python VS Bash脚本 VS 其他语言?

通常来说，Bash 脚本对于简短的一次性脚本有效，比如当你想要运行一系列的命令的时候。但是Bash 脚本有一些比较奇怪的地方，这使得大型程序或脚本难以用 Bash 实现：

- Bash 对于简单的使用情形没什么问题，但是很难对于所有可能的输入都正确。例如，脚本参数中的空格会导致 Bash 脚本出错。
- Bash 对于代码重用并不友好。因此，重用你先前已经写好的代码很困难。通常 Bash 中没有软件库的概念。
- Bash 依赖于一些像 `$?` 或 `$@` 的特殊字符指代特殊的值。其他的语言却会显式地引用，比如  `exitCode` 或 `sys.args`。

因此，对于大型或者更加复杂的脚本我们推荐使用更加成熟的脚本语言例如 Python 和 Ruby。
你可以找到很多用这些语言编写的，用来解决常见问题的在线库。
如果你发现某种语言实现了你所需要的特定功能库，最好的方式就是直接去使用那种语言。

## `source script.sh` 和 `./script.sh` 有什么区别?

这两种情况 `script.sh` 都会在bash会话中被读取和执行，不同点在于哪个会话执行这个命令。
对于 `source` 命令来说，命令是在当前的bash会话中执行的，因此当 `source` 执行完毕，对当前环境的任何更改（例如更改目录或是定义函数）都会留存在当前会话中。
单独运行 `./script.sh` 时，当前的bash会话将启动新的bash会话（实例），并在新实例中运行命令 `script.sh`。
因此，如果 `script.sh` 更改目录，新的bash会话（实例）会更改目录，但是一旦退出并将控制权返回给父bash会话，父会话仍然留在先前的位置（不会有目录的更改）。
同样，如果 `script.sh` 定义了要在终端中访问的函数，需要用 `source` 命令在当前bash会话中定义这个函数。否则，如果你运行 `./script.sh`，只有新的bash会话（进程）才能执行定义的函数，而当前的shell不能。

## 各种软件包和工具存储在哪里？引用过程是怎样的? `/bin` 或 `/lib` 是什么？

根据你在命令行中运行的程序，这些包和工具会全部在 `PATH` 环境变量所列出的目录中查找到， 你可以使用 `which` 命令(或是 `type` 命令)来检查你的shell在哪里发现了特定的程序。
一般来说，特定种类的文件存储有一定的规范，[文件系统，层次结构标准（Filesystem, Hierarchy Standard）](https://en.wikipedia.org/wiki/Filesystem_Hierarchy_Standard)可以查到我们讨论内容的详细列表。

- `/bin` - 基本命令二进制文件
- `/sbin` - 基本的系统二进制文件，通常是root运行的
- `/dev` - 设备文件，通常是硬件设备接口文件
- `/etc` - 主机特定的系统配置文件
- `/home` - 系统用户的主目录
- `/lib` - 系统软件通用库
- `/opt` - 可选的应用软件
- `/sys` - 包含系统的信息和配置([第一堂课](/2020/course-shell/)介绍的)
- `/tmp` - 临时文件( `/var/tmp` ) 通常重启时删除
- `/usr/` - 只读的用户数据
  + `/usr/bin` - 非必须的命令二进制文件
  + `/usr/sbin` - 非必须的系统二进制文件，通常是由root运行的
  + `/usr/local/bin` - 用户编译程序的二进制文件
- `/var` -变量文件 像日志或缓存

## 我应该用 `apt-get install` 还是 `pip install` 去下载软件包呢?

这个问题没有普遍的答案。这与使用系统程序包管理器还是特定语言的程序包管理器来安装软件这一更笼统的问题相关。需要考虑的几件事：

- 常见的软件包都可以通过这两种方法获得，但是小众的软件包或较新的软件包可能不在系统程序包管理器中。在这种情况下，使用特定语言的程序包管理器是更好的选择。
- 同样，特定语言的程序包管理器相比系统程序包管理器有更多的最新版本的程序包。
- 当使用系统软件包管理器时，将在系统范围内安装库。如果出于开发目的需要不同版本的库，则系统软件包管理器可能不能满足你的需要。对于这种情况，大多数编程语言都提供了隔离或虚拟环境，因此你可以用特定语言的程序包管理器安装不同版本的库而不会发生冲突。对于 Python，可以使用  virtualenv，对于 Ruby，使用 RVM 。
- 根据操作系统和硬件架构，其中一些软件包可能会附带二进制文件或者软件包需要被编译。例如，在树莓派（Raspberry Pi）之类的ARM架构计算机中，在软件附带二进制文件和软件包需要被编译的情况下，使用系统包管理器比特定语言包管理器更好。这在很大程度上取决于你的特定设置。
你应该仅使用一种解决方案，而不同时使用两种方法，因为这可能会导致难以解决的冲突。我们的建议是尽可能使用特定语言的程序包管理器，并使用隔离的环境（例如 Python 的 virtualenv）以避免影响全局环境。

## 用于提高代码性能，简单好用的性能分析工具有哪些?

性能分析方面相当有用和简单工具是[print timing](/2020/debugging-profiling/#timing)。你只需手动计算代码不同部分之间花费的时间。通过重复执行此操作，你可以有效地对代码进行二分法搜索，并找到花费时间最长的代码段。

对于更高级的工具， Valgrind 的 [Callgrind](http://valgrind.org/docs/manual/cl-manual.html)可让你运行程序并计算所有的时间花费以及所有调用堆栈（即哪个函数调用了另一个函数）。然后，它会生成带注释的代码版本，其中包含每行花费的时间。但是，它会使程序运行速度降低一个数量级，并且不支持线程。其他的，[ `perf` ](http://www.brendangregg.com/perf.html)工具和其他特定语言的采样性能分析器可以非常快速地输出有用的数据。[Flamegraphs](http://www.brendangregg.com/flamegraphs.html) 是对采样分析器结果的可视化工具。你还可以使用针对特定编程语言或任务的工具。例如，对于 Web 开发而言，Chrome 和 Firefox 内置的开发工具具有出色的性能分析器。

有时，代码中最慢的部分是系统等待磁盘读取或网络数据包之类的事件。在这些情况下，需要检查根据硬件性能估算的理论速度是否不偏离实际数值，也有专门的工具来分析系统调用中的等待时间，包括用于用户程序内核跟踪的[eBPF](http://www.brendangregg.com/blog/2019-01-01/learn-ebpf-tracing.html) 。如果需要低级的性能分析，[ `bpftrace` ](https://github.com/iovisor/bpftrace) 值得一试。


## 你使用那些浏览器插件?

我们钟爱的插件主要与安全性与可用性有关：
- [uBlock Origin](https://github.com/gorhill/uBlock) - 是一个[用途广泛（wide-spectrum）](https://github.com/gorhill/uBlock/wiki/Blocking-mode)的拦截器，它不仅可以拦截广告，还可以拦截第三方的页面，也可以拦截内部脚本和其他种类资源的加载。如果你打算花更多的时间去配置，前往[中等模式（medium mode）](https://github.com/gorhill/uBlock/wiki/Blocking-mode:-medium-mode)或者 [强力模式（hard mode）](https://github.com/gorhill/uBlock/wiki/Blocking-mode:-hard-mode)。在你调整好设置之前一些网站会停止工作，但是这些配置会显著提高你的网络安全水平。另外， [简易模式（easy mode）](https://github.com/gorhill/uBlock/wiki/Blocking-mode:-easy-mode)作为默认模式已经相当不错了，可以拦截大部分的广告和跟踪，你也可以自定义规则来拦截网站对象。
- [Stylus](https://github.com/openstyles/stylus/) - 是Stylish的分支（不要使用Stylish，它会[窃取浏览记录](https://www.theregister.co.uk/2018/07/05/browsers_pull_stylish_but_invasive_browser_extension/))），这个插件可让你将自定义CSS样式加载到网站。使用Stylus，你可以轻松地自定义和修改网站的外观。可以删除侧边框，更改背景颜色，更改文字大小或字体样式。这可以使你经常访问的网站更具可读性。此外，Stylus可以找到其他用户编写并发布在[userstyles.org](https://userstyles.org/)中的样式。大多数常用的网站都有一个或几个深色主题样式。
- 全页屏幕捕获 - 内置于 [Firefox](https://screenshots.firefox.com/) 和 [ Chrome 扩展程序](https://chrome.google.com/webstore/detail/full-page-screen-capture/fdpohaocaechififmbbbbbknoalclacl?hl=en)中。这些插件提供完整的网站截图，通常比打印要好用。
- [多账户容器](https://addons.mozilla.org/en-US/firefox/addon/multi-account-containers/) - 该插件使你可以将Cookie分为“容器”，从而允许你以不同的身份浏览web网页并且/或确保网站无法在它们之间共享信息。
- 密码集成管理器 - 大多数密码管理器都有浏览器插件，这些插件帮你将登录凭据输入网站的过程不仅方便，而且更加安全。与简单复制粘贴用户名和密码相比，这些插件将首先检查网站域是否与列出的条目相匹配，以防止冒充网站的网络钓鱼窃取登录凭据。

## 有哪些有用的数据整理工具？

在数据整理那一节课程中，我们没有时间讨论一些数据整理工具，包括分别用于JSON和HTML数据的专用解析器， `jq` 和 `pup`。Perl语言是另一个更高级的可以用于数据整理管道的工具。另一个技巧是使用 `column -t` 命令，可以将空格文本（不一定对齐）转换为对齐的文本。

一般来说，vim和Python是两个不常规的数据整理工具。对于某些复杂的多行转换，vim宏是非常有用的工具。你可以记录一系列操作，并根据需要重复执行多次，例如，在编辑的[讲义](/2020/editors/#macros)(去年 [视频](/2019/editors/))中，有一个示例是使用vim宏将XML格式的文件转换为JSON。

对于通常以CSV格式显示的表格数据， Python [pandas](https://pandas.pydata.org/)库是一个很棒的工具。不仅因为它能让复杂操作的定义（如分组依据，联接或过滤器）变得非常容易，而且还便于根据不同属性绘制数据。它还支持导出多种表格格式，包括 XLS，HTML 或 LaTeX。另外，R语言(一种有争议的[不好](http://arrgh.tim-smith.us/)的语言）具有很多功能，可以计算数据的统计数字，这在管道的最后一步中非常有用。 [ggplot2](https://ggplot2.tidyverse.org/)是R中很棒的绘图库。

## Docker和虚拟机有什么区别?

Docker 基于容器这个更为概括的概念。关于容器和虚拟机之间最大的不同是，虚拟机会执行整个的 OS 栈，包括内核（即使这个内核和主机内核相同）。与虚拟机不同，容器避免运行其他内核实例，而是与主机分享内核。在Linux环境中，有LXC机制来实现，并且这能使一系列分离的主机像是在使用自己的硬件启动程序，而实际上是共享主机的硬件和内核。因此容器的开销小于完整的虚拟机。

另一方面，容器的隔离性较弱而且只有在主机运行相同的内核时才能正常工作。例如，如果你在macOS 上运行 Docker，Docker 需要启动 Linux虚拟机去获取初始的 Linux内核，这样的开销仍然很大。最后，Docker 是容器的特定实现，它是为软件部署而定制的。基于这些，它有一些奇怪之处：例如，默认情况下，Docker 容器在重启之间不会有以任何形式的存储。

## 不同操作系统的优缺点是什么，我们如何选择（比如选择最适用于我们需求的Linux发行版)?

关于Linux发行版，尽管有相当多的版本，但大部分发行版在大多数使用情况下的表现是相同的。
可以使用任何发行版去学习 Linux 与 UNIX 的特性和其内部工作原理。
发行版之间的根本区别是发行版如何处理软件包更新。
某些版本，例如 Arch Linux 采用滚动更新策略，用了最前沿的软件包（bleeding-edge），但软件可能并不稳定。另外一些发行版（如Debian，CentOS 或 Ubuntu LTS）其更新策略要保守得多，因此更新的内容会更稳定，但会牺牲一些新功能。我们建议你使用 Debian 或 Ubuntu 来获得简单稳定的台式机和服务器体验。

Mac OS 是介于 Windows 和 Linux 之间的一个操作系统，它有很漂亮的界面。但是，Mac OS 是基于BSD 而不是 Linux，因此系统的某些部分和命令是不同的。
另一种值得体验的是 FreeBSD。虽然某些程序不能在 FreeBSD 上运行，但与 Linux 相比，BSD 生态系统的碎片化程度要低得多，并且说明文档更加友好。
除了开发Windows应用程序或需要使用某些Windows系统更好支持的功能（例如对游戏的驱动程序支持）外，我们不建议使用 Windows。

对于双系统，我们认为最有效的是 macOS 的 bootcamp，长期来看，任何其他组合都可能会出现问题，尤其是当你结合了其他功能比如磁盘加密。

## 使用 Vim 编辑器 VS Emacs 编辑器?

我们三个都使用 vim 作为我们的主要编辑器。但是 Emacs 也是一个不错的选择，你可以两者都尝试，看看那个更适合你。Emacs 不使用 vim 的模式编辑，但是这些功能可以通过 Emacs 插件像[Evil](https://github.com/emacs-evil/evil) 或 [Doom Emacs](https://github.com/hlissner/doom-emacs)来实现。
Emacs的优点是可以用Lisp语言进行扩展（Lisp比vim默认的脚本语言vimscript要更好用）。

## 机器学习应用的提示或技巧?

课程的一些经验可以直接用于机器学习程序。
就像许多科学学科一样，在机器学习中，你需要进行一系列实验，并检查哪些数据有效，哪些无效。
你可以使用 Shell 轻松快速地搜索这些实验结果，并且以合理的方式汇总。这意味着需要在限定时间内或使用特定数据集的情况下，检查所有实验结果。通过使用JSON文件记录实验的所有相关参数，使用我们在本课程中介绍的工具，这件事情可以变得极其简单。
最后，如果你不使用集群提交你的 GPU 作业，那你应该研究如何使该过程自动化，因为这是一项非常耗时的任务，会消耗你的精力。

## 还有更多的 Vim 小窍门吗？

更多的窍门：

- 插件 - 花时间去探索插件。有很多不错的插件修复了vim的缺陷或者增加了能够与现有vim工作流结合的新功能。关于这部分内容，资源是[VimAwesome](https://vimawesome.com/) 和其他程序员的dotfiles。
- 标记 - 在vim里你可以使用 `m<X>` 为字母 `X` 做标记，之后你可以通过 `'<X>` 回到标记位置。这可以让你快速定位到文件内或文件间的特定位置。
- 导航 - `Ctrl+O` 和 `Ctrl+I` 命令可以使你在最近访问位置前后移动。
- 撤销树 - vim 有不错的更改跟踪机制，不同于其他的编辑器，vim存储变更树，因此即使你撤销后做了一些修改，你仍然可以通过撤销树的导航回到初始状态。一些插件比如 [gundo.vim](https://github.com/sjl/gundo.vim) 和 [undotree](https://github.com/mbbill/undotree) 通过图形化来展示撤销树。
- 时间撤销 - `:earlier` 和 `:later` 命令使得你可以用时间而非某一时刻的更改来定位文件。
- [持续撤销](https://vim.fandom.com/wiki/Using_undo_branches#Persistent_undo) - 是一个默认未被开启的vim的内置功能，它在vim启动之间保存撤销历史，需要配置在 `.vimrc` 目录下的`undofile` 和 `undodir`，vim会保存每个文件的修改历史。
- 热键（Leader Key） - 热键是一个用于用户自定义配置命令的特殊按键。这种模式通常是按下后释放这个按键（通常是空格键）并与其他的按键组合去实现一个特殊的命令。插件也会用这些按键增加它们的功能，例如，插件UndoTree使用 `<Leader> U` 去打开撤销树。
- 高级文本对象 - 文本对象比如搜索也可以用vim命令构成。例如，`d/<pattern>` 会删除下一处匹配 pattern 的字符串，`cgn` 可以用于更改上次搜索的关键字。

## 2FA是什么，为什么我需要使用它?

双因子验证（Two Factor Authentication 2FA）在密码之上为帐户增加了一层额外的保护。为了登录，你不仅需要知道密码，还必须以某种方式“证明”可以访问某些硬件设备。最简单的情形是可以通过接收手机的 SMS 来实现（尽管 SMS 2FA 存在 [已知问题](https://www.kaspersky.com/blog/2fa-practical-guide/24219/)）。我们推荐使用[YubiKey](https://www.yubico.com/)之类的[U2F](https://en.wikipedia.org/wiki/Universal_2nd_Factor)方案。

## 对于不同的 Web 浏览器有什么评价?

2020的浏览器现状是，大部分的浏览器都与 Chrome 类似，因为它们都使用同样的引擎(Blink)。Microsoft Edge 同样基于 Blink，而 Safari 则 基于WebKit(与Blink类似的引擎)，这些浏览器仅仅是更糟糕的 Chrome 版本。不管是在性能还是可用性上，Chrome 都是一款很不错的浏览器。如果你想要替代品，我们推荐 Firefox。Firefox 与 Chrome 的在各方面不相上下，并且在隐私方面更加出色。
有一款目前还没有完成的叫 Flow 的浏览器，它实现了全新的渲染引擎，有望比现有引擎速度更快。
