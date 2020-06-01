---
layout: lecture
title: "编辑器 (Vim)"
date: 2019-01-15
ready: false
video:
  aspect: 56.25
  id: 3
---

写作和写代码其实是两项非常不同的活动。当我们编程的时候，会经常在文件间进行切换、阅读、浏览和修改代码，而不是连续编写一大段的文字。因此代码编辑器和文本编辑器种是很不同的两种工具（例如 微软的 Word 与 Visual Studio Code）

作为程序员，我们大部分时间都花在代码编辑上，所以花点时间掌握某个适合自己的编辑器是非常值得的。通常学习使用一个新的编辑器包含以下步骤：

- 阅读教程（比如这节课以及我们为您提供的资源）
- 坚持使用它来完成你所有的编辑工作（即使一开始这会让你的工作效率降低）
- 随时查阅：如果某个操作看起来像是有更方便的实现方法，一般情况下真的会有。

如果您能够遵循上述步骤，并且坚持使用新的编辑器完成您所有的文本编辑任务，那么学习一个复杂的代码编辑器的过程一般是这样的：头两个小时，您会学习到编辑器的基本操作，例如打开和编辑文件、保存与退出、浏览缓冲区。当学习时间累计达到20个小时之后，您使用新编辑器时当效率应该已经和使用老编辑器一样来。再次之后，其益处开始显现：有了足够的知识和肌肉记忆后，使用新编辑器将大大节省你的时间。而现代文本编辑器都是些复杂且强大的工具，永远有新东西可学：学的越多，效率越高。

# 该学哪个编辑器？

