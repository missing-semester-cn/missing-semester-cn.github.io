---
layout: lecture
title: "Command-line Environment"
description: >
  Learn how command-line programs work, including input/output streams, environment variables, and remote machines with SSH.
thumbnail: /static/assets/thumbnails/2026/lec2.png
date: 2026-01-13
ready: true
video:
  aspect: 56.25
  id: ccBGsPedE9Q
---

As we covered in the previous lecture, most shells are not a mere launcher to start up other programs,
but in practice they provide an entire programming language full of common patterns and abstractions.
However, unlike the majority of programming languages, in shell scripting everything is designed around running programs and getting them to communicate with each other simply and efficiently.

In particular, shell scripting is tightly bound by _conventions_. For a command line interface (CLI) program to play nicely within the broader shell environment there are some common patterns that it needs to follow.
We will now cover many of the concepts required to understand how command line programs work as well as ubiquitous conventions on how to use and configure them.

# The Command Line Interface

Writing a function in most programming languages looks something like:

```
def add(x: int, y: int) -> int:
    return x + y
```

Here we can explicitly see the inputs and the outputs of the program.
In contrast, shell scripts can look quite different at first glance.

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

To properly understand what is going in scripts like this one we first need to introduce a few concepts that appear often when shell programs communicate with each other or with the shell environment:

- Arguments
- Streams
- Environment variables
- Return codes
- Signals

## Arguments

Shell programs receive a list of arguments when they are executed.
Arguments are plain strings in shell, and it is up to the program how to interpret them.
For instance when we do `ls -l folder/`, we are executing the program `/bin/ls` with arguments `['-l', 'folder/']`.

From within a shell script we access these via special shell syntax.
To access the first argument we access the variable `$1`, second argument `$2` and so on and so forth until `$9`. To access all arguments as a list we use `$@` and to retrieve the number of arguments `$#`. Additionally we can also access the name of the program with `$0`.

For most programs the arguments will consist of a mixture of _flags_ and regular strings.
Flags can be identified because they are preceded by a dash (`-`) or double-dash (`--`).
Flags are usually optional and their role is to modify the behavior of the program.
For example `ls -l` changes how `ls` formats its output.

You will see double dash flags with long names like `--all`, and single dash flags like `-a`, which are most often followed by a single letter.
The same option might be specified in both formats, `ls -a` and `ls --all` are equivalent.
Single dash flags are often grouped, so `ls -l -a` and `ls -la` are also equivalent.
The order of flags usually doesn't matter either, `ls -la` and `ls -al` produce the same result.
Some flags are quite prevalent and as you get more familiar with the shell environment you'll intuitively reach for them, for example (`--help`, `--verbose`, `--version`).

> Flags are a first good example of shell conventions. The shell language does not require that our program uses `-` or `--` in this particular way.
Nothing prevents us from writing a program with syntax `myprogram +myoption myfile`, but it would lead to confusion since the expectation is that we use dashes.
> In practice, most programming languages provide CLI flag parsing libraries (e.g. `argparse` in python to parse arguments with the dash syntax).

Another common convention in CLI programs is for programs to accept a variable number of arguments of the same type. When given arguments in this way the command performs the same operation on each one of them.

```shell
mkdir src
mkdir docs
# is equivalent to
mkdir src docs
```

This syntax sugar might seem unnecessary at first, but it becomes really powerful when combined with _globbing_.
Globbing or globs are special patterns that the shell will expand before calling the program.

Say we wanted to delete all .py files in the current folder nonrecursively. From what we learned in the previous lecture we could achieve this by running

```shell
for file in $(ls | grep -P '\.py$'); do
    rm "$file"
done
```

But we can replace that with just `rm *.py`!

When we type `rm *.py` into the terminal, the shell will not call the `/bin/rm` program with arguments `['*.py']`.
Instead, the shell will search for files in the current folder matching the pattern `*.py` where `*` can match any string of zero or more characters of any type.
So if our folder has `main.py` and `utils.py` then the `rm` program will receive arguments `['main.py', 'utils.py']`.

The most common globs you will find are wildcards `*` (zero or more of anything), `?` (exactly one of anything) and curly braces.
Curly braces `{}` expand a comma-separated list of patterns into multiple arguments.

In practice, globs are best understood with motivating examples.

```shell
touch folder/{a,b,c}.py
# Will expand to
touch folder/a.py folder/b.py folder/c.py

convert image.{png,jpg}
# Will expand to
convert image.png image.jpg

cp /path/to/project/{setup,build,deploy}.sh /newpath
# Will expand to
cp /path/to/project/setup.sh /path/to/project/build.sh /path/to/project/deploy.sh /newpath

# Globbing techniques can also be combined
mv *{.py,.sh} folder
# Will move all *.py and *.sh files
```

