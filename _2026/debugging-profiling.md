---
layout: lecture
title: "调试与性能分析"
description: >
  学习如何使用日志与调试器调试程序，以及如何对代码进行性能分析。
thumbnail: /static/assets/thumbnails/2026/lec4.png
date: 2026-01-15
ready: true
panopto: "https://mit.hosted.panopto.com/Panopto/Pages/Viewer.aspx?id=a72c48e3-5eb2-46fa-aa03-b3b700e1ca8d"
video:
  aspect: 56.25
  id: 8VYT9TcUmKs
---

编程里有一条金科玉律：代码不会按照你以为的方式运行，而只会按照你告诉它的方式运行。要弥合这两者之间的差距，有时并不容易。这节课我们会介绍一些处理有 bug 且资源消耗过高代码的实用技巧：调试与性能分析。

# 调试

## 打印调试与日志

> “最有效的调试工具，仍然是细致的思考，再配合审慎放置的打印语句。” —— Brian Kernighan，_Unix for Beginners_。

调试程序的第一种方法，是在你发现问题的位置附近加入打印语句，并不断重复这个过程，直到你提取出足够的信息，理解到底是什么导致了问题。

第二种方法，是在程序里使用日志，而不是临时加一些随手写的打印语句。日志本质上可以看作“更讲究的打印”，通常会通过日志框架来完成，并内建支持如下能力：

- 将日志（或其中一部分）输出到其他位置；
- 设置严重级别（例如 INFO、DEBUG、WARN、ERROR 等），并按级别过滤输出；
- 支持对与日志条目相关的数据进行结构化记录，便于事后更容易地提取和分析。

在编程时，你通常也会主动预先加上一些日志语句，这样等到需要调试时，所需数据可能早就已经在那里了！事实上，当你通过打印语句找到了并修复了一个问题之后，在删除这些打印之前，往往值得先把它们改成正式的日志语句。这样一来，如果将来再出现类似的 bug，你就已经拥有所需的诊断信息，无需再去修改代码。

> **第三方日志**：许多程序支持 `-v` 或 `--verbose` 参数，在运行时打印更多信息。这对找出某条命令为什么失败很有帮助。有些程序甚至允许重复传入该参数，以获得更详细的输出。调试服务（数据库、Web 服务器等）相关问题时，也要查看它们自己的日志，在 Linux 上通常位于 `/var/log/`。对使用 systemd 的服务，可以用 `journalctl -u <service>` 查看日志。对于第三方库，则可以看看它们是否支持通过环境变量或配置开启调试日志。

## 调试器

当你已经知道该打印什么、也能轻松修改并重新运行代码时，打印调试通常很好用。而当你不确定自己需要什么信息、bug 只会在难以复现的条件下出现，或者修改并重启程序的代价很高（启动时间很长、状态很难重建等）时，调试器就会变得非常有价值。

调试器是一类让你在程序运行过程中与其执行状态进行交互的工具，它可以让你：

- 在执行到某一行时暂停程序；
- 一次一步地执行程序；
- 在程序崩溃后检查变量的值；
- 在满足给定条件时有条件地暂停执行；
- 以及更多高级功能。

