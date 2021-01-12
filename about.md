---
layout: lecture
title: "开设此课程的动机"
---

在传统的计算机科学课程中，从操作系统、编程语言到机器学习，这些高大上课程和主题已经非常多了。
然而有一个至关重要的主题却很少被专门讲授，而是留给学生们自己去探索。 这部分内容就是：精通工具。

这些年，我们在麻省理工学院参与了许多课程的助教活动，过程当中愈发意识到很多学生对于工具的了解知之甚少。
计算机设计的初衷就是任务自动化，然而学生们却常常陷在大量的重复任务中，或者无法完全发挥出诸如
版本控制、文本编辑器等工具的强大作用。效率低下和浪费时间还是其次，更糟糕的是，这还可能导致数据丢失或
无法完成某些特定任务。

这些主题不是大学课程的一部分：学生一直都不知道如何使用这些工具，或者说，至少是不知道如何高效
地使用，因此浪费了时间和精力在本来可以更简单的任务上。标准的计算机科学课程缺少了这门能让计算
变得更简捷的关键课程。

# The missing semester of your CS education

为了解决这个问题，我们开设了一个课程，涵盖各项对成为高效率计算机科学家或程序员至关重要的
主题。这个课程实用且具有很强的实践性，提供了各种能够立即广泛应用解决问题的趁手工具指导。
该课在 2020 年 1 月“独立活动期”开设，为期一个月，是学生开办的短期课程。虽然该课程针对
麻省理工学院，但我们公开提供了全部课程的录制视频与相关资料。

如果该课程适合你，那么以下还有一些具体的课程示例：

## 命令行与 shell 工具

如何使用别名、脚本和构建系统来自动化执行通用重复的任务。不再总是从文档中拷贝粘贴
命令。不要再“逐个执行这 15 个命令”，不要再“你忘了执行这个命令”、“你忘了传那个
参数”，类似的对话不要再有了。

例如，快速搜索历史记录可以节省大量时间。在下面这个示例中，我们展示了如何通过`convert`命令
在历史记录中跳转的一些技巧。

<video autoplay="autoplay" loop="loop" controls muted playsinline  oncontextmenu="return false;"  preload="auto"  class="demo">
  <source src="/static/media/demos/history.mp4" type="video/mp4">
</video>

## 版本控制

如何**正确地**使用版本控制，利用它避免尴尬的情况发生。与他人协作，并且能够快速定位
有问题的提交
不再大量注释代码。不再为解决 bug 而找遍所有代码。不再“我去，刚才是删了有用的代码？！”。
我们将教你如何通过拉取请求来为他人的项目贡献代码。

下面这个示例中，我们使用`git bisect`来定位哪个提交破坏了单元测试，并且通过`git rever`来进行修复。

<video autoplay="autoplay" loop="loop" controls muted playsinline  oncontextmenu="return false;"  preload="auto"  class="demo">
  <source src="/static/media/demos/git.mp4" type="video/mp4">
</video>

## 文本编辑

不论是本地还是远程，如何通过命令行高效地编辑文件，并且充分利用编辑器特性。不再来回复制
文件。不再重复编辑文件。

Vim 的宏是它最好的特性之一，在下面这个示例中，我们使用嵌套的 Vim 宏快速地将 html 表格转换成了 csv 格式。

<video autoplay="autoplay" loop="loop" controls muted playsinline  oncontextmenu="return false;"  preload="auto"  class="demo">
  <source src="/static/media/demos/vim.mp4" type="video/mp4">
</video>

## 远程服务器

使用 SSH 密钥连接远程机器进行工作时如何保持连接，并且让终端能够复用。不再为了仅执行个别命令
总是打开许多命令行终端。不再每次连接都总输入密码。不再因为网络断开或必须重启笔记本时
就丢失全部上下文。

以下示例，我们使用`tmux`来保持远程服务器的会话存在，并使用`mosh`来支持网络漫游和断开连接。

<video autoplay="autoplay" loop="loop" controls muted playsinline  oncontextmenu="return false;"  preload="auto"  class="demo">
  <source src="/static/media/demos/ssh.mp4" type="video/mp4">
</video>

## 查找文件

如何快速查找你需要的文件。不再挨个点击项目中的文件，直到找到你所需的代码。

以下示例，我们通过`fd`快速查找文件，通过`rg`找代码片段。我们也用到了`fasd`快速`cd`并`vim`最近/常用的文件/文件夹。

<video autoplay="autoplay" loop="loop" controls muted playsinline  oncontextmenu="return false;"  preload="auto"  class="demo">
  <source src="/static/media/demos/find.mp4" type="video/mp4">
</video>

## 数据处理

如何通过命令行直接轻松快速地修改、查看、解析、绘制和计算数据和文件。不再从日志文件拷贝
粘贴。不再手动统计数据。不再用电子表格画图。

## 虚拟机

如何使用虚拟机尝试新操作系统，隔离无关的项目，并且保持宿主机整洁。不再因为做安全实验而
意外损坏你的计算机。不再有大量随机安装的不同版本软件包。

## 安全

如何在不泄露隐私的情况下畅游互联网。不再抓破脑袋想符合自己疯狂规则的密码。不再连接不安全
的开放 WiFi 网络。不再传输未加密的信息。

# 结论

这 12 节课将包括但不限于以上内容，同时每堂课都提供了能帮助你熟悉这些工具的练手小测验。如果不能
等到一月，你也可以看下[黑客工具](https://hacker-tools.github.io/lectures/)，这是我们去年的
试讲。它是本课程的前身，包含许多相同的主题。

无论面对面还是远程在线，欢迎你的参与。

Happy hacking,<br>
Anish, Jose, and Jon
