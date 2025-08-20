---
layout: lecture
title: "Virtual Machines and Containers"
presenter: Anish, Jon
video:
  aspect: 56.25
  id: LJ9ki5zq6Ik
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

## Setup

- **Resources**: shared with host machine; be aware of this when allocating
physical resources.

- **Networking**: many options, default NAT should work fine for most use
cases.

- **Guest addons**: many hypervisors can install software in the guest to
enable nicer integration with host system. You should use this if you can.

## Resources

- Hypervisors
    - [VirtualBox](https://www.virtualbox.org/) (open-source)
    - [Virt-manager](https://virt-manager.org/) (open-source, manages KVM virtual machines and LXC containers)
    - [VMWare](https://www.vmware.com/) (commercial, available from IS&T [for
    MIT students](https://ist.mit.edu/vmware-fusion))

If you are already familiar with popular hypervisors/VMs you may want to learn more about how to do this from a command line friendly way. One option is the [libvirt](https://wiki.libvirt.org/page/UbuntuKVMWalkthrough) toolkit which allows you to manage multiple different virtualization providers/hypervisors.

## Exercises

1. Download and install a hypervisor.

1. Create a new virtual machine and install a Linux distribution (e.g.
[Debian](https://www.debian.org/)).

1. Experiment with snapshots. Try things that you've always wanted to try, like
   running `sudo rm -rf --no-preserve-root /`, and see if you can recover
   easily.

1. Read what a [fork-bomb](https://en.wikipedia.org/wiki/Fork_bomb) (`:(){ :|:& };:`) is and run it on the VM to see that the resource isolation (CPU, Memory, &c) works.

1. Install guest addons and experiment with different windowing modes, file
   sharing, and other features.

# Containers

Virtual Machines are relatively heavy-weight; what if you want to spin
up machines in an automated fashion? Enter containers!

 - Amazon Firecracker
 - Docker
 - rkt
 - lxc

Containers are _mostly_ just an assembly of various Linux security
features, like virtual file system, virtual network interfaces, chroots,
virtual memory tricks, and the like, that together give the appearance
of virtualization.

Not quite as secure or isolated as a VM, but pretty close and getting
better. Usually higher performance, and much faster to start, but not
always.

The performance boost comes from the fact that unlike VMs which run an entire copy of the operating system, containers share the linux kernel with the host. However note that if you are running linux containers on Windows/macOS a Linux VM will need to be active as a middle layer between the two.

![Docker vs VM](/2019/files/containers-vs-vms.png)
_Comparison between Docker containers and Virtual Machines. Credit: blog.docker.com_

Containers are handy for when you want to run an automated task in a
standardized setup:

 - Build systems
 - Development environments
 - Pre-packaged servers
 - Running untrusted programs
   - Grading student submissions
   - (Some) cloud computing
 - Continuous integration
   - Travis CI
   - GitHub Actions

Moreover, container software like Docker has also been extensively used as a solution for [dependency hell](https://en.wikipedia.org/wiki/Dependency_hell). If a machine needs to be running many services with conflicting dependencies they can be isolated using containers.

Usually, you write a file that defines how to construct your container.
You start with some minimal _base image_ (like Alpine Linux), and then
a list of commands to run to set up the environment you want (install
packages, copy files, build stuff, write config files, etc.). Normally,
there's also a way to specify any external ports that should be
available, and an _entrypoint_ that dictates what command should be run
when the container is started (like a grading script).

In a similar fashion to code repository websites (like [GitHub](https://github.com/)) there are some container repository websites (like [DockerHub](https://hub.docker.com/))where many software services have prebuilt images that one can easily deploy.

## Exercises

1. Choose a container software (Docker, LXC, …) and install a simple Linux image. Try SSHing into it.

1. Search and download a prebuilt container image for a popular web server (nginx, apache, …)
