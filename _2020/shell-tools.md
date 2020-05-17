---
layout: lecture
title: "Shell 工具和脚本"
date: 2019-01-14
ready: true
video:
  aspect: 56.25
  id: kgII-YWo3Zw
---

在这节课中，我们将会展示bash作为脚本语言的一些基础操作，以及几种最常用的shell工具。


# Shell 脚本

到目前为止，我们已经学习来如何在shell中执行命令，并使用管道将命令组合使用。但是，很多情况下我们需要执行一系列到操作并使用条件或循环这样的控制流。

Shell scripts are the next step in complexity.
Most shells have their own scripting language with variables, control flow and its own syntax.
What makes shell scripting different from other scripting programming language is that is optimized for performing shell related tasks.
Thus, creating command pipelines, saving results into files or reading from standard input are primitives in shell scripting which makes it easier to use than general purpose scripting languages.
For this section we will focus on bash scripting since it is the most common.

To assign variables in bash use the syntax `foo=bar` and access the value of the variable with `$foo`.
Note that `foo = bar` will not work since it is interpreted as calling the `foo` program with arguments `=` and `bar`.
In general, in shell scripts the space character will perform argument splitting and it can be confusing to use at first so always check for that.

Strings in bash can be defined with `'` and `"` delimiters but they are not equivalent.
Strings delimited with `'` are literal strings and will not substitute variable values whereas `"` delimited strings will.

```bash
foo=bar
echo "$foo"
# prints bar
echo '$foo'
# prints $foo
```

As with most programming languages, bash supports control flow techniques including `if`, `case`, `while` and `for`.
Similarly, `bash` has functions that take arguments and can operate with them. Here is an example of a function that creates a directory and `cd`s into it.


```bash
mcd () {
    mkdir -p "$1"
    cd "$1"
}
```

