---
layout: lecture
title: "调试与性能分析"
description: >
  学习如何使用日志和调试器调试程序，以及如何对代码进行性能分析。
thumbnail: /static/assets/thumbnails/2026/lec4.png
date: 2026-01-15
ready: true
panopto: "https://mit.hosted.panopto.com/Panopto/Pages/Viewer.aspx?id=a72c48e3-5eb2-46fa-aa03-b3b700e1ca8d"
video:
  aspect: 56.25
  id: 8VYT9TcUmKs
---

编程中的一条黄金法则是：代码不会做你期望它做的事，而是做你告诉它做的事。弥合这一差距有时是一项相当困难的壮举。在本讲座中，我们将介绍处理有缺陷和资源消耗大的代码的有用技术：调试和性能分析。

# 调试

## Printf 调试和日志

> "最有效的调试工具仍然是仔细的思考，加上明智地放置的打印语句" —— Brian Kernighan，_Unix for Beginners_。

调试程序的第一种方法是在发现问题的地方添加打印语句，并不断迭代，直到提取到足够的信息来理解是什么导致了该问题。

第二种方法是在程序中使用日志，而不是临时打印语句。日志本质上是"更谨慎地打印"，通常通过日志框架完成，该框架内置支持以下功能：

- 将日志（或日志的子集）定向到其他输出位置的能力；
- 设置严重级别（如 INFO、DEBUG、WARN、ERROR 等），并允许你根据这些级别过滤输出；以及
- 支持与日志条目相关的数据的结构化日志记录，以便事后更容易提取。

在编程时，你通常也会主动添加日志语句，以便你需要的调试数据可能已经在那里了！
事实上，一旦你用打印语句找到并修复了问题，在删除它们之前，通常值得将这些打印转换为适当的日志语句。这样，如果将来出现类似的错误，你就已经拥有了所需的诊断信息，而无需修改代码。

> **第三方日志**：许多程序支持 `-v` 或 `--verbose` 标志，以便在运行时打印更多信息。这有助于发现给定命令失败的原因。有些甚至允许重复该标志以获取更多详细信息。调试服务（数据库、Web 服务器等）问题时，请检查它们的日志——在 Linux 上通常在 `/var/log/` 中。使用 `journalctl -u <service>` 查看 systemd 服务的日志。对于第三方库，请检查它们是否通过环境变量或配置支持调试日志记录。

## 调试器

当你知道要打印什么并且可以轻松地修改和重新运行代码时，打印调试效果很好。当你不确定需要什么信息时，当错误只在难以复现的条件下出现时，或者当修改和重新启动程序成本高昂（启动时间长、需要重新创建复杂状态等）时，调试器就变得有价值了。

调试器是让你在程序执行时与其执行进行交互的程序，允许你：

- 当执行到达某一行时暂停执行。
- 一次执行一条指令。
- 在崩溃后检查变量的值。
- 当给定条件满足时有条件地暂停执行。
- 以及许多其他高级功能。

