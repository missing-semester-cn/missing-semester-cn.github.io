---
layout: lecture
title: "Packaging and Shipping Code"
description: >
 了解项目打包、环境、版本管理以及库、应用和服务的部署。
thumbnail: /static/assets/thumbnails/2026/lec6.png
date: 2026-01-20
ready: true
video:
  aspect: 56.25
  id: KBMiB-8P4Ns
---

让代码能够在自己的电脑上成功跑起来已经很难了；而让同一套代码在别人的电脑上也能跑通往往更加困难。

“交付”代码就是把你写好的代码，打包成一个别人拿过去就能运行的“形式”，整个过程不需要知道你的电脑的具体配置。不同的构建产物：软件库、命令行工具和web服务，他们的需求和部署的步骤也各不相同。取决于你所用的编程语言、系统库和操作系统等多种因素。这使得发布代码的形式也是不同的。但是无论如何，这些场景下都有一个共同的结果：我们需要定义好最后要交出的“成品” --- 即产物  （Artifact )是什么，并且明确的写出他对于运行环境的要求。

这次讲座当中，将会涵盖这些部分：

- [依赖关系和环境](#dependencies--environments)
- [产物与打包](#artifacts--packaging)
- [发布与版本控制](#releases--versioning)
- [可重复性](#reproducibility)
- [虚拟机与容器](#vms--containers)
- [配置](#configuration)
- [服务与编排](#services--orchestration)
- [发版](#publishing)

我们将在Python生态当中来举例子解释这些概念，因为具体的例子有助于理解抽象的概念。虽然不同语言所用的工具各不相同，但是概念是相通的

# 依赖关系和环境

现代的软件开发当中，抽象无处不在。 程序会将需要处理的逻辑交给别的库或者是不同的服务去做。但是这样就会不可避免的引入程序与其运行所需的库之间的依赖关系。

例如，在Python当中，想要获取网站内容，我们通常会这样做：

```python
import requests

response = requests.get("https://missing.csail.mit.edu")
```

不过，`requests` 库并不会随着Python运行时进行安装，如果我们尝试在没有安装 `requests`库的情况下运行这段代码，将会收到以下的报错：

```console
$ python fetch.py
Traceback (most recent call last):
  File "fetch.py", line 1, in <module>
    import requests
ModuleNotFoundError: No module named 'requests'
```

为了解决依赖错误问题，需要执行 `pip install requests` 来安装。

 `pip` 是 Python 编程语言用于安装包的命令行工具。执行 `pip install requests`，系统将会按照以下的步骤进行安装：

1. 在Python包索引([PyPI](https://pypi.org/))当中搜索请求。
1. 搜索我们所运行的平台的相应产物。
1. 解决依赖---  `requests`库本身需要依赖于其他的包，因此安装程序必须找到所有传递依赖的兼容版本并安装。
1. 下载这些产物，然后解压并复制到文件系统当中正确的位置。

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

我们可以看到 `requests` 有它自己的依赖，例如certifi` 或 `charset-normalizer，因此，需要先安装它们才能够安装 `requests` 。安装后，Python在运行时就能找到这些库

```console
$ python -c 'import requests; print(requests.__path__)'
['/usr/local/lib/python3.11/dist-packages/requests']

$ pip list | grep requests
requests        2.32.3
```

不同的编程语言在安装和发布库的时候有不同的工具和要求。
在一些语言，比如Rust当中，工具链已经规定好了--- `cargo` 负责构建、测试、依赖管理和发布。

在其他语言，例如Python当中，规定主要体现在规范层面  --- 这并非单一工具的使用，而是有着标准化规范去定义的打包工作方式，多种拥有相同的工具都能够完成这些事情(`pip` vs [`uv`](https://docs.astral.sh/uv/), `setuptools` vs [`hatch`](https://hatch.pypa.io/) vs [`poetry`](https://python-poetry.org/)).
而在像是LaTeX这样的生态系统当中，像 TeX Live 或 MacTeX 这样的发行版预装了成千上万个软件包。

伴随着依赖关系出现的还有依赖冲突。程序在面对相同依赖的不兼容版本时，就会产生依赖冲突。比如，如果 `tensorflow==2.3.0` 需要 `numpy>=1.16.0，<1.19.0`，` 而 pandas==1.2.0` 需要 `numpy>=1.16.5`，那么任何满足 `numpy>=1.16.5，<1.19.0` 的版本都有效。但如果你项目中的另一个包要求 `numpy>=1.19`，那就存在冲突，没有满足所有约束。

面对这种“依赖地狱”--多个包需要的共享依赖版本相互互不兼容，我们可以将每个程序的依赖隔离到各自的环境当中来解决。

在 Python 中，运行下面这些命令来创建隔离的虚拟环境：

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

你可以将虚拟环境看做是一个隔离的空间，里面有一套自己的已安装包。这个虚拟环境或 venv 将已安装的依赖与全局 Python 安装隔离开来。我们建议你为每个项目配备一个包含所需的依赖关系。这是个管理依赖的好习惯

> 虽然许多现代操作系统预先安装了例如 Python 等编程语言，但是我们不推荐直接修改这些已经安装好的配置，你的操作系统有可能依赖他们，我倾向于使用独立的环境

有些语言当中，安装协议不取决于工具，而是由规范确定。在 Python 中，[PEP 517](https://peps.python.org/pep-0517/) 定义了构建系统接口，[PEP 621](https://peps.python.org/pep-0621/) 则规定了项目元数据如何在 `pyproject.toml` 中存储。

这让开发者能够改进 `pip`，并生成像 `uv` 这样经过优化的工具。安装 `uv` 只需要 `pip install uv` 即可。

使用 `uv` 代替 `pip`，他们的接口是相同的，但是`uv`的速度更快：

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

> 为了显著缩短安装的时间，我们强烈建议，尽量使用 `uv pip` 代替 `pip`。

除了能够隔离依赖，隔离的环境还能让你使用用一个语言的不同版本来运行代码

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

当你需要多个版本Python运行代码或者项目的时候，隔离的环境显然很有用。    

> 在某些编程语言当中，依赖已经不用你手动创建了，每个项目会自己去获取所需的依赖。但是原理是一样的，现在多数的语言都有管理单一系统上多版本的机制，并且可以指定单个项目所使用的版本。

# 产物和打包

软件开发当中，开发人员负责编写、读取代码。而其他人得到的则是已经能够准备安装或者部署的产出。这就是由源代码产生的可打包、可分发的输出，也就是“产物”。

一个产物可以简单到仅仅是一个代码文件，也可以复杂到包含应用所有部分的整个虚拟机。 

看这个例子，我们当前目录中有一个 Python 文件 `greet.py`：

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

导入报错了，因为Python只会搜索**特定位置**的模块（当前目录、已安装的包和`PYTHONPATH` 中的路径）。所以打包需要将代码安装到Python已知的位置。

在 Python 中，打包库涉及生成一个工件，使用 `pip` 或 `uv` 可以安装相关文件。

Python 的产物称为轮子（*wheels*），包含安装包所需的所有信息：代码文件、包的元数据（名称、版本、依赖）以及文件放置的指令。

构建产物需要我们编写一个项目文件（通常称为 manifest），详细说明项目的具体内容、所需的依赖关系、包的版本以及其他信息。Python 当中，我们使用 `pyproject.toml` 来实现。

> `pyproject.toml` 是现代且推荐的方式。虽然早期的打包方法比如 `requirements.txt` 或 `setup.py` 还能使用，但是还是推荐尽量使用 `pyproject.toml`。

这里有一个库的简单 `pyproject.toml` ，同时里面有一些命令行工具：

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

 `typer` 是一个流行的Python软件包，可以构建Python命令行程序。

相应的 `greeting.py`是这样写的:

```python
import typer


def greet(name: str) -> str:
    return f"Hello, {name}!"


def main(name: str):
    print(greet(name))


if __name__ == "__main__":
    typer.run(main)
```

有了这个文件，我们现在就可以构建轮子了：

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

 `.whl` 是轮子（带有特殊结构的压缩包），`.tar.gz` 是需要从源代码构建的系统源代码发行版。

你可以检查轮子里面的东西，看看什么会被打包：

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

如果我们把这个轮子给别人，他们可以通过这样的命令来安装：

```console
$ uv pip install ./greeting-0.1.0-py3-none-any.whl
$ greet Alice
Hello, Alice!
```

这样我们之前构建的库会安装到他们的环境中，包括 `greet` CLI 工具。

这种方法存在局限性。特别是如果我们的库依赖于特定平台的库，比如 CUDA 用于 GPU 加速，那么我们的工件只能在安装了这些特定库的系统上工作，可能要为不同平台（Linux、macOS、Windows）和架构（x86、ARM）分别构建轮子。

安装软件时，从源代码安装和安装预构建的二进制文件的主要区别是，你需要在电脑上安装编译器和构建工具，下载源代码并进行编译。如果项目很大，可能会花费相当长的时间。

安装预构建的二进制文件则是使用别人已经编译好的产物，更加的方便快捷。但是不同平台和架构所使用的二进制文件不同，你需要选择符合自己机器的。例如，[ripgrep 的发布页面](https://github.com/BurntSushi/ripgrep/releases)展示了 Linux（x86_64、ARM）、macOS（英特尔、苹果硅）和 Windows 的预建二进制文件。

# 发布与版本控制

代码是在开发过程当中逐渐编写的，但以离散方式发布。在软件开发中，开发环境和生产环境之间有明确的区别。
代码必须在开发环境中被证明能运行，才能发布到生产环境。发布过程包含多个步骤，包括测试、依赖管理、版本管理、配置、部署和发布。

软件库是会随着时间不断更新功能和修复错误的，而非静态的。我们可以通过对应库在某一时刻都版本标识符来追踪变化。

库行为的变化有这些：修复非关键功能的补丁、扩展的新功能，甚至有时会产生破坏向后兼容的变更。

软件开发者使用变更日志这样的文档，记录版本引入的变更内容，传达与新版本相关的变更。

但是，考虑到依赖传递（依赖所依赖的依赖关系），追踪每个依赖关系的变化显然是不切实际。

> 你可以用 `uv tree`来可视化整个项目的依赖树，它以树状格式显示所有包及其传递依赖关系。

为了方便管理和标识，产生了一些对于软件版本管理的约定，其中最普遍的是[语义版本管理（Semantic Versioning)](https://semver.org/)，简称 SemVer。
在语义版本管理下，版本号的格式为主版本号.次版本号.修订号（MAJOR.MINOR.PATCH），每一位都是整数。简单来说，升级时的原则是 ：

- PATCH (e.g., 1.2.3 → 1.2.4) 应仅包含错误修复，并且完全向下兼容
- MINOR (e.g., 1.2.3 → 1.3.0) 以向下兼容的方式添加了新功能
- MAJOR (e.g., 1.2.3 → 2.0.0) 表示可能需要代码修改的破坏性变更

> 这是SemVer的简述，我们推荐你阅读完整的 SemVer 规范。比如，理解为什么从 0.1.3 升级到 0.2.0 会导致破坏性变更。或者 1.0.0-rc.1 的含义。

Python 的打包就原生支持语义版本管理，所以我们指定依赖的版本的时候，可以使用各种规格说明符：

在 `pyproject.toml` 中，有多种方式来约束依赖的兼容版本范围：

```toml
[project]
dependencies = [
    "requests==2.32.3",  # Exact version - only this specific version
    "click>=8.0",        # Minimum version - 8.0 or newer
    "numpy>=1.24,<2.0",  # Range - at least 1.24 but less than 2.0
    "pandas~=2.1.0",     # Compatible release - >=2.1.0 and <2.2.0
]
```

版本规范符存在于许多包管理器（npm、cargo 等）中，语义相当的精准。`~=` 运算符是 Python 的“兼容发布”运算符---`~=2.1.0` 表示“任何与 2.1.0 兼容的版本”，即 `>=2.1.0` 和 `<2.2.0`。约等于 npm 和 cargo 中的 caret （`^`） 运算符，遵循 SemVer 的兼容性概念。

但是不是所有的软件都使用语义版本管理的。常见的方式还有日历版本管理（CalVer），版本取决于发布日期而不是语义。例如，Ubuntu 使用诸如 `24.04`（2024 年 4 月）和 `24.10`（2024 年 10 月）这样的版本。使用CalVer可以很容易找到某个时间发布的版本，但是它没有任何有关于兼容性的信息。 最后，语义版本管理也不是一定正确的，有可能维护者在无意之中也会在小版本或补丁发布中引入破坏性的变更。

# 可重复性

现代软件开发中，你写的代码建立在大量抽象层之上。编程语言运行时、第三方库、操作系统，甚至硬件本身。这些层之间的差异可能会改变代码的行为，甚至有可能导致代码不能正常工作。除此之外，底层硬件的不同也会影响你的软件的性能。

“固定库版本”（Pinning）指的是指定一个精确的版本号，而不是给出一个范围。比如，指明 requests==2.32.3，而不是 requests>=2.0。

包管理器会考虑依赖、传递依赖、然后根据提供的所有约束生成一个满足所有约束的有效版本列表。具体的版本列表可以保存到文件当中来保证可重复性;这些文件称为*锁文件* 。

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

处理依赖性版本控制和可重复性时，关键是库与应用/服务之间的区别。

库会被其他人import使用，使用者的项目当中可能还有自己的依赖，如果将版本限制的太死，很容易和使用者已有的依赖产生冲突。而应用和服务是软件的最终消费者，他们通过用户界面或者API来对外暴露功能，而不是通过编程接口供人调用。

 所以，对库来说，最好指定版本范围，以最大化与整个包生态的兼容性；对应用来说，则应该锁定精确版本以确保可复现性——所有运行这个应用的人用的都是完全相同的依赖。

对于要求极致可复现性的项目，Nix 和 Bazel 这类工具提供了"密封构建"——编译器和系统库等所有输入，乃至构建环境本身，都被精确锁定并进行内容寻址。这意味着无论何时何地在哪台机器上跑构建，输出结果都能做到逐字节一致。

> 你甚至可以用 NixOS 管理整个电脑安装，这样你就能轻松地启动新的电脑设置副本，并通过版本控制的配置文件管理它们的完整配置。

软件开发中一个永无止境的矛盾是，新版本的软件总是有不同的bug，而旧版本随着时间的推移会暴露越来越多的安全漏洞。

我们可以通过使用持续集成流水线（我们在[代码质量与 CI](https://github.com/missing-semester-cn/missing-semester-cn.github.io/blob/master/2026/code-quality) 讲座中会详细讲解）来解决这个问题，通过测试应用程序与新版本进行对比，并自动化检测依赖新版本的发布，比如 [Dependabot](https://github.com/dependabot)。

即使有 CI 测试，升级软件版本时还是会出现问题，通常是因为开发环境和生产环境不匹配导致的。在这种情况下，最好的做法是制定回*滚*计划，将版本升级恢复，并重新部署一个之前运行良好的版本。

# 虚拟机和容器	

如果需要更加复杂的依赖，包管理器可能无法管理这么复杂的依赖。

一个常见原因：需要与特定的系统库或硬件驱动程序链接。例如，在科学计算和人工智能领域，程序通常需要专门的库和驱动程序来运行 GPU 硬件。许多系统级依赖（GPU 驱动、特定编译器版本、共享库如 OpenSSL）仍然需要在系统范围当中安装。

传统上，这种更广泛的依赖问题通过虚拟机（VM）得到解决。虚拟机抽象了整个计算机，提供一个完全隔离的环境，并且有自己的专用操作系统。

现在更多使用的方式是容器，在容器当中有应用程序及其依赖、库和文件系统。它共享主机的操作系统内核，而不是虚拟化整个计算机。因为容器共享了内核，所以比起虚拟机启动更快，运行也更加的高效。

[Docker](https://www.docker.com/)是目前最受欢迎的容器平台。Docker 引入了一种标准化的方式来构建、分发和运行容器。在底层，Docker 使用 containerd 作为其容器运行的工业标准，其他工具如 Kubernetes 也在使用。

运行容器很简便。例如，要在容器内运行 Python 解释器，输入命令`docker run`即可 （ -`it` 标志使容器与终端交互。退出时，容器停止）。

```console
$ docker run -it python:3.12 python
Python 3.12.7 (main, Nov  5 2024, 02:53:25) [GCC 12.2.0] on linux
>>> print("Hello from inside a container!")
Hello from inside a container!
```

实践中，你的程序可能依赖于整个文件系统。

为了解决这个问题，我们可以使用容器镜像，将应用的整个文件系统打包成一个构建产物。

 容器镜像是通过编程方式创建的。借助 Docker，我们可以用 Dockerfile 语法精确指定镜像的依赖项、系统库和各项配置：

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

Docker **镜像**是打包的产物（类似模板），而**容器**是该镜像的运行实例。

你可以从同一个镜像运行多个容器。镜像是分层构建的，Docker 文件中的每条指令（`FROM、` `RUN、` `COPY` 等）都会创建一个新的层。Docker 缓存这些步骤，所以如果你更改了 Dockerfile 中的一行，只需要重建该步骤及后续步骤。

之前的 Dockerfile 存在几个问题：它使用完整的 Python 镜像而不是 slim 版本。运行不同的 `RUN` 命令会生成不必要的层，没有固定的版本，且不清理包管理器缓存，也有可能会发送不必要的文件。还有一些常见错误包括不安全地将容器作为根运行，以及不小心将密钥嵌入层中。

我们在这里有个改进的版本：

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

在前面的例子中，可以看到我们不是从源头安装 `uv`，而是从 `ghcr.io/astral-sh/uv:latest` 镜像当中复制预构建的二进制文件。这被称为*构建* 模式。采用这种模式，我们不需要交付编译代码所需的所有工具，只需交付运行应用程序所需的最终二进制文件（此处为 `uv`）。

Docker 有一些重要的限制需要注意：

第一，容器镜像通常是针对平台的---比如为 `Linux/AMD64` 构建的镜像在没有模拟的情况下无法在 `Linux/arm64`（Apple Silicon Macs）上原生运行,而模拟情况下运行的很慢。

第二，Docker 容器需要 Linux 内核，所以在 macOS 和 Windows 上，Docker 实际上在底层运行一个轻量级的 Linux 虚拟机，这也增加了开销。

第三，Docker 的隔离性不如虚拟机---容器共享主机内核，这在多用户环境中是一个安全隐患。

> 如今，越来越多的项目也利用 通过 [nix flakes ](https://serokell.io/blog/practical-nix-flakes)来管理每个项目的“系统范围”库和应用程序。

# 配置

软件本质上是可配置的。在[命令行环境](https://github.com/missing-semester-cn/missing-semester-cn.github.io/blob/master/2026/command-line-environment)讲座中，我们看到程序通过命令行参数、环境变量甚至配置文件（也就是dotfiles）来接收选项。即使在更复杂的应用中，也同样可以这样做，并且已有成熟的大规模配置管理模式。软件配置不应该硬编码在代码当中，而应在运行时候注入。常见的几个例子是环境变量和配置文件。

这里有一个通过环境变量配置的应用程序示例：

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

  关于“配置”有一个重要的基准：同一份代码，应该只需修改配置就能部署到不同的环境（如开发环境、测试环境、生产环境），而不是需要修改代码。

在众多配置选项中，通常包含如 API 密钥等敏感数据。这些数据必须小心处理，避免意外暴露，且不得包含在版本控制中。

# 服务与编排

现代的应用很少独立存在。一个经典的例子：Web 应用可能需要用于持久存储的数据库、性能缓存、后台任务的消息队列以及各种其他支持服务。现代架构通常不会将所有功能整合到单一的单一应用中，而是将功能分解成独立的服务，这些服务可以独立开发、部署和扩展。

举例来说，如果我们发现应用可能需要使用缓存，比起自己从头写一个，不如利用现有的经过实战验证的成熟方案，比如 [Redis](https://redis.io/) 或 [Memcached](https://memcached.org/)。我们可以通过将 Redis 嵌入到应用依赖中，将其作为容器的一部分一起构建。这可能很麻烦，甚至可能根本不行。

更好的做法是将每个应用分别部署在自己的容器里面。这就是通常所说的**微服务架构**——每个组件作为一个独立的服务运行，通过网络（一般是 HTTP API）互相通信。

[Docker Compose](https://docs.docker.com/compose/) 是一款用于定义和运行多容器应用的工具。你不是单独管理容器，而是在一个 YAML 文件中声明所有服务并共同编排。现在我们的完整应用涵盖了多个容器：

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

通过 `docker compose up`，两个服务一起启动，网页应用可以通过主机名`cache`连接到 Redis（Docker 内部 DNS 会自动解析服务名称）。Docker Compose 允许我们声明如何部署一个或多个服务，并负责协调启动服务、建立网络以及管理共享卷以实现数据持久化。

生产部署时，我们一般都希望 Docker 的 compose 服务在启动时能够自己启动，失败时自动重启。常用的方式是使用 systemd 来管理 docker compose 的部署：

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

这个文件能够让你的应用在系统启动时启动（Docker 准备好后），并提供标准控件，如 `systemctl start myapp`、`systemctl stop myapp` 和 `systemctl status myapp`。

随着部署需求越来越复杂，我们可能需要能够跨多台机器的可扩展性、在服务崩溃时的容错性以及高可用性保障。机构们转向像 Kubernetes（k8s）这样先进的容器编排平台，这些平台可以跨多台机器集群管理数千个容器。不过，Kubernetes 学习曲线陡峭且运营开销较大，因此对于较小的项目来说是没必要的。

这种多容器配置之所以可行，部分原因是现代服务通过标准化的 API 和 HTTP REST API 相互通信。例如，每当程序与像 OpenAI 或 Anthropic 这样的大型语言模型提供商交互时，底层它会向其服务器发送 HTTP 请求并解析响应：

```console
$ curl https://api.anthropic.com/v1/messages \
    -H "x-api-key: $ANTHROPIC_API_KEY" \
    -H "content-type: application/json" \
    -H "anthropic-version: 2023-06-01" \
    -d '{"model": "claude-sonnet-4-20250514", "max_tokens": 256,
         "messages": [{"role": "user", "content": "Explain containers vs VMs in one sentence."}]}'
```

# 发版

当你验证完代码能够运行之后，你可能就会想让别人也能下载安装你的软件。发布分发的形式多种多样，本质上和你的编程语言和运行环境有关。

最简单的分发形式就是把构建产物上传到某个地方，让别人下载并本地安装。这种方式至今依然很普遍，比如 [Ubuntu 的软件包归档 ](http://archive.ubuntu.com/ubuntu/pool/main/)，本质上就是一个列出 .deb 文件的 HTTP 目录。

  现在，GitHub 已经成了发布源码和产物的事实标准平台。虽然源码通常都是公开的，但通过 GitHub Releases（发布页），维护者还可以把预编译好的二进制文件或其他产物，挂在对应的版本标签（Tag）下面。


包管理器有时支持直接从 GitHub 安装，无论是源代码还是预构建的轮子：

```console
# Install from source (will clone and build)
$ pip install git+https://github.com/psf/requests.git

# Install from a specific tag/branch
$ pip install git+https://github.com/psf/requests.git@v2.32.3

# Install a wheel directly from a GitHub release
$ pip install https://github.com/user/repo/releases/download/v1.0/package-1.0-py3-none-any.whl
```

事实上，像 Go 这样的语言采用去中心化的分发模式--- Go 模块直接从源代码库中分发，而非中央包仓库。模块路径像 `github.com/gorilla/mux` 会显示代码所在位置，然后`go get`取用。然而，大多数包管理器如 `pip`、`cargo` 或 `brew` 都有预包装项目的中央索引，便于分发和安装。

如果我们运行：

```console
$ uv pip install requests --verbose --no-cache 2>&1 | grep -F '.whl'
DEBUG Selecting: requests==2.32.5 [compatible] (requests-2.32.5-py3-none-any.whl)
DEBUG No cache entry for: https://files.pythonhosted.org/packages/1e/db/4254e3eabe8020b458f1a747140d32277ec7a271daf1d235b70dc0b4e6e3/requests-2.32.5-py3-none-any.whl.metadata
DEBUG No cache entry for: https://files.pythonhosted.org/packages/1e/db/4254e3eabe8020b458f1a747140d32277ec7a271daf1d235b70dc0b4e6e3/requests-2.32.5-py3-none-any.whl
```

我们看到`requests`的获取来源。注意文件名中的 `py3-none-any`，---这意味着轮子可以支持任何 Python 3 版本、任何操作系统、任何架构。对于已编译代码的包，轮子是针对平台的：

```console
$ uv pip install numpy --verbose --no-cache 2>&1 | grep -F '.whl'
DEBUG Selecting: numpy==2.2.1 [compatible] (numpy-2.2.1-cp312-cp312-macosx_14_0_arm64.whl)
```

这里的 `cp312-cp312-macosx_14_0_arm64` 表示这个轮子专门用于 macOS 14+上的 CPython 3.12，适用于 ARM64（苹果硅片）。如果你用的是不同平台，`pip` 会从源码下载不同的轮子或构建。

相反，为了让人们找到我们创建的包，我们需要把包发布到这些注册机构当中。在 Python 中，主要注册表是 [Python 包索引（PyPI）。](https://pypi.org/) 和安装一样，发布软件包的方式有很多种。`uv publish`命令为向 PyPI 上传包提供了现代化的接口：

```console
$ uv publish --publish-url https://test.pypi.org/legacy/
Publishing greeting-0.1.0.tar.gz
Publishing greeting-0.1.0-py3-none-any.whl
```

这里我们用 [TestPyPI](https://test.pypi.org/)---一个独立的包注册表，用于测试你的发布工作流程，同时不破坏真正的 PyPI。上传后，你可以从 TestPyPI 安装：

```console
$ uv pip install --index-url https://test.pypi.org/simple/ greeting
```

发布软件时一个关键考虑因素是是否可信。用户如何验证他们下载的软件包确实来自你，且没有被篡改？包注册库使用校验和验证完整性，一些生态系统支持包签名以提供密码学上的证明。

不同语言有自己的包注册库：Rust 的 [crates.io，JavaScript](https://crates.io/) 的 [npm，Ruby](https://www.npmjs.com/) 的 [RubyGems](https://rubygems.org/)，容器镜像的 [Docker Hub](https://hub.docker.com/)。与此同时，对于私有或内部包，组织通常部署自己的包仓库（如私有的 PyPI 服务器或私有的 Docker 注册表），或使用云服务提供商的托管解决方案。

向互联网部署网络服务需要额外的基础设施：域名注册、还需要DNS 配置以指向你的域名到服务器，通常还有像 nginx 这样的反向代理来处理 HTTPS 和流量路由。对于文档或静态网站等简单例子，[GitHub Pages](https://pages.github.com/) 提供直接从仓库免费托管。

 <!--

  **文档 (Documentation)**
到目前为止，我们一直强调**“构建产物 (Artifact)”**是打包和交付代码的核心输出。但除了产物本身，我们还需要为用户提供文档，说明代码的功能、安装步骤以及使用示例。
像 Python 的 **Sphinx** 和 **MkDocs** 这样的工具，可以根据代码里的注释（Docstrings）和 Markdown 文件自动生成网页文档，通常这些文档会托管在 **Read the Docs** 等服务上。
对于基于 HTTP 的 API（接口），**OpenAPI 规范**（以前叫 **Swagger**）提供了一套描述 API 端点的标准格式。利用这套规范，工具可以自动生成交互式文档（用户可以直接在网页上调接口测试）和客户端代码库。-->


# 练习

1. 先用 printenv 把当前环境变量保存到一个文件里；接着创建一个虚拟环境（venv）并激活它；再次运行 printenv 保存到另一个文件，然后对比 before.txt 和 after.txt。环境变量里到底改变了什么？为什么 Shell 会优先使用虚拟环境里的工具？（提示：观察激活前后 $PATH 变量的变化。）运行 which deactivate，想一想 deactivate 这个 Bash 函数具体做了什么。
1. 创建一个带有 pyproject.toml 的 Python 项目包，并把它安装到虚拟环境里。生成一个锁文件（Lockfile）并查看其中的内容。
1. 安装 Docker，并尝试用它在本地通过 docker compose 把《Missing Semester》这门课的官方网站跑起来。
1. 为一个简单的 Python 应用写一个 Dockerfile；然后再写一个 docker-compose.yml，让你这个应用能跟一个 Redis 缓存服务一起跑起来。
1. 把一个 Python 包发布到 TestPyPI（除非真的值得分享，否则别发到正式的 PyPI 上！）；然后针对该包构建一个 Docker 镜像，并将其推送到 ghcr.io（GitHub 镜像仓库）。
1. 利用 GitHub Pages 搭建一个个人网站。加分项（非强制）： 为它配置一个自定义域名。