这里 `$1` 是脚本到第一个参数。与其他脚本语言不同到是，bash使用了很多特殊到变量来表示参数、错误代码和相关变量。下面是列举来其中一些变量，更完整到列表可以参考 [这里](https://www.tldp.org/LDP/abs/html/special-chars.html)。
- `$0` - 脚本名
- `$1` 到 `$9` - 脚本到参数。 `$1` 是第一个参数，依此类推。
- `$@` - 所有参数
- `$#` - 参数个数
- `$?` - 前一个命令到返回值
- `$$` - 当前脚本到进程识别码
- `!!` - 完整到上一条命令，包括参数。常见应用：当你因为权限不足执行命令失败时，可以使用 `sudo !!`再尝试一次。
- `$_` - 上一条命令的最后一个参数。如果你正在使用的是交互式shell，你可以通过按下 `Esc` 之后键入 . 来获取这个值。

命令通常使用 `STDOUT`来返回输出值，使用`STDERR` 来返回错误及错误码，便于脚本以更加友好到方式报告错误。
返回码或退出状态是脚本/命令之间交流执行状态到方式。返回值0表示正常执行，其他所有非0的返回值都表示有错误发生。

退出码可以搭配`&&` (与操作符) 和 `||` (或操作符)使用，用来进行条件判断，决定是否执行其他程序。同一行的多个命令可以用` ; `分隔。程序 `true` 的返回码永远是`0`，`false` 的返回码永远是`1`。让我们看几个例子

```bash
false || echo "Oops, fail"
# Oops, fail

true || echo "Will not be printed"
#

true && echo "Things went well"
# Things went well

false && echo "Will not be printed"
#

false ; echo "This will always run"
# This will always run
```

Another common pattern is wanting to get the output of a command as a variable. This can be done with _command substitution_.
Whenever you place `$( CMD )` it will execute `CMD`, get the output of the command and substitute it in place.
For example, if you do `for file in $(ls)`, the shell will first call `ls` and then iterate over those values.
A lesser known similar feature is _process substitution_, `<( CMD )` will execute `CMD` and place the output in a temporary file and substitute the `<()` with that file's name. This is useful when commands expect values to be passed by file instead of by STDIN. For example, `diff <(ls foo) <(ls bar)` will show differences between files in dirs  `foo` and `bar`.


Since that was a huge information dump let's see an example that showcases some of these features. It will iterate through the arguments we provide, `grep` for the string `foobar` and append it to the file as a comment if it's not found.

```bash
#!/bin/bash

echo "Starting program at $(date)" # Date will be substituted

echo "Running program $0 with $# arguments with pid $$"

for file in $@; do
    grep foobar $file > /dev/null 2> /dev/null
    # When pattern is not found, grep has exit status 1
    # We redirect STDOUT and STDERR to a null register since we do not care about them
    if [[ $? -ne 0 ]]; then
        echo "File $file does not have any foobar, adding one"
        echo "# foobar" >> "$file"
    fi
done
```

In the comparison we tested whether `$?` was not equal to 0.
Bash implements many comparisons of this sort, you can find a detailed list in the manpage for [`test`](http://man7.org/linux/man-pages/man1/test.1.html).
When performing comparisons in bash try to use double brackets `[[ ]]` in favor of simple brackets `[ ]`. Chances of making mistakes are lower although it won't be portable to `sh`. A more detailed explanation can be found [here](http://mywiki.wooledge.org/BashFAQ/031).

When launching scripts, you will often want to provide arguments that are similar. Bash has ways of making this easier, expanding expressions by carrying out filename expansion. These techniques are often referred to as shell _globbing_.
- Wildcards - Whenever you want to perform some sort of wildcard matching you can use `?` and `*` to match one or any amount of characters respectively. For instance, given files `foo`, `foo1`, `foo2`, `foo10` and `bar`, the command `rm foo?` will delete `foo1` and `foo2` whereas `rm foo*` will delete all but `bar`.
- Curly braces `{}` - Whenever you have a common substring in a series of commands you can use curly braces for bash to expand this automatically. This comes in very handy when moving or converting files.

```bash
convert image.{png,jpg}
# Will expand to
convert image.png image.jpg

cp /path/to/project/{foo,bar,baz}.sh /newpath
# Will expand to
cp /path/to/project/foo.sh /path/to/project/bar.sh /path/to/project/baz.sh /newpath

# Globbing techniques can also be combined
mv *{.py,.sh} folder
# Will move all *.py and *.sh files


mkdir foo bar
# This creates files foo/a, foo/b, ... foo/h, bar/a, bar/b, ... bar/h
touch {foo,bar}/{a..h}
touch foo/x bar/y
# Show differences between files in foo and bar
diff <(ls foo) <(ls bar)
# Outputs
# < x
# ---
# > y
```

<!-- Lastly, pipes `|` are a core feature of scripting. Pipes connect one program's output to the next program's input. We will cover them more in detail in the data wrangling lecture. -->

Writing `bash` scripts can be tricky and unintuitive. There are tools like [shellcheck](https://github.com/koalaman/shellcheck) that will help you find out errors in your sh/bash scripts.

Note that scripts need not necessarily be written in bash to be called from the terminal. For instance, here's a simple Python script that outputs its arguments in reversed order

```python
#!/usr/local/bin/python
import sys
for arg in reversed(sys.argv[1:]):
    print(arg)
```

The shell knows to execute this script with a python interpreter instead of a shell command because we included a [shebang](https://en.wikipedia.org/wiki/Shebang_(Unix)) line at the top of the script.
It is good practice to write shebang lines using the [`env`](http://man7.org/linux/man-pages/man1/env.1.html) command that will resolve to wherever the command lives in the system, increasing the portability of your scripts. To resolve the location, `env` will make use of the `PATH` environment variable we introduced in the first lecture.
For this example the shebang line would look like `#!/usr/bin/env python`.

Some differences between shell functions and scripts that you should keep in mind are:
- Functions have to be in the same language as the shell, while scripts can be written in any language. This is why including a shebang for scripts is important.
- Functions are loaded once when their definition is read. Scripts are loaded every time they are executed. This makes functions slightly faster to load but whenever you change them you will have to reload their definition.
- Functions are executed in the current shell environment whereas scripts execute in their own process. Thus, functions can modify environment variables, e.g. change your current directory, whereas scripts can't. Scripts will be passed by value environment variables that have been exported using [`export`](http://man7.org/linux/man-pages/man1/export.1p.html)
- As with any programming language functions are a powerful construct to achieve modularity, code reuse and clarity of shell code. Often shell scripts will include their own function definitions.

# Shell 工具

## 查看命令如何使用

At this point you might be wondering how to find the flags for the commands in the aliasing section such as `ls -l`, `mv -i` and `mkdir -p`.
More generally, given a command how do you go about finding out what it does and its different options?
You could always start googling, but since UNIX predates StackOverflow there are builtin ways of getting this information.

As we saw in the shell lecture, the first order approach is to call said command with the `-h` or `--help` flags. A more detailed approach is to use the `man` command.
Short for manual, [`man`](http://man7.org/linux/man-pages/man1/man.1.html) provides a manual page (called manpage) for a command you specify.
For example, `man rm` will output the behavior of the `rm` command along with the flags that it takes including the `-i` flag we showed earlier.
In fact, what I have been linking so far for every command is the online version of Linux manpages for the commands.
Even non native commands that you install will have manpage entries if the developer wrote them and included them as part of the installation process.
For interactive tools such as the ones based on ncurses, help for the commands can often be accessed within the program using the `:help` command or typing `?`.

Sometimes manpages can be overly detailed descriptions of the commands and it can become hard to decipher what flags/syntax to use for common use cases.
[TLDR pages](https://tldr.sh/) are a nifty complementary solution that focuses on giving example use cases of a command so you can quickly figure out which options to use.
For instance, I find myself referring back to the tldr pages for [`tar`](https://tldr.ostera.io/tar) and [`ffmpeg`](https://tldr.ostera.io/ffmpeg) way more often than the manpages.


## 查找文件

One of the most common repetitive tasks that every programmer faces is finding files or directories.
All UNIX-like systems come packaged with [`find`](http://man7.org/linux/man-pages/man1/find.1.html), a great shell tool to find files. `find` will recursively search for files matching some criteria. Some examples:

```bash
# Find all directories named src
find . -name src -type d
# Find all python files that have a folder named test in their path
find . -path '**/test/**/*.py' -type f
# Find all files modified in the last day
find . -mtime -1
# Find all zip files with size in range 500k to 10M
find . -size +500k -size -10M -name '*.tar.gz'
```
Beyond listing files, find can also perform actions over files that match your query.
This property can be incredibly helpful to simplify what could be fairly monotonous tasks.
```bash
# Delete all files with .tmp extension
find . -name '*.tmp' -exec rm {} \;
# Find all PNG files and convert them to JPG
find . -name '*.png' -exec convert {} {.}.jpg \;
```

Despite `find`'s ubiquitousness, its syntax can sometimes be tricky to remember.
For instance, to simply find files that match some pattern `PATTERN` you have to execute `find -name '*PATTERN*'` (or `-iname` if you want the pattern matching to be case insensitive).
You could start building aliases for those scenarios but as part of the shell philosophy is good to explore using alternatives.
Remember, one of the best properties of the shell is that you are just calling programs so you can find (or even write yourself) replacements for some.
For instance, [`fd`](https://github.com/sharkdp/fd) is a simple, fast and user-friendly alternative to `find`.
It offers some nice defaults like colorized output, default regex matching, Unicode support and it has in what my opinion is a more intuitive syntax.
The syntax to find a pattern `PATTERN` is `fd PATTERN`.

Most would agree that `find` and `fd` are good but some of you might be wondering about the efficiency of looking for files every time versus compiling some sort of index or database for quickly searching.
That is what [`locate`](http://man7.org/linux/man-pages/man1/locate.1.html) is for.
`locate` uses a database that is updated using [`updatedb`](http://man7.org/linux/man-pages/man1/updatedb.1.html).
In most systems `updatedb` is updated daily via [`cron`](http://man7.org/linux/man-pages/man8/cron.8.html).
Therefore one trade-off between the two is speed vs freshness.
Moreover `find` and similar tools can also find files using attributes such as file size, modification time or file permissions while `locate` just uses the name.
A more in depth comparison can be found [here](https://unix.stackexchange.com/questions/60205/locate-vs-find-usage-pros-and-cons-of-each-other).

## 查找代码

Finding files is useful but quite often you are after what is in the file.
A common scenario is wanting to search for all files that contain some pattern, along with where in those files said pattern occurs.
To achieve this, most UNIX-like systems provide [`grep`](http://man7.org/linux/man-pages/man1/grep.1.html), a generic tool for matching patterns from the input text.
It is an incredibly valuable shell tool and we will cover it more in detail during the data wrangling lecture.

`grep` has many flags that make it a very versatile tool.
Some I frequently use are `-C` for getting **C**ontext around the matching line and `-v` for in**v**erting the match, i.e. print all lines that do **not** match the pattern. For example, `grep -C 5` will print 5 lines before and after the match.
When it comes to quickly parsing through many files, you want to use `-R` since it will **R**ecursively go into directories and look for text files for the matching string.

But `grep -R` can be improved in many ways, such as ignoring `.git` folders, using multi CPU support, &c.
So there has been no shortage of alternatives developed, including [ack](https://beyondgrep.com/), [ag](https://github.com/ggreer/the_silver_searcher) and [rg](https://github.com/BurntSushi/ripgrep).
All of them are fantastic but pretty much cover the same need.
For now I am sticking with ripgrep (`rg`) given how fast and intuitive it is. Some examples:
```bash
# Find all python files where I used the requests library
rg -t py 'import requests'
# Find all files (including hidden files) without a shebang line
rg -u --files-without-match "^#!"
# Find all matches of foo and print the following 5 lines
rg foo -A 5
# Print statistics of matches (# of matched lines and files )
rg --stats PATTERN
```

Note that as with `find`/`fd`, it is important that you know that these problems can be quickly solved using one of these tools, while the specific tools you use are not as important.

## 查找 shell 命令

So far we have seen how to find files and code, but as you start spending more time in the shell you may want to find specific commands you typed at some point.
The first thing to know is that the typing up arrow will give you back your last command and if you keep pressing it you will slowly go through your shell history.

The `history` command will let you access your shell history programmatically.
It will print your shell history to the standard output.
If we want to search there we can pipe that output to `grep` and search for patterns.
`history | grep find` will print commands with the substring "find".

In most shells you can make use of `Ctrl+R` to perform backwards search through your history.
After pressing `Ctrl+R` you can type a substring you want to match for commands in your history.
As you keep pressing it you will cycle through the matches in your history.
This can also be enabled with the UP/DOWN arrows in [zsh](https://github.com/zsh-users/zsh-history-substring-search).
A nice addition on top of `Ctrl+R` comes with using [fzf](https://github.com/junegunn/fzf/wiki/Configuring-shell-key-bindings#ctrl-r) bindings.
`fzf` is a general purpose fuzzy finder that can be used with many commands.
Here is used to fuzzily match through your history and present results in a convenient and visually pleasing manner.

Another cool history-related trick I really enjoy is **history-based autosuggestions**.
First introduced by the [fish](https://fishshell.com/) shell, this feature dynamically autocompletes your current shell command with the most recent command that you typed that shares a common prefix with it.
It can be enabled in [zsh](https://github.com/zsh-users/zsh-autosuggestions) and it is a great quality of life trick for your shell.

Lastly, a thing to have in mind is that if you start a command with a leading space it won't be added to your shell history.
This comes in handy when you are typing commands with passwords or other bits of sensitive information.
If you make the mistake of not adding the leading space you can always manually remove the entry by editing your `.bash_history` or `.zhistory`.

## 文件夹导航 

So far we have assumed that you already are where you need to be to perform these actions, but how do you go about quickly navigating directories?
There are many simple ways that you could do this, such as writing shell aliases, creating symlinks with [ln -s](http://man7.org/linux/man-pages/man1/ln.1.html) but the truth is that developers have figured out quite clever and sophisticated solutions by now.

As with the theme of this course, you often want to optimize for the common case.
Finding frequent and/or recent files and directories can be done through tools like [`fasd`](https://github.com/clvv/fasd)
Fasd ranks files and directories by [_frecency_](https://developer.mozilla.org/en/The_Places_frecency_algorithm), that is, by both _frequency_ and _recency_.
The most straightforward use is _autojump_ which adds a `z` command that you can use to quickly `cd` using a substring of a _frecent_ directory. E.g. if you often go to `/home/user/files/cool_project` you can simply `z cool` to jump there.

More complex tools exist to quickly get an overview of a directory structure [`tree`](https://linux.die.net/man/1/tree), [`broot`](https://github.com/Canop/broot) or even full fledged file managers like [`nnn`](https://github.com/jarun/nnn) or [`ranger`](https://github.com/ranger/ranger)

# 课后练习

1. 阅读 [`man ls`](http://man7.org/linux/man-pages/man1/ls.1.html) ，然后使用`ls` 命令进行如下操作：

    - 所有文件（包括隐藏文件）
    - 文件打印以人类可以理解的格式输出 (例如，使用454M 而不是 454279954)
    - 文件以最近访问顺序排序
    - 以彩色文本显示输出结果

    典型输出如下：

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
2. 编写两个bash函数  `marco` 和 `polo` 执行下面的操作。
   每当你执行 `marco` 时，当前的工作目录应当以某种形式保存，当执行 `polo` 时，无论现在处在什么目录下，都应当 `cd` 回到当时执行 `marco` 的目录。
   为了方便debug，你可以把代码写在单独的文件 `marco.sh` 中，并通过 `source marco.sh`命令，（重新）加载函数。
    {% comment %}
    marco() {
        export MARCO=$(pwd)
    }
    polo() {
        cd "$MARCO"
    }
    {% endcomment %}

3. 假设您有一个命令，它很少出错。因此为了在出错时能够对其进行调试，需要花费大量的时间重现错误并捕获输出。
   编写一段bash脚本，运行如下的脚本直到它出错，将它的标准输出和标准错误流记录到文件，并在最后输出所有内容。
   加分项：报告脚本在失败前共运行了多少次。

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

4. 本节课我们讲解了 `find` 命令的 `-exec` 参数非常强大，它可以对我们查找对文件进行操作。但是，如果我们要对所有文件进行操作呢？例如创建一个zip压缩文件？我们已经知道，命令行可以从参数或标准输入接受输入。在用管道连接命令时，我们将标准输出和标准输入连接起来，但是有些命令，例如`tar` 则需要从参数接受输入。这里我们可以使用[`xargs`](http://man7.org/linux/man-pages/man1/xargs.1.html) 命令，它可以使用标准输入中的内容作为参数。
   例如 `ls | xargs rm` 会删除当前目录中的所有文件。

    您的任务是编写一个命令，它可以递归地查找文件夹中所有的HTML文件，并将它们压缩成zip文件。注意，即使文件名中包含空格，您的命令也应该能够正确执行（提示：查看 `xargs`的参数`-d`） 

    {% comment %}
    find . -type f -name "*.html" | xargs -d '\n'  tar -cvzf archive.tar.gz
    {% endcomment %}

5. (进阶) 编写一个命令或脚本递归的查找文件夹中最近使用的文件。更通用的做法，你可以按照最近的使用时间列出文件吗？
