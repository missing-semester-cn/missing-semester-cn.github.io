---
layout: lecture
title: "课程概览与shell"
date: 2019-01-13
ready: true
video:
  aspect: 56.25
  id: Z56Jmr9Z34Q
---

{% comment %}
[Reddit Discussion](https://www.reddit.com/r/hackertools/comments/anic30/course_overview_iap_2019/)
{% endcomment %}

# 动机

作为计算机科学家，我们都知道计算机最擅长帮助我们完成重复性的工作。
但是我们却常常忘记这一点也适用于我们使用计算机的方式，而不仅仅是利用计算机程序去帮我们求解问题。
在从事与计算机相关的工作时，我们有很多触手可及的工具可以帮助我们更高效的解决问题。
但是我们中的大多数人实际上只利用了这些工具中的很少一部分，我们常常只是死记硬背地掌握了一些对我们来说如咒语一般的命令，
或是当我们卡住的时候，盲目地从网上复制粘贴一些命令。

本课程意在帮你解决这一问题。

我们希望教会您如何挖掘现有工具的潜力，并向您介绍一些新的工具。也许我们还可以促使您想要去探索（甚至是去开发）更多的工具。
我们认为这是大多数计算机科学相关课程中缺少的重要一环。

# 课程结构

本课程包含11个时常在一小时左右的讲座，每一个讲座都会关注一个
[特定的主题](/missing-semester/2020/)。尽管这些讲座之间基本上是各自独立的，但随着课程的进行，我们会假定您已经掌握了之前的内容。
每个讲座都有在线笔记供查阅，但是课上的很多内容并不会包含在笔记中。因此我们也会把课程录制下来发布到互联网上供大家观看学习。

我们希望能在这11个一小时讲座中涵盖大部分必须的内容，因此课程地节奏会比较紧凑。
为了能帮助您以自己的节奏来掌握讲座内容，每次课程都包含来一组练习来帮助您掌握本节课的重点。
s课后我们会安排答疑的时间来回答您的问题。如果您参加的是在线课程，可以发送邮件到
[missing-semester@mit.edu](mailto:missing-semester@mit.edu)来联系我们。

由于时长的限制，我们不可能达到那些专门课程一样的细致程度，我们会适时地将您介绍一些优秀的资源，帮助您深入的理解相关的工具或主题。
但是如果您还有一些特别关注的话题，也请联系我们。


# 主题 1: The Shell

##  shell 是什么？

如今的计算机有着多种多样的交互接口让我们可以进行指令的的输入，从炫酷的图像用户界面（GUI），语音输入甚至是AR/VR都已经无处不在。
这些交互接口可以覆盖80%的使用场景，但是它们也从根本上限制了您的操作方式——你不能点击一个不存在的按钮或者是用语音输入一个还没有被录入的指令。
为了充分利用计算机的能力，我们不得不回到最根本的方式，使用文字接口：Shell

几乎所有您能够接触到的平台都支持某种形式都shell，有些甚至还提供了多种shell供您选择。虽然它们之间有些细节上都差异，但是其核心功能都是一样都：它允许你执行程序，输入并获取某种半结构化都输出。

本节课我们会使用Bourne Again SHell, 简称 "bash" 。
这是被最广泛使用都一种shell，它都语法和其他都shell都是类似的。打开shell _提示符_（您输入指令的地方），您首先需要打开 _终端_ 。您的设备通常都已经内置了终端，或者您也可以安装一个，非常简单。

## 使用 shell

当您打开终端时，您会看到一个提示符，它看起来一般是这个样子的：

```console
missing:~$ 
```

这是shell最主要的文本接口。它告诉你，你的主机名是 `missing` 并且您当前的工作目录（"current working directory"）或者说您当前所在的位置是`~` (表示 "home")。 `$`符号表示您现在的身份不是root用户（稍后会介绍）。在找个提示符中，您可以输入 _命令_ ，命令最终会被shell解析。最简单的命令是执行一个程序：

```console
missing:~$ date
Fri 10 Jan 2020 11:49:31 AM EST
missing:~$ 
```

这里，我们执行了 `date` 找个程序，不出意料地，它打印出了当前的日前和时间。然后，shell等待我们输入其他命令。我们可以在执行命令的同时向程序传递 _参数_ ：

```console
missing:~$ echo hello
hello
```
上例中，我们让shell执行 `echo` ，同时指定参数`hello`。`echo` 程序将该参数打印出来。
shell基于空格分割命令并进行解析，然后执行第一个单词代表的程序，并将后续的单词作为程序可以访问的参数。如果您希望传递的参数中包含空格（例如一个名为 My Photos 的文件夹），您要么用使用单引号，双引号将其包裹起来，要么使用转义符号`\`进行处理(`My\ Photos`)。

但是，shell是如何知道去哪里寻找 `date` 或 `echo` 的呢？其实，类似于Python or Ruby，shell是一个编程环境，所以它具备变量、条件、循环和函数（下一课进行讲解）。当你在shell中执行命令时，您实际上是在执行一段shell可以解释执行的简短代码。如果你要求shell执行某个指令，但是该指令并不是shell所了解的编程关键字，那么它会去咨询 _环境变量_  `$PATH`，它会列出当shell接到某条指令时，进行程序搜索的路径：


```console
missing:~$ echo $PATH
/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
missing:~$ which echo
/bin/echo
missing:~$ /bin/echo $PATH
/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
```

When we run the `echo` command, the shell sees that it should execute
the program `echo`, and then searches through the `:`-separated list of
directories in `$PATH` for a file by that name. When it finds it, it
runs it (assuming the file is _executable_; more on that later). We can
find out which file is executed for a given program name using the
`which` program. We can also bypass `$PATH` entirely by giving the
_path_ to the file we want to execute.

## 在shell中导航

A path on the shell is a delimited list of directories; separated by `/`
on Linux and macOS and `\` on Windows. On Linux and macOS, the path `/`
is the "root" of the file system, under which all directories and files
lie, whereas on Windows there is one root for each disk partition (e.g.,
`C:\`). We will generally assume that you are using a Linux filesystem
in this class. A path that starts with `/` is called an _absolute_ path.
Any other path is a _relative_ path. Relative paths are relative to the
current working directory, which we can see with the `pwd` command and
change with the `cd` command. In a path, `.` refers to the current
directory, and `..` to its parent directory:

```console
missing:~$ pwd
/home/missing
missing:~$ cd /home
missing:/home$ pwd
/home
missing:/home$ cd ..
missing:/$ pwd
/
missing:/$ cd ./home
missing:/home$ pwd
/home
missing:/home$ cd missing
missing:~$ pwd
/home/missing
missing:~$ ../../bin/echo hello
hello
```

Notice that our shell prompt kept us informed about what our current
working directory was. You can configure your prompt to show you all
sorts of useful information, which we will cover in a later lecture.

In general, when we run a program, it will operate in the current
directory unless we tell it otherwise. For example, it will usually
search for files there, and create new files there if it needs to.

To see what lives in a given directory, we use the `ls` command:

```console
missing:~$ ls
missing:~$ cd ..
missing:/home$ ls
missing
missing:/home$ cd ..
missing:/$ ls
bin
boot
dev
etc
home
...
```

Unless a directory is given as its first argument, `ls` will print the
contents of the current directory. Most commands accept flags and
options (flags with values) that start with `-` to modify their
behavior. Usually, running a program with the `-h` or `--help` flag
(`/?` on Windows) will print some help text that tells you what flags
and options are available. For example, `ls --help` tells us:

```
  -l                         use a long listing format
```

```console
missing:~$ ls -l /home
drwxr-xr-x 1 missing  users  4096 Jun 15  2019 missing
```

This gives us a bunch more information about each file or directory
present. First, the `d` at the beginning of the line tells us that
`missing` is a directory. Then follow three groups of three characters
(`rwx`). These indicate what permissions the owner of the file
(`missing`), the owning group (`users`), and everyone else respectively
have on the relevant item. A `-` indicates that the given principal does
not have the given permission. Above, only the owner is allowed to
modify (`w`) the `missing` directory (i.e., add/remove files in it). To
enter a directory, a user must have "search" (represented by "execute":
`x`) permissions on that directory (and its parents). To list its
contents, a user must have read (`r`) permissions on that directory. For
files, the permissions are as you would expect. Notice that nearly all
the files in `/bin` have the `x` permission set for the last group,
"everyone else", so that anyone can execute those programs.

Some other handy programs to know about at this point are `mv` (to
rename/move a file), `cp` (to copy a file), and `mkdir` (to make a new
directory).

If you ever want _more_ information about a program's arguments, inputs,
outputs, or how it works in general, give the `man` program a try. It
takes as an argument the name of a program, and shows you its _manual
page_. Press `q` to exit.

```console
missing:~$ man ls
```

## 在程序间创建连接

In the shell, programs have two primary "streams" associated with them:
their input stream and their output stream. When the program tries to
read input, it reads from the input stream, and when it prints
something, it prints to its output stream. Normally, a program's input
and output are both your terminal. That is, your keyboard as input and
your screen as output. However, we can also rewire those streams!

The simplest form of redirection is `< file` and `> file`. These let you
rewire the input and output streams of a program to a file respectively:

```console
missing:~$ echo hello > hello.txt
missing:~$ cat hello.txt
hello
missing:~$ cat < hello.txt
hello
missing:~$ cat < hello.txt > hello2.txt
missing:~$ cat hello2.txt
hello
```

You can also use `>>` to append to a file. Where this kind of
input/output redirection really shines is in the use of _pipes_. The `|`
operator lets you "chain" programs such that the output of one is the
input of another:

```console
missing:~$ ls -l / | tail -n1
drwxr-xr-x 1 root  root  4096 Jun 20  2019 var
missing:~$ curl --head --silent google.com | grep --ignore-case content-length | cut --delimiter=' ' -f2
219
```

We will go into a lot more detail about how to take advantage of pipes
in the lecture on data wrangling.

## 一个功能全面又强大的工具

On most Unix-like systems, one user is special: the "root" user. You may
have seen it in the file listings above. The root user is above (almost)
all access restrictions, and can create, read, update, and delete any
file in the system. You will not usually log into your system as the
root user though, since it's too easy to accidentally break something.
Instead, you will be using the `sudo` command. As its name implies, it
lets you "do" something "as su" (short for "super user", or "root").
When you get permission denied errors, it is usually because you need to
do something as root. Though make sure you first double-check that you
really wanted to do it that way!

One thing you need to be root in order to do is writing to the `sysfs` file
system mounted under `/sys`. `sysfs` exposes a number of kernel parameters as
files, so that you can easily reconfigure the kernel on the fly without
specialized tools. **Note that sysfs does not exist on Windows or macOS.**

For example, the brightness of your laptop's screen is exposed through a file
called `brightness` under

```
/sys/class/backlight
```

By writing a value into that file, we can change the screen brightness.
Your first instinct might be to do something like:

```console
$ sudo find -L /sys/class/backlight -maxdepth 2 -name '*brightness*'
/sys/class/backlight/thinkpad_screen/brightness
$ cd /sys/class/backlight/thinkpad_screen
$ sudo echo 3 > brightness
An error occurred while redirecting file 'brightness'
open: Permission denied
```

This error may come as a surprise. After all, we ran the command with
`sudo`! This is an important thing to know about the shell. Operations
like `|`, `>`, and `<` are done _by the shell_, not by the individual
program. `echo` and friends do not "know" about `|`. They just read from
their input and write to their output, whatever it may be. In the case
above, the _shell_ (which is authenticated just as your user) tries to
open the brightness file for writing, before setting that as `sudo
echo`'s output, but is prevented from doing so since the shell does not
run as root. Using this knowledge, we can work around this:

```console
$ echo 3 | sudo tee brightness
```

Since the `tee` program is the one to open the `/sys` file for writing,
and _it_ is running as `root`, the permissions all work out. You can
control all sorts of fun and useful things through `/sys`, such as the
state of various system LEDs (your path might be different):

```console
$ echo 1 | sudo tee /sys/class/leds/input6::scrolllock/brightness
```

# 下一步

学到这里，您掌握对shell知识已经可以完成一些基础对任务了。您应该已经可以查找感兴趣对文件并使用大多数程序对基本功能了。
在下一场讲座中，我们会探讨如何利用shell及其他工具执行并自动化更复杂的任务。

# 课后练习

 1. Create a new directory called `missing` under `/tmp`.
 1. Look up the `touch` program. The `man` program is your friend.
 1. Use `touch` to create a new file called `semester` in `missing`.
 1. Write the following into that file, one line at a time:
    ```
    #!/bin/sh
    curl --head --silent https://missing.csail.mit.edu
    ```
    The first line might be tricky to get working. It's helpful to know that
    `#` starts a comment in Bash, and `!` has a special meaning even within
    double-quoted (`"`) strings. Bash treats single-quoted strings (`'`)
    differently: they will do the trick in this case. See the Bash
    [quoting](https://www.gnu.org/software/bash/manual/html_node/Quoting.html)
    manual page for more information.
 1. Try to execute the file, i.e. type the path to the script (`./semester`)
    into your shell and press enter. Understand why it doesn't work by
    consulting the output of `ls` (hint: look at the permission bits of the
    file).
 1. Run the command by explicitly starting the `sh` interpreter, and giving it
    the file `semester` as the first argument, i.e. `sh semester`. Why does
    this work, while `./semester` didn't?
 1. Look up the `chmod` program (e.g. use `man chmod`).
 1. Use `chmod` to make it possible to run the command `./semester` rather than
    having to type `sh semester`. How does your shell know that the file is
    supposed to be interpreted using `sh`? See this page on the
    [shebang](https://en.wikipedia.org/wiki/Shebang_(Unix)) line for more
    information.
 1. Use `|` and `>` to write the "last modified" date output by
    `semester` into a file called `last-modified.txt` in your home
    directory.
 1. Write a command that reads out your laptop battery's power level or your
    desktop machine's CPU temperature from `/sys`. Note: if you're a macOS
    user, your OS doesn't have sysfs, so you can skip this exercise.
