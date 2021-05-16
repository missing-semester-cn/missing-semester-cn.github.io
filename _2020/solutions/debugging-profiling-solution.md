---
layout: page
title: Solution-调试与性能分析
solution: true
---


## 1. 调试
1. 使用 Linux 上的 `journalctl` 或 macOS 上的 `log show` 命令来获取最近一天中超级用户的登录信息及其所执行的指令。如果找不到相关信息，您可以执行一些无害的命令，例如`sudo ls` 然后再次查看。
    这里我在树莓派上查询相关日志
    ```bash
    pi@raspberrypi:~$ journalctl | grep sudo
    pi@raspberrypi:~$ sudo ls
    Bookshelf  myconfig  project  proxy
    pi@raspberrypi:~$ journalctl | grep sudo
    May 16 03:06:04 raspberrypi sudo[799]:       pi : TTY=pts/0 ; PWD=/home/pi ; USER=root ; COMMAND=/usr/bin/ls
    May 16 03:06:04 raspberrypi sudo[799]: pam_unix(sudo:session): session opened for user root by pi(uid=0)
    May 16 03:06:04 raspberrypi sudo[799]: pam_unix(sudo:session): session closed for user root
    pi@raspberrypi:~$
    ```
    在 Mac 上面使用下面的命令
    ```
    log show --last 1h | grep sudo
    ```
