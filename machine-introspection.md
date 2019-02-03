---
layout: lecture
title: "Machine Introspection"
presenter: Jon
video:
  aspect: 56.25
  id: eNYT2Oq3PF8
---

Sometimes, computers misbehave. And very often, you want to know why.
Let's look at some tools that help you do that!

But first, let's make sure you're able to do introspection. Often,
system introspection requires that you have certain privileges, like
being the member of a group (like `power` for shutdown). The `root` user
is the ultimate privilege; they can do pretty much anything. You can run
a command as `root` (but be careful!) using `sudo`.

## What happened?

If something goes wrong, the first place to start is to look at what
happened around the time when things went wrong. For this, we need to
look at logs.

Traditionally, logs were all stored in `/var/log`, and many still are.
Usually there's a file or folder per program. Use `grep` or `less` to
find your way through them.

There's also a kernel log that you can see using the `dmesg` command.
This used to be available as a plain-text file, but nowadays you often
have to go through `dmesg` to get at it.

Finally, there is the "system log", which is increasingly where all of
your log messages go. On _most_, though not all, Linux systems, that log
is managed by `systemd`, the "system daemon", which controls all the
services that run in the background (and much much more at this point).
That log is accessible through the somewhat inconvenient `journalctl`
tool if you are root, or part of the `admin` or `wheel` groups.

For `journalctl`, you should be aware of these flags in particular:

 - `-u UNIT`: show only messages related to the given systemd service
 - `--full`: don't truncate long lines (the stupidest feature)
 - `-b`: only show messages from the latest boot (see also `-b -2`)
 - `-n100`: only show last 100 entries

## What is happening?

If something _is_ wrong, or you just want to get a feel for what's going
on in your system, you have a number of tools at your disposal for
inspecting the currently running system:

First, there's `top`, and the improved version `htop`, which show you
various statistics for the currently running processes on the system.
CPU use, memory use, process trees, etc. There are lots of shortcuts,
but `t` is particularly useful for enabling the tree view. You can also
see the process tree with `pstree` (+ `-p` to include PIDs). If you want
to know what those programs are doing, you'll often want to tail their
log files. `journalctl -f`, `dmesg -w`, and `tail -f` are you friends
here.

Sometimes, you want to know more about the resources being used overall
on your system. [`dstat`](http://dag.wiee.rs/home-made/dstat/) is
excellent for that. It gives you real-time resource metrics for lots of
different subsystems like I/O, networking, CPU utilization, context
switches, and the like. `man dstat` is the place to start.

If you're running out of disk space, there are two primary utilities
you'll want to know about: `df` and `du`. The former shows you the
status of all the partitions on your system (try it with `-h`), whereas
the latter measures the size of all the folders you give it, including
their contents (see also `-h` and `-s`).

To figure out what network connections you have open, `ss` is the way to
go. `ss -t` will show all open TCP connections. `ss -tl` will show all
listening (i.e., server) ports on your system. `-p` will also include
which process is using that connection, and `-n` will give you the raw
port numbers.


## System configuration

There are _many_ ways to configure your system, but we'll got through
two very common ones: networking and services. Most applications on your
system tell you how to configure them in their manpage, and usually it
will involve editing files in `/etc`; the system configuration
directory.

If you want to configure your network, the `ip` command lets you do
that. Its arguments take on a slightly weird form, but `ip help command`
will get you pretty far. `ip addr` shows you information about your
network interfaces and how they're configured (IP addresses and such),
and `ip route` shows you how network traffic is routed to different
network hosts. Network problems can often be resolved purely through the
`ip` tool. There's also `iw` for managing wireless network interfaces.
`ping` is a handy tool for checking how deeply things are broken. Try
pinging a hostname (google.com), an external IP address (1.1.1.1), and
an internal IP address (192.168.1.1 or default gw). You may also want to
fiddle with `/etc/resolv.conf` to check your DNS settings (how hostnames
are resolved to IP addresses).

To configure services, you pretty much have to interact with `systemd`
these days, for better or for worse. Most services on your system will
have a systemd service file that defines a systemd _unit_. These files
define what command to run when that services is started, how to stop
it, where to log things, etc. They're usually not too bad to read, and
you can find most of them in `/usr/lib/systemd/system/`. You can also
define your own in `/etc/systemd/system` .

Once you have a systemd service in mind, you use the `systemctl` command
to interact with it. `systemctl enable UNIT` will set the service to
start on boot (`disable` removes it again), and `start`, `stop`, and
`restart` will do what you expect. If something goes wrong, systemd will
let you know, and you can use `journalctl -u UNIT` to see the
application's log. You can also use `systemctl status` to see how all
your system services are doing. If your boot feels slow, it's probably
due to a couple of slow services, and you can use `systemd-analyze` (try
it with `blame`) to figure out which ones.

# Exercises

`locate`?
`dmidecode`?
`tcpdump`?
`/boot`?
`iptables`?
`/proc`?
