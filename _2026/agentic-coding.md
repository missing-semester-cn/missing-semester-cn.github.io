---
layout: lecture
title: "Agentic Coding"
description: >
  学习如何有效地使用 AI 编程代理完成软件开发任务。
thumbnail: /static/assets/thumbnails/2026/lec7.png
date: 2026-01-21
ready: true
video:
  aspect: 56.25
  id: sTdz6PZoAnw
---

编程代理是一种具有工具访问能力的对话式 AI 模型，这些工具包括读写文件、网页搜索和执行 Shell 命令等。它们可以运行在 IDE 中，也可以作为独立的命令行或 GUI 工具使用。编程代理是高度自主且功能强大的工具，能够支持广泛的应用场景。

本节课在[开发环境与工具](/2026/development-environment/)课程中 AI 辅助开发内容的基础上展开。作为快速演示，让我们继续使用[AI 辅助开发](/2026/development-environment/#ai-powered-development)一节中的示例：

```python
from urllib.request import urlopen

def download_contents(url: str) -> str:
    with urlopen(url) as response:
        return response.read().decode('utf-8')

def extract(content: str) -> list[str]:
    import re
    pattern = r'\[.*?\]\((.*?)\)'
    return re.findall(pattern, content)

print(extract(download_contents("https://raw.githubusercontent.com/missing-semester/missing-semester/refs/heads/master/_2026/development-environment.md")))
```

我们可以尝试向编程代理发出以下任务：

```
将这段代码改写为一个正规的命令行程序，使用 argparse 进行参数解析。添加类型注解，并确保程序通过类型检查。
```

代理会先阅读文件来理解代码，然后进行一些编辑，最后调用类型检查器来确保类型注解正确。如果它犯了导致类型检查失败的错误，很可能会自动迭代修正——不过这是一个简单的任务，不太可能出现这种情况。由于编程代理可以访问可能具有危害性的工具，因此默认情况下，代理框架会提示用户确认工具调用。

> 如果编程代理犯了错误——例如，你的 `mypy` 可执行文件直接在 `$PATH` 中可用，但代理却尝试使用 `python -m mypy`——你可以通过文字反馈来帮助它纠正方向。

编程代理支持多轮交互，因此你可以通过与代理的来回对话不断迭代工作。如果代理走错了方向，你甚至可以中断它。一个有用的心智模型是把它当作管理一个实习生：实习生会做那些繁琐的工作，但需要你的指导，偶尔也会做错事并需要纠正。

> 为了获得更直观的演示，你可以作为后续任务让代理运行生成的脚本。观察输出结果，然后尝试让它做些修改（例如，要求它只保留绝对 URL）。

# AI 模型和代理的工作原理

全面解释现代[大语言模型 (LLM)](https://en.wikipedia.org/wiki/Large_language_model)以及代理框架等基础设施的内部原理超出了本课程的范围。然而，对一些关键概念建立高层次的理解，有助于有效地*使用*这项前沿技术并理解其局限性。

LLM 可以被看作是对给定提示字符串（输入）的补全字符串（输出）概率分布进行建模。LLM 推理（即当你向对话聊天应用提交查询时发生的事情）会从这个概率分布中进行*采样*。LLM 具有固定的*上下文窗口*，即输入和输出字符串的最大长度。

{% comment %}
> 用数学符号表示，LLM 建模的是条件概率分布 $\pi_\theta$，即在提示 $x$ 下补全 $y$ 的概率分布，我们从中采样：$\hat{y} \sim \pi_\theta(\cdot \mid x)$。
{% endcomment %}

诸如对话聊天和编程代理等 AI 工具都是建立在这个基础原语之上的。对于多轮交互，聊天应用和代理使用回合标记，并在每次有新的用户提示时将整个对话历史作为提示字符串提供，每次用户提示调用一次 LLM 推理。对于工具调用代理，框架会将特定的 LLM 输出解释为工具调用请求，并将工具调用的结果作为提示字符串的一部分反馈给模型（因此每次工具调用/响应都会再次运行 LLM 推理）。工具调用代理的核心概念可以用[200 行代码实现](https://www.mihaileric.com/The-Emperor-Has-No-Clothes/)。

## 隐私

大多数 AI 编程工具在其标准配置下会将大量数据发送到云端。有时框架在本地运行，而 LLM 推理在云端运行；有时甚至更多的软件都在云端运行（例如，服务提供商可能会有效地获取你的整个代码库副本以及你与 AI 工具的所有交互记录）。

目前已经有一些相当不错的开源 AI 编程工具和开源 LLM（虽然还不及专有模型），但就目前而言，由于硬件限制，大多数用户在本地运行最前沿的开源 LLM 是不现实的。

# 应用场景

编程代理在各种各样的任务中都能发挥作用。以下是一些示例：

- **实现新功能。** 就像上面的示例一样，你可以要求编程代理实现一个功能。如何给出好的规范说明，目前与其说是科学不如说是艺术——你希望给代理的输入足够描述性，以便代理能按你的意图执行（至少方向正确，以便你迭代改进），但又不要过于详细，以至于你自己做了太多工作。测试驱动开发特别有效：编写测试（或使用编程代理帮你编写测试），审核测试以确保它们捕获了你想要的内容，然后让编程代理实现功能。模型在不断改进，因此你需要持续更新对模型能力的直觉判断。
    > 我们使用 Claude Code [实现](https://github.com/missing-semester/missing-semester/pull/345)了这些 Tufte 风格的旁注。
{%- comment %}
No need to demo this, since the intro of a lecture was a small demo of adding a new feature.
{% endcomment %}
- **修复错误。** 如果你有来自编译器、Linter、类型检查器或测试的错误，可以让代理来修复它们，例如使用"修复 mypy 的问题"这样的提示。当你能让编程模型进入反馈循环时，它们特别有效，因此尽量设置好环境，使模型能直接运行失败的检查，这样它就可以自主迭代。如果这不切实际，你可以手动给模型提供反馈。
    > 在 missing-semester 仓库的 [f552b55](https://github.com/missing-semester/missing-semester/commit/f552b5523462b22b8893a8404d2110c4e59613dd) 提交中，我们向 Claude Code 输入了"Review the agentic coding lecture for typos and grammatical issues"，随后要求它修复发现的问题，这些问题被提交在 [f1e1c41](https://github.com/missing-semester/missing-semester/commit/f1e1c417adba6b4149f7eef91ff5624de40dc637) 中。
{%- comment %}
Demo a coding agent fixing the bug in https://github.com/anishathalye/dotbot/commit/cef40c902ef0f52f484153413142b5154bbc5e99.

Write the failing tests to demo the bug, and then ask the agent to fix. Prepped in branch demo-bugfix.

Can run the failing test with:

    hatch test tests/test_cli.py::test_issue_357

Can prompt coding agent with:

    There is a bug I wrote a failing test for, you can repro it with `hatch test tests/test_cli.py::test_issue_357`. Fix the bug.

Get it to commit the changes.
{% endcomment %}
- **重构代码。** 你可以使用编程代理以各种方式重构代码，从简单的任务如重命名方法（这类重构也受[代码智能](/2026/development-environment/#code-intelligence-and-language-servers)支持）到更复杂的任务如将功能拆分到单独的模块中。
    > 我们使用 Claude Code 将 agentic coding [拆分](https://github.com/missing-semester/missing-semester/pull/344)成了独立的课程。
{%- comment %}
Show usage in Missing Semester, point out that the agent did make some mistakes.
{% endcomment %}
- **代码审查。** 你可以让编程代理审查代码。你可以给它基本的指导，比如"审查我尚未提交的最新更改"。如果你想审查一个 Pull Request，并且你的编程代理支持网页抓取，或者你安装了 [GitHub CLI](https://cli.github.com/) 等命令行工具，你甚至可以要求编程代理"审查这个 Pull Request {链接}"，它会从那里接管一切。
{%- comment %}
In Porcupine repo, prompt agent with:

    Review this PR: https://github.com/anishathalye/porcupine/pull/39
{% endcomment %}
- **理解代码。** 你可以向编程代理询问关于代码库的问题，这对于新成员入职特别有帮助。
{%- comment %}
Some prompts to try in the missing-semester repo:

    How do I run this site locally?

    How are the social preview cards implemented?
{% endcomment %}
- **作为 Shell 使用。** 你可以要求编程代理使用特定工具来完成任务，这样你就可以用自然语言调用 Shell 命令，例如"使用 find 命令查找所有超过 30 天的文件"或"使用 mogrify 将所有 jpg 图片缩小到原始大小的 50%"。
{%- comment %}
In Dotbot repo, prompt agent with:

    Use the ag command to find all Python renaming imports
{% endcomment %}
- **氛围编程（Vibe coding）。** 代理已经足够强大，你甚至可以在不亲自编写一行代码的情况下实现某些应用。
    > [这里有一个例子](https://github.com/cleanlab/office-presence-dashboard)，是讲师之一通过氛围编程完成的实际项目。
{%- comment %}
In missing-semester repo, prompt agent with:

    Make this site look retro.
{% endcomment %}

# 高级代理

这里，我们简要概述编程代理的一些更高级的使用模式和功能。

- **可复用提示词。** 创建可复用的提示词或模板。例如，你可以编写一个详细的提示词来以特定方式进行代码审查，并将其保存为可复用提示词。
    > 代理工具发展迅速。在某些工具中，作为独立功能的可复用提示词已被弃用。例如，在 Codex 和 Claude Code 中，它们已被 [Skills](https://code.claude.com/docs/en/skills)[涵盖](https://developers.openai.com/codex/custom-prompts)。
- **并行代理。** 编程代理可能会很慢：你可以向代理发出提示，然后它可能在一个问题上工作几十分钟。你可以同时运行多个代理实例，既可以处理同一任务（LLM 具有随机性，因此多次运行同一任务并取最佳解决方案可能会有帮助），也可以处理不同任务（例如，同时实现两个互不重叠的功能）。为了防止不同代理的更改互相干扰，你可以使用 [git worktrees](https://git-scm.com/docs/git-worktree)，我们在[版本控制](/2026/version-control/)课程中对此有介绍。
- **MCP。** MCP，全称 _Model Context Protocol_（模型上下文协议），是一个开放协议，可用于将编程代理与工具连接。例如，这个 [Notion MCP 服务器](https://github.com/makenotion/notion-mcp-server)可以让你的代理读写 Notion 文档，实现"读取 {Notion 文档} 中链接的规范，在 Notion 中起草实现计划作为新页面，然后实现原型"这样的用例。要发现 MCP，你可以使用 [Pulse](https://www.pulsemcp.com/servers) 和 [Glama](https://glama.ai/mcp/servers) 等目录。
- **上下文管理。** 正如我们[上文](#how-ai-models-and-agents-work)提到的，编程代理底层的 LLM 具有有限的*上下文窗口*。有效地使用编程代理需要善于利用上下文。你要确保代理能够访问所需的信息，但要避免不必要的上下文，以防止溢出上下文窗口或降低模型性能（随着上下文大小增长，即使没有溢出上下文窗口，性能也往往会下降）。代理框架会自动提供并在一定程度上管理上下文，但很多控制权仍然留给用户。
    - **清空上下文窗口。** 最基本的控制方式——编程代理支持清空上下文窗口（开始新对话），对于不相关的查询你应该这样做。
    - **回退对话。** 一些编程代理支持撤销对话历史中的步骤。在某些情况下，与其发送后续消息引导代理改变方向，不如使用"撤销"来更有效地管理上下文。
{%- comment %}
Make up a quick demo.
{% endcomment %}
    - **压缩（Compaction）。** 为了实现无限制长度的对话，编程代理支持上下文*压缩*：如果对话历史过长，它们会自动调用 LLM 来总结对话的前缀部分，并用摘要替换对话历史。一些代理允许用户在需要时手动触发压缩。
{%- comment %}
Show `/compact` in Claude Code, show full summary.
{% endcomment %}
    - **llms.txt。** `/llms.txt` 文件是一个提议的[标准](https://llmstxt.org/)位置，用于存放供 LLM 在推理时使用的文档。产品（如 [cursor.com/llms.txt](https://cursor.com/llms.txt)）、软件库（如 [ai.pydantic.dev/llms.txt](https://ai.pydantic.dev/llms.txt)）和 API（如 [apify.com/llms.txt](https://apify.com/llms.txt)）可能会有 `llms.txt` 文件，对开发很有帮助。这类文档每个 Token 的信息密度更高，因此比让编程代理抓取并阅读 HTML 页面更高效地利用上下文。当编程代理对你正在使用的依赖没有内置知识时（例如，因为它在 LLM 的知识截止日期之后发布），外部文档就特别有用。
{%- comment %}
Side-by-side comparison in an empty repo (on Desktop or some other self-contained place, with `git init` run in it):

    Write a single-file Python program example in demo.py using semlib to sort "Ilya Sutskever", "Soumith Chintala", and "Donald Knuth" in terms of their fame as AI researchers.

    Write a single-file Python program example in demo.py using semlib to sort "Ilya Sutskever", "Soumith Chintala", and "Donald Knuth" in terms of their fame as AI researchers. See https://semlib.anish.io/llms.txt. Follow links to Markdown versions of any pages linked in llms.txt files.

Not sure why the agent doesn't do this by default. You'd probably put that last sentence in a CLAUDE.md file.
{% endcomment %}
    - **AGENTS.md。** 大多数编程代理支持 [AGENTS.md](https://agents.md/) 或类似文件（例如，Claude Code 会查找 `CLAUDE.md`）作为编程代理的说明文件。代理启动时，会将 `AGENTS.md` 的全部内容预填充到上下文中。你可以用它来为代理提供跨会话的通用建议（例如，指示它在修改代码后始终运行类型检查器，解释如何运行单元测试，或提供代理可以浏览的第三方文档链接）。一些编程代理可以自动生成此文件（例如，Claude Code 中的 `/init` 命令）。参见[这里](https://github.com/pydantic/pydantic-ai/blob/main/CLAUDE.md)了解 `AGENTS.md` 的实际示例。
{%- comment %}
Dotbot example, CLAUDE.md that includes @DEVELOPMENT.md and says to always run the type checker and code formatter after making any changes to Python code.

Example prompt, off of master:

    Remove the "--version" command-line flag.

This is something that'll be fast, for demonstration purposes.
{% endcomment %}
    - **Skills（技能）。** `AGENTS.md` 中的内容总是会完整地加载到代理的上下文窗口中。*Skills* 增加了一层间接性来避免上下文膨胀：你可以为代理提供一系列 Skills 及其描述，代理可以根据需要"打开"某个 Skill（将其加载到上下文窗口中）。
    - **子代理（Subagents）。** 一些编程代理允许你定义子代理，即用于特定任务工作流的代理。顶层编程代理可以调用子代理来完成特定任务，这使得顶层代理和子代理都能更有效地管理上下文。顶层代理的上下文不会被子代理看到的所有内容膨胀，而子代理也能只获取其任务所需的上下文。举个例子，一些编程代理将网页研究实现为子代理：顶层代理向子代理提出查询，子代理运行网页搜索，检索各个网页，进行分析，然后将查询的答案返回给顶层代理。这样，顶层代理的上下文不会被所有检索到的网页的完整内容膨胀，子代理的上下文中也不会包含顶层代理对话历史的其余部分。

对于许多需要编写提示词的高级功能（例如 Skills 或子代理），你可以使用 LLM 来帮助你入门。一些编程代理甚至内置了对这种操作的支持。例如，Claude Code 可以从简短的提示词生成子代理（调用 `/agents` 并创建新代理）。试试用以下提示词创建一个子代理：

```
一个 Python 代码检查代理，使用 `mypy` 和 `ruff` 对自上次 git 提交以来修改过的所有文件进行类型检查、Lint 检查和格式检查。
```

然后，你可以让顶层代理通过类似"使用代码检查子代理"的消息来显式调用子代理。你甚至可以让顶层代理在适当的时候自动调用子代理，例如，在修改任何 Python 文件之后。

# 注意事项

AI 工具可能会犯错。它们建立在 LLM 之上，而 LLM 只是概率性的下一词预测模型。它们并不像人类那样具有"智能"。请审查 AI 输出的正确性和安全性。有时验证代码可能比你自己编写代码更困难；对于关键代码，请考虑手动编写。AI 可能会钻牛角尖并试图误导你；要注意调试死循环。不要把 AI 当作拐杖，要警惕过度依赖或理解浮于表面。仍有大量编程任务是 AI 目前无法完成的。计算思维依然有价值。

# 推荐软件

许多 IDE / AI 编程扩展都包含编程代理（参见[开发环境](/2026/development-environment/)课程的推荐）。其他流行的编程代理包括 Anthropic 的 [Claude Code](https://www.claude.com/product/claude-code)、OpenAI 的 [Codex](https://openai.com/codex/)，以及开源代理如 [opencode](https://github.com/anomalyco/opencode)。

# 练习

1. 通过将同一编程任务执行四次来比较手动编码、使用 AI 自动补全、内联聊天和代理的体验。最佳选择是你正在开发的项目中的一个小型功能。如果你需要其他想法，可以考虑在 GitHub 上的开源项目中完成"good first issue"类型的任务，或者 [Advent of Code](https://adventofcode.com/) 或 [LeetCode](https://leetcode.com/) 上的题目。
1. 使用 AI 编程代理浏览一个陌生的代码库。最好是在想要调试或为你真正关心的项目添加新功能的背景下进行。如果你一时想不起来，可以尝试使用 AI 代理来理解 [opencode](https://github.com/anomalyco/opencode) 代理中安全相关功能的工作原理。
1. 从零开始氛围编程一个小应用。不要手动编写一行代码。
1. 为你选择的编程代理创建并测试一个 `AGENTS.md`（或你的代理对应的等效文件，如 `CLAUDE.md`）、一个 Skill（例如 [Claude Code 中的 Skill](https://code.claude.com/docs/en/skills) 或 [Codex 中的 Skill](https://developers.openai.com/codex/skills/)），以及一个子代理（例如 [Claude Code 中的子代理](https://code.claude.com/docs/en/sub-agents)）。思考在什么情况下你会选择使用其中某一种而不是另一种。请注意，你选择的编程代理可能不支持其中某些功能；你可以跳过它们，或者尝试支持这些功能的其他编程代理。
1. 使用编程代理来完成与[代码质量](/2026/code-quality/)课程中 Markdown 无序列表正则表达式练习相同的目标。它是通过直接编辑文件来完成任务的吗？代理直接编辑文件来完成此类任务有什么缺点和局限性？想办法提示代理，使其不通过直接编辑文件来完成该任务。提示：让代理使用[第一节课](/2026/course-shell/)中提到的某个命令行工具。
1. 大多数编程代理都支持某种"YOLO 模式"（例如，在 Claude Code 中是 `--dangerously-skip-permissions`）。直接使用此模式并不安全，但在虚拟机或容器等隔离环境中运行编程代理然后启用自主操作可能是可以接受的。在你的机器上搭建这样的环境。[Claude Code devcontainers](https://code.claude.com/docs/en/devcontainer) 或 [Docker Sandboxes / Claude Code](https://docs.docker.com/ai/sandboxes/agents/claude-code/) 等文档可能会派上用场。搭建方式不止一种。