1. 学习 [这份](https://github.com/spiside/pdb-tutorial) `pdb` 实践教程并熟悉相关的命令。更深入的信息您可以参考[这份](https://realpython.com/python-debugging-pdb)教程。

2. 安装 [`shellcheck`](https://www.shellcheck.net/) 并尝试对下面的脚本进行检查。这段代码有什么问题吗？请修复相关问题。在您的编辑器中安装一个linter插件，这样它就可以自动地显示相关警告信息。
   ```bash
   #!/bin/sh
   ## Example: a typical script with several problems
   for f in $(ls *.m3u)
   do
     grep -qi hq.*mp3 $f \
       && echo -e 'Playlist $f contains a HQ file in mp3 format'
   done
   ```
   在 Vim 中可以通过[neomake](https://github.com/neomake/neomake)插件来集成 shellcheck，在`~/.vimrc`中添加` Plug 'neomake/neomake'`
    ```bash
    call plug#begin()
    Plug 'neomake/neomake'
    call plug#end()
    ```
    ![1.png]({{site.url}}/2020/solutions/images/7/1.png)
    然后在 vim 执行`:PlugInstall`安装插件
    ![1.png]({{site.url}}/2020/solutions/images/7/2.png)
    在需要检查的 shell 脚本中，执行`:Neomake` 即可进行 shellcheck 检查。然后光标移动到对应行时可以看到告警或错误。
    ![1.png]({{site.url}}/2020/solutions/images/7/3.png)
3. (进阶题) 请阅读 [可逆调试](https://undo.io/resources/reverse-debugging-whitepaper/) 并尝试创建一个可以工作的例子（使用 [`rr`](https://rr-project.org/) 或 [`RevPDB`](https://morepypy.blogspot.com/2016/07/reverse-debugging-for-python.html)）。

## 2. 性能分析

1. [这里](/static/files/sorts.py) 有一些排序算法的实现。请使用 [`cProfile`](https://docs.python.org/3/library/profile.html) 和 [`line_profiler`](https://github.com/pyutils/line_profiler) 来比较插入排序和快速排序的性能。两种算法的瓶颈分别在哪里？然后使用 `memory_profiler` 来检查内存消耗，为什么插入排序更好一些？然后再看看原地排序版本的快排。附加题：使用 `perf` 来查看不同算法的循环次数及缓存命中及丢失情况。
```bash
python -m cProfile -s time sorts.py #按照执行时间排序
```
```bash
python -m cProfile -s time sorts.py | grep sorts.py
33748/1000    0.066    0.000    0.069    0.000 sorts.py:23(quicksort)
34356/1000    0.045    0.000    0.055    0.000 sorts.py:32(quicksort_inplace)
        3    0.037    0.012    0.347    0.116 sorts.py:4(test_sorted)
     1000    0.031    0.000    0.032    0.000 sorts.py:11(insertionsort)
        1    0.007    0.007    0.385    0.385 sorts.py:1(<module>)
```
使用 `line_profiler`进行分析，需要安装：
```bash
pip install line_profiler
```
    然后为需要分析的函数添加装饰器 `@profile`，并执行：
    ```bash
    kernprof -l -v sorts.py
    ```
    首先对快速排序进行分析：
    ```bash
    Wrote profile results to sorts.py.lprof
    Timer unit: 1e-06 s

    Total time: 0.490021 s
    File: sorts.py
    Function: quicksort at line 22

    Line #      Hits         Time  Per Hit   % Time  Line Contents
    ==============================================================
        22                                           @profile
        23                                           def quicksort(array):
        24     32594      91770.0      2.8     18.7      if len(array) <= 1:
        25     16797      36674.0      2.2      7.5          return array
        26     15797      37626.0      2.4      7.7      pivot = array[0]
        27     15797     125796.0      8.0     25.7      left = [i for i in array[1:] if i < pivot]
        28     15797     119954.0      7.6     24.5      right = [i for i in array[1:] if i >= pivot]
        29     15797      78201.0      5.0     16.0      return quicksort(left) + [pivot] + quicksort(right)
    ```
    然后对插入排序进行分析：
    ```bash
    Total time: 1.33387 s
    File: sorts.py
    Function: insertionsort at line 11

    Line #      Hits         Time  Per Hit   % Time  Line Contents
    ==============================================================
        11                                           @profile
        12                                           def insertionsort(array):
        13
        14     26801      44242.0      1.7      3.3      for i in range(len(array)):
        15     25801      43372.0      1.7      3.3          j = i-1
        16     25801      41950.0      1.6      3.1          v = array[i]
        17    234763     434280.0      1.8     32.6          while j >= 0 and v < array[j]:
        18    208962     380062.0      1.8     28.5              array[j+1] = array[j]
        19    208962     343217.0      1.6     25.7              j -= 1
        20     25801      45248.0      1.8      3.4          array[j+1] = v
        21      1000       1503.0      1.5      0.1      return array
    ```
     插入排序的耗时更高一些。快速排序的瓶颈在于 `left`和 `right`的赋值，而插入排序的瓶颈在`while`循环。  
     使用 `memory_profiler`进行分析，需要安装：
    ```bash
     pip install memory_profiler
    ```
    同样需要添加`@profile` 装饰器。
    首先分析快速排序的内存使用情况：
    ```bash
    pi@raspberrypi:~$ python -m memory_profiler sorts.py
    Filename: sorts.py

    Line #    Mem usage    Increment  Occurences   Line Contents
    ============================================================
        22   20.199 MiB   20.199 MiB       32800   @profile
        23                                         def quicksort(array):
        24   20.199 MiB    0.000 MiB       32800       if len(array) <= 1:
        25   20.199 MiB    0.000 MiB       16900           return array
        26   20.199 MiB    0.000 MiB       15900       pivot = array[0]
        27   20.199 MiB    0.000 MiB      152906       left = [i for i in array[1:] if i < pivot]
        28   20.199 MiB    0.000 MiB      152906       right = [i for i in array[1:] if i >= pivot]
        29   20.199 MiB    0.000 MiB       15900       return quicksort(left) + [pivot] + quicksort(right)
    ```
    然后分析插入排序的内存使用情况：
    ```bash
    pi@raspberrypi:~$ python -m memory_profiler sorts.py

    Filename: sorts.py

    Line #    Mem usage    Increment  Occurences   Line Contents
    ============================================================
        11   20.234 MiB   20.234 MiB        1000   @profile
        12                                         def insertionsort(array):
        13
        14   20.234 MiB    0.000 MiB       26638       for i in range(len(array)):
        15   20.234 MiB    0.000 MiB       25638           j = i-1
        16   20.234 MiB    0.000 MiB       25638           v = array[i]
        17   20.234 MiB    0.000 MiB      237880           while j >= 0 and v < array[j]:
        18   20.234 MiB    0.000 MiB      212242               array[j+1] = array[j]
        19   20.234 MiB    0.000 MiB      212242               j -= 1
        20   20.234 MiB    0.000 MiB       25638           array[j+1] = v
        21   20.234 MiB    0.000 MiB        1000       return array
    ```
    同时对比原地操作的快速排序算法内存情况：
    ```bash
    pi@raspberrypi:~$ python -m memory_profiler sorts.py
    Filename: sorts.py

    Line #    Mem usage    Increment  Occurences   Line Contents
    ============================================================
        31   20.121 MiB   20.121 MiB       33528   @profile
        32                                         def quicksort_inplace(array, low=0, high=None):
        33   20.121 MiB    0.000 MiB       33528       if len(array) <= 1:
        34   20.121 MiB    0.000 MiB          42           return array
        35   20.121 MiB    0.000 MiB       33486       if high is None:
        36   20.121 MiB    0.000 MiB         958           high = len(array)-1
        37   20.121 MiB    0.000 MiB       33486       if low >= high:
        38   20.121 MiB    0.000 MiB       17222           return array
        39
        40   20.121 MiB    0.000 MiB       16264       pivot = array[high]
        41   20.121 MiB    0.000 MiB       16264       j = low-1
        42   20.121 MiB    0.000 MiB      124456       for i in range(low, high):
        43   20.121 MiB    0.000 MiB      108192           if array[i] <= pivot:
        44   20.121 MiB    0.000 MiB       55938               j += 1
        45   20.121 MiB    0.000 MiB       55938               array[i], array[j] = array[j], array[i]
        46   20.121 MiB    0.000 MiB       16264       array[high], array[j+1] = array[j+1], array[high]
        47   20.121 MiB    0.000 MiB       16264       quicksort_inplace(array, low, j)
        48   20.121 MiB    0.000 MiB       16264       quicksort_inplace(array, j+2, high)
        49   20.121 MiB    0.000 MiB       16264       return array
    ```
    可以看出，插入排序的内存效率略好于快速排序，因为快速排序需要一些额外的空间来保存结果，而插入排序则是原地操作。
    安装`perf`工具需要Linux 环境，这里使用树莓派完成（你可能会遇到[这个问题](https://raspberrypi.stackexchange.com/questions/43218/how-to-use-the-perf-utility-on-raspbian)）
    ```bash
    sudo apt-get install linux-perf
    ```
1. 这里有一些用于计算斐波那契数列 Python 代码，它为计算每个数字都定义了一个函数：
   ```python
   #!/usr/bin/env python
   def fib0(): return 0

   def fib1(): return 1

   s = """def fib{}(): return fib{}() + fib{}()"""

   if __name__ == '__main__':

       for n in range(2, 10):
           exec(s.format(n, n-1, n-2))
       # from functools import lru_cache
       # for n in range(10):
       #     exec("fib{} = lru_cache(1)(fib{})".format(n, n))
       print(eval("fib9()"))
   ```
   将代码拷贝到文件中使其变为一个可执行的程序。首先安装 [`pycallgraph`](http://pycallgraph.slowchop.com/en/master/)和[`graphviz`](http://graphviz.org/)(如果您能够执行`dot`, 则说明已经安装了 GraphViz.)。并使用 `pycallgraph graphviz -- ./fib.py` 来执行代码并查看`pycallgraph.png` 这个文件。`fib0` 被调用了多少次？我们可以通过记忆法来对其进行优化。将注释掉的部分放开，然后重新生成图片。这回每个`fibN` 函数被调用了多少次？
   ![1.png]({{site.url}}/2020/solutions/images/7/4.png)
   放开注释内容后，再次执行：
   ![1.png]({{site.url}}/2020/solutions/images/7/5.png)
   注意：如果你是 Python 2.7的话，需要修改一下注释的内容:
   ```python
   from backports.functools_lru_cache import lru_cache
   ```
   不过生成的图片里面会包含很多不相关的内容。

2. 我们经常会遇到的情况是某个我们希望去监听的端口已经被其他进程占用了。让我们通过进程的PID查找相应的进程。首先执行 `python -m http.server 4444` 启动一个最简单的 web 服务器来监听 `4444` 端口。在另外一个终端中，执行 `lsof | grep LISTEN` 打印出所有监听端口的进程及相应的端口。找到对应的 PID 然后使用 `kill <PID>` 停止该进程。  
      ![1.png]({{site.url}}/2020/solutions/images/7/6.png)

3. 限制进程资源也是一个非常有用的技术。执行 `stress -c 3` 并使用`htop` 对 CPU 消耗进行可视化。现在，执行`taskset --cpu-list 0,2 stress -c 3` 并可视化。`stress` 占用了3个 CPU 吗？为什么没有？阅读[`man taskset`](http://man7.org/linux/man-pages/man1/taskset.1.html)来寻找答案。附加题：使用 [`cgroups`](http://man7.org/linux/man-pages/man7/cgroups.7.html)来实现相同的操作，限制`stress -m`的内存使用。  
    首先是设备正常运行状态下的资源占用情况：
    ![1.png]({{site.url}}/2020/solutions/images/7/7.png)
    创建负载：
    ```bash
   stress -c 3
   ```
    ![1.png]({{site.url}}/2020/solutions/images/7/8.png)
    限制资源消耗
    ```bash
    taskset --cpu-list 0,2 stress -c 3
    ```
    ![1.png]({{site.url}}/2020/solutions/images/7/9.png)
    taskset 命令可以将任务绑定到指定CPU核心。  
    ![1.png]({{site.url}}/2020/solutions/images/7/10.png)
    接下来看`cgroups`是如何工作的，我参考了两篇文章：
    - [Linux资源管理之cgroups简介](https://tech.meituan.com/2015/03/31/cgroups.html)
    - [Linux-insidesControl Groups](https://0xax.gitbooks.io/linux-insides/content/Cgroups/linux-cgroups-1.html)    ß
    
    首先我们看一下如何创建内存负载，这里创建 3 个 worker 来不停的申请释放 512M 内存：
    ```bash
    stress -m 3 --vm-bytes 512M
    ```
    ![1.png]({{site.url}}/2020/solutions/images/7/11.png)
    由于题目要求限制内存的使用，首先我们看一下内存设备是否已经挂载：
    ```bash
    root@raspberrypi:~# lssubsys -am
    memory
    cpuset /sys/fs/cgroup/cpuset
    cpu,cpuacct /sys/fs/cgroup/cpu,cpuacct
    blkio /sys/fs/cgroup/blkio
    devices /sys/fs/cgroup/devices
    freezer /sys/fs/cgroup/freezer
    net_cls,net_prio /sys/fs/cgroup/net_cls,net_prio
    perf_event /sys/fs/cgroup/perf_event
    pids /sys/fs/cgroup/pids
    root@raspberrypi:~#
    ```
    内存没挂载的情况下，需要手动挂载：
    ```bash
    mount -t cgroup -o memory memory /sys/fs/cgroup/memory
    ```
    我在树莓派上出现了不能挂载的情况，此时需要修改 `boot.cmdline.txt`，添加：
    ```
    cgroup_enable=memory  cgroup_memory=1 
    ```
    然后重启，再次查看
    ```bash
    pi@raspberrypi:~$ lssubsys -am
    cpuset /sys/fs/cgroup/cpuset
    cpu,cpuacct /sys/fs/cgroup/cpu,cpuacct
    blkio /sys/fs/cgroup/blkio
    memory /sys/fs/cgroup/memory
    devices /sys/fs/cgroup/devices
    freezer /sys/fs/cgroup/freezer
    net_cls,net_prio /sys/fs/cgroup/net_cls,net_prio
    perf_event /sys/fs/cgroup/perf_event
    pids /sys/fs/cgroup/pids
    pi@raspberrypi:~$
    ```
    已经挂载成功，然后创建组并写入规则（内存限制为128M）
    ```bash
    root@raspberrypi:/home/pi# cgcreate -g memory:cgroup_test_group
    root@raspberrypi:/home/pi# echo 128M > /sys/fs/cgroup/memory/cgroup_test_group/memory.limit_in_bytes
    ```
    然后在控制组中运行`stress`，创建 3 个 worker 申请 512M 内存：
    ```bash
    oot@raspberrypi:/home/pi# cgexec -g memory:cgroup_test_group stress -m 3 --vm-bytes 512M
    stress: info: [832] dispatching hogs: 0 cpu, 0 io, 3 vm, 0 hdd
    stress: FAIL: [832] (415) <-- worker 833 got signal 9
    stress: WARN: [832] (417) now reaping child worker processes
    stress: FAIL: [832] (451) failed run completed in 5s
    ```
    执行失败。
    ![1.png]({{site.url}}/2020/solutions/images/7/12.png)  
    如果是申请 1M 内存，则可以成功运行：
    ```bash
    cgexec -g memory:cgroup_test_group stress -m 3 --vm-bytes 1M
    ```
    ![1.png]({{site.url}}/2020/solutions/images/7/13.png)  
4. (进阶题) `curl ipinfo.io` 命令或执行 HTTP 请求并获取关于您 IP 的信息。打开 [Wireshark](https://www.wireshark.org/) 并抓取 `curl` 发起的请求和收到的回复报文。（提示：可以使用`http`进行过滤，只显示 HTTP 报文）
    这里我使用的是`curl www.baidu.com`，请求百度的首页并过滤了除 HTTP 之外的其他报文：
    ![1.png]({{site.url}}/2020/solutions/images/7/14.png)  
    ![1.png]({{site.url}}/2020/solutions/images/7/15.png)  
