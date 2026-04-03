---
layout: lecture
title: "开发环境与工具"
description: >
  学习 IDE、Vim、语言服务器以及 AI 驱动的开发工具。
thumbnail: /static/assets/thumbnails/2026/lec3.png
date: 2026-01-14
ready: true
video:
  aspect: 56.25
  id: QnM1nVzrkx8
---

_开发环境_ 是一组用于开发软件的工具。开发环境的核心是文本编辑功能，以及配套的语法高亮、类型检查、代码格式化和自动补全等特性。像 [VS Code][vs-code] 这样的 _集成开发环境_（IDE）会把这些功能整合到一个应用中。基于终端的开发工作流则会把 [tmux](https://github.com/tmux/tmux)（终端复用器）、[Vim](https://www.vim.org/)（文本编辑器）、[Zsh](https://www.zsh.org/)（一种 Shell），以及语言特定的命令行工具组合在一起，例如 [Ruff](https://docs.astral.sh/ruff/)（Python 的 linter 和代码格式化工具）和 [Mypy](https://mypy-lang.org/)（Python 的类型检查器）。

IDE 和基于终端的工作流各有优劣。比如，图形化 IDE 往往更容易上手，而且如今的 IDE 一般也有更完善的开箱即用 AI 集成能力，例如 AI 自动补全；另一方面，基于终端的工作流更轻量，在没有 GUI 或无法安装软件的环境里，它们甚至可能是你唯一的选择。我们建议你对两者都建立基本熟悉度，并至少精通其中一种。如果你现在还没有偏好的 IDE，我们建议从 [VS Code][vs-code] 开始。

在这节课中，我们将介绍：

- [文本编辑与 Vim](#text-editing-and-vim)
- [代码智能与语言服务器](#code-intelligence-and-language-servers)
- [AI 驱动的开发](#ai-powered-development)
- [扩展与 IDE 的其他功能](#extensions-and-other-ide-functionality)

[vs-code]: https://code.visualstudio.com/

# 文本编辑与 Vim {#text-editing-and-vim}

编程时，你的大部分时间都花在代码间导航、阅读代码片段和修改代码上，而不是长时间连续输入，或者从头到尾线性地通读文件。[Vim] 正是针对这种任务分布而优化的文本编辑器。

**Vim 的哲学。** Vim 建立在一个非常优美的想法之上：它的界面本身就是一种用于导航和编辑文本的编程语言。按键操作（并带有助记名）就是命令，而这些命令是可以组合的。Vim 避免使用鼠标，因为鼠标太慢了；Vim 甚至避免使用方向键，因为那需要太多手部移动。结果就是：这个编辑器会让人感觉像在使用脑机接口一样，速度能跟上你的思维。

**其他软件中的 Vim 支持。** 你不必真的使用 [Vim] 本体，也能从它的核心思想中受益。许多涉及文本编辑的软件都支持 “Vim mode”，要么是内建功能，要么是插件。例如，VS Code 有 [VSCodeVim](https://marketplace.visualstudio.com/items?itemName=vscodevim.vim) 插件，Zsh 内建了 [Vim 模拟支持](https://zsh.sourceforge.io/Guide/zshguide04.html)，就连 Claude Code 也内建了 [Vim 编辑模式](https://code.claude.com/docs/en/interactive-mode#vim-editor-mode)。你几乎可以认为，任何涉及文本编辑的工具，多少都会以某种方式支持 Vim mode。

## 模态编辑 {#modal-editing}

Vim 是一个 _模态编辑器_：它针对不同类别的任务提供不同的工作模式。

- **正常模式**：用于在文件中移动和进行编辑
- **插入模式**：用于插入文本
- **替换模式**：用于替换文本
- **可视化模式**（普通、行或块）：用于选择文本块
- **命令模式**：用于运行命令

在不同操作模式下，按键的含义也不同。比如，字母 `x` 在插入模式下只会插入字面字符 `x`，但在正常模式下，它会删除光标所在字符，而在可视化模式下，它会删除当前选区。

在默认配置下，Vim 会在左下角显示当前模式。初始/默认模式是正常模式。通常你会把大多数时间花在正常模式和插入模式之间切换。

你可以通过按 `<ESC>`（Escape 键）从任意模式返回正常模式。在正常模式下，按 `i` 进入插入模式，按 `R` 进入替换模式，按 `v` 进入可视化模式，按 `V` 进入可视化行模式，按 `<C-v>`（Ctrl-V，有时也写作 `^V`）进入可视化块模式，按 `:` 进入命令模式。

使用 Vim 时你会频繁按 `<ESC>`：可以考虑把 Caps Lock 重映射为 Escape（[macOS 教程](https://vim.fandom.com/wiki/Map_caps_lock_to_escape_in_macOS)），或者为 `<ESC>` 设置一个由简单按键序列触发的[替代映射](https://vim.fandom.com/wiki/Avoid_the_escape_key#Mappings)。

## 基础：插入文本 {#basics-inserting-text}

在正常模式下，按 `i` 进入插入模式。此时 Vim 的行为就和其他文本编辑器差不多，直到你按下 `<ESC>` 返回正常模式。只要掌握这一点，再加上前面提到的基础知识，你就已经可以开始用 Vim 编辑文件了。当然，如果你总是停留在插入模式中，效率并不会特别高。

## Vim 的界面本身是一种编程语言 {#vims-interface-is-a-programming-language}

Vim 的界面本身就是一种编程语言。按键操作（带有助记名）就是命令，而这些命令是可以 _组合_ 的。这让移动和编辑都能非常高效，尤其是当这些命令变成肌肉记忆之后，就像你熟悉了键盘布局后，打字也会变得非常高效一样。

### 移动 {#movement}

你应该把大多数时间花在正常模式中，使用移动命令在文件里导航。在 Vim 中，移动命令也被称为 “名词（nouns）”，因为它们指向的是一段文本。

- 基础移动：`hjkl`（左、下、上、右）
- 单词：`w`（下一个单词）、`b`（单词开头）、`e`（单词结尾）
- 行：`0`（行首）、`^`（第一个非空白字符）、`$`（行尾）
- 屏幕：`H`（屏幕顶部）、`M`（屏幕中间）、`L`（屏幕底部）
- 滚动：`Ctrl-u`（向上）、`Ctrl-d`（向下）
- 文件：`gg`（文件开头）、`G`（文件结尾）
- 行号：`:{number}<CR>` 或 `{number}G`（第 {number} 行）
    - `<CR>` 指的是回车 / Enter 键
- 其他：`%`（匹配项，例如括号或花括号）
- 查找：`f{character}`、`t{character}`、`F{character}`、`T{character}`
    - 在当前行内向前/向后查找或跳到 {character}
    - 使用 `,` / `;` 在匹配之间导航
- 搜索：`/{regex}`，使用 `n` / `N` 在匹配之间导航

### 选择 {#selection}

可视化模式包括：

- 可视化：`v`
- 可视化行：`V`
- 可视化块：`Ctrl-v`

你可以使用移动键来扩展选择范围。

### 编辑 {#edits}

你过去用鼠标完成的事情，现在都可以通过键盘上的编辑命令配合移动命令来完成。到了这里，Vim 的界面就开始真正像一门编程语言了。Vim 的编辑命令也被称为 “动词（verbs）”，因为动词作用于名词。

- `i` 进入插入模式
    - 但如果是操作/删除文本，通常你会想用比退格键更强的东西
- `o` / `O` 在下方 / 上方插入一行
- `d{motion}` 删除 {motion}
    - 例如，`dw` 是删除一个单词，`d$` 是删除到行尾，`d0` 是删除到行首
- `c{motion}` 修改 {motion}
    - 例如，`cw` 是修改一个单词
    - 相当于 `d{motion}` 后接 `i`
- `x` 删除字符（等价于 `dl`）
- `s` 替换字符（等价于 `cl`）
- 可视化模式 + 操作
    - 选中文本后，按 `d` 删除，或按 `c` 修改
- `u` 撤销，`<C-r>` 重做
- `y` 复制 / “yank”（有些其他命令，例如 `d`，也会复制）
- `p` 粘贴
- 还有很多要学：例如，`~` 可以切换字符大小写，`J` 可以把多行连接起来

### 计数 {#counts}

你可以给名词和动词加上计数，从而把某个动作执行多次。

- `3w` 向前移动 3 个单词
- `5j` 向下移动 5 行
- `7dw` 删除 7 个单词

### 修饰符 {#modifiers}

你可以使用修饰符来改变名词的含义。有些修饰符是 `i`，表示 “inner” 或 “inside”；还有 `a`，表示 “around”。

- `ci(` 修改当前这对圆括号内部的内容
- `ci[` 修改当前这对方括号内部的内容
- `da'` 删除一个单引号字符串，包括两侧的单引号

## 综合起来看 {#putting-it-all-together}

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

我们从正常模式开始，使用下面这一串命令来修复这些问题：

- `main` 从未被调用
    - `G` 跳到文件末尾
    - `o` 在下方 **o**pen 一个新行
    - 输入 `if __name__ == "__main__": main()`
        - 如果你的编辑器支持 Python 语言功能，它可能会在插入模式里为你自动缩进
    - `<ESC>` 回到正常模式
- 从 0 开始而不是从 1 开始
    - 输入 `/`，然后键入 `range` 和 `<CR>`，搜索 “range”
    - `ww` 向前移动两个 **w**ord（你也可以用 `2w`，但在实践中，对于较小的次数，重复按键往往比使用计数功能更常见）
    - `i` 切换到 **i**nsert 模式，并添加 `1,`
    - `<ESC>` 回到正常模式
    - `e` 跳到下一个单词的 **e**nd
    - `a` 开始 **a**ppend 文本，并添加 `+ 1`
    - `<ESC>` 回到正常模式
- 对 5 的倍数打印的是 `"fizz"`
    - `:6<CR>` 跳到第 6 行
    - `ci"` **c**hange **i**nside 这个 `"` 内部的内容，把它改成 `"buzz"`
    - `<ESC>` 回到正常模式

## 学习 Vim {#learning-vim}

学习 Vim 最好的方式，就是先掌握基础（也就是我们目前讲过的这些内容），然后在你使用的所有软件里都启用 Vim mode，并在实践中真正去用它。别总想去用鼠标或方向键；在一些编辑器里，你甚至可以直接解绑方向键，强迫自己养成更好的习惯。

### 更多资源 {#additional-resources}

- 本课程上一轮迭代中的 [Vim 讲义](/2020/editors/)；我们在那里更深入地讲解了 Vim
- `vimtutor` 是随 Vim 一起安装的教程；如果装了 Vim，你应该可以直接在 Shell 里运行 `vimtutor`
- [Vim Adventures](https://vim-adventures.com/) 是一个学习 Vim 的游戏
- [Vim Tips Wiki](https://vim.fandom.com/wiki/Vim_Tips_Wiki)
- [Vim Advent Calendar](https://vimways.org/2019/) 收录了各种 Vim 小技巧
- [VimGolf](https://www.vimgolf.com/) 是一种 [code golf](https://en.wikipedia.org/wiki/Code_golf)，只不过这里的“编程语言”是 Vim 的界面
- [Vi/Vim Stack Exchange](https://vi.stackexchange.com/)
- [Vim Screencasts](http://vimcasts.org/)
- [Practical Vim](https://pragprog.com/titles/dnvim2/)（书）

[Vim]: https://www.vim.org/

# 代码智能与语言服务器 {#code-intelligence-and-language-servers}

IDE 通常会通过扩展提供语言特定支持，而这些功能需要对代码有语义级理解；这些扩展会连接实现了 [Language Server Protocol](https://microsoft.github.io/language-server-protocol/) 的 _语言服务器_（language servers）。例如，[VS Code 的 Python 扩展](https://marketplace.visualstudio.com/items?itemName=ms-python.python)依赖 [Pylance](https://marketplace.visualstudio.com/items?itemName=ms-python.vscode-pylance)，而 [VS Code 的 Go 扩展](https://marketplace.visualstudio.com/items?itemName=golang.go)依赖官方的 [gopls](https://go.dev/gopls/)。只要为你使用的语言安装对应的扩展和语言服务器，就可以在 IDE 中启用许多语言特定功能，例如：

- **代码补全。** 更强的自动补全和自动建议，例如在输入 `object.` 后能看到对象的字段和方法。
- **内联文档。** 在悬停提示和自动建议里查看文档。
- **跳转到定义。** 从使用位置跳转到定义位置，例如从字段引用 `object.field` 跳到该字段的定义。
- **查找引用。** 和上面相反，查找某个条目（例如字段或类型）被引用的所有位置。
- **导入辅助。** 整理 imports、移除未使用 imports、标记缺失 imports。
- **代码质量。** 这些工具可以单独使用，但这类能力通常也由语言服务器提供。代码格式化会在你输入时自动缩进和整理格式，而类型检查器与 linter 会在你输入时发现代码中的错误。我们会在[代码质量](/2026/code-quality/)一讲中更深入地介绍这类功能。

## 配置语言服务器 {#configuring-language-servers}

对于某些语言，你只需要安装扩展和语言服务器，就万事俱备了。对另一些语言来说，若想把语言服务器的价值发挥到最大，你还需要告诉 IDE 你的环境信息。比如，让 VS Code 指向你的 [Python 环境](https://code.visualstudio.com/docs/python/environments)，就能让语言服务器看到你已安装的包。关于环境，我们会在[代码打包与发布](/2026/shipping-code/)一讲中更详细地介绍。

根据不同语言，你还可以为语言服务器配置一些设置。例如，在 VS Code 中使用 Python 支持时，你可以为那些没有使用 Python 可选类型注解的项目禁用静态类型检查。

# AI 驱动的开发 {#ai-powered-development}

自 2021 年中 [GitHub Copilot][github-copilot] 引入 OpenAI 的 [Codex 模型](https://openai.com/index/openai-codex/) 以来，[大型语言模型（LLMs）](https://en.wikipedia.org/wiki/Large_language_model) 已被广泛应用于软件工程。目前主要有三种形态：自动补全、内联聊天和编程代理。

[github-copilot]: https://github.com/features/copilot/ai-code-editor

## 自动补全 {#autocomplete}

AI 驱动的自动补全在形态上与 IDE 中传统的自动补全类似：当你输入时，它会在光标位置给出补全建议。有时，它会作为一种“开箱即用”的被动能力存在。除此之外，AI 自动补全通常还可以通过代码注释来进行[提示](https://en.wikipedia.org/wiki/Prompt_engineering)。

例如，假设我们要写一个脚本，下载这些讲义的内容并提取其中所有链接。我们可以从下面开始：

```python
import requests

def download_contents(url: str) -> str:
```

模型会自动补全这个函数体：

```python
    response = requests.get(url)
    return response.text
```

我们还可以通过注释进一步引导补全。例如，如果我们开始写一个提取所有 Markdown 链接的函数，但函数名并不特别具有描述性：

```python
def extract(contents: str) -> list[str]:
```

模型可能会补全成这样：

```python
    lines = contents.splitlines()
    return [line for line in lines if line.strip()]
```

我们可以通过代码注释来引导补全：

```python
def extract(content: str) -> list[str]:
    # 从内容中提取所有 Markdown 链接
```

这一次，模型会给出更好的补全：

```python
    import re
    pattern = r'\[.*?\]\((.*?)\)'
    return re.findall(pattern, content)
```

这里我们可以看到这种 AI 编程工具的一个缺点：它只能在光标所在位置给出补全。在这个例子里，更好的实践应该是把 `import re` 放在模块层级，而不是函数内部。

上面的例子故意用了一个命名很差的函数，来演示如何通过注释引导代码补全；在实际中，你当然会希望把函数命名得更清楚一些，例如 `extract_links`，也会希望写上 docstring（在这种情况下，模型也应该生成与上面类似的补全）。

为了演示，我们可以把脚本补完整：

```python
print(extract(download_contents("https://raw.githubusercontent.com/missing-semester/missing-semester/refs/heads/master/_2026/development-environment.md")))
```

## 内联聊天 {#inline-chat}

内联聊天允许你选中一行或一段代码，然后直接向 AI 模型发出提示，让它提出编辑建议。在这种交互模式下，模型可以修改现有代码（这点不同于自动补全，后者只能补全光标之后的代码）。

继续前面的例子，假设我们决定不使用第三方 `requests` 库。我们可以选中相关的三行代码，调用内联聊天，并输入类似下面这样的提示：

```
改用内置库
```

模型会提出这样的修改：

```python
from urllib.request import urlopen

def download_contents(url: str) -> str:
    with urlopen(url) as response:
        return response.read().decode('utf-8')
```

## 编程代理 {#coding-agents}

我们会在[Agentic Coding](/2026/agentic-coding/)一讲中深入介绍编程代理。

## 推荐软件 {#recommended-software}

一些流行的 AI IDE 包括带有 [GitHub Copilot][github-copilot] 扩展的 [VS Code][vs-code]，以及 [Cursor](https://cursor.com/)。GitHub Copilot 目前对学生、教师以及热门开源项目的维护者提供[免费使用](https://github.com/education/students)。这是一个变化非常快的领域。许多头部产品的功能其实大致相当。

# 扩展与 IDE 的其他功能 {#extensions-and-other-ide-functionality}

IDE 本身已经是很强大的工具，而 _扩展_ 会让它们更加强大。我们不可能在一节课里覆盖所有这些功能，但这里会先给出几个常见扩展的线索。我们鼓励你自己继续探索这一空间；网上有很多 IDE 热门扩展清单，例如针对 Vim 插件的 [Vim Awesome](https://vimawesome.com/)，以及[按安装量排序的 VS Code 扩展列表](https://marketplace.visualstudio.com/search?target=VSCode&category=All%20categories&sortBy=Installs)。

- [Development containers](https://containers.dev/)：主流 IDE 都支持它们（例如 [VS Code 就支持](https://code.visualstudio.com/docs/devcontainers/containers)）。dev containers 让你可以使用容器来运行开发工具，这对可移植性或隔离性都很有帮助。我们会在[代码打包与发布](/2026/shipping-code/)一讲中更深入地介绍容器。
- 远程开发：通过 SSH 在远程机器上进行开发（例如使用 [VS Code 的 Remote SSH 插件](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-ssh)）。例如，如果你想在云上一台性能很强的 GPU 机器上开发和运行代码，这会非常方便。
- 协作编辑：像 Google Docs 一样编辑同一个文件（例如使用 [VS Code 的 Live Share 插件](https://marketplace.visualstudio.com/items?itemName=MS-vsliveshare.vsliveshare)）。

# 练习 {#exercises}

1. 在你使用的所有支持 Vim mode 的软件中启用 Vim 模式，例如编辑器和 Shell，并在接下来一个月里把所有文本编辑都用 Vim 模式完成。每当你觉得哪里低效，或者想到“肯定有更好的办法”时，就去 Google 一下，通常真的有更好的办法。
1. 完成一道 [VimGolf](https://www.vimgolf.com/) 挑战。
1. 为你正在做的一个项目配置 IDE 扩展和语言服务器。确保所有预期功能都能正常工作，例如对库依赖进行跳转到定义。如果你手头没有可用于这个练习的代码，也可以从 GitHub 上找一个开源项目来用（例如[这个](https://github.com/spf13/cobra)）。
1. 浏览一份 IDE 扩展列表，安装一个看起来对你有用的扩展。
