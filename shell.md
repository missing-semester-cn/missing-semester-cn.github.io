---
layout: page
title: "Shell and Scripting"
---

The shell is an efficient, textual interface to your computer.

The shell prompt: what greets you when you open a terminal.
Lets you run programs and commands; common ones are:

 - `cd` to change directory
 - `ls` to list files and directories
 - `mv` and `cp` to move and copy files

But the shell lets you do _so_ much more; you can invoke any program on
your computer, and command-line tools exist for doing pretty much
anything you may want to do. And they're often more efficient than their
graphical counterparts. We'll go through a bunch of those in this class.

The shell provides an interactive programming language ("scripting").
There are many shells:

 - You've probably used `sh` or `bash`.
 - Also shells that match languages: `csh`.
 - Or "better" shells: `fish`, `zsh`, `ksh`.

In this class we'll focus on the ubiquitous `sh` and `bash`, but feel
free to play around with others. I like `fish`.

Shell programming is a *very* useful tool in your toolbox.
Can either write programs directly at the prompt, or into a file.
`#!/bin/sh` + `chmod +x` to make shell executable.

## Working with the shell

Run a command a bunch of times:

```shell
for i in $(seq 1 5); do echo hello; done
```

There's a lot to unpack:

 - `for x in list; do BODY; done`
   - `;` terminates a command -- equivalent to newline
   - split `list`, assign each to `x`, and run body
   - splitting is "whitespace splitting", which we'll get back to
   - no curly braces in shell, so `do` + `done`
 - `$(seq 1 10)`
   - run the program `seq` with arguments `1` and `5`
   - substitute entire `$()` with the output of that program
   - equivalent to
     ```shell
     for i in 1 2 3 4 5
     ```
 - `echo hello`
   - everything in a shell script is a command
   - in this case, run the `echo` command, which prints its arguments
     with the argument `hello`.
   - all commands are searched for in `$PATH` (colon-separated)

We have variables:
```shell
for f in $(ls); do echo $f; done
```

Will print each file name in the current directory.
Can also set variables using `=` (no space!):

```shell
foo=bar
echo $foo
```

There are a bunch of "special" variables too:

 - `$1` to `$9`: arguments to the script
 - `$0` name of the script itself
 - `$#` number of arguments
 - `$$` process ID of current shell

To only print directories

```shell
for f in $(ls); do if test -d $f; then echo dir $f; fi; done
```

More to unpack here:

 - `if CONDITION; then BODY; fi`
   - `CONDITION` is a command; if it returns with exit status 0
     (success), then `BODY` is run.
   - can also hook in an `else` or `elif`
   - again, no curly braces, so `then` + `fi`
 - `test` is another program that provides various checks and
   comparisons, and exits with 0 if they're true (`$?`)
   - `man COMMAND` is your friend: `man test`
   - can also be invoked with `[` + `]`: `[ -d $f ]`
     - take a look at `man test` and `which "["`

But wait! This is wrong! What if a file is called "My Documents"?

 - `for f in $(ls)` expands to `for f in My Documents`
 - first do the test on `My`, then on `Documents`
 - not what we wanted!
 - biggest source of bugs in shell scripts

## Argument splitting

Bash splits arguments by whitespace; not always what you want!

 - need to use quoting to handle spaces in arguments
   `for f in "My Documents"` would work correctly
 - same problem somewhere else -- do you see where?
   `test -d $f`: if `$f` contains whitespace, `test` will error!
 - `echo` happens to be okay, because split + join by space
   but what if a filename contains a newline?! turns into space!
 - quote all use of variables that you don't want split
 - but how do we fix our script above?
   what does `for f in "$(ls)"` do do you think?

Globbing is the answer!

 - bash knows how to look for files using patterns:
   - `*` any string of characters
   - `?` any single character
   - `{a,b,c}` any of these characters
 - `for f in *`: all files in this directory
 - when globbing, each matching file becomes its own argument
   - still need to make sure to quote when _using_: `test -d "$f"`
 - can make advanced patterns:
   - `for f in a*`: all files starting with `a` in the current directory
   - `for f in foo/*.txt`: all `.txt` files in `foo`
   - `for f in foo/*/p??.txt`
     all three-letter text files starting with p in subdirs of `foo`