> Some shells (e.g. zsh) support even more advanced forms of globbing such as `**` that will expand to include recursive paths. So `rm **/*.py` will delete all .py files recursively.


## Streams

Whenever we execute a program pipeline like

```shell
cat myfile | grep -P '\d+' | uniq -c
```

we see that the `grep` program is communicating with both the `cat` and `uniq` programs.

An important observation here is that all three programs are executing at once.
Namely, the shell is not first calling cat, then grep, and then uniq.
Instead, all three programs are being spawned and the shell is connecting the output of cat to the input of grep and the output of grep to the input of uniq.
When using the pipe operator `|`, the shell operates on streams of data that flow from one program to the next in the chain.

We can demonstrate this concurrency, all commands in a pipeline start immediately:

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

We can see that all processes but `cat` are running right away. The shell spawns all processes and connects their streams before any of them finish. `cat` will only get started once sleep finishes, and the output of `cat` will be sent to grep and so on and so forth.

Every program has an input stream, labeled stdin (for standard input). When piping, stdin is connected automatically. Within a script, many programs accept `-` as a filename to mean "read from stdin":

```shell
# These are equivalent when data comes from a pipe
echo "hello" | grep "hello"
echo "hello" | grep "hello" -
```

Similarly, every program has two output streams: stdout and stderr.
The standard output is the one most commonly encountered and it is the one that is used for piping the output of the program to the next command in the pipeline.
The standard error is an alternative stream that is intended for programs to report warnings and other types of issues, without that output getting parsed by the next command in the chain.

```console
$ ls /nonexistent
ls: cannot access '/nonexistent': No such file or directory
$ ls /nonexistent | grep "pattern"
ls: cannot access '/nonexistent': No such file or directory
# The error message still appears because stderr is not piped
$ ls /nonexistent 2>/dev/null
# No output - stderr was redirected to /dev/null
```

The shell provides syntax for redirecting these streams. Here are some illustrative examples.

```shell
# Redirect stdout to a file (overwrite)
echo "hello" > output.txt

# Redirect stdout to a file (append)
echo "world" >> output.txt

# Redirect stderr to a file
ls foobar 2> errors.txt

# Redirect both stdout and stderr to the same file
ls foobar &> all_output.txt

# Redirect stdin from a file
grep "pattern" < input.txt

# Discard output by redirecting to /dev/null
cmd > /dev/null 2>&1
```

