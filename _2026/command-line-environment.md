---
layout: lecture
title: "命令行环境"
description: >
  学习命令行程序的工作原理，包括输入/输出流、环境变量以及使用 SSH 连接远程机器。
thumbnail: /static/assets/thumbnails/2026/lec2.png
date: 2026-01-13
ready: true
video:
  aspect: 56.25
  id: ccBGsPedE9Q
---

正如我们在上一节课所讨论的，大多数 Shell 并不只是个单纯的程序启动器。
实际上，它们提供了一套完整的编程语言，包含了各种常见的模式和抽象。
但与主流编程语言不同的是，Shell 脚本的一切设计都是为了运行程序，并让这些程序能以一种简单、高效的方式相互通信。

具体来说，Shell 脚本深受各种 *约定（conventions）* 的影响。一个命令行（CLI，Command Line Interface）程序要想在更广泛的 Shell 环境里良好协作，就必须遵循一些通用模式。
接下来，我们将介绍理解命令行程序运作逻辑所需的核心概念，以及关于如何使用、配置这些程序的常见约定。

# 命令行界面

在大多数编程语言中，写个函数大概长这样：

```
def add(x: int, y: int) -> int:
    return x + y
```

在这里，程序的输入和输出是清晰可见的。
相比之下，shell 脚本第一眼看上去可能完全是另一回事。

```shell
#!/usr/bin/env bash

if [[ -f $1 ]]; then
    echo "Target file already exists"
    exit 1
else
    if $DEBUG; then
        grep 'error' - | tee $1
    else
        grep 'error' - > $1
    fi
    exit 0
fi
```

为了准确理解这类脚本中发生了什么，我们首先需要引入几个在程序间通信或与 Shell 环境交互时高频出现的概念：

- 参数（Arguments）
- 流（Streams）
- 环境变量（Environment variables）
- 返回码（Return codes）
- 信号（Signals）

## 参数

Shell 程序在执行时会接收一个参数列表。
在 Shell 中，参数本质上就是纯字符串，由程序决定怎么解析这些字符串。
比如当我们执行 `ls -l folder/` 时，我们实际上是在运行 `/bin/ls` 这个程序，并给它传了一组参数：`['-l', 'folder/']`。

在 Shell 脚本内部，我们可以通过特定的语法来访问这些参数。
我们使用变量 `$1` 访问第一个参数，从 `$2` 到 `$9` 以此类推。使用 `$@` 把所有参数当作一个列表访问，使用 `$#` 获取参数的个数。此外，可以使用 `$0` 获得程序本身的名称。

对于大多数程序，参数通常由 *选项（flags）* 和普通的字符串组成。
选项的特征是前面带个短横线（-）或双横线（--）。
它们通常是可选的，用来修改程序的行为。
比如 `ls -l` 改变了 `ls` 的输出格式。

你会看到有着长名称的双横线选项，比如 `--all`，以及单个字母的单横线选项，比如 `-a` 。
很多时候两种格式是等价的，比如 `ls -a` 和 `ls --all` 效果一样。
单横线参数通常可以合并写，所以 `ls -l -a` 和 `ls -la` 也是等价的。
参数的顺序通常也无所谓，`ls -la` 和 `ls -al` 结果相同。
一些选项实在是太流行，以至于随着你对 Shell 环境越来越熟悉，你会本能地使用它们，例如 `--help`、`--verbose` 和 `--version`。

> 选项是 Shell 约定的一个绝佳例子。Shell 语言本身并不强制要求你用 `-` 或 `--`。
> 你完全可以写个程序用 `myprogram +myoption myfile` 这种语法，但这会把大家搞懵，因为大家都默认该用横线。
> 实际上，多数编程语言都提供了 CLI 参数解析库（比如 Python 的 `argparse` 用来解析带横线语法的参数）。

在命令行（CLI）程序中，还有一个很常见的惯例：程序往往支持传入不定数量的同类型参数。在这种情况下，命令会对每一个参数执行相同的操作。

```shell
mkdir src
mkdir docs
# 等价于
mkdir src docs
```

这种“语法糖”初看可能觉得没啥必要，但一旦配合 *通配符扩展（globbing）* 使用，威力就真正体现出来了。
通配符是 shell 在调用程序前会展开的特殊模式。

假设我们想非递归地删除当前目录下所有的 .py 文件。按照上一课学到的知识，我们可以通过下面的方式实现：

```shell
for file in $(ls | grep -P '\.py$'); do
    rm "$file"
done
```

但实际上，你只需要运行 `rm *.py` 就能直接搞定！

当你在终端输入 `rm *.py` 时，Shell 传给 `/bin/rm` 程序的参数并不是字符串 `['*.py']`。
相反，Shell 会在当前目录中搜索符合 `*.py` 模式的文件——这里的 `*` 可以匹配零个或多个任意字符。
因此，如果我们的文件夹里有 `main.py` 和 `utils.py`，那么 `rm` 程序实际接收到的参数列表是 `['main.py', 'utils.py']`。

你最常见到的通配模式包括通配符 `*`（匹配零个或多个任意字符）、`?`（恰好匹配一个任意字符），以及花括号。
花括号 `{}` 会把逗号分隔的一组模式展开成多个参数。

实际里，理解通配符最好的方式还是通过例子。

```shell
touch folder/{a,b,c}.py
# 会被扩展为
touch folder/a.py folder/b.py folder/c.py

convert image.{png,jpg}
# 会被扩展为
convert image.png image.jpg

cp /path/to/project/{setup,build,deploy}.sh /newpath
# 会被扩展为
cp /path/to/project/setup.sh /path/to/project/build.sh /path/to/project/deploy.sh /newpath

# 通配符技巧也可以被结合
mv *{.py,.sh} folder
# 会移动所有 *.py 和 *.sh 文件
```

> 有些 Shell（例如 zsh）还支持更高级的通配形式，比如 `**`，它会展开为递归路径。因此 `rm **/*.py` 会递归删除所有 `.py` 文件。


## 流

每当我们执行下面这种程序管道时：

```shell
cat myfile | grep -P '\d+' | uniq -c
```

