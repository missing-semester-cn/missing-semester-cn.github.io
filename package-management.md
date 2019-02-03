---
layout: lecture
title: "Package Management and Dependency Management"
presenter: Anish
video:
  aspect: 56.25
  id: tgvt473T8xA
---

Software usually builds on (a collection of) other software, which necessitates
dependency management.

Package/dependency management programs are language-specific, but many share
common ideas.

# Package repositories

Packages are hosted in _package repositories_. There are different repositories
for different languages (and sometimes multiple for a particular language),
such as [PyPI](https://pypi.org/) for Python, [RubyGems](https://rubygems.org/)
for Ruby, and [crates.io](https://crates.io/) for Rust. They generally store
software (source code and sometimes pre-compiled binaries for specific
platforms) for all versions of a package.

# Semantic versioning

Software evolves over time, and we need a way to refer to software versions.
Some simple ways could be to refer to software by a sequence number or a commit
hash, but we can do better in terms of communicating more information: using
version numbers.

There are many approaches; one popular one is [Semantic
Versioning](https://semver.org/):

```
x.y.z
^ ^ ^
| | +- patch
| +--- minor
+----- major
```

Increment **major** version when you make incompatible API changes.

Increment **minor** version when you add functionality in a backward-compatible manner.

Increment **patch** when you make backward-compatible bug fixes.

For example, if you depend on a feature introduced in `v1.2.0` of some
software, then you can install `v1.x.y` for any minor version `x >= 2` and any
patch version `y`. You need to install major version `1` (because `2` can
introduce backward-incompatible changes), and you need to install a minor
version `>= 2` (because you depend on a feature introduced in that minor
version). You can use any newer minor version or patch version because
they should not introduce any backward-incompatible changes.

# Lock files

In addition to specifying versions, it can be nice to enforce that the
_contents_ of the dependency have not changed to prevent tampering. Some tools
use _lock files_ to specify cryptographic hashes of dependencies (along with
versions) that are checked on package install.

# Specifying versions

Tools often let you specify versions in multiple ways, such as:

- exact version, e.g. `2.3.12`
- minimum major version, e.g. `>= 2`
- specific major version and minimum patch version, e.g. `>= 2.3, <3.0`

Specifying an exact version can be advantageous to avoid different behaviors
based on installed dependencies (this shouldn't happen if all dependencies
faithfully follow semver, but sometimes people make mistakes). Specifying a
minimum requirement has the advantage of allowing bug fixes to be installed
(e.g. patch upgrades).

# Dependency resolution

Package managers use various dependency resolution algorithms to satisfy
dependency requirements. This often gets challenging with complex dependencies
(e.g. a package can be indirectly depended on by multiple top-level
dependencies, and different versions could be required). Different package
managers have different levels of sophistication in their dependency
resolution, but it's something to be aware of: you may need to understand this
if you are debugging dependencies.

# Virtual environments

If you're developing multiple software projects, they may depend on different
versions of a particular piece of software. Sometimes, your build tool will
handle this naturally (e.g. by building a static binary).

For other build tools and programming languages, one approach is handling this
with virtual environments (e.g. with the
[virtualenv](https://docs.python-guide.org/dev/virtualenvs/) tool for Python).
Instead of installing dependencies system-wide, you can install dependencies
per-project in a virtual environment, and _activate_ the virtual environment
that you want to use when you're working on a specific project.

# Vendoring

Another very different approach to dependency management is _vendoring_.
Instead of using a dependency manager or build tool to fetch software, you copy
the entire source code for a dependency into your software's repository. This
has the advantage that you're always building against the same version of the
dependency and you don't need to rely on a package repository, but it is more
effort to upgrade dependencies.
