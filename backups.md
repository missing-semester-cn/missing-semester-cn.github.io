---
layout: page
title: "Backups"
presenter: Jose
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

An common pitfall when performing backups is blindly trusting whatever the system says it's doing and not verifying that the data can be properly recovered. Toy Story 2 was almost lost and their backups were not working, [luck](https://www.youtube.com/watch?v=8dhp_20j0Ys) ended up saving them.

## Versioning

You should understand that [RAID](https://en.wikipedia.org/wiki/RAID) is not a backup, and in general **mirroring is not a backup solution**. Simply syncing your files somewhere does not help in many scenarios such as:

- Data corruption
- Malicious software
- Deleting files by mistake

If the changes on your data propagate to the backup then you won't be able to recover in these scenarios. Note that this is the case for a lot of cloud storage solutions like Dropbox, Google Drive, One Drive, &c. Some of them do keep deleted data around for short amounts of time but usually the interface to recover is not something you want to be using to recover large amounts of files.

A proper backup system should be versioned in order to prevent this failure mode. By providing different snapshots in time one can easily navigate them to restore whatever was lost. The most widely known software of this kind is macOS Time Machine.

## Deduplication

However, making several copies of your data might be extremely costly in terms of disk space. Nevertheless, from one version to the next, most data will be identical and needs not be transferred again. This is where [data deduplication](https://en.wikipedia.org/wiki/Data_deduplication) comes into play, by keeping track of what has already been stored one can do **incremental backups** where only the changes from one version to the next need to be stored. This significantly reduces the amount of space needed for backups beyond the first copy.

## Encryption

Since we might be backing up to untrusted third parties like cloud providers it is worth considering that if you backup your data is copied *as is* then it could potentially be looked by unwanted agents. Documents like your taxes are sensitive information that should not be backed up in plain format. To prevent this, many backup solutions offer **client side encryption** where data is encrypted before being sent to the server. That way the server cannot read the data it is storing but you can decrypt it with your secret key.

As a side note, if your disk (or home partition) is not encrypted, then anyone that get ahold of your computer can manage to override the user access controls and read your data. Modern hardware supports fast and efficient read and writes of encrypted data so you might want to consider enabling **full disk encryption**.