可以看到，`grep` 同时在和 `cat`、`uniq` 两个程序通信。

这里一个很重要的观察是，这三个程序其实是同时在运行的。
也就是说，Shell 并不是先执行 `cat`，再执行 `grep`，最后执行 `uniq`。
相反，这三个程序会一起被拉起，Shell 会把 `cat` 的输出接到 `grep` 的输入上，再把 `grep` 的输出接到 `uniq` 的输入上。
当你使用管道运算符 `|` 时，Shell 会操作从前一个程序流向后一个程序的数据流。

我们可以演示一下这种并发性。管道中的所有命令都会立刻启动：

```console
$ (sleep 15 && cat numbers.txt) | grep -P '^\d$' | sort | uniq  &
[1] 12345
$ ps | grep -P '(sleep|cat|grep|sort|uniq)'
  32930 pts/1    00:00:00 sleep
  32931 pts/1    00:00:00 grep
  32932 pts/1    00:00:00 sort
  32933 pts/1    00:00:00 uniq
  32948 pts/1    00:00:00 grep
```

可以看到，除了 `cat` 以外，其他进程都会马上开始运行。Shell 会先把所有进程都创建出来，并把它们的流连接好，而不是等某个进程结束之后再启动下一个。`cat` 只有在 `sleep` 结束后才会真正开始执行，然后它的输出会流向 `grep`，后面也是同样的道理。

每个程序都有一个输入流，叫作 stdin（standard input，标准输入）。在使用管道时，stdin 会自动连上。在脚本里，很多程序还接受 `-` 作为“文件名”，表示“从 stdin 读取”：

```shell
# 当数据从管道传输时，以下是等价的
echo "hello" | grep "hello"
echo "hello" | grep "hello" -
```

类似地，每个程序还有两个输出流：stdout 和 stderr。
标准输出 stdout 是最常见的那个，也是默认会被拿去管道给下一个命令的输出。
标准错误 stderr 则是另一条流，程序会用它输出警告和其他问题信息，这样这些内容就不会被管道中的下一个命令当成正常数据继续处理。

```console
$ ls /nonexistent
ls: cannot access '/nonexistent': No such file or directory
$ ls /nonexistent | grep "pattern"
ls: cannot access '/nonexistent': No such file or directory
# The error message still appears because stderr is not piped
$ ls /nonexistent 2>/dev/null
# No output - stderr was redirected to /dev/null
```

Shell 提供了专门的语法来重定向这些流。下面是一些示例。

