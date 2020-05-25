---
layout: lecture
title: "元编程"
details: 构建系统、依赖管理、测试、持续集成
date: 2019-01-27
ready: false
video:
  aspect: 56.25
  id: _Ms1Z4xfqv4
---

{% comment %}
[Reddit Discussion](https://www.reddit.com/r/hackertools/comments/anicor/data_wrangling_iap_2019/)
{% endcomment %}

我们这里说的 “元编程（metaprogramming）” 是什么意思呢？好吧，对于本文要介绍的这些内容，这是我们能够想到的最能概括它们的词。因为我们今天要讲的东西，更多是关于 *流程* ，而不是写代码或更高效的工作。本节课我们会学习构建系统、代码测试以及依赖管理。在您还是学生的时候，这些东西看上去似乎对你来说没那么重要，不过当你开始实习或走进社会的时候，您将会接触到大型的代码库，本节课讲授的这些东西也会变得随处可见。必须要指出的是，“元编程” 也有[用于操作程序的程序](https://en.wikipedia.org/wiki/Metaprogramming)" 之含义，这和我们今天讲座所介绍的概念是完全不同的。

# 构建系统

如果您使用 LaTeX 来编写论文，您需要执行哪些命令才能编译出你想要的论文呢？执行基准测试、绘制图表然后将其插入论文的命令又有哪些？或者，如何编译本课程提供的代码并执行测试呢？

对于大多数系统来说，不论其是否包含代码，都会包含一个“构建过程”。有时，您需要执行一系列操作。通常，这一过程包含了很多步骤，很多分支。执行一些命令来生成图表，然后执行另外的一些命令生成结果，然后在执行其他的命令来生成最终的论文。有很多事情需要我们完成，您并不是第一个因此感到苦恼的人，幸运的是，有很多工具可以帮助我们完成这些操作。

这些工具通常被称为 "构建系统"，而且这些工具还不少。如何选择工具完全取决于您当前手头上要完成的任务以及项目的规模。从本质上讲，这些工具都是非常类似的。您需要定义*依赖*、*目标*和*规则*。您必须告诉构建系统您具体的构建目标，系统的任务则是找到构建这些目标所需要的依赖，并根据规则构建所需的中间产物，直到最终目标被构建出来。理想的情况下，如果目标的依赖没有发生改动，并且我们可以从之前的构建中复用这些依赖，那么与其相关的构建规则并不会被执行。

`make` 是最常用的构建系统之一，您会发现它通常被安装到了几乎所有基于UNIX的系统中。
`make`并不完美，但是对于中小型项目来说，它已经足够好了。当您执行 `make` 时，它会去参考当前目录下名为 `Makefile` 的文件。所有构建目标、相关依赖和规则都需要在该文件中定义，它看上去是这样的：

```make
paper.pdf: paper.tex plot-data.png
	pdflatex paper.tex

plot-%.png: %.dat plot.py
	./plot.py -i $*.dat -o $@
```

这个文件中的指令是即如何使用右侧文件构建左侧文件的规则。或者，换句话说，引号左侧的是构建目标，引号右侧的是构建它所需的依赖。缩进的部分是从依赖构建目标时需要用到的一段程序。在 `make` 中，第一条指令还指明了构建的目的，如果您使用不带参数的 `make`，这便是我们最终的构建结果。或者，您可以使用这样的命令来构建其他目标：`make plot-data.png`。

规则中的 `%` 是一种模式，它会匹配其左右两侧相同的字符串。例如，如果目标是 `plot-foo.png`， `make` 会去寻找 `foo.dat` 和 `plot.py` 作为依赖。现在，让我们看看如果在一个空的源码目录中执行`make` 会发生什么？

```console
$ make
make: *** No rule to make target 'paper.tex', needed by 'paper.pdf'.  Stop.
```

`make` 会告诉我们，为了构建出`paper.pdf`，它需要 `paper.tex`，但是并没有一条规则能够告诉它如何构建该文件。让我们构建它吧！

```console
$ touch paper.tex
$ make
make: *** No rule to make target 'plot-data.png', needed by 'paper.pdf'.  Stop.
```

哟，有意思，我们是**有**构建 `plot-data.png` 的规则的，但是这是一条模式规则。因为源文件`foo.dat` 并不存在，因此 `make` 就会告诉你它不能构建 `plot-data.png`，让我们创建这些文件：

```console
$ cat paper.tex
\documentclass{article}
\usepackage{graphicx}
\begin{document}
\includegraphics[scale=0.65]{plot-data.png}
\end{document}
$ cat plot.py
#!/usr/bin/env python
import matplotlib
import matplotlib.pyplot as plt
import numpy as np
import argparse

parser = argparse.ArgumentParser()
parser.add_argument('-i', type=argparse.FileType('r'))
parser.add_argument('-o')
args = parser.parse_args()

data = np.loadtxt(args.i)
plt.plot(data[:, 0], data[:, 1])
plt.savefig(args.o)
$ cat data.dat
1 1
2 2
3 3
4 4
5 8
```

当我们执行 `make` 时会发生什么？

```console
$ make
./plot.py -i data.dat -o plot-data.png
pdflatex paper.tex
... lots of output ...
```

看！PDF ！

如果再次执行 `make` 会怎样？

```console
$ make
make: 'paper.pdf' is up to date.
```
什么事情都没做！为什么？好吧，因为它什么都不需要做。make回去检查之前的构建是因其依赖改变而需要被更新。让我们试试修改 `paper.tex` 在重新执行 `make`：

```console
$ vim paper.tex
$ make
pdflatex paper.tex
...
```

注意 `make` 并**没有**重新构建 `plot.py`，因为没必要；`plot-data.png` 的所有依赖都没有发生改变。


# 依赖管理

就您的项目来说，它的依赖可能本身也是其他的项目。您也许会依赖某些程序(例如 `python`)、系统包 (例如 `openssl`)或相关编程语言的库(例如 `matplotlib`)。 现在，大多数的依赖可以通过某些**软件仓库**来获取，这些仓库会在一个地方托管大量的依赖，我们则可以通过一套非常简单的机制来安装依赖。例如 Ubuntu 系统下面有Ubuntu软件包仓库，您可以通过`apt` 这个工具来访问， RubyGems 则包含了 Ruby 的相关库，PyPi 包含了 Python 库， Arch Linux 用户贡献的库则可以在 Arch User Repository 中找到。

由于每个仓库、每种工具的运行机制都不太一样，因此我们并不会在本节课深入讲解具体的细节。我们会介绍一些通用的术语，例如*版本控制*。大多数被其他项目所依赖的项目都会在每次发布新版本时创建一个*版本号*。通常看上去像 8.1.3 或 64.1.20192004。版本号一般是数字构成的，但也并不绝对。版本号有很多用途，其中最重要的作用是保证软件能够运行。试想一下，加入我的库要发布一个新版本，在这个版本里面我重命名了某个函数。如果有人在我的库升级版本后，仍希望基于它构建新的软件，那么很可能构建会失败，因为它希望调用的函数已经不复存在了。有了版本控制就可以很好的解决这个问题，我们可以指定当前项目需要基于某个版本，甚至某个范围内的版本，或是某些项目来构建。这么做的话，即使某个被依赖的库发生了变化，依赖它的软件可以基于其之前的版本进行构建。

That also isn't ideal though! What if I issue a security update which
does _not_ change the public interface of my library (its "API"), and
which any project that depended on the old version should immediately
start using? This is where the different groups of numbers in a version
come in. The exact meaning of each one varies between projects, but one
relatively common standard is [_semantic
versioning_](https://semver.org/). With semantic versioning, every
version number is of the form: major.minor.patch. The rules are:

 - If a new release does not change the API, increase the patch version.
 - If you _add_ to your API in a backwards-compatible way, increase the
   minor version.
 - If you change the API in a non-backwards-compatible way, increase the
   major version.

This already provides some major advantages. Now, if my project depends
on your project, it _should_ be safe to use the latest release with the
same major version as the one I built against when I developed it, as
long as its minor version is at least what it was back then. In other
words, if I depend on your library at version `1.3.7`, then it _should_
be fine to build it with `1.3.8`, `1.6.1`, or even `1.3.0`. Version
`2.2.4` would probably not be okay, because the major version was
increased. We can see an example of semantic versioning in Python's
version numbers. Many of you are probably aware that Python 2 and Python
3 code do not mix very well, which is why that was a _major_ version
bump. Similarly, code written for Python 3.5 might run fine on Python
3.7, but possibly not on 3.4.

When working with dependency management systems, you may also come
across the notion of _lock files_. A lock file is simply a file that
lists the exact version you are _currently_ depending on of each
dependency. Usually, you need to explicitly run an update program to
upgrade to newer versions of your dependencies. There are many reasons
for this, such as avoiding unnecessary recompiles, having reproducible
builds, or not automatically updating to the latest version (which may
be broken). And extreme version of this kind of dependency locking is
_vendoring_, which is where you copy all the code of your dependencies
into your own project. That gives you total control over any changes to
it, and lets you introduce your own changes to it, but also means you
have to explicitly pull in any updates from the upstream maintainers
over time.

# Continuous integration systems

As you work on larger and larger projects, you'll find that there are
often additional tasks you have to do whenever you make a change to it.
You might have to upload a new version of the documentation, upload a
compiled version somewhere, release the code to pypi, run your test
suite, and all sort of other things. Maybe every time someone sends you
a pull request on GitHub, you want their code to be style checked and
you want some benchmarks to run? When these kinds of needs arise, it's
time to take a look at continuous integration.

Continuous integration, or CI, is an umbrella term for "stuff that runs
whenever your code changes", and there are many companies out there that
provide various types of CI, often for free for open-source projects.
Some of the big ones are Travis CI, Azure Pipelines, and GitHub Actions.
They all work in roughly the same way: you add a file to your repository
that describes what should happen when various things happen to that
repository. By far the most common one is a rule like "when someone
pushes code, run the test suite". When the event triggers, the CI
provider spins up a virtual machines (or more), runs the commands in
your "recipe", and then usually notes down the results somewhere. You
might set it up so that you are notified if the test suite stops
passing, or so that a little badge appears on your repository as long as
the tests pass.

As an example of a CI system, the class website is set up using GitHub
Pages. Pages is a CI action that runs the Jekyll blog software on every
push to `master` and makes the built site available on a particular
GitHub domain. This makes it trivial for us to update the website! We
just make our changes locally, commit them with git, and then push. CI
takes care of the rest.

## 测试简介

多数的大型软件都有“测试套”。您可能已经对测试的相关概念有所了解，但是我们觉得有些测试方法和测试术语还是应该再次提醒一下：

 - 测试套：所有测试的统称
 - 单元测试：一个“微型测试”，用于对某个封装的特性进行测试
 - 集成测试：: 一个“宏观测试”，针对系统的某一大部分进行，测试其不同的特性或组件是否能*协同*工作。
 - 回归测试：用于保证之前引起问题的 bug 不会再次出现
 - 模拟（Mocking）: 使用一个假的实现来替换函数、模块或类型，屏蔽那些和测试不相关的内容。例如，您可能会“模拟网络连接” 或 “模拟硬盘”


# 课后练习

 1. Most makefiles provide a target called `clean`. This isn't intended
    to produce a file called `clean`, but instead to clean up any files
    that can be re-built by make. Think of it as a way to "undo" all of
    the build steps. Implement a `clean` target for the `paper.pdf`
    `Makefile` above. You will have to make the target
    [phony](https://www.gnu.org/software/make/manual/html_node/Phony-Targets.html).
    You may find the [`git
    ls-files`](https://git-scm.com/docs/git-ls-files) subcommand useful.
    A number of other very common make targets are listed
    [here](https://www.gnu.org/software/make/manual/html_node/Standard-Targets.html#Standard-Targets).
 2. Take a look at the various ways to specify version requirements for
    dependencies in [Rust's build
    system](https://doc.rust-lang.org/cargo/reference/specifying-dependencies.html).
    Most package repositories support similar syntax. For each one
    (caret, tilde, wildcard, comparison, and multiple), try to come up
    with a use-case in which that particular kind of requirement makes
    sense.
 3. Git can act as a simple CI system all by itself. In `.git/hooks`
    inside any git repository, you will find (currently inactive) files
    that are run as scripts when a particular action happens. Write a
    [`pre-commit`](https://git-scm.com/docs/githooks#_pre_commit) hook
    that runs `make paper.pdf` and refuses the commit if the `make`
    command fails. This should prevent any commit from having an
    unbuildable version of the paper.
 4. Set up a simple auto-published page using [GitHub
    Pages](https://help.github.com/en/actions/automating-your-workflow-with-github-actions).
    Add a [GitHub Action](https://github.com/features/actions) to the
    repository to run `shellcheck` on any shell files in that
    repository (here is [one way to do
    it](https://github.com/marketplace/actions/shellcheck)). Check that
    it works!
 5. [Build your
    own](https://help.github.com/en/actions/automating-your-workflow-with-github-actions/building-actions)
    GitHub action to run [`proselint`](http://proselint.com/) or
    [`write-good`](https://github.com/btford/write-good) on all the
    `.md` files in the repository. Enable it in your repository, and
    check that it works by filing a pull request with a typo in it.
