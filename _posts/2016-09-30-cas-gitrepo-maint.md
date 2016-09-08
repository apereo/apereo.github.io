---
layout:     post
title:      CAS Git Repository Maintenance
summary:    The CAS development team is starting with a bit of git repository housekeeping. Here is how and why.
date:       2016-09-30 12:32:18
categories: cas
---

If you have managed to clone the [CAS Github repository](https://github.com/apereo/cas) recently, you would notice that the repository is obscenely large; 1.2GB large that is. Depending on your connection bandwidth, the initial `git clone` operation could take a very long time specially time that could otherwise be spent wisely to catch Pokémon. Over the years, the CAS development has collected a lot of history in the git commit log. Given the [upcoming CAS 5 release](https://github.com/apereo/cas/milestones), we feel this is an oppurtune time to do a little bit of housekeeping to compress the repository and leave it in a functional efficient state.

Here are the details.

## What does this mean to adopters?

If you are a CAS deployer and have started your CAS deployment using a [WAR overlay method](https://apereo.github.io/cas/development/installation/Maven-Overlay-Installation.html), this will have **absolutely NO IMPACT** on your deployment and future upgrades. None whatsoever. Keep building, patching and upgrading.

If you are a CAS deployer and have started your CAS deployment via building directly from source, you **MIGHT** be in trouble. We certainly recommend all CAS deployments start with the official and suggested deployment strategy, but if you wish to stick to your own ways, read on.

## What does this mean to developers?

Well, we are simply creating history here.

Here is the [issue](https://github.com/apereo/cas/issues/1814) tracking this particular task.

One of the caveats of cleanup process is that the commit log is massaged to rewrite the project history. This means that all project activity remains in place along with commit messages, authors and dates yet SHAs will be replaced and regenerated. This also implies that anyone else with a local clone or fork of the CAS repository will need to either use `git rebase` or create a fresh clone. If you fail to do so and manage to `push` again, old history is going to get pushed along with it and the repository will be reset to the state it was in before! So nuke your existing clones and forks and start again.

Note that the cleanup process affects not just `master` but all CAS repository branches, and there are quite a few. This means that before you start over with a fresh clone, you will need to make sure lingering branches in your local fork of the CAS repository are either:

- Safely backed up and stored somewhere else, so they can be reworked later into the fresh clone.
- Merged into the canonical CAS repository prior to the cleanup effort.

## How do we do this?

We plan to follow [this guide](http://stevelorek.com/how-to-shrink-a-git-repository.html). Initial experiments seem to demonstrate that repository size would shrink down to about 500MB, which is quite an improvement.

Prior to the cleanup process, we plan to store the existing CAS repository in a separate git repository for safekeeping as a backup.

## When do we do this?

The cleanup process takes a while to complete, somewhere between 2-4 hours. Announcements will follow on the [CAS mailing lists](https://apereo.github.io/cas/Mailing-Lists.html) to give developers a headsup on the individual milestones within the cleanup task. Keep an eye out.


[Misagh Moayyed](https://twitter.com/misagh84)
