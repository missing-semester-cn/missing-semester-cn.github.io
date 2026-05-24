---
layout: lecture
title: "开发环境与工具"
description: >
  了解 IDE、Vim、语言服务器，以及 AI 驱动的开发工具。
thumbnail: /static/assets/thumbnails/2026/lec3.png
date: 2026-01-14
ready: true
video:
  aspect: 56.25
  id: QnM1nVzrkx8
---

_开发环境_ 是一组用于开发软件的工具。开发环境的核心是文本编辑功能，以及语法高亮、类型检查、代码格式化和自动补全等配套功能。像 [VS Code][vs-code] 这样的 _集成开发环境_（IDE）会把这些功能整合到一个应用里。基于终端的开发工作流则会组合使用多种工具，例如 [tmux](https://github.com/tmux/tmux)（终端复用器）、[Vim](https://www.vim.org/)（文本编辑器）、[Zsh](https://www.zsh.org/)（shell），以及特定语言的命令行工具，例如 [Ruff](https://docs.astral.sh/ruff/)（Python linter 和代码格式化工具）和 [Mypy](https://mypy-lang.org/)（Python 类型检查器）。

IDE 和基于终端的工作流各有优缺点。比如，图形化 IDE 可能更容易上手，而今天的 IDE 通常也拥有更好的开箱即用 AI 集成能力，比如 AI 自动补全；另一方面，基于终端的工作流更加轻量，而且在没有 GUI 或无法安装软件的环境中，它们可能是你唯一的选择。我们建议你对两者都具备基本熟悉度，并至少精通其中一种。如果你还没有偏好的 IDE，我们建议从 [VS Code][vs-code] 开始。

本讲将介绍：

- [文本编辑与 Vim](#text-editing-and-vim)
- [代码智能与语言服务器](#code-intelligence-and-language-servers)
- [AI 驱动的开发](#ai-powered-development)
- [扩展与其他 IDE 功能](#extensions-and-other-ide-functionality)

[vs-code]: https://code.visualstudio.com/

<a id="text-editing-and-vim"></a>

# 文本编辑与 Vim

编程时，你的大部分时间并不是在连续写出大段代码，也不是从头到尾阅读文件，而是在代码中导航、阅读代码片段，以及对代码进行编辑。[Vim] 是一种针对这种任务分布而优化的文本编辑器。

**Vim 的哲学。** Vim 的基础是一种漂亮的想法：它的界面本身就是一门编程语言，专为导航和编辑文本而设计。按键（带有助记性的名称）就是命令，而这些命令可以组合。Vim 避免使用鼠标，因为鼠标太慢；Vim 甚至避免使用方向键，因为方向键需要太多手部移动。结果就是：这个编辑器用起来像是脑机接口，能够匹配你的思考速度。

**其他软件中的 Vim 支持。** 你不一定非要使用 [Vim] 本身，才能受益于它的核心思想。很多涉及文本编辑的程序都支持“Vim 模式”，有些是内置功能，有些则通过插件实现。例如，VS Code 有 [VSCodeVim](https://marketplace.visualstudio.com/items?itemName=vscodevim.vim) 插件，Zsh 对 Vim 仿真有[内置支持](https://zsh.sourceforge.io/Guide/zshguide04.html)，甚至 Claude Code 也对 Vim 编辑器模式提供了[内置支持](https://code.claude.com/docs/en/interactive-mode#vim-editor-mode)。你使用的任何涉及文本编辑的工具，很可能都以某种方式支持 Vim 模式。

## 模式编辑

Vim 是一个 _模式编辑器_：它针对不同类别的任务有不同的操作模式。

- **Normal（普通模式）**：用于在文件中移动和进行编辑
- **Insert（插入模式）**：用于插入文本
- **Replace（替换模式）**：用于替换文本
- **Visual（可视模式）**（普通、行或块）：用于选择文本块
- **Command-line（命令行模式）**：用于运行命令

按键在不同操作模式下有不同含义。例如，在插入模式中，字母 `x` 只会插入一个字面字符“x”；但在普通模式中，它会删除光标下的字符；而在可视模式中，它会删除选区。

在默认配置下，Vim 会在左下角显示当前模式。初始/默认模式是普通模式。通常，你大部分时间会在普通模式和插入模式之间切换。

你可以按 `<ESC>`（Escape 键）从任意模式切回普通模式。在普通模式中，可以按 `i` 进入插入模式，按 `R` 进入替换模式，按 `v` 进入可视模式，按 `V` 进入可视行模式，按 `<C-v>`（Ctrl-V，有时也写作 `^V`）进入可视块模式，按 `:` 进入命令行模式。

使用 Vim 时你会大量使用 `<ESC>` 键：可以考虑把 Caps Lock 重映射为 Escape（[macOS 说明](https://vim.fandom.com/wiki/Map_caps_lock_to_escape_in_macOS)），或者用一段简单的按键序列为 `<ESC>` 创建一个[替代映射](https://vim.fandom.com/wiki/Avoid_the_escape_key#Mappings)。

## 基础：插入文本

在普通模式中，按 `i` 进入插入模式。此时，Vim 的行为就像任何其他文本编辑器一样，直到你按 `<ESC>` 回到普通模式。只要掌握这一点和上面解释的基础知识，你就已经可以用 Vim 开始编辑文件了（不过如果你所有时间都在插入模式中编辑，效率并不会特别高）。

## Vim 的界面是一门编程语言

Vim 的界面是一门编程语言。按键（带有助记性的名称）就是命令，而这些命令可以 _组合_。这让移动和编辑变得高效，尤其是在这些命令形成肌肉记忆之后，就像你学会键盘布局后打字会变得非常高效一样。

### 移动

你应该把大部分时间花在普通模式中，用移动命令在文件里导航。Vim 中的移动也叫作“名词”，因为它们指代文本块。

- 基本移动：`hjkl`（左、下、上、右）
- 单词：`w`（下一个单词）、`b`（单词开头）、`e`（单词结尾）
- 行：`0`（行首）、`^`（第一个非空白字符）、`$`（行尾）
- 屏幕：`H`（屏幕顶部）、`M`（屏幕中部）、`L`（屏幕底部）
- 滚动：`Ctrl-u`（向上）、`Ctrl-d`（向下）
- 文件：`gg`（文件开头）、`G`（文件结尾）
- 行号：`:{number}<CR>` 或 `{number}G`（第 {number} 行）
  - `<CR>` 指回车/Enter 键
- 其他：`%`（匹配项，例如括号或大括号）
- 查找：`f{character}`、`t{character}`、`F{character}`、`T{character}`
  - 在当前行向前/向后 find/to 到 {character}
  - 用 `,` / `;` 在匹配项之间导航
- 搜索：`/{regex}`，用 `n` / `N` 在匹配项之间导航

### 选择

可视模式：

- 可视模式：`v`
- 可视行模式：`V`
- 可视块模式：`Ctrl-v`

可以使用移动键来扩展选区。

### 编辑

过去你用鼠标做的事情，现在都可以通过键盘上的编辑命令完成；这些编辑命令可以与移动命令组合。Vim 的界面从这里开始看起来像一门编程语言。Vim 的编辑命令也叫作“动词”，因为动词作用于名词。

- `i` 进入插入模式
  - 但如果要操作/删除文本，你想使用的不应只是退格键
- `o` / `O` 在下方/上方插入新行
- `d{motion}` 删除 {motion}
  - 例如 `dw` 是删除一个单词，`d$` 是删除到行尾，`d0` 是删除到行首
- `c{motion}` 修改 {motion}
  - 例如 `cw` 是修改一个单词
  - 类似于 `d{motion}` 后接 `i`
- `x` 删除字符（等价于 `dl`）
- `s` 替换字符（等价于 `cl`）
- 可视模式 + 操作
  - 选中文本后，按 `d` 删除它，或按 `c` 修改它
- `u` 撤销，`<C-r>` 重做
- `y` 复制/“yank”（像 `d` 这样的一些其他命令也会复制）
- `p` 粘贴
- 还有很多可以学习：例如，`~` 会切换字符大小写，`J` 会把多行连接到一起

### 次数

你可以把名词、动词和次数组合起来，让某个动作执行指定次数。

- `3w` 向前移动 3 个单词
- `5j` 向下移动 5 行
- `7dw` 删除 7 个单词

### 修饰符

你可以用修饰符改变名词的含义。有些修饰符包括 `i`，表示“inner”或“inside”（内部），以及 `a`，表示“around”（周围）。

- `ci(` 修改当前一对圆括号内部的内容
- `ci[` 修改当前一对方括号内部的内容
- `da'` 删除一个单引号字符串，包括周围的单引号

## 综合示例

下面是一个有问题的 [fizz buzz](https://en.wikipedia.org/wiki/Fizz_buzz) 实现：

```python
def fizz_buzz(limit):
    for i in range(limit):
        if i % 3 == 0:
            print("fizz", end="")
        if i % 5 == 0:
            print("fizz", end="")
        if i % 3 and i % 5:
            print(i, end="")
        print()

def main():
    fizz_buzz(20)
```

我们从普通模式开始，使用下面这组命令序列来修复问题：

- `main` 从未被调用
  - `G` 跳到文件末尾
  - `o` 在下方 **o**pen（打开）一个新行
  - 输入 `if __name__ == "__main__": main()`
    - 如果你的编辑器有 Python 语言支持，它可能会在插入模式中帮你做一些自动缩进
  - `<ESC>` 回到普通模式
- 从 0 而不是从 1 开始
  - 按 `/`，再输入 `range` 和 `<CR>`，搜索“range”
  - `ww` 向前移动两个 **w**ord（单词）（也可以用 `2w`，但实践中，对较小的次数，重复按键通常比使用次数功能更常见）
  - `i` 切换到 **i**nsert（插入）模式，并添加 `1,`
  - `<ESC>` 回到普通模式
  - `e` 跳到下一个单词的 **e**nd（结尾）
  - `a` 开始 **a**ppend（追加）文本，并添加 `+ 1`
  - `<ESC>` 回到普通模式
- 对 5 的倍数打印了“fizz”
  - `:6<CR>` 跳到第 6 行
  - `ci"` 表示 **c**hange（修改）**i**nside（内部）这对 `"` 中的内容，把它改成 `"buzz"`
  - `<ESC>` 回到普通模式

## 学习 Vim

学习 Vim 的最好方式，是先掌握基础知识（也就是我们到目前为止讲过的内容），然后在你所有软件中启用 Vim 模式，并开始在实践中使用它。避免使用鼠标或方向键的诱惑；在一些编辑器里，你甚至可以取消方向键绑定，强迫自己养成好习惯。

### 更多资源

- 本课程上一轮的 [Vim 讲义](/2020/editors/)——那里更深入地讲过 Vim
- `vimtutor` 是随 Vim 安装的教程——如果已经安装了 Vim，你应该可以在 shell 中运行 `vimtutor`
- [Vim Adventures](https://vim-adventures.com/) 是一个学习 Vim 的游戏
- [Vim Tips Wiki](https://vim.fandom.com/wiki/Vim_Tips_Wiki)
- [Vim Advent Calendar](https://vimways.org/2019/) 包含各种 Vim 技巧
- [VimGolf](https://www.vimgolf.com/) 是 [code golf](https://en.wikipedia.org/wiki/Code_golf)，不过其中的编程语言是 Vim 的 UI
- [Vi/Vim Stack Exchange](https://vi.stackexchange.com/)
- [Vim Screencasts](http://vimcasts.org/)
- [Practical Vim](https://pragprog.com/titles/dnvim2/)（书籍）

[Vim]: https://www.vim.org/

<a id="code-intelligence-and-language-servers"></a>

# 代码智能与语言服务器

IDE 通常会提供特定语言的支持，这些支持需要对代码进行语义理解，通常由 IDE 扩展连接到实现了 [Language Server Protocol](https://microsoft.github.io/language-server-protocol/) 的 _语言服务器_ 来完成。例如，[VS Code 的 Python 扩展](https://marketplace.visualstudio.com/items?itemName=ms-python.python)依赖 [Pylance](https://marketplace.visualstudio.com/items?itemName=ms-python.vscode-pylance)，而 [VS Code 的 Go 扩展](https://marketplace.visualstudio.com/items?itemName=golang.go)依赖 Go 官方的 [gopls](https://go.dev/gopls/)。为你使用的语言安装扩展和语言服务器之后，你就可以在 IDE 中启用许多特定语言的功能，例如：

- **代码补全。** 更好的自动补全和自动建议，比如在输入 `object.` 后，能够看到某个对象的字段和方法。
- **内联文档。** 在悬停和自动建议中查看文档。
- **跳转到定义。** 从使用位置跳转到定义位置，例如从字段引用 `object.field` 跳转到该字段的定义。
- **查找引用。** 上一项的反向操作：查找某个字段、类型等特定项目被引用的所有位置。
- **导入辅助。** 整理导入、移除未使用的导入、标记缺失的导入。
- **代码质量。** 这些工具可以单独使用，但语言服务器通常也会提供此类功能。代码格式化工具会自动缩进和自动格式化代码，类型检查器和 linter 会在你输入时发现代码中的错误。我们会在[代码质量讲义](/2026/code-quality/)中更深入地介绍这一类功能。

## 配置语言服务器

对于某些语言，你只需要安装扩展和语言服务器，一切就准备好了。对于其他语言，为了最大化语言服务器的收益，你需要告诉 IDE 你的环境信息。例如，让 VS Code 指向你的 [Python 环境](https://code.visualstudio.com/docs/python/environments)，就能让语言服务器看到你安装的包。环境会在我们的[打包与发布代码讲义](/2026/shipping-code/)中更深入地介绍。

根据具体语言，你可能还可以为语言服务器配置一些设置。例如，在 VS Code 的 Python 支持中，对于没有使用 Python 可选类型注解的项目，你可以禁用静态类型检查。

<a id="ai-powered-development"></a>

# AI 驱动的开发

自从 2021 年中期 [GitHub Copilot][github-copilot] 使用 OpenAI 的 [Codex 模型](https://openai.com/index/openai-codex/)亮相以来，[LLM](https://en.wikipedia.org/wiki/Large_language_model) 已经在软件工程中得到广泛采用。现在主要有三种形态：自动补全、内联聊天和编程代理。

[github-copilot]: https://github.com/features/copilot/ai-code-editor

## 自动补全

AI 驱动的自动补全与 IDE 中传统自动补全的形态相同：在你输入时，在光标位置提供补全建议。有时，它会作为一种“开箱即用”的被动功能使用。除此之外，AI 自动补全通常会通过代码注释来进行[提示](https://en.wikipedia.org/wiki/Prompt_engineering)。

例如，我们来写一个脚本，用于下载这些讲义的内容并提取其中所有链接。可以从这里开始：

```python
import requests

def download_contents(url: str) -> str:
```

模型会自动补全函数体：

```python
    response = requests.get(url)
    return response.text
```

我们还可以用注释进一步引导补全。例如，如果我们开始写一个函数来提取所有 Markdown 链接，但函数名不够描述性：

```python
def extract(contents: str) -> list[str]:
```

模型可能会自动补全出类似这样的内容：

```python
    lines = contents.splitlines()
    return [line for line in lines if line.strip()]
```

我们可以通过代码注释引导补全：

```python
def extract(content: str) -> list[str]:
    # extract all Markdown links from the content
```

这一次，模型给出了更好的补全：

```python
    import re
    pattern = r'\[.*?\]\((.*?)\)'
    return re.findall(pattern, content)
```

在这里，我们看到了这种 AI 编码工具的一个缺点：它只能在光标位置提供补全。在这个例子中，更好的实践是把 `import re` 放在模块级别，而不是放在函数内部。

上面的例子使用了一个命名很差的函数，是为了演示如何用注释来引导代码补全；在实践中，你应该使用更具描述性的函数名，例如 `extract_links`，并编写 docstring（基于这些信息，模型应该会生成与上面类似的补全）。

为了演示，我们可以补完整个脚本：

```python
print(extract(download_contents("https://raw.githubusercontent.com/missing-semester/missing-semester/refs/heads/master/_2026/development-environment.md")))
```

## 内联聊天

内联聊天让你可以选中某一行或某个代码块，然后直接提示 AI 模型提出一次编辑。在这种交互模式中，模型可以修改已有代码（这不同于自动补全，自动补全只能补全光标之后的代码）。

继续上面的例子，假设我们决定不使用第三方 `requests` 库。我们可以选中相关的三行代码，调用内联聊天，然后说类似这样的话：

```text
use built-in libraries instead
```

模型会提出：

```python
from urllib.request import urlopen

def download_contents(url: str) -> str:
    with urlopen(url) as response:
        return response.read().decode('utf-8')
```

## 编程代理

编程代理会在 [Agentic Coding](/2026/agentic-coding/) 讲义中深入介绍。

## 推荐软件

一些流行的 AI IDE 包括搭配 [GitHub Copilot][github-copilot] 扩展使用的 [VS Code][vs-code]，以及 [Cursor](https://cursor.com/)。GitHub Copilot 目前对[学生免费](https://github.com/education/students)，也对教师和热门开源项目维护者免费。这个领域正在快速发展。许多领先产品都拥有大致等价的功能。

<a id="extensions-and-other-ide-functionality"></a>

# 扩展与其他 IDE 功能

IDE 是强大的工具，而 _扩展_ 会让它们更强大。我们无法在一节课里覆盖所有这些功能，但这里会提供几个流行扩展的方向。我们鼓励你自己探索这个领域；网上有许多热门 IDE 扩展列表，例如面向 Vim 插件的 [Vim Awesome](https://vimawesome.com/)，以及[按流行度排序的 VS Code 扩展](https://marketplace.visualstudio.com/search?target=VSCode&category=All%20categories&sortBy=Installs)。

- [开发容器](https://containers.dev/)：受流行 IDE 支持（例如 [VS Code 支持](https://code.visualstudio.com/docs/devcontainers/containers)）。开发容器允许你使用容器来运行开发工具。这有助于提升可移植性或隔离性。[打包与发布代码讲义](/2026/shipping-code/)会更深入地介绍容器。
- 远程开发：通过 SSH 在远程机器上开发（例如使用 [VS Code 的 Remote SSH 插件](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-ssh)）。例如，如果你想在云端一台强大的 GPU 机器上开发和运行代码，这会很方便。
- 协同编辑：像 Google Docs 那样编辑同一个文件（例如使用 [VS Code 的 Live Share 插件](https://marketplace.visualstudio.com/items?itemName=MS-vsliveshare.vsliveshare)）。

# 练习

1. 在你使用的所有支持 Vim 模式的软件中启用 Vim 模式，例如你的编辑器和 shell，并在接下来一个月的所有文本编辑中使用 Vim 模式。每当某件事看起来效率低，或者你想到“肯定有更好的办法”时，试着去 Google 一下，很可能确实有更好的办法。
2. 完成一个 [VimGolf](https://www.vimgolf.com/) 挑战。
3. 为你正在做的某个项目配置 IDE 扩展和语言服务器。确保所有预期功能都能正常工作，例如对库依赖进行跳转到定义。如果你没有可以用于这个练习的代码，可以使用 GitHub 上的某个开源项目（例如[这个项目](https://github.com/spf13/cobra)）。
4. 浏览一个 IDE 扩展列表，并安装一个看起来对你有用的扩展。
