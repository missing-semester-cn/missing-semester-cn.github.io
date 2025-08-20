---
layout: lecture
title: "Remote Machines"
presenter: Jose
video:
  aspect: 62.5
  id: X5c2Y8BCowM
---

It has become more and more common for programmers to use remote servers in their everyday work. If you need to use remote servers in order to deploy backend software or you need a server with higher computational capabilities, you will end up using a Secure Shell (SSH). As with most tools covered, SSH is highly configurable so it is worth learning about it.


## Executing commands

An often overlooked feature of `ssh` is the ability to run commands directly.

- `ssh foobar@server ls` will execute ls in the home folder of foobar
- It works with pipes, so `ssh foobar@server ls | grep PATTERN` will grep locally the remote output of `ls` and `ls | ssh foobar@server grep PATTERN` will grep remotely the local output of `ls`.

## SSH Keys

Key-based authentication exploits public-key cryptography to prove to the server that the client owns the secret private key without revealing the key. This way you do not need to reenter your password every time. Nevertheless the private key (e.g. `~/.ssh/id_rsa`) is effectively your password so treat it like so.

- Key generation. To generate a pair you can simply run `ssh-keygen -t rsa -b 4096`. If you do not choose a passphrase anyone that gets hold of your private key will be able to access authorized servers so it is recommended to choose  one and use `ssh-agent` to manage shell sessions.

