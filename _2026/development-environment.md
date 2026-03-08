---
layout: lecture
title: "Development Environment and Tools"
description: >
  Learn about IDEs, Vim, language servers, and AI-powered development tools.
thumbnail: /static/assets/thumbnails/2026/lec3.png
date: 2026-01-14
ready: true
video:
  aspect: 56.25
  id: QnM1nVzrkx8
---

A _development environment_ is a set of tools for developing software. At the heart of a development environment is text editing functionality, along with accompanying features such as syntax highlighting, type checking, code formatting, and autocomplete. _Integrated development environments_ (IDEs) such as [VS Code][vs-code] bring together all of this functionality into a single application. Terminal-based development workflows combine tools such as [tmux](https://github.com/tmux/tmux) (a terminal multiplexer), [Vim](https://www.vim.org/) (a text editor), [Zsh](https://www.zsh.org/) (a shell), and language-specific command-line tools, such as [Ruff](https://docs.astral.sh/ruff/) (a Python linter and code formatter) and [Mypy](https://mypy-lang.org/) (a Python type checker).

IDEs and terminal-based workflows each have their strengths and weaknesses. For example, graphical IDEs can be easier to learn, and today's IDEs generally have better out-of-the-box AI integrations like AI autocomplete; on the other hand, terminal-based workflows are lightweight, and they may be your only option in environments where you don't have a GUI or can't install software. We recommend you develop basic familiarity with both and develop mastery of at least one. If you don't already have a preferred IDE, we recommend starting with [VS Code][vs-code].

In this lecture, we'll cover:

- [Text editing and Vim](#text-editing-and-vim)
- [Code intelligence and language servers](#code-intelligence-and-language-servers)
- [AI-powered development](#ai-powered-development)
- [Extensions and other IDE functionality](#extensions-and-other-ide-functionality)

[vs-code]: https://code.visualstudio.com/

# Text editing and Vim

When programming, you spend most of your time navigating through code, reading snippets of code, and making edits to code, rather than writing long streams or reading files top-to-bottom. [Vim] is a text editor that is optimized for this distribution of tasks.

**The philosophy of Vim.** Vim has a beautiful idea as its foundation: its interface is itself a programming language, designed for navigating and editing text. Keystrokes (with mnemonic names) are commands, and these commands are composable. Vim avoids the use of the mouse, because it's too slow; Vim even avoids use of the arrow keys because it requires too much movement. The result: an editor that feels like a brain-computer interface and matches the speed at which you think.

**Vim support in other software.** You don't have to use [Vim] itself to benefit from the ideas at its core. Many programs that involve any kind of text editing support "Vim mode", either as built-in functionality or as a plugin. For example, VS Code has the [VSCodeVim](https://marketplace.visualstudio.com/items?itemName=vscodevim.vim) plugin, Zsh has [built-in support](https://zsh.sourceforge.io/Guide/zshguide04.html) for Vim emulation, and even Claude Code has [built-in support](https://code.claude.com/docs/en/interactive-mode#vim-editor-mode) for Vim editor mode. Chances are that any tool you use that involves text editing supports Vim mode in one way or another.

## Modal editing

Vim is a _modal editor_: it has different operating modes for different classes of tasks.

- **Normal**: for moving around a file and making edits
- **Insert**: for inserting text
- **Replace**: for replacing text
- **Visual** (plain, line, or block): for selecting blocks of text
- **Command-line**: for running a command

Keystrokes have different meanings in different operating modes. For example, the letter `x` in Insert mode will just insert a literal character "x", but in Normal mode, it will delete the character under the cursor, and in Visual mode, it will delete the selection.

In its default configuration, Vim shows the current mode in the bottom left. The initial/default mode is Normal mode. You'll generally spend most of your time between Normal mode and Insert mode.

You change modes by pressing `<ESC>` (the escape key) to switch from any mode back to Normal mode. From Normal mode, enter Insert mode with `i`, Replace mode with `R`, Visual mode with `v`, Visual Line mode with `V`, Visual Block mode with `<C-v>` (Ctrl-V, sometimes also written `^V`), and Command-line mode with `:`.

You use the `<ESC>` key a lot when using Vim: consider remapping Caps Lock to Escape ([macOS instructions](https://vim.fandom.com/wiki/Map_caps_lock_to_escape_in_macOS)) or create an [alternative mapping](https://vim.fandom.com/wiki/Avoid_the_escape_key#Mappings) for `<ESC>` with a simple key sequence.

## Basics: inserting text

From Normal mode, press `i` to enter Insert mode. Now, Vim behaves like any other text editor, until you press `<ESC>` to return to Normal mode. This, along with the basics explained above, are all you need to start editing files using Vim (though not particularly efficiently, if you're spending all your time editing from Insert mode).

## Vim's interface is a programming language

Vim's interface is a programming language. Keystrokes (with mnemonic names) are commands, and these commands _compose_. This enables efficient movement and edits, especially once the commands become muscle memory, just like typing becomes super efficient once you've learned your keyboard layout.

### Movement

You should spend most of your time in Normal mode, using movement commands to navigate the file. Movements in Vim are also called "nouns", because they refer to chunks of text.

- Basic movement: `hjkl` (left, down, up, right)
- Words: `w` (next word), `b` (beginning of word), `e` (end of word)
- Lines: `0` (beginning of line), `^` (first non-blank character), `$` (end of line)
- Screen: `H` (top of screen), `M` (middle of screen), `L` (bottom of screen)
- Scroll: `Ctrl-u` (up), `Ctrl-d` (down)
- File: `gg` (beginning of file), `G` (end of file)
- Line numbers: `:{number}<CR>` or `{number}G` (line {number})
    - `<CR>` refers to the carriage return / enter key
- Misc: `%` (matching item, like parenthesis or brace)
- Find: `f{character}`, `t{character}`, `F{character}`, `T{character}`
    - find/to forward/backward {character} on the current line
    - `,` / `;` for navigating matches
- Search: `/{regex}`, `n` / `N` for navigating matches

### Selection

Visual modes:

- Visual: `v`
- Visual Line: `V`
- Visual Block: `Ctrl-v`

Can use movement keys to make selection.

### Edits

Everything that you used to do with the mouse, you now do with the keyboard using editing commands that compose with movement commands. Here's where Vim's interface starts to look like a programming language. Vim's editing commands are also called "verbs", because verbs act on nouns.

- `i` enter Insert mode
    - but for manipulating/deleting text, want to use something more than backspace
- `o` / `O` insert line below / above
- `d{motion}` delete {motion}
    - e.g. `dw` is delete word, `d$` is delete to end of line, `d0` is delete to beginning of line
- `c{motion}` change {motion}
    - e.g. `cw` is change word
    - like `d{motion}` followed by `i`
- `x` delete character (equivalent to `dl`)
- `s` substitute character (equivalent to `cl`)
- Visual mode + manipulation
    - select text, `d` to delete it or `c` to change it
- `u` to undo, `<C-r>` to redo
- `y` to copy / "yank" (some other commands like `d` also copy)
- `p` to paste
- Lots more to learn: for example, `~` flips the case of a character, and `J` joins together lines

### Counts

You can combine nouns and verbs with a count, which will perform a given action a number of times.

- `3w` move 3 words forward
- `5j` move 5 lines down
- `7dw` delete 7 words

### Modifiers

You can use modifiers to change the meaning of a noun. Some modifiers are `i`, which means "inner" or "inside", and `a`, which means "around".

- `ci(` change the contents inside the current pair of parentheses
- `ci[` change the contents inside the current pair of square brackets
- `da'` delete a single-quoted string, including the surrounding single quotes

## Putting it all together

Here is a broken [fizz buzz](https://en.wikipedia.org/wiki/Fizz_buzz) implementation:

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

We use the following sequence of commands to fix the issues, beginning in Normal mode:

- Main is never called
    - `G` to jump to the end of the file
    - `o` to **o**pen a new line below
    - Type in `if __name__ == "__main__": main()`
        - If your editor has Python language support, it might do some auto-indentation for you in Insert mode
    - `<ESC>` to go back to Normal mode
- Starts at 0 instead of 1
    - `/` followed by `range` and `<CR>` to search for "range"
    - `ww` to move forward two **w**ords (you could also use `2w`, but in practice, for small counts it's common to repeat the key instead of using the count functionality)
    - `i` to switch to **i**nsert mode, and add `1,`
    - `<ESC>` to go back to Normal mode
    - `e` to jump to the **e**nd of the next word
    - `a` to start **a**ppending text, and add `+ 1`
    - `<ESC>` to go back to Normal mode
- Prints "fizz" for multiples of 5
    - `:6<CR>` to go to line 6
    - `ci"` to **c**hange **i**nside the '**"**', change to `"buzz"`
    - `<ESC>` to go back to Normal mode

## Learning Vim

The best way to learn Vim is to learn the fundamentals (what we've covered so far) and then just enable Vim mode in all your software and start using it in practice. Avoid the temptation to use the mouse or the arrow keys; in some editors, you can unbind the arrow keys to force yourself to build good habits.

### Additional resources

- The [Vim lecture](/2020/editors/) from the previous iteration of this class --- we have covered Vim in more depth there
- `vimtutor` is a tutorial that comes installed with Vim --- if Vim is installed, you should be able to run `vimtutor` from your shell
- [Vim Adventures](https://vim-adventures.com/) is a game to learn Vim
- [Vim Tips Wiki](https://vim.fandom.com/wiki/Vim_Tips_Wiki)
- [Vim Advent Calendar](https://vimways.org/2019/) has various Vim tips
- [VimGolf](https://www.vimgolf.com/) is [code golf](https://en.wikipedia.org/wiki/Code_golf), but where the programming language is Vim's UI
- [Vi/Vim Stack Exchange](https://vi.stackexchange.com/)
- [Vim Screencasts](http://vimcasts.org/)
- [Practical Vim](https://pragprog.com/titles/dnvim2/) (book)

[Vim]: https://www.vim.org/

# Code intelligence and language servers

IDEs generally offer language-specific support that requires semantic understanding of the code through IDE extensions that connect to _language servers_ that implement [Language Server Protocol](https://microsoft.github.io/language-server-protocol/). For example, the [Python extension for VS Code](https://marketplace.visualstudio.com/items?itemName=ms-python.python) relies on [Pylance](https://marketplace.visualstudio.com/items?itemName=ms-python.vscode-pylance), and the [Go extension for VS Code](https://marketplace.visualstudio.com/items?itemName=golang.go) relies on the first-party [gopls](https://go.dev/gopls/). By installing the extension and language server for the languages you work with, you can enable many language-specific features in your IDE, such as:

- **Code completion.** Better autocomplete and autosuggest, such as being able to see an object's fields and methods after typing `object.`.
- **Inline documentation.** Seeing documentation on hover and autosuggest.
- **Jump-to-definition.** Jumping from a use site to the definition, such as being able to go from a field reference `object.field` to the definition of the field.
- **Find references.** The inverse of the above, find all sites where a particular item such as a field or type is referenced.
- **Help with imports.** Organizing imports, removing unused imports, flagging missing imports.
- **Code quality.** These tools can be used standalone, but this functionality is often provided by language servers as well. Code formatting auto-indents and auto-formats code, and type checkers and linters find errors in your code, as you type. We will cover this class of functionality in greater depth in the [lecture on code quality](/2026/code-quality/).

## Configuring language servers

For some languages, all you need to do is install the extension and language server, and you'll be all set. For others, to get the maximum benefit from the language server, you need to tell the IDE about your environment. For example, pointing VS Code to your [Python environment](https://code.visualstudio.com/docs/python/environments) will enable the language server to see your installed packages. Environments are covered in more depth in our [lecture on packaging and shipping code](/2026/shipping-code/).

Depending on the language, there might be some settings you can configure for your language server. For example, using the Python support in VS Code, you can disable static type checking for projects that don't make use of Python's optional type annotations.

# AI-powered development

Since the introduction of [GitHub Copilot][github-copilot] using OpenAI's [Codex model](https://openai.com/index/openai-codex/) in mid 2021, [LLMs](https://en.wikipedia.org/wiki/Large_language_model) have become widely adopted in software engineering. There are three main form factors in use right now: autocomplete, inline chat, and coding agents.

[github-copilot]: https://github.com/features/copilot/ai-code-editor

## Autocomplete

AI-powered autocomplete has the same form factor as traditional autocomplete in your IDE, suggesting completions at your cursor position as you type. Sometimes, it's used as a passive feature that "just works". Beyond that, AI autocomplete is generally [prompted](https://en.wikipedia.org/wiki/Prompt_engineering) using code comments.

For example, let's write a script to download the contents of these lecture notes and extract all the links. We can start with:

```python
import requests

def download_contents(url: str) -> str:
```

The model will autocomplete the body of the function:

```python
    response = requests.get(url)
    return response.text
```

We can further guide completions using comments. For example, if we start writing a function to extract all Markdown links, but it doesn't have a particularly descriptive name:

```python
def extract(contents: str) -> list[str]:
```

The model will autocomplete something like this:

```python
    lines = contents.splitlines()
    return [line for line in lines if line.strip()]
```

We can guide the completion through code comments:

```python
def extract(content: str) -> list[str]:
    # extract all Markdown links from the content
```

This time, the model gives a better completion:

```python
    import re
    pattern = r'\[.*?\]\((.*?)\)'
    return re.findall(pattern, content)
```

Here, we see one downside of this AI coding tool: it can only provide completions at the cursor. In this case, it would be better practice to put the `import re` at the module level, rather than inside the function.

The example above used a poorly-named function to demonstrate how code completion can be steered using comments; in practice, you'd want to write code with functions named more descriptively, like `extract_links`, and you'd want to write docstrings (and based on this, the model should generate a completion analogous to the one above).

For demonstration purposes, we can complete the script:

```python
print(extract(download_contents("https://raw.githubusercontent.com/missing-semester/missing-semester/refs/heads/master/_2026/development-environment.md")))
```

## Inline chat

Inline chat lets you select a line or block and then directly prompt the AI model to propose an edit. In this interaction mode, the model can make changes to existing code (which differs from autocomplete, which only completes code beyond the cursor).

Continuing the example from above, suppose we decided not to use the third-party `requests` library. We could select the relevant three lines of code, invoke inline chat, and say something like:

```
use built-in libraries instead
```

The model proposes:

```python
from urllib.request import urlopen

def download_contents(url: str) -> str:
    with urlopen(url) as response:
        return response.read().decode('utf-8')
```

## Coding agents

Coding agents are covered in depth in the [Agentic Coding](/2026/agentic-coding/) lecture.

## Recommended software

Some popular AI IDEs are [VS Code][vs-code] with the [GitHub Copilot][github-copilot] extension and [Cursor](https://cursor.com/). GitHub Copilot is currently available [for free for students](https://github.com/education/students), teachers, and maintainers of popular open source projects. This is a rapidly evolving space. Many of the leading products have roughly equivalent functionality.

# Extensions and other IDE functionality

IDEs are powerful tools, made even more powerful by _extensions_. We can't cover all of these features in a single lecture, but here we provide some pointers to a couple popular extensions. We encourage you to explore this space on your own; there are many lists of popular IDE extensions available online, such as [Vim Awesome](https://vimawesome.com/) for Vim plugins and [VS Code extensions sorted by popularity](https://marketplace.visualstudio.com/search?target=VSCode&category=All%20categories&sortBy=Installs).

- [Development containers](https://containers.dev/): supported by popular IDEs (e.g., [supported by VS Code](https://code.visualstudio.com/docs/devcontainers/containers)), dev containers let you use a container to run development tools. This can be helpful for portability or isolation. The [lecture on packaging and shipping code](/2026/shipping-code/) covers containers in more depth.
- Remote development: do development on a remote machine using SSH (e.g., with the [Remote SSH plugin for VS Code](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-ssh)). This can be handy, for example, if you want to develop and run code on a beefy GPU machine in the cloud.
- Collaborative editing: edit the same file, Google Docs style (e.g., with the [Live Share plugin for VS Code](https://marketplace.visualstudio.com/items?itemName=MS-vsliveshare.vsliveshare)).

# Exercises

1. Enable Vim mode in all the software you use that supports it, such as your editor and your shell, and use Vim mode for all your text editing for the next month. Whenever something seems inefficient, or when you think "there must be a better way", try Googling it, there probably is a better way.
1. Complete a challenge from [VimGolf](https://www.vimgolf.com/).
1. Configure an IDE extension and language server for a project that you're working on. Ensure that all the expected functionality, such as jump-to-definition for library dependencies, works as expected. If you don't have code that you can use for this exercise, you can use some open-source project from GitHub (such as [this one](https://github.com/spf13/cobra)).
1. Browse a list of IDE extensions and install one that seems useful to you.
