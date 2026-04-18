---
layout: lecture
title: "Packaging and Shipping Code"
description: >
  Learn about project packaging, environments, versioning, and deploying libraries, applications, and services.
thumbnail: /static/assets/thumbnails/2026/lec6.png
date: 2026-01-20
ready: true
video:
  aspect: 56.25
  id: KBMiB-8P4Ns
---

让代码按照预期状况运行很困难，而让同样的代码在不同于自己的机器上开发则更为困难。

Getting code to work as intended is hard; getting that same code to run on a machine different from your own is often harder.

交付代码意味着将你编写的代码转换成一种可用的形式，使其他人可以在没有你计算机的精确设置下运行它。
交付代码有多种形式，取决于编程语言、系统库和操作系统等许多因素。
它还取决于你构建的内容：软件库、命令行工具或网络服务都有不同的需求和部署步骤。
无论如何，所有这些场景之间都有一个共同模式：我们需要定义可交付物是什么——也就是所谓的“制品”——以及它对周围环境所做的假设。

Shipping code means taking the code you wrote and converting it into a usable form that someone else can run without your computer's exact setup.
Shipping code takes many forms and depends on the choices of programming language, system libraries, and operating system, among many other factors.
It also depends on what you are building: a software library, a command line tool, and a web service all have different requirements and deployment steps.
Regardless, there is a common pattern between all these scenarios: we need to define what the deliverable is --- a.k.a. the _artifact_ --- and what assumptions it makes about the environment around it.

在本节课中，我们会涉及:

In this lecture, we'll cover:

- [依赖关系和环境](#dependencies--environments)
- [制品和打包](#artifacts--packaging)
- [发布和版本管理](#releases--versioning)
- [可复现性](#reproducibility)
- [虚拟机和容器](#vms--containers)
- [配置](#configuration)
- [服务和编排](#services--orchestration)
- [发布流程](#publishing)

- [Dependencies & Environments](#dependencies--environments)
- [Artifacts & Packaging](#artifacts--packaging)
- [Releases & Versioning](#releases--versioning)
- [Reproducibility](#reproducibility)
- [VMs & Containers](#vms--containers)
- [Configuration](#configuration)
- [Services & Orchestration](#services--orchestration)
- [Publishing](#publishing)

考虑到具体的实例有助于理解，我们会通过来自 Python 生态的例子解释这些概念，。尽管对于其他的编程语言生态而言工具有所不同，这些概念在很大程度上都是相同的。

We'll explain these concepts through examples from the Python ecosystem, as concrete examples are helpful for understanding. While the tools are different for other programming language ecosystems, the concepts will largely be the same.

# 依赖关系和环境

# Dependencies & Environments

在现代软件开发中，抽象层无处不在。
程序很自然地将逻辑委托给其他库或服务。
然而，这会在程序与其运行所必需的库之间引入一种 _依赖_ 关系。
例如，在 Python 中，要获取一个网站的内容，我们通常这样做：

In modern software development, layers of abstraction are ubiquitous.
Programs naturally offload logic to other libraries or services.
However, this introduces a _dependency_ relationship between your program and the libraries it requires to function.
For instance, in Python, to fetch the content of a website we often do:

```python
import requests

response = requests.get("https://missing.csail.mit.edu")
```

但 `requests` 库并未随 Python 运行时预装，因此如果我们尝试在未安装 `requests` 的情况下运行此代码，Python 将抛出一个错误：

Yet the `requests` library does not come bundled with the Python runtime, so if we try to run this code without having `requests` installed, Python will raise an error:

```console
$ python fetch.py
Traceback (most recent call last):
  File "fetch.py", line 1, in <module>
    import requests
ModuleNotFoundError: No module named 'requests'
```

要使此库可用，我们需要首先运行 `pip install requests` 来安装它。
`pip` 是 Python 编程语言提供的用于安装包的命令行工具。
执行 `pip install requests` 会产生以下一系列操作：

To make this library available we need to first run `pip install requests` to install it.
`pip` is the command line tool that the Python programming language provides for installing packages.
Executing `pip install requests` produces the following sequence of actions:

1. 在 Python 包索引 (Python Package Index，故缩写为 `PyPI`)（[PyPI](https://pypi.org/)）中搜索 `requests`。
2. 为我们运行所在的平台搜索合适的制品。
3. 解析依赖关系 —— `requests` 库本身依赖于其他包，因此安装程序必须找到所有传递依赖的兼容版本，并预先安装它们。
4. 下载制品，然后解压并将文件复制到文件系统中的正确位置。

1. Search for requests in the Python Package Index ([PyPI](https://pypi.org/))
1. Search for the appropriate artifact for the platform we are running under
1. Resolve dependencies --- the `requests` library itself depends on other packages, so the installer must find compatible versions of all transitive dependencies and install them beforehand
1. Download the artifacts, then unpack and copy the files into the right places in our filesystem

```console
$ pip install requests
Collecting requests
  Downloading requests-2.32.3-py3-none-any.whl (64 kB)
Collecting charset-normalizer<4,>=2
  Downloading charset_normalizer-3.4.0-cp311-cp311-manylinux_x86_64.whl (142 kB)
Collecting idna<4,>=2.5
  Downloading idna-3.10-py3-none-any.whl (70 kB)
Collecting urllib3<3,>=1.21.1
  Downloading urllib3-2.2.3-py3-none-any.whl (126 kB)
Collecting certifi>=2017.4.17
  Downloading certifi-2024.8.30-py3-none-any.whl (167 kB)
Installing collected packages: urllib3, idna, charset-normalizer, certifi, requests
Successfully installed certifi-2024.8.30 charset-normalizer-3.4.0 idna-3.10 requests-2.32.3 urllib3-2.2.3
```

由此我们可以看到，`requests` 拥有自身的依赖项，例如 `certifi` 或 `charset-normalizer`，这些依赖必须在安装 `requests` 之前先行安装。
一旦安装完成，Python 运行时便能在导入时找到这个库。

Here we can see that `requests` has its own dependencies such as `certifi` or `charset-normalizer` and that they have to be installed before `requests` can be installed.
Once installed, the Python runtime can find this library when importing it.

```console
$ python -c 'import requests; print(requests.__path__)'
['/usr/local/lib/python3.11/dist-packages/requests']

$ pip list | grep requests
requests        2.32.3
```

不同编程语言在安装和发布库方面拥有不同的工具、惯例与实践方式。
在一些语言 (例如 Rust) 中，工具链是统一的 —— `cargo` 负责构建、测试、依赖管理和发布。
而在其他的语言（例如 Python）中，统一发生在规范层面 —— 并非依赖单一工具，而是通过标准化的规范来定义打包机制，从而允许每个任务存在多个相互竞争的工具（例如 `pip` 与 [`uv`](https://docs.astral.sh/uv/)、`setuptools` 与 [`hatch`](https://hatch.pypa.io/) 或 [`poetry`](https://python-poetry.org/)）。
此外，在某些生态（如 LaTeX）中，像 TeX Live 或 MacTeX 这样的发行版则会预先捆绑安装数千个包。

Programming languages have different tools, conventions and practices for installing and publishing libraries.
In some languages like Rust, the toolchain is unified --- `cargo` handles building, testing, dependency management, and publishing.
In others like Python, the unification happens at a specification level --- rather than a single tool, there are standardized specifications that define how packaging works, allowing multiple competing tools for each task (`pip` vs [`uv`](https://docs.astral.sh/uv/), `setuptools` vs [`hatch`](https://hatch.pypa.io/) vs [`poetry`](https://python-poetry.org/)).
And in some ecosystems like LaTeX, distributions like TeX Live or MacTeX come bundled with thousands of packages pre-installed.

引入依赖关系的同时也会带来依赖冲突。
当程序需要同一依赖的不兼容版本时，就会发生冲突。
例如，如果 `tensorflow==2.3.0` 要求 `numpy>=1.16.0,<1.19.0` 而 `pandas==1.2.0` 要求 `numpy>=1.16.5`，那么任何满足 `numpy>=1.16.5,<1.19.0` 的版本都是有效的。
但如果项目中的另一个包要求 `numpy>=1.19`，那么就会产生冲突，因为没有任何版本能满足所有约束。

Introducing dependencies also introduces dependency conflicts.
Conflicts happen when programs require incompatible versions of the same dependency.
For example, if `tensorflow==2.3.0` requires `numpy>=1.16.0,<1.19.0` and `pandas==1.2.0`  requires `numpy>=1.16.5`, then any version satisfying `numpy>=1.16.5,<1.19.0` will be valid.
But if another package in your project requires `numpy>=1.19`, you have a conflict with no valid version that satisfies all constraints.

这种多个包对共享依赖要求互不兼容版本的情况，通常被称为 _依赖地狱_。
处理冲突的一种方法是将每个程序的依赖隔离到其各自的 _环境_ 中。
在 Python 中，我们可以通过运行以下命令创建虚拟环境：

This situation --- where multiple packages require mutually incompatible versions of shared dependencies --- is commonly referred to as _dependency hell_.
One way to deal with conflicts is to isolate the dependencies of each program into their own _environment_.
In Python we create a virtual environment by running:

```console
$ which python
/usr/bin/python
$ pwd
/home/missingsemester
$ python -m venv venv
$ source venv/bin/activate
$ which python
/home/missingsemester/venv/bin/python
$ which pip
/home/missingsemester/venv/bin/pip
$ python -c 'import requests; print(requests.__path__)'
['/home/missingsemester/venv/lib/python3.11/site-packages/requests']

$ pip list
Package Version
------- -------
pip     24.0
```

可以将环境视为一个完全独立的语言运行时版本，它拥有自己的一套已安装包。
这种虚拟环境（venv）将已安装的依赖与全局 Python 环境隔离开来。
为每个项目建立独立的虚拟环境以容纳其所需依赖，是一种良好实践。

You can think of an environment as an entire standalone version of the language runtime with its own set of installed packages.
This virtual environment or venv isolates the installed dependencies from the global Python installation.
It is a good practice to have a virtual environment for each project, containing the dependencies it requires.

> 许多现代操作系统虽然预装了 Python 等编程语言运行时，但直接修改这些系统自带的版本是不明智的，因为操作系统本身的功能可能依赖于它们。更推荐的做法是使用独立的环境。

> While many modern operating systems ship with installations of programming language runtimes like Python, it is unwise to modify these installations since the OS might rely on them for its own functionality. Prefer using separate environments instead.

在某些语言中，安装协议并非由单一工具定义，而是以规范形式存在。
Python 的 [PEP 517](https://peps.python.org/pep-0517/) 定义了构建系统接口，[PEP 621](https://peps.python.org/pep-0621/) 则规定了如何将项目元数据存储在 `pyproject.toml` 中。
这使得开发者能够改进 `pip` 并创建出更优化的工具，例如 `uv`。安装 `uv` 只需执行 `pip install uv` 即可。

In some languages, the installation protocol is not defined by a tool but as a specification.
In Python [PEP 517](https://peps.python.org/pep-0517/) defines the build system interface and [PEP 621](https://peps.python.org/pep-0621/) specifies how project metadata is stored in `pyproject.toml`.
This has enabled developers to improve upon `pip` and produce more optimized tools like `uv`. To install `uv` it suffices to do `pip install uv`.

使用 `uv` 替代 `pip` 时，其接口保持一致，但速度显著更快：
Using `uv` instead of `pip` follows the same interface but is significantly faster:

```console
$ uv pip install requests
Resolved 5 packages in 12ms
Prepared 5 packages in 0.45ms
Installed 5 packages in 8ms
 + certifi==2024.8.30
 + charset-normalizer==3.4.0
 + idna==3.10
 + requests==2.32.3
 + urllib3==2.2.3
```

> 我们强烈建议尽可能使用 `uv pip` 而非 `pip`，因为它能显著缩短安装时间。

> We strongly recommend using `uv pip` instead of `pip` whenever possible as it dramatically reduces the installation time.

除了依赖隔离之外，环境还允许您使用不同版本的编程语言运行时。

Beyond dependency isolation, environments also allow you to have different versions of your programming language runtime.

```console
$ uv venv --python 3.12 venv312
Using CPython 3.12.7
Creating virtual environment at: venv312

$ source venv312/bin/activate && python --version
Python 3.12.7

$ uv venv --python 3.11 venv311
Using CPython 3.11.10
Creating virtual environment at: venv311

$ source venv311/bin/activate && python --version
Python 3.11.10
```

这在你需要跨多个Python版本测试代码，或者项目需要特定版本时很有帮助。

This helps when you need to test your code across multiple Python versions or when a project requires a specific version.

> 在某些编程语言中，每个项目会自动获得其依赖项的独立环境，而无需手动创建，但原理是相同的。如今大多数语言也都具备在单个系统上管理多个语言版本的机制，并可为各个项目指定所使用的版本。

> In some programming languages, each project automatically gets its own environment for its dependencies rather than you creating it manually, but the principle is the same. Most languages these days also have a mechanism for managing multiple versions of the language on a single system, and then specifying which version to use for individual projects.

# 制品与打包

# Artifacts & Packaging

在软件开发中，我们区分源代码和制品。开发者编写和阅读源代码，而制品则是由该源代码生成的、可打包分发的输出物——可供安装或部署。
制品可以简单到仅是一个我们运行的代码文件，也可以复杂到包含应用程序所有必要组件的完整虚拟机。
考虑以下示例，我们在当前目录中有一个Python文件`greet.py`：

In software development we differentiate between source code and artifacts. Developers write and read source code, while artifacts are the packaged, distributable outputs produced from that source code --- ready to be installed or deployed.
An artifact can be as simple as a file of code that we run, and as complex as an entire Virtual Machine that contains all the necessary bits and bobs of an application.
Consider this example where we have a Python file `greet.py` in our current directory:

```console
$ cat greet.py
def greet(name):
    return f"Hello, {name}!"

$ python -c "from greet import greet; print(greet('World'))"
Hello, World!

$ cd /tmp
$ python -c "from greet import greet; print(greet('World'))"
ModuleNotFoundError: No module named 'greet'
```

当我们移动到不同目录时，导入会失败，因为Python只在特定位置（当前目录、已安装的包以及`PYTHONPATH`中的路径）搜索模块。打包通过将代码安装到已知位置来解决这个问题。

The import fails once we move to a different directory because Python only searches for modules in specific locations (the current directory, installed packages, and paths in `PYTHONPATH`). Packaging solves this by installing the code into a known location.

在Python中，打包库涉及生成一个制品，供`pip`或`uv`等包安装器使用以安装相关文件。
Python制品称为_wheels_（轮子），包含安装包所需的所有信息：代码文件、包的元数据（名称、版本、依赖项）以及文件在环境中的放置指示。
构建制品需要编写项目文件（通常也称为清单），详细说明项目的具体信息、所需依赖项、包的版本等。在Python中，我们使用`pyproject.toml`来实现这一目的。

In Python, packaging a library involves producing an artifact that package installers like `pip` or `uv` can use to install the relevant files.
Python artifacts are called _wheels_ and contain all the necessary information to install a package: the code files, metadata about the package (name, version, dependencies), and instructions for where to place files in the environment.
Building an artifact requires that we write a project file (also often known as manifest) detailing the specifics of the project, the required dependencies, the version of the package, and other information. In Python, we use `pyproject.toml` for this purpose.

> `pyproject.toml` 是现代推荐的方式。虽然较早的打包方法如 `requirements.txt` 或 `setup.py` 仍然受支持，但应尽可能优先使用 `pyproject.toml`。

> `pyproject.toml` is the modern and recommended way. While earlier packaging methods like `requirements.txt` or `setup.py` are still supported, you should prefer `pyproject.toml` whenever possible.

以下是一个同时提供命令行工具的库的最小`pyproject.toml`示例：

Here's a minimal `pyproject.toml` for a library that also provides a command-line tool:

```toml
[project]
name = "greeting"
version = "0.1.0"
description = "A simple greeting library"
dependencies = ["typer>=0.9"]

[project.scripts]
greet = "greeting:main"

[build-system]
requires = ["setuptools>=61.0"]
build-backend = "setuptools.build_meta"
```

`typer`库是一个流行的Python包，用于以最少的样板代码创建命令行界面。

The `typer` library is a popular Python package for creating command-line interfaces with minimal boilerplate.

以及对应的`greeting.py`：

And the corresponding `greeting.py`:

```python
import typer


def greet(name: str) -> str:
    return f"Hello, {name}!"


def main(name: str):
    print(greet(name))


if __name__ == "__main__":
    typer.run(main)
```

有了这个文件，我们现在可以构建wheel：

With this file, we can now build the wheel:

```console
$ uv build
Building source distribution...
Building wheel from source distribution...
Successfully built dist/greeting-0.1.0.tar.gz
Successfully built dist/greeting-0.1.0-py3-none-any.whl

$ ls dist/
greeting-0.1.0-py3-none-any.whl
greeting-0.1.0.tar.gz
```

`.whl`文件就是wheel（一种具有特定结构的zip归档文件），`.tar.gz`则是适用于需要从源代码构建的系统的源码分发。

The `.whl` file is the wheel (a zip archive with a specific structure), and the `.tar.gz` is a source distribution for systems that need to build from source.

你可以检查wheel的内容，查看打包了哪些文件：

You can inspect the contents of a wheel to see what gets packaged:

```console
$ unzip -l dist/greeting-0.1.0-py3-none-any.whl
Archive:  dist/greeting-0.1.0-py3-none-any.whl
  Length      Date    Time    Name
---------  ---------- -----   ----
      150  2024-01-15 10:30   greeting.py
      312  2024-01-15 10:30   greeting-0.1.0.dist-info/METADATA
       92  2024-01-15 10:30   greeting-0.1.0.dist-info/WHEEL
        9  2024-01-15 10:30   greeting-0.1.0.dist-info/top_level.txt
      435  2024-01-15 10:30   greeting-0.1.0.dist-info/RECORD
---------                     -------
      998                     5 files
```

现在，如果我们将这个wheel交给其他人，他们可以通过运行以下命令安装：

Now if we were to give this wheel to someone else, they could install it by running:

```console
$ uv pip install ./greeting-0.1.0-py3-none-any.whl
$ greet Alice
Hello, Alice!
```

这将把我们之前构建的库安装到他们的环境中，包括`greet`命令行工具。

This would install the library we built earlier into their environment, including the `greet` cli tool.

这种方法存在局限性。特别是如果我们的库依赖于平台特定的库，例如用于GPU加速的CUDA，那么我们的制品仅适用于安装了这些特定库的系统，并且我们可能需要为不同平台（Linux、macOS、Windows）和架构（x86、ARM）构建单独的wheel。

There are limitations to this approach. In particular if our library depends on platform-specific libraries, e.g. CUDA for GPU acceleration, then our artifact only works on systems with those specific libraries installed, and we may need to build separate wheels for different platforms (Linux, macOS, Windows) and architectures (x86, ARM).


安装软件时，从源代码安装和安装预构建二进制文件之间存在重要区别。从源代码安装意味着下载原始代码并在您的机器上编译——这需要安装编译器和构建工具，对于大型项目可能耗时较长。

When installing software, there's an important distinction between installing from source and installing a prebuilt binary. Installing from source means downloading the original code and compiling it on your machine --- this requires having a compiler and build tools installed, and can take significant time for large projects.

安装预构建二进制文件意味着下载由他人预先编译好的制品——更快更简单，但二进制文件必须与您的平台和架构匹配。
例如，[ripgrep的发布页面](https://github.com/BurntSushi/ripgrep/releases)展示了适用于Linux（x86_64、ARM）、macOS（Intel、Apple Silicon）和Windows的预构建二进制文件。

Installing a prebuilt binary means downloading an artifact that was already compiled by someone else --- faster and simpler, but the binary must match your platform and architecture.
For example, [ripgrep's releases page](https://github.com/BurntSushi/ripgrep/releases) shows prebuilt binaries for Linux (x86_64, ARM), macOS (Intel, Apple Silicon), and Windows.


# 发布与版本管理

# Releases & Versioning

代码的构建是一个持续的过程，但发布则是离散进行的。
在软件开发中，开发环境和生产环境之间存在明确区别。
代码需要被证明在开发环境中正常工作，才能被_交付_到生产环境。
发布过程涉及许多步骤，包括测试、依赖管理、版本控制、配置、部署和发布。

Code is built in a continuous process but is released on a discrete basis.
In software development there is a clear distinction between development and production environments.
Code needs to be proven to work in a dev environment before getting _shipped_ to prod.
The release process involves many steps, including testing, dependency management, versioning, configuration, deployment and publishing.


软件库并非静态，而是随着时间推移不断演进，获得修复和新功能。
我们通过离散的版本标识符来跟踪这种演进，这些标识符对应库在特定时间点的状态。
库行为的变化范围很广，包括修复非关键功能的补丁、扩展功能的新特性，以及破坏向后兼容性的变更。
变更日志记录了版本引入的更改——这些是软件开发人员用来传达新版本相关变更的文档。

Software libraries are not static and evolve over time getting fixes and new features.
We track this evolution by discrete version identifiers that correspond to the state of the library at a certain point in time.
Changes in the behavior of a library can range from patches that fix noncritical functionality, new features that extend its functionality, to changes breaking backwards compatibility.
Changelogs document what changes a version introduces --- these are documents that software developers use to communicate the changes associated with a new release.

然而，跟踪每个依赖项的持续变化是不切实际的，当我们考虑传递依赖项时——即我们依赖项的依赖项——更是如此。

However, keeping track of the ongoing changes in each and every dependency is impractical, even more so when we consider the transitive dependencies --- i.e. the dependencies of our dependencies.

> 你可以使用 `uv tree` 可视化项目的整个依赖树，它以树形格式显示所有包及其传递依赖项。

> You can visualize the entire dependency tree of your project with `uv tree`, which shows all packages and their transitive dependencies in a tree format.

为了简化这个问题，存在关于软件版本管理的约定，其中最流行的是[语义化版本控制](https://semver.org/)或SemVer。
在语义化版本控制下，版本标识符的形式为MAJOR.MINOR.PATCH，其中每个值均为整数。简而言之，升级时：

- PATCH（例如，1.2.3 → 1.2.4）应仅包含错误修复，并完全向后兼容
- MINOR（例如，1.2.3 → 1.3.0）以向后兼容的方式添加新功能
- MAJOR（例如，1.2.3 → 2.0.0）表示可能需要进行代码修改的破坏性变更

To simplify this problem there are conventions on how to version software, and one of the most prevalent is [Semantic Versioning](https://semver.org/) or SemVer.
Under Semantic Versioning a version has an identifier of the form MAJOR.MINOR.PATCH where each one of the values takes an integer value. The short version is that upgrading:

- PATCH (e.g., 1.2.3 → 1.2.4) should only contain bug fixes and be fully backwards compatible
- MINOR (e.g., 1.2.3 → 1.3.0) adds new functionality in a backwards-compatible way
- MAJOR (e.g., 1.2.3 → 2.0.0) indicates breaking changes that may require code modifications

> 这是一个简化说明，我们鼓励阅读完整的SemVer规范，以理解例如为什么从0.1.3升级到0.2.0可能导致破坏性变更，或1.0.0-rc.1的含义。

> This is a simplification and we encourage reading the full SemVer specification to understand for instance why going from 0.1.3 to 0.2.0 might cause breaking changes or what 1.0.0-rc.1 means.
Python打包原生支持语义化版本控制，因此当我们指定依赖项版本时，可以使用各种限定符：

Python packaging supports semantic versioning natively, so when we specify the versions of our dependencies we can use various specifiers:

在`pyproject.toml`中，我们有多种方式来限定依赖项的兼容版本范围：

In the `pyproject.toml` we have different ways of constraining the ranges of compatible versions of our dependencies:

```toml
[project]
dependencies = [
    "requests==2.32.3",  # Exact version - only this specific version
    "click>=8.0",        # Minimum version - 8.0 or newer
    "numpy>=1.24,<2.0",  # Range - at least 1.24 but less than 2.0
    "pandas~=2.1.0",     # Compatible release - >=2.1.0 and <2.2.0
]
```

版本限定符存在于许多包管理器（npm、cargo等）中，具体语义各不相同。`~=`运算符是Python的“兼容版本”运算符——`~=2.1.0`表示“与2.1.0兼容的任何版本”，即`>=2.1.0`且`<2.2.0`。这大致等同于npm和cargo中的脱字号（`^`）运算符，后者遵循SemVer的兼容性概念。

Version specifiers exist across many package managers (npm, cargo, etc.) with varying exact semantics. The `~=` operator is Python's "compatible release" operator --- `~=2.1.0` means "any version that is compatible with 2.1.0", which translates to `>=2.1.0` and `<2.2.0`. This is roughly equivalent to the caret (`^`) operator in npm and cargo, which follows SemVer's notion of compatibility.

并非所有软件都使用语义化版本控制。一种常见的替代方案是日历版本控制（CalVer），其版本基于发布日期而非语义含义。例如，Ubuntu使用诸如`24.04`（2024年4月）和`24.10`（2024年10月）的版本。CalVer便于查看版本的发布时长，但无法传达任何兼容性信息。最后，语义化版本控制并非万无一失，有时维护者会在次要版本或补丁版本中无意引入破坏性变更。

Not all software uses semantic versioning. A common alternative is Calendar Versioning (CalVer), where versions are based on release dates rather than semantic meaning. For example, Ubuntu uses versions like `24.04` (April 2024) and `24.10` (October 2024). CalVer makes it easy to see how old a release is, though it doesn't communicate anything about compatibility.  Lastly, semantic versioning is not infallible, and sometimes maintainers inadvertently introduce breaking changes in minor or patch releases.


# 可复现性

# Reproducibility

在现代软件开发中，你编写的代码建立在大量抽象层之上。
这包括你的编程语言运行时、第三方库、操作系统，甚至硬件本身。
任何一层的差异都可能改变代码的行为，甚至导致其无法按预期工作。
此外，底层硬件的差异也会影响你交付软件的能力。

In modern software development the code you write sits atop a significant number of layers of abstraction.
This includes things like your programming language runtime, third party libraries, the operating system, or even the hardware itself.
Any difference across any of these layers might change the behavior of your code or even prevent it from working as intended.
Furthermore, even differences in the underlying hardware impact your ability to ship software.

锁定库是指指定确切的版本而非范围，例如使用`requests==2.32.3`而非`requests>=2.0`。

Pinning a library refers to specifying an exact version rather than a range, e.g. `requests==2.32.3` instead of `requests>=2.0`.

包管理器的部分工作是考虑依赖项（以及传递依赖项）提供的所有约束，然后生成一个满足所有约束的有效版本列表。
这个具体的版本列表可以保存到文件中以实现可复现性；这些文件被称为_锁文件_。

Part of the job of a package manager is to consider all the constraints provided by the dependencies --- and transitive dependencies --- and then produce a valid list of versions that will satisfy all the constraints.
The specific list of versions can then be saved to a file for reproducibility purposes; these files are referred to as _lock files_.

```console
$ uv lock
Resolved 12 packages in 45ms

$ cat uv.lock | head -20
version = 1
requires-python = ">=3.11"

[[package]]
name = "certifi"
version = "2024.8.30"
source = { registry = "https://pypi.org/simple" }
sdist = { url = "https://files.pythonhosted.org/...", hash = "sha256:..." }
wheels = [
    { url = "https://files.pythonhosted.org/...", hash = "sha256:..." },
]
...
```

在处理依赖版本控制和可复现性时，一个关键区别在于库与应用程序/服务之间的差异。
库旨在被其他可能拥有自身依赖项的代码导入和使用，因此指定过于严格的版本约束可能导致与用户其他依赖项的冲突。
相反，应用程序或服务是软件的最终消费者，通常通过用户界面或API（而非编程接口）暴露其功能。
对于库，指定版本范围是良好实践，以最大限度地提高与更广泛包生态系统的兼容性。对于应用程序，锁定确切版本可确保可复现性——每个运行应用程序的人都使用完全相同的依赖项。

One critical distinction when dealing with dependency versioning and reproducibility is the difference between libraries and applications/services.
A library is intended to be imported and used by other code which might have its own dependencies, so specifying overly strict version constraints can cause conflicts with the user's other dependencies.
In contrast, applications or services are final consumers of the software and typically expose their functionality through a user interface or an API, not through a programming interface.
For libraries, it is good practice to specify version ranges to maximize compatibility with the wider package ecosystem. For applications, pinning exact versions ensures reproducibility --- everyone running the application uses the exact same dependencies.


对于需要最大可复现性的项目，像[Nix](https://nixos.org/)和[Bazel](https://bazel.build/)这样的工具提供_密封_构建——其中每个输入包括编译器、系统库甚至构建环境本身都被锁定并经过内容寻址。这保证了无论构建何时何地运行，输出都完全一致。

For projects requiring maximum reproducibility, tools like [Nix](https://nixos.org/) and [Bazel](https://bazel.build/) provide _hermetic_ builds --- where every input including compilers, system libraries, and even the build environment itself is pinned and content-addressed. This guarantees bit-for-bit identical outputs regardless of when or where the build runs.

> 你甚至可以使用NixOS管理整个计算机安装，从而轻松创建计算机设置的新副本，并通过版本控制的配置文件管理其完整配置。

> You can even use NixOS to manage your entire computer install so that you can trivially spin up new copies of your computer setup and manage their complete configuration through version-controlled configuration files.

软件开发中一个永无止境的矛盾是：新软件版本会引入有意或无意的破坏性变更，而另一方面，旧软件版本随着时间的推移会暴露出安全漏洞。
我们可以通过使用持续集成流水线（我们将在[代码质量与CI](/2026/code-quality/)课程中进一步了解）来解决这个问题，这些流水线针对新软件版本测试我们的应用程序，并建立自动化机制来检测依赖项何时发布新版本，例如[Dependabot](https://github.com/dependabot)。

A neverending tension in software development is that new software versions introduce breakage either intentionally or unintentionally, while on the other hand, old software versions become compromised with security vulnerabilities over time.
We can address this by using continuous integration pipelines (we'll see more in the [Code Quality and CI](/2026/code-quality/) lecture) that test our application against new software versions and having automation in place for detecting when new versions of our dependencies are released, such as [Dependabot](https://github.com/dependabot).

即使实施了CI测试，升级软件版本时仍会出现问题，这通常是由于开发环境和生产环境之间不可避免的差异所致。
在这种情况下，最佳做法是制定_回滚_计划，即撤销版本升级，重新部署一个已知良好的版本。

Even with CI testing in place, issues still occur when upgrading software versions, often because of the inevitable mismatch between dev and prod environments.
In those circumstances the best course of action is to have a _rollback_ plan, where the version upgrade is reverted and a known good version is redeployed instead.

# 虚拟机与容器

# VMs & Containers

当你开始依赖更复杂的依赖项时，代码的依赖项可能会超出包管理器能处理的范围。
一个常见原因是需要与特定的系统库或硬件驱动程序交互。
例如，在科学计算和AI领域，程序通常需要专门的库和驱动程序来利用GPU硬件。
许多系统级依赖项（GPU驱动程序、特定编译器版本、OpenSSL等共享库）仍然需要系统级安装。

As you start relying on more complex dependencies, it is likely that the dependencies of your code will span beyond the boundaries of what the package manager can handle.
One common reason is having to interface with specific system libraries or hardware drivers.
For example, in scientific computing and AI, programs often need specialized libraries and drivers to utilize GPU hardware.
Many system-level dependencies (GPU drivers, specific compiler versions, shared libraries like OpenSSL) still require system-wide installation.

传统上，这个更广泛的依赖问题是通过虚拟机（VM）解决的。
虚拟机抽象了整个计算机，提供了一个完全隔离的环境，拥有自己专用的操作系统。
更现代的方法是容器，它将应用程序与其依赖项、库和文件系统打包在一起，但共享主机的操作系统内核，而不是虚拟化整个计算机。
容器比虚拟机更轻量，因为它们共享内核，从而启动更快、运行更高效。

Traditionally this wider dependency problem was solved with Virtual Machines (VMs).
VMs abstract the entire computer and provide a completely isolated environment with its own dedicated operating system.
A more modern approach is containers, which package an application along with its dependencies, libraries, and filesystem, but share the host's operating system kernel rather than virtualizing an entire computer.
Containers are lighter weight than VMs because they share the kernel, making them faster to start and more efficient to run.

最流行的容器平台是[Docker](https://www.docker.com/)。Docker引入了一种构建、分发和运行容器的标准化方式。在底层，Docker使用containerd作为其容器运行时——这也是Kubernetes等其他工具使用的行业标准。

The most popular container platform is [Docker](https://www.docker.com/). Docker introduced a standardized way to build, distribute, and run containers. Under the hood, Docker uses containerd as its container runtime --- an industry standard that other tools like Kubernetes also use.

运行容器很简单。例如，要在容器内运行Python解释器，我们使用`docker run`（`-it`标志使容器具有交互式终端。退出时，容器会停止）。

Running a container is straightforward. For example, to run a Python interpreter inside a container we use `docker run` (The `-it` flags make the container interactive with a terminal. When you exit, the container stops.).

```console
$ docker run -it python:3.12 python
Python 3.12.7 (main, Nov  5 2024, 02:53:25) [GCC 12.2.0] on linux
>>> print("Hello from inside a container!")
Hello from inside a container!
```

实际上，你的程序可能依赖整个文件系统。
为了解决这个问题，我们可以使用容器镜像，将应用程序的整个文件系统作为制品进行交付。
容器镜像以编程方式创建。使用docker时，我们通过Dockerfile语法精确指定镜像的依赖项、系统库和配置：

In practice your program might depend on the entire filesystem.
To overcome this, we can use container images that ship the entire filesystem of the application as the artifact.
The container images are created programmatically. With docker we specify exactly the dependencies, system libraries, and configuration of the image using a Dockerfile syntax:

```dockerfile
FROM python:3.12
RUN apt-get update
RUN apt-get install -y gcc
RUN apt-get install -y libpq-dev
RUN pip install numpy
RUN pip install pandas
COPY . /app
WORKDIR /app
RUN pip install .
```

一个重要区别：Docker **镜像**是打包的制品（类似于模板），而**容器**是该镜像的运行实例。你可以从同一个镜像运行多个容器。镜像是分层构建的，Dockerfile中的每条指令（`FROM`、`RUN`、`COPY`等）都会创建一个新层。Docker会缓存这些层，因此如果你更改Dockerfile中的某一行，只需重建该层及后续层。

An important distinction: a Docker **image** is the packaged artifact (like a template), while a **container** is a running instance of that image. You can run multiple containers from the same image. Images are built in layers, where each instruction (`FROM`, `RUN`, `COPY`, etc) in a Dockerfile creates a new layer. Docker caches these layers, so if you change a line in your Dockerfile, only that layer and subsequent layers need to be rebuilt.

前面的Dockerfile存在几个问题：它使用了完整的Python镜像而非精简变体，运行了单独的`RUN`命令从而创建了不必要的层，版本未锁定，且未清理包管理器缓存，导致交付了不必要的文件。其他常见错误包括以root身份不安全地运行容器，以及无意中将密钥嵌入层中。

The previous Dockerfile has several issues: it uses the full Python image instead of a slim variant, runs separate `RUN` commands creating unnecessary layers, versions are not pinned, and it doesn't clean up package manager caches, shipping unnecessary files. Other frequent mistakes include insecurely running containers as root and accidentally embedding secrets in layers.

Here's an improved version

```dockerfile
FROM python:3.12-slim
COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv
RUN apt-get update && \
    apt-get install -y --no-install-recommends gcc libpq-dev && \
    rm -rf /var/lib/apt/lists/*
COPY pyproject.toml uv.lock ./
RUN uv pip install --system -r uv.lock
COPY . /app
```

在前面的示例中，我们看到我们没有从源代码安装`uv`，而是从`ghcr.io/astral-sh/uv:latest`镜像复制预构建的二进制文件。这被称为_构建器_模式。通过这种模式，我们无需交付编译代码所需的所有工具，只需交付运行应用程序所需的最终二进制文件（本例中为`uv`）。

In the previous example we see that instead of installing `uv` from source, we are copying the prebuilt binary from the `ghcr.io/astral-sh/uv:latest` image. This is known as the _builder_ pattern. With this pattern we do not need to ship all the tools needed to compile our code, just the final binary that is needed to run the application (`uv` in this case).

Docker存在一些重要的局限性需要注意。首先，容器镜像通常是平台特定的——为`linux/amd64`构建的镜像无法在`linux/arm64`（Apple Silicon Mac）上原生运行，需要模拟，速度较慢。其次，Docker容器需要Linux内核，因此在macOS和Windows上，Docker实际上在底层运行一个轻量级Linux虚拟机，增加了开销。第三，Docker的隔离性弱于虚拟机——容器共享主机内核，这在多租户环境中存在安全隐患。

Docker has important limitations to be aware of. First, container images are often platform-specific --- an image built for `linux/amd64` won't run natively on `linux/arm64` (Apple Silicon Macs) without emulation, which is slow. Second, Docker containers require a Linux kernel, so on macOS and Windows, Docker actually runs a lightweight Linux VM under the hood, adding overhead. Third, Docker's isolation is weaker than VMs --- containers share the host kernel, which is a security concern in multi-tenant environments.

> 如今，越来越多的项目也开始使用nix，通过[nix flakes](https://serokell.io/blog/practical-nix-flakes)来管理每个项目的“系统级”库和应用程序。

> These days, more projects are also making use of nix to manage even "system-wide" libraries and applications per project through [nix flakes](https://serokell.io/blog/practical-nix-flakes).

# 配置

# Configuration

软件本质上是可配置的。在[命令行环境](/2026/command-line-environment/)课程中，我们看到了程序通过标志、环境变量甚至配置文件（又称点文件）接收选项。即使对于更复杂的应用程序，这一点仍然成立，并且存在管理大规模配置的成熟模式。
软件配置不应嵌入代码中，而应在运行时提供。
常见的配置方式包括环境变量和配置文件。

Software is inherently configurable. In the [command line environment](/2026/command-line-environment/) lecture we saw programs receiving options via flags, environment variables or even configuration files a.k.a. dotfiles. This holds true even for more complex applications, and there are established patterns for managing configuration at scale.
Software configuration should not be embedded in the code but be provided at runtime.
A couple of common ones being environment variables and config files.

以下是一个通过环境变量配置的应用程序示例：

Here's an example of an application that is configured via environment variables:

```python
import os

DATABASE_URL = os.environ.get("DATABASE_URL", "sqlite:///local.db")
DEBUG = os.environ.get("DEBUG", "false").lower() == "true"
API_KEY = os.environ["API_KEY"]  # Required - will raise if not set
```

应用程序也可以通过配置文件进行配置（例如，通过`yaml.load`加载配置的Python程序），`config.yaml`：

An application could also be configured via a configuration file (e.g., a Python program that loads a config via `yaml.load`), `config.yaml`:

```yaml
database:
  url: "postgresql://localhost/myapp"
  pool_size: 5
server:
  host: "0.0.0.0"
  port: 8080
  debug: false
```

关于配置的一个实用经验法则是：相同的代码库应该能够通过仅更改配置（而非代码）部署到不同的环境（开发、预发布、生产）。

A good right-hand rule for thinking about configuration is that the same codebase should be deployable to different environments (development, staging, production) with only configuration changes, never code changes.

在众多配置选项中，通常包含敏感数据，例如API密钥。
密钥需要谨慎处理，避免意外泄露，并且绝不能包含在版本控制中。

Among the many configuration options there is often sensitive data such as API keys.
Secrets need to be handled with care to avoid exposing them accidentally, and must not be included in version control.


# 服务与编排

# Services & Orchestration

现代应用程序很少孤立存在。一个典型的Web应用程序可能需要数据库进行持久存储、缓存以提高性能、消息队列处理后台任务，以及各种其他支持服务。现代架构通常将功能分解为独立的服务，而不是将所有功能捆绑到一个单一的整体应用程序中，这些服务可以独立开发、部署和扩展。

Modern applications rarely exist in isolation. A typical web application might need a database for persistent storage, a cache for performance, a message queue for background tasks, and various other supporting services. Rather than bundling everything into a single monolithic application, modern architectures often decompose functionality into separate services that can be developed, deployed, and scaled independently.

例如，如果我们确定应用程序可能受益于使用缓存，我们可以利用现有的经过实战测试的解决方案，如[Redis](https://redis.io/)或[Memcached](https://memcached.org/)，而不是自己构建。
我们可以通过将Redis构建为容器的一部分来将其嵌入应用程序依赖项中，但这意味着需要协调Redis和我们的应用程序之间的所有依赖项，这可能具有挑战性甚至不可行。
相反，我们可以做的是将每个应用程序单独部署在自己的容器中。
这通常被称为微服务架构，其中每个组件作为独立服务运行，通过网络（通常通过HTTP API）进行通信。

As an example, if we determine our application might benefit from using a cache, instead of rolling our own we can leverage existing battle tested solutions like [Redis](https://redis.io/) or [Memcached](https://memcached.org/).
We could embed Redis in our application dependencies by building it as part of the container, but that means harmonizing all the dependencies between Redis and our application which could be challenging or even unfeasible.
Instead what we can do is deploy each application separately in its own container.
This is commonly referred to as a microservice architecture where each component runs as an independent service that communicates over the network, typically via HTTP APIs.

[Docker Compose](https://docs.docker.com/compose/)是一个用于定义和运行多容器应用程序的工具。你无需单独管理容器，而是在单个YAML文件中声明所有服务，并将它们编排在一起。现在我们的完整应用程序包含多个容器：

[Docker Compose](https://docs.docker.com/compose/) is a tool for defining and running multi-container applications. Rather than managing containers individually, you declare all services in a single YAML file and orchestrate them together. Now our full application encompasses more than one container:

```yaml
# docker-compose.yml
services:
  web:
    build: .
    ports:
      - "8080:8080"
    environment:
      - REDIS_URL=redis://cache:6379
    depends_on:
      - cache

  cache:
    image: redis:7-alpine
    volumes:
      - redis_data:/data

volumes:
  redis_data:
```

使用`docker compose up`，两个服务会同时启动，Web应用程序可以使用主机名`cache`连接Redis（Docker的内部DNS会自动解析服务名称）。
Docker Compose允许我们声明如何部署一个或多个服务，并处理一起启动它们、设置它们之间的网络以及管理用于数据持久化的共享卷的编排工作。

With `docker compose up`, both services start together, and the web application can connect to Redis using the hostname `cache` (Docker's internal DNS resolves service names automatically).
Docker Compose lets us declare how we want to deploy one or more services, and handles the orchestration of starting them together, setting up networking between them, and managing shared volumes for data persistence.

对于生产部署，通常希望docker compose服务在启动时自动启动，并在故障时重启。常见的方法是使用systemd来管理docker compose部署：

For production deployments, you often want your docker compose services to start automatically on boot and restart on failure. A common approach is to use systemd to manage the docker compose deployment:

```ini
# /etc/systemd/system/myapp.service
[Unit]
Description=My Application
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=/opt/myapp
ExecStart=/usr/bin/docker compose up -d
ExecStop=/usr/bin/docker compose down

[Install]
WantedBy=multi-user.target
```

这个systemd单元文件确保你的应用程序在系统启动时（Docker准备就绪后）启动，并提供标准的控制命令，如`systemctl start myapp`、`systemctl stop myapp`和`systemctl status myapp`。

This systemd unit file ensures your application starts when the system boots (after Docker is ready), and provides standard controls like `systemctl start myapp`, `systemctl stop myapp`, and `systemctl status myapp`.

随着部署需求变得更加复杂——需要跨多台机器扩展、服务崩溃时的容错能力以及高可用性保证——组织会转向复杂的容器编排平台，如Kubernetes (k8s)，它可以管理跨机器集群的数千个容器。话虽如此，Kubernetes学习曲线陡峭且运维开销大，因此对于较小项目来说往往是大材小用。

As deployment requirements grow more complex --- needing scalability across multiple machines, fault tolerance when services crash, and high availability guarantees --- organizations turn to sophisticated container orchestration platforms like Kubernetes (k8s), which can manage thousands of containers across clusters of machines. That said, Kubernetes has a steep learning curve and significant operational overhead, so it's often overkill for smaller projects.

这种多容器设置之所以部分可行，是因为现代服务通过标准化API（即HTTP REST API）相互通信。例如，每当程序与OpenAI或Anthropic等LLM提供商交互时，底层实际上是向他们的服务器发送HTTP请求并解析响应：

This multi-container setup is partly feasible because modern services communicate with each other via standardized APIs, with HTTP REST APIs. For example, whenever a program interacts with an LLM provider like OpenAI or Anthropic, under the hood it is sending an HTTP request to their servers and parsing the response:

```console
$ curl https://api.anthropic.com/v1/messages \
    -H "x-api-key: $ANTHROPIC_API_KEY" \
    -H "content-type: application/json" \
    -H "anthropic-version: 2023-06-01" \
    -d '{"model": "claude-sonnet-4-20250514", "max_tokens": 256,
         "messages": [{"role": "user", "content": "Explain containers vs VMs in one sentence."}]}'
```

# 发布

# Publishing

一旦你的代码被证明可以工作，你可能会有兴趣将其分发给其他人下载和安装。
分发形式多种多样，并且与您所使用的编程语言和环境密切相关。

Once you have shown your code to work, you might be interested in distributing it for others to download and install.
Distribution takes many forms and is intrinsically tied to the programming language and environments that you operate with.

最简单的分发形式是上传制品供人们下载并在本地安装。
这仍然很常见，你可以在[Ubuntu的软件包归档](http://archive.ubuntu.com/ubuntu/pool/main/)等地方找到它，这本质上是一个`.deb`文件的HTTP目录列表。

The simplest form of distribution is uploading artifacts for people to download and install locally.
This is still common and you can find it in places like [Ubuntu's package archive](http://archive.ubuntu.com/ubuntu/pool/main/), which is essentially an HTTP directory listing of `.deb` files.

如今，GitHub已成为发布源代码和制品的实际标准平台。
虽然源代码通常是公开的，但GitHub Releases允许维护者将预构建的二进制文件和其他制品附加到标记版本上。

These days, GitHub has become the de facto platform for publishing source code and artifacts.
While the source code is often publicly available, GitHub Releases allow maintainers to attach prebuilt binaries and other artifacts to tagged versions.


包管理器有时支持直接从GitHub安装，无论是从源代码还是从预构建的wheel：

Package managers sometimes support installing directly from GitHub, either from source or from a pre-built wheel:

```console
# Install from source (will clone and build)
$ pip install git+https://github.com/psf/requests.git

# Install from a specific tag/branch
$ pip install git+https://github.com/psf/requests.git@v2.32.3

# Install a wheel directly from a GitHub release
$ pip install https://github.com/user/repo/releases/download/v1.0/package-1.0-py3-none-any.whl
```

事实上，像Go这样的语言使用去中心化的分发模型——Go模块直接从其源代码仓库分发，而不是通过中央包仓库。
像`github.com/gorilla/mux`这样的模块路径指示代码所在位置，`go get`直接从那里获取。然而，大多数包管理器如`pip`、`cargo`或`brew`都有预打包项目的中央索引，以便于分发和安装。如果我们运行

In fact, some languages like Go use a decentralized distribution model --- rather than a central package repository, Go modules are distributed directly from their source code repositories.
Module paths like `github.com/gorilla/mux` indicate where the code lives, and `go get` fetches directly from there. However, most package managers like `pip`, `cargo`, or `brew` have central indexes of pre-packaged projects for ease of distribution and installation. If we run

```console
$ uv pip install requests --verbose --no-cache 2>&1 | grep -F '.whl'
DEBUG Selecting: requests==2.32.5 [compatible] (requests-2.32.5-py3-none-any.whl)
DEBUG No cache entry for: https://files.pythonhosted.org/packages/1e/db/4254e3eabe8020b458f1a747140d32277ec7a271daf1d235b70dc0b4e6e3/requests-2.32.5-py3-none-any.whl.metadata
DEBUG No cache entry for: https://files.pythonhosted.org/packages/1e/db/4254e3eabe8020b458f1a747140d32277ec7a271daf1d235b70dc0b4e6e3/requests-2.32.5-py3-none-any.whl
```

我们可以看到我们从哪里获取`requests`的wheel。注意文件名中的`py3-none-any`——这表示该wheel适用于任何Python 3版本、任何操作系统、任何架构。对于包含编译代码的包，wheel是平台特定的：

we see where we are fetching the `requests` wheel from. Notice the `py3-none-any` in the filename --- this means the wheel works with any Python 3 version, on any OS, on any architecture. For packages with compiled code, the wheel is platform-specific:

```console
$ uv pip install numpy --verbose --no-cache 2>&1 | grep -F '.whl'
DEBUG Selecting: numpy==2.2.1 [compatible] (numpy-2.2.1-cp312-cp312-macosx_14_0_arm64.whl)
```

这里的`cp312-cp312-macosx_14_0_arm64`表示该wheel专门适用于macOS 14+上ARM64（Apple Silicon）的CPython 3.12。如果你在其他平台上，`pip`将下载不同的wheel或从源代码构建。

Here `cp312-cp312-macosx_14_0_arm64` indicates this wheel is specifically for CPython 3.12 on macOS 14+ for ARM64 (Apple Silicon). If you're on a different platform, `pip` will download a different wheel or build from source.

反过来，为了让人们能够找到我们创建的包，我们需要将其发布到这些注册中心之一。
在Python中，主要的注册中心是[Python Package Index (PyPI)](https://pypi.org)。
与安装类似，发布包也有多种方式。`uv publish`命令提供了将包上传到PyPI的现代接口：

Conversely, for people to be able to find a package we've created, we need to publish it to one of these registries.
In Python, the main registry is the [Python Package Index (PyPI)](https://pypi.org).
Like with installing, there are multiple ways of publishing packages. The `uv publish` command provides a modern interface for uploading packages to PyPI:

```console
$ uv publish --publish-url https://test.pypi.org/legacy/
Publishing greeting-0.1.0.tar.gz
Publishing greeting-0.1.0-py3-none-any.whl
```

这里我们使用的是[TestPyPI](https://test.pypi.org)——一个独立的包注册中心，用于测试发布流程，而不会污染真实的PyPI。上传后，你可以从TestPyPI安装：

Here we are using [TestPyPI](https://test.pypi.org) --- a separate package registry intended for testing your publishing workflow without polluting the real PyPI. Once uploaded, you can install from TestPyPI:

```console
$ uv pip install --index-url https://test.pypi.org/simple/ greeting
```

发布软件时的一个关键考虑因素是信任。用户如何验证他们下载的包确实来自你且未被篡改？包注册中心使用校验和来验证完整性，一些生态系统支持包签名以提供加密的作者身份证明。

A key consideration when publishing software is trust. How do users verify that the package they download actually comes from you and hasn't been tampered with? Package registries use checksums to verify integrity, and some ecosystems support package signing to provide cryptographic proof of authorship.

不同语言有自己的包注册中心：Rust的[crates.io](https://crates.io)、JavaScript的[npm](https://www.npmjs.com)、Ruby的[RubyGems](https://rubygems.org)以及容器镜像的[Docker Hub](https://hub.docker.com)。同时，对于私有或内部包，组织通常部署自己的包仓库（例如私有PyPI服务器或私有Docker注册中心），或使用云提供商提供的托管解决方案。

Different languages have their own package registries: [crates.io](https://crates.io) for Rust, [npm](https://www.npmjs.com) for JavaScript, [RubyGems](https://rubygems.org) for Ruby, and [Docker Hub](https://hub.docker.com) for container images. Meanwhile, for private or internal packages, organizations often deploy their own package repositories (such as a private PyPI server or a private Docker registry) or use managed solutions from cloud providers.

将Web服务部署到互联网涉及额外的基础设施：域名注册、DNS配置以将域名指向服务器，以及通常使用像nginx这样的反向代理来处理HTTPS和路由流量。对于文档或静态站点等更简单的用例，[GitHub Pages](https://pages.github.com/)直接从仓库提供免费托管。

Deploying a web service to the internet involves additional infrastructure: domain name registration, DNS configuration to point your domain to your server, and often a reverse proxy like nginx to handle HTTPS and route traffic. For simpler use cases like documentation or static sites, [GitHub Pages](https://pages.github.com/) provides free hosting directly from a repository.

<!--
## Documentation

So far we have emphasized the deliverable _artifact_ as the main output of packaging and shipping code.
In addition to the artifact, we need to document for users the code's functionality, installation instructions, and usage examples.

Tools like [Sphinx](https://www.sphinx-doc.org/) (Python) and [MkDocs](https://www.mkdocs.org/) can automatically generate browsable documentation from docstrings and markdown files, often hosted on services like [Read the Docs](https://readthedocs.org/).
For HTTP-based APIs, the [OpenAPI specification](https://www.openapis.org/) (formerly Swagger) provides a standard format for describing API endpoints, which tools can use to generate interactive documentation and client libraries automatically. -->


# 练习

# Exercises

1. 使用`printenv`将你的环境保存到文件中，创建一个venv，激活它，再次使用`printenv`输出到另一个文件，然后`diff before.txt after.txt`。环境中发生了什么变化？为什么shell优先使用venv？（提示：查看激活前后的`$PATH`。）运行`which deactivate`并思考deactivate bash函数的作用。

1. Save your environment with `printenv` to a file, create a venv, activate it, `printenv` to another file and `diff before.txt after.txt`. What changed in the environment? Why does the shell prefer the venv? (Hint: look at `$PATH` before and after activation.) Run `which deactivate` and reason about what the deactivate bash function is doing.
2. 创建一个带有`pyproject.toml`的Python包，并在虚拟环境中安装它。创建一个锁文件并检查其内容。

1. Create a Python package with a `pyproject.toml` and install it in a virtual environment. Create a lockfile and inspect it.
3. 安装Docker并使用docker compose在本地构建Missing Semester课程网站。

1. Install Docker and use it to build the Missing Semester class website locally using docker compose.
4. 为简单的Python应用程序编写Dockerfile。然后编写一个`docker-compose.yml`，使你的应用程序与Redis缓存一起运行。

1. Write a Dockerfile for a simple Python application. Then write a `docker-compose.yml` that runs your application alongside a Redis cache.
5. 发布一个Python包到TestPyPI（除非值得分享，否则不要发布到真实的PyPI！）。然后用该包构建一个Docker镜像并推送到`ghcr.io`。

1. Publish a Python package to TestPyPI (don't publish to the real PyPI unless it's worth sharing!). Then build a Docker image with said package and push it to `ghcr.io`.
6. 使用[GitHub Pages](https://docs.github.com/en/pages/quickstart)创建一个网站。附加（非）学分：使用自定义域名配置它。

1. Make a website using [GitHub Pages](https://docs.github.com/en/pages/quickstart). Extra (non-)credit: configure it with a custom domain.