程序员们对自己正在使用的文本编辑器通常有着 [非常强的执念](https://en.wikipedia.org/wiki/Editor_war)。


现在最流行的编辑器是什么？ [Stack Overflow的调查](https://insights.stackoverflow.com/survey/2019/#development-environments-and-tools)(这个调查可能并不如我们想象的那样客观，因为Stack Overflow 的用户并不能代表所有程序员 )显示， [Visual Studio Code](https://code.visualstudio.com/)是目前最流行的代码编辑器。而[Vim](https://www.vim.org/) 则是最流行的基于命令行的编辑器。

## Vim

All the instructors of this class use Vim as their editor. Vim has a rich
history; it originated from the Vi editor (1976), and it's still being
developed today. Vim has some really neat ideas behind it, and for this reason,
lots of tools support a Vim emulation mode (for example, 1.4 million people
have installed [Vim emulation for VS code](https://github.com/VSCodeVim/Vim)).
Vim is probably worth learning even if you finally end up switching to some
other text editor.

It's not possible to teach all of Vim's functionality in 50 minutes, so we're
going to focus on explaining the philosophy of Vim, teaching you the basics,
showing you some of the more advanced functionality, and giving you the
resources to master the tool.

# Vim的哲学

When programming, you spend most of your time reading/editing, not writing. For
this reason, Vim is a _modal_ editor: it has different modes for inserting text
vs manipulating text. Vim is programmable (with Vimscript and also other
languages like Python), and Vim's interface itself is a programming language:
keystrokes (with mnemonic names) are commands, and these commands are
composable. Vim avoids the use of the mouse, because it's too slow; Vim even
avoids using the arrow keys because it requires too much movement.

The end result is an editor that can match the speed at which you think.

# 编辑模式


Vim的设计以大多数时间都花在阅读、浏览和进行少量编辑改动为基础，因此它具有多种操作模式：

- *正常模式*：在文件中四处移动光标进行修改
- *插入模式*：插入文本
- *替换模式*：替换文本
- *可视（一般，行，块）模式*：选中文本块
- *命令模式*：用于执行命令


Keystrokes have different meanings in different operating modes. For example,
the letter `x` in insert mode will just insert a literal character 'x', but in
normal mode, it will delete the character under the cursor, and in visual mode,
it will delete the selection.

In its default configuration, Vim shows the current mode in the bottom left.
The initial/default mode is normal mode. You'll generally spend most of your
time between normal mode and insert mode.

You change modes by pressing `<ESC>` (the escape key) to switch from any mode
back to normal mode. From normal mode, enter insert mode with `i`, replace mode
with `R`, visual mode with `v`, visual line mode with `V`, visual block mode
with `<C-v>` (Ctrl-V, sometimes also written `^V`), and command-line mode with
`:`.

You use the `<ESC>` key a lot when using Vim: consider remapping Caps Lock to
Escape ([macOS
instructions](https://vim.fandom.com/wiki/Map_caps_lock_to_escape_in_macOS)).

# 基本操作

## 插入文本

From normal mode, press `i` to enter insert mode. Now, Vim behaves like any
other text editor, until you press `<ESC>` to return to normal mode. This,
along with the basics explained above, are all you need to start editing files
using Vim (though not particularly efficiently, if you're spending all your
time editing from insert mode).

## Buffers, tabs, and windows

Vim maintains a set of open files, called "buffers". A Vim session has a number
of tabs, each of which has a number of windows (split panes). Each window shows
a single buffer. Unlike other programs you are familiar with, like web
browsers, there is not a 1-to-1 correspondence between buffers and windows;
windows are merely views. A given buffer may be open in _multiple_ windows,
even within the same tab. This can be quite handy, for example, to view two
different parts of a file at the same time.

By default, Vim opens with a single tab, which contains a single window.

## 命令行

Command mode can be entered by typing `:` in normal mode. Your cursor will jump
to the command line at the bottom of the screen upon pressing `:`. This mode
has many functionalities, including opening, saving, and closing files, and
[quitting Vim](https://twitter.com/iamdevloper/status/435555976687923200).

- `:q` quit (close window)
- `:w` save ("write")
- `:wq` save and quit
- `:e {name of file}` open file for editing
- `:ls` show open buffers
- `:help {topic}` open help
    - `:help :w` opens help for the `:w` command
    - `:help w` opens help for the `w` movement

# Vim 的接口其实是一种编程语言

The most important idea in Vim is that Vim's interface itself is a programming
language. Keystrokes (with mnemonic names) are commands, and these commands
_compose_. This enables efficient movement and edits, especially once the
commands become muscle memory.

## 移动

You should spend most of your time in normal mode, using movement commands to
navigate the buffer. Movements in Vim are also called "nouns", because they
refer to chunks of text.

- Basic movement: `hjkl` (left, down, up, right)
- Words: `w` (next word), `b` (beginning of word), `e` (end of word)
- Lines: `0` (beginning of line), `^` (first non-blank character), `$` (end of line)
- Screen: `H` (top of screen), `M` (middle of screen), `L` (bottom of screen)
- Scroll: `Ctrl-u` (up), `Ctrl-d` (down)
- File: `gg` (beginning of file), `G` (end of file)
- Line numbers: `:{number}<CR>` or `{number}G` (line {number})
- Misc: `%` (corresponding item)
- Find: `f{character}`, `t{character}`, `F{character}`, `T{character}`
    - find/to forward/backward {character} on the current line
    - `,` / `;` for navigating matches
- Search: `/{regex}`, `n` / `N` for navigating matches

## 选择

Visual modes:

- Visual
- Visual Line
- Visual Block

Can use movement keys to make selection.

## 编辑

Everything that you used to do with the mouse, you now do with the keyboard
using editing commands that compose with movement commands. Here's where Vim's
interface starts to look like a programming language. Vim's editing commands
are also called "verbs", because verbs act on nouns.

- `i` enter insert mode
    - but for manipulating/deleting text, want to use something more than
    backspace
- `o` / `O` insert line below / above
- `d{motion}` delete {motion}
    - e.g. `dw` is delete word, `d$` is delete to end of line, `d0` is delete
    to beginning of line
- `c{motion}` change {motion}
    - e.g. `cw` is change word
    - like `d{motion}` followed by `i`
- `x` delete character (equal do `dl`)
- `s` substitute character (equal to `xi`)
- visual mode + manipulation
    - select text, `d` to delete it or `c` to change it
- `u` to undo, `<C-r>` to redo
- `y` to copy / "yank" (some other commands like `d` also copy)
- `p` to paste
- Lots more to learn: e.g. `~` flips the case of a character

## 计数

You can combine nouns and verbs with a count, which will perform a given action
a number of times.

- `3w` move 3 words forward
- `5j` move 5 lines down
- `7dw` delete 7 words

## 修饰语

You can use modifiers to change the meaning of a noun. Some modifiers are `i`,
which means "inner" or "inside", and `a`, which means "around".

- `ci(` change the contents inside the current pair of parentheses
- `ci[` change the contents inside the current pair of square brackets
- `da'` delete a single-quoted string, including the surrounding single quotes

# Demo

Here is a broken [fizz buzz](https://en.wikipedia.org/wiki/Fizz_buzz)
implementation:

```python
def fizz_buzz(limit):
    for i in range(limit):
        if i % 3 == 0:
            print('fizz')
        if i % 5 == 0:
            print('fizz')
        if i % 3 and i % 5:
            print(i)

def main():
    fizz_buzz(10)
```

We will fix the following issues:

- Main is never called
- Starts at 0 instead of 1
- Prints "fizz" and "buzz" on separate lines for multiples of 15
- Prints "fizz" for multiples of 5
- Uses a hard-coded argument of 10 instead of taking a command-line argument

{% comment %}
- main is never called
  - `G` end of file
  - `o` open new line below
  - type in "if __name__ ..." thing
- starts at 0 instead of 1
  - search for `/range`
  - `ww` to move forward 2 words
  - `i` to insert text, "1, "
  - `ea` to insert after limit, "+1"
- newline for "fizzbuzz"
  - `jj$i` to insert text at end of line
  - add ", end=''"
  - `jj.` to repeat for second print
  - `jjo` to open line below if
  - add "else: print()"
- fizz fizz
  - `ci'` to change fizz
- command-line argument
  - `ggO` to open above
  - "import sys"
  - `/10`
  - `ci(` to "int(sys.argv[1])"
{% endcomment %}

See the lecture video for the demonstration. Compare how the above changes are
made using Vim to how you might make the same edits using another program.
Notice how very few keystrokes are required in Vim, allowing you to edit at the
speed you think.

# 自定义 Vim

Vim is customized through a plain-text configuration file in `~/.vimrc`
(containing Vimscript commands). There are probably lots of basic settings that
you want to turn on.

We are providing a well-documented basic config that you can use as a starting
point. We recommend using this because it fixes some of Vim's quirky default
behavior. **Download our config [here](/2020/files/vimrc) and save it to
`~/.vimrc`.**

Vim is heavily customizable, and it's worth spending time exploring
customization options. You can look at people's dotfiles on GitHub for
inspiration, for example, your instructors' Vim configs
([Anish](https://github.com/anishathalye/dotfiles/blob/master/vimrc),
[Jon](https://github.com/jonhoo/configs/blob/master/editor/.config/nvim/init.vim) (uses [neovim](https://neovim.io/)),
[Jose](https://github.com/JJGO/dotfiles/blob/master/vim/.vimrc)). There are
lots of good blog posts on this topic too. Try not to copy-and-paste people's
full configuration, but read it, understand it, and take what you need.

# 扩展 Vim

There are tons of plugins for extending Vim. Contrary to outdated advice that
you might find on the internet, you do _not_ need to use a plugin manager for
Vim (since Vim 8.0). Instead, you can use the built-in package management
system. Simply create the directory `~/.vim/pack/vendor/start/`, and put
plugins in there (e.g. via `git clone`).

Here are some of our favorite plugins:

- [ctrlp.vim](https://github.com/ctrlpvim/ctrlp.vim): fuzzy file finder
- [ack.vim](https://github.com/mileszs/ack.vim): code search
- [nerdtree](https://github.com/scrooloose/nerdtree): file explorer
- [vim-easymotion](https://github.com/easymotion/vim-easymotion): magic motions

We're trying to avoid giving an overwhelmingly long list of plugins here. You
can check out the instructors' dotfiles
([Anish](https://github.com/anishathalye/dotfiles),
[Jon](https://github.com/jonhoo/configs),
[Jose](https://github.com/JJGO/dotfiles)) to see what other plugins we use.
Check out [Vim Awesome](https://vimawesome.com/) for more awesome Vim plugins.
There are also tons of blog posts on this topic: just search for "best Vim
plugins".

# 其他程序的 Vim 模式

Many tools support Vim emulation. The quality varies from good to great;
depending on the tool, it may not support the fancier Vim features, but most
cover the basics pretty well.

## Shell

If you're a Bash user, use `set -o vi`. If you use Zsh, `bindkey -v`. For Fish,
`fish_vi_key_bindings`. Additionally, no matter what shell you use, you can
`export EDITOR=vim`. This is the environment variable used to decide which
editor is launched when a program wants to start an editor. For example, `git`
will use this editor for commit messages.

## Readline

Many programs use the [GNU
Readline](https://tiswww.case.edu/php/chet/readline/rltop.html) library for
their command-line interface. Readline supports (basic) Vim emulation too,
which can be enabled by adding the following line to the `~/.inputrc` file:

```
set editing-mode vi
```

With this setting, for example, the Python REPL will support Vim bindings.

## 其他

There are even vim keybinding extensions for web
[browsers](http://vim.wikia.com/wiki/Vim_key_bindings_for_web_browsers), some
popular ones are
[Vimium](https://chrome.google.com/webstore/detail/vimium/dbepggeogbaibhgnhhndojpepiihcmeb?hl=en)
for Google Chrome and [Tridactyl](https://github.com/tridactyl/tridactyl) for
Firefox. You can even get Vim bindings in [Jupyter
notebooks](https://github.com/lambdalisue/jupyter-vim-binding).

# Vim 进阶

Here are a few examples to show you the power of the editor. We can't teach you
all of these kinds of things, but you'll learn them as you go. A good
heuristic: whenever you're using your editor and you think "there must be a
better way of doing this", there probably is: look it up online.

## 搜索和替换

`:s` (substitute) command ([documentation](http://vim.wikia.com/wiki/Search_and_replace)).

- `%s/foo/bar/g`
    - replace foo with bar globally in file
- `%s/\[.*\](\(.*\))/\1/g`
    - replace named Markdown links with plain URLs

## 多窗口

- `:sp` / `:vsp` to split windows
- Can have multiple views of the same buffer.

## 宏

- `q{character}` to start recording a macro in register `{character}`
- `q` to stop recording
- `@{character}` replays the macro
- Macro execution stops on error
- `{number}@{character}` executes a macro {number} times
- Macros can be recursive
    - first clear the macro with `q{character}q`
    - record the macro, with `@{character}` to invoke the macro recursively
    (will be a no-op until recording is complete)
- Example: convert xml to json ([file](/2020/files/example-data.xml))
    - Array of objects with keys "name" / "email"
    - Use a Python program?
    - Use sed / regexes
        - `g/people/d`
        - `%s/<person>/{/g`
        - `%s/<name>\(.*\)<\/name>/"name": "\1",/g`
        - ...
    - Vim commands / macros
        - `Gdd`, `ggdd` delete first and last lines
        - Macro to format a single element (register `e`)
            - Go to line with `<name>`
            - `qe^r"f>s": "<ESC>f<C"<ESC>q`
        - Macro to format a person
            - Go to line with `<person>`
            - `qpS{<ESC>j@eA,<ESC>j@ejS},<ESC>q`
        - Macro to format a person and go to the next person
            - Go to line with `<person>`
            - `qq@pjq`
        - Execute macro until end of file
            - `999@q`
        - Manually remove last `,` and add `[` and `]` delimiters

# 扩展资料

- `vimtutor` is a tutorial that comes installed with Vim
- [Vim Adventures](https://vim-adventures.com/) is a game to learn Vim
- [Vim Tips Wiki](http://vim.wikia.com/wiki/Vim_Tips_Wiki)
- [Vim Advent Calendar](https://vimways.org/2019/) has various Vim tips
- [Vim Golf](http://www.vimgolf.com/) is [code golf](https://en.wikipedia.org/wiki/Code_golf), but where the programming language is Vim's UI
- [Vi/Vim Stack Exchange](https://vi.stackexchange.com/)
- [Vim Screencasts](http://vimcasts.org/)
- [Practical Vim](https://pragprog.com/book/dnvim2/practical-vim-second-edition) (book)

# 课后练习

1. Complete `vimtutor`. Note: it looks best in a
   [80x24](https://en.wikipedia.org/wiki/VT100) (80 columns by 24 lines)
   terminal window.
1. Download our [basic vimrc](/2020/files/vimrc) and save it to `~/.vimrc`. Read
   through the well-commented file (using Vim!), and observe how Vim looks and
   behaves slightly differently with the new config.
1. Install and configure a plugin:
   [ctrlp.vim](https://github.com/ctrlpvim/ctrlp.vim).
   1. Create the plugins directory with `mkdir -p ~/.vim/pack/vendor/start`
   1. Download the plugin: `cd ~/.vim/pack/vendor/start; git clone
      https://github.com/ctrlpvim/ctrlp.vim`
   1. Read the
      [documentation](https://github.com/ctrlpvim/ctrlp.vim/blob/master/readme.md)
      for the plugin. Try using CtrlP to locate a file by navigating to a
      project directory, opening Vim, and using the Vim command-line to start
      `:CtrlP`.
    1. Customize CtrlP by adding
       [configuration](https://github.com/ctrlpvim/ctrlp.vim/blob/master/readme.md#basic-options)
       to your `~/.vimrc` to open CtrlP by pressing Ctrl-P.
1. To practice using Vim, re-do the [Demo](#demo) from lecture on your own
   machine.
1. Use Vim for _all_ your text editing for the next month. Whenever something
   seems inefficient, or when you think "there must be a better way", try
   Googling it, there probably is. If you get stuck, come to office hours or
   send us an email.
1. Configure your other tools to use Vim bindings (see instructions above).
1. Further customize your `~/.vimrc` and install more plugins.
1. (Advanced) Convert XML to JSON ([example file](/2020/files/example-data.xml))
   using Vim macros. Try to do this on your own, but you can look at the
   [macros](#macros) section above if you get stuck.