大多数编程语言都支持（或附带）某种形式的调试器。最通用的是**通用调试器**，如 [`gdb`](https://www.gnu.org/software/gdb/)（GNU 调试器）和 [`lldb`](https://lldb.llvm.org/)（LLVM 调试器），它们可以调试任何原生二进制文件。许多语言还有**语言特定的调试器**，它们与运行时更紧密地集成（如 Python 的 pdb 或 Java 的 jdb）。

`gdb` 是 C、C++、Rust 和其他编译语言的事实标准调试器。它可以探测几乎任何进程，并获取其当前的机器状态：寄存器、栈、程序计数器等。

一些有用的 GDB 命令：

- `run` - 启动程序
- `b {function}` 或 `b {file}:{line}` - 设置断点
- `c` - 继续执行
- `step` / `next` / `finish` - 步入 / 步过 / 步出
- `p {variable}` - 打印变量的值
- `bt` - 显示回溯（调用栈）
- `watch {expression}` - 当值变化时中断

> 考虑使用 GDB 的 TUI 模式（`gdb -tui` 或在 GDB 中按 `Ctrl-x a`）以获得分屏视图，在命令提示符旁边显示源代码。

### 记录-重放调试

一些最令人沮丧的错误是 _Heisenbugs_（海森堡bug）：当你试图观察它们时，它们似乎会消失或改变行为的错误。竞态条件、与时间相关的错误以及只在特定系统条件下出现的问题都属于这一类。传统的调试在这里通常毫无用处，因为再次运行程序会产生不同的行为（例如，打印语句可能会减慢代码的速度，以至于竞态不再发生）。

**记录-重放调试**通过记录程序的执行并允许你以确定性的方式重放它来解决这个问题，你需要多少次就可以重放多少次。更好的是，你可以_反向_执行以准确找出问题出在哪里。

[rr](https://rr-project.org/) 是 Linux 的一个强大工具，它记录程序执行并允许具有完整调试功能的确定性重放。它与 GDB 配合使用，所以你已经在使用熟悉的界面了。

基本用法：

```bash
# 记录程序执行
rr record ./my_program

# 重放记录（打开 GDB）
rr replay
```

重放时会发生神奇的事情。因为执行是确定性的，你可以使用**反向调试**命令：

- `reverse-continue` (`rc`) - 向后运行直到命中断点
- `reverse-step` (`rs`) - 向后单步执行一行
- `reverse-next` (`rn`) - 向后步过，跳过函数调用
- `reverse-finish` - 向后运行直到进入当前函数

这对调试来说非常强大。假设你遇到了崩溃——无需猜测错误在哪里并设置断点，你可以：

1. 运行到崩溃点
2. 检查损坏的状态
3. 在损坏的变量上设置观察点
4. 使用 `reverse-continue` 准确找到它是在哪里被损坏的

**何时使用 rr：**
- 间歇性失败的不可靠测试
- 竞态条件和线程错误
- 难以复现的崩溃
- 任何你希望"回到过去"的错误

> 注意：rr 只在 Linux 上工作，需要硬件性能计数器。它在不暴露这些计数器的虚拟机中不工作，例如在大多数 AWS EC2 实例上，并且它不支持 GPU 访问。对于 macOS，请查看 [Warpspeed](https://warpspeed.dev/)。

> **rr 和并发性**：因为 rr 确定性地记录执行，它会序列化线程调度。这意味着如果某些竞态条件依赖于特定的时间，它们可能在 rr 下不会出现。rr 对于调试竞态仍然有用——一旦你捕获了一次失败的运行，你就可以可靠地重放它——但你可能需要多次记录尝试才能捕获间歇性错误。对于不涉及并发的错误，rr 最出色：你总能复现确切的执行，并使用反向调试来追踪损坏。

## 系统调用追踪

有时你需要了解程序如何与操作系统交互。程序通过[系统调用](https://en.wikipedia.org/wiki/System_call)向内核请求服务——打开文件、分配内存、创建进程等。追踪这些调用可以揭示程序为什么挂起、它试图访问哪些文件，或者它在哪里花时间等待。

### strace（Linux）和 dtruss（macOS）

[`strace`](https://www.man7.org/linux/man-pages/man1/strace.1.html) 让你观察程序发出的每个系统调用：

```bash
# 追踪所有系统调用
strace ./my_program

# 只追踪与文件相关的调用
strace -e trace=file ./my_program

# 跟随子进程（对于启动其他程序的程序很重要）
strace -f ./my_program

# 追踪运行中的进程
strace -p <PID>

# 显示时间信息
strace -T ./my_program
```

> 在 macOS 和 BSD 上，使用 [`dtruss`](https://www.manpagez.com/man/1/dtruss/)（它包装了 `dtrace`）来实现类似功能：

> 要深入了解 `strace`，请查看 Julia Evans 的优秀 [strace zine](https://jvns.ca/strace-zine-unfolded.pdf)。

### bpftrace 和 eBPF

[eBPF](https://ebpf.io/)（扩展伯克利包过滤器）是一种强大的 Linux 技术，允许在内核中运行沙盒程序。[`bpftrace`](https://github.com/iovisor/bpftrace) 为编写 eBPF 程序提供了高级语法。这些是在内核中运行的任意程序，因此具有巨大的表达能力（尽管也有类似 awk 的笨拙语法）。它们最常见的用例是调查正在调用哪些系统调用，包括聚合（如计数或延迟统计）或检查（甚至过滤）系统调用参数。

```bash
# 系统范围追踪文件打开（立即打印）
sudo bpftrace -e 'tracepoint:syscalls:sys_enter_openat { printf("%s %s\n", comm, str(args->filename)); }'

# 按名称计数系统调用（Ctrl-C 时打印摘要）
sudo bpftrace -e 'tracepoint:syscalls:sys_enter_* { @[probe] = count(); }'
```

但是，你也可以使用像 [`bcc`](https://github.com/iovisor/bcc) 这样的工具链直接用 C 编写 eBPF 程序，它还附带[许多方便的工具](https://www.brendangregg.com/blog/2015-09-22/bcc-linux-4.3-tracing.html)，如 `biosnoop` 用于打印磁盘操作的延迟分布，或 `opensnoop` 用于打印所有打开的文件。

`strace` 有用是因为它很容易"启动并运行"，而当你需要更低的开销、想追踪内核函数、需要做某种聚合等时，`bpftrace` 是你应该选择的工具。不过请注意，`bpftrace` 必须以 `root` 身份运行，而且它通常监控整个内核，而不仅仅是特定进程。要针对特定程序，你可以按命令名或 PID 过滤：

```bash
# 按命令名过滤（Ctrl-C 时打印摘要）
sudo bpftrace -e 'tracepoint:syscalls:sys_enter_* /comm == "bash"/ { @[probe] = count(); }'

# 使用 -c 从启动开始追踪特定命令（cpid = 子进程 PID）
sudo bpftrace -e 'tracepoint:syscalls:sys_enter_* /pid == cpid/ { @[probe] = count(); }' -c 'ls -la'
```

`-c` 标志运行指定的命令并将 `cpid` 设置为它的 PID，这对于从程序启动的那一刻开始追踪很有用。当被追踪的命令退出时，bpftrace 打印聚合结果。

### 网络调试

对于网络问题，[`tcpdump`](https://www.man7.org/linux/man-pages/man1/tcpdump.1.html) 和 [Wireshark](https://www.wireshark.org/) 让你捕获和分析网络数据包：

```bash
# 捕获端口 80 上的数据包
sudo tcpdump -i any port 80

# 捕获并保存到文件以供 Wireshark 分析
sudo tcpdump -i any -w capture.pcap
```

对于 HTTPS 流量，加密使 tcpdump 不太有用。像 [mitmproxy](https://mitmproxy.org/) 这样的工具可以作为拦截代理来检查加密流量。浏览器开发者工具（网络选项卡）通常是调试来自 Web 应用程序的 HTTPS 请求的最简单方法——它们显示解密后的请求/响应数据、头部和计时信息。

## 内存调试

内存错误——缓冲区溢出、释放后使用、内存泄漏——是最危险和最难调试的。它们通常不会立即崩溃，而是以导致问题很久之后才出现的方式损坏内存。

### Sanitizers（消毒器）

查找内存错误的一种方法是使用 **sanitizers**，它们是编译器功能，可在运行时检测代码中的错误。例如，广泛使用的 **AddressSanitizer (ASan)** 检测：
- 缓冲区溢出（栈、堆和全局）
- 释放后使用
- 返回后使用
- 内存泄漏

```bash
# 使用 AddressSanitizer 编译
gcc -fsanitize=address -g program.c -o program
./program
```

有各种有用的 sanitizer：

- **ThreadSanitizer (TSan)**：检测多线程代码中的数据竞态（`-fsanitize=thread`）
- **MemorySanitizer (MSan)**：检测对未初始化内存的读取（`-fsanitize=memory`）
- **UndefinedBehaviorSanitizer (UBSan)**：检测未定义行为，如整数溢出（`-fsanitize=undefined`）

Sanitizer 需要重新编译，但速度足够快，可以在 CI 管道和常规开发中使用。

### Valgrind：当你无法重新编译时

[Valgrind](https://valgrind.org/) 而是在类似虚拟机的环境中运行你的程序以检测内存错误。它比 sanitizer 慢，但不需要重新编译：

```bash
valgrind --leak-check=full ./my_program
```

在以下情况使用 Valgrind：
- 你没有源代码
- 你无法重新编译（第三方库）
- 你需要 sanitizer 中不可用的特定工具

Valgrind 实际上是一个非常强大的受控执行环境，我们将在后面进行性能分析时看到更多关于它的内容！

## AI 用于调试

大型语言模型已经成为令人惊讶地有用的调试助手。它们擅长某些与传统工具互补的调试任务。

**LLM 的闪光之处：**

- **解释晦涩的错误消息**：编译器错误，尤其是来自 C++ 模板或 Rust 借用检查器的错误， notoriously（臭名昭著地）晦涩。LLM 可以将它们翻译成简单的英语并提出修复建议。

- **跨越语言和抽象边界**：如果你正在调试一个跨越多种语言的问题（比如 C 库中的错误通过 Python 绑定表现出来），LLM 可以帮助导航不同的层。它们特别擅长理解 FFI 边界、构建系统问题和跨语言调试（例如，我的程序出错，但我相信是因为我的一个依赖项中有错误）。

- **将症状与根本原因相关联**："我的程序运行正常但使用的内存比预期多 10 倍"是 LLM 可以帮助调查的模糊症状类型，提出可能的原因和要查找的内容。

- **分析崩溃转储和堆栈跟踪**：粘贴堆栈跟踪并询问可能是什么原因造成的。

> **关于调试符号的说明**：为了获得有意义的堆栈跟踪和调试，请确保你的二进制文件（和任何链接的库）都使用调试符号编译（`-g` 标志）。调试信息通常以 DWARF 格式存储。此外，使用帧指针编译（`-fno-omit-frame-pointer`）使堆栈跟踪更可靠，特别是对于性能分析工具。如果没有这些，堆栈跟踪可能只显示内存地址或不完整。这对于原生编译的程序（C++、Rust）比 Python 或 Java 更重要。

**需要记住的限制：**
- LLM 可能会产生听起来合理但错误的解释
- 它们可能会建议掩盖错误而不是修复它的修复方法
- 始终使用实际的调试工具验证建议
- 它们最好作为理解你代码的补充，而不是替代

> 这与开发环境讲座中涵盖的[通用 AI 编码能力](/2026/development-environment/#ai-powered-development)不同。这里我们专门讨论使用 LLM 作为调试辅助工具。

# 性能分析

即使你的代码在功能上表现如你所期望，但如果它在过程中占用了你所有的 CPU 或内存，那可能还不够好。算法课程经常教授大 _O_ 表示法，但没有教授如何在你的程序中找到热点。既然[过早优化是所有罪恶的根源](https://wiki.c2.com/?PrematureOptimization)，你应该了解性能分析器和监控工具。它们将帮助你了解程序的哪些部分占用了大部分时间和/或资源，这样你就可以专注于优化这些部分。

## 计时

测量性能最简单的方法是计时。在许多场景中，只需打印代码在两点之间花费的时间就足够了。

然而，挂钟时间可能会产生误导，因为你的计算机可能同时运行其他进程或等待事件发生。`time` 命令区分 _Real_、_User_ 和 _Sys_ 时间：

- **Real** - 从开始到结束的挂钟时间，包括等待的时间
- **User** - CPU 运行用户代码所花费的时间
- **Sys** - CPU 运行内核代码所花费的时间

```bash
$ time curl https://missing.csail.mit.edu &> /dev/null
real	0m0.272s
user	0m0.079s
sys	    0m0.028s
```

这里请求花费了近 300 毫秒（实际时间），但只有 107 毫秒的 CPU 时间（user + sys）。其余时间都在等待网络。

## 资源监控

有时，分析程序性能的第一步是了解其实际资源消耗。当资源受限时，程序通常运行缓慢。

- **通用监控**：[`htop`](https://htop.dev/) 是 `top` 的改进版本，显示当前运行进程的各种统计信息。有用的快捷键：`<F6>` 排序进程，`t` 显示树形层次结构，`h` 切换线程。还有 [`btop`](https://github.com/aristocratos/btop)，它监控_更多_东西。

- **I/O 操作**：[`iotop`](https://www.man7.org/linux/man-pages/man8/iotop.8.html) 显示实时 I/O 使用信息。

- **内存使用**：[`free`](https://www.man7.org/linux/man-pages/man1/free.1.html) 显示总空闲和已用内存。

- **打开的文件**：[`lsof`](https://www.man7.org/linux/man-pages/man8/lsof.8.html) 列出进程打开的文件信息。用于检查哪个进程打开了特定文件。

- **网络连接**：[`ss`](https://www.man7.org/linux/man-pages/man8/ss.8.html) 让你监控网络连接。一个常见的用例是找出哪个进程正在使用给定端口：`ss -tlnp | grep :8080`。

- **网络使用**：[`nethogs`](https://github.com/raboof/nethogs) 和 [`iftop`](https://pdw.ex-parrot.com/iftop/) 是用于监控每个进程网络使用的良好交互式 CLI 工具。

## 可视化性能数据

人类在图表中发现模式的速度比在一堆数字中快得多。在分析性能时，绘制数据通常可以揭示原始数字中看不到的趋势、峰值和异常。

**使数据可绘制**：在为调试添加打印或日志语句时，请考虑格式化输出，以便以后可以轻松绘制。CSV 格式中的简单时间戳和值（`1705012345,42.5`）比散文句子更容易绘制。JSON 结构化日志也可以用最小的努力解析和绘制。换句话说，以[整洁的方式](https://vita.had.co.nz/papers/tidy-data.pdf)记录你的数据。

**使用 gnuplot 快速绘图**：对于简单的命令行绘图，[`gnuplot`](http://www.gnuplot.info/) 可以直接从数据文件生成图表：

```bash
# 绘制带有时间戳、值的简单 CSV
gnuplot -e "set datafile separator ','; plot 'latency.csv' using 1:2 with lines"
```

**使用 matplotlib 和 ggplot2 进行迭代探索**：对于更深入的分析，Python 的 [`matplotlib`](https://matplotlib.org/) 和 R 的 [`ggplot2`](https://ggplot2.tidyverse.org/) 支持迭代探索。与一次性绘图不同，这些工具允许你快速切片和转换数据以调查假设。ggplot2 的分面图特别强大——你可以按类别将单个数据集拆分到多个子图中（例如，按端点或一天中的时间分面请求延迟），以梳理出否则会被隐藏的模式。

**示例用例：**
- 随时间绘制请求延迟可以揭示周期性减速（垃圾回收、cron 作业、流量模式），原始百分位数会掩盖这些
- 可视化增长数据结构的插入时间可以暴露算法复杂性问题——向量插入的图表将在后备数组大小加倍时显示特征性峰值
- 按不同维度（请求类型、用户群、服务器）分面指标通常可以揭示"系统范围"的问题实际上只孤立在一个类别中

## CPU 性能分析器

大多数时候，当人们提到_性能分析器_时，他们指的是_CPU 性能分析器_。有两种主要类型：

- **追踪性能分析器**记录程序进行的每个函数调用
- **采样性能分析器**定期探测你的程序（通常每毫秒一次）并记录程序的堆栈

采样性能分析器开销较低，通常更适合生产使用。

### perf：采样性能分析器

[`perf`](https://www.man7.org/linux/man-pages/man1/perf.1.html) 是标准的 Linux 性能分析器。它可以在不重新编译的情况下分析任何程序：

`perf stat` 给你一个关于时间花在哪里的快速概览：

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

真实世界程序的性能分析器输出将包含大量信息。人类是视觉生物，相当不擅长阅读大量数字。[火焰图](https://www.brendangregg.com/flamegraphs.html)是一种可视化，使性能分析数据更容易理解。

火焰图在 Y 轴上显示函数调用层次结构，X 轴上与时间成比例。它们是交互式的——你可以点击缩放到程序的特定部分。

[![FlameGraph](https://www.brendangregg.com/FlameGraphs/cpu-bash-flamegraph.svg)](https://www.brendangregg.com/FlameGraphs/cpu-bash-flamegraph.svg)

从 `perf` 数据生成火焰图：

```bash
# 记录性能分析
perf record -g ./my_program

# 生成火焰图（需要火焰图脚本）
perf script | stackcollapse-perf.pl | flamegraph.pl > flamegraph.svg
```

> 考虑使用 [Speedscope](https://www.speedscope.app/) 作为基于 Web 的交互式火焰图查看器，或使用 [Perfetto](https://perfetto.dev/) 进行全面的系统级分析。

### Valgrind 的 Callgrind：追踪性能分析器

[`callgrind`](https://valgrind.org/docs/manual/cl-manual.html) 是一种性能分析工具，记录程序的调用历史和指令计数。与采样性能分析器不同，它提供精确的调用计数，并可以显示调用者和被调用者之间的关系：

```bash
# 使用 callgrind 运行
valgrind --tool=callgrind ./my_program

# 使用 callgrind_annotate（文本）或 kcachegrind（GUI）分析
callgrind_annotate callgrind.out.<pid>
kcachegrind callgrind.out.<pid>
```

Callgrind 比采样性能分析器慢，但提供精确的调用计数，如果需要这些信息，还可以选择模拟缓存行为（使用 `--cache-sim=yes`）。

> 如果你使用特定语言，可能有更专业的性能分析器。例如，Python 有 [`cProfile`](https://docs.python.org/3/library/profile.html) 和 [`py-spy`](https://github.com/benfred/py-spy)，Go 有 [`go tool pprof`](https://pkg.go.dev/cmd/pprof)，Rust 有 [`cargo-flamegraph`](https://github.com/flamegraph-rs/flamegraph)（实际上适用于任何编译程序！）。

## 内存性能分析器

内存性能分析器帮助你了解程序随时间如何使用内存并发现内存泄漏。

### Valgrind 的 Massif

[`massif`](https://valgrind.org/docs/manual/ms-manual.html) 分析堆内存使用情况：

```bash
valgrind --tool=massif ./my_program
ms_print massif.out.<pid>
```

这显示了随时间的堆使用情况，帮助识别内存泄漏和过度分配。

> 对于 Python，[`memory-profiler`](https://pypi.org/project/memory-profiler/) 提供逐行内存使用信息。

## 基准测试

当你需要比较不同实现或工具的性能时，[`hyperfine`](https://github.com/sharkdp/hyperfine) 是用于对命令行程序进行基准测试的优秀工具：

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

> 对于 Web 开发，浏览器开发者工具包括优秀的性能分析器。请参阅 [Firefox Profiler](https://profiler.firefox.com/docs/) 和 [Chrome DevTools](https://developers.google.com/web/tools/chrome-devtools/rendering-tools) 文档。

# 练习

## 调试

1. **调试排序算法**：以下伪代码实现了归并排序，但包含一个错误。用你选择的语言实现它，然后使用调试器（gdb、lldb、pdb 或你 IDE 的调试器）查找并修复错误。

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

   测试向量：`merge_sort([3, 1, 4, 1, 5, 9, 2, 6])` 应返回 `[1, 1, 2, 3, 4, 5, 6, 9]`。使用断点并逐步执行合并函数，找出错误元素被选择的位置。

1. 安装 [`rr`](https://rr-project.org/) 并使用反向调试查找损坏错误。将此程序保存为 `corruption.c`：

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

   使用 `gcc -g corruption.c -o corruption` 编译并运行。学生 1 的 ID 被损坏，但损坏发生在只接触学生 0 的函数中。使用 `rr record ./corruption` 和 `rr replay` 查找罪魁祸首。在 `students[1].id` 上设置观察点，并在损坏后使用 `reverse-continue` 准确找到哪行代码覆盖了它。

1. 使用 AddressSanitizer 调试内存错误。将其保存为 `uaf.c`：

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

   首先在不使用 sanitizer 的情况下编译和运行：`gcc uaf.c -o uaf && ./uaf`。它可能看起来可以工作。现在使用 AddressSanitizer 编译：`gcc -fsanitize=address -g uaf.c -o uaf && ./uaf`。读取错误报告。ASan 发现了什么错误？修复它识别的问题。

1. 使用 `strace`（Linux）或 `dtruss`（macOS）追踪像 `ls -l` 这样的命令发出的系统调用。它在执行什么系统调用？尝试追踪一个更复杂的程序，看看它打开了哪些文件。

1. 使用 LLM 帮助调试晦涩的错误消息。尝试复制编译器错误（特别是来自 C++ 模板或 Rust 的）并请求解释和修复。尝试将一些来自 `strace` 或地址 sanitizer 的输出放入其中。

## 性能分析

1. 使用 `perf stat` 获取你选择的程序的基本性能统计信息。不同的计数器是什么意思？

1. 使用 `perf record` 进行性能分析。将其保存为 `slow.c`：

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

   使用调试符号编译：`gcc -g -O2 slow.c -o slow -lm`。运行 `perf record -g ./slow`，然后运行 `perf report` 查看时间花在哪里。尝试使用火焰图脚本生成火焰图。

1. 使用 `hyperfine` 对同一任务的两种不同实现进行基准测试（例如，`find` vs `fd`，`grep` vs `ripgrep`，或你自己代码的两个版本）。

1. 运行资源密集型程序时使用 `htop` 监控你的系统。尝试使用 `taskset` 限制进程可以使用的 CPU：`taskset --cpu-list 0,2 stress -c 3`。为什么 `stress` 不使用三个 CPU？

1. 一个常见问题是，你想要监听的端口已被另一个进程占用。了解如何发现该进程：首先执行 `python -m http.server 4444` 以在端口 4444 上启动一个最小的 Web 服务器。在单独的终端上运行 `ss -tlnp | grep 4444` 以查找进程。使用 `kill <PID>` 终止它。
