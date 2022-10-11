---
layout: lecture
title: "大杂烩"
date: 2022-10-26
ready: true
sync: true
syncdate: 2021-04-24
video:
  aspect: 56.25
  id: JZDt-PRq0uo
---

## 目录

- [修改键位映射](#%E4%BF%AE%E6%94%B9%E9%94%AE%E4%BD%8D%E6%98%A0%E5%B0%84)
- [守护进程](#%E5%AE%88%E6%8A%A4%E8%BF%9B%E7%A8%8B)
- [FUSE](#fuse)
- [备份](#%E5%A4%87%E4%BB%BD)
- [API（应用程序接口）](#API%EF%BC%88%E5%BA%94%E7%94%A8%E7%A8%8B%E5%BA%8F%E6%8E%A5%E5%8F%A3%EF%BC%89)
- [常见命令行标志参数及模式](#%E5%B8%B8%E8%A7%81%E5%91%BD%E4%BB%A4%E8%A1%8C%E6%A0%87%E5%BF%97%E5%8F%82%E6%95%B0%E5%8F%8A%E6%A8%A1%E5%BC%8F)
- [窗口管理器](#%E7%AA%97%E5%8F%A3%E7%AE%A1%E7%90%86%E5%99%A8)
- [VPN](#vpn)
- [Markdown](#markdown)
- [Hammerspoon (macOS桌面自动化)](#Hammerspoon%20(macOS%E6%A1%8C%E9%9D%A2%E8%87%AA%E5%8A%A8%E5%8C%96))
  - [资源](#%E8%B5%84%E6%BA%90)
- [开机引导以及 Live USB](#%E5%BC%80%E6%9C%BA%E5%BC%95%E5%AF%BC%E4%BB%A5%E5%8F%8A%20Live%20USB)
- [Docker, Vagrant, VMs, Cloud, OpenStack](#docker-vagrant-vms-cloud-openstack)
- [交互式记事本编程](#%E4%BA%A4%E4%BA%92%E5%BC%8F%E8%AE%B0%E4%BA%8B%E6%9C%AC%E7%BC%96%E7%A8%8B)
- [GitHub](#github)

## 修改键位映射
作为一名程序员，键盘是你的主要输入工具。它像计算机里的其他部件一样是可配置的，而且值得你在这上面花时间。

一个很常见的配置是修改键位映射。通常这个功能由在计算机上运行的软件实现。当某一个按键被按下，软件截获键盘发出的按键事件（keypress event）并使用另外一个事件取代。比如：
- 将 Caps Lock 映射为 Ctrl 或者 Escape：Caps Lock 使用了键盘上一个非常方便的位置而它的功能却很少被用到，所以我们（讲师）非常推荐这个修改；
- 将 PrtSc 映射为播放/暂停：大部分操作系统支持播放/暂停键；
- 交换 Ctrl 和 Meta 键（Windows 的徽标键或者 Mac 的 Command 键）。

你也可以将键位映射为任意常用的指令。软件监听到特定的按键组合后会运行设定的脚本。
- 打开一个新的终端或者浏览器窗口；
- 输出特定的字符串，比如：一个超长邮件地址或者 MIT ID；
- 使计算机或者显示器进入睡眠模式。

甚至更复杂的修改也可以通过软件实现：
- 映射按键顺序，比如：按 Shift 键五下切换大小写锁定；
- 区别映射单点和长按，比如：单点 Caps Lock 映射为 Escape，而长按 Caps Lock 映射为 Ctrl；
- 对不同的键盘或软件保存专用的映射配置。

下面是一些修改键位映射的软件：
- macOS - [karabiner-elements](https://pqrs.org/osx/karabiner/), [skhd](https://github.com/koekeishiya/skhd) 或者 [BetterTouchTool](https://folivora.ai/)
- Linux - [xmodmap](https://wiki.archlinux.org/index.php/Xmodmap) 或者 [Autokey](https://github.com/autokey/autokey)
- Windows - 控制面板，[AutoHotkey](https://www.autohotkey.com/) 或者 [SharpKeys](https://www.randyrants.com/category/sharpkeys/)
- QMK - 如果你的键盘支持定制固件，[QMK](https://docs.qmk.fm/) 可以直接在键盘的硬件上修改键位映射。保留在键盘里的映射免除了在别的机器上的重复配置。

## 守护进程

即便守护进程（daemon）这个词看上去有些陌生，你应该已经大约明白它的概念。大部分计算机都有一系列在后台保持运行，不需要用户手动运行或者交互的进程。这些进程就是守护进程。以守护进程运行的程序名一般以 `d` 结尾，比如 SSH 服务端 `sshd`，用来监听传入的 SSH 连接请求并对用户进行鉴权。

Linux 中的 `systemd`（the system daemon）是最常用的配置和运行守护进程的方法。运行 `systemctl status` 命令可以看到正在运行的所有守护进程。这里面有很多可能你没有见过，但是掌管了系统的核心部分的进程：管理网络、DNS解析、显示系统的图形界面等等。用户使用 `systemctl` 命令和 `systemd` 交互来`enable`（启用）、`disable`（禁用）、`start`（启动）、`stop`（停止）、`restart`（重启）、或者`status`（检查）配置好的守护进程及系统服务。

`systemd` 提供了一个很方便的界面用于配置和启用新的守护进程或系统服务。下面的配置文件使用了守护进程来运行一个简单的 Python 程序。文件的内容非常直接所以我们不对它详细阐述。`systemd` 配置文件的详细指南可参见 [freedesktop.org](https://www.freedesktop.org/software/systemd/man/systemd.service.html)。

```ini
# /etc/systemd/system/myapp.service
[Unit]
# 配置文件描述
Description=My Custom App
# 在网络服务启动后启动该进程
After=network.target

[Service]
# 运行该进程的用户
User=foo
# 运行该进程的用户组
Group=foo
# 运行该进程的根目录
WorkingDirectory=/home/foo/projects/mydaemon
# 开始该进程的命令
ExecStart=/usr/bin/local/python3.7 app.py
# 在出现错误时重启该进程
Restart=on-failure

[Install]
# 相当于Windows的开机启动。即使GUI没有启动，该进程也会加载并运行
WantedBy=multi-user.target
# 如果该进程仅需要在GUI活动时运行，这里应写作：
# WantedBy=graphical.target
# graphical.target在multi-user.target的基础上运行和GUI相关的服务
```

如果你只是想定期运行一些程序，可以直接使用 [`cron`](https://www.man7.org/linux/man-pages/man8/cron.8.html)。它是一个系统内置的，用来执行定期任务的守护进程。


## FUSE

现在的软件系统一般由很多模块化的组件构建而成。你使用的操作系统可以通过一系列共同的方式使用不同的文件系统上的相似功能。比如当你使用 `touch` 命令创建文件的时候，`touch` 使用系统调用（system call）向内核发出请求。内核再根据文件系统，调用特有的方法来创建文件。这里的问题是，UNIX 文件系统在传统上是以内核模块的形式实现，导致只有内核可以进行文件系统相关的调用。

[FUSE](https://en.wikipedia.org/wiki/Filesystem_in_Userspace)（用户空间文件系统）允许运行在用户空间上的程序实现文件系统调用，并将这些调用与内核接口联系起来。在实践中，这意味着用户可以在文件系统调用中实现任意功能。

FUSE 可以用于实现如：一个将所有文件系统操作都使用 SSH 转发到远程主机，由远程主机处理后返回结果到本地计算机的虚拟文件系统。这个文件系统里的文件虽然存储在远程主机，对于本地计算机上的软件而言和存储在本地别无二致。`sshfs`就是一个实现了这种功能的 FUSE 文件系统。

一些有趣的 FUSE 文件系统包括：
- [sshfs](https://github.com/libfuse/sshfs)：使用 SSH 连接在本地打开远程主机上的文件
- [rclone](https://rclone.org/commands/rclone_mount/)：将 Dropbox、Google Drive、Amazon S3、或者 Google Cloud Storage 一类的云存储服务挂载为本地文件系统
- [gocryptfs](https://nuetzlich.net/gocryptfs/)：覆盖在加密文件上的文件系统。文件以加密形式保存在磁盘里，但该文件系统挂载后用户可以直接从挂载点访问文件的明文
- [kbfs](https://keybase.io/docs/kbfs)：分布式端到端加密文件系统。在这个文件系统里有私密（private），共享（shared），以及公开（public）三种类型的文件夹
- [borgbackup](https://borgbackup.readthedocs.io/en/stable/usage/mount.html)：方便用户浏览删除重复数据后的压缩加密备份

## 备份

任何没有备份的数据都可能在一个瞬间永远消失。复制数据很简单，但是可靠地备份数据很难。下面列举了一些关于备份的基础知识，以及一些常见做法容易掉进的陷阱。

首先，复制存储在同一个磁盘上的数据不是备份，因为这个磁盘是一个单点故障（single point of failure）。这个磁盘一旦出现问题，所有的数据都可能丢失。放在家里的外置磁盘因为火灾、抢劫等原因可能会和源数据一起丢失，所以是一个弱备份。推荐的做法是将数据备份到不同的地点存储。

同步方案也不是备份。即使方便如 Dropbox 或者 Google Drive，当数据在本地被抹除或者损坏，同步方案可能会把这些“更改”同步到云端。同理，像 RAID 这样的磁盘镜像方案也不是备份。它不能防止文件被意外删除、损坏、或者被勒索软件加密。

有效备份方案的几个核心特性是：版本控制，删除重复数据，以及安全性。对备份的数据实施版本控制保证了用户可以从任何记录过的历史版本中恢复数据。在备份中检测并删除重复数据，使其仅备份增量变化可以减少存储开销。在安全性方面，作为用户，你应该考虑别人需要有什么信息或者工具才可以访问或者完全删除你的数据及备份。最后一点，不要盲目信任备份方案。用户应该经常检查备份是否可以用来恢复数据。

备份不限制于备份在本地计算机上的文件。云端应用的重大发展使得我们很多的数据只存储在云端。当我们无法登录这些应用，在云端存储的网络邮件，社交网络上的照片，流媒体音乐播放列表，以及在线文档等等都会随之丢失。用户应该有这些数据的离线备份，而且已经有项目可以帮助下载并存储它们。

如果想要了解更多具体内容，请参考本课程2019年关于备份的[课堂笔记](/2019/backups)。


## API（应用程序接口）

关于如何使用计算机有效率地完成 _本地_ 任务，我们这堂课已经介绍了很多方法。这些方法在互联网上其实也适用。大多数线上服务提供的 API（应用程序接口）让你可以通过编程方式来访问这些服务的数据。比如，美国国家气象局就提供了一个可以从 shell 中获取天气预报的 API。

这些 API 大多具有类似的格式。它们的结构化 URL 通常使用 `api.service.com` 作为根路径，用户可以访问不同的子路径来访问需要调用的操作，以及添加查询参数使 API 返回符合查询参数条件的结果。

以美国天气数据为例，为了获得某个地点的天气数据，你可以发送一个 GET 请求（比如使用`curl`）到[`https://api.weather.gov/points/42.3604,-71.094`](https://api.weather.gov/points/42.3604,-71.094)。返回中会包括一系列用于获取特定信息（比如小时预报、气象观察站信息等）的 URL。通常这些返回都是`JSON`格式，你可以使用[`jq`](https://stedolan.github.io/jq/)等工具来选取需要的部分。

有些需要认证的 API 通常要求用户在请求中加入某种私密令牌（secret token）来完成认证。请阅读你想访问的 API 所提供的文档来确定它请求的认证方式，但是其实大多数 API 都会使用 [OAuth](https://www.oauth.com/)。OAuth 通过向用户提供一系列仅可用于该 API 特定功能的私密令牌进行校验。因为使用了有效 OAuth 令牌的请求在 API 看来就是用户本人发出的请求，所以请一定保管好这些私密令牌。否则其他人就可以冒用你的身份进行任何你可以在这个 API 上进行的操作。

[IFTTT](https://ifttt.com/) 这个网站可以将很多 API 整合在一起，让某 API 发生的特定事件触发在其他 API 上执行的任务。IFTTT 的全称If This Then That 足以说明它的用法，比如在检测到用户的新推文后，自动发布在其他平台。但是你可以对它支持的 API 进行任意整合，所以试着来设置一下任何你需要的功能吧！

## 常见命令行标志参数及模式

命令行工具的用法千差万别，阅读 `man` 页面可以帮助你理解每种工具的用法。即便如此，下面我们将介绍一下命令行工具一些常见的共同功能。

 - 大部分工具支持 `--help` 或者类似的标志参数（flag）来显示它们的简略用法。
 - 会造成不可撤回操作的工具一般会提供“空运行”（dry run）标志参数，这样用户可以确认工具真实运行时会进行的操作。这些工具通常也会有“交互式”（interactive）标志参数，在执行每个不可撤回的操作前提示用户确认。
 - `--version` 或者 `-V` 标志参数可以让工具显示它的版本信息（对于提交软件问题报告非常重要）。
 - 基本所有的工具支持使用 `--verbose` 或者 `-v` 标志参数来输出详细的运行信息。多次使用这个标志参数，比如 `-vvv`，可以让工具输出更详细的信息（经常用于调试）。同样，很多工具支持 `--quiet` 标志参数来抑制除错误提示之外的其他输出。
 - 大多数工具中，使用 `-` 代替输入或者输出文件名意味着工具将从标准输入（standard input）获取所需内容，或者向标准输出（standard output）输出结果。
 - 会造成破坏性结果的工具一般默认进行非递归的操作，但是支持使用“递归”（recursive）标志函数（通常是 `-r`）。
 - 有的时候你可能需要向工具传入一个 _看上去_ 像标志参数的普通参数，比如：
   - 使用 `rm` 删除一个叫 `-r` 的文件；
   - 在通过一个程序运行另一个程序的时候（`ssh machine foo`），向内层的程序（`foo`）传递一个标志参数。
   
   这时候你可以使用特殊参数 `--` 让某个程序 _停止处理_ `--` 后面出现的标志参数以及选项（以 `-` 开头的内容）：
    - `rm -- -r` 会让 `rm` 将 `-r` 当作文件名；
    - `ssh machine --for-ssh -- foo --for-foo` 的 `--` 会让 `ssh` 知道 `--for-foo` 不是 `ssh` 的标志参数。

## 窗口管理器

大部分人适应了 Windows、macOS、以及 Ubuntu 默认的“拖拽”式窗口管理器。这些窗口管理器的窗口一般就堆在屏幕上，你可以拖拽改变窗口的位置、缩放窗口、以及让窗口堆叠在一起。这种堆叠式（floating/stacking）管理器只是窗口管理器中的一种。特别在 Linux 中，有很多种其他的管理器。

平铺式（tiling）管理器就是一个常见的替代。顾名思义，平铺式管理器会把不同的窗口像贴瓷砖一样平铺在一起而不和其他窗口重叠。这和 [tmux](https://github.com/tmux/tmux) 管理终端窗口的方式类似。平铺式管理器按照写好的布局显示打开的窗口。如果只打开一个窗口，它会填满整个屏幕。新开一个窗口的时候，原来的窗口会缩小到比如三分之二或者三分之一的大小来腾出空间。打开更多的窗口会让已有的窗口进一步调整。

就像 tmux 那样，平铺式管理器可以让你在完全不使用鼠标的情况下使用键盘切换、缩放、以及移动窗口。它们值得一试！

## VPN

VPN 现在非常火，但我们不清楚这是不是因为[一些好的理由](https://gist.github.com/joepie91/5a9909939e6ce7d09e29)。你应该了解 VPN 能提供的功能和它的限制。使用了 VPN 的你对于互联网而言，**最好的情况**下也就是换了一个网络供应商（ISP）。所有你发出的流量看上去来源于 VPN 供应商的网络而不是你的“真实”地址，而你实际接入的网络只能看到加密的流量。

虽然这听上去非常诱人，但是你应该知道使用 VPN 只是把原本对网络供应商的信任放在了 VPN 供应商那里——网络供应商 _能看到的_，VPN 供应商 _也都能看到_。如果相比网络供应商你更信任 VPN 供应商，那当然很好。反之，则连接VPN的价值不明确。机场的不加密公共热点确实不可以信任，但是在家庭网络环境里，这个差异就没有那么明显。

你也应该了解现在大部分包含用户敏感信息的流量已经被 HTTPS 或者 TLS 加密。这种情况下你所处的网络环境是否“安全”不太重要：供应商只能看到你和哪些服务器在交谈，却不能看到你们交谈的内容。

这一切的大前提都是“最好的情况”。曾经发生过 VPN 提供商错误使用弱加密或者直接禁用加密的先例。另外，有些恶意的或者带有投机心态的供应商会记录和你有关的所有流量，并很可能会将这些信息卖给第三方。找错一家 VPN 经常比一开始就不用 VPN 更危险。

MIT 向有访问校内资源需求的成员开放自己运营的 [VPN](https://ist.mit.edu/vpn)。如果你也想自己配置一个 VPN，可以了解一下 [WireGuard](https://www.wireguard.com/) 以及 [Algo](https://github.com/trailofbits/algo)。

## Markdown

你在职业生涯中大概率会编写各种各样的文档。在很多情况下这些文档需要使用标记来增加可读性，比如：插入粗体或者斜体内容，增加页眉、超链接、以及代码片段。

在不使用 Word 或者 LaTeX 等复杂工具的情况下，你可以考虑使用 [Markdown](https://commonmark.org/help/) 这个轻量化的标记语言（markup language）。你可能已经见过 Markdown 或者它的一个变种。很多环境都支持并使用 Markdown 的一些子功能。

Markdown 致力于将人们编写纯文本时的一些习惯标准化。比如：
- 用`*`包围的文字表示强调（*斜体*），或者用`**`表示特别强调（**粗体**）；
- 以`#`开头的行是标题，`#`的数量表示标题的级别，比如：`##二级标题`；
- 以`-`开头代表一个无序列表的元素。一个数字加`.`（比如`1.`）代表一个有序列表元素；
- 反引号 `` ` ``（backtick）包围的文字会以`代码字体`显示。如果要显示一段代码，可以在每一行前加四个空格缩进，或者使用三个反引号包围整个代码片段：

    ```
    就像这样
    ```
- 如果要添加超链接，将 _需要显示_ 的文字用方括号包围，并在后面紧接着用圆括号包围链接：`[显示文字](指向的链接)`。

Markdown 不仅容易上手，而且应用非常广泛。实际上本课程的课堂笔记和其他资料都是使用 Markdown 编写的。点击[这个链接](https://github.com/missing-semester-cn/missing-semester-cn.github.io/blob/master/_2020/potpourri.md)可以看到本页面的原始 Markdown 内容。



## Hammerspoon (macOS 桌面自动化)

[Hammerspoon](https://www.hammerspoon.org/) 是面向 macOS 的一个桌面自动化框架。它允许用户编写和操作系统功能挂钩的 Lua 脚本，从而与键盘、鼠标、窗口、文件系统等交互。

下面是 Hammerspoon 的一些示例应用：

- 绑定移动窗口到的特定位置的快捷键
- 创建可以自动将窗口整理成特定布局的菜单栏按钮
- 在你到实验室以后，通过检测所连接的 WiFi 网络自动静音扬声器
- 在你不小心拿了朋友的充电器时弹出警告

从用户的角度，Hammerspoon 可以运行任意 Lua 代码，绑定菜单栏按钮、按键、或者事件。Hammerspoon 提供了一个全面的用于和系统交互的库，因此它能没有限制地实现任何功能。你可以从头编写自己的 Hammerspoon 配置，也可以结合别人公布的配置来满足自己的需求。

### 资源

- [Getting Started with Hammerspoon](https://www.hammerspoon.org/go/)：Hammerspoon 官方教程
- [Sample configurations](https://github.com/Hammerspoon/hammerspoon/wiki/Sample-Configurations)：Hammerspoon 官方示例配置
- [Anish's Hammerspoon config](https://github.com/anishathalye/dotfiles-local/tree/mac/hammerspoon)：Anish 的 Hammerspoon 配置

## 开机引导以及 Live USB

在你的计算机启动时，[BIOS](https://en.wikipedia.org/wiki/BIOS) 或者 [UEFI](https://en.wikipedia.org/wiki/Unified_Extensible_Firmware_Interface) 会在加载操作系统之前对硬件系统进行初始化，这被称为引导（booting）。你可以通过按下计算机提示的键位组合来配置引导，比如 `Press F9 to configure BIOS. Press F12 to enter boot menu`。在 BIOS 菜单中你可以对硬件相关的设置进行更改，也可以在引导菜单中选择从硬盘以外的其他设备加载操作系统——比如 Live USB。

[Live USB](https://en.wikipedia.org/wiki/Live_USB) 是包含了完整操作系统的闪存盘。Live USB 的用途非常广泛，包括：
 - 作为安装操作系统的启动盘；
 - 在不将操作系统安装到硬盘的情况下，直接运行 Live USB 上的操作系统；
 - 对硬盘上的相同操作系统进行修复；
 - 恢复硬盘上的数据。

Live USB 通过在闪存盘上 _写入_ 操作系统的镜像制作，而写入不是单纯的往闪存盘上复制 `.iso` 文件。你可以使用 [UNetbootin](https://unetbootin.github.io/) 、[Rufus](https://github.com/pbatard/rufus) 等 Live USB 写入工具制作。

## Docker, Vagrant, VMs, Cloud, OpenStack

[虚拟机](https://en.wikipedia.org/wiki/Virtual_machine)（Virtual Machine）以及容器化（containerization）等工具可以帮助你模拟一个包括操作系统的完整计算机系统。虚拟机可以用于创建独立的测试或者开发环境，以及用作安全测试的沙盒。

[Vagrant](https://www.vagrantup.com/) 是一个构建和配置虚拟开发环境的工具。它支持用户在配置文件中写入比如操作系统、系统服务、需要安装的软件包等描述，然后使用 `vagrant up` 命令在各种环境（VirtualBox，KVM，Hyper-V等）中启动一个虚拟机。[Docker](https://www.docker.com/) 是一个使用容器化概念的类似工具。

租用云端虚拟机可以享受以下资源的即时访问：

- 便宜、常开、且有公共IP地址的虚拟机用来托管网站等服务
- 有大量 CPU、磁盘、内存、以及 GPU 资源的虚拟机
- 超出用户可以使用的物理主机数量的虚拟机
  - 相比物理主机的固定开支，虚拟机的开支一般按运行的时间计算。所以如果用户只需要在短时间内使用大量算力，租用1000台虚拟机运行几分钟明显更加划算。

受欢迎的 VPS 服务商有 [Amazon AWS](https://aws.amazon.com/)，[Google Cloud](https://cloud.google.com/)、[ Microsoft Azure](https://azure.microsoft.com/)以及[DigitalOcean](https://www.digitalocean.com/)。

MIT CSAIL 的成员可以使用 [CSAIL OpenStack instance](https://tig.csail.mit.edu/shared-computing/open-stack/)
申请免费的虚拟机用于研究。

## 交互式记事本编程

[交互式记事本](https://en.wikipedia.org/wiki/Notebook_interface)可以帮助开发者进行与运行结果交互等探索性的编程。现在最受欢迎的交互式记事本环境大概是 [Jupyter](https://jupyter.org/)。它的名字来源于所支持的三种核心语言：Julia、Python、R。[Wolfram Mathematica](https://www.wolfram.com/mathematica/) 是另外一个常用于科学计算的优秀环境。

## GitHub

[GitHub](https://github.com/) 是最受欢迎的开源软件开发平台之一。我们课程中提到的很多工具，从 [vim](https://github.com/vim/vim) 到
[Hammerspoon](https://github.com/Hammerspoon/hammerspoon)，都托管在 Github 上。向你每天使用的开源工具作出贡献其实很简单，下面是两种贡献者们经常使用的方法：

- 创建一个[议题（issue）](https://help.github.com/en/github/managing-your-work-on-github/creating-an-issue)。
议题可以用来反映软件运行的问题或者请求新的功能。创建议题并不需要创建者阅读或者编写代码，所以它是一个轻量化的贡献方式。高质量的问题报告对于开发者十分重要。在现有的议题发表评论也可以对项目的开发作出贡献。
- 使用[拉取请求（pull request）](https://help.github.com/en/github/collaborating-with-issues-and-pull-requests/about-pull-requests)提交代码更改。由于涉及到阅读和编写代码，提交拉取请求总的来说比创建议题更加深入。拉取请求是请求别人把你自己的代码拉取（且合并）到他们的仓库里。很多开源项目仅允许认证的管理者管理项目代码，所以一般需要[复刻（fork）](https://help.github.com/en/github/getting-started-with-github/fork-a-repo)这些项目的上游仓库（upstream repository），在你的 Github 账号下创建一个内容完全相同但是由你控制的复刻仓库。这样你就可以在这个复刻仓库自由创建新的分支并推送修复问题或者实现新功能的代码。完成修改以后再回到开源项目的 Github 页面[创建一个拉取请求](https://help.github.com/en/github/collaborating-with-issues-and-pull-requests/creating-a-pull-request)。

提交请求后，项目管理者会和你交流拉取请求里的代码并给出反馈。如果没有问题，你的代码会和上游仓库中的代码合并。很多大的开源项目会提供贡献指南，容易上手的议题，甚至专门的指导项目来帮助参与者熟悉这些项目。
