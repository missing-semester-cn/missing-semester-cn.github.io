---
layout: lecture
title: "开发环境与工具"
description: >
  了解 IDE、Vim、语言服务器和 AI 驱动的开发工具。
thumbnail: /static/assets/thumbnails/2026/lec3.png
date: 2026-01-14
ready: true
video:
  aspect: 56.25
  id: QnM1nVzrkx8
---

_开发环境_ 是一套用于开发软件的工具。开发环境的核心是文本编辑功能，以及随之而来的功能，如语法高亮、类型检查、代码格式化和自动补全。_集成开发环境_（IDE），如 [VS Code][vs-code]，将所有这些功能整合到一个应用程序中。基于终端的开发工作流结合了 [tmux](https://github.com/tmux/tmux)（终端复用器）、[Vim](https://www.vim.org/)（文本编辑器）、[Zsh](https://www.zsh.org/)（shell）等工具，以及特定于语言的命令行工具，如 [Ruff](https://docs.astral.sh/ruff/)（Python 的 linter 和代码格式化工具）和 [Mypy](https://mypy-lang.org/)（Python 的类型检查器）。

IDE 和基于终端的工作流各有优缺点。例如，图形化的 IDE 更容易学习，而且现在的 IDE 通常有更好的开箱即用的 AI 集成，如 AI 自动补全；另一方面，基于终端的工作流是轻量级的，在没有 GUI 或无法安装软件的环境中，它们可能是你唯一的选择。我们建议你基本熟悉两者，并精通至少一种。如果你还没有首选的 IDE，我们建议从 [VS Code][vs-code] 开始。

在本讲座中，我们将涵盖：

- [文本编辑与 Vim](#text-editing-and-vim)
- [代码智能与语言服务器](#code-intelligence-and-language-servers)
- [AI 驱动的开发](#ai-powered-development)
- [扩展和其他 IDE 功能](#extensions-and-other-ide-functionality)

[vs-code]: https://code.visualstudio.com/

# 文本编辑与 Vim

在编程时，你大部分时间都在浏览代码、阅读代码片段和编辑代码，而不是编写长串的代码或从上到下阅读文件。[Vim] 是一个针对这种任务分布优化的文本编辑器。

**Vim 的理念。** Vim 有一个美丽的基础理念：它的接口本身就是一门编程语言，专为导航和编辑文本而设计。按键（带有助记名称）是命令，这些命令是可组合的。Vim 避免使用鼠标，因为它太慢；Vim 甚至避免使用方向键，因为它需要太多的移动。结果是：一个感觉像脑机接口的编辑器，与你思考的速度相匹配。

**其他软件中的 Vim 支持。** 你不必使用 [Vim] 本身就能从其核心理念中受益。许多涉及任何类型文本编辑的程序都支持 "Vim 模式"，无论是作为内置功能还是作为插件。例如，VS Code 有 [VSCodeVim](https://marketplace.visualstudio.com/items?itemName=vscodevim.vim) 插件，Zsh 有 Vim 仿真的[内置支持](https://zsh.sourceforge.io/Guide/zshguide04.html)，甚至 Claude Code 也有 Vim 编辑器模式的[内置支持](https://code.claude.com/docs/en/interactive-mode#vim-editor-mode)。很可能你使用的任何涉及文本编辑的工具都以某种方式支持 Vim 模式。

## 模态编辑

Vim 是一个_模态编辑器_：它有针对不同任务类别的不同操作模式。

- **Normal（普通）**：在文件中移动和进行编辑
- **Insert（插入）**：插入文本
- **Replace（替换）**：替换文本
- **Visual（可视）**（普通、行或块）：选择文本块
- **Command-line（命令行）**：运行命令

按键在不同的操作模式下有不同的含义。例如，字母 `x` 在 Insert 模式下只会插入字面字符 "x"，但在 Normal 模式下，它会删除光标下的字符，在 Visual 模式下，它会删除选中的内容。

在默认配置中，Vim 在左下角显示当前模式。初始/默认模式是 Normal 模式。你通常会在 Normal 模式和 Insert 模式之间度过大部分时间。

你可以通过按 `<ESC>`（Escape 键）从任何模式切换回 Normal 模式。从 Normal 模式，使用 `i` 进入 Insert 模式，`R` 进入 Replace 模式，`v` 进入 Visual 模式，`V` 进入 Visual Line 模式，`<C-v>`（Ctrl-V，有时也写作 `^V`）进入 Visual Block 模式，`:` 进入 Command-line 模式。

使用 Vim 时你会频繁使用 `<ESC>` 键：考虑将 Caps Lock 重新映射为 Escape（[macOS 说明](https://vim.fandom.com/wiki/Map_caps_lock_to_escape_in_macOS)）或为 `<ESC>` 创建一个简单的按键[替代映射](https://vim.fandom.com/wiki/Avoid_the_escape_key#Mappings)。

## 基础：插入文本

从 Normal 模式，按 `i` 进入 Insert 模式。现在，Vim 的行为就像任何其他文本编辑器，直到你按 `<ESC>` 返回 Normal 模式。这些，以及上面解释的基础知识，是你开始使用 Vim 编辑文件所需的全部（尽管如果你把所有时间都花在从 Insert 模式编辑上，效率不会特别高）。

## Vim 的接口是一门编程语言

Vim 的接口是一门编程语言。按键（带有助记名称）是命令，这些命令_组合_。这使得移动和编辑变得高效，特别是当命令成为肌肉记忆时，就像一旦你学会了键盘布局，打字就会变得非常高效。

### 移动

你应该在 Normal 模式下度过大部分时间，使用移动命令导航文件。Vim 中的移动也称为 "名词"，因为它们指的是文本块。

- 基本移动：`hjkl`（左、下、上、右）
- 单词：`w`（下一个单词），`b`（单词开头），`e`（单词结尾）
- 行：`0`（行首），`^`（第一个非空白字符），`$`（行尾）
- 屏幕：`H`（屏幕顶部），`M`（屏幕中部），`L`（屏幕底部）
- 滚动：`Ctrl-u`（上），`Ctrl-d`（下）
- 文件：`gg`（文件开头），`G`（文件结尾）
- 行号：`:{number}<CR>` 或 `{number}G`（第 {number} 行）
    - `<CR>` 指的是回车/回车键
- 其他：`%`（匹配项，如括号或大括号）
- 查找：`f{character}`，`t{character}`，`F{character}`，`T{character}`
    - 在当前行上向前/向后查找/到 {character}
    - `,` / `;` 用于导航匹配项
- 搜索：`/{regex}`，`n` / `N` 用于导航匹配项

### 选择

可视模式：

- Visual: `v`
- Visual Line: `V`
- Visual Block: `Ctrl-v`

可以使用移动键进行选择。

### 编辑

你以前用鼠标做的一切，现在都用键盘通过编辑命令来完成，这些命令与移动命令组合。这就是 Vim 的接口开始看起来像一门编程语言的地方。Vim 的编辑命令也称为 "动词"，因为动词作用于名词。

- `i` 进入 Insert 模式
    - 但对于操作/删除文本，想要使用比退格键更多的东西
- `o` / `O` 在下面/上面插入行
- `d{motion}` 删除 {motion}
    - 例如 `dw` 是删除单词，`d$` 是删除到行尾，`d0` 是删除到行首
- `c{motion}` 更改 {motion}
    - 例如 `cw` 是更改单词
    - 像 `d{motion}` 后跟 `i`
- `x` 删除字符（等同于 `dl`）
- `s` 替换字符（等同于 `cl`）
- Visual 模式 + 操作
    - 选择文本，`d` 删除它或 `c` 更改它
- `u` 撤销，`<C-r>` 重做
- `y` 复制/"yank"（其他一些命令如 `d` 也会复制）
- `p` 粘贴
- 还有很多要学习：例如，`~` 翻转字符的大小写，`J` 将行连接在一起

### 计数

你可以将名词和动词与计数结合，这将执行给定动作若干次。

- `3w` 向前移动 3 个单词
- `5j` 向下移动 5 行
- `7dw` 删除 7 个单词

### 修饰符

你可以使用修饰符来改变名词的含义。一些修饰符是 `i`，意思是 "inner" 或 "inside"，以及 `a`，意思是 "around"。

- `ci(` 更改当前一对括号内的内容
- `ci[` 更改当前一对方括号内的内容
- `da'` 删除单引号字符串，包括周围的单引号

## 综合运用

这里有一个损坏的 [fizz buzz](https://en.wikipedia.org/wiki/Fizz_buzz) 实现：

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

我们使用以下命令序列来修复问题，从 Normal 模式开始：

- Main 从未被调用
    - `G` 跳转到文件末尾
    - `o` 在下方**o**pen（打开）一个新行
    - 输入 `if __name__ == "__main__": main()`
        - 如果你的编辑器有 Python 语言支持，它可能会在 Insert 模式下为你做一些自动缩进
    - `<ESC>` 返回 Normal 模式
- 从 0 开始而不是 1
    - `/` 后跟 `range` 和 `<CR>` 搜索 "range"
    - `ww` 向前移动两个**w**ords（单词）（你也可以使用 `2w`，但在实践中，对于小计数，重复按键而不是使用计数功能是很常见的）
    - `i` 切换到 **i**nsert（插入）模式，并添加 `1,`
    - `<ESC>` 返回 Normal 模式
    - `e` 跳转到下一个单词的 **e**nd（结尾）
    - `a` 开始 **a**ppending（追加）文本，并添加 `+ 1`
    - `<ESC>` 返回 Normal 模式
- 对于 5 的倍数打印 "fizz"
    - `:6<CR>` 转到第 6 行
    - `ci"` 来 **c**hange（更改）**i**nside（内部）的 '**"**'，改为 `"buzz"`
    - `<ESC>` 返回 Normal 模式

## 学习 Vim

学习 Vim 的最好方法是学习基础知识（我们到目前为止所涵盖的），然后在你所有的软件中启用 Vim 模式并开始实践使用它。避免使用鼠标或方向键的诱惑；在某些编辑器中，你可以解绑方向键来迫使自己养成良好的习惯。

### 额外资源

- 本课程之前迭代的 [Vim 讲座](/2020/editors/) --- 我们在那里更深入地介绍了 Vim
- `vimtutor` 是 Vim 附带的教程 --- 如果安装了 Vim，你应该能够从 shell 运行 `vimtutor`
- [Vim Adventures](https://vim-adventures.com/) 是一个学习 Vim 的游戏
- [Vim Tips Wiki](https://vim.fandom.com/wiki/Vim_Tips_Wiki)
- [Vim Advent Calendar](https://vimways.org/2019/) 有各种 Vim 技巧
- [VimGolf](https://www.vimgolf.com/) 是[代码高尔夫](https://en.wikipedia.org/wiki/Code_golf)，但编程语言是 Vim 的 UI
- [Vi/Vim Stack Exchange](https://vi.stackexchange.com/)
- [Vim Screencasts](http://vimcasts.org/)
- [Practical Vim](https://pragprog.com/titles/dnvim2/)（书）

[Vim]: https://www.vim.org/

# 代码智能与语言服务器

IDE 通常提供特定于语言的支持，这需要通过 IDE 扩展连接到实现[语言服务器协议](https://microsoft.github.io/language-server-protocol/)的_语言服务器_来对代码进行语义理解。例如，[VS Code 的 Python 扩展](https://marketplace.visualstudio.com/items?itemName=ms-python.python)依赖于 [Pylance](https://marketplace.visualstudio.com/items?itemName=ms-python.vscode-pylance)，[VS Code 的 Go 扩展](https://marketplace.visualstudio.com/items?itemName=golang.go)依赖于第一方的 [gopls](https://go.dev/gopls/)。通过为你使用的语言安装扩展和语言服务器，你可以在 IDE 中启用许多特定于语言的功能，例如：

- **代码补全。** 更好的自动补全和自动建议，例如能够在输入 `object.` 后看到对象的字段和方法。
- **内联文档。** 悬停和自动建议时查看文档。
- **跳转到定义。** 从使用站点跳转到定义，例如能够从字段引用 `object.field` 跳转到该字段的定义。
- **查找引用。** 上述功能的反向操作，查找特定项目（如字段或类型）被引用的所有站点。
- **导入帮助。** 组织导入、删除未使用的导入、标记缺失的导入。
- **代码质量。** 这些工具可以单独使用，但这种功能通常也由语言服务器提供。代码格式化自动缩进和自动格式化代码，类型检查器和 linter 在你输入时查找代码中的错误。我们将在[代码质量讲座](/2026/code-quality/)中更深入地介绍这类功能。

## 配置语言服务器

对于某些语言，你所需要做的就是安装扩展和语言服务器，然后就可以了。对于其他语言，为了从语言服务器获得最大收益，你需要告诉 IDE 你的环境。例如，将 VS Code 指向你的 [Python 环境](https://code.visualstudio.com/docs/python/environments)将使语言服务器能够看到你安装的包。环境在我们的[打包和发布代码讲座](/2026/shipping-code/)中有更深入的介绍。

根据语言的不同，你可能可以为语言服务器配置一些设置。例如，使用 VS Code 中的 Python 支持，你可以对不使用 Python 可选类型注解的项目禁用静态类型检查。

# AI 驱动的开发

自 2021 年中期 [GitHub Copilot][github-copilot] 使用 OpenAI 的 [Codex 模型](https://openai.com/index/openai-codex/) 推出以来，[LLMs](https://en.wikipedia.org/wiki/Large_language_model) 已在软件工程中得到广泛采用。目前有三种主要形式在使用：自动补全、内联聊天和编码代理。

[github-copilot]: https://github.com/features/copilot/ai-code-editor

## 自动补全

AI 驱动的自动补全与 IDE 中的传统自动补全具有相同的形式，在你输入时在光标位置建议补全。有时，它被用作一个"就能工作"的被动功能。除此之外，AI 自动补全通常使用代码注释进行[提示](https://en.wikipedia.org/wiki/Prompt_engineering)。

例如，让我们编写一个脚本来下载这些讲座笔记的内容并提取所有链接。我们可以从以下开始：

```python
import requests

def download_contents(url: str) -> str:
```

模型将自动补全函数的主体：

```python
    response = requests.get(url)
    return response.text
```

我们可以使用注释进一步引导补全。例如，如果我们开始编写一个提取所有 Markdown 链接的函数，但它没有一个特别具有描述性的名称：

```python
def extract(contents: str) -> list[str]:
```

模型将自动补全类似这样的内容：

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

在这里，我们看到了这个 AI 编码工具的一个缺点：它只能在光标处提供补全。在这种情况下，更好的做法是将 `import re` 放在模块级别，而不是函数内部。

上面的示例使用了一个命名不佳的函数来演示如何使用注释来引导代码补全；在实践中，你会希望编写具有更具描述性名称的函数，如 `extract_links`，并且你会希望编写文档字符串（基于此，模型应该生成类似于上面的补全）。

为了演示目的，我们可以完成脚本：

```python
print(extract(download_contents("https://raw.githubusercontent.com/missing-semester/missing-semester/refs/heads/master/_2026/development-environment.md")))
```

## 内联聊天

内联聊天让你选择一行或一块代码，然后直接提示 AI 模型提出编辑建议。在这种交互模式下，模型可以对现有代码进行更改（这与自动补全不同，后者只完成光标之外的代码）。

继续上面的示例，假设我们决定不使用第三方 `requests` 库。我们可以选择相关的三行代码，调用内联聊天，然后说类似这样的话：

```
use built-in libraries instead
```

模型建议：

```python
from urllib.request import urlopen

def download_contents(url: str) -> str:
    with urlopen(url) as response:
        return response.read().decode('utf-8')
```

## 编码代理

编码代理在 [Agentic Coding](/2026/agentic-coding/) 讲座中有深入介绍。

## 推荐软件

一些流行的 AI IDE 是带有 [GitHub Copilot][github-copilot] 扩展的 [VS Code][vs-code] 和 [Cursor](https://cursor.com/)。GitHub Copilot 目前[对学生](https://github.com/education/students)、教师以及流行开源项目的维护者免费提供。这是一个快速发展的领域。许多领先的产品具有大致相当的功能。

# 扩展和其他 IDE 功能

IDE 是强大的工具，通过_扩展_变得更加强大。我们无法在单个讲座中涵盖所有这些功能，但这里我们提供了一些流行扩展的指针。我们鼓励你自己探索这个领域；网上有许多流行的 IDE 扩展列表，例如 [Vim Awesome](https://vimawesome.com/) 用于 Vim 插件和[按流行度排序的 VS Code 扩展](https://marketplace.visualstudio.com/search?target=VSCode&category=All%20categories&sortBy=Installs)。

- [开发容器](https://containers.dev/)：受流行 IDE 支持（例如，[VS Code 支持](https://code.visualstudio.com/docs/devcontainers/containers)），开发容器让你使用容器来运行开发工具。这对于可移植性或隔离性很有帮助。[打包和发布代码讲座](/2026/shipping-code/)更深入地介绍了容器。
- 远程开发：使用 SSH 在远程机器上进行开发（例如，使用 [VS Code 的 Remote SSH 插件](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-ssh)）。这可能很方便，例如，如果你想在云中的高性能 GPU 机器上开发和运行代码。
- 协作编辑：以 Google Docs 风格编辑同一文件（例如，使用 [VS Code 的 Live Share 插件](https://marketplace.visualstudio.com/items?itemName=MS-vsliveshare.vsliveshare))。

# 练习

1. 在你使用的所有支持 Vim 模式的软件中启用 Vim 模式，例如你的编辑器和你的 shell，并在下个月内对所有文本编辑使用 Vim 模式。每当某些事情看起来效率低下，或者当你想"一定有更好的方法"时，尝试 Google 一下，可能真的有更好的方法。
1. 完成 [VimGolf](https://www.vimgolf.com/) 的一个挑战。
1. 为你正在进行的项目配置 IDE 扩展和语言服务器。确保所有预期的功能，例如库依赖项的跳转到定义，都能按预期工作。如果你没有可以用于此练习的代码，你可以使用 GitHub 上的某些开源项目（例如[这个](https://github.com/spf13/cobra)）。
1. 浏览 IDE 扩展列表并安装一个看起来对你有用的扩展。