大多数编程语言都支持（或自带）某种形式的调试器。其中最通用的是 **通用调试器（general-purpose debuggers）**，比如 [`gdb`](https://www.gnu.org/software/gdb/) 和 [`lldb`](https://lldb.llvm.org/)；它们可以调试任何原生二进制程序。许多语言也有 **语言专用调试器（language-specific debuggers）**，能与运行时更紧密地集成（例如 Python 的 `pdb` 或 Java 的 `jdb`）。

`gdb` 是 C、C++、Rust 以及其他编译型语言事实上的标准调试器。它让你几乎可以探查任何进程，并查看其当前的机器状态：寄存器、栈、程序计数器等等。

一些常用的 GDB 命令：

- `run` - 启动程序
- `b {function}` 或 `b {file}:{line}` - 设置断点
- `c` - 继续执行
- `step` / `next` / `finish` - 步入 / 步过 / 步出
- `p {variable}` - 打印变量的值
- `bt` - 显示回溯（调用栈）
- `watch {expression}` - 当值发生变化时中断

> 可以考虑使用 GDB 的 TUI 模式（`gdb -tui`，或在 GDB 中按 `Ctrl-x a`），这样可以在分屏视图里同时看到源代码和命令提示符。

### 记录-回放调试

最让人抓狂的一类 bug 是 _Heisenbug_：你一试图观察它，它就消失了，或者行为发生改变。竞争条件、依赖时序的 bug，以及只会在特定系统条件下出现的问题，都属于这一类。传统调试在这里往往派不上用场，因为再次运行程序时，行为可能已经变了（比如加上打印语句后，代码可能被拖慢到足以让竞争条件不再出现）。

**记录-回放调试（record-replay debugging）** 的思路是：先记录程序的一次执行过程，再让你按确定性的方式反复回放，需要多少次都行。更棒的是，你甚至可以沿着执行过程倒着走，精确找出问题到底从哪里开始。

[rr](https://rr-project.org/) 是 Linux 上一个很强大的工具，它会记录程序执行过程，并允许你以完整的调试能力对其进行确定性回放。它与 GDB 配合使用，所以你已经熟悉它的界面了。

基本用法：

```bash
# 记录一次程序执行
rr record ./my_program

# 回放这次记录（会打开 GDB）
rr replay
```

真正神奇的部分发生在回放阶段。由于执行是确定性的，你可以使用 **反向调试（reverse debugging）** 命令：

- `reverse-continue` (`rc`) - 向后运行，直到碰到断点
- `reverse-step` (`rs`) - 向后单步执行一行
- `reverse-next` (`rn`) - 向后执行，但跳过函数调用
- `reverse-finish` - 向后运行，直到进入当前函数

这对调试来说非常强大。比如你遇到了一次崩溃，与其猜测 bug 在哪里并预先设断点，你可以：

1. 运行到崩溃点
2. 检查被破坏后的状态
3. 在被破坏的变量上设置监视点（watchpoint）
4. 使用 `reverse-continue` 精确找出它是在哪一行被破坏的

**什么时候用 rr：**
- 间歇性失败的 flaky 测试
- 竞争条件和线程相关 bug
- 难以复现的崩溃
- 任何让你希望自己“能回到过去”的 bug

> 注意：rr 只能在 Linux 上使用，并且要求硬件性能计数器可用。它无法在那些不暴露这类计数器的虚拟机里工作，例如大多数 AWS EC2 实例；它也不支持 GPU 访问。对于 macOS，可以看看 [Warpspeed](https://warpspeed.dev/)。

> **rr 与并发**：由于 rr 会以确定性的方式记录执行过程，它会把线程调度串行化。这意味着，如果某些竞争条件依赖于非常具体的时序，它们在 rr 下可能不会出现。rr 仍然很适合调试竞争问题，一旦你捕获到一次失败运行，就可以稳定地反复回放；但为了抓住间歇性 bug，你可能需要尝试多次录制。对于不涉及并发的 bug，rr 的优势尤其明显：你总能复现完全相同的执行过程，并用反向调试一路追踪到内存或状态被破坏的位置。

## 系统调用跟踪

有时你需要理解程序是如何与操作系统交互的。程序会通过 [系统调用](https://en.wikipedia.org/wiki/System_call) 向内核请求服务，例如打开文件、分配内存、创建进程等等。跟踪这些调用，可以帮助你发现程序为什么卡住、它在尝试访问哪些文件，或者它把时间花在了哪里等待。

### strace（Linux）与 dtruss（macOS）

[`strace`](https://www.man7.org/linux/man-pages/man1/strace.1.html) 可以让你观察一个程序发出的每一次系统调用：

```bash
# 跟踪所有系统调用
strace ./my_program

# 只跟踪与文件相关的调用
strace -e trace=file ./my_program

# 跟踪子进程（对会启动其他程序的程序很重要）
strace -f ./my_program

# 跟踪一个正在运行的进程
strace -p <PID>

# 显示时间信息
strace -T ./my_program
```

> 在 macOS 和 BSD 上，可以使用 [`dtruss`](https://www.manpagez.com/man/1/dtruss/)（它是对 `dtrace` 的封装）实现类似功能。

> 如果你想更深入理解 `strace`，可以看看 Julia Evans 那本很棒的 [strace zine](https://jvns.ca/strace-zine-unfolded.pdf)。

### bpftrace 与 eBPF

[eBPF](https://ebpf.io/)（extended Berkeley Packet Filter，扩展 Berkeley Packet Filter）是一项强大的 Linux 技术，允许在内核中运行受沙箱约束的程序。[`bpftrace`](https://github.com/iovisor/bpftrace) 提供了一种较高层次的语法，用来编写 eBPF 程序。这些程序本质上是在内核中执行的任意程序，因此表达能力极强（尽管语法也有点像 awk，一开始不太顺手）。它们最常见的用途，是调查系统到底调用了哪些系统调用，包括做聚合统计（例如计数或延迟分布），或查看系统调用参数（甚至按参数进行过滤）。

```bash
# 在整个系统范围内跟踪文件打开（会立即打印）
sudo bpftrace -e 'tracepoint:syscalls:sys_enter_openat { printf("%s %s\n", comm, str(args->filename)); }'

# 按名称统计系统调用（Ctrl-C 时打印汇总）
sudo bpftrace -e 'tracepoint:syscalls:sys_enter_* { @[probe] = count(); }'
```

不过，你也可以直接用 C 语言编写 eBPF 程序，并配合像 [`bcc`](https://github.com/iovisor/bcc) 这样的工具链。它还自带了[许多很实用的工具](https://www.brendangregg.com/blog/2015-09-22/bcc-linux-4.3-tracing.html)，例如 `biosnoop` 可以打印磁盘操作的延迟分布，`opensnoop` 可以打印所有打开过的文件。

`strace` 的优势在于上手快，很适合“先跑起来看看”；而当你需要更低开销、想跟踪内核函数、需要做聚合统计等时，就更应该使用 `bpftrace`。不过要注意，`bpftrace` 必须以 `root` 身份运行，而且它通常监控的是整个内核，而不是某一个特定进程。要把范围收窄到某个程序，你可以按命令名或 PID 过滤：

```bash
# 按命令名过滤（Ctrl-C 时打印汇总）
sudo bpftrace -e 'tracepoint:syscalls:sys_enter_* /comm == "bash"/ { @[probe] = count(); }'

# 用 -c 从程序启动时开始跟踪某个具体命令（cpid = 子进程 PID）
sudo bpftrace -e 'tracepoint:syscalls:sys_enter_* /pid == cpid/ { @[probe] = count(); }' -c 'ls -la'
```

`-c` 参数会运行给定命令，并把 `cpid` 设为该命令的 PID，这对从程序一启动就开始跟踪非常有用。当被跟踪的命令退出时，bpftrace 会打印聚合后的结果。

### 网络调试

对于网络问题，[`tcpdump`](https://www.man7.org/linux/man-pages/man1/tcpdump.1.html) 和 [Wireshark](https://www.wireshark.org/) 可以让你抓取并分析网络数据包：

```bash
# 抓取 80 端口上的数据包
sudo tcpdump -i any port 80

# 抓包并保存到文件中，供 Wireshark 分析
sudo tcpdump -i any -w capture.pcap
```

对于 HTTPS 流量，由于有加密，`tcpdump` 的作用就没那么大了。像 [mitmproxy](https://mitmproxy.org/) 这样的工具可以充当中间代理，帮助你检查加密后的流量。对于 Web 应用发出的 HTTPS 请求，浏览器开发者工具（Network 面板）通常是最简单的调试方式，因为它能直接显示解密后的请求/响应数据、请求头以及时间信息。

## 内存调试

内存 bug，比如缓冲区溢出、释放后使用（use-after-free）、内存泄漏，是最危险、也最难调试的一类问题。它们往往不会立刻崩溃，而是以破坏内存的方式埋下隐患，直到很久之后才表现出问题。

### Sanitizer（运行时检查器）

查找内存 bug 的一种方法是使用 **Sanitizer**，也就是编译器提供的一类运行时检查功能。它们会给代码插桩，在程序运行时检测错误。例如，广泛使用的 **AddressSanitizer（ASan）** 可以检测：

- 缓冲区溢出（栈、堆和全局区）
- 释放后使用
- 返回后使用（use-after-return）
- 内存泄漏

```bash
# 使用 AddressSanitizer 编译
gcc -fsanitize=address -g program.c -o program
./program
```

还有很多其他有用的 Sanitizer：

- **ThreadSanitizer（TSan）**：检测多线程代码中的数据竞争（`-fsanitize=thread`）
- **MemorySanitizer（MSan）**：检测对未初始化内存的读取（`-fsanitize=memory`）
- **UndefinedBehaviorSanitizer（UBSan）**：检测整数溢出等未定义行为（`-fsanitize=undefined`）

Sanitizer 需要重新编译，但速度已经足够快，适合放进 CI 流水线，也适合在日常开发中使用。

### Valgrind：当你无法重新编译时

[Valgrind](https://valgrind.org/) 则是以一种有点像虚拟机的方式运行你的程序，以检测内存错误。它比 Sanitizer 慢，但不需要重新编译：

```bash
valgrind --leak-check=full ./my_program
```

以下情况适合用 Valgrind：

- 你没有源代码
- 你无法重新编译（例如第三方库）
- 你需要使用 Sanitizer 没有提供的特定工具

Valgrind 实际上是一个非常强大的受控执行环境；等讲到性能分析时，我们还会再次见到它！

## 用 AI 辅助调试

大语言模型已经成了出人意料地好用的调试助手。它们在某些调试任务上表现出色，正好可以补上传统工具的短板。

**LLM 擅长的场景：**

- **解释晦涩的错误信息**：编译器错误，尤其是来自 C++ 模板或 Rust 借用检查器的报错，往往难懂得出名。LLM 可以把它们翻译成更直白的语言，并给出可能的修复方向。

- **跨越语言与抽象边界排查问题**：如果你在调试一个跨多种语言的问题（比如某个 C 库的 bug 通过 Python 绑定暴露出来），LLM 可以帮助你在不同层之间来回切换。它们尤其擅长理解 FFI 边界、构建系统问题，以及跨语言调试场景（例如“我的程序报错了，但我怀疑根因在某个依赖库里”）。

- **把症状和根因联系起来**：像“我的程序功能正常，但内存占用比预期高 10 倍”这种模糊症状，LLM 很擅长帮你展开排查，提出常见原因和应该关注的线索。

- **分析崩溃转储与栈跟踪**：你可以把一段栈跟踪（stack trace）贴进去，询问它可能的成因。

> **关于调试符号**：如果你希望得到有意义的栈跟踪和调试信息，请确保你的二进制程序（以及链接到的库）都带着调试符号编译（`-g` 标志）。调试信息通常以 DWARF 格式存储。另外，使用帧指针编译（`-fno-omit-frame-pointer`）也会让栈跟踪更可靠，尤其是对性能分析工具而言。否则，栈跟踪里可能只会出现内存地址，或者信息残缺不全。这个问题对原生编译程序（C++、Rust）比对 Python 或 Java 更重要。

**也要记住它的局限：**
- LLM 可能会一本正经地编造听起来很合理、但其实是错的解释
- 它们可能会给出“掩盖 bug”而不是“修复 bug”的方案
- 一定要用真正的调试工具验证它给出的建议
- 它们最适合作为补充，而不是替代你对自己代码的理解

> 这和在“开发环境”那一讲中提到的[通用 AI 编程能力](/2026/development-environment/#ai-powered-development)不是一回事。这里讨论的是把 LLM 当作调试辅助工具来使用。

# 性能分析

即使你的代码在功能上完全符合预期，但如果它在运行过程中耗尽了所有 CPU 或内存资源，那也未必算得上足够好。算法课通常会教大 _O_ 记号，却很少教你如何找出程序里的热点（hot spots）。鉴于[过早优化是万恶之源](https://wiki.c2.com/?PrematureOptimization)，你应该了解性能分析器（profilers）和监控工具。它们会帮助你理解程序中究竟是哪一部分消耗了最多的时间和资源，从而把优化精力集中在真正值得优化的地方。

## 计时

衡量性能最简单的方法，就是直接计时。在很多场景下，你只需要打印出代码在两个时间点之间执行了多久，就已经足够了。

不过，墙上时间（wall clock time）有时会产生误导，因为你的计算机可能同时还在运行其他进程，或者在等待某些事件发生。`time` 命令会区分 _Real_、_User_ 和 _Sys_ 三种时间：

- **Real** - 从开始到结束的真实墙上时间，包括等待的时间
- **User** - CPU 执行用户态代码所花费的时间
- **Sys** - CPU 执行内核态代码所花费的时间

```bash
$ time curl https://missing.csail.mit.edu &> /dev/null
real	0m0.272s
user	0m0.079s
sys	    0m0.028s
```

这里这个请求花了接近 300 毫秒的真实时间（real），但 CPU 时间（user + sys）只有 107ms。剩下的时间都花在等待网络上了。

## 资源监控

有时候，分析程序性能的第一步，是先弄清楚它实际消耗了哪些资源。程序运行缓慢，往往只是因为它受到了资源限制。

- **通用监控**：[`htop`](https://htop.dev/) 是 `top` 的增强版，可以用更友好的方式展示当前运行进程的各种统计信息。常用快捷键包括：`<F6>` 用于排序进程，`t` 用于显示树状层级，`h` 用于切换线程显示。还有一个 [`btop`](https://github.com/aristocratos/btop)，能监控的东西就更多了。

- **I/O 操作**：[`iotop`](https://www.man7.org/linux/man-pages/man8/iotop.8.html) 可以实时显示 I/O 使用情况。

- **内存使用**：[`free`](https://www.man7.org/linux/man-pages/man1/free.1.html) 可以显示总内存、空闲内存和已用内存。

- **打开的文件**：[`lsof`](https://www.man7.org/linux/man-pages/man8/lsof.8.html) 会列出进程打开的文件信息。它很适合用来检查某个具体文件当前被哪个进程打开了。

- **网络连接**：[`ss`](https://www.man7.org/linux/man-pages/man8/ss.8.html) 可以监控网络连接。一个常见用途是查出某个端口被哪个进程占用了：`ss -tlnp | grep :8080`。

- **网络使用情况**：[`nethogs`](https://github.com/raboof/nethogs) 和 [`iftop`](https://pdw.ex-parrot.com/iftop/) 都是很不错的交互式 CLI 工具，可以按进程监控网络流量。

## 性能数据可视化

人类在图表里识别模式的速度，远快于在一堆数字表格里。分析性能时，把数据画出来，往往能看见原始数字里完全看不出来的趋势、尖峰和异常。

**让数据易于绘图**：在为了调试而加打印或日志语句时，不妨顺手把输出格式设计成之后容易拿去画图的样子。一个简单的 CSV 格式时间戳和值（如 `1705012345,42.5`），会比一句自然语言描述更容易绘图。JSON 结构化日志同样也很容易被解析并拿去作图。换句话说，要[用整洁数据（tidy data）的方式](https://vita.had.co.nz/papers/tidy-data.pdf)记录你的数据。

**用 gnuplot 快速绘图**：如果只是做简单的命令行绘图，[`gnuplot`](http://www.gnuplot.info/) 可以直接从数据文件生成图表：

```bash
# 绘制一个简单的 timestamp,value CSV
gnuplot -e "set datafile separator ','; plot 'latency.csv' using 1:2 with lines"
```

**用 matplotlib 和 ggplot2 做迭代式探索**：如果你需要更深入的分析，Python 的 [`matplotlib`](https://matplotlib.org/) 和 R 的 [`ggplot2`](https://ggplot2.tidyverse.org/) 很适合做迭代式探索。与一次性画图不同，这些工具可以让你快速切片、变换数据，并用来验证假设。ggplot2 的 facet 图尤其强大，你可以按类别把同一份数据拆成多个子图（比如按 endpoint 或一天中的时间段来拆请求延迟），从而挖出原本隐藏的模式。

**示例用法：**
- 绘制请求延迟随时间的变化，能看出原始分位数里会掩盖掉的周期性变慢现象（比如垃圾回收、定时任务、流量波动）
- 将一个不断增长的数据结构的插入时间可视化，可以暴露算法复杂度问题，例如对 vector 插入的图会在底层数组翻倍扩容时出现典型尖峰
- 按不同维度（请求类型、用户群体、服务器）做分面，往往会揭示出所谓“全系统问题”其实只集中在某一个类别里

## CPU 分析器

大多数时候，人们提到 _profilers_ 时，说的都是 _CPU profiler_。它们主要分为两类：

- **追踪式分析器（tracing profilers）** 会记录程序发出的每一次函数调用
- **采样式分析器（sampling profilers）** 会周期性地探测你的程序（通常是每毫秒一次），并记录程序的调用栈

采样式分析器开销更低，因此通常更适合在生产环境中使用。

### perf：采样式分析器

[`perf`](https://www.man7.org/linux/man-pages/man1/perf.1.html) 是 Linux 上的标准性能分析工具。它可以在无需重新编译的情况下分析任何程序：

`perf stat` 可以快速给你一个时间花在哪儿的整体概览：

```bash
$ perf stat ./slow_program

 Performance counter stats for './slow_program':

         3,210.45 msec task-clock                #    0.998 CPUs utilized
               12      context-switches          #    3.738 /sec
                0      cpu-migrations            #    0.000 /sec
              156      page-faults               #   48.587 /sec
   12,345,678,901      cycles                    #    3.845 GHz
    9,876,543,210      instructions              #    0.80  insn per cycle
    1,234,567,890      branches                  #  384.532 M/sec
       12,345,678      branch-misses             #    1.00% of all branches
```

真实程序的 profiler 输出往往会包含海量信息。人类是视觉动物，而我们其实并不擅长直接阅读一大堆数字。[火焰图（flame graph）](https://www.brendangregg.com/flamegraphs.html) 就是一种让性能分析数据更容易理解的可视化方式。

火焰图在 Y 轴上展示函数调用层级，在 X 轴上按比例展示耗时。它通常还是可交互的，你可以点击后缩放到程序的某个局部。

[![FlameGraph](https://www.brendangregg.com/FlameGraphs/cpu-bash-flamegraph.svg)](https://www.brendangregg.com/FlameGraphs/cpu-bash-flamegraph.svg)

如果要从 `perf` 数据生成火焰图：

```bash
# 记录性能分析数据
perf record -g ./my_program

# 生成火焰图（需要 flamegraph 脚本）
perf script | stackcollapse-perf.pl | flamegraph.pl > flamegraph.svg
```

> 你也可以考虑使用 [Speedscope](https://www.speedscope.app/) 这样的交互式 Web 火焰图查看器，或者使用 [Perfetto](https://perfetto.dev/) 做更完整的系统级分析。

### Valgrind 的 Callgrind：追踪式分析器

[`callgrind`](https://valgrind.org/docs/manual/cl-manual.html) 是一个性能分析工具，它会记录程序的调用历史和指令计数。与采样式分析器不同，它可以提供精确的调用次数，并展示调用者与被调用者之间的关系：

```bash
# 用 callgrind 运行
valgrind --tool=callgrind ./my_program

# 用 callgrind_annotate（文本）或 kcachegrind（GUI）分析
callgrind_annotate callgrind.out.<pid>
kcachegrind callgrind.out.<pid>
```

Callgrind 比采样式分析器更慢，但它能提供精确的调用次数；如果你需要的话，它还可以额外模拟缓存行为（使用 `--cache-sim=yes`）。

> 如果你使用的是某种特定语言，也可能会有更专门的分析器。例如，Python 有 [`cProfile`](https://docs.python.org/3/library/profile.html) 和 [`py-spy`](https://github.com/benfred/py-spy)，Go 有 [`go tool pprof`](https://pkg.go.dev/cmd/pprof)，Rust 有 [`cargo-flamegraph`](https://github.com/flamegraph-rs/flamegraph)（实际上它对任何编译型程序都能用！）。

## 内存分析器

内存分析器能帮助你理解程序是如何随时间使用内存的，并找出内存泄漏。

### Valgrind 的 Massif

[`massif`](https://valgrind.org/docs/manual/ms-manual.html) 用来分析堆内存使用情况：

```bash
valgrind --tool=massif ./my_program
ms_print massif.out.<pid>
```

它会向你展示堆内存随时间的变化，从而帮助识别内存泄漏和过度分配的问题。

> 对于 Python，[`memory-profiler`](https://pypi.org/project/memory-profiler/) 可以提供逐行的内存使用信息。

## 基准测试

当你需要比较不同实现或不同工具的性能时，[`hyperfine`](https://github.com/sharkdp/hyperfine) 非常适合拿来给命令行程序做基准测试：

```bash
$ hyperfine --warmup 3 'fd -e jpg' 'find . -iname "*.jpg"'
Benchmark #1: fd -e jpg
  Time (mean ± σ):      51.4 ms ±   2.9 ms    [User: 121.0 ms, System: 160.5 ms]
  Range (min … max):    44.2 ms …  60.1 ms    56 runs

Benchmark #2: find . -iname "*.jpg"
  Time (mean ± σ):      1.126 s ±  0.101 s    [User: 141.1 ms, System: 956.1 ms]
  Range (min … max):    0.975 s …  1.287 s    10 runs

Summary
  'fd -e jpg' ran
   21.89 ± 2.33 times faster than 'find . -iname "*.jpg"'
```

> 对于 Web 开发，浏览器开发者工具里自带了非常不错的性能分析器。可以看看 [Firefox Profiler](https://profiler.firefox.com/docs/) 和 [Chrome DevTools](https://developers.google.com/web/tools/chrome-devtools/rendering-tools) 的文档。

# 练习

## 调试

1. **调试一个排序算法**：下面的伪代码实现了归并排序，但其中包含一个 bug。请用你熟悉的任意编程语言实现它，然后用调试器（gdb、lldb、pdb 或 IDE 自带调试器）找出并修复这个 bug。

   ```
   function merge_sort(arr):
       if length(arr) <= 1:
           return arr
       mid = length(arr) / 2
       left = merge_sort(arr[0..mid])
       right = merge_sort(arr[mid..end])
       return merge(left, right)

   function merge(left, right):
       result = []
       i = 0, j = 0
       while i < length(left) AND j < length(right):
           if left[i] <= right[j]:
               append result, left[i]
               i = i + 1
           else:
               append result, right[i]
               j = j + 1
       append remaining elements from left and right
       return result
   ```

   测试向量：`merge_sort([3, 1, 4, 1, 5, 9, 2, 6])` 应该返回 `[1, 1, 2, 3, 4, 5, 6, 9]`。请使用断点，并在 `merge` 函数里逐步执行，找出错误元素是在哪里被选出来的。

1. 安装 [`rr`](https://rr-project.org/)，并用反向调试找出一个内存破坏 bug。将下面这个程序保存为 `corruption.c`：

   ```c
   #include <stdio.h>

   typedef struct {
       int id;
       int scores[3];
   } Student;

   Student students[2];

   void init() {
       students[0].id = 1001;
       students[0].scores[0] = 85;
       students[0].scores[1] = 92;
       students[0].scores[2] = 78;

       students[1].id = 1002;
       students[1].scores[0] = 90;
       students[1].scores[1] = 88;
       students[1].scores[2] = 95;
   }

   void curve_scores(int student_idx, int curve) {
       for (int i = 0; i < 4; i++) {
           students[student_idx].scores[i] += curve;
       }
   }

   int main() {
       init();
       printf("=== Initial state ===\n");
       printf("Student 0: id=%d\n", students[0].id);
       printf("Student 1: id=%d\n", students[1].id);

       curve_scores(0, 5);

       printf("\n=== After curving ===\n");
       printf("Student 0: id=%d\n", students[0].id);
       printf("Student 1: id=%d\n", students[1].id);

       if (students[1].id != 1002) {
           printf("\nERROR: Student 1's ID was corrupted! Expected 1002, got %d\n",
                  students[1].id);
           return 1;
       }
       return 0;
   }
   ```

   用 `gcc -g corruption.c -o corruption` 编译并运行它。Student 1 的 ID 会被破坏，但发生破坏的位置却在一个只会修改 student 0 的函数里。请使用 `rr record ./corruption` 和 `rr replay` 找出真正的罪魁祸首。在 `students[1].id` 上设置一个 watchpoint，并在发生破坏之后使用 `reverse-continue`，精确定位是哪一行代码改写了它。

1. 用 AddressSanitizer 调试一个内存错误。将下面内容保存为 `uaf.c`：

   ```c
   #include <stdlib.h>
   #include <string.h>
   #include <stdio.h>

   int main() {
       char *greeting = malloc(32);
       strcpy(greeting, "Hello, world!");
       printf("%s\n", greeting);

       free(greeting);

       greeting[0] = 'J';
       printf("%s\n", greeting);

       return 0;
   }
   ```

   先在不开启 Sanitizer 的情况下编译并运行：`gcc uaf.c -o uaf && ./uaf`。它看起来可能还能“正常工作”。然后再用 AddressSanitizer 编译：`gcc -fsanitize=address -g uaf.c -o uaf && ./uaf`。阅读错误报告。ASan 找到了什么 bug？修复它指出的问题。

1. 使用 `strace`（Linux）或 `dtruss`（macOS）跟踪一个像 `ls -l` 这样的命令发出的系统调用。它到底调用了哪些系统调用？再试着跟踪一个更复杂的程序，看看它打开了哪些文件。

1. 用一个 LLM 来帮助你理解一条晦涩的错误信息。可以试着复制一条编译器报错（尤其是来自 C++ 模板或 Rust 的），请它解释原因并给出修复思路。你也可以把 `strace` 的一部分输出，或者 AddressSanitizer 的报错内容粘进去试试看。

## 性能分析

1. 对你自己选择的一个程序运行 `perf stat`，获取基础性能统计信息。不同的计数器分别代表什么？

1. 使用 `perf record` 做性能分析。将下面内容保存为 `slow.c`：

   ```c
   #include <math.h>
   #include <stdio.h>

   double slow_computation(int n) {
       double result = 0;
       for (int i = 0; i < n; i++) {
           for (int j = 0; j < 1000; j++) {
               result += sin(i * j) * cos(i + j);
           }
       }
       return result;
   }

   int main() {
       double r = 0;
       for (int i = 0; i < 100; i++) {
           r += slow_computation(1000);
       }
       printf("Result: %f\n", r);
       return 0;
   }
   ```

   带着调试符号编译：`gcc -g -O2 slow.c -o slow -lm`。运行 `perf record -g ./slow`，然后运行 `perf report` 看看时间主要花在了哪里。再试试用 flamegraph 脚本生成一张火焰图。

1. 用 `hyperfine` 比较同一任务的两种不同实现（例如 `find` 对比 `fd`、`grep` 对比 `ripgrep`，或者你自己代码的两个版本）。

1. 运行一个资源密集型程序的同时，使用 `htop` 监控系统。再试试用 `taskset` 限制进程可用的 CPU：`taskset --cpu-list 0,2 stress -c 3`。为什么 `stress` 没有用满三个 CPU？

1. 一个很常见的问题是：你想监听的端口已经被另一个进程占用了。学会找出这个进程：先执行 `python -m http.server 4444`，在 4444 端口启动一个最小 Web 服务器；然后在另一个终端运行 `ss -tlnp | grep 4444` 找出对应进程；最后用 `kill <PID>` 结束它。
