---
layout: lecture
title: "安全和密码学"
date: 2019-01-28
ready: false
video:
  aspect: 56.25
  id: tjwobAmnKTo
---

去年的[这节课](/2019/security/)我们从计算机 _用户_ 的角度探讨了增强隐私保护和安全的方法。
今年我们将关注比如散列函数、密钥生成函数、对称/非对称密码体系这些安全和密码学的概念是如何应用于前几节课所学到的工具（Git和SSH）中的。

本课程不能作为计算机系统安全 ([6.858](https://css.csail.mit.edu/6.858/)) 或者
密码学 ([6.857](https://courses.csail.mit.edu/6.857/)以及6.875)的替代。
如果你不是密码学的专家，请不要[试图创造或者修改加密算法](https://www.schneier.com/blog/archives/2015/05/amateurs_produc.html)。从事和计算机系统安全相关的工作同理。

这节课将对一些基本的概念进行简单（但实用）的说明。
虽然这些说明不足以让你学会如何 _设计_ 安全系统或者加密协议，但我们希望你可以对现在使用的程序和协议有一个大概了解。

# 熵

[熵](https://en.wikipedia.org/wiki/Entropy_(information_theory))(Entropy) 是对不确定性的量度。
它的一个应用是决定密码的强度。

![XKCD 936: Password Strength](https://imgs.xkcd.com/comics/password_strength.png)

正如上面的 [XKCD 漫画](https://xkcd.com/936/) 所描述的，
"correcthorsebatterystaple" 这个密码比 "Tr0ub4dor&3" 更安全——可是熵是如何量化安全性的呢？

熵的单位是 _比特_。对于一个均匀分布的随机离散变量，熵等于`log_2(所有可能的个数，即n)`。
扔一次硬币的熵是1比特。掷一次（六面）骰子的熵大约为2.58比特。

一般我们认为攻击者了解密码的模型（最小长度，最大长度，可能包含的字符种类等），但是不了解某个密码是如何随机选择的——
比如[掷骰子](https://en.wikipedia.org/wiki/Diceware)。

使用多少比特的熵取决于应用的威胁模型。 
上面的XKCD漫画告诉我们，大约40比特的熵足以对抗在线穷举攻击（受限于网络速度和应用认证机制）。
而对于离线穷举攻击（主要受限于计算速度）, 一般需要更强的密码 (比如80比特或更多)。

# 散列函数

[密码散列函数](https://en.wikipedia.org/wiki/Cryptographic_hash_function)
(Cryptographic hash function) 可以将任意大小的数据映射为一个固定大小的输出。除此之外，还有一些其他特性。 
一个散列函数的大概规范如下：

```
hash(value: array<byte>) -> vector<byte, N>  (N对于该函数固定)
```

[SHA-1](https://en.wikipedia.org/wiki/SHA-1)是Git中使用的一种散列函数，
它可以将任意大小的输入映射为一个160比特（可被40位十六进制数表示）的输出。
下面我们用`sha1sum`命令来测试SHA1对几个字符串的输出：

```console
$ printf 'hello' | sha1sum
aaf4c61ddcc5e8a2dabede0f3b482cd9aea9434d
$ printf 'hello' | sha1sum
aaf4c61ddcc5e8a2dabede0f3b482cd9aea9434d
$ printf 'Hello' | sha1sum 
f7ff9e8b7bb2e09b70935a5d785e0cc5d9d0abf0
```

抽象地讲，散列函数可以被认为是一个难以取反，且看上去随机（但具确定性）的函数
（这就是[散列函数的理想模型](https://en.wikipedia.org/wiki/Random_oracle)）。
一个散列函数拥有以下特性：

- 确定性：对于不变的输入永远有相同的输出。
- 不可逆性：对于`hash(m) = h`，难以通过已知的输出`h`来计算出原始输入`m`。
- 目标碰撞抵抗性/弱无碰撞：对于一个给定输入`m_1`，难以找到`m_2 != m_1`且`hash(m_1) = hash(m_2)`。
- 碰撞抵抗性/强无碰撞：难以找到一组满足`hash(m_1) = hash(m_2)`的输入`m_1, m_2`（该性质严格强于目标碰撞抵抗性）。

注：虽然SHA-1还可以用于特定用途，它已经[不再被认为](https://shattered.io/)是一个强密码散列函数。
你可参照[密码散列函数的生命周期](https://valerieaurora.org/hash.html)这个表格了解一些散列函数是何时被发现弱点及破解的。 
请注意，针对应用推荐特定的散列函数超出了本课程内容的范畴。
如果选择散列函数对于你的工作非常重要，请先系统学习信息安全及密码学。


## 密码散列函数的应用

- Git中的内容寻址存储(Content addressed storage)：[散列函数](https://en.wikipedia.org/wiki/Hash_function)是一个宽泛的概念（存在非密码学的散列函数），那么Git为什么要特意使用密码散列函数？
- 文件的信息摘要(Message digest)：像Linux ISO这样的软件可以从非官方的（有时不太可信的）镜像站下载，所以需要设法确认下载的软件和官方一致。
官方网站一般会在（指向镜像站的）下载链接旁边备注安装文件的哈希值。
用户从镜像站下载安装文件后可以对照公布的哈希值来确定安装文件没有被篡改。
- [承诺机制](https://en.wikipedia.org/wiki/Commitment_scheme)(Commitment scheme)：
假设我希望承诺一个值，但之后再透露它—— 
比如在没有一个可信的、双方可见的硬币的情况下在我的脑海中公平的“扔一次硬币”。
我可以选择一个值`r = random()`，并和你分享它的哈希值`h = sha256(r)`。
这时你可以开始猜硬币的正反：我们一致同意偶数`r`代表正面，奇数`r`代表反面。
你猜完了以后，我告诉你值`r`的内容，得出胜负。同时你可以使用`sha256(r)`来检查我分享的哈希值`h`以确认我没有作弊。

# 密钥生成函数

[密钥生成函数](https://en.wikipedia.org/wiki/Key_derivation_function) (Key Derivation Functions) 作为密码散列函数的相关概念，被应用于包括生成固定长度，可以使用在其他密码算法中的密钥等方面。
为了对抗穷举法攻击，密钥生成函数通常较慢。

## 密钥生成函数的应用

- 从密码生成可以在其他加密算法中使用的密钥，比如对称加密算法（见下）。
- 存储登录凭证时不可直接存储明文密码。<br>
正确的方法是针对每个用户随机生成一个[盐](https://en.wikipedia.org/wiki/Salt_(cryptography)) `salt = random()`，
并存储盐，以及密钥生成函数对连接了盐的明文密码生成的哈希值`KDF(password + salt)`。<br>
在验证登录请求时，使用输入的密码连接存储的盐重新计算哈希值`KDF(input + salt)`，并与存储的哈希值对比。

# 对称加密

说到加密，可能你会首先想到隐藏明文信息。对称加密使用以下几个方法来实现这个功能：

```
keygen() -> key  (这是一个随机方法)

encrypt(plaintext: array<byte>, key) -> array<byte>  (输出密文)
decrypt(ciphertext: array<byte>, key) -> array<byte>  (输出明文)
```

加密方法`encrypt()`输出的密文`ciphertext`很难在不知道`key`的情况下得出明文`plaintext`。<br>
解密方法`decrypt()`有明显的正确性。因为功能要求给定密文及其密钥，解密方法必须输出明文：`decrypt(encrypt(m, k), k) = m`。

[AES](https://en.wikipedia.org/wiki/Advanced_Encryption_Standard) 是现在常用的一种对称加密系统。

## 对称加密的应用

- 对在不信任的云服务上存储的文件进行加密。<br>对称加密可以和密钥生成函数配合使用，这样可以使用密码加密文件：
将密码输入密钥生成函数生成密钥 `key = KDF(passphrase)`，然后存储`encrypt(file, key)`。

# 非对称加密

The term "asymmetric" refers to there being two keys, with two different roles.
A private key, as its name implies, is meant to be kept private, while the
public key can be publicly shared and it won't affect security (unlike sharing
the key in a symmetric cryptosystem). Asymmetric cryptosystems provide the
following set of functionality, to encrypt/decrypt and to sign/verify:

```
keygen() -> (public key, private key)  (this function is randomized)

encrypt(plaintext: array<byte>, public key) -> array<byte>  (the ciphertext)
decrypt(ciphertext: array<byte>, private key) -> array<byte>  (the plaintext)

sign(message: array<byte>, private key) -> array<byte>  (the signature)
verify(message: array<byte>, signature: array<byte>, public key) -> bool  (whether or not the signature is valid)
```

The encrypt/decrypt functions have properties similar to their analogs from
symmetric cryptosystems. A message can be encrypted using the _public_ key.
Given the output (ciphertext), it's hard to determine the input (plaintext)
without the _private_ key. The decrypt function has the obvious correctness
property, that `decrypt(encrypt(m, public key), private key) = m`.

Symmetric and asymmetric encryption can be compared to physical locks. A
symmetric cryptosystem is like a door lock: anyone with the key can lock and
unlock it. Asymmetric encryption is like a padlock with a key. You could give
the unlocked lock to someone (the public key), they could put a message in a
box and then put the lock on, and after that, only you could open the lock
because you kept the key (the private key).

The sign/verify functions have the same properties that you would hope physical
signatures would have, in that it's hard to forge a signature. No matter the
message, without the _private_ key, it's hard to produce a signature such that
`verify(message, signature, public key)` returns true. And of course, the
verify function has the obvious correctness property that `verify(message,
sign(message, private key), public key) = true`.

## 非对称加密的应用

- [PGP email encryption](https://en.wikipedia.org/wiki/Pretty_Good_Privacy).
People can have their public keys posted online (e.g. in a PGP keyserver, or on
[Keybase](https://keybase.io/)). Anyone can send them encrypted email.
- Private messaging. Apps like [Signal](https://signal.org/) and
[Keybase](https://keybase.io/) use asymmetric keys to establish private
communication channels.
- Signing software. Git can have GPG-signed commits and tags. With a posted
public key, anyone can verify the authenticity of downloaded software.

## 密钥分发

Asymmetric-key cryptography is wonderful, but it has a big challenge of
distributing public keys / mapping public keys to real-world identities. There
are many solutions to this problem. Signal has one simple solution: trust on
first use, and support out-of-band public key exchange (you verify your
friends' "safety numbers" in person). PGP has a different solution, which is
[web of trust](https://en.wikipedia.org/wiki/Web_of_trust). Keybase has yet
another solution of [social
proof](https://keybase.io/blog/chat-apps-softer-than-tofu) (along with other
neat ideas). Each model has its merits; we (the instructors) like Keybase's
model.

# 案例分析

## 密码管理器

This is an essential tool that everyone should try to use (e.g.
[KeePassXC](https://keepassxc.org/)). Password managers let you use unique,
randomly generated high-entropy passwords for all your websites, and they save
all your passwords in one place, encrypted with a symmetric cipher with a key
produced from a passphrase using a KDF.

Using a password manager lets you avoid password reuse (so you're less impacted
when websites get compromised), use high-entropy passwords (so you're less likely to
get compromised), and only need to remember a single high-entropy password.

## 两步验证

[Two-factor authentication](https://en.wikipedia.org/wiki/Multi-factor_authentication)
(2FA) requires you to use a passphrase ("something you know") along with a 2FA
authenticator (like a [YubiKey](https://www.yubico.com/), "something you have")
in order to protect against stolen passwords and
[phishing](https://en.wikipedia.org/wiki/Phishing) attacks.

## 全盘加密

Keeping your laptop's entire disk encrypted is an easy way to protect your data
in the case that your laptop is stolen. You can use [cryptsetup +
LUKS](https://wiki.archlinux.org/index.php/Dm-crypt/Encrypting_a_non-root_file_system)
on Linux,
[BitLocker](https://fossbytes.com/enable-full-disk-encryption-windows-10/) on
Windows, or [FileVault](https://support.apple.com/en-us/HT204837) on macOS.
This encrypts the entire disk with a symmetric cipher, with a key protected by
a passphrase.

## 聊天加密

Use [Signal](https://signal.org/) or [Keybase](https://keybase.io/). End-to-end
security is bootstrapped from asymmetric-key encryption. Obtaining your
contacts' public keys is the critical step here. If you want good security, you
need to authenticate public keys out-of-band (with Signal or Keybase), or trust
social proofs (with Keybase).

## SSH

We've covered the use of SSH and SSH keys in an [earlier
lecture](/2020/command-line/#remote-machines). Let's look at the cryptography
aspects of this.

When you run `ssh-keygen`, it generates an asymmetric keypair, `public_key,
private_key`. This is generated randomly, using entropy provided by the
operating system (collected from hardware events, etc.). The public key is
stored as-is (it's public, so keeping it a secret is not important), but at
rest, the private key should be encrypted on disk. The `ssh-keygen` program
prompts the user for a passphrase, and this is fed through a key derivation
function to produce a key, which is then used to encrypt the private key with a
symmetric cipher.

In use, once the server knows the client's public key (stored in the
`.ssh/authorized_keys` file), a connecting client can prove its identity using
asymmetric signatures. This is done through
[challenge-response](https://en.wikipedia.org/wiki/Challenge%E2%80%93response_authentication).
At a high level, the server picks a random number and sends it to the client.
The client then signs this message and sends the signature back to the server,
which checks the signature against the public key on record. This effectively
proves that the client is in possession of the private key corresponding to the
public key that's in the server's `.ssh/authorized_keys` file, so the server
can allow the client to log in.

{% comment %}
extra topics, if there's time

security concepts, tips
- biometrics
- HTTPS
{% endcomment %}

# 资源

- [去年的讲稿](/2019/security/): 更注重于计算机用户可以如何增强隐私保护和安全
- [Cryptographic Right Answers](https://latacora.micro.blog/2018/04/03/cryptographic-right-answers.html): 
解答了在一些应用环境下“应该使用什么加密？”的问题

# 练习

1. **熵**
    1. 假设一个密码是从五个小写的单词拼接组成，每个单词都是从一个含有10万单词的字典中随机选择，且每个单词选中的概率相同。
       一个符合这样构造的例子是`correcthorsebatterystaple`。这个密码有多少比特的熵？
    1. 假设另一个密码是用八个随机的大小写字母或数字组成。一个符合这样构造的例子是`rg8Ql34g`。这个密码又有多少比特的熵？
    1. 哪一个密码更强？
    1. 假设一个攻击者每秒可以尝试1万个密码，这个攻击者需要多久可以分别破解上述两个密码？
1. **Cryptographic hash functions.** Download a Debian image from a
   [mirror](https://www.debian.org/CD/http-ftp/) (e.g. [this
   file](http://debian.xfree.com.ar/debian-cd/10.2.0/amd64/iso-cd/debian-10.2.0-amd64-netinst.iso)
   from an Argentinean mirror). Cross-check the hash (e.g. using the
   `sha256sum` command) with the hash retrieved from the official Debian site
   (e.g. [this
   file](https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/SHA256SUMS)
   hosted at `debian.org`, if you've downloaded the linked file from the
   Argentinean mirror).
1. **Symmetric cryptography.** Encrypt a file with AES encryption, using
   [OpenSSL](https://www.openssl.org/): `openssl aes-256-cbc -salt -in {input
   filename} -out {output filename}`. Look at the contents using `cat` or
   `hexdump`. Decrypt it with `openssl aes-256-cbc -d -in {input filename} -out
   {output filename}` and confirm that the contents match the original using
   `cmp`.
1. **Asymmetric cryptography.**
    1. Set up [SSH
       keys](https://www.digitalocean.com/community/tutorials/how-to-set-up-ssh-keys--2)
       on a computer you have access to (not Athena, because Kerberos interacts
       weirdly with SSH keys). Rather than using RSA keys as in the linked
       tutorial, use more secure [ED25519
       keys](https://wiki.archlinux.org/index.php/SSH_keys#Ed25519). Make sure
       your private key is encrypted with a passphrase, so it is protected at
       rest.
    1. [Set up GPG](https://www.digitalocean.com/community/tutorials/how-to-use-gpg-to-encrypt-and-sign-messages)
    1. Send Anish an encrypted email ([public key](https://keybase.io/anish)).
    1. Sign a Git commit with `git commit -C` or create a signed Git tag with
       `git tag -s`. Verify the signature on the commit with `git show
       --show-signature` or on the tag with `git tag -v`.
