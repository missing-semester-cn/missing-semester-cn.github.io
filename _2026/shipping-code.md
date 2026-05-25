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

让代码想你预想中那样运行很难，但把同样的代码在你自己机器上跑一般情况下可能更困难。
交付代码意味着把你写的代码转换成一种可用的形式，让别人不需要完全复制你的环境就能运行。
交付代码有多种形式，具体取决于编程语言、系统库、操作系统等诸多因素。
这也取决于你在搭建什么：一个软件库，一个命令行工具或一个网络服务都有不同的需求和部署步骤。
无论如何，所有这些场景背后都有一个共同的规律：我们需要定义清楚可交付物是什么（也就是制品），以及它对周围环境做出了哪些假设。

在这篇演讲中，我们将会覆盖：

- [依赖与环境](#dependencies--environments)
- [制品和包装](#artifacts--packaging)
- [发布与版本](#releases--versioning)
- [可复用性](#reproducibility)
- [虚拟机和容器](#vms--containers)
- [设置](#configuration)
- [服务与编排](#services--orchestration)
- [交付](#publishing)

由于真实的例子对于理解很有帮助，我们将会通过Python生态中的一些例子赖解释这些概念。尽管对于有些工具对于其他编程语言环境会不一样，这些概念却极度雷同。

# 依赖与环境s

在现代软件开发中，多层的抽象化是不可或缺的。程序自然会将其逻辑交由其他库或服务来处理。但是，这就在你的代码和代码运行所需的库中引入了一个“依赖”的关系。比如，在Python中，如果你想要抓取一个网站的内容，我们经常会：

```python
import requests

response = requests.get("https://missing.csail.mit.edu")
```

尽管`requests`库并没有在Python的运行时被捆绑加载，所以，如果我们要尝试在没有`requests`安装的情况下运行这串代码，Python会报出这个错：

```console
$ python fetch.py
Traceback (most recent call last):
  File "fetch.py", line 1, in <module>
    import requests
ModuleNotFoundError: No module named 'requests'
```

为了使这个库能够被访问，我们首先需要运行`pip install requests`来安装它。
`pip`是Python编程语言提供用于下载包的一个命令行工具。
运行`pip install requests`会产生以下一系列活动：

1. 在Python Package Index ([PyPI](https://pypi.org/))中查找`requests`库;
1. 搜索适用于当前运行平台的构件;
1. 解析依赖关系——`requests`库本身也依赖其他包，因此安装程序必须找到所有传递性依赖的兼容版本，并事先安装它们;
1. 下载这些构件，然后解压并将文件复制到我们文件系统中的正确位置。

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
这里我们可以看到`requests`拥有自己的依赖，像是`certifi`或`charset-normalizer`，他们需要在`requests`被下载前被提前下载。
一旦下载，Python运行时就可以在导入的时候找到这个库。

```console
$ python -c 'import requests; print(requests.__path__)'
['/usr/local/lib/python3.11/dist-packages/requests']

$ pip list | grep requests
requests        2.32.3
```

Programming languages have different tools, conventions and practices for installing and publishing libraries.
In some languages like Rust, the toolchain is unified --- `cargo` handles building, testing, dependency management, and publishing.
In others like Python, the unification happens at a specification level --- rather than a single tool, there are standardized specifications that define how packaging works, allowing multiple competing tools for each task (`pip` vs [`uv`](https://docs.astral.sh/uv/), `setuptools` vs [`hatch`](https://hatch.pypa.io/) vs [`poetry`](https://python-poetry.org/)).
And in some ecosystems like LaTeX, distributions like TeX Live or MacTeX come bundled with thousands of packages pre-installed.

Introducing dependencies also introduces dependency conflicts.
Conflicts happen when programs require incompatible versions of the same dependency.
For example, if `tensorflow==2.3.0` requires `numpy>=1.16.0,<1.19.0` and `pandas==1.2.0`  requires `numpy>=1.16.5`, then any version satisfying `numpy>=1.16.5,<1.19.0` will be valid.
But if another package in your project requires `numpy>=1.19`, you have a conflict with no valid version that satisfies all constraints.

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

You can think of an environment as an entire standalone version of the language runtime with its own set of installed packages.
This virtual environment or venv isolates the installed dependencies from the global Python installation.
It is a good practice to have a virtual environment for each project, containing the dependencies it requires.

> While many modern operating systems ship with installations of programming language runtimes like Python, it is unwise to modify these installations since the OS might rely on them for its own functionality. Prefer using separate environments instead.

In some languages, the installation protocol is not defined by a tool but as a specification.
In Python [PEP 517](https://peps.python.org/pep-0517/) defines the build system interface and [PEP 621](https://peps.python.org/pep-0621/) specifies how project metadata is stored in `pyproject.toml`.
This has enabled developers to improve upon `pip` and produce more optimized tools like `uv`. To install `uv` it suffices to do `pip install uv`.

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

> We strongly recommend using `uv pip` instead of `pip` whenever possible as it dramatically reduces the installation time.

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

This helps when you need to test your code across multiple Python versions or when a project requires a specific version.

> In some programming languages, each project automatically gets its own environment for its dependencies rather than you creating it manually, but the principle is the same. Most languages these days also have a mechanism for managing multiple versions of the language on a single system, and then specifying which version to use for individual projects.

# Artifacts & Packaging

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

The import fails once we move to a different directory because Python only searches for modules in specific locations (the current directory, installed packages, and paths in `PYTHONPATH`). Packaging solves this by installing the code into a known location.

In Python, packaging a library involves producing an artifact that package installers like `pip` or `uv` can use to install the relevant files.
Python artifacts are called _wheels_ and contain all the necessary information to install a package: the code files, metadata about the package (name, version, dependencies), and instructions for where to place files in the environment.
Building an artifact requires that we write a project file (also often known as manifest) detailing the specifics of the project, the required dependencies, the version of the package, and other information. In Python, we use `pyproject.toml` for this purpose.

> `pyproject.toml` is the modern and recommended way. While earlier packaging methods like `requirements.txt` or `setup.py` are still supported, you should prefer `pyproject.toml` whenever possible.

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

The `typer` library is a popular Python package for creating command-line interfaces with minimal boilerplate.

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

The `.whl` file is the wheel (a zip archive with a specific structure), and the `.tar.gz` is a source distribution for systems that need to build from source.

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

Now if we were to give this wheel to someone else, they could install it by running:

```console
$ uv pip install ./greeting-0.1.0-py3-none-any.whl
$ greet Alice
Hello, Alice!
```

This would install the library we built earlier into their environment, including the `greet` cli tool.

There are limitations to this approach. In particular if our library depends on platform-specific libraries, e.g. CUDA for GPU acceleration, then our artifact only works on systems with those specific libraries installed, and we may need to build separate wheels for different platforms (Linux, macOS, Windows) and architectures (x86, ARM).


When installing software, there's an important distinction between installing from source and installing a prebuilt binary. Installing from source means downloading the original code and compiling it on your machine --- this requires having a compiler and build tools installed, and can take significant time for large projects.

Installing a prebuilt binary means downloading an artifact that was already compiled by someone else --- faster and simpler, but the binary must match your platform and architecture.
For example, [ripgrep's releases page](https://github.com/BurntSushi/ripgrep/releases) shows prebuilt binaries for Linux (x86_64, ARM), macOS (Intel, Apple Silicon), and Windows.


# Releases & Versioning

Code is built in a continuous process but is released on a discrete basis.
In software development there is a clear distinction between development and production environments.
Code needs to be proven to work in a dev environment before getting _shipped_ to prod.
The release process involves many steps, including testing, dependency management, versioning, configuration, deployment and publishing.


Software libraries are not static and evolve over time getting fixes and new features.
We track this evolution by discrete version identifiers that correspond to the state of the library at a certain point in time.
Changes in the behavior of a library can range from patches that fix noncritical functionality, new features that extend its functionality, to changes breaking backwards compatibility.
Changelogs document what changes a version introduces --- these are documents that software developers use to communicate the changes associated with a new release.

However, keeping track of the ongoing changes in each and every dependency is impractical, even more so when we consider the transitive dependencies --- i.e. the dependencies of our dependencies.

> You can visualize the entire dependency tree of your project with `uv tree`, which shows all packages and their transitive dependencies in a tree format.

To simplify this problem there are conventions on how to version software, and one of the most prevalent is [Semantic Versioning](https://semver.org/) or SemVer.
Under Semantic Versioning a version has an identifier of the form MAJOR.MINOR.PATCH where each one of the values takes an integer value. The short version is that upgrading:

- PATCH (e.g., 1.2.3 → 1.2.4) should only contain bug fixes and be fully backwards compatible
- MINOR (e.g., 1.2.3 → 1.3.0) adds new functionality in a backwards-compatible way
- MAJOR (e.g., 1.2.3 → 2.0.0) indicates breaking changes that may require code modifications

> This is a simplification and we encourage reading the full SemVer specification to understand for instance why going from 0.1.3 to 0.2.0 might cause breaking changes or what 1.0.0-rc.1 means.
Python packaging supports semantic versioning natively, so when we specify the versions of our dependencies we can use various specifiers:

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

Version specifiers exist across many package managers (npm, cargo, etc.) with varying exact semantics. The `~=` operator is Python's "compatible release" operator --- `~=2.1.0` means "any version that is compatible with 2.1.0", which translates to `>=2.1.0` and `<2.2.0`. This is roughly equivalent to the caret (`^`) operator in npm and cargo, which follows SemVer's notion of compatibility.

Not all software uses semantic versioning. A common alternative is Calendar Versioning (CalVer), where versions are based on release dates rather than semantic meaning. For example, Ubuntu uses versions like `24.04` (April 2024) and `24.10` (October 2024). CalVer makes it easy to see how old a release is, though it doesn't communicate anything about compatibility.  Lastly, semantic versioning is not infallible, and sometimes maintainers inadvertently introduce breaking changes in minor or patch releases.


# Reproducibility

In modern software development the code you write sits atop a significant number of layers of abstraction.
This includes things like your programming language runtime, third party libraries, the operating system, or even the hardware itself.
Any difference across any of these layers might change the behavior of your code or even prevent it from working as intended.
Furthermore, even differences in the underlying hardware impact your ability to ship software.

Pinning a library refers to specifying an exact version rather than a range, e.g. `requests==2.32.3` instead of `requests>=2.0`.

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

One critical distinction when dealing with dependency versioning and reproducibility is the difference between libraries and applications/services.
A library is intended to be imported and used by other code which might have its own dependencies, so specifying overly strict version constraints can cause conflicts with the user's other dependencies.
In contrast, applications or services are final consumers of the software and typically expose their functionality through a user interface or an API, not through a programming interface.
For libraries, it is good practice to specify version ranges to maximize compatibility with the wider package ecosystem. For applications, pinning exact versions ensures reproducibility --- everyone running the application uses the exact same dependencies.


For projects requiring maximum reproducibility, tools like [Nix](https://nixos.org/) and [Bazel](https://bazel.build/) provide _hermetic_ builds --- where every input including compilers, system libraries, and even the build environment itself is pinned and content-addressed. This guarantees bit-for-bit identical outputs regardless of when or where the build runs.

> You can even use NixOS to manage your entire computer install so that you can trivially spin up new copies of your computer setup and manage their complete configuration through version-controlled configuration files.

A neverending tension in software development is that new software versions introduce breakage either intentionally or unintentionally, while on the other hand, old software versions become compromised with security vulnerabilities over time.
We can address this by using continuous integration pipelines (we'll see more in the [Code Quality and CI](/2026/code-quality/) lecture) that test our application against new software versions and having automation in place for detecting when new versions of our dependencies are released, such as [Dependabot](https://github.com/dependabot).

Even with CI testing in place, issues still occur when upgrading software versions, often because of the inevitable mismatch between dev and prod environments.
In those circumstances the best course of action is to have a _rollback_ plan, where the version upgrade is reverted and a known good version is redeployed instead.

# VMs & Containers

As you start relying on more complex dependencies, it is likely that the dependencies of your code will span beyond the boundaries of what the package manager can handle.
One common reason is having to interface with specific system libraries or hardware drivers.
For example, in scientific computing and AI, programs often need specialized libraries and drivers to utilize GPU hardware.
Many system-level dependencies (GPU drivers, specific compiler versions, shared libraries like OpenSSL) still require system-wide installation.

Traditionally this wider dependency problem was solved with Virtual Machines (VMs).
VMs abstract the entire computer and provide a completely isolated environment with its own dedicated operating system.
A more modern approach is containers, which package an application along with its dependencies, libraries, and filesystem, but share the host's operating system kernel rather than virtualizing an entire computer.
Containers are lighter weight than VMs because they share the kernel, making them faster to start and more efficient to run.

The most popular container platform is [Docker](https://www.docker.com/). Docker introduced a standardized way to build, distribute, and run containers. Under the hood, Docker uses containerd as its container runtime --- an industry standard that other tools like Kubernetes also use.

Running a container is straightforward. For example, to run a Python interpreter inside a container we use `docker run` (The `-it` flags make the container interactive with a terminal. When you exit, the container stops.).

```console
$ docker run -it python:3.12 python
Python 3.12.7 (main, Nov  5 2024, 02:53:25) [GCC 12.2.0] on linux
>>> print("Hello from inside a container!")
Hello from inside a container!
```

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

An important distinction: a Docker **image** is the packaged artifact (like a template), while a **container** is a running instance of that image. You can run multiple containers from the same image. Images are built in layers, where each instruction (`FROM`, `RUN`, `COPY`, etc) in a Dockerfile creates a new layer. Docker caches these layers, so if you change a line in your Dockerfile, only that layer and subsequent layers need to be rebuilt.

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

In the previous example we see that instead of installing `uv` from source, we are copying the prebuilt binary from the `ghcr.io/astral-sh/uv:latest` image. This is known as the _builder_ pattern. With this pattern we do not need to ship all the tools needed to compile our code, just the final binary that is needed to run the application (`uv` in this case).

Docker has important limitations to be aware of. First, container images are often platform-specific --- an image built for `linux/amd64` won't run natively on `linux/arm64` (Apple Silicon Macs) without emulation, which is slow. Second, Docker containers require a Linux kernel, so on macOS and Windows, Docker actually runs a lightweight Linux VM under the hood, adding overhead. Third, Docker's isolation is weaker than VMs --- containers share the host kernel, which is a security concern in multi-tenant environments.

> These days, more projects are also making use of nix to manage even "system-wide" libraries and applications per project through [nix flakes](https://serokell.io/blog/practical-nix-flakes).

# Configuration

Software is inherently configurable. In the [command line environment](/2026/command-line-environment/) lecture we saw programs receiving options via flags, environment variables or even configuration files a.k.a. dotfiles. This holds true even for more complex applications, and there are established patterns for managing configuration at scale.
Software configuration should not be embedded in the code but be provided at runtime.
A couple of common ones being environment variables and config files.

Here's an example of an application that is configured via environment variables:

```python
import os

DATABASE_URL = os.environ.get("DATABASE_URL", "sqlite:///local.db")
DEBUG = os.environ.get("DEBUG", "false").lower() == "true"
API_KEY = os.environ["API_KEY"]  # Required - will raise if not set
```

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

A good right-hand rule for thinking about configuration is that the same codebase should be deployable to different environments (development, staging, production) with only configuration changes, never code changes.

Among the many configuration options there is often sensitive data such as API keys.
Secrets need to be handled with care to avoid exposing them accidentally, and must not be included in version control.


# Services & Orchestration

Modern applications rarely exist in isolation. A typical web application might need a database for persistent storage, a cache for performance, a message queue for background tasks, and various other supporting services. Rather than bundling everything into a single monolithic application, modern architectures often decompose functionality into separate services that can be developed, deployed, and scaled independently.

As an example, if we determine our application might benefit from using a cache, instead of rolling our own we can leverage existing battle tested solutions like [Redis](https://redis.io/) or [Memcached](https://memcached.org/).
We could embed Redis in our application dependencies by building it as part of the container, but that means harmonizing all the dependencies between Redis and our application which could be challenging or even unfeasible.
Instead what we can do is deploy each application separately in its own container.
This is commonly referred to as a microservice architecture where each component runs as an independent service that communicates over the network, typically via HTTP APIs.

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

With `docker compose up`, both services start together, and the web application can connect to Redis using the hostname `cache` (Docker's internal DNS resolves service names automatically).
Docker Compose lets us declare how we want to deploy one or more services, and handles the orchestration of starting them together, setting up networking between them, and managing shared volumes for data persistence.

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

This systemd unit file ensures your application starts when the system boots (after Docker is ready), and provides standard controls like `systemctl start myapp`, `systemctl stop myapp`, and `systemctl status myapp`.

As deployment requirements grow more complex --- needing scalability across multiple machines, fault tolerance when services crash, and high availability guarantees --- organizations turn to sophisticated container orchestration platforms like Kubernetes (k8s), which can manage thousands of containers across clusters of machines. That said, Kubernetes has a steep learning curve and significant operational overhead, so it's often overkill for smaller projects.

This multi-container setup is partly feasible because modern services communicate with each other via standardized APIs, with HTTP REST APIs. For example, whenever a program interacts with an LLM provider like OpenAI or Anthropic, under the hood it is sending an HTTP request to their servers and parsing the response:

```console
$ curl https://api.anthropic.com/v1/messages \
    -H "x-api-key: $ANTHROPIC_API_KEY" \
    -H "content-type: application/json" \
    -H "anthropic-version: 2023-06-01" \
    -d '{"model": "claude-sonnet-4-20250514", "max_tokens": 256,
         "messages": [{"role": "user", "content": "Explain containers vs VMs in one sentence."}]}'
```

# Publishing

Once you have shown your code to work, you might be interested in distributing it for others to download and install.
Distribution takes many forms and is intrinsically tied to the programming language and environments that you operate with.

The simplest form of distribution is uploading artifacts for people to download and install locally.
This is still common and you can find it in places like [Ubuntu's package archive](http://archive.ubuntu.com/ubuntu/pool/main/), which is essentially an HTTP directory listing of `.deb` files.

These days, GitHub has become the de facto platform for publishing source code and artifacts.
While the source code is often publicly available, GitHub Releases allow maintainers to attach prebuilt binaries and other artifacts to tagged versions.


Package managers sometimes support installing directly from GitHub, either from source or from a pre-built wheel:

```console
# Install from source (will clone and build)
$ pip install git+https://github.com/psf/requests.git

# Install from a specific tag/branch
$ pip install git+https://github.com/psf/requests.git@v2.32.3

# Install a wheel directly from a GitHub release
$ pip install https://github.com/user/repo/releases/download/v1.0/package-1.0-py3-none-any.whl
```

In fact, some languages like Go use a decentralized distribution model --- rather than a central package repository, Go modules are distributed directly from their source code repositories.
Module paths like `github.com/gorilla/mux` indicate where the code lives, and `go get` fetches directly from there. However, most package managers like `pip`, `cargo`, or `brew` have central indexes of pre-packaged projects for ease of distribution and installation. If we run

```console
$ uv pip install requests --verbose --no-cache 2>&1 | grep -F '.whl'
DEBUG Selecting: requests==2.32.5 [compatible] (requests-2.32.5-py3-none-any.whl)
DEBUG No cache entry for: https://files.pythonhosted.org/packages/1e/db/4254e3eabe8020b458f1a747140d32277ec7a271daf1d235b70dc0b4e6e3/requests-2.32.5-py3-none-any.whl.metadata
DEBUG No cache entry for: https://files.pythonhosted.org/packages/1e/db/4254e3eabe8020b458f1a747140d32277ec7a271daf1d235b70dc0b4e6e3/requests-2.32.5-py3-none-any.whl
```

we see where we are fetching the `requests` wheel from. Notice the `py3-none-any` in the filename --- this means the wheel works with any Python 3 version, on any OS, on any architecture. For packages with compiled code, the wheel is platform-specific:

```console
$ uv pip install numpy --verbose --no-cache 2>&1 | grep -F '.whl'
DEBUG Selecting: numpy==2.2.1 [compatible] (numpy-2.2.1-cp312-cp312-macosx_14_0_arm64.whl)
```

Here `cp312-cp312-macosx_14_0_arm64` indicates this wheel is specifically for CPython 3.12 on macOS 14+ for ARM64 (Apple Silicon). If you're on a different platform, `pip` will download a different wheel or build from source.

Conversely, for people to be able to find a package we've created, we need to publish it to one of these registries.
In Python, the main registry is the [Python Package Index (PyPI)](https://pypi.org).
Like with installing, there are multiple ways of publishing packages. The `uv publish` command provides a modern interface for uploading packages to PyPI:

```console
$ uv publish --publish-url https://test.pypi.org/legacy/
Publishing greeting-0.1.0.tar.gz
Publishing greeting-0.1.0-py3-none-any.whl
```

Here we are using [TestPyPI](https://test.pypi.org) --- a separate package registry intended for testing your publishing workflow without polluting the real PyPI. Once uploaded, you can install from TestPyPI:

```console
$ uv pip install --index-url https://test.pypi.org/simple/ greeting
```

A key consideration when publishing software is trust. How do users verify that the package they download actually comes from you and hasn't been tampered with? Package registries use checksums to verify integrity, and some ecosystems support package signing to provide cryptographic proof of authorship.

Different languages have their own package registries: [crates.io](https://crates.io) for Rust, [npm](https://www.npmjs.com) for JavaScript, [RubyGems](https://rubygems.org) for Ruby, and [Docker Hub](https://hub.docker.com) for container images. Meanwhile, for private or internal packages, organizations often deploy their own package repositories (such as a private PyPI server or a private Docker registry) or use managed solutions from cloud providers.

Deploying a web service to the internet involves additional infrastructure: domain name registration, DNS configuration to point your domain to your server, and often a reverse proxy like nginx to handle HTTPS and route traffic. For simpler use cases like documentation or static sites, [GitHub Pages](https://pages.github.com/) provides free hosting directly from a repository.

<!--
## Documentation

So far we have emphasized the deliverable _artifact_ as the main output of packaging and shipping code.
In addition to the artifact, we need to document for users the code's functionality, installation instructions, and usage examples.

Tools like [Sphinx](https://www.sphinx-doc.org/) (Python) and [MkDocs](https://www.mkdocs.org/) can automatically generate browsable documentation from docstrings and markdown files, often hosted on services like [Read the Docs](https://readthedocs.org/).
For HTTP-based APIs, the [OpenAPI specification](https://www.openapis.org/) (formerly Swagger) provides a standard format for describing API endpoints, which tools can use to generate interactive documentation and client libraries automatically. -->


# Exercises

1. Save your environment with `printenv` to a file, create a venv, activate it, `printenv` to another file and `diff before.txt after.txt`. What changed in the environment? Why does the shell prefer the venv? (Hint: look at `$PATH` before and after activation.) Run `which deactivate` and reason about what the deactivate bash function is doing.
1. Create a Python package with a `pyproject.toml` and install it in a virtual environment. Create a lockfile and inspect it.
1. Install Docker and use it to build the Missing Semester class website locally using docker compose.
1. Write a Dockerfile for a simple Python application. Then write a `docker-compose.yml` that runs your application alongside a Redis cache.
1. Publish a Python package to TestPyPI (don't publish to the real PyPI unless it's worth sharing!). Then build a Docker image with said package and push it to `ghcr.io`.
1. Make a website using [GitHub Pages](https://docs.github.com/en/pages/quickstart). Extra (non-)credit: configure it with a custom domain.
