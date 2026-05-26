---
layout: lecture
title: "代码的打包与交付"
description: >
  学习项目打包和封装环境，版本控制，和部署库，应用，和服务。
thumbnail: /static/assets/thumbnails/2026/lec6.png
date: 2026-01-20
ready: true
video:
  aspect: 56.25
  id: KBMiB-8P4Ns
---

让代码按你预想的那样运行很难；让同样的代码在不同机器上运行往往更难。
交付代码意味着把你写的代码转换成一种可用的形式，让别人不需要完全复制你的环境就能运行。
交付代码有多种形式，具体取决于编程语言、系统库、操作系统等诸多因素。
这也取决于你在构建什么：一个软件库、一个命令行工具或一个网络服务都有不同的需求和部署步骤。
无论如何，所有这些场景背后都有一个共同的规律：我们需要定义清楚可交付物是什么（也就是制品），以及它对周围环境做出了哪些假设。

在这篇演讲中，我们将会覆盖：

- [依赖与环境](#依赖与环境)
- [制品和打包](#制品和打包)
- [发布与版本](#发布与版本)
- [可复用性](#可复用性)
- [虚拟机和容器](#虚拟机和容器)
- [设置](#设置)
- [服务与编排](#服务与编排)
- [交付](#交付)

我们将通过Python生态系统中的例子来解释这些概念，因为具体的例子有助于理解。虽然其他编程语言生态系统的工具不同，但概念大致相同。

# 依赖与环境

在现代软件开发中，抽象层无处不在。程序自然地将逻辑委托给其他库或服务。然而，这会在你的程序和程序运行所需的库之间引入一种_依赖_关系。例如，在Python中，要获取网站内容，我们经常这样做：

```python
import requests

response = requests.get("https://missing.csail.mit.edu")
```

然而`requests`库并未与Python运行时捆绑在一起，因此如果我们尝试在没有安装`requests`的情况下运行这段代码，Python会报错：

```console
$ python fetch.py
Traceback (most recent call last):
  File "fetch.py", line 1, in <module>
    import requests
ModuleNotFoundError: No module named 'requests'
```

为了使用这个库，我们需要先运行`pip install requests`来安装它。
`pip`是Python编程语言提供的用于安装包的命令行工具。
执行`pip install requests`会执行以下操作序列：

1. 在Python Package Index ([PyPI](https://pypi.org/))中搜索`requests`库;
1. 搜索适用于当前运行平台的制品;
1. 解析依赖关系——`requests`库本身也依赖其他包，因此安装程序必须找到所有传递性依赖的兼容版本，并事先安装它们;
1. 下载这些制品，然后解压并将文件复制到我们文件系统中的正确位置。

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
这里我们可以看到`requests`拥有自己的依赖，如`certifi`和`charset-normalizer`，它们需要在`requests`安装之前先安装。
安装后，Python运行时就可以在导入时找到这个库。

```console
$ python -c 'import requests; print(requests.__path__)'
['/usr/local/lib/python3.11/dist-packages/requests']

$ pip list | grep requests
requests        2.32.3
```
编程语言有不同的工具、传统和惯例来安装和发布库。
在一些语言（比如Rust）中，工具链是统一化的——`cargo`负责所有构建、测试、依赖管理和发布。
而在其他语言（比如Python）中，统一化发生在规范层面——并非只有一个工具，而是有一套标准化的规范来定义打包的工作方式，允许多个竞争工具执行不同任务（`pip`与[`uv`](https://docs.astral.sh/uv/)、`setuptools`与[`hatch`](https://hatch.pypa.io/)与[`poetry`](https://python-poetry.org/)）。而在某些生态系统如LaTeX中，像TeX Live或MacTeX这样的发行版会预装成千上万个软件包。

引入依赖也会引入冲突。
当程序需要同一依赖的不兼容版本时，冲突就会发生。例如，如果`tensorflow==2.3.0`需要`numpy>=1.16.0,<1.19.0`而`pandas==1.2.0`需要`numpy>=1.16.5`，那么任何满足`numpy>=1.16.5,<1.19.0`的版本都是有效的。但如果你项目中的另一个包需要`numpy>=1.19`，就会产生冲突，因为没有满足所有约束的有效版本。

这种情况——多个包需要共享依赖的互不兼容版本——通常被称为_依赖地狱（dependency hell）_。
一种解决这些冲突的方法是将每个程序的依赖隔离到它们自己的 _环境_ 中。
在Python中，我们通过运行以下命令来创建虚拟环境：

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
你可以把环境想象成语言运行时的完整独立版本，拥有自己安装的一组包。
这种虚拟环境（venv）将已安装的依赖与全局Python安装隔离开来。
为每个项目配备单独的虚拟环境是一种好习惯，每个环境包含该项目所需的依赖。

> 尽管许多现代操作系统自带了诸如Python等编程语言运行时的安装，但修改这些安装是不明智的，因为操作系统可能依赖它们来实现自身功能。建议改用独立的环境。

在某些语言中，安装协议并非由某个工具来定义，而是作为一种规范存在。
在Python中，[PEP 517](https://peps.python.org/pep-0517/)定义了构建系统接口，[PEP 621](https://peps.python.org/pep-0621/)指定了项目的元数据（metadata）如何存储在`pyproject.toml`中。
这使开发者能够在`pip`基础上进行改进并开发出更优化的工具，如`uv`。安装`uv`只需运行`pip install uv`。

使用 uv 替代 pip 时，接口相同，但速度显著更快：

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

> 我们强烈建议尽可能使用 `uv pip` 而不是 `pip`，因为它能显著缩短安装时间。

除了依赖隔离之外，环境还能让你使用不同版本的编程语言运行时。

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

这在需要在多个 Python 版本上测试代码或项目需要特定版本时很有帮助。

> 在某些编程语言中，每个项目会自动获得自己的依赖环境，而无需手动创建，但原理是相同的。如今大多数语言也都有机制来在单个系统上管理多个语言版本，然后为各个项目指定使用哪个版本。

# 制品和打包

在软件开发中，我们区分源代码和制品。开发者编写和阅读源代码，而制品是从源代码生成的、打包后可分发的输出——随时可供安装或部署。
制品可以简单到我们运行的一个代码文件，也可以复杂到包含应用程序各种必要组件的完整虚拟机。
考虑这个例子，我们在当前目录中有一个 Python 文件 `greet.py`：

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

一旦我们移动到不同的目录，导入就会失败，因为 Python 只在特定位置搜索模块（当前目录、已安装的包和 `PYTHONPATH` 中的路径）。打包通过将代码安装到已知位置来解决这个问题。

在 Python 中，打包库涉及生成一个制品，包安装工具如 `pip` 或 `uv` 可以用它来安装相关文件。
Python 制品被称为 _wheels_，包含安装包所需的所有信息：代码文件、包的元数据（名称、版本、依赖）以及在环境中放置文件的说明。
构建制品需要我们编写一个项目文件（也称为清单），详细说明项目的具体信息、所需依赖、包版本和其他信息。在 Python 中，我们使用 `pyproject.toml` 来实现这一目的。

> `pyproject.toml` 是现代且推荐的方案。虽然早期打包方法如 `requirements.txt` 或 `setup.py` 仍然受支持，但只要可能，你应该优先使用 `pyproject.toml`。

以下是一个最小化 `pyproject.toml` 示例，适用于同时提供命令行工具的库：

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

`typer` 库是一个流行的 Python 包，用于以最少样板代码创建命令行界面。

相应的 `greeting.py`：

```python
import typer


def greet(name: str) -> str:
    return f"Hello, {name}!"


def main(name: str):
    print(greet(name))


if __name__ == "__main__":
    typer.run(main)
```

有了这个文件，我们现在可以构建 wheel 了：

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

`.whl` 文件是 the wheel（具有特定结构的 zip 归档），而 `.tar.gz` 是需要从源码构建的系统使用的源码分发。

你可以检查 wheel 的内容，看看打包了什么：

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

现在如果我们把这个 wheel 给其他人，他们可以通过运行以下命令来安装：

```console
$ uv pip install ./greeting-0.1.0-py3-none-any.whl
$ greet Alice
Hello, Alice!
```

这将把我们之前构建的库安装到他们的环境中，包括 `greet` CLI 工具。

这种方法有局限性。特别是如果我们的库依赖于平台特定库，如用于 GPU 加速的 CUDA，那么我们的制品只在安装了这些特定库的系统上工作，我们可能需要为不同平台（Linux、macOS、Windows）和架构（x86、ARM）构建单独的 wheel。

安装软件时，源码安装和预构建二进制安装之间存在重要区别。源码安装意味着下载原始代码并在你的机器上编译——这需要安装编译器和构建工具，对于大型项目可能需要相当长的时间。

安装预构建二进制文件意味着下载已由他人编译的制品——更快更简单，但二进制文件必须与你的平台和架构匹配。
例如，[ripgrep 的发布页面](https://github.com/BurntSushi/ripgrep/releases) 显示了适用于 Linux（x86_64、ARM）、macOS（Intel、Apple Silicon）和 Windows 的预构建二进制文件。


# 发布与版本

代码是持续构建的，但是离散发布的。
在软件开发中，开发环境和生产环境之间存在明显区别。
代码需要在开发环境中被证明有效，然后才能被 _交付_ 到生产环境。
发布过程涉及许多步骤，包括测试、依赖管理、版本控制、配置、部署和公开发布。

软件库不是静态的，会随时间演变，获得修复和新功能。
我们通过离散的版本标识符来跟踪这种演变，这些标识符对应于库在特定时间点的状态。
库行为的变化范围包括修复非关键功能的补丁、扩展其功能的新特性，以及破坏向后兼容性的更改。
变更日志记录了版本引入的更改——这是软件开发人员用来传达新版本相关更改的文档。

然而，跟踪每个依赖的持续变化是不切实际的，考虑传递依赖时更是如此——即我们依赖的依赖。

> 你可以使用 `uv tree` 可视化项目的整个依赖树，它以树形格式显示所有包及其传递依赖。

为了简化这个问题，有一些关于如何对软件进行版本控制的约定，其中最常见的是[语义化版本控制](https://semver.org/)或 SemVer。
在语义化版本控制下，版本具有 MAJOR.MINOR.PATCH 形式的标识符，其中每个值都取整数值。简而言之，升级时：

- PATCH（例如，1.2.3 → 1.2.4）应该只包含错误修复，并且完全向后兼容
- MINOR（例如，1.2.3 → 1.3.0）以向后兼容的方式添加新功能
- MAJOR（例如，1.2.3 → 2.0.0）表示可能需要进行代码修改的重大更改

> 这是一个简化版本，我们建议阅读完整的 SemVer 规范，以了解例如为什么从 0.1.3 到 0.2.0 可能会导致破坏性更改，或者 1.0.0-rc.1 是什么意思。
Python 打包原生支持语义化版本控制，因此当我们指定依赖的版本时，可以使用各种限定符：

在 `pyproject.toml` 中，我们有不同的方式来限制依赖的兼容版本范围：

```toml
[project]
dependencies = [
    "requests==2.32.3",  # 精确版本 - 只有这个特定版本
    "click>=8.0",        # 最低版本 - 8.0 或更新版本
    "numpy>=1.24,<2.0",  # 范围 - 至少 1.24 但小于 2.0
    "pandas~=2.1.0",     # 兼容版本 - >=2.1.0 且 <2.2.0
]
```

版本限定符存在于许多包管理器（npm、cargo 等）中，具有不同的确切语义。`~=` 运算符是 Python 的"兼容版本"运算符——`~=2.1.0` 表示"任何与 2.1.0 兼容的版本"，转换为 `>=2.1.0` 和 `<2.2.0`。这大致等同于 npm 和 cargo 中的插入符（`^`）运算符，它遵循 SemVer 的兼容性概念。

并非所有软件都使用语义化版本控制。一个常见的替代方案是日历版本控制（CalVer），其中版本基于发布日期而非语义含义。例如，Ubuntu 使用像 `24.04`（2024年4月）和 `24.10`（2024年10月）这样的版本。CalVer 可以轻松看出发布的年代，但它不传达任何关于兼容性的信息。最后，语义化版本控制并非绝对可靠，有时维护者会在次要版本或补丁版本中无意中引入破坏性更改。


# 可复用性

在现代软件开发中，你编写的代码位于大量抽象层之上。
这包括你的编程语言运行时、第三方库、操作系统，甚至硬件本身。
这些层中的任何差异都可能改变代码的行为，甚至阻止其按预期工作。
此外，底层硬件的差异也会影响你交付软件的能力。

固定一个库指的是指定精确版本而不是范围，例如 `requests==2.32.3` 而不是 `requests>=2.0`。

包管理器的工作之一是考虑依赖提供的所有约束——以及传递依赖——然后生成一个满足所有约束的有效版本列表。
然后可以将这个特定的版本列表保存到文件中，以实现可复用性；这些文件被称为 _锁定文件_。

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

在处理依赖版本控制和可复用性时，一个关键的区别是库与应用程序/服务之间的差异。
库旨在被其他代码导入和使用，这些代码可能有自己的依赖，因此指定过于严格的版本约束可能会导致与用户其他依赖的冲突。
相比之下，应用程序或服务是软件的最终消费者，通常通过用户界面或 API 而非编程接口暴露其功能。
对于库，指定版本范围以最大化与更广泛包生态系统的兼容性是一个好习惯。对于应用程序，固定精确版本可以确保可复现性——每个运行应用程序的人都使用完全相同的依赖。


对于需要最大可复现性的项目，像 [Nix](https://nixos.org/) 和 [Bazel](https://bazel.build/) 这样的工具提供了 _密封式_ 构建——其中每个输入，包括编译器、系统库，甚至构建环境本身都被固定和内容寻址。这保证了无论构建在何时何地运行，都能产生逐位相同的输出。

> 你甚至可以使用 NixOS 管理你的整个计算机安装，这样你就可以轻松地启动计算机设置的新副本，并通过版本控制的配置文件管理它们的完整配置。

软件开发中一个永恒的矛盾是，新软件版本会有意或无意地引入破坏，而另一方面，旧软件版本会随着时间的推移而遭受安全漏洞的侵害。
我们可以通过使用持续集成管道（我们将在[代码质量与 CI](/2026/code-quality/)讲座中看到更多）来解决这个问题，这些管道针对新软件版本测试我们的应用程序，并拥有检测依赖新版本何时发布的自动化机制，例如 [Dependabot](https://github.com/dependabot)。

即使有了 CI 测试，升级软件版本时仍然会出现问题，通常是因为开发和生产环境之间不可避免的不匹配。
在这种情况下，最好的做法是制定一个 _回滚_ 计划，即回退版本升级并重新部署已知的良好版本。

# 虚拟机和容器

当你开始依赖更复杂的依赖项时，你的代码的依赖项可能会超出包管理器所能处理的范围。
一个常见的原因是必须与特定的系统库或硬件驱动程序交互。
例如，在科学计算和 AI 中，程序通常需要专门的库和驱动程序来利用 GPU 硬件。
许多系统级依赖项（GPU 驱动程序、特定的编译器版本、像 OpenSSL 这样的共享库）仍然需要系统范围的安装。

传统上，这种更广泛的依赖问题通过虚拟机（VM）来解决。
虚拟机抽象整个计算机，并提供具有自己专用操作系统的完全隔离的环境。
一种更现代的方法是容器，它将应用程序及其依赖项、库和文件系统打包在一起，但共享主机的操作系统内核，而不是虚拟化整个计算机。
容器比虚拟机更轻量，因为它们共享内核，使它们启动更快、运行更高效。

最受欢迎的容器平台是 [Docker](https://www.docker.com/)。Docker 引入了一种标准化的方式来构建、分发和运行容器。在底层，Docker 使用 containerd 作为其容器运行时——这是 Kubernetes 等其他工具也使用的行业标准。

运行容器很简单。例如，要在容器内运行 Python 解释器，我们使用 `docker run`（`-it` 标志使容器具有交互式终端。当你退出时，容器停止。）。

```console
$ docker run -it python:3.12 python
Python 3.12.7 (main, Nov  5 2024, 02:53:25) [GCC 12.2.0] on linux
>>> print("Hello from inside a container!")
Hello from inside a container!
```

实际上，你的程序可能依赖于整个文件系统。
为了解决这个问题，我们可以使用容器镜像，它将应用程序的整个文件系统作为制品交付。
容器镜像是通过编程方式创建的。使用 docker，我们可以使用 Dockerfile 语法精确指定镜像的依赖项、系统库和配置：

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

一个重要的区别：Docker **镜像**是打包的制品（就像一个模板），而**容器**是该镜像的运行实例。你可以从同一个镜像运行多个容器。镜像是分层构建的，Dockerfile 中的每个指令（`FROM`、`RUN`、`COPY` 等）都会创建一个新层。Docker 会缓存这些层，因此如果你更改 Dockerfile 中的一行，只有该层及后续层需要重新构建。

之前的 Dockerfile 有几个问题：它使用完整的 Python 镜像而不是精简版本，运行单独的 `RUN` 命令会创建不必要的层，版本没有固定，而且它不清除包管理器缓存，导致传送了不必要的文件。其他常见错误包括以 root 身份不安全地运行容器，以及不小心在层中嵌入机密。

以下是一个改进的版本

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

在上一个例子中，我们看到我们不是从源代码安装 `uv`，而是从 `ghcr.io/astral-sh/uv:latest` 镜像复制预构建的二进制文件。这被称为 _构建器_ 模式。使用这种模式，我们不需要传送编译代码所需的所有工具，只需要运行应用程序所需的最终二进制文件（在本例中是 `uv`）。

Docker 有一些需要注意的重要限制。首先，容器镜像通常是特定于平台的——为 `linux/amd64` 构建的镜像在没有仿真的情况下无法在 `linux/arm64`（Apple Silicon Macs）上本地运行，而仿真很慢。其次，Docker 容器需要 Linux 内核，因此在 macOS 和 Windows 上，Docker 实际上在后台运行一个轻量级的 Linux 虚拟机，增加了开销。第三，Docker 的隔离性比虚拟机弱——容器共享主机内核，这在多租户环境中是一个安全问题。

> 如今，越来越多的项目也使用 nix 通过 [nix flakes](https://serokell.io/blog/practical-nix-flakes) 为每个项目管理甚至是"系统范围"的库和应用程序。

# 设置

软件本质上是可配置的。在[命令行环境](/2026/command-line-environment/)讲座中，我们看到程序通过标志、环境变量甚至配置文件（又称 dotfiles）接收选项。即使对于更复杂的应用程序，这也适用，并且有用于大规模管理配置的既定模式。
软件配置不应嵌入代码中，而应在运行时提供。
常见的几种方式是环境变量和配置文件。

以下是一个通过环境变量配置的应用程序示例：

```python
import os

DATABASE_URL = os.environ.get("DATABASE_URL", "sqlite:///local.db")
DEBUG = os.environ.get("DEBUG", "false").lower() == "true"
API_KEY = os.environ["API_KEY"]  # Required - will raise if not set
```

应用程序也可以通过配置文件进行配置（例如，通过 `yaml.load` 加载配置的 Python 程序），`config.yaml`：

```yaml
database:
  url: "postgresql://localhost/myapp"
  pool_size: 5
server:
  host: "0.0.0.0"
  port: 8080
  debug: false
```

思考配置的一个好的经验法则是，相同的代码库应该可以通过仅更改配置而不更改代码的方式部署到不同的环境（开发、预发布、生产）。

在许多配置选项中，通常包含敏感数据，如 API 密钥。
需要小心处理机密，以避免意外暴露它们，并且绝不能将其包含在版本控制中。


# 服务与编排

现代应用程序很少孤立存在。一个典型的 Web 应用程序可能需要数据库进行持久化存储、缓存以提高性能、消息队列用于后台任务，以及各种其他支持服务。现代架构通常将功能分解为可以独立开发、部署和扩展的独立服务，而不是将所有内容捆绑到一个单一的单体应用程序中。

举个例子，如果我们确定应用程序可能从使用缓存中受益，我们可以利用现有的经过实战检验的解决方案，如 [Redis](https://redis.io/) 或 [Memcached](https://memcached.org/)，而不是自己编写。
我们可以将 Redis 嵌入到应用程序依赖中，将其作为容器的一部分构建，但这意味着协调 Redis 和我们应用程序之间的所有依赖，这可能具有挑战性甚至不可行。
相反，我们可以做的是在每个应用程序自己的容器中分别部署它们。
这通常被称为微服务架构，其中每个组件作为独立服务运行，通过网络通信，通常通过 HTTP API。

[Docker Compose](https://docs.docker.com/compose/) 是一个用于定义和运行多容器应用程序的工具。与其单独管理容器，你可以在单个 YAML 文件中声明所有服务并一起编排它们。现在我们的完整应用程序包含多个容器：

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

使用 `docker compose up`，两个服务一起启动，Web 应用程序可以使用主机名 `cache` 连接到 Redis（Docker 的内部 DNS 会自动解析服务名称）。
Docker Compose 让我们声明如何部署一个或多个服务，并处理一起启动它们的编排、在它们之间建立网络连接，以及管理用于数据持久化的共享卷。

对于生产部署，你通常希望 docker compose 服务在启动时自动启动，并在失败时重新启动。一种常见的方法是使用 systemd 来管理 docker compose 部署：

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

此 systemd 单元文件确保你的应用程序在系统启动时启动（在 Docker 准备就绪后），并提供标准控制，如 `systemctl start myapp`、`systemctl stop myapp` 和 `systemctl status myapp`。

随着部署需求变得更加复杂——需要在多台机器上进行扩展、服务崩溃时的容错能力以及高可用性保证——组织转向复杂的容器编排平台，如 Kubernetes（k8s），它可以在机器集群中管理数千个容器。也就是说，Kubernetes 有陡峭的学习曲线和显著的运维开销，因此对于较小的项目来说通常过于复杂。

这种多容器设置之所以部分可行，是因为现代服务通过标准化 API（HTTP REST API）相互通信。例如，每当程序与像 OpenAI 或 Anthropic 这样的 LLM 提供商交互时，在底层它正在向它们的服务器发送 HTTP 请求并解析响应：

```console
$ curl https://api.anthropic.com/v1/messages \
    -H "x-api-key: $ANTHROPIC_API_KEY" \
    -H "content-type: application/json" \
    -H "anthropic-version: 2023-06-01" \
    -d '{"model": "claude-sonnet-4-20250514", "max_tokens": 256,
         "messages": [{"role": "user", "content": "Explain containers vs VMs in one sentence."}]}'
```

# 交付

一旦你证明了你的代码可以工作，你可能会有兴趣分发它供其他人下载和安装。
分发有多种形式，并且与你所使用的编程语言和环境紧密相关。

最简单的分发形式是上传制品供人们下载并在本地安装。
这仍然很常见，你可以在 [Ubuntu 的软件包归档](http://archive.ubuntu.com/ubuntu/pool/main/) 等地方找到它，它本质上是 `.deb` 文件的 HTTP 目录列表。

如今，GitHub 已成为发布源代码和制品的事实标准平台。
虽然源代码通常是公开可用的，但 GitHub Releases 允许维护者将预构建的二进制文件和其他制品附加到带标签的版本。


包管理器有时支持直接从 GitHub 安装，无论是从源代码还是从预构建的 wheel：

```console
# Install from source (will clone and build)
$ pip install git+https://github.com/psf/requests.git

# Install from a specific tag/branch
$ pip install git+https://github.com/psf/requests.git@v2.32.3

# Install a wheel directly from a GitHub release
$ pip install https://github.com/user/repo/releases/download/v1.0/package-1.0-py3-none-any.whl
```

事实上，像 Go 这样的一些语言使用去中心化的分发模式——而不是中央包仓库，Go 模块直接从其源代码仓库分发。
像 `github.com/gorilla/mux` 这样的模块路径指示代码所在的位置，`go get` 直接从那里获取。然而，大多数包管理器如 `pip`、`cargo` 或 `brew` 都有预打包项目的中央索引，以便于分发和安装。如果我们运行

```console
$ uv pip install requests --verbose --no-cache 2>&1 | grep -F '.whl'
DEBUG Selecting: requests==2.32.5 [compatible] (requests-2.32.5-py3-none-any.whl)
DEBUG No cache entry for: https://files.pythonhosted.org/packages/1e/db/4254e3eabe8020b458f1a747140d32277ec7a271daf1d235b70dc0b4e6e3/requests-2.32.5-py3-none-any.whl.metadata
DEBUG No cache entry for: https://files.pythonhosted.org/packages/1e/db/4254e3eabe8020b458f1a747140d32277ec7a271daf1d235b70dc0b4e6e3/requests-2.32.5-py3-none-any.whl
```

我们可以看到从哪里获取 `requests` wheel。注意文件名中的 `py3-none-any`——这意味着 wheel 适用于任何 Python 3 版本，在任何操作系统上，任何架构上。对于具有编译代码的包，wheel 是特定于平台的：

```console
$ uv pip install numpy --verbose --no-cache 2>&1 | grep -F '.whl'
DEBUG Selecting: numpy==2.2.1 [compatible] (numpy-2.2.1-cp312-cp312-macosx_14_0_arm64.whl)
```

这里的 `cp312-cp312-macosx_14_0_arm64` 表示此 wheel 专门针对 macOS 14+ 上的 ARM64（Apple Silicon）的 CPython 3.12。如果你在不同的平台上，`pip` 将下载不同的 wheel 或从源代码构建。

相反，为了让人们能够找到我们创建的包，我们需要将其发布到这些注册表之一。
在 Python 中，主要的注册表是 [Python Package Index (PyPI)](https://pypi.org)。
与安装一样，有多种发布包的方式。`uv publish` 命令提供了一个现代的界面上传包到 PyPI：

```console
$ uv publish --publish-url https://test.pypi.org/legacy/
Publishing greeting-0.1.0.tar.gz
Publishing greeting-0.1.0-py3-none-any.whl
```

这里我们使用 [TestPyPI](https://test.pypi.org)——一个单独的包注册表，用于测试你的发布工作流而不会污染真正的 PyPI。上传后，你可以从 TestPyPI 安装：

```console
$ uv pip install --index-url https://test.pypi.org/simple/ greeting
```

发布软件时一个关键的考虑因素是信任。用户如何验证他们下载的包确实来自你并且没有被篡改？包注册表使用校验和来验证完整性，一些生态系统支持包签名以提供作者身份的加密证明。

不同的语言有自己的包注册表：[crates.io](https://crates.io) 用于 Rust，[npm](https://www.npmjs.com) 用于 JavaScript，[RubyGems](https://rubygems.org) 用于 Ruby，[Docker Hub](https://hub.docker.com) 用于容器镜像。同时，对于私有或内部包，组织通常部署自己的包仓库（如私有 PyPI 服务器或私有 Docker 注册表）或使用云提供商的托管解决方案。

将 Web 服务部署到互联网需要额外的基础设施：域名注册、DNS 配置以将你的域名指向你的服务器，以及通常像 nginx 这样的反向代理来处理 HTTPS 和路由流量。对于更简单的用例，如文档或静态站点，[GitHub Pages](https://pages.github.com/) 直接从仓库提供免费托管。

<!--
## Documentation

So far we have emphasized the deliverable _artifact_ as the main output of packaging and shipping code.
In addition to the artifact, we need to document for users the code's functionality, installation instructions, and usage examples.

Tools like [Sphinx](https://www.sphinx-doc.org/) (Python) and [MkDocs](https://www.mkdocs.org/) can automatically generate browsable documentation from docstrings and markdown files, often hosted on services like [Read the Docs](https://readthedocs.org/).
For HTTP-based APIs, the [OpenAPI specification](https://www.openapis.org/) (formerly Swagger) provides a standard format for describing API endpoints, which tools can use to generate interactive documentation and client libraries automatically. -->


# 练习

1. 使用 `printenv` 将环境保存到文件中，创建一个 venv，激活它，将 `printenv` 输出到另一个文件，然后使用 `diff before.txt after.txt` 比较。环境中发生了什么变化？为什么 shell 优先选择 venv？（提示：查看激活前后的 `$PATH`。）运行 `which deactivate` 并推理 deactivate bash 函数在做什么。
1. 创建一个带有 `pyproject.toml` 的 Python 包，并将其安装在虚拟环境中。创建锁定文件并检查它。
1. 安装 Docker 并使用它在本地构建 Missing Semester 课程网站，使用 docker compose。
1. 为一个简单的 Python 应用程序编写 Dockerfile。然后编写一个 `docker-compose.yml`，让你的应用程序与 Redis 缓存一起运行。
1. 将一个 Python 包发布到 TestPyPI（除非值得分享，否则不要发布到真正的 PyPI！）。然后使用所述包构建 Docker 镜像并将其推送到 `ghcr.io`。
1. 使用 [GitHub Pages](https://docs.github.com/en/pages/quickstart) 制作一个网站。额外（非）学分：使用自定义域名配置它。
