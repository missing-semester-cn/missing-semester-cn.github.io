---
layout: lecture
title: "Agentic Coding"
description: >
  Learn how to use AI coding agents effectively for software development tasks.
thumbnail: /static/assets/thumbnails/2026/lec7.png
date: 2026-01-21
ready: true
video:
  aspect: 56.25
  id: sTdz6PZoAnw
---

Coding agents are conversational AI models with access to tools such as reading/writing files, web search, and invoking shell commands. They live either in the IDE or in standalone command-line or GUI tools. Coding agents are highly autonomous and powerful tools, enabling a wide variety of use cases.

This lecture builds on the AI-powered development material from the [Development Environment and Tools](/2026/development-environment/) lecture. As a quick demo, let's continue with the example from the [AI-powered development](/2026/development-environment/#ai-powered-development) section:

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

We can try prompting a coding agent with the following task:

```
Turn this into a proper command-line program, with argparse for argument parsing. Add type annotations, and make sure the program passes type checking.
```

The agent will read the file to understand it, then make some edits, and finally invoke the type checker to make sure the type annotations are correct. If it makes a mistake such that it fails type checking, it will likely iterate, though this is a simple task so that is unlikely to happen. Because coding agents have access to tools that may be harmful, by default, agent harnesses prompt the user to confirm tool calls.

> If the coding agent makes a mistake --- for example, if you have the `mypy` binary available directly on `$PATH` but the agent tries calling `python -m mypy` --- you can give it text feedback to help it course correct.

Coding agents support multi-turn interaction, so you can iterate on work over a back-and-forth conversation with the agent. You can even interrupt the agent if it's going down the wrong track. One helpful mental model might be that of a manager of an intern: the intern will do the nitty gritty work, but will require guidance, and will occasionally do the wrong thing and need to be corrected.

> For a more illustrative demo, try asking the agent as a follow-up to run the resulting script. Observe the outputs, and try asking it to make a change (e.g., ask it to include only absolute URLs).

# How AI models and agents work