Whitespace issues don't stop there:

 - `if [ "$foo" = "bar" ]; then` -- see the issue?
 - what if `$foo` is empty? arguments to `[` are `=` and `bar`...
 - _can_ work around this with `[ "x$foo" = "xbar" ]`, but bleh
 - instead, use `[[`: bash built-in comparator that has special parsing
   - also allows `&&` instead of `-a`, `||` over `-o`, etc.

<!-- TODO: arrays? $@. ${array[@]} vs "${array[@]}". -->

## Composability

Shell is powerful in part because of composability. Can chain multiple
programs together rather than have one program that does everything.

The key character is `|` (pipe).

 - `a | b` means run both `a` and `b`
   send all output of `a` as input to `b`
   print the output of `b`

All programs you launch ("processes") have three "streams":

 - `STDIN`: when the program reads input, it comes from here
 - `STDOUT`: when the program prints something, it goes here
 - `STDERR`: a 2nd output the program can choose to use
 - by default, `STDIN` is your keyboard, `STDOUT` and `STDERR` are both
   your terminal. but you can change that!
   - `a | b` makes `STDOUT` of `a` `STDIN` of `b`.
   - also have:
     - `a > foo` (`STDOUT` of `a` goes to the file `foo`)
     - `a 2> foo` (`STDERR` of `a` goes to the file `foo`)
     - `a < foo` (`STDIN` of `a` is read from the file `foo`)
     - hint: `tail -f` will print a file as it's being written
 - why is this useful? lets you manipulate output of a program!
   - `ls | grep foo`: all files that contain the word `foo`
   - `ps | grep foo`: all processes that contain the word `foo`
   - `journalctl | grep -i intel | tail -n5`:
     last 5 system log messages with the word intel (case insensitive)
   - `who | sendmail -t me@example.com`
     send the list of logged-in users to `me@example.com`
   - forms the basis for much data-wrangling, as we'll cover later

Bash also provides a number of other ways to compose programs.

You can group commands with `(a; b) | tac`: run `a`, then `b`, and send
all their output to `tac`, which prints its input in reverse order.

A lesser-known, but super useful one is _process substitution_.
`b <(a)` will run `a`, generate a temporary file-name for its output
stream, and pass that file-name to `b`. For example:

```shell
diff <(journalctl -b -1 | head -n20) <(journalctl -b -2 | head -n20)
```
will show you the difference between the first 20 lines of the last boot
log and the one before that.

<!-- TODO: exit codes? -->

## Job and process control

What if you want to run longer-term things in the background?

 - the `&` suffix runs a program "in the background"
   - it will give you back your prompt immediately
   - handy if you want to run two programs at the same time
     like a server and client: `server & client`
   - note that the running program still has your terminal as `STDOUT`!
     try: `server > server.log & client`
 - see all such processes with `jobs`
   - notice that it shows "Running"
 - bring it to the foreground with `fg %JOB` (no argument is latest)
 - if you want to background the current program: `^Z` + `bg`
   - `^Z` stops the current process and makes it a "job"
   - `bg` runs the last job in the background (as if you did `&`)
 - background jobs are still tied to your current session, and exit if
   you log out. `disown` lets you sever that connection. or use `nohup`.
 - `$!` is pid of last background process

<!-- TODO: process output control (^S and ^Q)? -->

What about other stuff running on your computer?

 - `ps` is your friend: lists running processes
   - `ps -A`: print processes from all users (also `ps ax`)
   - `ps` has *many* arguments: see `man ps`
 - `pgrep`: find processes by searching (like `ps -A | grep`)
   - `pgrep -af`: search and display with arguments
 - `kill`: send a _signal_ to a process by ID (`pkill` by search + `-f`)
   - signals tell a process to "do something"
   - most common: `SIGKILL` (`-9` or `-KILL`): tell it to exit *now*
     equivalent to `^\`
   - also `SIGTERM` (`-15` or `-TERM`): tell it to exit gracefully
     equivalent to `^C`

## Exercises and further reading

QoL stuff: fasd/autojump, fzf, rg, fd, etc.

TODO