Another powerful tool that exemplifies the Unix philosophy is [`fzf`](https://github.com/junegunn/fzf), a fuzzy finder. It reads lines from stdin and provides an interactive interface to filter and select:

```console
$ ls | fzf
$ cat ~/.bash_history | fzf
```

`fzf` can be integrated with many shell operations. We'll see more uses of it when we discuss shell customization.


## Environment variables

To assign variables in bash we use the syntax `foo=bar`, and then access the value of the variable with the `$foo` syntax.
Note that `foo = bar` is invalid syntax as the shell will parse it as calling the program `foo` with arguments `['=', 'bar']`.
In shell scripting the role of the space character is to perform argument splitting.
This behavior can be confusing and tricky to get used to, so keep it in mind.

Shell variables do not have types, they are all strings.
Note that when writing string expressions in the shell single and double quotes are not interchangeable.
Strings delimited with `'` are literal strings and will not expand variables, perform command substitution, or process escape sequences, whereas `"` delimited strings will.

```shell
foo=bar
echo "$foo"
# prints bar
echo '$foo'
# prints $foo
```

To capture the output of a command into a variable we use _command substitution_.
When we execute
```shell
files=$(ls)
echo "$files" | grep README
echo "$files" | grep ".py"
```
the output (concretely the stdout) of ls is placed into the variable `$files` which we can access later.
The content of the `$files` variable does include the newlines from the ls output, which is how programs like `grep` know to operate on each item independently.

A lesser known similar feature is _process substitution_, `<( CMD )` will execute `CMD` and place the output in a temporary file and substitute the `<()` with that file's name.
This is useful when commands expect values to be passed by file instead of by STDIN.
For example, `diff <(ls src) <(ls docs)` will show differences between files in dirs `src` and `docs`.

Whenever a shell program calls another program it passes along a set of variables that are often referred to as _environment variables_.
From within a shell we can find the current environment variables by running `printenv`.
To pass an environment variable explicitly we can prepend a command with a variable assignment

> Environment variables are conventionally written in ALL_CAPS (e.g., `HOME`, `PATH`, `DEBUG`). This is a convention, not a technical requirement, but following it helps distinguish environment variables from local shell variables which are typically lowercase.

```shell
TZ=Asia/Tokyo date  # prints the current time in Tokyo
echo $TZ  # this will be empty, since TZ was only set for the child command
```

Alternatively, we can use the `export` built-in function that will modify our current environment and thus all child processes will inherit the variable:

```shell
export DEBUG=1
# All programs from this point onwards will have DEBUG=1 in their environment
bash -c 'echo $DEBUG'
# prints 1
```

To delete a variable use the `unset` built-in command, e.g. `unset DEBUG`.

> Environment variables are another shell convention. They can be used to modify the behavior of many programs implicitly rather than explicitly. For example, the shell sets the `$HOME` environment variable with the path of the home folder of the current user. Then programs can access this variable to get this information instead of requiring an explicit `--home /home/alice`. Another common example is `$TZ`, which many programs use to format dates and times according to the specified timezone.

## Return codes

As we saw earlier, the main output of a shell program is conveyed through the stdout/stderr streams and filesystem side effects.

By default a shell script will return exit code zero.
The convention is that zero means everything went well whereas nonzero means some issues were encountered.
To return a nonzero exit code we have to use the `exit NUM` shell built-in.
We can access the return code of the last command that was run by accessing the special variable `$?`.

The shell has boolean operators `&&` and `||` for performing AND and OR operations respectively.
Unlike those encountered in regular programming languages, the ones in the shell operate on the return code of programs.
Both of these are [short-circuiting](https://en.wikipedia.org/wiki/Short-circuit_evaluation) operators.
This means that they can be used to conditionally run commands based on the success or failure of previous commands, where success is determined based on whether the return code is zero or not. Some examples:

```shell
# echo will only run if grep succeeds (finds a match)
grep -q "pattern" file.txt && echo "Pattern found"

# echo will only run if grep fails (no match)
grep -q "pattern" file.txt || echo "Pattern not found"

# true is a shell program that always succeeds
true && echo "This will always print"

# and false is a shell program that always fails
false || echo "This will always print"
```

The same principle applies to `if` and `while` statements, they both use return codes to make decisions:

```shell
# if uses the return code of the condition command (0 = true, nonzero = false)
if grep -q "pattern" file.txt; then
    echo "Found"
fi

# while loops continue as long as the command returns 0
while read line; do
    echo "$line"
done < file.txt
```

## Signals

In some cases you will need to interrupt a program while it is executing, for instance if a command is taking too long to complete.
The simplest way to interrupt a program is to press `Ctrl-C` and the command will probably stop.
But how does this actually work and why does it sometimes fail to stop the process?

```console
$ sleep 100
^C
$
```

> Note, here `^C` is how `Ctrl-C` is displayed when typed in the terminal.

Under the hood, what happened here is the following:

1. We pressed `Ctrl-C`
2. The shell identified the special combination of characters
3. The shell process sent a SIGINT signal to the `sleep` process
4. The signal interrupted the execution of the `sleep` process

Signals are a special communication mechanism.
When a process receives a signal it stops its execution, deals with the signal and potentially changes the flow of execution based on the information that the signal delivered. For this reason, signals are _software interrupts_.


In our case, when typing `Ctrl-C` this prompts the shell to deliver a `SIGINT` signal to the process.
Here's a minimal example of a Python program that captures `SIGINT` and ignores it, no longer stopping. To kill this program we can now use the `SIGQUIT` signal instead, by typing `Ctrl-\`.

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

Here's what happens if we send `SIGINT` twice to this program, followed by `SIGQUIT`. Note that `^` is how `Ctrl` is displayed when typed in the terminal.

```console
$ python sigint.py
24^C
I got a SIGINT, but I am not stopping
26^C
I got a SIGINT, but I am not stopping
30^\[1]    39913 quit       python sigint.py
```

While `SIGINT` and `SIGQUIT` are both usually associated with terminal related requests, a more generic signal for asking a process to exit gracefully is the `SIGTERM` signal.
To send this signal we can use the [`kill`](https://www.man7.org/linux/man-pages/man1/kill.1.html) command, with the syntax `kill -TERM <PID>`.

Signals can do other things beyond killing a process. For instance, `SIGSTOP` pauses a process. In the terminal, typing `Ctrl-Z` will prompt the shell to send a `SIGTSTP` signal, short for Terminal Stop (i.e. the terminal's version of `SIGSTOP`).

We can then continue the paused job in the foreground or in the background using [`fg`](https://www.man7.org/linux/man-pages/man1/fg.1p.html) or [`bg`](https://man7.org/linux/man-pages/man1/bg.1p.html), respectively.

The [`jobs`](https://www.man7.org/linux/man-pages/man1/jobs.1p.html) command lists the unfinished jobs associated with the current terminal session.
You can refer to those jobs using their pid (you can use [`pgrep`](https://www.man7.org/linux/man-pages/man1/pgrep.1.html) to find that out).
More intuitively, you can also refer to a process using the percent symbol followed by its job number (displayed by `jobs`). To refer to the last backgrounded job you can use the `$!` special parameter.

One more thing to know is that the `&` suffix in a command will run the command in the background, giving you the prompt back, although it will still use the shell's STDOUT which can be annoying (use shell redirections in that case). Equivalently, to background an already running program you can do `Ctrl-Z` followed by `bg`.


Note that backgrounded processes are still children processes of your terminal and will die if you close the terminal (this will send yet another signal, `SIGHUP`).
To prevent that from happening you can run the program with [`nohup`](https://www.man7.org/linux/man-pages/man1/nohup.1.html) (a wrapper to ignore `SIGHUP`), or use `disown` if the process has already been started.
Alternatively, you can use a terminal multiplexer as we will see in the next section.

Below is a sample session to showcase some of these concepts.

```
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

$ kill -SIGHUP %2   # nohup protects from SIGHUP

$ jobs
[2]  + running    nohup sleep 2000

$ kill %2
[2]  + 18745 terminated  nohup sleep 2000
```

A special signal is `SIGKILL` since it cannot be captured by the process and it will always terminate it immediately. However, it can have bad side effects such as leaving orphaned children processes.

You can learn more about these and other signals [here](https://en.wikipedia.org/wiki/Signal_(IPC)) or typing [`man signal`](https://www.man7.org/linux/man-pages/man7/signal.7.html) or `kill -l`.

Within shell scripts, you can use the `trap` built-in to execute commands when signals are received. This is useful for cleanup operations:

```shell
#!/usr/bin/env bash
cleanup() {
    echo "Cleaning up temporary files..."
    rm -f /tmp/mytemp.*
}
trap cleanup EXIT  # Run cleanup when script exits
trap cleanup SIGINT SIGTERM  # Also on Ctrl-C or kill
```
{% comment %}
### Users, Files and Permissions

Lastly, another way programs have to indirectly communicate with each other is using files.
For a program to be able to correctly read/write/delete files and folders, the file permissions must allow the operation.

Listing a specific file will give the following output

```console
$ ls -l notes.txt
-rw-r--r--  1 alice  users  12693 Jan 11 23:05 notes.txt
```

Here `ls` is listing what is the owner of the file, user `alice`, and the group `users`. Then the `rw-r--r--` are a shorthand notation for the permissions.
In this case, the file `notes.txt` has read/write permissions for the user alice `rw-`, and only read permissions for the group and the rest of users in the file system.

```console
$ ./script.sh
# permission denied
$ chmod +x script.sh
$ ls -l script.sh
-rwxr-xr-x  1 alice  users  3125 Jan 11 23:07 script.sh
$ ./script.sh
```

For a script to be executable, the executable rights must be set, hence why we had to use the `chmod` (change mode) program.
`chmod` syntax, while intuitive, is not obvious when first encountered.
If you, like me, prefer to learn by example, this is a good usecase of the `tldr` tool (note that you need to install it first).

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

Run `tldr chmod` to see more examples, including recursive operations and group permissions.

> Your shell might show you something like `command not found: tldr`. That is because it is a more modern tool and it is not pre-installed in most systems. A good reference for how to install tools is the [https://command-not-found.com](https://command-not-found.com) website. It contains instructions for a huge collection of CLI tools for popular OS distributions.

Each program is run as a specific user in the system. We can use the `whoami` command to find our user name and `id -u` to find our UID (user id) which is the integer value that the OS associates with the user.

When running `sudo command`, the `command` is run as the root user which can bypass most permissions in the system.
Try running `sudo whoami` and `sudo id -u` to see how the output changes (you might be prompted for your password).
To change the owner of a file or folder, we use the `chown` command.

You can learn more about UNIX file permissions [here](https://en.wikipedia.org/wiki/File-system_permissions#Traditional_Unix_permissions)

So far we've focused on your local machine, but many of these skills become even more valuable when working with remote servers.

{% endcomment %}

# Remote Machines

It has become more and more common for programmers to work with remote servers in their everyday work. The most common tool for the job here is SSH (Secure Shell) which will help us connect to a remote server and provide the now familiar shell interface. We connect to a server with a command like:

```bash
ssh alice@server.mit.edu
```

Here we are trying to ssh as user `alice` in server `server.mit.edu`.

An often overlooked feature of `ssh` is the ability to run commands non-interactively. `ssh` correctly handles sending the stdin and receiving the stdout of the command, so we can combine it with other commands

```shell
# here ls runs in the remote, and wc runs locally
ssh alice@server ls | wc -l

# here both ls and wc run in the server
ssh alice@server 'ls | wc -l'

```

> Try installing [Mosh](https://mosh.org/) as a SSH replacement that can handle disconnections, entering/exiting sleep, changing networks and dealing with high latency links.

For `ssh` to let us run commands in the remote server we need to prove that we are authorized to do so.
We can do this via passwords or ssh keys.
Key-based authentication utilizes public-key cryptography to prove to the server that the client owns the secret private key without revealing the key.
Key based authentication is both more convenient and more secure, so you should prefer it.
Note that the private key (often `~/.ssh/id_rsa` and more recently `~/.ssh/id_ed25519`) is effectively your password, so treat it like so and never share its contents.

To generate a pair you can run [`ssh-keygen`](https://www.man7.org/linux/man-pages/man1/ssh-keygen.1.html).
```bash
ssh-keygen -a 100 -t ed25519 -f ~/.ssh/id_ed25519
```

If you have ever configured pushing to GitHub using SSH keys, then you have probably done the steps outlined [here](https://help.github.com/articles/connecting-to-github-with-ssh/) and have a valid key pair already. To check if you have a passphrase and validate it you can run `ssh-keygen -y -f /path/to/key`.

At the server side `ssh` will look into `.ssh/authorized_keys` to determine which clients it should let in. To copy a public key over you can use:

```bash
cat .ssh/id_ed25519.pub | ssh alice@remote 'cat >> ~/.ssh/authorized_keys'

# or more simply (if ssh-copy-id is available)

ssh-copy-id -i .ssh/id_ed25519 alice@remote
```

Beyond running commands, the connection that ssh establishes can be used to transfer files from and to the server securely. [`scp`](https://www.man7.org/linux/man-pages/man1/scp.1.html) is the most traditional tool and the syntax is `scp path/to/local_file remote_host:path/to/remote_file`. [`rsync`](https://www.man7.org/linux/man-pages/man1/rsync.1.html) improves upon `scp` by detecting identical files in local and remote, and preventing copying them again. It also provides more fine grained control over symlinks, permissions and has extra features like the `--partial` flag that can resume from a previously interrupted copy. `rsync` has a similar syntax to `scp`.

SSH client configuration is located at `~/.ssh/config` and it lets us declare hosts and set default settings for them. This configuration file is not just read by `ssh` but also other programs like `scp`, `rsync`, `mosh`, &c.

```bash
Host vm
    User alice
    HostName 172.16.174.141
    Port 2222
    IdentityFile ~/.ssh/id_ed25519

# Configs can also take wildcards
Host *.mit.edu
    User alice
```




# Terminal Multiplexers

When using the command line interface you will often want to run more than one thing at once.
For instance, you might want to run your editor and your program side by side.
Although this can be achieved by opening new terminal windows, using a terminal multiplexer is a more versatile solution.

Terminal multiplexers like [`tmux`](https://www.man7.org/linux/man-pages/man1/tmux.1.html) allow you to multiplex terminal windows using panes and tabs so you can interact with multiple shell sessions in an efficient manner.
Moreover, terminal multiplexers let you detach a current terminal session and reattach at some point later in time.
Because of this, terminal multiplexers are really convenient when working with remote machines, as it avoids the need to use `nohup` and similar tricks.

The most popular terminal multiplexer these days is [`tmux`](https://www.man7.org/linux/man-pages/man1/tmux.1.html). `tmux` is highly configurable and by using the associated keybindings you can create multiple tabs and panes and quickly navigate through them.

`tmux` expects you to know its keybindings, and they all have the form `<C-b> x` where that means (1) press `Ctrl+b`, (2) release `Ctrl+b`, and then (3) press `x`. `tmux` has the following hierarchy of objects:
- **Sessions** - a session is an independent workspace with one or more windows
    + `tmux` starts a new session.
    + `tmux new -s NAME` starts it with that name.
    + `tmux ls` lists the current sessions
    + Within `tmux` typing `<C-b> d`  detaches the current session
    + `tmux a` attaches the last session. You can use `-t` flag to specify which

- **Windows** - Equivalent to tabs in editors or browsers, they are visually separate parts of the same session
    + `<C-b> c` Creates a new window. To close it you can just terminate the shells doing `<C-d>`
    + `<C-b> N` Go to the _N_ th window. Note they are numbered
    + `<C-b> p` Goes to the previous window
    + `<C-b> n` Goes to the next window
    + `<C-b> ,` Rename the current window
    + `<C-b> w` List current windows

- **Panes** - Like vim splits, panes let you have multiple shells in the same visual display.
    + `<C-b> "` Split the current pane horizontally
    + `<C-b> %` Split the current pane vertically
    + `<C-b> <direction>` Move to the pane in the specified _direction_. Direction here means arrow keys.
    + `<C-b> z` Toggle zoom for the current pane
    + `<C-b> [` Start scrollback. You can then press `<space>` to start a selection and `<enter>` to copy that selection.
    + `<C-b> <space>` Cycle through pane arrangements.

> To learn more about tmux, consider reading [this](https://www.hamvocke.com/blog/a-quick-and-easy-guide-to-tmux/) quick tutorial and [this](https://linuxcommand.org/lc3_adv_termmux.php) more detailed explanation.

With tmux and SSH in your toolkit, you'll want to make your environment feel like home on any machine. That's where shell customization comes in.

# Customizing the Shell

A wide array of command line programs are configured using plain-text files known as _dotfiles_
(because the file names begin with a `.`, e.g. `~/.vimrc`, so that they are
hidden in the directory listing `ls` by default).

> Dotfiles are yet another shell convention. The dot in the front is to "hide" them when listing (yes, another convention).

Shells are one example of programs configured with such files. On startup, your shell will read many files to load its configuration.
Depending on the shell and whether you are starting a login and/or interactive session, the entire process can be quite complex.
[Here](https://blog.flowblok.id.au/2013-02/shell-startup-scripts.html) is an excellent resource on the topic.

For `bash`, editing your `.bashrc` or `.bash_profile` will work in most systems.
Some other examples of tools that can be configured through dotfiles are:

- `bash` - `~/.bashrc`, `~/.bash_profile`
- `git` - `~/.gitconfig`
- `vim` - `~/.vimrc` and the `~/.vim` folder
- `ssh` - `~/.ssh/config`
- `tmux` - `~/.tmux.conf`

A common configuration change is adding new locations for the shell to find programs. You will encounter this pattern when installing software:

```shell
export PATH="$PATH:path/to/append"
```

Here, we are telling the shell to set the value of the $PATH variable to its current value plus a new path, and have all children processes inherit this new value for PATH.
This will allow children processes to find programs located under `path/to/append`.


Customizing your shell often means installing new command-line tools. Package managers make this easy. They handle downloading, installing, and updating software. Different operating systems have different package managers: macOS uses [Homebrew](https://brew.sh/), Ubuntu/Debian use `apt`, Fedora uses `dnf`, and Arch uses `pacman`. We'll cover package managers in more depth in the shipping code lecture.

Here's how to install two useful tools using Homebrew on macOS:

```shell
# ripgrep: a faster grep with better defaults
brew install ripgrep

# fd: a faster, user-friendly find
brew install fd
```

With these installed, you can use `rg` instead of `grep` and `fd` instead of `find`.

> **Warning about `curl | bash`**: You'll often see installation instructions like `curl -fsSL https://example.com/install.sh | bash`. This pattern downloads a script and immediately executes it, which is convenient but risky; you're running code you haven't inspected. A safer approach is to download first, review, then execute:
> ```shell
> curl -fsSL https://example.com/install.sh -o install.sh
> less install.sh  # review the script
> bash install.sh
> ```
> Some installers use a slightly safer variant: `/bin/bash -c "$(curl -fsSL https://url)"` which at least ensures bash interprets the script rather than your current shell.

When you try to run a command that isn't installed, your shell will show `command not found`. The website [command-not-found.com](https://command-not-found.com) is a helpful resource you can use to search for any command to find out how to install it across different package managers and distributions.

Another useful tool is [`tldr`](https://tldr.sh/), which provides simplified, example-focused man pages. Instead of reading through lengthy documentation, you can quickly see common usage patterns:

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

Sometimes you don't need a whole new program, but rather just a shortcut for an existing command with specific flags. That's where aliases come in.

We can also create our own command aliases using the `alias` shell built-in.
A shell alias is a short form for another command that your shell will replace automatically before evaluating the expression.
For instance, an alias in bash has the following structure:

```bash
alias alias_name="command_to_alias arg1 arg2"
```

> Note that there is no space around the equal sign `=`, because [`alias`](https://www.man7.org/linux/man-pages/man1/alias.1p.html) is a shell command that takes a single argument.

Aliases have many convenient features:

```bash
# Make shorthands for common flags
alias ll="ls -lh"

# Save a lot of typing for common commands
alias gs="git status"
alias gc="git commit"

# Save you from mistyping
alias sl=ls

# Overwrite existing commands for better defaults
alias mv="mv -i"           # -i prompts before overwrite
alias mkdir="mkdir -p"     # -p make parent dirs as needed
alias df="df -h"           # -h prints human readable format

# Alias can be composed
alias la="ls -A"
alias lla="la -l"

# To ignore an alias run it prepended with \
\ls
# Or disable an alias altogether with unalias
unalias la

# To get an alias definition just call it with alias
alias ll
# Will print ll='ls -lh'
```

Aliases have limitations: they cannot take arguments in the middle of a command. For more complex behavior, you should use shell functions instead.

Most shells support `Ctrl-R` for reverse history search. Type `Ctrl-R` and start typing to search through previous commands. Earlier we introduced `fzf` as a fuzzy finder; with fzf's shell integration configured, `Ctrl-R` becomes an interactive fuzzy search through your entire history, far more powerful than the default.

How should you organize your dotfiles? They should be in their own folder,
under version control, and **symlinked** into place using a script. This has
the benefits of:

- **Easy installation**: if you log in to a new machine, applying your
customizations will only take a minute.
- **Portability**: your tools will work the same way everywhere.
- **Synchronization**: you can update your dotfiles anywhere and keep them all
in sync.
- **Change tracking**: you're probably going to be maintaining your dotfiles
for your entire programming career, and version history is nice to have for
long-lived projects.

What should you put in your dotfiles?
You can learn about your tool's settings by reading online documentation or
[man pages](https://en.wikipedia.org/wiki/Man_page). Another great way is to
search the internet for blog posts about specific programs, where authors will
tell you about their preferred customizations. Yet another way to learn about
customizations is to look through other people's dotfiles: you can find tons of
[dotfiles
repositories](https://github.com/search?o=desc&q=dotfiles&s=stars&type=Repositories)
on GitHub --- see the most popular one
[here](https://github.com/mathiasbynens/dotfiles) (we advise you not to blindly
copy configurations though).
[Here](https://dotfiles.github.io/) is another good resource on the topic.

All of the class instructors have their dotfiles publicly accessible on GitHub: [Anish](https://github.com/anishathalye/dotfiles),
[Jon](https://github.com/jonhoo/configs),
[Jose](https://github.com/jjgo/dotfiles).

**Frameworks and plugins** can improve your shell as well. Some popular general frameworks are [prezto](https://github.com/sorin-ionescu/prezto) or [oh-my-zsh](https://ohmyz.sh/), and smaller plugins that focus on specific features:

- [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting) - colors valid/invalid commands as you type
- [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions) - suggests commands from history as you type
- [zsh-completions](https://github.com/zsh-users/zsh-completions) - additional completion definitions
- [zsh-history-substring-search](https://github.com/zsh-users/zsh-history-substring-search) - fish-like history search
- [powerlevel10k](https://github.com/romkatv/powerlevel10k) - fast, customizable prompt theme

Shells like [fish](https://fishshell.com/) include many of these features by default.

> You don't need a massive framework like oh-my-zsh to get these features. Installing individual plugins is often faster and gives you more control. Large frameworks can significantly slow down shell startup time, so consider installing only what you actually use.


# AI in the Shell

There are many ways to incorporate AI tooling in the shell. Here are a few examples at different levels of integration:

**Command generation**: Tools like [`simonw/llm`](https://github.com/simonw/llm) can help generate shell commands from natural language descriptions:

```console
$ llm cmd "find all python files modified in the last week"
find . -name "*.py" -mtime -7
```

**Pipeline integration**: LLMs can be integrated into shell pipelines to process and transform data. They're particularly useful when you need to extract information from inconsistent formats where regex would be painful:

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

Note how we use `"$INSTRUCTIONS"` (quoted) because the variable contains spaces, and `< users.txt` to redirect the file's content to stdin.

**AI shells**: Tools like [Claude Code](https://docs.anthropic.com/en/docs/claude-code) act as a meta-shell that accepts English commands and translates them into shell operations, file edits, and more complex multi-step tasks.

# Terminal Emulators

Along with customizing your shell, it is worth spending some time figuring out your choice of **terminal emulator** and its settings.
A terminal emulator is a GUI program that provides the text-based interface where your shell runs.
There are many terminal emulators out there.

Since you might be spending hundreds to thousands of hours in your terminal it pays off to look into its settings. Some of the aspects that you may want to modify in your terminal include:

- Font choice
- Color Scheme
- Keyboard shortcuts
- Tab/Pane support
- Scrollback configuration
- Performance (some newer terminals like [Alacritty](https://github.com/alacritty/alacritty) or [Ghostty](https://ghostty.org/) offer GPU acceleration).



# Exercises

## Arguments and Globs

1. You might see commands like `cmd --flag -- --notaflag`. The `--` is a special argument that tells the program to stop parsing flags. Everything after `--` is treated as a positional argument. Why might this be useful? Try running `touch -- -myfile` and then removing it without `--`.

1. Read [`man ls`](https://www.man7.org/linux/man-pages/man1/ls.1.html) and write an `ls` command that lists files in the following manner:
    - Includes all files, including hidden files
    - Sizes are listed in human readable format (e.g. 454M instead of 454279954)
    - Files are ordered by recency
    - Output is colorized

    A sample output would look like this:

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

1. Process substitution `<(command)` lets you use a command's output as if it were a file. Use `diff` with process substitution to compare the output of `printenv` and `export`. Why are they different? (Hint: try `diff <(printenv | sort) <(export | sort)`).

## Environment Variables

1. Write bash functions `marco` and `polo` that do the following: whenever you execute `marco` the current working directory should be saved in some manner, then when you execute `polo`, no matter what directory you are in, `polo` should `cd` you back to the directory where you executed `marco`. For ease of debugging you can write the code in a file `marco.sh` and (re)load the definitions to your shell by executing `source marco.sh`.

{% comment %}
marco() {
    export MARCO=$(pwd)
}

polo() {
    cd "$MARCO"
}
{% endcomment %}

## Return Codes

1. Say you have a command that fails rarely. In order to debug it you need to capture its output but it can be time consuming to get a failure run. Write a bash script that runs the following script until it fails and captures its standard output and error streams to files and prints everything at the end. Bonus points if you can also report how many runs it took for the script to fail.

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

## Signals and Job Control

1. Start a `sleep 10000` job in a terminal, background it with `Ctrl-Z` and continue its execution with `bg`. Now use [`pgrep`](https://www.man7.org/linux/man-pages/man1/pgrep.1.html) to find its pid and [`pkill`](https://man7.org/linux/man-pages/man1/pgrep.1.html) to kill it without ever typing the pid itself. (Hint: use the `-af` flags).

1. Say you don't want to start a process until another completes. How would you go about it? In this exercise, our limiting process will always be `sleep 60 &`. One way to achieve this is to use the [`wait`](https://www.man7.org/linux/man-pages/man1/wait.1p.html) command. Try launching the sleep command and having an `ls` wait until the background process finishes.

    However, this strategy will fail if we start in a different bash session, since `wait` only works for child processes. One feature we did not discuss in the notes is that the `kill` command's exit status will be zero on success and nonzero otherwise. `kill -0` does not send a signal but will give a nonzero exit status if the process does not exist. Write a bash function called `pidwait` that takes a pid and waits until the given process completes. You should use `sleep` to avoid wasting CPU unnecessarily.

## Files and Permissions

1. (Advanced) Write a command or script to recursively find the most recently modified file in a directory. More generally, can you list all files by recency?

## Terminal Multiplexers

1. Follow this `tmux` [tutorial](https://www.hamvocke.com/blog/a-quick-and-easy-guide-to-tmux/) and then learn how to do some basic customizations following [these steps](https://www.hamvocke.com/blog/a-guide-to-customizing-your-tmux-conf/).

## Aliases and Dotfiles

1. Create an alias `dc` that resolves to `cd` for when you type it wrong.

1. Run `history | awk '{$1="";print substr($0,2)}' | sort | uniq -c | sort -n | tail -n 10` to get your top 10 most used commands and consider writing shorter aliases for them. Note: this works for Bash; if you're using ZSH, use `history 1` instead of just `history`.

1. Create a folder for your dotfiles and set up version control.

1. Add a configuration for at least one program, e.g. your shell, with some customization (to start off, it can be something as simple as customizing your shell prompt by setting `$PS1`).

1. Set up a method to install your dotfiles quickly (and without manual effort) on a new machine. This can be as simple as a shell script that calls `ln -s` for each file, or you could use a [specialized utility](https://dotfiles.github.io/utilities/).

1. Test your installation script on a fresh virtual machine.

1. Migrate all of your current tool configurations to your dotfiles repository.

1. Publish your dotfiles on GitHub.

## Remote Machines (SSH)

Install a Linux virtual machine (or use an already existing one) for these exercises. If you are not familiar with virtual machines check out [this](https://hibbard.eu/install-ubuntu-virtual-box/) tutorial for installing one.

1. Go to `~/.ssh/` and check if you have a pair of SSH keys there. If not, generate them with `ssh-keygen -a 100 -t ed25519`. It is recommended that you use a password and use `ssh-agent`, more info [here](https://www.ssh.com/ssh/agent).

1. Edit `.ssh/config` to have an entry as follows:

    ```bash
    Host vm
        User username_goes_here
        HostName ip_goes_here
        IdentityFile ~/.ssh/id_ed25519
        LocalForward 9999 localhost:8888
    ```

1. Use `ssh-copy-id vm` to copy your ssh key to the server.

1. Start a webserver in your VM by executing `python -m http.server 8888`. Access the VM webserver by navigating to `http://localhost:9999` in your machine.

1. Edit your SSH server config by doing `sudo vim /etc/ssh/sshd_config` and disable password authentication by editing the value of `PasswordAuthentication`. Disable root login by editing the value of `PermitRootLogin`. Restart the `ssh` service with `sudo service sshd restart`. Try sshing in again.

1. (Challenge) Install [`mosh`](https://mosh.org/) in the VM and establish a connection. Then disconnect the network adapter of the server/VM. Can mosh properly recover from it?

1. (Challenge) Look into what the `-N` and `-f` flags do in `ssh` and figure out a command to achieve background port forwarding.
