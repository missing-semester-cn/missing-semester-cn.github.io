---
layout: lecture
title: "Dotfiles"
presenter: Anish
video:
  aspect: 62.5
  id: YSZBWWJw3mI
---

Many programs are configured using plain-text files known as "dotfiles"
(because the file names begin with a `.`, e.g. `~/.gitconfig`, so that they are
hidden in the directory listing `ls` by default).

A lot of the tools you use probably have a lot of settings that can be tuned
pretty finely. Often times, tools are customized with specialized languages,
e.g. Vimscript for Vim or the shell's own language for a shell.

Customizing and adapting your tools to your preferred workflow will make you
more productive. We advise you to invest time in customizing your tool yourself
rather than cloning someone else's dotfiles from GitHub.

You probably have some dotfiles set up already. Some places to look:

- `~/.bashrc`
- `~/.emacs`
- `~/.vim`
- `~/.gitconfig`

Some programs don't put the files under your home folder directly and instead they put them in a folder under `~/.config`.

Dotfiles are not exclusive to command line applications, for instance the [MPV](https://mpv.io/) video player can be configured editing files under `~/.config/mpv`

# Learning to customize tools

You can learn about your tool's settings by reading online documentation or
[man pages](https://en.wikipedia.org/wiki/Man_page). Another great way is to
search the internet for blog posts about specific programs, where authors will
tell you about their preferred customizations. Yet another way to learn about
customizations is to look through other people's dotfiles: you can find tons of
[dotfiles
repositories](https://github.com/search?o=desc&q=dotfiles&s=stars&type=Repositories)
on GitHub --- see the most popular one
[here](https://github.com/mathiasbynens/dotfiles) (we advise you not to blindly
copy configurations though).

# Organization

How should you organize your dotfiles? They should be in their own folder,
under version control, and **symlinked** into place using a script. This has
the benefits of:

- **Easy installation**: if you log in to a new machine, applying your
customizations will only take a minute
- **Portability**: your tools will work the same way everywhere
- **Synchronization**: you can update your dotfiles anywhere and keep them all
in sync
- **Change tracking**: you're probably going to be maintaining your dotfiles
for your entire programming career, and version history is nice to have for
long-lived projects

```shell
cd ~/src
mkdir dotfiles
cd dotfiles
git init
touch bashrc
# create a bashrc with some settings, e.g.:
#     PS1='\w > '
touch install
chmod +x install
# insert the following into the install script:
#     #!/usr/bin/env bash
#     BASEDIR=$(dirname $0)
#     cd $BASEDIR
#
#     ln -s ${PWD}/bashrc ~/.bashrc
git add bashrc install
git commit -m 'Initial commit'
```

# Advanced topics

## Machine-specific customizations

Most of the time, you'll want the same configuration across machines, but
sometimes, you'll want a small delta on a particular machine. Here are a couple
ways you can handle this situation:

### Branch per machine

Use version control to maintain a branch per machine. This approach is
logically straightforward but can be pretty heavyweight.

### If statements

If the configuration file supports it, use the equivalent of if-statements to
apply machine specific customizations. For example, your shell could have something
like:

```shell
if [[ "$(uname)" == "Linux" ]]; then {do_something else}; fi

# Darwin is the architecture name for macOS systems
if [[ "$(uname)" == "Darwin" ]]; then {do_something}; fi

# You can also make it machine specific
if [[ "$(hostname)" == "myServer" ]]; then {do_something}; fi
```

### Includes

If the configuration file supports it, make use of includes. For example,
a `~/.gitconfig` can have a setting:

```
[include]
    path = ~/.gitconfig_local
```

And then on each machine, `~/.gitconfig_local` can contain machine-specific
settings. You could even track these in a separate repository for
machine-specific settings.

This idea is also useful if you want different programs to share some configurations. For instance if you want both `bash` and `zsh` to share the same set of aliases you can write them under `.aliases` and have the following block in both.

```bash
# Test if ~/.aliases exists and source it
if [ -f ~/.aliases ]; then
    source ~/.aliases
fi
```

# Resources

- Your instructors' dotfiles:
  [Anish](https://github.com/anishathalye/dotfiles),
  [Jon](https://github.com/jonhoo/configs),
  [Jose](https://github.com/jjgo/dotfiles)
- [GitHub does dotfiles](http://dotfiles.github.io/): dotfile frameworks,
utilities, examples, and tutorials
- [Shell startup
  scripts](https://blog.flowblok.id.au/2013-02/shell-startup-scripts.html): an
  explanation of the different configuration files used for your shell

# Exercises

1. Create a folder for your dotfiles and set up [version
   control](/2019/version-control/).

1. Add a configuration for at least one program, e.g. your shell, with some
   customization (to start off, it can be something as simple as customizing
   your shell prompt by setting `$PS1`).

1. Set up a method to install your dotfiles quickly (and without manual effort)
   on a new machine. This can be as simple as a shell script that calls `ln -s`
   for each file, or you could use a [specialized
   utility](http://dotfiles.github.io/utilities/).

1. Test your installation script on a fresh virtual machine.

1. Migrate all of your current tool configurations to your dotfiles repository.

1. Publish your dotfiles on GitHub.
