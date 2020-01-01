---
layout:     post
title:      Checking Out Pull Requests Locally
summary:    Check out GitHub pull requests as local branches using a simple bash function.
tags:       [Blog]
---

Sometimes, when someone sends you a pull request from a fork or branch of a GitHub repository, you may want to merge it 
locally to resolve a merge conflict or to test and verify the changes on your local computer before merging on GitHub. [This document](https://help.github.com/en/github/collaborating-with-issues-and-pull-requests/checking-out-pull-requests-locally) describes the process quite well and I have managed to summarize and condense the 
instructions into a small *bash* function that can be reused for any GitHub repository:

```bash
function fetchpr() {
  pullid=$1
  branch="pr-${pullid}"
  git fetch origin pull/$pullid/head:$branch
  git checkout $branch
}
```  

You can reuse the function by putting it into the likes of your `.profile`.

Let's demonstrate with a simple example. Imagine there exists a rather stale pull 
request `https://github.com/org/repo/pull/4585` pending on your `org/repo` repository. If you want to check out this pull request
locally to resume work on it, you could do the following:

```bash
cd path/to/repository/directory
fetchpr 4585
```         

You will have the pull request as a local branch under `pr-4585`.

[Misagh Moayyed](https://fawnoos.com)
