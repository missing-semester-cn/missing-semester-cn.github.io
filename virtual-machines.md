---
layout: page
title: "Virtual Machines and Containers"
---

# Virtual Machines

Virtual machines are simulated computers. You can configure a guest virtual
machine with some operating system and configuration and use it without
affecting your host environment.

For this class, you can use VMs to experiment with operating systems, software,
and configurations without risk: you won't affect your primary development
environment.

In general, VMs have lots of uses. They are commonly used for running software
that only runs on a certain operating system (e.g. using a Windows VM on Linux
to run Windows-specific software). They are often used for experimenting with
potentially malicious software.

## Useful features

- **Isolation**: hypervisors do a pretty good job of isolating the guest from
the host, so you can use VMs to run buggy or untrusted software reasonably
safely.

- **Snapshots**: you can take "snapshots" of your virtual machine, capturing
the entire machine state (disk, memory, etc.), make changes to your machine,
and then restore to an earlier state. This is useful for testing out
potentially destructive actions, among other things.

## Disadvantages

Virtual machines are generally slower than running on bare metal, so they may
be unsuitable for certain applications.

## Resources

- Hypervisors
    - [VirtualBox](https://www.virtualbox.org/) (open-source)
    - [VMWare](https://www.vmware.com/) (commercial, available from IS&T [for
    MIT students](https://ist.mit.edu/vmware-fusion))

## Exercises

1. Download and install a hypervisor.

1. Create a new virtual machine and install a Linux distribution (e.g.
[Debian](https://www.debian.org/)).

1. Experiment with snapshots. Try things that you've always wanted to try, like
   running `sudo rm -rf --no-preserve-root /`, and see if you can recover
   easily.

# Containers

Coming soon!
