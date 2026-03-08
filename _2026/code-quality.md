---
layout: lecture
title: "Code Quality"
description: >
  Learn about formatting, linting, testing, continuous integration, and more.
thumbnail: /static/assets/thumbnails/2026/lec9.png
date: 2026-01-23
ready: true
video:
  aspect: 56.25
  id: XBiLUNx84CQ
---

There are a variety of tools and techniques that support developers in writing high-quality code. In this lecture, we'll cover:

- [Formatting](#formatting)
- [Linting](#linting)
- [Testing](#testing)
- [Pre-commit hooks](#pre-commit-hooks)
- [Continuous integration](#continuous-integration)
- [Command runners](#command-runners)

As a bonus topic, we'll also cover [regular expressions](#regular-expressions), a cross-cutting topic that has applications in code quality (e.g., for running a subset of tests that match a pattern) as well as other domains like IDEs (e.g., for search and replace).

Many of these tools will be language-specific (e.g., the [Ruff](https://docs.astral.sh/ruff/) linter/formatter for Python). In some cases, tools will support multiple languages (e.g., the [Prettier](https://prettier.io/) code formatter). The concepts, however, are near universal --- you can find code formatters, linters, testing libraries, and so on for any programming language.

# Formatting

Code auto-formatters automatically prettify surface syntax. This way, you can focus on the more deep and challenging problems, while the auto-formatting tool handles mundane details such as consistency of `'` versus `"` syntax for strings, having spaces surrounding binary operators (`x + y` instead of `x+y`), having `import` statements in sorted order, and avoiding over-length lines. One major benefit of code formatters is that they standardize code style across all developers working on a codebase.

Some tools such as Prettier are [highly configurable](https://prettier.io/docs/configuration); you should check in the configuration file into [version control](/2026/version-control/) for your project. Other tools, such as [Black](https://github.com/psf/black) and [gofmt](https://pkg.go.dev/cmd/gofmt) have limited or no configurability, to reduce [bikeshedding](https://en.wikipedia.org/wiki/Law_of_triviality).

You can set up [IDE integration](/2026/development-environment/#code-intelligence-and-language-servers) with your code formatter, so that your code will be auto-formatted as you type or when you save a file. You can also add an [EditorConfig](https://editorconfig.org/) file to your project, which communicates to your IDE certain project-level settings like indent size for each file type.

# Linting

Linters run static analysis (analyze your code without running it) to find antipatterns and potential issues in your code. These tools go deeper than autoformatters, looking beyond surface syntax. The level of depth of analysis varies by tool.

Linters come equipped with lists of _rules_, with presets that can be configured on a project-level basis. Some linter rules produce false positives, so you can disable them on a per-file or per-line basis.

Good linters will have built-in help or documentation that explains each linter rule --- what the rule is looking for, why it's bad, and what's a better alternative for the code pattern. For example, see the documentation for the [SIM102](https://docs.astral.sh/ruff/rules/collapsible-if/) rule in [Ruff](https://docs.astral.sh/ruff/) which catches unnecessarily nested `if` statements in Python code.

Some linters can not only flag issues but also automatically fix certain issues for you.

Aside from language-specific linters, another tool that might come in handy is [semgrep](https://github.com/semgrep/semgrep), a "semantic grep" tool that works at the AST level (rather than character level, like grep) and supports many languages. You can use semgrep to easily write custom linter rules for your projects. For example, if you wanted to prevent the dangerous `subprocess.Popen(..., shell=True)` in Python, you could find that code pattern with:

```bash
semgrep -l python -e "subprocess.Popen(..., shell=True, ...)"
```

# Testing

Software testing is a standard technique to increase your confidence in the correctness of your code. You write code, and then you write code that exercises the code you wrote and raises an error if the code doesn't work as expected.

You can write tests for chunks of code at different levels of granularity: _unit tests_ for individual functions, _integration tests_ for interaction between modules or services, and _functional tests_ for end-to-end scenarios. You can do _test-driven development_, where you write tests before you write any implementation code. When you find bugs in your code, you can write _regression tests_, so you'll catch if the functionality ever breaks in the future. You can write _property-based tests_, pioneered in [QuickCheck](https://hackage.haskell.org/package/QuickCheck) in Haskell, and implemented in many libraries, like [Hypothesis](https://hypothesis.readthedocs.io/) for Python. Which approach to testing is right depends on your project; likely, you will adopt some combination.

If your program has external dependencies like a database or web API, it may be helpful to _mock_ those dependencies in your tests, rather than have your code interact with third-party dependencies at test time.

## Code coverage

Code coverage is a metric by which you can measure how good your tests are. Code coverage looks at which lines of your code are executed when your tests are run, so you can ensure you are covering all code paths. Code coverage tools can show you line-by-line coverage to guide you in writing tests. Services such as [Codecov](https://app.codecov.io) provide web interfaces for tracking and viewing code coverage over the history of a project.

Like any metric, code coverage is not perfect; don't over-index on coverage, focus on writing high-quality tests.

# Pre-commit hooks

Git pre-commit [hooks](https://git-scm.com/book/en/v2/Customizing-Git-Git-Hooks), made easier by the [pre-commit](https://pre-commit.com/) framework, automatically run user-specified code prior to every Git commit. Projects commonly use pre-commit hooks to run formatters and linters, and sometimes tests, automatically before every commit, to ensure that committed code matches the project code style and is free of certain issues.

# Continuous integration

Continuous integration (CI) services like [GitHub Actions](https://github.com/features/actions) can run scripts for you every time you push code (or on every pull request, or on a schedule). Developers commonly use CI services to run code quality tools including formatters, linters, and tests. For compiled languages, you can ensure code compiles; for statically typed languages, you can make sure it type checks. Running CI every push of new commits can catch errors introduced into the main version of the code; running on pull requests can catch issues with contributor submissions; running on a schedule can catch issues with external dependencies (e.g., a developer accidentally releases a breaking change as [semver-compatible](/2026/shipping-code/#releases--versioning)).

Because CI scripts run separately from developer machines, you can easily run long-running jobs there. This can be leveraged, for example, to run a _matrix_ of tests across different operating systems and programming language versions to ensure that the software works properly across all of them.

Generally, the script running in CI will not directly make changes to your code: it will run tools in "check-only" mode rather than "fix" mode, so for example, the auto-formatter will raise an error when the code is not compliant with the format.

Repositories often include [status badges](https://docs.github.com/en/actions/how-tos/monitor-workflows/add-a-status-badge) in their README, showing CI status and other information such as code coverage. For example, below is Missing Semester's current build status.

[![Build Status](https://github.com/missing-semester/missing-semester/actions/workflows/build.yml/badge.svg)](https://github.com/missing-semester/missing-semester/actions/workflows/build.yml) [![Links Status](https://github.com/missing-semester/missing-semester/actions/workflows/links.yml/badge.svg)](https://github.com/missing-semester/missing-semester/actions/workflows/links.yml)

> Our [links checker](https://github.com/missing-semester/missing-semester/blob/master/.github/workflows/links.yml), which uses the [proof-html](https://github.com/anishathalye/proof-html) GitHub Action is often failing, usually due to issues with third-party websites. Still, it has helped us catch and fix many broken links (sometimes due to typos, most of the time due to websites moving around content without adding redirects or websites disappearing).

A good way to learn the particulars of CI services, formatters, linters, and testing libraries is by example. Find high-quality open-source projects on GitHub---the more similar to your project in programming language, domain, size and scope, and so on, the better---and study their `pyproject.toml`, `.github/workflows/`, `DEVELOPMENT.md`, and other relevant files.

## Continuous deployment

Continuous deployment makes use of CI infrastructure to actually _deploy_ changes. For example, the Missing Semester repository uses continuous deployment to GitHub pages so that whenever we `git push` updated lecture notes, the site is automatically built and deployed. You can build other types of [artifacts](/2026/shipping-code/) in CI, such as binaries for applications or Docker images for services.

# Command runners

Command runners like [just](https://github.com/casey/just) simplify the task of running commands in the context of a project. As you build up code quality infrastructure for your project, you don't want to make your developers memorize commands like `uv run ruff check --fix`. With a command runner, this can turn into `just lint`, and you can have analogous invocations like `just format`, `just typecheck`, etc., for all the different tools a developer might want to run for your project.

Some language-specific project or package managers have built-in support for such functionality, which means you don't need to use a language-agnostic tool like `just`. For example, the `scripts` section of a `package.json` for [npm](https://nodejs.org/en/learn/getting-started/an-introduction-to-the-npm-package-manager) (Node.js) and the `tool.hatch.envs.*.scripts` sections of a `pyproject.toml` for [Hatch](https://hatch.pypa.io/) (Python) support this functionality.

# Regular expressions

_Regular expressions_, commonly abbreviated as "regex", is a language used to represent sets of strings. Regex patterns are commonly used for pattern matching in various contexts such as command-line tools and IDEs. For example, [ag](https://github.com/ggreer/the_silver_searcher) supports regex patterns for codebase-wide search (e.g., `ag "import .* as .*"` will find all renamed imports in Python), and [go test](https://pkg.go.dev/cmd/go#hdr-Test_packages) supports a `-run [regexp]` option for selecting a subset of tests. Furthermore, programming languages have built-in support or third-party libraries for regular expression matching, so you can use regexes for functionality such as pattern matching, validation, and parsing.

To help build intuition, below are some examples of regex patterns. In this lecture, we use [Python regex syntax](https://docs.python.org/3/library/re.html). There are many flavors of regex, with slight variation between them, especially in the more sophisticated functionality. You can use an online regex tester like [regex101](https://regex101.com/) to develop and debug regular expressions.

- `abc` --- matches the literal "abc".
- `missing|semester` --- matches the string "missing" or the string "semester".
- `\d{4}-\d{2}-\d{2}` --- matches dates in YYYY-MM-DD format, such as "2026-01-14". Beyond ensuring that the string consists of four digits, a dash, two digits, a dash, and two digits, this does not validate the date, so "2026-01-99" matches this regex pattern too.
- `.+@.+` --- matches email addresses, strings that contain some text, then an "@", and then some more text. This does only the most basic validation and matches strings like "nonsense@@@email". A regex that matches email addresses with no false positives or negatives [exists](https://pdw.ex-parrot.com/Mail-RFC822-Address.html) but is impractical.

## Regex syntax

You can find a comprehensive guide to regex syntax in [this documentation](https://docs.python.org/3/library/re.html#regular-expression-syntax) (or one of many other resources available online). Here are some of the basic building blocks:

- `abc` matches the literal string, when the characters have no special meaning (in this example, "abc")
- `.` matches any single character
- `[abc]` matches a single character contained in the brackets (in this example, "a", "b", or "c")
- `[^abc]` matches a single character except those contained in the brackets (e.g., "d")
- `[a-f]` matches a single character contained in the range indicated in the brackets (e.g., "c", but not "q")
- `a|b` matches either pattern (e.g., "a" or "b")
- `\d` matches any digit character (e.g., "3")
- `\w` matches any word character (e.g., "x")
- `\b` matches any word _boundary_ (e.g., in the string "missing semester", matches just before the "m", just after the "g", just before the "s", and just after the "r")
- `(...)` matches the group of a pattern
- `...?` matches zero or one of a pattern, such as `words?` to match "word" or "words"
- `...*` matches any number of a pattern, such as `.*` to match any number of any character
- `...+` matches one or more of a pattern, such as `\d+` to match any non-zero number of digits
- `...{N}` matches exactly N of a pattern, such as `\d{4}` for 4 digits
- `\.` matches a literal "."
- `\\` matches a literal "\\"
- `^` matches the start of the line
- `$` matches the end of the line

## Capture groups and references

If you use regex groups `(...)`, you can refer to sub-parts of the match for extraction or search-and-replace purposes. For example, to extract just the month from a YYYY-MM-DD style date, you can use the following Python code:

```python
>>> import re
>>> re.match(r"\d{4}-(\d{2})-\d{2}", "2026-01-14").group(1)
'01'
```

In your text editor, you can use reference capture groups in replace patterns. The syntax might vary between IDEs. For example, in VS Code, you can use variables like `$1`, `$2`, etc., and in Vim, you can use `\1`, `\2`, etc., to reference groups.

## Limitations

[Regular languages](https://en.wikipedia.org/wiki/Regular_language) are powerful but limited; there are classes of strings that cannot be expressed as a standard regex (e.g., it is [not possible](https://en.wikipedia.org/wiki/Pumping_lemma_for_regular_languages) to write a regular expression that matches the set of strings {a^n b^n \| n &ge; 0}, the set of strings of a number of "a"s followed by the same number of "b"s; more practically, languages like HTML are not regular languages). In practice, modern regex engines support features like lookahead and backreferences that extend support beyond regular languages, and they are practically extremely useful, but it is important to know that they are still limited in their expressive power. For more sophisticated languages, you might need to reach for a more capable type of parser (for one example, see [pyparsing](https://github.com/pyparsing/pyparsing), a [PEG](https://en.wikipedia.org/wiki/Parsing_expression_grammar) parser).

## Learning regex

We recommend learning the fundamentals (what we have covered in this lecture), and then looking at regex references as you need them, rather than memorizing the entirety of the language.

Conversational AI tools can be effective at helping you generating regex patterns. For example, try prompting your favorite LLM with the following query:

```
Write a Python-style regex pattern that matches the requested path from log lines from Nginx. Here is an example log line:

169.254.1.1 - - [09/Jan/2026:21:28:51 +0000] "GET /feed.xml HTTP/2.0" 200 2995 "-" "python-requests/2.32.3"
```

# Exercises

1. Configure a formatter, linter, and pre-commit hooks for a project you're working on. If you have lots of errors: autoformatting should take care of the format errors. For the linter errors, try using an [AI agent](/2026/agentic-coding/) to fix all the linter errors. Make sure the AI agent can run the linter and observe the results, so that it can run in an iterative loop to fix all the issues. Check the results carefully to ensure the AI doesn't break your code!
1. Learn a testing library for a language you know and write a unit test for a project you're working on. Run a code coverage tool, generate an HTML-formatted coverage report, and observe the results. Can you find the lines that are covered? Your code coverage will likely be very low. Try manually writing some tests to improve it. Try using an [AI agent](/2026/agentic-coding/) to improve coverage; make sure the coding agent can run tests with coverage and produce a line-by-line coverage report, so it knows where to focus. Are the AI-generated tests actually good?
1. Set up continuous integration to run on every push for a project you're working on. Have CI run formatting, linting, and tests. Break your code on purpose (e.g., introduce a linter violation), and ensure that CI catches it.
1. Try writing a [regex pattern](#regular-expressions) and use the `grep` [command-line tool](/2026/course-shell/) to find occurrences of `subprocess.Popen(..., shell=True)` in your code. Now, try to "break" the regex pattern. Does [semgrep](#linting) still successfully match the dangerous code that trips up your grep invocation?
1. Practice regex search-and-replace in your IDE or text editor by replacing the `-` [Markdown bullet markers](https://spec.commonmark.org/0.31.2/#bullet-list-marker) with `*` bullet markers in [these lecture notes](https://raw.githubusercontent.com/missing-semester/missing-semester/refs/heads/master/_2026/code-quality.md). Note that just replacing all the "-" characters in the file would be incorrect, as there are many uses of that character that are not bullet markers.
1. Write a regex to capture from JSON structures of the form `{"name": "Alyssa P. Hacker", "college": "MIT"}` the name (e.g., `Alyssa P. Hacker`, in this example). Hint: in your first attempt, you might end up writing a regex that extracts `Alyssa P. Hacker", "college": "MIT`; read about greedy quantifiers in the [Python regex docs](https://docs.python.org/3/library/re.html) to figure out how to fix it.
    1. Make the regex pattern work even in situations where the name has a `"` character in it (double quotes can be escaped in JSON with `\"`).
    1. We do **not** recommend using regular expressions for sophisticated parsing problems in practice. Figure out how to use your programming language's JSON parser for this task. Write a command-line program that takes as input, on stdin, a JSON structure of the form described above, and output, on stdout, the name. You should only need a couple lines of code to do this. In Python, you can do it easily in one line of code beyond `import json`.
