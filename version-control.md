---
layout: page
title: "Version Control"
presenter: Jon
---

Whenever you are working on something that changes over time, it's
useful to be able to _track_ those changes. This can be for a number of
reasons: it gives you a record of what changed, how to undo it, who
changed it, and possibly even why. Version control systems (VCS) give
you that ability. They let you _commit_ changes to a set of files, along
with a message describing the change, as well as look at and undo
changes you've made in the past.

Most VCS support sharing the commit history between multiple users. This
allows for convenient collaboration: you can see the changes I've made,
and I can see the changes you've made. And since the VCS tracks
_changes_, it can often (though not always) figure out how to combine
our changes as long as they touch relatively disjoint things.

There [_a
lot_](https://en.wikipedia.org/wiki/Comparison_of_version-control_software)
of VCSes out there that differ a lot in what they support, how they
function, and how you interact with them. Here, we'll focus on
[git](https://git-scm.com/), one of the more commonly used ones, but I
recommend you also take a look at
[Mercurial](https://www.mercurial-scm.org/).

With that all said -- to the cliffnotes!

## Is git dark magic?

not quite.. you need to understand the data model.
we're going to skip over some of the details, but roughly speaking,
the _core_ "thing" in git is a commit.

 - every commit has a unique name, "revision hash"
   a long hash like `998622294a6c520db718867354bf98348ae3c7e2`
   often shortened to a short (unique-ish) prefix: `9986222`
 - commit has author + commit message
 - also has the hash of any _ancestor commits_
   usually just the hash of the previous commit
 - commit also stores a _diff_, a representation of how you get from the
   commit's ancestors to the commit (e.g., remove this line in this
   file, add these lines to this file, rename that file, etc.)

initially, the _repository_ (roughly: the folder that git manages) has
no content, and no commits. let's set that up:

```console
$ git init hackers
$ cd hackers
$ git status
```

the output here actually gives us a good starting point. let's dig in
and make sure we understand it all.

first, "On branch master".

 - don't want to use hashes all the time.
 - branches are names that point to hashes.
 - master is traditionally the name for the "latest" commit.
   every time a new commit is made, the master name will be made to
   point to the new commit's hash.
 - special name `HEAD` refers to "current" name
 - you can also make your own names with `git branch` (or `git tag`)
   we'll get back to that

let's skip over "No commits yet" because that's all there is to it.

then, "nothing to commit".

 - every commit contains a diff with all the changes you made.
   but how is that diff constructed in the first place?
 - _could_ just always commit _all_ changes you've made since the last
   commit
   - sometimes you want to only commit some of them (e.g., not `TODO`s)
   - sometimes you want to break up a change into multiple commits to
     give a separate commit message for each one
 - git lets you _stage_ changes to construct a commit
   - add changes to a file or files to the staged changes with `git add`
     - add only some changes in a file with `git add -p`
     - without argument `git add` operates on "all known files"
   - remove a file and stage its removal with `git rm`
   - empty the set of staged changes `git reset`
     - note that this does *not* change any of your files!
       it *only* means that no changes will be included in a commit
     - to remove only some staged changes:
       `git reset FILE` or `git reset -p`
   - check staged changes with `git diff --staged`
   - see remaining changes with `git diff`
   - when you're happy with the stage, make a commit with `git commit`
     - if you just want to commit *all* changes: `git commit -a`
     - `git help add` has a bunch more helpful info

while you're playing with the above, try to run `git status` to see what
git thinks you're doing -- it's surprisingly helpful!

## A commit you say...

okay, we have a commit, now what?

 - we can look at recent changes: `git log` (or `git log --oneline`)
 - we can look at the full changes: `git log -p`
 - we can show a particular commit: `git show master`
   - or with `-p` for full diff/patch
 - we can go back to the state at a commit using `git checkout NAME`
   - if `NAME` is a commit hash, git says we're "detached". this just
     means there's no `NAME` that refers to this commit, so if we make
     commits, no-one will know about them.
 - we can revert a change with `git revert NAME`
   - applies the diff in the commit at `NAME` in reverse.
 - we can compare an older version to this one using `git diff NAME..`
   - `a..b` is a commit _range_. if either is left out, it means `HEAD`.
 - we can show all the commits between using `git log NAME..`
   - `-p` works here too
 - we can change `master` to point to a particular commit (effectively
   undoing everything since) with `git reset NAME`:
   - huh, why? wasn't `reset` to change staged changes?
     reset has a "second" form (see `git help reset`) which sets `HEAD`
     to the commit pointed to by the given name.
   - notice that this didn't change any files -- `git diff` now
     effectively shows `git diff NAME..`.

## What's in a name?

clearly, names are important in git. and they're the key to
understanding *a lot* of what goes on in git. so far, we've talked about
commit hashes, master, and `HEAD`. but there's more!

 - you can make your own branches (like master) with `git branch b`
   - creates a new name, `b`, which points to the commit at `HEAD`
   - you're still "on" master though, so if you make a new commit,
     master will point to that new commit, `b` will not.
   - switch to a branch with `git checkout b`
     - any commits you make will now update the `b` name
     - switch back to master with `git checkout master`
       - all your changes in `b` are hidden away
 - tags are other names that never change, and that have their own
   message. often used to mark releases + changelogs.
 - `NAME^` means "the commit before `NAME`
   - can apply recursively: `NAME^^^`
   - you _most likely_ mean `~` when you use `~`
     - `~` is "temporal", whereas `^` goes by ancestors
     - `~~` is the same as `^^`
     - with `~` you can also write `X~3` for "3 commits older than `X`
     - you don't want `^3`
   - `git diff HEAD^`
 - `-` means "the previous name"
 - most commands operate on `HEAD` unless you give another argument

## Clean up your mess.

your commit history will _very_ often end up as:

 - `add feature x` -- maybe even with a commit message about `x`!
 - `forgot to add file`
 - `fix bug`
 - `typo`
 - `typo2`
 - `actually fix`
 - `actually actually fix`
 - `tests pass`
 - `fix example code`
 - `typo`
 - `x`
 - `x`
 - `x`
 - `x`

that's _fine_ as far as git is concerned, but is not very helpful to
your future self, or to other people who are curious about what has
changed. git lets you clean up these things:

 - `git commit --amend`: fold staged changes into previous commit
   - note that this _changes_ the previous commit, giving it a new hash!
 - `git rebase -i HEAD~13` is _magical_.
   for each commit from past 13, choose what to do:
   - default is `pick`; do nothing
   - `r`: change commit message
   - `e`: change commit (add or remove files)
   - `s`: combine commit with previous and edit commit message
   - `f`: "fixup" -- combine commit with previous; discard commit msg
   - at the end, `HEAD` is made to point to what is now the last commit

## Playing with others.

a common use-case for version control is to allow multiple people to
make changes to a set of files without stepping on each other's toes.
or rather, to make sure that _if_ they step on each other's toes, they
won't just silently overwrite each other's changes.

git is a _distributed_ VCS: everyone has a local copy of the entire
repository (well, of everything others have chosen to publish). some
VCSes are _centralized_ (e.g., subversion): a server has all the
commits, clients only have the files they have "checked out". basically,
they only have the _current_ files, and need to ask the server if they
want anything else.

every copy of a git repository can be listed as a "remote". you can copy
an existing git repository using `git clone ADDRESS` (instead of `git
init`). this creates a remote called _origin_ that points to `ADDRESS`.
you can fetch names and the commits they point to from a remote with
`git fetch REMOTE`. all names at a remote are available to you as
`REMOTE/NAME`, and you can use them just like local names.

if you have write access to a remote, you can change names at the remote
to point to commits you've made using `git push`. for example, let's
make the master name (branch) at the remote `origin` point to the commit
that our master branch currently points to:

   - `git push origin master:master`
   - for convenience, you can set `origin/master` as the default target
     for when you `git push` from the current branch with `-u`
   - consider: what does this do? `git push origin master:HEAD^`

often you'll use GitHub, GitLab, BitBucket, or something else as your
remote. there's nothing "special" about that as far as git is concerned.
it's all just names and commits. if someone makes a change to master and
updates `github/master` to point to their commit (we'll get back to
that in a second), then when you `git fetch github`, you'll be able to
see their changes with `git log github/master`.

## Working with others.

so far, branches seem pretty useless: you can create them, do work on
them, but then what? eventually, you'll just make master point to them
anyway, right?

 - what if you had to fix something while working on a big feature?
 - what if someone else made a change to master in the meantime?

inevitably, you will have to _merge_ changes in one branch with changes
in another, whether those changes are made by you or someone else. git
lets you do this with, unsurprisingly, `git merge NAME`. `merge` will:

 - look for the latest point where `HEAD` and `NAME` shared a commit
   ancestor (i.e., where they diverged)
 - (try to) apply all those changes to the current `HEAD`
 - produce a commit that contains all those changes, and lists both
   `HEAD` and `NAME` as its ancestors
 - set `HEAD` to that commit's hash

once your big feature has been finished, you can merge its branch into
master, and git will ensure that you don't lose any changes from either
branch!

if you've used git in the past, you may recognize `merge` by a different
name: `pull`. when you do `git pull REMOTE BRANCH`, that is:

 - `git fetch REMOTE`
 - `git merge REMOTE/BRANCH`
 - where, like `push`, `REMOTE` and `BRANCH` are often omitted and use
   the "tracking" remote branch (remember `-u`?)

this usually works _great_. as long as the changes to the branches being
merged are disjoint. if they are not, you get a _merge conflict_. sounds
scary...

 - a merge conflict is just git telling you that it doesn't know what
   the final diff should look like
 - git pauses and asks you to finish staging the "merge commit"
 - open the conflicted file in your editor and look for lots of angle
   brackets (`<<<<<<<`). the stuff above `=======` is the change made in
   the `HEAD` since the shared ancestor commit. the stuff below is the
   change made in the `NAME` since the shared commit.
 - `git mergetool` is pretty handy -- opens a diff editor
 - once you've _resolved_ the conflict by figuring out what the file
   should now look like, stage those changes with `git add`.
 - when all the conflicts are resolved, finish with `git commit`

you've just resolved your first git merge conflict! \o/
now you can publish your finished changes with `git push`

## fast-forward, forced pushes

## rebase vs merge

## git stash
