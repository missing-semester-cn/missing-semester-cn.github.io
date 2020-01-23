---
layout: lecture
title: "Debugging and Profiling"
date: 2019-01-23
---

A golden rule in programming is that code will not do what you expect it to do but what you told it to do.
Bridging that gap can sometimes be a quite difficult feat.
In this lecture we are going to cover useful techniques for dealing with buggy and resource hungry code: debugging and profiling.

# Debugging

## Printf debugging and Logging

"The most effective debugging tool is still careful thought, coupled with judiciously placed print statements" — Brian Kernighan, _Unix for Beginners_.

The first approach to debug a problem is often adding print statements around where you have detected that something is wrong and keep iterating until you have extracted enough information to understand what is responsible for the issue.

The next step is to do use logging in your program instead of ad hoc print statements. Logging is better than just regular print statements for several reasons:

- You can log to files, sockets even remote servers instead of standard output.
- Logging supports severity levels (such as INFO, DEBUG, WARN, ERROR, &c) so you can filter your output accordingly.
- For new issues, there's a fair chance that your logs will contain enough information to detect what is going wrong.

One of my favorite tips for making logs more readable is to color code them.
By now you probably have realized that your terminal uses colors to make things more readable.
But how does it do it? Programs like `ls` or `grep` are using [ANSI escape codes](https://en.wikipedia.org/wiki/ANSI_escape_code) which are special sequences of characters to indicate your shell to change the color of the output. For example executing `echo -e "\e[38;2;255;0;0mThis is red\e[0m"` prints a red `This is red` message in your terminal.

## Third party logs

As you start building larger software systems you will most probably run into dependencies that will run as separate programs.
Web servers, databases or message brokers are common examples of this kind of dependencies.
When interacting with these systems you will often need to read their logs since client side error messages might not suffice.

Luckily, most programs will write their own logs somewhere in your system.
In UNIX systems, it is commonplace for programs to write their logs under `/var/log`.
For instance, the [NGINX](https://www.nginx.com/) webserver will place its logs under `/var/log/nginx`.
More recently, systems have started using a **system log** ”, which is increasingly where all of your log messages go.
Most (but not all) Linux systems will use `systemd`, a system daemon that will control many things in your system such as which services are enabled and running.
`systemd` will place the logs under `/var/log/journal` in a specialized format and you can use the [`journalctl`](http://man7.org/linux/man-pages/man1/journalctl.1.html) command to display the messages.
Similarly, on macOS there is still `/var/log/system.log` but increasingly tools will log into the system log that can be displayed with [`log show`](https://www.manpagez.com/man/1/log/).
On most UNIX systems you can also use the [`dmesg`](http://man7.org/linux/man-pages/man1/dmesg.1.html) command to access the kernel log.

For logging under the system logs you can use the [`logger`](http://man7.org/linux/man-pages/man1/logger.1.html) tool.
Many programming languages will also have bindings for doing so.
Here's an example of using `logger` and how to check that the entry made it to the system logs.

```bash
logger "Hello Logs"
# On macOS
log show --last 1m | grep Hello
# On Linux
journalctl --since "1m ago" | grep Hello
```

As we saw in the data wrangling lecture, logs can be quite verbose and they require some level of processing and filtering to get the information you want.
If you find yourself heavily filtering through `journalctl` and `log show` you will probably want to familiarize yourself with their flags which can perform a first pass of filtering of their output.
There are also some tools like  [`lnav`](http://lnav.org/) that provide an improved presentation and navigation for log files.

## Debuggers

When printf debugging is not enough you should be using a debugger.
Debuggers are programs that will let you interact with the execution of a program, letting you do things like:

- Halt execution of the program when it reaches a certain line.
- Step through the program one instruction at a time.
- Inspect values of variables after the program crashed.
- Conditionally halt the execution when a given condition is met.
- And many more advanced features

Many programming languages will come with some form of debugger.
In Python this is the Python Debugger [`pdb`](https://docs.python.org/3/library/pdb.html).

Here is a brief description of some of the commands `pdb` supports.

- **l**(ist) - Displays 11 lines around the current line or continue the previous listing.
- **s**(tep) - Execute the current line, stop at the first possible occasion.
- **n**(ext) - Continue execution until the next line in the current function is reached or it returns.
- **b**(reak) - Set a breakpoint (depending on the argument provided).
- **p**(rint) - Evaluate the expression in the current context and print its value. There's also **pp** to display using [`pprint`](https://docs.python.org/3/library/pprint.html) instead.
- **r**(eturn) - Continue execution until the current function returns.
- **q**(uit) - Quit from the debugger

Let's go through an example of using `pdb` to fix the following buggy python code.

```bash
TODO TODO
```



Note that since Python is an interpreted language we can use the `pdb` shell to execute commands and to execute instructions.
[`ipdb`](https://pypi.org/project/ipdb/) is an improved `pdb` that uses the [`IPython`](https://ipython.org) REPL enabling tab completion, syntax highlighting, better tracebacks, and better introspection while retaining the same interface as the `pdb` module.

For more low level programming you will probably want to look into [`gdb`](https://www.gnu.org/software/gdb/) (and its quality of life modification [`pwndbg`](https://github.com/pwndbg/pwndbg)) and [`lldb`](https://lldb.llvm.org/).
They are optimized for C-like language debugging but will let you probe pretty much any process and get its current machine state: registers, stack, program counter, &c.


## Specialized Tools

Even if what you are trying to debug is a black box binary there are tools that can help you with that.
Whenever programs need to perform actions that only the kernel can, they will use [System Calls](https://en.wikipedia.org/wiki/System_call).
There are commands that will let you trace the syscalls your program makes. In Linux there's [`strace`](http://man7.org/linux/man-pages/man1/strace.1.html) and macOS and BSD have [`dtrace`](http://dtrace.org/blogs/about/). Since `dtrace` can be tricky to use since it uses its own `D` language there is a wrapper called [`dtruss`](https://www.manpagez.com/man/1/dtruss/) that will provide an interface more similar to `strace` (more details [here](https://8thlight.com/blog/colin-jones/2015/11/06/dtrace-even-better-than-strace-for-osx.html)).

Below are some examples of using `strace` or `dtruss` to show [`stat`](http://man7.org/linux/man-pages/man2/stat.2.html) syscall traces for an execution of `ls`. For a deeper dive into `strace`, [this](https://blogs.oracle.com/linux/strace-the-sysadmins-microscope-v2) is a good read.

```bash
# On Linux
sudo strace -e lstat ls -l > /dev/null

# On macOS
sudo dtruss -t lstat64_extended ls -l > /dev/null
```

Under some circumstances, looking at the network packets might be necessary to figure out what is going wrong with your program.
Tools like [`tcpdump`](http://man7.org/linux/man-pages/man1/tcpdump.1.html) and [Wireshark](https://www.wireshark.org/) are network packet analyzers that will let you read the contents of network packets and filter them based on many criteria.

For web development, the Chrome/Firefox developer tools are a quite amazing tool. They feature a large number of tools:
- Source code - Inspect the HTML/CSS/JS source code of any website
- Live HTML, CSS, JS modification - Change the website content, styles and behavior to test. (This also means that website screenshots are not valid proofs).
- Javascript shell - Execute commands in the JS REPL
- Network - Analyze the timeline of requests
- Storage - Look into the Cookies and local application storage.

## Static Analysis

Not all issues need the code to be run to be discovered.
For example, just by carefully looking at a piece of code you could realize that your loop variable is shadowing an already existing variable or function name; or that a variable has never been defined.
Here is where [static analysis](https://en.wikipedia.org/wiki/Static_program_analysis) tools come into play.
Static analysis programs take source code as input and analyze it using coding rules to reason about its correctness.

For instance, in the following Python snippet there are several mistakes.
First, our loop variable `foo` shadows the previous definition of the function `foo`. We also wrote `baz` instead of `bar` in the last line so the program will crash, but it will take a minute to do so because of the `sleep` call.

```python
import time

def foo():
    return 42

for foo in range(5):
    print(foo)
bar = 1
bar *= 0.2
time.sleep(60)
print(baz)
```

Static analysis tools can catch both these issues. When we run [`pyflakes`](https://pypi.org/project/pyflakes) on the code and get errors related to those issues. [`mypy`](http://mypy-lang.org/) is another tool that can detect type checking issues. Here, `bar` is first an `int` and it's then casted to a `float` so `mypy` will warn us about the error.
Note that all these issues were detected without actually having to run the code.
In the shell tools lecture we covered [`shellcheck`](https://www.shellcheck.net/) which is a similar tool for shell scripts.

```bash
$ pyflakes foobar.py
foobar.py:6: redefinition of unused 'foo' from line 3
foobar.py:11: undefined name 'baz'

$ mypy foobar.py
foobar.py:6: error: Incompatible types in assignment (expression has type "int", variable has type "Callable[[], Any]")
foobar.py:9: error: Incompatible types in assignment (expression has type "float", variable has type "int")
foobar.py:11: error: Name 'baz' is not defined
Found 3 errors in 1 file (checked 1 source file)
```

Most editors and IDEs will support displaying the output of these tools within the editor itself, highlighting the locations of warnings and errors.
This is often called **code linting** and it can also be used to display other types of issues such as stylistic violations or insecure constructs.

In vim, the plugins [`ale`](https://vimawesome.com/plugin/ale) or [`syntastic`](https://vimawesome.com/plugin/syntastic) will let you do that.
For Python, [`pylint`](https://www.pylint.org) and [`pep8`](https://pypi.org/project/pep8/) are examples of stylistic linters and [`bandit`](https://pypi.org/project/bandit/) is a tool designed to find common security issues.
For other languages people have compiled comprehensive lists of useful static analysis tools such as [Awesome Static Analysis](https://github.com/mre/awesome-static-analysis) (you may want to take a look at the _Writing_ section) and for linters there is [Awesome Linters](https://github.com/caramelomartins/awesome-linters).

A complementary tool to stylistic linting are code formatters such as [`black`](https://github.com/psf/black) for Python, `gofmt` for Go or `rustfmt` for Rust.
These tools autoformat your code so it's consistent with common stylistic patterns for the given programming language.
Although you might be unwilling to give stylistic control about your code, standardizing code format will help other people read your code and will make you better at reading other people's (stylistically standardized) code.

# Profiling

Even if your code functionally behaves as you would expect that might not be good enough if it takes all your CPU or memory in the process.
Algorithms classes will teach you big _O_ notation but they won't teach how to find hot spots in your program.
Since [premature optimization is the root of all evil](http://wiki.c2.com/?PrematureOptimization) you should learn about profilers and monitoring tools, since they will help you understand what parts of your program are taking most of the time and/or resources so you can focus on optimizing those parts.

## Timing

Similar to the debugging case, in many scenarios it can be enough to just print the time it took your code between two points.
Here is an example in Python using the [`time`](https://docs.python.org/3/library/time.html) module.

```python
import time, random
n = random.randint(1, 10) * 100

# Get current time
start = time.time()

# Do some work
print("Sleeping for {} ms".format(n))
time.sleep(n/1000)

# Compute time between start and now
print(time.time() - start)

# Output
# Sleeping for 500 ms
# 0.5713930130004883
```

However, as you might have noticed if you ran the printed time might not match your expected measurements.
Wall clock time can be misleading since your computer might be running other processes at the same time or might be waiting for events to happen. It is common for tools to make a distinction between _Real_, _User_ and _Sys_ time. In general _User_ + _Sys_ tells you how much time your process actually spent in the CPU (more detailed explanation [here](https://stackoverflow.com/questions/556405/what-do-real-user-and-sys-mean-in-the-output-of-time1))

- _Real_ - Wall clock elapsed time from start to finish of the program, including the time taken by other processes and time taken while blocked (e.g. waiting for I/O or network)
- _User_ - Amount of time spent in the CPU running user code
- _Sys_ - Amount of time spent in the CPU running kernel code

For example, try running a command that performs an HTTP request and prefixing it with [`time`](http://man7.org/linux/man-pages/man1/time.1.html). Under a slow connection you might get an output like the one below. Here it took over 2 seconds for the request to complete but the process only took 15ms of CPU user time and 12ms of kernel CPU time.

```bash
$ time curl https://missing.csail.mit.edu &> /dev/null`
real    0m2.561s
user    0m0.015s
sys     0m0.012s
```

## Profilers

### CPU

Most of the time when people refer to profilers they actually mean CPU profilers since they are the most common.
There are two main types of CPU profilers, tracing profilers and sampling profilers.
Tracing profilers keep a record of every function call your program makes whereas sampling profilers probe your program periodically (commonly every milliseconds) and record the program's stack.
They then present aggregate statistics of what your program spent the most time doing.
[Here](https://jvns.ca/blog/2017/12/17/how-do-ruby---python-profilers-work-) is a good intro article if you want more detail on this topic.

Most programming languages will have some form a command line profiler that you can use to analyze your code.
Often those integrate with full fledged IDEs but for this lecture we are going to focus on the command line tools themselves.

In Python
TODO cProfile


A caveat of Python's `cProfile` profiler (and many profilers for that matter) is that they will display time per function call. That can become intuitive really fast specially if you are using third party libraries in your code since internal function calls will also be accounted for.
A more intuitive way of displaying profiling information is to include the time taken per line of code, this is what _line profilers_ do.

For instance the following piece of Python code performs a request to the class website and parses the response to get all URLs in the page.

```python
#!/usr/bin/env python
import requests
from bs4 import BeautifulSoup

# This is a decorator that tells line_profiler
# that we want to analyze this function
@profile
def get_urls():
    response = requests.get('https://missing.csail.mit.edu')
    s = BeautifulSoup(response.content, 'lxml')
    urls = []
    for url in s.find_all('a'):
        urls.append(url['href'])

if __name__ == '__main__':
    get_urls()
```

If we ran it thorugh Python's `cProfile` profiler we get over 2500 lines of output and even with sorting it is hard to understand where the time is being spent. A quick run with [`line_profiler`](https://github.com/rkern/line_profiler) shows the time taken per line.

```bash
$ kernprof -l -v a.py
Wrote profile results to a.py.lprof
Timer unit: 1e-06 s

Total time: 0.636188 s
File: a.py
Function: get_urls at line 5

Line #  Hits         Time  Per Hit   % Time  Line Contents
==============================================================
 5                                           @profile
 6                                           def get_urls():
 7         1     613909.0 613909.0     96.5      response = requests.get('https://missing.csail.mit.edu')
 8         1      21559.0  21559.0      3.4      s = BeautifulSoup(response.content, 'lxml')
 9         1          2.0      2.0      0.0      urls = []
10        25        685.0     27.4      0.1      for url in s.find_all('a'):
11        24         33.0      1.4      0.0          urls.append(url['href'])
```

### Memory

In languages like C or C++ memory leaks can cause your program to never release memory that doesn't need anymore.
To help in the process of memory debugging you can use tools like [Valgrind](https://valgrind.org/) that will help you identify memory leaks.

In garbage collected languages like Python it is still useful to use a memory profiler since as long as you have pointers to objects in memory they won't be garbage collected.
Here's an example program and the associated output when running it with [memory-profiler](https://pypi.org/project/memory-profiler/) (note the decorator like in `line-profiler`)

```python
@profile
def my_func():
    a = [1] * (10 ** 6)
    b = [2] * (2 * 10 ** 7)
    del b
    return a

if __name__ == '__main__':
    my_func()
```

```bash
$ python -m memory_profiler example.py
Line #    Mem usage  Increment   Line Contents
==============================================
     3                           @profile
     4      5.97 MB    0.00 MB   def my_func():
     5     13.61 MB    7.64 MB       a = [1] * (10 ** 6)
     6    166.20 MB  152.59 MB       b = [2] * (2 * 10 ** 7)
     7     13.61 MB -152.59 MB       del b
     8     13.61 MB    0.00 MB       return a
```

### Event Profiling

As it was the case for `strace` for debugging, you might want to ignore the specifics of the code that you are running and treat it like a black box when profiling.
The [`perf`](http://man7.org/linux/man-pages/man1/perf.1.html) command abstracts away CPU differences and does not report time or memory but instead it reports system events related to your programs.
For example, `perf` can easily report poor cache locality, high amounts of page faults or livelocks.

TODO `perf` command

- `perf list` - List the events that can be traced with perf
- `perf stat COMMAND ARG1 ARG2` - Gets counts of different events related a process or command
- `perf record` -
- `perf report` -
- Basic performance stats: `perf stat {command}`
- Run a program with the profiler: `perf record {command}`
- Analyze profile: `perf report`


### Visualization

Profiler output for real world programs will contain large amounts of information because of the inherent complexity of software projects.
Humans are visual creatures and are quite terrible at reading large amounts of numbers and making sense of them.
Thus there are many tools for displaying profiler's output in a easier to parse way.

One common way to display CPU profiling information for sampling profilers is to use a [Flame Graph](http://www.brendangregg.com/flamegraphs.html) which will display a hierarchy of function calls across the Y axis and time taken proportional to the X axis. They are also interactive letting you zoom into specific parts of the program and get their stack traces (try clicking in the image below).

[![FlameGraph](http://www.brendangregg.com/FlameGraphs/cpu-bash-flamegraph.svg)](http://www.brendangregg.com/FlameGraphs/cpu-bash-flamegraph.svg)

Call graphs or control flow graphs display the relationships between subroutines within a program by including functions as nodes and functions calls between them as directed edges. When coupled with profiling information such as number of calls and time taken, call graphs can be quite useful for interpreting the flow of a program.
In Python you can use the [`pycallgraph`](http://pycallgraph.slowchop.com/en/master/) library to generate them.

![Call Graph](https://upload.wikimedia.org/wikipedia/commons/2/2f/A_Call_Graph_generated_by_pycallgraph.png)


## Resource Monitoring

Sometimes, the first step towards analyzing the performance of your program is to understand what its actual resource consumption is.
Often programs will run slow when they are resource constrained, e.g. not having enough memory or having a slow network connection.
There is a myriad of command line tools for probing and displaying different system resources like CPU usage, memory usage, network, disk usage and so on.

- **General Monitoring** - Probably the most popular is [`htop`](https://hisham.hm/htop/index.php) which is an improved version of [`top`](http://man7.org/linux/man-pages/man1/top.1.html).
`htop` presents you various statistics for the currently running processes on the system.
See also [`glances`](https://nicolargo.github.io/glances/) for similar implementation with a great UI. For getting aggregate measures across all processes, [`dstat`](http://dag.wiee.rs/home-made/dstat/) is also nifty tool that computes real-time resource metrics for lots of different subsystems like I/O, networking, CPU utilization, context switches, &c.
- **I/O operations** - [`iotop`](http://man7.org/linux/man-pages/man8/iotop.8.html) displays live I/O usage information, handy to check if a process is doing heavy I/O disk operations
- **Disk Usage** - [`df`](http://man7.org/linux/man-pages/man1/df.1.html) will display metrics per partitions and [`du`](http://man7.org/linux/man-pages/man1/du.1.html) displays **d**isk **u**sage per file for the current directory. In these tools the `-h` flag tells the program to print with **h**uman readable format.
A more interactive version of `du` is [`ncdu`](https://dev.yorhel.nl/ncdu) which will let you navigate folders and delete files and folders as you navigate.
- **Memory Usage** - [`free`](http://man7.org/linux/man-pages/man1/free.1.html) displays the total amount of free and used memory in the system. Memory is also  displayed in tools like `htop`.
- **Open Files** - [`lsof`](http://man7.org/linux/man-pages/man8/lsof.8.html)  lists file information about files opened by processes. It can be quite useful for checking which process has opened a given file.
- **Network Connections and Config** - [`ss`](http://man7.org/linux/man-pages/man8/ss.8.html) will let you monitor incoming and outgoing network packets statistics as well as interface statistics. A common use case of `ss` is figuring out what process is using a given port in a machine. For displaying routing, network devices and interfaces you can use [`ip`](http://man7.org/linux/man-pages/man8/ip.8.html). Note that `netstat` and `ifconfig` have been deprecated in favor of the former tools respectively.
- **Network Usage** -  [`nethogs`](https://github.com/raboof/nethogs) and [`iftop`](http://www.ex-parrot.com/pdw/iftop/) are good interactive CLI tools for monitoring network usage.

If you want to test these tools you can also artificially impose loads on the machine using the [`stress`](https://linux.die.net/man/1/stress) command.


### Specialized tools

Sometimes, black box benchmarking is all you need to determine what software to use.
Tools like [`hyperfine`](https://github.com/sharkdp/hyperfine) will let you quickly benchmark command line programs.
For instance, in the shell tools and scripting lecture we recommended `fd` over `find`. We can use `hyperfine` to compare them in tasks we run often.
E.g. in the example below `fd` was 20x faster than `find` in my machine.

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

As it was the case for debugging, browsers also come with a fantastic set of tools for profiling webpage loading letting you figure out where time is being spent: loading, rendering, scripting, &c.
More info for [Firefox](https://developer.mozilla.org/en-US/docs/Mozilla/Performance/Profiling_with_the_Built-in_Profiler) and [Chrome](https://developers.google.com/web/tools/chrome-devtools/rendering-toolss).

# Exercises

1. Do [this](https://github.com/spiside/pdb-tutorial) hands on `pdb` tutorial to familiarize yourself with the commands. For a more in depth tutorial read [this](https://realpython.com/python-debugging-pdb).

1. Use `journalctl` on Linux or `log show` on macOS to get the super user accesses and commands in the last day.
If there aren't any you can execute some harmless commands such as `sudo ls` and check again.

1. Install [`shellchek`](https://www.shellcheck.net/) and try checking following script. What is wrong with the code? Fix it. Install a linter plugin in your editor so you can get your warnings automatically.


```bash
#!/bin/sh
## Example: a typical script with several problems
for f in $(ls *.m3u)
do
  grep -qi hq.*mp3 $f \
    && echo -e 'Playlist $f contains a HQ file in mp3 format'
done
```

1. [Here](/static/files/sorts.py) are some sorting algorithm implementations. Use [`cProfile`](https://docs.python.org/2/library/profile.html) and [`line_profiler`](https://github.com/rkern/line_profiler) to compare the runtime of insertion sort and quicksort. What is the bottleneck of each algorithm? Use then `memory_profiler` to check the memory consumption, why is insertion sort better? Check now the inplace version of quicksort. Challenge: Use `perf` to look at the cache locality of each algorithm.

1. Here's some (arguably convoluted) Python code for computing Fibonacci numbers using a function for each number.

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

Put the code into a file and make it executable. Install [`pycallgraph`](http://pycallgraph.slowchop.com/en/master/). Run the code as is with `pycallgraph graphviz -- ./fib.py` and check the `pycallgraph.png` file. How many times is `fib0` called?. We can do better than that by memoizing the functions. Uncomment the commented lines and regenerate the images. How many times are we calling each `fibN` function now?

1. A common issue is that a port you want to listen on is already taken by another process. Let's learn how to discover that process pid. First execute `python -m http.server 4444` to start a minimal web server listening on port `4444`. On a separate terminal run `lsof | grep LISTEN` to print all listening processes and ports. Find that process pid and terminate it by running `kill <PID>`.

1. Limiting processes resources can be another handy tool in your toolbox.
Try running `stress -c 3` and visualize the CPU consumption with `htop`. Now, execute `taskset --cpu-list 0,2 stress -c 3` and visualize it. Is `stress` taking three CPUs? Why not? Read [`man taskset`](http://man7.org/linux/man-pages/man1/taskset.1.html).
Challenge: achieve the same using [`cgroups`](http://man7.org/linux/man-pages/man7/cgroups.7.html). Try limiting the memory consumption of `stress -m`.

1. (Advanced) The command `curl ipinfo.io` performs a HTTP request an fetches information about your public IP. Open [Wireshark](https://www.wireshark.org/) and try to sniff the request and reply packets that `curl` sent and received. (Hint: Use the `http` filter to just watch HTTP packets).

1. (Advanced) Read about [reversible debugging](https://undo.io/resources/reverse-debugging-whitepaper/) and get a simple example working using [`rr`](https://rr-project.org/) or [`RevPDB`](https://morepypy.blogspot.com/2016/07/reverse-debugging-for-python.html).
