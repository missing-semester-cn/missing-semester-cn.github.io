---
layout: page
title: "Under Construction"
---


Construction
============

Things to add to other sections

# Course Overview

# Virtual Machines

- Add QEMU+LVM with virt-manager as Linux virtualization option

Exercises

- Install OpenSSH server to ssh in your VM

# Dotfiles

To Cover:

- bashrc/zshrc
- SSH config
- Alias, Functions
- stow

Exercises

- Write a .ssh/config entry for Athena
- Run `cat .bash_history | sort | uniq -c | sort -rn | head -n 10` (or the equivalent for zsh) to get 10 most used commands and consider writing sorter aliases for them

# Shell and scripting

To Cover:

- stuff like mv `myfile{.txt, .md}`, ls `*.png`
- File redirect, <(), <{}
- PATH
- zsh, fish,
- QoL stuff: fasd/autojump, fzf, rg, mosh

Exercises

- Implement an interactive Ctrl+R with fzf and zsh keybindings

Reference

- [ExplainShell](https://explainshell.com/)
- [The Linux Command Line](http://linuxcommand.org/tlcl.php)

# Terminal emulators and multiplexers

# Data wrangling

To Cover:

- grep, find, tee, less, tail, head,
- Regular expressions
- terminal escape sequences

Exercises:

- Implement a rudimentary grep using regex & terminal color escape sequences

References:

- [More Shell, Less Egg](http://www.leancrew.com/all-this/2011/12/more-shell-less-egg/)

# Editors

# IDEs

To cover:

- Syntax linting
- Style linting

# Version Control

To cover

- Git Reflog

Exercises

- Explore git-extras like `git ignore`

Reference

- [Git for computer scientists](http://eagain.net/articles/git-for-computer-scientists/)
- [Git as a functional datastructure](https://blog.jayway.com/2013/03/03/git-is-a-purely-functional-data-structure/)
- [gitignore.io](https://www.gitignore.io/)

# Backups

To cover:

- 3,2,1 Rule
- Github is not enough (i.e. your taxes can't go there)
- Difference between backups and mirrors (i.e. why gdrive/dropbox can be dangerous)
- Versioned, Deduplicated, compressed backup options: (borg, tarsnap, rsync.net)
- Backing up webservices (i.e. spotify playlists)

Exercises

- Choose a webservice you use often (Spotify, Google Music, &c) and figure out what options for backing up your data are. Often people have already made solutions based on available APIs

# Debuggers, logging, profilers and monitoring

# Package management

# OS customization

To Cover

- Clipboard Manager (stack/searchable/history)
- Keyboard remapping / shortcuts
- Tiling Window Managers

Exercises

- Look for a searchable clipboard manager for your OS
- Remap Caps Lock to some other key you use more ofter like ESC, Ctrl or Backspace
- Make a custom keyboard shorcut to open a new terminal window or new browser window

References

- reddit.com/r/unixporn

# OS automation

To cover:

- cron/anacron would be quite useful too
- automator, applescript
- GUI automation (pyautogui)

Exercises:

- Implement "when a file is added to the Downloads folder that matches a regex move it to folder X"
- Use pyautogui to draw a square spiral in Paint/GIMP/&c

References

- [Automating the boring stuff Chapter 18](https://automatetheboringstuff.com/chapter18/)

# Web and browsers

To cover:

- The web console: html, css, js, network tab, cookies, &c
- Adblockers: Having one to avoid not only ads but also most malicious websites
- Custom CSS: Stylish
- Notion of web API, IFTTT
- Archive.org

Exercises

- Write Custom CSS to disable StackOverflow sidebar
- Use web api to fetch current public IP (ipinfo.io)
- Look some webpage you have visited over the years on archive.org to see archived versions

# Security and privacy

To cover:

- Encrypting files, disks
- What are SSH Keys
- Password managers
- Two factor authentication, paper keys
- HTTPS
- VPNs

Exercises

- Encrypt a file using PGP
- Use veracrypt to create a simple encrypted volume
- Use ssh-copy-id to access VM without a password
- Get 2FA for most important accoutns i.e. GMail, Dropbox, Github, &c


References

- [PrivacyTools.io](https://privacytools.io)
- [Secure Secure Shell](https://stribika.github.io/2015/01/04/secure-secure-shell.html)