If you have configured pushing to Github using SSH keys you have probably done the steps outlined [here](https://help.github.com/articles/connecting-to-github-with-ssh/) and have a valid pair already. To check if you have a passphrase and validate it you can run `ssh-keygen -y -f /path/to/key`.

- Key based authentication. `ssh` will look into `.ssh/authorized_keys` to determine which clients it should let in. To copy a public key over we can use the

```bash
cat .ssh/id_dsa.pub | ssh foobar@remote 'cat >> ~/.ssh/authorized_keys'
```

A simpler solution can be achieved with `ssh-copy-id` where available.

```bash
ssh-copy-id -i .ssh/id_dsa.pub foobar@remote
```

## Copying files over ssh

There are many ways to copy files over ssh

- `ssh+tee`, the simplest is to use `ssh` command execution and stdin input by doing `cat localfile | ssh remote_server tee serverfile`
- `scp` when copying large amounts of files/directories, the secure copy `scp` command is more convenient since it can easily recurse over paths. The syntax is `scp path/to/local_file remote_host:path/to/remote_file`
- `rsync` improves upon `scp` by detecting identical files in local and remote and preventing copying them again. It also provides more fine grained control over symlinks, permissions and has extra features like the `--partial` flag that can resume from a previously interrupted copy. `rsync` has a similar syntax to `scp`.


## Backgrounding processes

By default when interrupting a ssh connection, child processes of the parent shell are killed along with it. There are a couple of alternatives

- `nohup` - the `nohup` tool effectively allows for a process to live when the terminal gets killed. Although this can sometimes be achieved with `&` and `disown`, nohup is a better default. More details can be found [here](https://unix.stackexchange.com/questions/3886/difference-between-nohup-disown-and).

- `tmux`, `screen` - whereas `nohup` effectively backgrounds the process it is not convenient for interactive shell sessions. In that case using a terminal multiplexer like `screen` or `tmux` is a convenient choice since one can easily detach and reattach the associated shells.

Lastly, if you disown a program and want to reattach it to the current terminal, you can look into [reptyr](https://github.com/nelhage/reptyr). `reptyr PID` will grab the process with id PID and attach it to your current terminal.

## Port Forwarding

In many scenarios you will run into software that works by listening to ports in the machine. When this happens in your local machine you can simply do `localhost:PORT` or `127.0.0.1:PORT`, but what do you do with a remote server that does not have its ports directly available through the network/internet?. This is called port forwarding and it
comes in two flavors: Local Port Forwarding and Remote Port Forwarding (see the pictures for more details, credit of the pictures from [this SO post](https://unix.stackexchange.com/questions/115897/whats-ssh-port-forwarding-and-whats-the-difference-between-ssh-local-and-remot)).


**Local Port Forwarding**
![Local Port Forwarding](https://i.stack.imgur.com/a28N8.png)

**Remote Port Forwarding**
![Remote Port Forwarding](https://i.stack.imgur.com/4iK3b.png)


The most common scenario is local port forwarding where a service in the remote machine listens in a port and you want to link a port in your local machine to forward to the remote port. For example if we execute  `jupyter notebook` in the remote server that listens to the port `8888`. Thus to forward that to the local port `9999` we would do `ssh -L 9999:localhost:8888 foobar@remote_server` and then navigate to `localhost:9999` in our local machine.

## Graphics Forwarding

Sometimes forwarding ports is not enough since we want to run a GUI based program in the server. You can always resort to Remote Desktop Software that sends the entire Desktop Environment (ie. options like RealVNC, Teamviewer, &c). However for a single GUI tool, SSH provides a good alternative: Graphics Forwarding.

Using the `-X` flag tells SSH to forward

 For trusted X11 forwarding the `-Y` flag can be used.

Final note is that for this to work the `sshd_config` on the server must have the following options

```bash
X11Forwarding yes
X11DisplayOffset 10
```

## Roaming

A common pain when connecting to a remote server are disconnections due to shutting down/sleeping your computer or changing a network. Moreover if one has a connection with significant lag using ssh can become quite frustrating. [Mosh](https://mosh.org/), the mobile shell, improves upon ssh, allowing roaming connections, intermittent connectivity and providing intelligent local echo.

Mosh is present in all common distributions and package managers. Mosh requires an ssh server to be working in the server. You do not need to be superuser to install mosh  but it does require that ports 60000 through 60010 to be open in the server (they usually are since they are not in the privileged range).

A downside of `mosh` is that is does not support roaming port/graphics forwarding so if you use those often `mosh` won't be of much help.

## SSH Configuration

#### Client

We have covered many many arguments that we can pass. A tempting alternative is to create shell aliases that look like `alias my_serer="ssh -X -i ~/.id_rsa -L 9999:localhost:8888 foobar@remote_server`, however there is a better alternative, using `~/.ssh/config`.

```bash
Host vm
    User foobar
    HostName 172.16.174.141
    Port 22
    IdentityFile ~/.ssh/id_rsa
    RemoteForward 9999 localhost:8888

# Configs can also take wildcards
Host *.mit.edu
    User foobaz
```


An additional advantage of using the `~/.ssh/config` file over aliases  is that other programs like `scp`, `rsync`, `mosh`, &c are able to read it as well and convert the settings into the corresponding flags.


Note that the `~/.ssh/config` file can be considered a dotfile, and in general it is fine for it to be included with the rest of your dotfiles. However if you make it public, think about the information that you are potentially providing strangers on the internet: the addresses of your servers, the users you are using, the open ports, &c. This may facilitate some types of attacks so be thoughtful about sharing your SSH configuration.

Warning: Never include your RSA keys ( `~/.ssh/id_rsa*` ) in a public repository!

#### Server side

Server side configuration is usually specified in `/etc/ssh/sshd_config`. Here you can make  changes like disabling password authentication, changing ssh ports, enabling X11 forwarding, &c. You can specify config settings in a per user basis.

## Remote Filesystem

Sometimes it is convenient to mount a remote folder. [sshfs](https://github.com/libfuse/sshfs) can mount a folder on a remote server
locally, and then you can use a local editor.

## Exercises

1. For SSH to work the host needs to be running an SSH server. Install an SSH server (such as OpenSSH) in a virtual machine so you can do the rest of the exercises. To figure out what is the ip of the machine run the command `ip addr` and look for the inet field (ignore the `127.0.0.1` entry, that corresponds to the loopback interface).

1. Go to `~/.ssh/` and check if you have a pair of SSH keys there. If not, generate them with `ssh-keygen -t rsa -b 4096`. It is recommended that you use a password and use `ssh-agent` , more info [here](https://www.ssh.com/ssh/agent).

1. Use `ssh-copy-id` to copy the key to your virtual machine. Test that you can ssh without a password. Then, edit your `sshd_config` in the server to disable password authentication by editing the value of `PasswordAuthentication`. Disable root login by editing the value of `PermitRootLogin`.

1. Edit the `sshd_config` in the server to change the ssh port and check that you can still ssh. If you ever have a public facing server, a non default port and key only login will throttle a significant amount of malicious attacks.

1. Install mosh in your server/VM, establish a connection and then disconnect the network adapter of the server/VM. Can mosh properly recover from it?

1. Another use of local port forwarding is to tunnel certain host to the server. If your network filters some website like for example `reddit.com` you can tunnel it through the server as follows:

    - Run `ssh remote_server -L 80:reddit.com:80`
    - Set `reddit.com` and `www.reddit.com` to `127.0.0.1` in `/etc/hosts`
    - Check that you are accessing that website through the server
    - If it is not obvious use a website such as [ipinfo.io](https://ipinfo.io/) which will change depending on your host public ip.


1. Background port forwarding can easily be achieved with a couple of extra flags. Look into what the `-N` and `-f` flags do in `ssh` and figure out what a command such as this `ssh -N -f -L 9999:localhost:8888 foobar@remote_server` does.


## References

- [SSH Hacks](http://matt.might.net/articles/ssh-hacks/)
- [Secure Secure Shell](https://stribika.github.io/2015/01/04/secure-secure-shell.html)

{% comment %}
Lecture notes will be available by the start of lecture.
{% endcomment %}
