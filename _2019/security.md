---
layout: lecture
title: "Security and Privacy"
presenter: Jon
video:
  aspect: 56.25
  id: OBx_c-i-M8s
---

The world is a scary place, and everyone's out to get you.

Okay, maybe not, but that doesn't mean you want to flaunt all your
secrets. Security (and privacy) is generally all about raising the bar
for attackers. Find out what your threat model is, and then design your
security mechanisms around that! If the threat model is the NSA or
Mossad, you're _probably_ going to have a bad time.

There are _many_ ways to make your technical persona more secure. We'll
touch on a lot of high-level things here, but this is a process, and
educating yourself is one of the best things you can do. So:

## Follow the Right People

One of the best ways to improve your security know-how is to follow
other people who are vocal about security. Some suggestions:

 - [@TroyHunt](https://twitter.com/TroyHunt)
 - [@SwiftOnSecurity](https://twitter.com/SwiftOnSecurity)
 - [@taviso](https://twitter.com/taviso)
 - [@thegrugq](https://twitter.com/thegrugq)
 - [@tqbf](https://twitter.com/tqbf)
 - [@mattblaze](https://twitter.com/mattblaze)
 - [@moxie](https://twitter.com/moxie)

See also [this
list](https://heimdalsecurity.com/blog/best-twitter-cybersec-accounts/)
for more suggestions.

## General Security Advice

Tech Solidarity has a pretty great list of [do's and don'ts for
journalists](https://web.archive.org/web/20221123204419/https://techsolidarity.org/resources/basic_security.htm)
that has a lot of sane advice, and is decently up-to-date. [@thegrugq](https://medium.com/@thegrugq)
also has a good blog post on [travel security
advice](https://medium.com/@thegrugq/stop-fabricating-travel-security-advice-35259bf0e869)
that's worth reading. We'll repeat much of the advice from those sources
here, plus some more. Also, get a [USB data
blocker](https://www.amazon.com/dp/B00QRRZ2QM/), because [USB is
scary](https://www.bleepingcomputer.com/news/security/heres-a-list-of-29-different-types-of-usb-attacks/).

## Authentication

The very first thing you should do, if you haven't already, is download
a password manager. Some good ones are:

 - [1password](https://1password.com/)
 - [KeePass](https://keepass.info/)
 - [BitWarden](https://bitwarden.com/)
 - [`pass`](https://git.zx2c4.com/password-store/about/)

If you're particularly paranoid, use one that encrypts the passwords
locally on your computer, as opposed to storing them in plain-text at
the server. Use it to generate passwords
for all the web sites you care about right now. Then, switch on
two-factor authentication, ideally with a
[FIDO/U2F](https://fidoalliance.org/) dongle (a
[YubiKey](https://www.yubico.com/quiz/) for example, which has [20% off
for students](https://www.yubico.com/why-yubico/for-education/)). TOTP
(like Google Authenticator or Duo) will also work in a pinch, but
[doesn't protect against
phishing](https://twitter.com/taviso/status/1082015009348104192). SMS is
pretty much useless unless your threat model only includes random
strangers picking up your password in transit.

Also, a note about paper keys. Often, services will give you a "backup
key" that you can use as a second factor if you lose your real second
factor (btw, always keep a backup dongle somewhere safe!). While you
_can_ stick those in your password managers, that means that should
someone get access to your password manager, you're totally hosed (but
maybe you're okay with that thread model). If you are truly paranoid,
print out these paper keys, never store them digitally, and place them
in a safe in the real world.

## Private Communication

Use [Signal](https://www.signal.org/) ([setup
instructions](https://medium.com/@mshelton/signal-for-beginners-c6b44f76a1f0).
[Wire](https://wire.com/en/) is [fine
too](https://www.securemessagingapps.com/); WhatsApp is okay; [don't use
Telegram](https://twitter.com/bascule/status/897187286554628096)).
Desktop messengers are pretty broken (partially due to usually relying
on Electron, which is a huge trust stack).

E-mail is particularly problematic, even if PGP signed. It's not
generally forward-secure, and the key-distribution problem is pretty
severe. [keybase.io](https://keybase.io/) helps, and is useful for a
number of other reasons. Also, PGP keys are generally handled on desktop
computers, which is one of the least secure computing environments.
Relatedly, consider getting a Chromebook, or just work on a tablet with
a keyboard.

## File Security

File security is hard, and operates on many level. What is it you're
trying to secure against?

[![$5 wrench](https://imgs.xkcd.com/comics/security.png)](https://xkcd.com/538/)

 - Offline attacks (someone steals your laptop while it's off): turn on
   full disk encryption. ([cryptsetup +
   LUKS](https://wiki.archlinux.org/index.php/Dm-crypt/Encrypting_a_non-root_file_system)
   on Linux,
   [BitLocker](https://fossbytes.com/enable-full-disk-encryption-windows-10/)
   on Windows, [FileVault](https://support.apple.com/en-us/HT204837) on
   macOS. Note that this won't help if the attacker _also_ has you and
   really wants your secrets.
 - Online attacks (someone has your laptop and it's on): use file
   encryption. There are two primary mechanisms for doing so
    - Encrypted filesystems: stacked filesystem encryption software encrypts files individually rather than having encrypted block devices. You can "mount" these filesystems by providing the decryption key, and then browse the files inside it freely. When you unmount it, those files are all unavailable.  Modern solutions include [gocryptfs](https://github.com/rfjakob/gocryptfs) and [eCryptFS](http://ecryptfs.org/). More detailed comparisons can be found [here](https://nuetzlich.net/gocryptfs/comparison/) and [here](https://wiki.archlinux.org/index.php/disk_encryption#Comparison_table)
    - Encrypted files: encrypt individual files with symmetric
      encryption (see `gpg -c`) and a secret key. Or, like `pass`, also
      encrypt the key with your public key so only you can read it back
      later with your private key. Exact encryption settings matter a
      lot!
 - [Plausible
   deniability](https://en.wikipedia.org/wiki/Plausible_deniability)
   (what seems to be the problem officer?): usually lower performance,
   and easier to lose data. Hard to actually prove that it provides
   [deniable
   encryption](https://en.wikipedia.org/wiki/Deniable_encryption)! See
   the [discussion
   here](https://security.stackexchange.com/questions/135846/is-plausible-deniability-actually-feasible-for-encrypted-volumes-disks),
   and then consider whether you may want to try
   [VeraCrypt](https://www.veracrypt.fr/en/Home.html) (the maintained
   fork of good ol' TrueCrypt).
 - Encrypted backups: use [Tarsnap](https://www.tarsnap.com/) or [Borgbase](https://www.borgbase.com/)
    - Think about whether an attacker can delete your backups if they
      get a hold of your laptop!

## Internet Security & Privacy

The internet is a _very_ scary place. Open WiFi networks
[are](https://www.troyhunt.com/the-beginners-guide-to-breaking-website/)
[scary](https://www.troyhunt.com/talking-with-scott-hanselman-on/). Make
sure you delete them afterwards, otherwise your phone will happily
announce and re-connect to something with the same name later!

If you're ever on a network you don't trust, a VPN _may_ be worthwhile,
but keep in mind that you're trusting the VPN provider _a lot_. Do you
really trust them more than your ISP? If you truly want a VPN, use a
provider you're sure you trust, and you should probably pay for it. Or
set up [WireGuard](https://www.wireguard.com/) for yourself -- it's
[excellent](https://web.archive.org/web/20210526211307/https://latacora.micro.blog/there-will-be/)!

There are also secure configuration settings for a lot of internet-enabled
applications at [cipherlist.eu](https://cipherlist.eu/). If you're particularly
privacy-oriented, [privacytools.io](https://privacytools.io) is also a good
resource.

Some of you may wonder about [Tor](https://www.torproject.org/). Keep in
mind that Tor is _not_ particularly resistant to powerful global
attackers, and is weak against traffic analysis attacks. It may be
useful for hiding traffic on a small scale, but won't really buy you all
that much in terms of privacy. You're better off using more secure
services in the first place (Signal, TLS + certificate pinning, etc.).

## Web Security

So, you want to go on the Web too?
Jeez, you're really pushing your luck here.

Install [HTTPS Everywhere](https://www.eff.org/https-everywhere).
SSL/TLS is
[critical](https://www.troyhunt.com/ssl-is-not-about-encryption/), and
it's _not_ just about encryption, but also about being able to verify
that you're talking to the right service in the first place! If you run
your own web server, [test it](https://www.ssllabs.com/ssltest/index.html). TLS configuration
[can get hairy](https://wiki.mozilla.org/Security/Server_Side_TLS).
HTTPS Everywhere will do its very best to never navigate you to HTTP
sites when there's an alternative. That doesn't save you, but it helps.
If you're truly paranoid, blacklist any SSL/TLS CAs that you don't
absolutely need.

Install [uBlock Origin](https://github.com/gorhill/uBlock). It is a
[wide-spectrum
blocker](https://github.com/gorhill/uBlock/wiki/Blocking-mode) that
doesn't just stop ads, but all sorts of third-party communication a page
may try to do. And inline scripts and such. If you're willing to spend
some time on configuration to make things work, go to [medium
mode](https://github.com/gorhill/uBlock/wiki/Blocking-mode:-medium-mode)
or even [hard
mode](https://github.com/gorhill/uBlock/wiki/Blocking-mode:-hard-mode).
Those _will_ make some sites not work until you've fiddled with the
settings enough, but will also significantly improve your online
security.

If you're using Firefox, enable [Multi-Account
Containers](https://support.mozilla.org/en-US/kb/containers). Create
separate containers for social networks, banking, shopping, etc. Firefox
will keep the cookies and other state for each of the containers totally
separate, so sites you visit in one container can't snoop on sensitive
data from the others. In Google Chrome, you can use [Chrome
Profiles](https://support.google.com/chrome/answer/2364824) to achieve
similar results.

Exercises

TODO

1. Encrypt a file using PGP
1. Use veracrypt to create a simple encrypted volume
1. Enable 2FA for your most data sensitive accounts i.e. GMail, Dropbox, Github, &c
