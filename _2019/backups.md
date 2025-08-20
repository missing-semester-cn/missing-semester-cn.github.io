---
layout: lecture
title: "Backups"
presenter: Jose
video:
  aspect: 56.25
  id: lrpqYF8tcYQ
---

There are two types of people:

- Those who do backups
- Those who will do backups

Any data you own that you haven't backed up is data that could be gone at any moment, forever. Here we will cover some good backup basics and the pitfalls of some approaches.

## 3-2-1 Rule

The [3-2-1 rule](https://www.us-cert.gov/sites/default/files/publications/data_backup_options.pdf) is a general recommended strategy for backing up your data. It state that you should have:

- at least **3 copies** of your data
- **2** copies in **different mediums**
- **1** of the copies being **offsite**

The main idea behind this recommendation is not to put all your eggs in one basket. Having 2 different devices/disks ensures that a single hardware failure doesn't take away all your data. Similarly, if you store your only backup at home and the house burns down or gets robbed you lose everything, that's what the offsite copy is there for. Onsite backups give you availability and speed, offsite give you the resiliency should a disaster happen.

## Testing your backups

A common pitfall when performing backups is blindly trusting whatever the system says it's doing and not verifying that the data can be properly recovered. Toy Story 2 was almost lost and their backups were not working, [luck](https://www.youtube.com/watch?v=8dhp_20j0Ys) ended up saving them.

## Versioning

You should understand that [RAID](https://en.wikipedia.org/wiki/RAID) is not a backup, and in general **mirroring is not a backup solution**. Simply syncing your files somewhere will not help in several scenarios, such as:

- Data corruption
- Malicious software
- Deleting files by mistake

If the changes on your data propagate to the backup then you won't be able to recover in these scenarios. Note that this is the case for a lot of cloud storage solutions like Dropbox, Google Drive, One Drive, &c. Some of them do keep deleted data around for short amounts of time but usually the interface to recover is not something you want to be using to recover large amounts of files.

A proper backup system should be versioned in order to prevent this failure mode. By providing different snapshots in time one can easily navigate them to restore whatever was lost. The most widely known software of this kind is macOS Time Machine.

## Deduplication

However, making several copies of your data might be extremely costly in terms of disk space. Nevertheless, from one version to the next, most data will be identical and needs not be transferred again. This is where [data deduplication](https://en.wikipedia.org/wiki/Data_deduplication) comes into play, by keeping track of what has already been stored one can do **incremental backups** where only the changes from one version to the next need to be stored. This significantly reduces the amount of space needed for backups beyond the first copy.

## Encryption

Since we might be backing up to untrusted third parties like cloud providers it is worth considering that if you backup your data is copied *as is* then it could potentially be looked by unwanted agents. Documents like your taxes are sensitive information that should not be backed up in plain format. To prevent this, many backup solutions offer **client side encryption** where data is encrypted before being sent to the server. That way the server cannot read the data it is storing but you can decrypt it with your secret key.

As a side note, if your disk (or home partition) is not encrypted, then anyone that get hold of your computer can manage to override the user access controls and read your data. Modern hardware supports fast and efficient read and writes of encrypted data so you might want to consider enabling **full disk encryption**.


## Append only

The properties reviewed so far focus on hardware failure or user mistakes but fail to address what happens if a malicious agent wanted to delete your data. Namely, say someone hacks into your system, are they able to wipe all your copies of the data you care about? If you worry about that scenario then you need some sort of append only backup solution. In general, this means having a server that will allow you to send new data but will refuse to delete existing data. Usually users have two keys, an append only key that supports  creating new backups and a full access key that also allows for deleting old backups that are no longer needed. The latter one is stored offline.

Note that this is a quite challenging scenario since you need the ability to make changes whilst still preventing a malicious user from deleting your data. Existing commercial solutions include [Tarsnap](https://www.tarsnap.com/) and [Borgbase](https://www.borgbase.com/).


## Additional considerations

Some other things you may want to look into are:

- **Periodic backups**: outdated backups can become pretty useless. Making backups regularly should be a consideration for your system
- **Bootable backups**: some programs allow you to clone your entire disk. That way you have an image that contains an entire copy of your system you can boot directly from.
- **Differential backup strategies**, you may not necessarily care the same about all your data. You can define different backup policies for different types of data.
- **Append only backups** an additional consideration is to enforce append only operations to your backup repositories in order to prevent malicious agents to delete them if they get hold of your machine.


## Webservices

Not all the data that you use lives on your hard disk. If you use **webservices**, then it might be the case that some data you care about, such as Google Docs presentations or Spotify playlists, is stored online. Another easy example that is easy to forget is email accounts with web access, such as Gmail. Figuring out a backup solution in these cases is somewhat trickier. However, there are many services that allow you to download your data, either directly or via an API. Tools such as [gmvault](https://github.com/gaubert/gmvault) for Gmail are available to download the email files to your computer.


## Webpages

Similarly, some high quality content can be found online in the form of webpages. If said content is static one can easily back it up by just saving the website and all of its attachments. Another alternative is the [Wayback Machine](https://archive.org/web/), a massive digital archive of the World Wide Web managed by the [Internet Archive](https://archive.org/), a non profit organization focused on the preservation of all sorts of media. The Wayback Machine allows you to capture and archive webpages being able to later retrieve all the snapshots that have been archived for that website. If you find it useful, consider [donating](https://archive.org/donate/) to the project.


## Resources

Some good backup programs and services we have used and can honestly recommend:

- [Tarsnap](https://www.tarsnap.com/) - deduplicated, encrypted online backup service for the truly paranoid.
- [Borg Backup](https://borgbackup.readthedocs.io) - deduplicated backup program that supports compression and authenticated encryption. If you need a cloud provider [rsync.net](https://www.rsync.net/products/borg.html) has special offerings for Borg users.
- [rsync](https://rsync.samba.org/) is a utility that provides fast incremental file transfer. It is not a full backup solution.
- [rclone](https://rclone.org/) like rsync but for cloud storage providers such as Amazon S3, Dropbox, Google Drive, rsync.net, &c. Supports client side encryption of remote folders.

## Exercises

1. Consider how you are (not) backing up your data and look into fixing/improving that.

1. Figure out how to backup your email accounts

1. Choose a webservice you use often (Spotify, Google Music, etc.) and figure out what options for backing up your data are. Often people have already made tools (such as [youtube-dl](https://ytdl-org.github.io/youtube-dl/)) solutions based on available APIs.

1. Think of a website you have visited repeatedly over the years and look it up in [archive.org](https://archive.org/web/), how many versions does it have?

1. One way to efficiently implement deduplication is to use hardlinks. Whereas symbolic link (also called a soft link or a symlink) is a file that points to another file or folder, a hardlink is a exact copy of the pointer (it uses the same inode and points to the same place in the disk). Thus if the original file is removed a symlink stops working whereas a hard link doesn't. However, hardlinks only work for files. Try using the command `ln` to create hard links and compare them to symlinks created with `ln -s`. (In macOS you will need to install the gnu coreutils or the hln package).
