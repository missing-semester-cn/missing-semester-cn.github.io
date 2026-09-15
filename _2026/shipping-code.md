
---
layout: lecture
title: "代码打包与发布"
description: >
  了解项目打包、环境、版本管理，以及如何部署库、应用程序和服务。
thumbnail: /static/assets/thumbnails/2026/lec6.png
date: 2026-01-20
ready: true
video:
  aspect: 56.25
  id: KBMiB-8P4Ns
---

让代码按预期运行已经不容易了；要让同一份代码在另一台配置不同的机器上运行，往往更难。

发布代码（Shipping code），就是把你写好的代码整理成别人可以直接使用的形式，而不要求对方拥有与你电脑完全相同的环境。
代码发布有很多种方式，具体取决于编程语言、系统库、操作系统等多种因素。
它还取决于你正在构建什么：软件库、命令行工具和 Web 服务的要求与部署步骤都不一样。
不过，这些场景都有一个共同点：我们需要先明确最终要交付的内容，也就是所谓的**构建产物（artifact）**，以及它对周围运行环境有哪些依赖和假设。

本节将介绍：

- [依赖与环境](#依赖与环境)
- [构建产物与打包](#构建产物与打包)
- [发布与版本管理](#发布与版本管理)
- [可复现性](#可复现性)
- [虚拟机与容器](#虚拟机与容器)
- [配置](#配置)
- [服务与编排](#服务与编排)
- [发布软件](#发布软件)

为了便于理解，我们会主要使用 Python 生态中的例子来说明这些概念。其他编程语言使用的工具虽然不同，但背后的思想大体相同。

# 依赖与环境

在现代软件开发中，抽象层无处不在。
程序通常会把一部分功能交给其他库或服务来完成。
但这样一来，你的程序和这些库之间就产生了**依赖（dependency）**关系：程序只有在这些依赖存在时才能正常工作。
例如，在 Python 中，我们通常会这样获取一个网站的内容：

```python
import requests

response = requests.get("https://missing.csail.mit.edu")
```

但是，`requests` 并不是 Python 运行时自带的库。如果没有安装它就直接运行这段代码，Python 会报错：

```console
$ python fetch.py
Traceback (most recent call last):
  File "fetch.py", line 1, in <module>
    import requests
ModuleNotFoundError: No module named 'requests'
```

要使用这个库，我们需要先运行 `pip install requests` 来安装它。
`pip` 是 Python 提供的命令行包管理工具。
执行 `pip install requests` 时，大致会经历以下步骤：

1. 在 Python Package Index（[PyPI](https://pypi.org/)）中查找 `requests`
1. 查找适合当前运行平台的构建产物
1. 解析依赖关系——`requests` 本身还依赖其他包，因此安装器必须找到所有传递依赖中彼此兼容的版本，并先安装它们
1. 下载这些构建产物，解压后把文件复制到文件系统中的正确位置

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

从这里可以看到，`requests` 还依赖 `certifi`、`charset-normalizer` 等其他包，而这些包需要在安装 `requests` 之前先准备好。
安装完成后，Python 运行时就可以在导入时找到这个库：

```console
$ python -c 'import requests; print(requests.__path__)'
['/usr/local/lib/python3.11/dist-packages/requests']

$ pip list | grep requests
requests        2.32.3
```

不同编程语言在安装和发布库方面，有不同的工具、约定和实践。
有些语言（例如 Rust）使用统一的工具链——`cargo` 同时负责构建、测试、依赖管理和发布。
有些语言（例如 Python）是在规范层面统一：并不规定只能使用某一个工具，而是通过标准规范定义打包方式，因此同一个任务可以有多个工具可选，例如 `pip` 和 [`uv`](https://docs.astral.sh/uv/)，以及 `setuptools`、[`hatch`](https://hatch.pypa.io/) 和 [`poetry`](https://python-poetry.org/)。
还有一些生态（例如 LaTeX）会通过 TeX Live 或 MacTeX 这类发行版，预装数千个软件包。

引入依赖之后，也会带来依赖冲突。
当多个程序或软件包要求同一个依赖的不同版本，而且这些版本要求彼此不兼容时，就会发生冲突。
例如，假设 `tensorflow==2.3.0` 要求 `numpy>=1.16.0,<1.19.0`，而 `pandas==1.2.0` 要求 `numpy>=1.16.5`，那么任何满足 `numpy>=1.16.5,<1.19.0` 的版本都可以使用。
但如果项目中的另一个包要求 `numpy>=1.19`，就不存在能够同时满足所有要求的版本，于是发生冲突。

这种“多个软件包对同一个共享依赖提出互不兼容的版本要求”的情况，通常被称为**依赖地狱（dependency hell）**。
解决冲突的一种方法，是把每个程序的依赖隔离到各自独立的**环境（environment）**中。
在 Python 中，可以这样创建虚拟环境：

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

你可以把一个环境理解成一套相对独立的语言运行时，它拥有自己单独安装的一组软件包。
这个虚拟环境（virtual environment，简称 venv）会把项目的依赖与系统全局安装的 Python 隔离开。
通常的最佳实践是：每个项目都使用一个独立的虚拟环境，并只在其中安装该项目需要的依赖。

> 许多现代操作系统会预装 Python 等编程语言运行时，但不建议直接修改这些系统自带环境，因为操作系统本身可能依赖它们来实现某些功能。更好的做法是使用单独的环境。

在某些语言中，安装协议并不是由某个具体工具定义的，而是通过规范定义。
在 Python 中，[PEP 517](https://peps.python.org/pep-0517/) 定义了构建系统接口，[PEP 621](https://peps.python.org/pep-0621/) 则规定了项目元数据如何存储在 `pyproject.toml` 中。
这些规范让开发者可以在 `pip` 的基础上开发出更高效的工具，例如 `uv`。安装 `uv` 只需运行 `pip install uv`。

`uv` 的使用方式与 `pip` 类似，但速度通常快得多：

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

> 只要条件允许，我们强烈推荐优先使用 `uv pip` 而不是 `pip`，因为它能显著缩短安装时间。

除了隔离依赖之外，环境还可以让你在同一台机器上使用不同版本的编程语言运行时。

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

当你需要在多个 Python 版本上测试代码，或者某个项目要求特定版本时，这会非常有用。

> 在一些编程语言中，每个项目会自动拥有独立的依赖环境，不需要手动创建，但原理是一样的。如今大多数语言也都提供了在同一系统中管理多个语言版本的机制，并允许为不同项目指定所使用的版本。

# 构建产物与打包

在软件开发中，我们会区分**源代码（source code）**和**构建产物（artifact）**。
开发者编写和阅读的是源代码，而构建产物则是由源代码生成、经过打包后可供安装或部署的最终输出。
构建产物可以简单到只是一个直接运行的代码文件，也可以复杂到是一整台虚拟机，其中包含应用程序运行所需的所有内容。

假设当前目录下有一个 Python 文件 `greet.py`：

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

当我们切换到其他目录后，导入就失败了，因为 Python 只会在特定位置查找模块，例如当前目录、已经安装的软件包，以及 `PYTHONPATH` 中指定的路径。
打包可以解决这个问题：它会把代码安装到一个明确、可被 Python 找到的位置。

在 Python 中，打包一个库意味着生成一个构建产物，让 `pip` 或 `uv` 这样的包安装工具可以用它把相关文件安装到系统中。
Python 的这类构建产物称为 **wheel**。wheel 中包含安装一个包所需的全部信息：代码文件、包的元数据（名称、版本、依赖），以及这些文件应该放到环境中什么位置的信息。
要构建这样的产物，我们需要编写项目配置文件（也常称为 manifest），说明项目的基本信息、依赖、版本等内容。在现代 Python 项目中，通常使用 `pyproject.toml`。

> `pyproject.toml` 是现代 Python 项目推荐的方式。较早的 `requirements.txt` 或 `setup.py` 仍然受到支持，但只要可以，应该优先使用 `pyproject.toml`。

下面是一个最小的 `pyproject.toml` 示例。它定义了一个 Python 库，并同时提供一个命令行工具：

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

`typer` 是一个流行的 Python 包，可以用较少的样板代码创建命令行界面。

对应的 `greeting.py` 如下：

```python
import typer


def greet(name: str) -> str:
    return f"Hello, {name}!"


def main(name: str):
    print(greet(name))


if __name__ == "__main__":
    typer.run(main)
```

有了这些文件之后，就可以构建 wheel：

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

`.whl` 文件就是 wheel，本质上是一种具有特定目录结构的 ZIP 压缩包；`.tar.gz` 则是源码发行包，供需要从源代码构建的系统使用。

可以查看 wheel 中包含了哪些文件：

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

如果把这个 wheel 文件发给其他人，对方可以这样安装：

```console
$ uv pip install ./greeting-0.1.0-py3-none-any.whl
$ greet Alice
Hello, Alice!
```

这样就会把我们之前构建的库安装到对方的环境中，其中也包括 `greet` 这个命令行工具。

不过，这种方式也有局限。
如果我们的库依赖特定平台的系统库，例如用于 GPU 加速的 CUDA，那么这个构建产物通常只能在已经安装相应库的系统上工作。
此时，我们可能需要分别为不同平台（Linux、macOS、Windows）和不同 CPU 架构（x86、ARM）构建不同的 wheel。

安装软件时，还需要区分**从源码安装**和**安装预编译二进制文件**。
从源码安装意味着下载原始代码并在本机编译，因此需要提前安装编译器和构建工具，而且大型项目可能会耗费较长时间。

安装预编译二进制文件则是直接下载别人已经编译好的构建产物，通常更快、更简单，但二进制文件必须与当前平台和处理器架构匹配。
例如，[ripgrep 的 Releases 页面](https://github.com/BurntSushi/ripgrep/releases) 提供了适用于 Linux（x86_64、ARM）、macOS（Intel、Apple Silicon）和 Windows 的预编译二进制文件。

# 发布与版本管理

代码通常是持续开发的，但软件版本则是在某些具体时间点发布。
在软件开发中，开发环境（development）和生产环境（production）之间有明确区别。
代码需要先在开发环境中证明能够正常工作，然后才会被**发布（ship）**到生产环境。
整个发布流程通常包括测试、依赖管理、版本管理、配置、部署和对外发布等多个步骤。

软件库并不是一成不变的，它们会不断修复问题、增加新功能。
我们通过一个个离散的版本号来记录这种演进，每个版本号都对应软件在某个时间点的状态。
一次版本变化可能只是修复不太严重的问题，也可能增加新的功能，甚至可能引入破坏向后兼容性的改动。
**变更日志（changelog）**用于记录每个版本引入了哪些变化，开发者会通过它向用户说明新版本的改动。

不过，要持续追踪每一个依赖的所有变化并不现实；如果再考虑传递依赖，也就是“依赖的依赖”，问题会更加复杂。

> 可以使用 `uv tree` 查看项目完整的依赖树，它会以树形结构展示所有软件包及其传递依赖。

为了简化版本管理，人们制定了多种软件版本约定，其中最常见的一种是[语义化版本控制（Semantic Versioning）](https://semver.org/)，简称 SemVer。
在语义化版本中，版本号通常写成 `MAJOR.MINOR.PATCH`，三个部分都是整数。简单来说：

- PATCH（例如 1.2.3 → 1.2.4）：只应包含错误修复，并且应完全向后兼容
- MINOR（例如 1.2.3 → 1.3.0）：增加新功能，但仍保持向后兼容
- MAJOR（例如 1.2.3 → 2.0.0）：包含破坏兼容性的变化，使用者可能需要修改代码

> 上面的解释经过了简化。建议阅读完整的 SemVer 规范，例如了解为什么从 0.1.3 升级到 0.2.0 也可能包含破坏兼容性的变化，以及 `1.0.0-rc.1` 表示什么。

Python 的打包系统原生支持版本约束，因此指定依赖版本时，可以使用多种写法。

在 `pyproject.toml` 中，可以这样限制依赖的兼容版本范围：

```toml
[project]
dependencies = [
    "requests==2.32.3",  # 精确版本——只能使用这个版本
    "click>=8.0",        # 最低版本——8.0 或更高版本
    "numpy>=1.24,<2.0",  # 版本范围——至少 1.24，但低于 2.0
    "pandas~=2.1.0",     # 兼容版本——>=2.1.0 且 <2.2.0
]
```

许多包管理器（例如 npm、cargo）都支持版本约束，但具体语义可能有所不同。
`~=` 是 Python 中的“兼容版本（compatible release）”运算符，`~=2.1.0` 表示“任何与 2.1.0 兼容的版本”，也就是 `>=2.1.0` 且 `<2.2.0`。
它大致类似于 npm 和 cargo 中的 `^` 运算符，后者遵循 SemVer 对“兼容性”的定义。

并不是所有软件都使用语义化版本。
另一种常见方案是**日历版本（Calendar Versioning，CalVer）**，也就是根据发布日期来生成版本号，而不是让版本号表示兼容性。
例如 Ubuntu 使用 `24.04`（2024 年 4 月）和 `24.10`（2024 年 10 月）这样的版本号。
CalVer 的优点是可以直观看出一个版本发布了多久，但无法直接说明兼容性。
此外，语义化版本也并非绝对可靠，有时维护者会无意中在 minor 或 patch 版本中引入破坏兼容性的改动。

# 可复现性

在现代软件开发中，你写的代码通常建立在很多层抽象之上。
这些层可能包括编程语言运行时、第三方库、操作系统，甚至底层硬件。
其中任何一层发生变化，都可能改变代码的行为，甚至导致代码无法正常运行。
不仅如此，底层硬件的差异也可能影响软件能否顺利发布和运行。

**锁定（pinning）**某个库，是指把它的版本写成一个精确值，而不是一个范围。例如使用 `requests==2.32.3`，而不是 `requests>=2.0`。

包管理器的一项重要工作，就是综合考虑所有依赖及其传递依赖提供的版本限制，并找出一组能够满足全部限制条件的版本。
这组最终确定的具体版本，可以保存到文件中，以便之后复现同样的环境；这类文件通常称为**锁文件（lock file）**。

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

在依赖版本管理和可复现性方面，一个很重要的区别是：**库（library）**和**应用程序/服务（application/service）**应采用不同策略。
库通常会被其他代码导入和使用，而使用者自己的项目也可能拥有其他依赖，因此，如果库把依赖版本限制得过于严格，就很容易与用户项目中的其他依赖发生冲突。
相反，应用程序或服务通常已经是软件的最终使用方，它们一般通过用户界面或 API 对外提供功能，而不是作为程序库被其他代码调用。
因此，对于库，更好的做法通常是使用合理的版本范围，以提高与整个软件包生态的兼容性；而对于应用程序，则更适合锁定精确版本，以保证每个运行该应用的人都使用完全相同的依赖。

如果项目对可复现性的要求非常高，可以使用 [Nix](https://nixos.org/) 或 [Bazel](https://bazel.build/) 等工具进行**封闭式构建（hermetic build）**。
在这种构建方式中，包括编译器、系统库甚至整个构建环境在内的所有输入都会被固定版本，并通过内容寻址管理。
这样无论何时、在何处构建，都可以得到逐位完全一致的输出。

> 你甚至可以使用 NixOS 来管理整台计算机的安装和配置。这样一来，可以很方便地重新创建一套完全相同的电脑环境，并通过版本控制中的配置文件统一管理全部配置。

软件开发中一直存在一个无法完全消除的矛盾：
一方面，新版本可能有意或无意地引入兼容性问题；另一方面，旧版本随着时间推移又可能暴露安全漏洞。
一种解决思路是使用持续集成（CI）流水线（我们会在[代码质量与 CI](/2026/code-quality/)一课中进一步介绍），让应用持续在新版本软件上运行测试；同时可以使用 [Dependabot](https://github.com/dependabot) 等自动化工具，监测项目依赖是否发布了新版本。

即使已经使用 CI 进行测试，升级软件版本时仍然可能出现问题，常见原因之一就是开发环境和生产环境之间不可避免的差异。
遇到这种情况时，最稳妥的方案通常是提前准备**回滚（rollback）**机制：撤销这次版本升级，重新部署一个已经确认能够正常工作的旧版本。

# 虚拟机与容器

随着项目依赖越来越复杂，代码所需要的依赖很可能会超出包管理器能够处理的范围。
一个常见原因是：程序需要与特定系统库或硬件驱动进行交互。
例如，在科学计算和 AI 场景中，程序通常需要专门的库和驱动，才能使用 GPU。
许多系统级依赖（例如 GPU 驱动、特定版本的编译器、OpenSSL 之类的共享库）仍然需要在整个系统层面安装。

传统上，人们通常使用**虚拟机（Virtual Machine，VM）**来解决这类更广泛的依赖问题。
虚拟机会抽象出一整台计算机，并提供一个完全隔离的环境，其中运行着独立的操作系统。
更现代的做法是使用**容器（container）**：容器会把应用程序及其依赖、库和文件系统一起打包，但不会虚拟出一整台计算机，而是与宿主机共享操作系统内核。
由于共享内核，容器比虚拟机更轻量，启动更快，运行成本也更低。

目前最流行的容器平台是 [Docker](https://www.docker.com/)。
Docker 提供了一套标准化方式来构建、分发和运行容器。
在底层，Docker 使用 containerd 作为容器运行时；containerd 已经成为行业标准，Kubernetes 等其他工具同样会使用它。

运行容器非常直接。
例如，可以通过 `docker run` 在容器中启动 Python 解释器（`-it` 参数表示以交互终端方式运行；退出后容器也会停止）：

```console
$ docker run -it python:3.12 python
Python 3.12.7 (main, Nov  5 2024, 02:53:25) [GCC 12.2.0] on linux
>>> print("Hello from inside a container!")
Hello from inside a container!
```

实际项目中，程序可能会依赖整个文件系统。
为了处理这种情况，我们可以使用**容器镜像（container image）**，把应用所需的整个文件系统作为构建产物一起发布。
容器镜像通常通过代码化的方式构建。在 Docker 中，我们可以使用 Dockerfile 明确指定镜像需要的依赖、系统库和配置：

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

这里有一个重要区别：Docker **镜像（image）**是已经打包好的构建产物，可以理解为模板；而**容器（container）**则是镜像运行起来之后的实例。
同一个镜像可以启动多个容器。
镜像由多层组成，Dockerfile 中的每条指令（例如 `FROM`、`RUN`、`COPY`）都会生成一个新的层。
Docker 会缓存这些层，因此，如果只修改 Dockerfile 中的一行，通常只需要重新构建这一层以及它后面的层。

上面的 Dockerfile 存在几个问题：
它使用完整的 Python 镜像，而不是体积更小的 slim 版本；每个 `RUN` 都单独写一行，产生了不必要的镜像层；依赖没有固定版本；也没有清理包管理器缓存，因此会把不需要的文件一起打进镜像。
其他常见错误还包括让容器以 root 身份运行，以及不小心把密钥等敏感信息写进镜像层。

下面是一个改进后的版本：

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

在这个例子中，我们没有从源码安装 `uv`，而是直接从 `ghcr.io/astral-sh/uv:latest` 镜像中复制预编译好的二进制文件。
这种做法称为 **builder 模式**。
使用这种模式后，我们不需要把编译代码所需的全部工具都打进最终镜像，只需要留下应用运行时真正需要的最终二进制文件（这里就是 `uv`）。

Docker 也有一些重要限制。
第一，容器镜像通常与平台相关：为 `linux/amd64` 构建的镜像无法在 `linux/arm64`（例如 Apple Silicon Mac）上原生运行，除非使用模拟，而模拟通常速度较慢。
第二，Docker 容器依赖 Linux 内核，因此在 macOS 和 Windows 上，Docker 实际上会在底层运行一个轻量级 Linux 虚拟机，这会增加一定开销。
第三，Docker 的隔离能力弱于虚拟机，因为容器共享宿主机内核。在多租户环境中，这会带来一定安全风险。

> 如今，越来越多项目也开始使用 Nix，通过 [nix flakes](https://serokell.io/blog/practical-nix-flakes) 在项目层面管理原本属于“系统级”的库和应用。

# 配置

软件本身通常都需要配置。
在[命令行环境](/2026/command-line-environment/)一课中，我们已经看到程序可以通过命令行参数、环境变量或配置文件（也就是 dotfiles）接收配置。
对于更复杂的应用也是如此，而且在大规模系统中，已经形成了一些成熟的配置管理模式。

软件配置不应该硬编码在代码中，而应该在程序运行时提供。
最常见的两种方式是环境变量和配置文件。

下面是一个通过环境变量进行配置的应用示例：

```python
import os

DATABASE_URL = os.environ.get("DATABASE_URL", "sqlite:///local.db")
DEBUG = os.environ.get("DEBUG", "false").lower() == "true"
API_KEY = os.environ["API_KEY"]  # 必填——如果没有设置就会抛出异常
```

应用也可以通过配置文件来配置。
例如，一个 Python 程序可以通过 `yaml.load` 加载下面的 `config.yaml`：

```yaml
database:
  url: "postgresql://localhost/myapp"
  pool_size: 5
server:
  host: "0.0.0.0"
  port: 8080
  debug: false
```

理解配置时，一个很实用的原则是：
**同一套代码应该能够部署到不同环境（开发、预发布、生产），环境之间的差异只通过配置解决，而不应该通过修改代码解决。**

在众多配置项中，经常会包含 API Key 等敏感数据。
这类密钥必须谨慎处理，避免意外泄露，并且绝不能提交到版本控制系统中。

# 服务与编排

现代应用很少完全独立运行。
一个典型的 Web 应用可能需要数据库来持久化数据，需要缓存来提升性能，需要消息队列处理后台任务，还可能依赖其他辅助服务。
与其把所有功能都塞进一个庞大的单体应用中，现代架构通常会把功能拆分为多个独立服务，使它们可以分别开发、部署和扩缩容。

例如，如果我们发现应用需要缓存，与其自己实现一个缓存系统，不如直接使用已经经过大量实践验证的方案，例如 [Redis](https://redis.io/) 或 [Memcached](https://memcached.org/)。
我们当然可以把 Redis 作为应用依赖的一部分，在同一个容器里一起构建，但这样就需要同时协调 Redis 和应用各自的依赖，实际操作可能很困难，甚至无法实现。
更好的做法是把不同应用分别部署到各自独立的容器中。

这种架构通常被称为**微服务架构（microservice architecture）**：每个组件都作为独立服务运行，并通过网络互相通信，最常见的方式是 HTTP API。

[Docker Compose](https://docs.docker.com/compose/) 是一个用于定义和运行多容器应用的工具。
与其逐个手动管理容器，我们可以在一个 YAML 文件中声明所有服务，然后统一启动和编排。
这样，我们完整的应用就可以由多个容器组成：

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

执行 `docker compose up` 后，这两个服务会一起启动。
Web 应用可以通过主机名 `cache` 连接 Redis，因为 Docker 的内部 DNS 会自动解析服务名。

Docker Compose 允许我们声明一个或多个服务应该如何部署，并负责统一启动这些服务、建立服务之间的网络连接，以及管理用于持久化数据的共享卷（volume）。

在生产环境中，我们通常希望 Docker Compose 中的服务可以在系统开机时自动启动，并在异常退出后重新运行。
一种常见做法是使用 systemd 来管理 Docker Compose 部署：

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

这个 systemd unit 文件可以确保应用在系统启动时自动运行（并等待 Docker 准备完成），同时也可以使用标准命令来管理应用，例如 `systemctl start myapp`、`systemctl stop myapp` 和 `systemctl status myapp`。

当部署需求进一步复杂，例如需要跨多台机器进行扩缩容、在服务崩溃时实现容错，以及保证高可用性时，组织通常会使用 Kubernetes（k8s）这样的专业容器编排平台。
Kubernetes 可以在由多台机器组成的集群中管理成千上万个容器。
不过，它的学习曲线较陡，运维成本也很高，因此对于小型项目来说通常过于复杂。

现代服务之间通常通过标准化 API 通信，这也是多容器架构能够实现的重要原因之一，其中 HTTP REST API 非常常见。
例如，当程序调用 OpenAI 或 Anthropic 这样的 LLM 服务商时，底层实际上就是向对方服务器发送 HTTP 请求并解析返回结果：

```console
$ curl https://api.anthropic.com/v1/messages \
    -H "x-api-key: $ANTHROPIC_API_KEY" \
    -H "content-type: application/json" \
    -H "anthropic-version: 2023-06-01" \
    -d '{"model": "claude-sonnet-4-20250514", "max_tokens": 256,
         "messages": [{"role": "user", "content": "Explain containers vs VMs in one sentence."}]}'
```

# 发布软件

当你已经确认代码能够正常工作后，下一步往往就是把它分发出去，让其他人可以下载和安装。
软件分发有很多形式，而且与所使用的编程语言和运行环境密切相关。

最简单的分发方式，就是把构建产物上传到某个地方，让用户自行下载并在本机安装。
这种方式至今仍然很常见。
例如，[Ubuntu 的软件包归档](http://archive.ubuntu.com/ubuntu/pool/main/) 本质上就是一个通过 HTTP 提供的 `.deb` 文件目录。

如今，GitHub 已经成为发布源代码和构建产物的事实标准平台。
源代码通常直接公开，而 GitHub Releases 还允许维护者在带标签的版本上附加预编译二进制文件以及其他构建产物。

有些包管理器支持直接从 GitHub 安装软件，可以从源码构建，也可以直接安装已经构建好的 wheel：

```console
# 从源码安装（会先 clone 再构建）
$ pip install git+https://github.com/psf/requests.git

# 从指定 tag/branch 安装
$ pip install git+https://github.com/psf/requests.git@v2.32.3

# 直接安装 GitHub Release 中的 wheel
$ pip install https://github.com/user/repo/releases/download/v1.0/package-1.0-py3-none-any.whl
```

实际上，一些语言（例如 Go）采用的是去中心化分发模式。
Go 模块不是通过一个中央软件包仓库统一分发，而是直接从源代码仓库获取。
例如 `github.com/gorilla/mux` 这样的模块路径本身就说明了代码存放位置，`go get` 会直接从那里拉取代码。

不过，大多数包管理器（例如 `pip`、`cargo` 和 `brew`）仍然会使用中央索引，集中管理已经打包好的项目，从而方便软件分发和安装。
如果执行：

```console
$ uv pip install requests --verbose --no-cache 2>&1 | grep -F '.whl'
DEBUG Selecting: requests==2.32.5 [compatible] (requests-2.32.5-py3-none-any.whl)
DEBUG No cache entry for: https://files.pythonhosted.org/packages/1e/db/4254e3eabe8020b458f1a747140d32277ec7a271daf1d235b70dc0b4e6e3/requests-2.32.5-py3-none-any.whl.metadata
DEBUG No cache entry for: https://files.pythonhosted.org/packages/1e/db/4254e3eabe8020b458f1a747140d32277ec7a271daf1d235b70dc0b4e6e3/requests-2.32.5-py3-none-any.whl
```

就可以看到 `requests` 的 wheel 是从哪里下载的。
注意文件名中的 `py3-none-any`：这表示该 wheel 适用于任意 Python 3 版本、任意操作系统和任意处理器架构。

对于包含编译代码的软件包，wheel 通常会和具体平台绑定：

```console
$ uv pip install numpy --verbose --no-cache 2>&1 | grep -F '.whl'
DEBUG Selecting: numpy==2.2.1 [compatible] (numpy-2.2.1-cp312-cp312-macosx_14_0_arm64.whl)
```

这里的 `cp312-cp312-macosx_14_0_arm64` 表示，这个 wheel 专门适用于 CPython 3.12、macOS 14 及以上版本，并且处理器架构为 ARM64（Apple Silicon）。
如果使用的是其他平台，`pip` 会下载另一个适合该平台的 wheel，或者退回到从源码构建。

反过来，如果想让别人能够找到我们自己创建的软件包，就需要把它发布到某个软件包仓库。
在 Python 中，最主要的软件包仓库是 [Python Package Index（PyPI）](https://pypi.org)。

与安装类似，发布软件包也有多种方式。
`uv publish` 提供了一个现代化接口，可以把软件包上传到 PyPI：

```console
$ uv publish --publish-url https://test.pypi.org/legacy/
Publishing greeting-0.1.0.tar.gz
Publishing greeting-0.1.0-py3-none-any.whl
```

这里使用的是 [TestPyPI](https://test.pypi.org)。
它是一个专门用于测试发布流程的软件包仓库，可以避免在正式 PyPI 中留下测试包。
上传完成后，可以这样从 TestPyPI 安装：

```console
$ uv pip install --index-url https://test.pypi.org/simple/ greeting
```

发布软件时，一个非常重要的问题是**信任**。
用户如何确认自己下载的软件包确实来自你，而且在传输或存储过程中没有被篡改？
软件包仓库通常会使用校验和（checksum）验证完整性，有些生态还支持软件包签名，用密码学方式证明软件包的来源和作者身份。

不同语言有自己的软件包仓库：
Rust 使用 [crates.io](https://crates.io)，JavaScript 使用 [npm](https://www.npmjs.com)，Ruby 使用 [RubyGems](https://rubygems.org)，容器镜像则常使用 [Docker Hub](https://hub.docker.com)。
对于私有或组织内部的软件包，企业通常会搭建自己的软件包仓库，例如私有 PyPI 服务器或私有 Docker Registry，也可以使用云服务商提供的托管方案。

把 Web 服务部署到互联网还需要额外的基础设施，例如注册域名、配置 DNS 让域名指向服务器，以及使用 nginx 等反向代理来处理 HTTPS 和流量转发。
对于文档或静态网站这类简单场景，[GitHub Pages](https://pages.github.com/) 可以直接从仓库免费托管网站。

<!--
## 文档

到目前为止，我们一直把可交付的**构建产物（artifact）**作为代码打包和发布的主要输出。
除了构建产物本身，还需要为用户编写文档，说明代码的功能、安装方法和使用示例。

[Sphinx](https://www.sphinx-doc.org/)（Python）和 [MkDocs](https://www.mkdocs.org/) 等工具可以根据 docstring 和 Markdown 文件自动生成可浏览的文档，这些文档通常会托管在 [Read the Docs](https://readthedocs.org/) 等服务上。
对于基于 HTTP 的 API，[OpenAPI 规范](https://www.openapis.org/)（以前称为 Swagger）提供了一套描述 API 端点的标准格式，工具可以据此自动生成交互式文档和客户端库。
-->

# 练习

1. 使用 `printenv` 把当前环境变量保存到文件中，然后创建一个 venv 并激活它，再次使用 `printenv` 保存到另一个文件中，最后运行 `diff before.txt after.txt`。环境发生了哪些变化？为什么 Shell 会优先使用 venv？（提示：比较激活前后的 `$PATH`。）运行 `which deactivate`，并分析 `deactivate` 这个 bash 函数在做什么。
1. 创建一个带有 `pyproject.toml` 的 Python 包，并把它安装到虚拟环境中。创建 lockfile，并查看其中的内容。
1. 安装 Docker，并使用 docker compose 在本地构建 Missing Semester 课程网站。
1. 为一个简单的 Python 应用编写 Dockerfile，然后再编写一个 `docker-compose.yml`，让应用和 Redis 缓存一起运行。
1. 把一个 Python 包发布到 TestPyPI（除非确实值得分享，否则不要发布到正式 PyPI！）。然后用这个包构建 Docker 镜像，并推送到 `ghcr.io`。
1. 使用 [GitHub Pages](https://docs.github.com/en/pages/quickstart) 创建一个网站。额外（不计分）任务：为它配置自定义域名。

