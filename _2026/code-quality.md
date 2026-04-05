---
layout: lecture
title: "代码质量"
description: >
  学习格式化、lint、测试、持续集成等内容。
thumbnail: /static/assets/thumbnails/2026/lec9.png
date: 2026-01-23
ready: true
video:
  aspect: 56.25
  id: XBiLUNx84CQ
---

有各种各样的工具和技术可以帮助开发者编写高质量的代码。在这节课中，我们将介绍：

- [格式化](#格式化)
- [Lint](#lint)
- [测试](#测试)
- [Pre-commit 钩子](#pre-commit-钩子)
- [持续集成](#持续集成)
- [命令运行器](#命令运行器)

作为额外主题，我们还会介绍[正则表达式](#正则表达式)。这是一个跨领域的话题，既可用于代码质量相关场景（如运行匹配某个模式的一部分测试），也可用于 IDE 等其他领域（如查找与替换）。

这些工具很多是语言特定的（如 Python 的 [Ruff](https://docs.astral.sh/ruff/) linter/formatter）。有些则支持多种语言（如代码格式化工具 [Prettier](https://prettier.io/)）。不过这些概念几乎是通用的：任何编程语言都能找到代码格式化器、linter、测试库等。

# 格式化

代码自动格式化工具会自动美化表层语法。这样你就可以专注于更深层、更有挑战性的问题，而把字符串用 `'` 还是 `"`、二元运算符两边是否留空格（`x + y` 而不是 `x+y`）、`import` 是否按序排序、避免过长行等琐碎细节交给自动格式化工具处理。代码格式化器的一个主要好处是能在整个代码库的所有开发者之间统一代码风格。

有些工具如 Prettier [高度可配置](https://prettier.io/docs/configuration)；你应该把配置文件一并提交到项目的[版本控制](/2026/version-control/)中。另一些如 [Black](https://github.com/psf/black) 和 [gofmt](https://pkg.go.dev/cmd/gofmt) 配置项有限或完全不可配置，以减少[自行车棚问题](https://en.wikipedia.org/wiki/Law_of_triviality)。

可以为代码格式化器配置 [IDE 集成](/2026/development-environment/#code-intelligence-and-language-servers)，让代码在输入时或保存文件时自动格式化。也可以在项目中加入 [EditorConfig](https://editorconfig.org/) 文件，向 IDE 传达某些项目级设置，如不同文件类型的缩进大小。

# Lint

Linter 运行静态分析（即不运行代码就分析代码），以发现反模式和潜在问题。这类工具比自动格式化器看得更深，不只关注表层语法。分析深度因工具而异。

Linter 通常内置一系列 _规则_，并提供可在项目级配置的预设。有些 linter 规则会产生误报，因此你可以按文件或按行禁用它们。

好的 linter 会自带帮助信息或文档，解释每条规则在检查什么、为什么不好、以及更好的替代方案。比如 [Ruff](https://docs.astral.sh/ruff/) 的 [SIM102](https://docs.astral.sh/ruff/rules/collapsible-if/) 规则会捕获 Python 代码中不必要的嵌套 `if` 语句。

有些 linter 不仅能标出问题，还能自动帮你修复某些问题。

除了语言特定的 linter，还有一个可能很有用的工具是 [semgrep](https://github.com/semgrep/semgrep)。它是一个“语义 grep”工具，在 AST 层面工作（而不是像 grep 那样在字符层面工作），并支持许多语言。你可以用 semgrep 很方便地为项目编写自定义 linter 规则。举例来说，如果你想阻止 Python 中危险的 `subprocess.Popen(..., shell=True)`，你可以用下面的代码模式查找它：

```bash
semgrep -l python -e "subprocess.Popen(..., shell=True, ...)"
```

# 测试

软件测试是一种提高代码正确性信心的标准技术。先写代码，再写代码去调用你写的代码；如果行为不符合预期，测试就会报错。

你可以为不同粒度的代码编写测试：针对单个函数的 _单元测试_，针对模块或服务之间交互的 _集成测试_，以及针对端到端场景的 _功能测试_。你也可以进行 _测试驱动开发_，即先写测试，再写实现代码。当你在代码中发现 bug 时，可以编写 _回归测试_，这样未来功能再次损坏时你就能捕获到。你还可以编写 _基于性质的测试_，它由 Haskell 中的 [QuickCheck](https://hackage.haskell.org/package/QuickCheck) 开创，并在许多库中得到实现，例如 Python 的 [Hypothesis](https://hypothesis.readthedocs.io/)。哪种测试方式适合你，取决于你的项目；很可能你会采用其中若干种的组合。

如果程序依赖数据库或 Web API 等外部依赖，在测试中 _模拟（mock）_ 这些依赖往往有帮助，而不是真的与第三方交互。

## 代码覆盖率

代码覆盖率是衡量测试质量的指标。它关注测试运行时哪些代码行被执行到了，帮你确认覆盖了所有代码路径。代码覆盖率工具可以按行显示覆盖情况，指导你编写测试。像 [Codecov](https://app.codecov.io) 这样的服务提供 Web 界面，跟踪和查看项目历史中的覆盖率。

和任何指标一样，代码覆盖率也并不完美；不要过度关注覆盖率，更重要的是编写高质量的测试。

# Pre-commit 钩子

Git 的 pre-commit [钩子](https://git-scm.com/book/en/v2/Customizing-Git-Git-Hooks) 在 [pre-commit](https://pre-commit.com/) 框架的帮助下更容易使用，它会在每次 Git 提交前自动运行指定代码。项目通常利用 pre-commit 钩子在提交前自动运行格式化器、linter，有时也运行测试，确保提交的代码符合项目风格且没有某些问题。

# 持续集成

[GitHub Actions](https://github.com/features/actions) 这样的持续集成（CI, Continuous Integration）服务可以在你每次推送代码时（或每次 pull request 时，或按计划）运行脚本。开发者通常用 CI 运行各种代码质量工具，包括格式化器、linter 和测试。编译型语言可以确保代码能编译；静态类型语言可以确保类型检查通过。每次推送新提交时运行 CI 能捕获引入主分支的错误；在 pull request 上运行能发现贡献者提交中的问题；按计划运行能发现外部依赖的问题（比如某个开发者意外发布了一个与 [semver-compatible](/2026/shipping-code/#releases--versioning) 声称兼容但实际破坏行为的变更）。

由于 CI 脚本在开发者机器之外独立运行，方便运行耗时较长的任务。比如在不同操作系统和不同编程语言版本上运行测试 _矩阵_，确保软件在所有环境中都能正常工作。

一般来说，CI 中运行的脚本不会直接修改代码：通常以”只检查”模式运行工具，比如代码不符合格式要求时自动格式化器会报错，而不是直接改动代码。

代码仓库通常在 README 中包含[状态徽章](https://docs.github.com/en/actions/how-tos/monitor-workflows/add-a-status-badge)，展示 CI 状态及代码覆盖率等信息。下面就是 Missing Semester 当前的构建状态。

[![Build Status](https://github.com/missing-semester/missing-semester/actions/workflows/build.yml/badge.svg)](https://github.com/missing-semester/missing-semester/actions/workflows/build.yml) [![Links Status](https://github.com/missing-semester/missing-semester/actions/workflows/links.yml/badge.svg)](https://github.com/missing-semester/missing-semester/actions/workflows/links.yml)

> 我们的[链接检查器](https://github.com/missing-semester/missing-semester/blob/master/.github/workflows/links.yml)使用 [proof-html](https://github.com/anishathalye/proof-html) GitHub Action，它经常失败，通常是因为第三方网站出了问题。即便如此，它仍然帮助我们发现并修复了许多失效链接（有时是因为拼写错误，但更多时候是因为网站在没有加重定向的情况下移动了内容，或者网站直接消失了）。

学习 CI 服务、格式化器、linter 和测试库具体细节的好方法是通过示例。去 GitHub 上找高质量的开源项目来研究，越接近你的项目越好——比如编程语言、领域、规模和范围等都越相似越好——研究它们的 `pyproject.toml`、`.github/workflows/`、`DEVELOPMENT.md` 等相关文件。

## 持续部署

持续部署利用 CI 基础设施来真正 _部署_ 变更。比如 Missing Semester 仓库就用持续部署到 GitHub Pages，每次 `git push` 更新后的讲义时，网站自动构建并部署。你也可以在 CI 中构建其他类型的[产物](/2026/shipping-code/)，比如应用程序二进制文件或服务的 Docker 镜像。

# 命令运行器

像 [just](https://github.com/casey/just) 这样的命令运行器，可以简化在项目上下文中运行命令这件事。随着项目逐步建立起代码质量基础设施，你不会想让开发者去记住 `uv run ruff check --fix` 这样的命令。有了命令运行器，这就可以变成 `just lint`，同时你还可以为各种工具提供类似的调用方式，比如 `just format`、`just typecheck` 等。

有些语言特定的项目或包管理器已内置了这类功能，不需要用像 `just` 这样与语言无关的工具。比如 [npm](https://nodejs.org/en/learn/getting-started/an-introduction-to-the-npm-package-manager)（Node.js）的 `package.json` 中的 `scripts` 部分，以及 [Hatch](https://hatch.pypa.io/)（Python）的 `pyproject.toml` 中 `tool.hatch.envs.*.scripts` 相关部分都支持。

# 正则表达式

_正则表达式_，通常缩写为 “regex”，是一种用来表示字符串集合的语言。Regex 模式常被用于各种场景中的模式匹配，例如命令行工具和 IDE。比如，[ag](https://github.com/ggreer/the_silver_searcher) 支持用 regex 模式做整个代码库范围的搜索（例如，`ag "import .* as .*"` 会找出 Python 中所有重命名导入），而 [go test](https://pkg.go.dev/cmd/go#hdr-Test_packages) 支持 `-run [regexp]` 选项来选择测试的一个子集。此外，编程语言通常内置了正则表达式支持，或者有第三方库可用，因此你可以用 regex 来实现模式匹配、校验和解析等功能。

为了帮助建立直觉，下面给出一些 regex 示例。本讲使用 [Python regex 语法](https://docs.python.org/3/library/re.html)。Regex 有很多不同「风味」，之间存在细微差异，尤其在更高级的功能上。可以用 [regex101](https://regex101.com/) 这样的在线工具来开发和调试正则表达式。

- `abc` --- 匹配字面量字符串 “abc”。
- `missing|semester` --- 匹配字符串 “missing” 或字符串 “semester”。
- `\d{4}-\d{2}-\d{2}` --- 匹配 YYYY-MM-DD 格式的日期，例如 “2026-01-14”。除了保证字符串由四位数字、一个连字符、两位数字、一个连字符以及两位数字组成之外，它并不会验证这个日期是否合法，因此 “2026-01-99” 也会匹配这个 regex 模式。
- `.+@.+` --- 匹配电子邮件地址，也就是包含一些文本、接着一个 “@”、然后再跟一些文本的字符串。这只做了最基础的校验，因此像 “nonsense@@@email” 这样的字符串也会匹配。一个对电子邮件地址既无误报也无漏报的 regex [确实存在](https://pdw.ex-parrot.com/Mail-RFC822-Address.html)，但并不实用。

## Regex 语法

完整的 regex 语法指南可以在[这份文档](https://docs.python.org/3/library/re.html#regular-expression-syntax)或网上很多其他资源中找到。下面是一些基本构件：

- `abc` 在字符没有特殊含义时匹配该字面量字符串（本例中为 “abc”）
- `.` 匹配任意单个字符
- `[abc]` 匹配方括号中包含的任意一个字符（本例中为 “a”、“b” 或 “c”）
- `[^abc]` 匹配除方括号中字符之外的任意一个字符（例如 “d”）
- `[a-f]` 匹配方括号中所示范围内的任意一个字符（例如 “c”，但不包括 “q”）
- `a|b` 匹配任一模式（例如 “a” 或 “b”）
- `\d` 匹配任意数字字符（例如 “3”）
- `\w` 匹配任意单词字符（例如 “x”）
- `\b` 匹配任意单词 _边界_（例如，在字符串 “missing semester” 中，会匹配 “m” 前面、“g” 后面、“s” 前面以及 “r” 后面的位置）
- `(...)` 匹配一个模式组
- `...?` 匹配零个或一个模式，例如 `words?` 可匹配 “word” 或 “words”
- `...*` 匹配任意数量的某个模式，例如 `.*` 可匹配任意数量的任意字符
- `...+` 匹配一个或多个某个模式，例如 `\d+` 可匹配非零个数字
- `...{N}` 精确匹配 N 个某个模式，例如 `\d{4}` 表示 4 位数字
- `\.` 匹配字面量 “.”
- `\\` 匹配字面量 “\\”
- `^` 匹配行首
- `$` 匹配行尾

## 捕获组与引用

如果你使用 regex 分组 `(...)`，你就可以引用匹配结果中的子部分，以便提取或进行查找替换。例如，如果想从 YYYY-MM-DD 形式的日期中只提取月份，可以使用下面这段 Python 代码：

```python
>>> import re
>>> re.match(r"\d{4}-(\d{2})-\d{2}", "2026-01-14").group(1)
'01'
```

在文本编辑器中，你可以在替换模式里使用对捕获组的引用。具体语法在不同 IDE 中可能不同。例如，在 VS Code 中，你可以使用 `$1`、`$2` 等变量，而在 Vim 中，你可以使用 `\1`、`\2` 等来引用分组。

## 局限性

[正则语言](https://en.wikipedia.org/wiki/Regular_language)很强大但也有局限，有些字符串类别无法用标准 regex 表达（比如[不可能](https://en.wikipedia.org/wiki/Pumping_lemma_for_regular_languages)写出一个正则表达式来匹配集合 {a^n b^n | n >= 0}，即若干个 “a” 后面跟相同数量的 “b”；更实际地说，HTML 也不是正则语言）。实践中，现代 regex 引擎支持前瞻、反向引用等特性，能力已超出正则语言；它们在实际中极其有用，但了解其表达能力的有限性仍然重要。对于更复杂的语言，可能需要更强的解析器（如 [pyparsing](https://github.com/pyparsing/pyparsing)，一种 [PEG](https://en.wikipedia.org/wiki/Parsing_expression_grammar) 解析器）。

## 学习 regex

建议先学基础知识（即本讲覆盖的内容），然后在需要时查阅 regex 参考资料，而不是试图把整门语言都背下来。

对话式 AI 工具在帮你生成 regex 模式方面也可能很有效。比如可以尝试向 LLM 提交下面这个问题：

```
编写一个 Python 风格的正则表达式模式，该模式与 Nginx 日志行中请求的路径相匹配。这是一个示例日志行：

169.254.1.1 - - [09/Jan/2026:21:28:51 +0000] "GET /feed.xml HTTP/2.0" 200 2995 "-" "python-requests/2.32.3"
```

# 练习

1. 为你正在进行的一个项目配置格式化器、linter 和 pre-commit 钩子。如果你有很多错误：自动格式化应当能够处理格式错误。对于 linter 错误，试着使用一个 [AI agent](/2026/agentic-coding/) 来修复所有 linter 错误。确保这个 AI agent 能运行 linter 并观察结果，这样它就可以在迭代循环中修复所有问题。仔细检查结果，确保 AI 没有破坏你的代码！
1. 学习一种你熟悉语言的测试库，并为你正在进行的一个项目编写一个单元测试。运行代码覆盖率工具，生成 HTML 格式的覆盖率报告，并观察结果。你能找到哪些行被覆盖了吗？你的代码覆盖率很可能会很低。尝试手动编写一些测试来改进它。也试着使用一个 [AI agent](/2026/agentic-coding/) 来提高覆盖率；确保这个 coding agent 能以带覆盖率的方式运行测试，并生成逐行覆盖率报告，这样它才知道该聚焦在哪里。AI 生成的测试真的好吗？
1. 为你正在进行的一个项目设置持续集成，并让它在每次 push 时运行。让 CI 运行格式化、lint 和测试。故意把你的代码弄坏（例如，引入一条 linter 违规），并确认 CI 能抓到它。
1. 试着写一个[正则表达式](#正则表达式)，并使用 `grep` [命令行工具](/2026/course-shell/) 在你的代码中查找 `subprocess.Popen(..., shell=True)` 的出现位置。然后，试着“破坏”这个 regex 模式。[semgrep](#lint) 是否仍然能成功匹配到那些会让你的 grep 调用失效的危险代码？
1. 在你的 IDE 或文本编辑器里练习 regex 查找替换，把[这些讲义](https://raw.githubusercontent.com/missing-semester/missing-semester/refs/heads/master/_2026/code-quality.md)中的 `-` [Markdown 项目符号标记](https://spec.commonmark.org/0.31.2/#bullet-list-marker)替换为 `*` 项目符号标记。注意，直接替换文件中所有的 `-` 字符是不正确的，因为该字符在文件中还有很多并非项目符号标记的用途。
1. 写一个 regex，从形如 `{"name": "Alyssa P. Hacker", "college": "MIT"}` 的 JSON 结构中捕获 name（例如本例中的 `Alyssa P. Hacker`）。提示：在第一次尝试时，你可能最终会写出一个提取 `Alyssa P. Hacker", "college": "MIT` 的 regex；读一读 [Python regex 文档](https://docs.python.org/3/library/re.html)中关于贪婪量词的内容，弄清楚如何修复它。
    1. 让这个 regex 模式在 name 中包含 `"` 字符时也能工作（在 JSON 中，双引号可以用 `\"` 转义）。
    1. 在实践中，我们 **不** 推荐用正则表达式解决复杂解析问题。弄清楚如何用你所使用编程语言的 JSON 解析器来完成这个任务。写一个命令行程序，从标准输入读取上述形式的 JSON 结构，并把 name 输出到标准输出。你应该只需要几行代码就能完成。在 Python 中，除了 `import json` 之外，一行代码就可以轻松做到。