```shell
# 将标准输出（stdout）重定向到文件（覆盖）
echo "hello" > output.txt

# 将标准输出（stdout）重定向到文件（追加）
echo "world" >> output.txt

# 将标准错误（stderr）重定向到文件
ls foobar 2> errors.txt

# 将标准输出和标准错误同时重定向到同一个文件
ls foobar &> all_output.txt

# 从文件中重定向标准输入（stdin）
grep "pattern" < input.txt

# 通过重定向到 /dev/null 来丢弃输出
cmd > /dev/null 2>&1
```
另一个很能体现 Unix 哲学的强力工具是模糊查找器 [`fzf`](https://github.com/junegunn/fzf)。它从 stdin 读取一行行输入，并提供一个交互式界面让你筛选和选择：

```console
$ ls | fzf
$ cat ~/.bash_history | fzf
```

`fzf` 可以和很多 Shell 操作整合起来。等讲到 Shell 定制时，我们还会看到它更多的用法。


## 环境变量

在 bash 里，给变量赋值要写成 `foo=bar`，读取变量值则用 `$foo`。
注意，`foo = bar` 是非法语法，因为 Shell 会把它解析成调用程序 `foo`，并给它传入参数 `['=', 'bar']`。
在 Shell 脚本里，空格的作用就是分隔参数。
这个行为一开始很容易让人迷糊，也不太符合直觉，所以要特别记住。

Shell 变量没有类型，它们本质上全都是字符串。
还要注意，在 Shell 里写字符串时，单引号和双引号并不能互换。
用 `'` 包起来的是字面量字符串，不会展开变量、不会做命令替换，也不会处理转义序列；而 `"` 包起来的字符串则会。

```shell
foo=bar
echo "$foo"
# 打印 bar
echo '$foo'
# 打印 $foo
```

要把一个命令的输出保存到变量里，我们会用 *命令替换（command substitution）*。
当我们执行：
```shell
files=$(ls)
echo "$files" | grep README
echo "$files" | grep ".py"
```

`ls` 的输出（更具体地说，是 stdout）会被放进变量 `$files` 里，后面就可以继续使用它。
而且 `$files` 里确实保留了 `ls` 输出中的换行，这也是为什么 `grep` 这类程序能把每一项当成独立的一行来处理。

另一个相似但没那么出名的特性是 *进程替换（process substitution）*。`<( CMD )` 会执行 `CMD`，把输出放进一个临时文件里，再用这个临时文件名替换掉 `<()`。
当某个命令要求你通过文件而不是 STDIN 来传值时，这就很有用了。
比如，`diff <(ls src) <(ls docs)` 会展示 `src` 和 `docs` 两个目录中文件列表的差异。

每当一个 Shell 程序调用另一个程序时，它都会顺带传过去一组变量，这些变量通常就叫作 *环境变量（environment variables）*。
在 Shell 里，我们可以通过运行 `printenv` 查看当前环境变量。
如果想显式地给某个命令传一个环境变量，可以在命令前面直接加赋值：

> 按约定，环境变量一般都写成全大写（例如 `HOME`、`PATH`、`DEBUG`）。这不是技术上的硬性要求，但遵循这个约定能让环境变量和通常用小写命名的本地 Shell 变量区分得更清楚。

```shell
TZ=Asia/Tokyo date  # 打印东京的当前时间
echo $TZ  # 这将为空，因为 TZ 仅为子命令设置
```

另一种方式是使用内建命令 `export`，它会修改当前 Shell 的环境，因此之后启动的所有子进程都会继承这个变量：

```shell
export DEBUG=1
# 从此时起，所有程序的环境中都将具有 DEBUG=1
bash -c 'echo $DEBUG'
# 打印 1
```

要删除一个变量，可以使用内建命令 `unset`，例如 `unset DEBUG`。

> 环境变量也是 Shell 约定的一部分。它们可以用来隐式地修改很多程序的行为，而不必显式传参。比如，Shell 会把当前用户的家目录路径放进 `$HOME` 环境变量里，程序就可以直接读这个变量，而不用额外要求传一个 `--home /home/alice`。另一个常见例子是 `$TZ`，很多程序都会根据它指定的时区来格式化日期和时间。

## 返回码

前面我们已经看到，Shell 程序的主要输出通常通过 stdout/stderr 流，以及对文件系统产生的副作用来体现。

默认情况下，Shell 脚本会返回退出码 0。
按照惯例，0 表示一切正常，非 0 则表示执行过程中遇到了某些问题。
如果要主动返回一个非零退出码，需要使用 Shell 内建命令 `exit NUM`。
而上一条命令的返回码，则可以通过特殊变量 `$?` 取得。

Shell 里有布尔运算符 `&&` 和 `||`，分别表示 AND 和 OR。
但和普通编程语言里常见的布尔运算不同，Shell 里的这两个运算符是基于程序的返回码来工作的。
它们也都是[短路](https://en.wikipedia.org/wiki/Short-circuit_evaluation)运算符。
这意味着，你可以根据前一个命令是成功还是失败来有条件地执行后续命令，而“成功”的判断标准正是返回码是否为 0。看几个例子：

```shell
# echo 仅当 grep 成功时才会运行（找到匹配项）
grep -q "pattern" file.txt && echo "Pattern found"

# echo 仅在 grep 失败（不匹配）时运行
grep -q "pattern" file.txt || echo "Pattern not found"

# true 是一个总是成功的 shell 程序
true && echo "This will always print"

# false 是一个总是失败的 shell 程序
false || echo "This will always print"
```

同样的原则也适用于 `if` 和 `while` 语句，它们也是根据返回码来做判断的：

```shell
# if 使用条件命令的返回码（0 = true，非零 = false）
if grep -q "pattern" file.txt; then
    echo "Found"
fi

# 只要命令返回 0，while 循环就会继续
while read line; do
    echo "$line"
done < file.txt
```

## 信号

有时候你会需要在程序执行到一半时打断它，比如某条命令跑得太久了。
最简单的做法就是按 `Ctrl-C`，这条命令通常就会停下来。
但这背后到底发生了什么？为什么它有时又停不掉？

```console
$ sleep 100
^C
$
```

> 注意，这里的 `^C` 是 `Ctrl-C` 在终端里的显示方式。

底层实际发生的过程是这样的：

1. 我们按下了 `Ctrl-C`
2. Shell 识别出了这个特殊按键组合
3. Shell 进程向 `sleep` 进程发送了一个 `SIGINT` 信号
4. 这个信号打断了 `sleep` 进程的执行

信号是一种特殊的通信机制。
当进程收到信号时，它会停下当前执行，处理这个信号，并根据这个信号携带的信息决定是否改变后续执行流程。所以，信号本质上是一种 *软件中断（software interrupt）*。


在这个例子里，输入 `Ctrl-C` 会让 Shell 给对应进程发送一个 `SIGINT` 信号。
下面是一个最小 Python 示例：它会捕获 `SIGINT` 并忽略它，因此不会再因为 `Ctrl-C` 而停止。此时如果要杀掉这个程序，可以改用 `SIGQUIT` 信号，也就是按 `Ctrl-\`。

```python
#!/usr/bin/env python
import signal, time

def handler(signum, time):
    print("\nI got a SIGINT, but I am not stopping")

signal.signal(signal.SIGINT, handler)
i = 0
while True:
    time.sleep(.1)
    print("\r{}".format(i), end="")
    i += 1
```

如果我们先给这个程序发两次 `SIGINT`，再发一次 `SIGQUIT`，就会看到下面的结果。注意，`^` 是终端里显示 `Ctrl` 的方式。

```console
$ python sigint.py
24^C
I got a SIGINT, but I am not stopping
26^C
I got a SIGINT, but I am not stopping
30^\[1]    39913 quit       python sigint.py
```

`SIGINT` 和 `SIGQUIT` 通常都和终端里的交互操作有关，而如果你只是想更通用地请求某个进程“优雅退出”，一般会用 `SIGTERM` 信号。
发送这个信号可以使用 [`kill`](https://www.man7.org/linux/man-pages/man1/kill.1.html) 命令，语法是 `kill -TERM <PID>`。

信号除了杀进程，还能干别的事。比如，`SIGSTOP` 会暂停一个进程。在终端中，按下 `Ctrl-Z` 会让 Shell 发送一个 `SIGTSTP` 信号，也就是 Terminal Stop（也就是终端版本的 `SIGSTOP`）。

之后，我们可以分别用 [`fg`](https://www.man7.org/linux/man-pages/man1/fg.1p.html) 或 [`bg`](https://man7.org/linux/man-pages/man1/bg.1p.html)，让这个暂停的任务在前台或后台继续运行。

[`jobs`](https://www.man7.org/linux/man-pages/man1/jobs.1p.html) 命令会列出当前终端会话里尚未结束的作业。
你可以通过 pid 来引用这些作业（需要的话可以用 [`pgrep`](https://www.man7.org/linux/man-pages/man1/pgrep.1.html) 查）。
更直观一点的方式是用百分号加作业号来引用某个作业，这个作业号会显示在 `jobs` 的输出里。要引用最近一个放到后台运行的作业，可以使用特殊参数 `$!`。

还有一点要知道：命令末尾加上 `&`，就会让它在后台运行，并立即把提示符还给你。不过它仍然会使用当前 Shell 的 STDOUT，这有时会让人有点烦（这种情况下可以配合 Shell 重定向）。
类似地，如果一个程序已经在前台运行了，你也可以先按 `Ctrl-Z`，再执行 `bg`，把它转到后台。


要注意，放到后台的进程依然是当前终端的子进程，所以如果你把终端关掉，它们也会一起死掉（这时还会收到另一个信号 `SIGHUP`）。
如果不想这样，可以用 [`nohup`](https://www.man7.org/linux/man-pages/man1/nohup.1.html) 来运行程序，它本质上是个忽略 `SIGHUP` 的包装命令；如果进程已经启动了，也可以使用 `disown`。
或者，你也可以像下一节会讲到的那样，直接使用终端复用器（terminal multiplexer）。

下面是一段示例会话，用来演示其中的一些概念。

```shell
$ sleep 1000
^Z
[1]  + 18653 suspended  sleep 1000

$ nohup sleep 2000 &
[2] 18745
appending output to nohup.out

$ jobs
[1]  + suspended  sleep 1000
[2]  - running    nohup sleep 2000

$ kill -SIGHUP %1
[1]  + 18653 hangup     sleep 1000

$ kill -SIGHUP %2   # nohup 防止 SIGHUP

$ jobs
[2]  + running    nohup sleep 2000

$ kill %2
[2]  + 18745 terminated  nohup sleep 2000
```

有一个比较特殊的信号是 `SIGKILL`。它无法被进程捕获，因此总是会立刻终止进程。但它也可能带来副作用，比如留下孤儿子进程。

如果想进一步了解这些以及其他信号，可以看[这里](https://en.wikipedia.org/wiki/Signal_(IPC))，或者直接运行 [`man signal`](https://www.man7.org/linux/man-pages/man7/signal.7.html) 或 `kill -l`。

在 Shell 脚本里，你可以使用内建命令 `trap`，让脚本在收到信号时执行指定命令。这在做清理工作时很有用：

```shell
#!/usr/bin/env bash
cleanup() {
    echo "Cleaning up temporary files..."
    rm -f /tmp/mytemp.*
}
trap cleanup EXIT  # 当脚本退出时执行清理
trap cleanup SIGINT SIGTERM  # 也可以按 Ctrl-C 或 Kill
```
{% comment %}
### 用户，文件与权限

最后，程序之间还有一种间接通信方式，就是通过文件。
如果一个程序想正确地读取、写入或删除文件和目录，那么对应的文件权限必须允许它这么做。

查看某个具体文件时，你会看到类似下面的输出：

```console
$ ls -l notes.txt
-rw-r--r--  1 alice  users  12693 Jan 11 23:05 notes.txt
```

这里 `ls` 展示了文件的所有者，也就是用户 `alice`，以及所属用户组 `users`。后面的 `rw-r--r--` 则是权限的简写表示法。
在这个例子里，用户 alice 对文件 `notes.txt` 有读写权限 `rw-`，而用户组和系统中的其他用户都只有只读权限。

```console
$ ./script.sh
# permission denied
$ chmod +x script.sh
$ ls -l script.sh
-rwxr-xr-x  1 alice  users  3125 Jan 11 23:07 script.sh
$ ./script.sh
```

一个脚本想要可执行，就必须先设置可执行权限，所以这里我们需要用到 `chmod`（change mode）这个程序。
`chmod` 的语法虽然有一定直觉性，但第一次看到时通常并不算直观。
如果你和我一样更喜欢通过例子来学，那么这里就很适合用 `tldr` 工具（注意它通常需要先安装）。

```console
❯ tldr chmod
  Change the access permissions of a file or directory.
  More information: <https://www.gnu.org/software/coreutils/chmod>.

  Give the [u]ser who owns a file the right to e[x]ecute it:

      chmod u+x path/to/file

  Give the [u]ser rights to [r]ead and [w]rite to a file/directory:

      chmod u+rw path/to/file_or_directory

  Give [a]ll users rights to [r]ead and e[x]ecute:

      chmod a+rx path/to/file
```

运行 `tldr chmod` 可以看到更多例子，包括递归操作和用户组权限相关的用法。

> 你的 shell 可能会提示类似 `command not found: tldr` 的错误。这是因为它属于比较新的工具，大多数系统默认并不会预装。想查某个工具怎么安装，可以参考 [https://command-not-found.com](https://command-not-found.com) 这个网站。它收录了大量 CLI 工具在主流发行版上的安装说明。

系统里的每个程序都会以某个特定用户的身份运行。我们可以用 `whoami` 查看当前用户名，用 `id -u` 查看 UID（user id），也就是操作系统分配给该用户的整数标识。

当你运行 `sudo command` 时，`command` 会以 root 用户身份执行，而 root 可以绕过系统里的大多数权限限制。
你可以试试运行 `sudo whoami` 和 `sudo id -u`，看看输出会发生什么变化（系统可能会要求你输入密码）。
如果要修改文件或目录的所有者，可以使用 `chown` 命令。

如果想进一步了解 UNIX 文件权限，可以看[这里](https://en.wikipedia.org/wiki/File-system_permissions#Traditional_Unix_permissions)。

到目前为止，我们讨论的主要还是本地机器，但这些技能在远程服务器场景下往往会更有价值。

{% endcomment %}

# 远程机器

现在，程序员在日常工作中接触远程服务器已经越来越常见。这里最常用的工具是 SSH（Secure Shell），它可以帮助我们连接到远程服务器，并提供一个你现在已经很熟悉的 shell 界面。连接服务器的命令通常像这样：

```bash
ssh alice@server.mit.edu
```

这里表示我们要以用户 `alice` 的身份登录服务器 `server.mit.edu`。

`ssh` 有一个经常被忽略的能力，就是可以非交互式地执行命令。`ssh` 会正确处理把 stdin 发送给远程命令，以及接收该命令的 stdout，因此它也可以和其他命令组合使用。

```shell
# 这里 ls 在远程执行，wc 在本地执行
ssh alice@server ls | wc -l

# 这里 ls 和 wc 都在远程服务器上执行
ssh alice@server 'ls | wc -l'

```

> 可以试试安装 [Mosh](https://mosh.org/) 作为 SSH 的替代品。它能更好地处理断线、设备休眠/唤醒、网络切换，以及高延迟链路等情况。

想让 `ssh` 允许我们在远程服务器上执行命令，就必须先证明自己有这个权限。
这个认证过程可以通过密码，也可以通过 SSH 密钥来完成。
基于密钥的认证使用公钥密码学，在不泄露私钥本身的前提下，向服务器证明客户端持有那把私钥。
密钥认证既更方便，也更安全，因此通常应该优先使用。
注意，私钥（过去常见的是 `~/.ssh/id_rsa`，现在更常见的是 `~/.ssh/id_ed25519`）本质上就等同于你的密码，所以一定要像对待密码一样保管，绝不要把内容泄露出去。

要生成一对密钥，可以运行 [`ssh-keygen`](https://www.man7.org/linux/man-pages/man1/ssh-keygen.1.html)。

```bash
ssh-keygen -a 100 -t ed25519 -f ~/.ssh/id_ed25519
```

如果你以前配置过用 SSH key 向 GitHub push，那么大概率已经按照[这里](https://help.github.com/articles/connecting-to-github-with-ssh/)的步骤操作过，也已经有一对可用的密钥了。要检查你是否拥有密钥短语，以及验证它是否有效，可以运行 `ssh-keygen -y -f /path/to/key`。

在服务器端，`ssh` 会查看 `.ssh/authorized_keys`，以决定允许哪些客户端登录。要把公钥复制过去，可以这样做：

```bash
cat .ssh/id_ed25519.pub | ssh alice@remote 'cat >> ~/.ssh/authorized_keys'

# 或者更简单一点（如果系统提供了 ssh-copy-id）

ssh-copy-id -i .ssh/id_ed25519 alice@remote
```

除了执行命令，SSH 建立起来的连接还可以安全地在本地和服务器之间传输文件。[`scp`](https://www.man7.org/linux/man-pages/man1/scp.1.html) 是最传统的工具，语法是 `scp path/to/local_file remote_host:path/to/remote_file`。[`rsync`](https://www.man7.org/linux/man-pages/man1/rsync.1.html) 在 `scp` 的基础上做了改进，它会检测本地和远程是否已有相同文件，从而避免重复复制。它还对符号链接、权限等细节提供了更细粒度的控制，也有像 `--partial` 这样的额外特性，可以从上次中断的位置继续传输。`rsync` 的语法和 `scp` 比较接近。

SSH 客户端配置文件位于 `~/.ssh/config`，你可以在里面声明主机别名，并为它们设置默认参数。这个配置文件不只是 `ssh` 会读取，`scp`、`rsync`、`mosh` 等程序也会使用它。

```bash
Host vm
    User alice
    HostName 172.16.174.141
    Port 2222
    IdentityFile ~/.ssh/id_ed25519

# 配置也可以使用通配符
Host *.mit.edu
    User alice
```




# 终端复用器

在命令行里工作时，你经常会想同时运行不止一件事。
比如你可能想把编辑器和正在运行的程序并排放在一起。
虽然多开几个终端窗口也能做到，但使用终端复用器会是一个更灵活的方案。

像 [`tmux`](https://www.man7.org/linux/man-pages/man1/tmux.1.html) 这样的终端复用器，允许你通过窗格（pane）和标签页（tab）来复用终端窗口，从而高效地同时操作多个 shell 会话。
除此之外，终端复用器还支持把当前终端会话分离（detach）出去，并在之后的某个时间重新附着（attach）回来。
正因为这样，它在远程机器上尤其方便，因为你通常就不再需要 `nohup` 之类的技巧了。

现在最流行的终端复用器大概就是 [`tmux`](https://www.man7.org/linux/man-pages/man1/tmux.1.html)。`tmux` 的可配置性很高，配合它的快捷键，你可以创建多个标签页（tab）和窗格（pane），并在它们之间快速切换。

`tmux` 要求你记住它的快捷键，它们大多都写成 `<C-b> x` 这种形式，意思是：(1) 按下 `Ctrl+b`，(2) 松开 `Ctrl+b`，然后 (3) 再按 `x`。`tmux` 的对象层级大致如下：

- **Sessions（会话）** - 一个 session 是一个独立的工作区，里面可以包含一个或多个 window。
    + `tmux` 会启动一个新的 session。
    + `tmux new -s NAME` 会以指定名称启动一个 session。
    + `tmux ls` 用来列出当前所有 session。
    + 在 `tmux` 里按 `<C-b> d` 可以分离（detach）当前 session。
    + `tmux a` 会附着（attach）到最近一个 session，也可以用 `-t` 指定具体是哪一个。

- **Windows（窗口）** - 相当于编辑器或浏览器里的 tab，它们是同一个 session 中视觉上彼此分开的部分。
    + `<C-b> c` 创建一个新 window。想关闭它的话，直接在里面的 shell 里按 `<C-d>` 退出即可。
    + `<C-b> N` 跳到第 _N_ 个 window。注意 window 是有编号的。
    + `<C-b> p` 切换到前一个 window。
    + `<C-b> n` 切换到后一个 window。
    + `<C-b> ,` 重命名当前 window。
    + `<C-b> w` 列出当前所有 window。

- **Panes（窗格）** - 类似 vim 的 split，pane 允许你在同一个可视区域里同时放多个 shell。
    + `<C-b> "` 水平拆分当前 pane。
    + `<C-b> %` 垂直拆分当前 pane。
    + `<C-b> <direction>` 切换到指定 _direction_ 方向的 pane，这里的 direction 指方向键。
    + `<C-b> z` 切换当前 pane 的缩放状态。
    + `<C-b> [` 进入滚动回看模式。之后你可以按 `<space>` 开始选择，再按 `<enter>` 复制选中的内容。
    + `<C-b> <space>` 在不同 pane 布局之间轮换。

> 如果你想更深入了解 tmux，可以看看[这篇](https://www.hamvocke.com/blog/a-quick-and-easy-guide-to-tmux/)快速教程，以及[这篇](https://linuxcommand.org/lc3_adv_termmux.php)更详细的说明。

当你的工具箱里已经有了 tmux 和 SSH，你大概也会希望无论在哪台机器上，都能把环境调整成自己熟悉的样子。这时就该开始做 shell 自定义了。

# 定制 Shell

很多命令行程序都是通过纯文本配置文件来配置的，这类文件通常被称为 _dotfiles_。
之所以叫这个名字，是因为文件名通常以 `.` 开头，比如 `~/.vimrc`，因此默认情况下在 `ls` 的目录列表里是隐藏的。

> Dotfiles 也是 shell 世界里的另一种约定。文件名前面的点号就是为了在列目录时把它们“隐藏”起来（没错，又是一个约定）。

Shell 本身就是这类通过 dotfiles 配置的程序之一。启动时，它会读取多个文件来加载配置。
具体会读哪些文件，取决于你使用的是哪种 shell，以及当前启动的是 login session、interactive session，还是两者兼有，因此整个过程其实可能相当复杂。
如果你想深入了解这一点，[这里](https://blog.flowblok.id.au/2013-02/shell-startup-scripts.html)有一篇很好的参考资料。

对于 `bash` 来说，在大多数系统里编辑 `.bashrc` 或 `.bash_profile` 就足够了。
其他一些也常通过 dotfiles 配置的工具包括：

- `bash` - `~/.bashrc`, `~/.bash_profile`
- `git` - `~/.gitconfig`
- `vim` - `~/.vimrc` and the `~/.vim` folder
- `ssh` - `~/.ssh/config`
- `tmux` - `~/.tmux.conf`

一种很常见的配置修改，是为 shell 增加额外的程序搜索路径。安装软件时你会经常遇到这种写法：

```shell
export PATH="$PATH:path/to/append"
```

这里的意思是，把 `$PATH` 变量设置为“当前值加上一个新路径”，并让所有子进程继承这个新的 PATH 值。
这样一来，子进程就能找到位于 `path/to/append` 下的程序。


自定义 shell 往往也意味着要安装一些新的命令行工具。包管理器可以让这件事简单很多，它们负责下载、安装和更新软件。不同操作系统使用的包管理器也不同：macOS 常用 [Homebrew](https://brew.sh/)，Ubuntu/Debian 用 `apt`，Fedora 用 `dnf`，Arch 用 `pacman`。我们会在发布代码（shipping code）那一讲里更详细地介绍包管理器。

下面是在 macOS 上使用 Homebrew 安装两个实用工具的示例：

```shell
# ripgrep：更快、默认行为也更合理的 grep
brew install ripgrep

# fd：更快、也更易用的 find
brew install fd
```

装好之后，你就可以用 `rg` 替代 `grep`，用 `fd` 替代 `find`。

> **关于 `curl | bash` 的提醒**：你经常会看到类似 `curl -fsSL https://example.com/install.sh | bash` 这样的安装命令。这个模式会先下载脚本，然后立刻执行，确实方便，但也有风险，因为你是在运行一段自己还没检查过的代码。更稳妥的做法是先下载、先看一遍，再执行：
> ```shell
> curl -fsSL https://example.com/install.sh -o install.sh
> less install.sh  # 检查脚本内容
> bash install.sh
> ```
> 有些安装器会用一个稍微安全一点的变体：`/bin/bash -c "$(curl -fsSL https://url)"`，至少这样能确保脚本是由 bash 解释，而不是交给你当前的 shell。

当你尝试运行一个还没安装的命令时，shell 一般会提示 `command not found`。这时可以看看 [command-not-found.com](https://command-not-found.com)，你可以在这个网站上搜索任意命令，查看它在不同包管理器和发行版里该如何安装。

另一个很有用的工具是 [`tldr`](https://tldr.sh/)。它提供的是简化版、以示例为中心的 man page。你不用通读完整的长篇文档，就能很快看到最常见的用法：

```console
$ tldr fd
  An alternative to find.
  Aims to be faster and easier to use than find.

  Recursively find files matching a pattern in the current directory:
      fd "pattern"

  Find files that begin with "foo":
      fd "^foo"

  Find files with a specific extension:
      fd --extension txt
```

有时候你并不需要一个全新的程序，而只是想给某个现有命令配上一组固定参数，做成一个更顺手的快捷写法。这就是 alias 的用武之地。

我们也可以用 shell 内建的 `alias` 命令自己定义命令别名。
shell alias 本质上是另一个命令的简写形式，shell 在真正执行之前，会先自动把它替换掉。
比如在 bash 里，alias 的结构大致是这样：

```bash
alias alias_name="command_to_alias arg1 arg2"
```

> 注意，等号 `=` 两边不能有空格，因为 [`alias`](https://www.man7.org/linux/man-pages/man1/alias.1p.html) 是一个 shell 命令，它接收的是单个参数。

alias 有不少很方便的用法：

```bash
# 为常用选项制作简写
alias ll="ls -lh"

# 节省大量输入常用命令的时间
alias gs="git status"
alias gc="git commit"

# 避免输入错误
alias sl=ls

# 覆盖现有命令以获得更好的默认值
alias mv="mv -i"           # -i 覆盖前提示
alias mkdir="mkdir -p"     # -p 根据需要创建父目录
alias df="df -h"           # -h 打印人类可读的格式

# 可以组成别名
alias la="ls -A"
alias lla="la -l"

# 要忽略别名，请运行它并在其前面加上 \
\ls
# 或者使用 unalias 完全禁用别名
unalias la

# 要获取别名定义，只需使用 alias 调用它
alias ll
# 将打印 ll='ls -lh'
```

不过 alias 也有局限：它不能在命令中间接收参数。只要行为稍微复杂一点，就应该改用 shell function。

大多数 shell 都支持用 `Ctrl-R` 进行反向历史搜索。按下 `Ctrl-R` 之后开始输入，就可以在之前执行过的命令里查找。前面我们介绍过 `fzf` 这个模糊查找工具；如果配置好它的 shell 集成，那么 `Ctrl-R` 就会变成一个可交互的历史命令模糊搜索，比默认版本强大得多。

dotfiles 应该怎么组织？比较推荐的做法是：把它们放在一个单独的目录里，纳入版本控制，再用脚本通过 **符号链接（symlink）** 把它们链接到实际位置。这样做有几个好处：

- **安装方便**：登录到一台新机器时，应用这些配置只需要一分钟。
- **可移植性**：无论在哪台机器上，工具的行为都尽量保持一致。
- **便于同步**：你可以在任何地方更新 dotfiles，并让它们始终保持同步。
- **变更可追踪**：你大概率会在整个职业生涯中一直维护这些 dotfiles，而长期项目保留版本历史总是件好事。

那应该把什么放进 dotfiles 里？
你可以通过在线文档或者 [man page](https://en.wikipedia.org/wiki/Man_page) 了解工具支持哪些配置。另一个很好的办法，是在网上搜索某个程序的相关文章，作者通常会分享自己偏好的定制方式。再一种方法，就是直接看看别人的 dotfiles：GitHub 上有很多 [dotfiles 仓库](https://github.com/search?o=desc&q=dotfiles&s=stars&type=Repositories)，最热门的一个在 [这里](https://github.com/mathiasbynens/dotfiles)（不过我们不建议你不加判断地整套照抄）。
[这里](https://dotfiles.github.io/) 也是关于这个主题的不错资源。

这门课几位讲师的 dotfiles 也都公开放在 GitHub 上：[Anish](https://github.com/anishathalye/dotfiles)、
[Jon](https://github.com/jonhoo/configs)、
[Jose](https://github.com/jjgo/dotfiles)。

**框架和插件（frameworks and plugins）** 也能进一步提升你的 shell 体验。比较常见的通用框架有 [prezto](https://github.com/sorin-ionescu/prezto) 和 [oh-my-zsh](https://ohmyz.sh/)，另外还有一些专注于特定功能的小插件：

- [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting) - 输入时为合法或不合法的命令着色
- [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions) - 根据历史记录实时给出命令建议
- [zsh-completions](https://github.com/zsh-users/zsh-completions) - 补充更多自动补全定义
- [zsh-history-substring-search](https://github.com/zsh-users/zsh-history-substring-search) - 类似 fish 的历史搜索
- [powerlevel10k](https://github.com/romkatv/powerlevel10k) - 速度快、可定制性高的 prompt 主题

像 [fish](https://fishshell.com/) 这样的 shell，默认就内置了很多这类功能。

> 想要这些功能，并不一定非得用 oh-my-zsh 这种大而全的框架。单独安装需要的插件，通常更快，也更容易掌控。大型框架可能会明显拖慢 shell 启动速度，所以最好只安装你真正会用到的部分。

# Shell 中的 AI

把 AI 工具集成进 shell 的方式有很多，下面给几个不同集成层次的例子：

**命令生成（Command generation）**：像 [`simonw/llm`](https://github.com/simonw/llm) 这样的工具，可以根据自然语言描述生成 shell 命令：

```console
$ llm cmd "find all python files modified in the last week"
find . -name "*.py" -mtime -7
```

**管道集成（Pipeline integration）**：LLM 也可以集成到 shell pipeline 里，用来处理和转换数据。尤其是在你需要从格式不一致的文本中提取信息、而用正则会很麻烦的时候，这种方式会特别方便：

```console
$ cat users.txt
Contact: john.doe@example.com
User 'alice_smith' logged in at 3pm
Posted by: @bob_jones on Twitter
Author: Jane Doe (jdoe)
Message from mike_wilson yesterday
Submitted by user: sarah.connor
$ INSTRUCTIONS="Extract just the username from each line, one per line, nothing else"
$ llm "$INSTRUCTIONS" < users.txt
john.doe
alice_smith
bob_jones
jdoe
mike_wilson
sarah.connor
```

注意这里我们写的是 `"$INSTRUCTIONS"`，也就是带引号的形式，因为这个变量里包含空格；而 `< users.txt` 则是把文件内容重定向到标准输入（stdin）。

**AI shell**：像 [Claude Code](https://docs.anthropic.com/en/docs/claude-code) 这样的工具，可以看作是一层“元 shell（meta-shell）”，它接收英文指令，再把它们转换成 shell 操作、文件编辑和更复杂的多步骤任务。

# 终端模拟器

除了自定义 shell 本身，你也值得花点时间认真挑选一下 **终端模拟器（terminal emulator）** 以及它的配置。
终端模拟器是一个图形界面程序，它提供了你运行 shell 时看到的那层文本界面。
市面上的终端模拟器有很多。

考虑到你可能会在终端里花上几百甚至几千个小时，认真看看这些设置是值得的。你可能会想调整的方面包括：

- 字体选择
- 配色方案
- 键盘快捷键
- 标签页 / 分栏支持
- 回滚缓冲区配置
- 性能（一些较新的终端，比如 [Alacritty](https://github.com/alacritty/alacritty) 或 [Ghostty](https://ghostty.org/)，支持 GPU 加速）。

# 练习

## 参数与 Globs

1. 你可能见过像 `cmd --flag -- --notaflag` 这样的命令。这里的 `--` 是一个特殊参数，它告诉程序后面不要再继续解析选项（flag）了。也就是说，`--` 后面的所有内容都会被当作位置参数（positional argument）。这有什么用？试着运行 `touch -- -myfile`，然后在不使用 `--` 的情况下把它删掉。

1. 阅读 [`man ls`](https://www.man7.org/linux/man-pages/man1/ls.1.html)，写出一个 `ls` 命令，让它按下面的方式列出文件：
    - 包含所有文件，包括隐藏文件
    - 文件大小以易读格式显示（例如 `454M`，而不是 `454279954`）
    - 按最近修改时间排序
    - 输出带颜色

    示例输出大概像这样：

    ```
    -rw-r--r--   1 user group 1.1M Jan 14 09:53 baz
    drwxr-xr-x   5 user group  160 Jan 14 09:53 .
    -rw-r--r--   1 user group  514 Jan 14 06:42 bar
    -rw-r--r--   1 user group 106M Jan 13 12:12 foo
    drwx------+ 47 user group 1.5K Jan 12 18:08 ..
    ```

{% comment %}
ls -lath --color=auto
{% endcomment %}

1. 进程替换 `<(command)` 可以让你把一个命令的输出当成文件来用。试着配合 `diff` 和进程替换，比较 `printenv` 与 `export` 的输出。它们为什么不一样？（提示：可以试试 `diff <(printenv | sort) <(export | sort)`）

## 环境变量

1. 写两个 bash 函数 `marco` 和 `polo`，行为如下：每次执行 `marco` 时，都要以某种方式保存当前工作目录；之后无论你切到哪个目录，只要执行 `polo`，它都应该把你 `cd` 回执行 `marco` 时所在的目录。为了方便调试，你可以把代码写进 `marco.sh`，然后通过执行 `source marco.sh` 把这些定义重新加载到当前 shell。

{% comment %}
marco() {
    export MARCO=$(pwd)
}

polo() {
    cd "$MARCO"
}
{% endcomment %}

## 返回码

1. 假设你有一个很少失败的命令。为了调试它，你需要把它的输出保存下来，但等到一次失败运行可能会很耗时。写一个 bash 脚本，不断运行下面这个脚本直到它失败为止，并把标准输出和标准错误分别保存到文件里，最后把结果打印出来。如果你还能顺便报告它运行了多少次才失败，就加分。

    ```bash
    #!/usr/bin/env bash

    n=$(( RANDOM % 100 ))

    if [[ n -eq 42 ]]; then
       echo "Something went wrong"
       >&2 echo "The error was using magic numbers"
       exit 1
    fi

    echo "Everything went according to plan"
    ```

{% comment %}
#!/usr/bin/env bash

count=0
until [[ "$?" -ne 0 ]];
do
  count=$((count+1))
  ./random.sh &> out.txt
done

echo "found error after $count runs"
cat out.txt
{% endcomment %}

## 信号与任务控制

1. 在终端里启动一个 `sleep 10000` 任务，用 `Ctrl-Z` 把它挂起，再用 `bg` 让它继续在后台运行。然后使用 [`pgrep`](https://www.man7.org/linux/man-pages/man1/pgrep.1.html) 找到它的 pid，再用 [`pkill`](https://man7.org/linux/man-pages/man1/pgrep.1.html) 把它杀掉，整个过程都不要手动输入这个 pid。（提示：试试 `-af` 参数）

1. 假设你不想在某个进程完成之前启动另一个进程，你会怎么做？在这个练习里，限制条件始终是 `sleep 60 &`。一种实现方式是使用 [`wait`](https://www.man7.org/linux/man-pages/man1/wait.1p.html) 命令。试着启动这个 `sleep`，然后让一个 `ls` 等到后台进程结束后再执行。

    不过，如果我们是在另一个 bash 会话里启动的，这个策略就失效了，因为 `wait` 只对当前 shell 的子进程有效。讲义里还没提到的一点是：`kill` 命令成功时退出状态为 0，失败时则非 0。`kill -0` 不会真的发送信号，但如果进程不存在，它会返回非 0。写一个叫 `pidwait` 的 bash 函数，接收一个 pid，并一直等待到该进程结束。你应该用 `sleep` 来避免空转浪费 CPU。

## 文件与权限

1. （进阶）写一个命令或脚本，递归找出某个目录中最近修改过的文件。更一般一点，你能不能按“最近修改时间”列出所有文件？

## 终端复用器

1. 跟着这篇 `tmux` [教程](https://www.hamvocke.com/blog/a-quick-and-easy-guide-to-tmux/) 先上手，然后再按照 [这些步骤](https://www.hamvocke.com/blog/a-guide-to-customizing-your-tmux-conf/) 学习一些基础定制。

## Aliases 与 Dotfiles

1. 创建一个 alias `dc`，让你把 `cd` 打错时也能正常工作。

1. 运行 `history | awk '{$1="";print substr($0,2)}' | sort | uniq -c | sort -n | tail -n 10`，找出你最常用的 10 条命令，并考虑给它们写更短的 alias。注意：这条命令适用于 Bash；如果你用的是 ZSH，把 `history` 换成 `history 1`。

1. 为你的 dotfiles 建一个目录，并把它纳入版本控制。

1. 至少为一个程序加入配置，比如你的 shell，并做一些定制（刚开始时，哪怕只是通过设置 `$PS1` 来调整 shell prompt 也可以）。

1. 配置一种方法，让你能在新机器上快速、自动地安装 dotfiles。这可以简单到只是写一个 shell 脚本，对每个文件执行 `ln -s`；也可以使用一个 [专门的工具](https://dotfiles.github.io/utilities/)。

1. 在一台全新的虚拟机上测试你的安装脚本。

1. 把你当前所有工具的配置都迁移到 dotfiles 仓库里。

1. 把你的 dotfiles 发布到 GitHub。

## 远程机器（SSH）

为了完成下面这些练习，请安装一台 Linux 虚拟机（或者直接使用一台现成的）。如果你不熟悉虚拟机，可以先看看[这篇](https://hibbard.eu/install-ubuntu-virtual-box/)安装教程。

1. 进入 `~/.ssh/`，检查你是否已经有一对 SSH 密钥。如果没有，就用 `ssh-keygen -a 100 -t ed25519` 生成一对。建议给密钥设置密码，并配合 `ssh-agent` 使用，更多信息见[这里](https://www.ssh.com/ssh/agent)。

1. 编辑 `.ssh/config`，加入下面这样的配置项：

    ```bash
    Host vm
        User username_goes_here
        HostName ip_goes_here
        IdentityFile ~/.ssh/id_ed25519
        LocalForward 9999 localhost:8888
    ```

1. 使用 `ssh-copy-id vm` 把你的 SSH 公钥复制到服务器上。

1. 在虚拟机里执行 `python -m http.server 8888` 启动一个 Web 服务器。然后在你自己的机器上访问 `http://localhost:9999`，确认自己能访问虚拟机里的这个服务。

1.  运行 `sudo vim /etc/ssh/sshd_config` 编辑 SSH 服务端配置，把 `PasswordAuthentication` 改成禁用密码认证，再把 `PermitRootLogin` 改成禁用 root 登录。然后执行 `sudo service sshd restart` 重启 `ssh` 服务，再试着重新 SSH 登录。

1. （挑战）在虚拟机里安装 [`mosh`](https://mosh.org/)，并建立连接。然后断开服务器/虚拟机的网卡。`mosh` 能不能正确恢复连接？

1.  （挑战）查一下 `ssh` 里的 `-N` 和 `-f` 参数分别是什么意思，然后写出一条能够实现后台端口转发的命令。