Fully explaining the inner workings of modern [large language models (LLMs)](https://en.wikipedia.org/wiki/Large_language_model) and infrastructure such as agent harnesses is beyond the scope of this course. However, having a high-level understanding of some of the key ideas is helpful for effectively _using_ this bleeding edge technology and understanding its limitations.

LLMs can be viewed as modeling the probability distribution of completion strings (outputs) given prompt strings (inputs). LLM inference (what happens when you, e.g., supply a query to a conversational chat app) _samples_ from this probability distribution. LLMs have a fixed _context window_, the maximum length of the input and output strings.

{% comment %}
> In mathematical notation, the LLM models the probability distribution $\pi_\theta$ of completions $y$ conditioned on prompts $x$, and we sample from this distribution: $\hat{y} \sim \pi_\theta(\cdot \mid x)$.
{% endcomment %}

AI tools such as conversational chat and coding agents build on top of this primitive. For multi-turn interactions, chat apps and agents use turn markers and supply the entire conversation history as the prompt string every time there is a new user prompt, invoking LLM inference once per user prompt. For tool-calling agents, the harness interprets certain LLM outputs as requests to invoke a tool, and the harness supplies the results of the tool call back to the model as part of the prompt string (so LLM inference runs again every time there is a tool call/response). The core concepts in tool-calling agents can be [implemented in 200 lines of code](https://www.mihaileric.com/The-Emperor-Has-No-Clothes/).

## Privacy

Most AI coding tools in their standard configurations send a lot of your data to the cloud. Sometimes the harness runs locally while LLM inference runs in the cloud, other times even more of the software is running in the cloud (and, e.g., the service provider might effectively get a copy of your entire repository as well as all interactions you have with the AI tool).

There are open-source AI coding tools and open-source LLMs that are pretty good (though not quite as good as the proprietary models), but at the present, for most users, running bleeding-edge open LLMs locally will be infeasible due to hardware limitations.

# Use cases

Coding agents can be helpful for a wide variety of tasks. Some examples:

- **Implementing new features.** As in the example above, you can ask a coding agent to implement a feature. Giving a good specification is more of an art than a science at this point; you want the input to the agent to be descriptive enough so that the agent does what you want it to do (at least heading in the right direction so you can iterate), but not overly descriptive to the point where you're doing too much work yourself. Test-driven development can be particularly effective: write tests (or use the coding agent to help you write tests), audit them to ensure they capture what you want, and then ask the coding agent to implement the feature. Models are continually improving, so you'll have to keep your intuition up-to-date on what the models are capable of.
    > We used Claude Code to [implement](https://github.com/missing-semester/missing-semester/pull/345) these Tufte-style sidenotes.
{%- comment %}
No need to demo this, since the intro of a lecture was a small demo of adding a new feature.
{% endcomment %}
- **Fixing errors.** If you have errors from your compiler, linter, type checker, or tests, you can ask your agent to correct them, for example with a prompt like "fix the issues with mypy". Coding models are particularly effective when you can get them in a feedback loop, so try to set things up so that the model can run the failing check directly, which will let it iterate autonomously. If this is impractical, you can give the model feedback manually.
    > On commit [f552b55](https://github.com/missing-semester/missing-semester/commit/f552b5523462b22b8893a8404d2110c4e59613dd) of the missing-semester repo, we prompted Claude Code with "Review the agentic coding lecture for typos and grammatical issues" and subsequently asked it to fix the issues it found, which were committed in [f1e1c41](https://github.com/missing-semester/missing-semester/commit/f1e1c417adba6b4149f7eef91ff5624de40dc637).
{%- comment %}
Demo a coding agent fixing the bug in https://github.com/anishathalye/dotbot/commit/cef40c902ef0f52f484153413142b5154bbc5e99.

Write the failing tests to demo the bug, and then ask the agent to fix. Prepped in branch demo-bugfix.

Can run the failing test with:

    hatch test tests/test_cli.py::test_issue_357

Can prompt coding agent with:

    There is a bug I wrote a failing test for, you can repro it with `hatch test tests/test_cli.py::test_issue_357`. Fix the bug.

Get it to commit the changes.
{% endcomment %}
- **Refactoring.** You can use coding agents to refactor code in various ways, from simple tasks like renaming a method (this kind of refactoring is also supported by [code intelligence](/2026/development-environment/#code-intelligence-and-language-servers)) to more complex tasks like breaking out functionality into a separate module.
    > We used Claude Code to [split](https://github.com/missing-semester/missing-semester/pull/344) agentic coding into its own lecture.
{%- comment %}
Show usage in Missing Semester, point out that the agent did make some mistakes.
{% endcomment %}
- **Code review.** You can ask coding agents to review code. You can give them basic guidance, like "review my latest changes that are not yet committed". If you want to review a pull request and your coding agent supports web fetch, or you have command-line tools like the [GitHub CLI](https://cli.github.com/) installed, you might even be able to ask the coding agent "Review the pull request {link}" and it'll handle it from there.
{%- comment %}
In Porcupine repo, prompt agent with:

    Review this PR: https://github.com/anishathalye/porcupine/pull/39
{% endcomment %}
- **Code understanding.** You can ask a coding agent questions about a codebase, which can be particularly helpful for onboarding.
{%- comment %}
Some prompts to try in the missing-semester repo:

    How do I run this site locally?

    How are the social preview cards implemented?
{% endcomment %}
- **As a shell.** You can ask the coding agent to use a particular tool to solve a task, so you can invoke a shell command using natural language, such as "use the find command to find all files older than 30 days" or "use mogrify to resize all the jpgs to 50% of their original size".
{%- comment %}
In Dotbot repo, prompt agent with:

    Use the ag command to find all Python renaming imports
{% endcomment %}
- **Vibe coding.** Agents are powerful enough that you can implement some applications without writing a single line of code yourself.
    > [Here is an example](https://github.com/cleanlab/office-presence-dashboard) of a real-world project that one of the instructors vibe-coded.
{%- comment %}
In missing-semester repo, prompt agent with:

    Make this site look retro.
{% endcomment %}

# Advanced agents

Here, we give a brief overview of some more advanced usage patterns and capabilities of coding agents.

- **Reusable prompts.** Create reusable prompts or templates. For example, you can write a detailed prompt to do code review in a particular way, and save that as a reusable prompt.
    > Agent tooling evolves quickly. In some tools, reusable prompts as a standalone feature are deprecated. For example, in Codex and Claude Code, they are [subsumed](https://developers.openai.com/codex/custom-prompts) by [skills](https://code.claude.com/docs/en/skills).
- **Parallel agents.** Coding agents can be slow: you can prompt the agent, and it can work at a problem for tens of minutes. You can run multiple copies of agents at the same time, either working on the same task (LLMs are stochastic, so it can be helpful to run the same thing multiple times and take the best solution) or different tasks (e.g., implement two non-overlapping features at the same time). To keep the different agents' changes from interfering with each other, you can use [git worktrees](https://git-scm.com/docs/git-worktree), which we cover in the lecture on [version control](/2026/version-control/).
- **MCPs.** MCP, which stands for _Model Context Protocol_, is an open protocol that you can use to connect your coding agents with tools. For example, this [Notion MCP server](https://github.com/makenotion/notion-mcp-server) can let your agent read/write Notion docs, enabling use cases like "read the spec linked in {Notion doc}, draft an implementation plan as a new page in Notion, and then implement a prototype". For discovering MCPs, you can use directories like [Pulse](https://www.pulsemcp.com/servers) and [Glama](https://glama.ai/mcp/servers).
- **Context management.** As we noted [above](#how-ai-models-and-agents-work), the LLMs that underlie coding agents have a limited _context window_. Effective use of coding agents necessitates making good use of context. You want to make sure the agent has access to the information it needs, but avoid unnecessary context to avoid overflowing the context window or degrading the performance of the model (which tends to happen as context size grows, even if it doesn't overflow the context window). Agent harnesses automatically supply, and to some degree, manage context, but a lot of control is left to the user.
    - **Clearing the context window.** The most basic control, coding agents support clearing the context window (starting a new conversation), which you should do for unrelated queries.
    - **Rewinding the conversation.** Some coding agents support undoing steps in the conversation history. Rather than give a follow-up message steering the agent in a different direction, in situations where an "undo" makes more sense, this more effectively manages context.
{%- comment %}
Make up a quick demo.
{% endcomment %}
    - **Compaction.** To enable conversations of unbounded length, coding agents support context _compaction_: if the conversation history grows too long, they will automatically call an LLM to summarize the prefix of the conversation, and replace the conversation history with the summary. Some agents give control to the user to invoke compaction when desired.
{%- comment %}
Show `/compact` in Claude Code, show full summary.
{% endcomment %}
    - **llms.txt.** The `/llms.txt` file is a proposed [standard](https://llmstxt.org/) location for a document meant for LLMs to use at inference time. Products (e.g., [cursor.com/llms.txt](https://cursor.com/llms.txt)), software libraries (e.g., [ai.pydantic.dev/llms.txt](https://ai.pydantic.dev/llms.txt)), and APIs (e.g., [apify.com/llms.txt](https://apify.com/llms.txt)) might have `llms.txt` files that are handy for development. Such documents are more information dense per token, and so they are more context-efficient than asking your coding agent to fetch and read an HTML page. External documentation is handy when a coding agent doesn't have built-in knowledge about a dependency you are trying to use (e.g., because it was published after the LLM's knowledge cutoff).
{%- comment %}
Side-by-side comparison in an empty repo (on Desktop or some other self-contained place, with `git init` run in it):

    Write a single-file Python program example in demo.py using semlib to sort "Ilya Sutskever", "Soumith Chintala", and "Donald Knuth" in terms of their fame as AI researchers.

    Write a single-file Python program example in demo.py using semlib to sort "Ilya Sutskever", "Soumith Chintala", and "Donald Knuth" in terms of their fame as AI researchers. See https://semlib.anish.io/llms.txt. Follow links to Markdown versions of any pages linked in llms.txt files.

Not sure why the agent doesn't do this by default. You'd probably put that last sentence in a CLAUDE.md file.
{% endcomment %}
    - **AGENTS.md.** Most coding agents support [AGENTS.md](https://agents.md/) or similar (e.g., Claude Code looks for `CLAUDE.md`) as a README for coding agents. When the agent starts, it pre-fills the context with the entire contents of `AGENTS.md`. You can use this to give the agent advice that is common across sessions (e.g., instruct it to always run the type-checker after making code changes, explain how to run unit tests, or provide links to third-party docs that the agent can browse). Some coding agents can auto-generate this file (e.g., the `/init` command in Claude Code). See [here](https://github.com/pydantic/pydantic-ai/blob/main/CLAUDE.md) for a real-world example of an `AGENTS.md`.
{%- comment %}
Dotbot example, CLAUDE.md that includes @DEVELOPMENT.md and says to always run the type checker and code formatter after making any changes to Python code.

Example prompt, off of master:

    Remove the "--version" command-line flag.

This is something that'll be fast, for demonstration purposes.
{% endcomment %}
    - **Skills.** Content in the `AGENTS.md` is always loaded, in its entirety, into the context window of an agent. _Skills_ add one level of indirection to avoid context bloat: you can provide the agent with a list of skills along with descriptions, and the agent can "open" the skill (load it into its context window) as desired.
    - **Subagents.** Some coding agents let you define subagents, which are agents for task-specific workflows. The top-level coding agent can invoke a sub-agent to complete a particular task, which enables both the top-level agent and subagent to more effectively manage context. The top-level agent's context isn't bloated with everything the subagent sees, and the subagent can get just the context it needs for its task. As one example, some coding agents implement web research as a subagent: the top-level agent will pose a query to the subagent, which will run web search, retrieve individual web pages, analyze them, and provide an answer to the query to the top-level agent. This way, the top-level agent doesn't have its context bloated by the full content of all retrieved web pages, and the subagent doesn't have in its context the rest of the conversation history of the top-level agent.

For many of the advanced features that require writing prompts (e.g., skills or subagents), you can use LLMs to get you started. Some coding agents even have built-in support for doing this. For example, Claude Code can generate a subagent from a short prompt (invoke `/agents` and create a new agent). Try creating a subagent with this prompt:

```
A Python code checking agent that uses `mypy` and `ruff` to type-check, lint, and format *check* any files that have been modified from the last git commit.
```

Then, you can use the top-level agent to explicitly invoke the subagent with a message like "use the code checker subagent". You might also be able to get the top-level agent to automatically invoke the subagent when appropriate, for example, after modifying any Python files.

# What to watch out for

AI tools can make mistakes. They are built on LLMs, which are just probabilistic next-token-prediction models. They are not "intelligent" in the same way as humans. Review AI output for correctness and security bugs. Sometimes verifying code can be harder than writing the code yourself; for critical code, consider writing it by hand. AI can go down rabbit holes and try to gaslight you; be aware of debugging spirals. Don't use AI as a crutch, and be wary of overreliance or having a shallow understanding. There's still a huge class of programming tasks that AI is still incapable of doing. Computational thinking is still valuable.

# Recommended software

Many IDEs / AI coding extensions include coding agents (see recommendations from the [development environment lecture](/2026/development-environment/)). Other popular coding agents include Anthropic's [Claude Code](https://www.claude.com/product/claude-code), OpenAI's [Codex](https://openai.com/codex/), and open-source agents like [opencode](https://github.com/anomalyco/opencode).

# Exercises

1. Compare the experience of coding by hand, using AI autocomplete, inline chat, and agents by doing the same programming task four times. The best candidate is a small-sized feature from a project you're already working on. If you're looking for other ideas, you could consider completing "good first issue" style tasks in open-source projects on GitHub, or [Advent of Code](https://adventofcode.com/) or [LeetCode](https://leetcode.com/) problems.
1. Use an AI coding agent to navigate an unfamiliar codebase. This is best done in the context of wanting to debug or add a new feature to a project you actually care about. If you don't have any that come to mind, try using an AI agent to understand how security-related features work in the [opencode](https://github.com/anomalyco/opencode) agent.
1. Vibe code a small app from scratch. Do not write a single line of code by hand.
1. For your coding agent of choice, create and test an `AGENTS.md` (or analogous for your agent of choice, such as `CLAUDE.md`), a skill (e.g., [skill in Claude Code](https://code.claude.com/docs/en/skills) or [skill in Codex](https://developers.openai.com/codex/skills/)), and a subagent (e.g., [subagent in Claude Code](https://code.claude.com/docs/en/sub-agents)). Think about when you'd want to use one of these versus another. Note that your coding agent of choice might not support some of these functionalities; you can either skip them, or try a different coding agent that has support.
1. Use a coding agent to accomplish the same goal as in the Markdown bullet points regex exercise from the [Code Quality lecture](/2026/code-quality/). Does it complete the tasks via direct file edits? What are the downsides and limitations of an agent editing the file directly to complete such a task? Figure out how to prompt the agent such that it doesn't complete the task via direct file edits. Hint: ask the agent to use one of the command-line tools mentioned in the [first lecture](/2026/course-shell/).
1. Most coding agents support a form of "yolo mode" (e.g., in Claude Code, `--dangerously-skip-permissions`). It is not secure to use this mode directly, but it may be acceptable to run a coding agent in an isolated environment like a virtual machine or container and then enable autonomous operation. Get this setup running on your machine. Documentation such as [Claude Code devcontainers](https://code.claude.com/docs/en/devcontainer) or [Docker Sandboxes / Claude Code](https://docs.docker.com/ai/sandboxes/agents/claude-code/) may come in handy. There is more than one way to set this up.
