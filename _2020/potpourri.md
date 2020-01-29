---
layout: lecture
title: "Potpourri"
date: 2019-01-29
---

## Backups
## Systemd
## FUSE
## Keyboard remapping




## APIs

We've talked a lot in this class about using your computer more
efficiently to accomplish _local_ tasks, but you will find that many of
these lessons also extend to the wider internet. Most services online
will have "APIs" that let you programmatically access their data. For
example, the US government has an API that lets you get weather
forecasts, which you could use to easily get a weather forecast in your
shell.

Most of these APIs have a similar format. They are structured URLs,
often rooted at `api.service.com`, where the path and query parameters
indicate what data you want to read or what action you want to perform.
For the US weather data for example, to get the forecast for a
particular location, you issue GET request (with `curl` for example) to
https://api.weather.gov/points/42.3604,-71.094. The response itself
contains a bunch of other URLs that let you get specific forecasts for
that region. Usually, the responses are formatted as JSON, which you can
then pipe through a tool like [`jq`](https://stedolan.github.io/jq/) to
massage into what you care about.

Some APIs require authentication, and this usually takes the form of
some sort of secret _token_ that you need to include with the request.
You should read the documentation for the API to see what the particular
service you are looking for uses, but "[OAuth](https://www.oauth.com/)"
is a protocol you will often see used. At its heart, OAuth is a way to
give you tokens that can "act as you" on a given service, and can only
be used for particular purposes. Keep in mind that these tokens are
_secret_, and anyone who gains access to your token can do whatever the
token allows under _your_ account!

[IFTTT](https://ifttt.com/) is a website and service centered around the
idea of APIs — it provides integrations with tons of services, and lets
you chain events from them in nearly arbitrary ways. Give it a look!

## Common command-line flags/patterns

Command-line tools vary a lot, and you will often want to check out
their `man` pages before using them. They often share some common
features though that can be good to be aware of:

 - Most tools support some kind of `--help` flag to display brief usage
   instructions for the tool.
 - Many tools that can cause irrevocable change support the notion of a
   "dry run" in which they only print what they _would have done_, but
   do not actually perform the change. Similarly, they often have an
   "interactive" flag that will prompt you for each destructive action.
 - You can usually use `--version` or `-V` to have the program print its
   own version (handy for reporting bugs!).
 - Almost all tools have a `--verbose` or `-v` flag to produce more
   verbose output. You can usually include the flag multiple times
   (`-vvv`) to get _more_ verbose output, which can be handy for
   debugging. Similarly, many tools have a `--quiet` flag for making it
   only print something on error.
 - In many tools, `-` in place of a file name means "standard input" or
   "standard output", depending on the argument.
 - Possibly destructive tools are generally not recursive by default,
   but support a "recursive" flag (often `-r`) to make them recurse.
 - If you want to run one program "through" another, like `ssh machine
   foo`, it can sometimes be awkward to pass arguments to the
   "inner" program (`foo`), as they will be interpreted as arguments to the
   "outer" program (`ssh`). The argument `--` makes a program _stop_
   processing flags and options (things starting with `-`) in what
   follows: `ssh machine --for-ssh -- foo --for-foo`.

## Window managers

Most of you are used to using a "drag and drop" window manager, like
what comes with Windows, macOS, and Ubuntu by default. There are windows
that just sort of hang there on screen, and you can drag them around,
resize them, and have them overlap one another. But these are only one
_type_ of window manager, often referred to as a "floating" window
manager. There are many others, especially on Linux. A particularly
common alternative is a "tiling" window manager. In a tiling window
manager, windows never overlap, and are instead arranged as tiles on
your screen, sort of like panes in tmux. With a tiling window manager,
the screen is always filled by whatever windows are open, arranged
according to some _layout_. If you have just one window, it takes up the
full screen. If you then open another, the original window shrinks to
make room for it (often something like 2/3 and 1/3). If you open a
third, the other windows will again shrink to accommodate the new
window. Just like with tmux panes, you can navigate around these tiled
windows with your keyboard, and you can resize them and move them
around, all without touching the mouse. They are worth looking into!

## VPNs

VPNs are all the rage these days, but it's not clear that's for [any
good reason](https://gist.github.com/joepie91/5a9909939e6ce7d09e29). You
should be aware of what a VPN does and does not get you. A VPN, in the
best case, is _really_ just a way for you to change your internet
service provider as far as the internet is concerned. All your traffic
will look like it's coming from the VPN provider instead of your "real"
location, and the network you are connected to will only see encrypted
traffic.

While that may seem attractive, keep in mind that when you use a VPN,
all you are really doing is shifting your trust from you current ISP to
the VPN hosting company. Whatever your ISP _could_ see, the VPN provider
now sees _instead_. If you trust them _more_ than your ISP, that is a
win, but otherwise, it is not clear that you have gained much. If you
are sitting on some dodgy unencrypted public Wi-Fi at an airport, then
maybe you don't trust the connection much, but at home, the trade-off is
not quite as clear.

You should also know that these days, much of your traffic, at least of
a sensitive nature, is _already_ encrypted through HTTPS or TLS more
generally. In that case, it usually matters little whether you are on
a "bad" network or not -- the network operator will only learn what
servers you talk to, but not anything about the data that is exchanged.

Notice that I said "in the best case" above. It is not unheard of for
VPN providers to accidentally misconfigure their software such that the
encryption is either weak or entirely disabled. Some VPN providers are
malicious (or at the very least opportunist), and will log all your
traffic, and possibly sell information about it to third parties.
Choosing a bad VPN provider is often worse than not using one in the
first place.

## Markdown

There is a high chance that you will write some text over the course of
your career. And often, you will want to mark up that text in simple
ways. You want some text to be bold or italic, or you want to add
headers, links, and code fragments. Instead of pulling out a heavy tool
like Word or LaTeX, you may want to consider using the lightweight
markup language [Markdown](https://commonmark.org/help/).

You have probably seen Markdown already, or at least some variant of it.
Subsets of it are used and supported almost everywhere, even if it's not
under the name Markdown. At its core, Markdown is an attempt to codify
the way that people already often mark up text when they are writing
plain text documents. Emphasis (*italics*) is added by surrounding a
word with `*`. Strong emphasis (**bold**) is added using `**`. Lines
starting with `#` are headings (and the number of `#`s is the subheading
level). Any line starting with `-` is a bullet list item, and any line
starting with a number + `.` is a numbered list item. Backtick is used
to show words in `code font`, and a code block can be entered by
indenting a line with four spaces or surrounding it with
triple-backticks:

    ```
    code goes here
    ```

To add a link, place the _text_ for the link in square brackets,
and the URL immediately following that in parentheses: `[name](url)`.
Markdown is easy to get started with, and you can use it nearly
everywhere. In fact, the lecture notes for this lecture, and all the
others, are written in Markdown, and you can see the raw Markdown
[here](https://raw.githubusercontent.com/missing-semester/missing-semester/master/_2020/potpourri.md).



## Hammerspoon (desktop automation on macOS)

[Hammerspoon](https://www.hammerspoon.org/) is a desktop automation framework
for macOS. It lets you write Lua scripts that hook into operating system
functionality, allowing you to interact with the keyboard/mouse, windows,
displays, filesystem, and much more.

Some examples of things you can do with Hammerspoon:

- Bind hotkeys to move windows to specific locations
- Create a menu bar button that automatically lays out windows in a specific layout
- Mute your speaker when you arrive in lab (by detecting the WiFi network)
- Show you a warning if you've accidentally taken your friend's power supply

At a high level, Hammerspoon lets you run arbitrary Lua code, bound to menu
buttons, key presses, or events, and Hammerspoon provides an extensive library
for interacting with the system, so there's basically no limit to what you can
do with it. Many people have made their Hammerspoon configurations public, so
you can generally find what you need by searching the internet, but you can
always write your own code from scratch.

### Resources

- [Getting Started with Hammerspoon](https://www.hammerspoon.org/go/)
- [Sample configurations](https://github.com/Hammerspoon/hammerspoon/wiki/Sample-Configurations)
- [Anish's Hammerspoon config](https://github.com/anishathalye/dotfiles-local/tree/mac/hammerspoon)

## Booting + Live USBs

When your machine boots up, before the operating system is loaded, the
[BIOS](https://en.wikipedia.org/wiki/BIOS)/[UEFI](https://en.wikipedia.org/wiki/Unified_Extensible_Firmware_Interface)
initializes the system. During this process, you can press a specific key
combination to configure this layer of software. For example, your computer may
say something like "Press F9 to configure BIOS. Press F12 to enter boot menu."
during the boot process. You can configure all sorts of hardware-related
settings in the BIOS menu. You can also enter the boot menu to boot from an
alternate device instead of your hard drive.

[Live USBs](https://en.wikipedia.org/wiki/Live_USB) are USB flash drives
containing an operating system. You can create one of these by downloading an
operating system (e.g. a Linux distribution) and burning it to the flash drive.
This process is a little bit more complicated than simply copying a `.iso` file
to the disk. There are tools like [UNetbootin](https://unetbootin.github.io/)
to help you create live USBs.

Live USBs are useful for all sorts of purposes. Among other things, if you
break your existing operating system installation so that it no longer boots,
you can use a live USB to recover data or fix the operating system.

## Docker, Vagrant, VMs, Cloud, OpenStack

[Virtual machines](https://en.wikipedia.org/wiki/Virtual_machine) and similar
tools like containers let you emulate a whole computer system, including the
operating system. This can be useful for creating an isolated environment for
testing, development, or exploration (e.g. running potentially malicious code).

[Vagrant](https://www.vagrantup.com/) is a tool that lets you describe machine
configurations (operating system, services, packages, etc.) in code, and then
instantiate VMs with a simple `vagrant up`. [Docker](https://www.docker.com/)
is conceptually similar but it uses containers instead.

You can rent virtual machines on the cloud, and it's a nice way to get instant
access to:

- A cheap always-on machine that has a public IP address, used to host services
- A machine with a lot of CPU, disk, RAM, and/or GPU
- Many more machines than you physically have access to (billing is often by
the second, so if you want a lot of compute for a short amount of time, it's
feasible to rent 1000 computers for a couple minutes)

Popular services include [Amazon AWS](https://aws.amazon.com/), [Google
Cloud](https://cloud.google.com/), and
[DigitalOcean](https://www.digitalocean.com/).

If you're a member of MIT CSAIL, you can get free VMs for research purposes
through the [CSAIL OpenStack
instance](https://tig.csail.mit.edu/shared-computing/open-stack/).

## Notebook programming

[Notebook programming
environments](https://en.wikipedia.org/wiki/Notebook_interface) can be really
handy for doing certain types of interactive or exploratory development.
Perhaps the most popular notebook programming environment today is
[Jupyter](https://jupyter.org/), for Python (and several other languages).
[Wolfram Mathematica](https://www.wolfram.com/mathematica/) is another notebook
programming environment that's great for doing math-oriented programming.

## GitHub

[GitHub](https://github.com/) is one of the most popular platforms for
open-source software development. Many of the tools we've talked about in this
class, from [vim](https://github.com/vim/vim) to
[Hammerspoon](https://github.com/Hammerspoon/hammerspoon), are hosted on
GitHub. It's easy to get started contributing to open-source to help improve
the tools that you use every day.

There are two primary ways in which people contribute to projects on GitHub:

- Creating an
[issue](https://help.github.com/en/github/managing-your-work-on-github/creating-an-issue).
This can be used to report bugs or request a new feature. Neither of these
involves reading or writing code, so it can be pretty lightweight to do.
High-quality bug reports can be extremely valuable to developers. Commenting on
existing discussions can be helpful too.
- Contribute code through a [pull
request](https://help.github.com/en/github/collaborating-with-issues-and-pull-requests/about-pull-requests).
This is generally more involved than creating an issue. You can
[fork](https://help.github.com/en/github/getting-started-with-github/fork-a-repo)
a repository on GitHub, clone your fork, create a new branch, make some changes
(e.g. fix a bug or implement a feature), push the branch, and then [create a
pull
request](https://help.github.com/en/github/collaborating-with-issues-and-pull-requests/creating-a-pull-request).
After this, there will generally be some back-and-forth with the project
maintainers, who will give you feedback on your patch. Finally, if all goes
well, your patch will be merged into the upstream repository. Often times,
larger projects will have a contributing guide, tag beginner-friendly issues,
and some even have mentorship programs to help first-time contributors become
familiar with the project.
