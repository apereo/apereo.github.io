---
layout:     post
title:      Apereo CAS - Contribution Guidelines
summary:    A quick hands-on guide for one to get started with contibuting to the development and prosperity of the Apereo CAS project. 
tags:       [CAS]
---

Most if not all open-source projects [should] have a [contributor guide](https://apereo.github.io/cas/developer/Contributor-Guidelines.html), whose job is to explain the project policy and pace when it comes to accepting changes from the community. Indeed and among many other things, providing guidelines and documentation that teach one how to build, test and contribute patches of all sorts and colors is a pretty good sign of a healthy project and a vibrant community. 

The overarching theme of this guide starts with the following questions:

1. What is the Apereo CAS project policy on accepting contributions?
2. How may one, seriously and in a step-wise fashion, get started with contributions? 

# What do I work on?
 
Certain number of projects in open-source try to advertise work items and tasks which they think might be [good candidates for contributions](https://github.com/spring-projects/spring-boot/issues?q=is%3Aopen+is%3Aissue+label%3A%22status%3A+ideal-for-contribution%22). This is generally and often *not* the Apereo CAS project policy. The policy is much simpler than that. 

It goes something like this:

> Everything is ideal for contributions.

In other words, 

- There is no *"We vs. You"*. 
- There is no *"Some folks can only fix certain issues and some can't"*. 
- There is no *"Person X made the change; so X must fix it too"* (aka code ownership)

Of course, if you are a newcomer to the project and have just begun to understand the ins and outs of the [CAS project codebase](https://apereo.github.io/2017/06/12/cas-codebase-overview/), there may certainly be areas in which you might find more comfort to slowly get your feet wet. You're welcome to [ask for suggestions](https://apereo.github.io/cas/Mailing-Lists.html). For the most part, the work item you wish to work on should be something you find interesting and enjoyable with some degree of practicality.

Remember that you are deploying open-source software, which means you have automatically become a project/community member and a potential maintainer, whether you realize it or not. Staying in *consume-only* mode generally leads to poor results.

# What can I work on?

All contributions are extremely welcomed with open arms regardless of shape, size and color. You may be interested in helping with fixing typos, writing documentation, authoring test cases, developing code, squashing bugs, etc. All is welcome. 

[More contributions simply equal more confidence](https://apereo.github.io/2017/03/08/the-myth-of-ga-rel/).

In other words, if you happen to come across a bothersome use case and/or something you consider a perfect candidate for improvement and attention, you are most definitely, aggressively and wholeheartedly encouraged to spend time and DNA to improve the quality of your Apereo CAS life. There is no point in silent suffering.

If you find that contributing to the project is at the moment out of your reach, don't worry. There are resources, [here](https://www.coursera.org/) and [here](https://www.apereo.org/content/commercial-affiliates) that can provide training and support to get you started for the win.


# Do I need an issue first?

No. 

If you have already identified an enhancement or a bug, it is STRONGLY recommended that you simply submit a pull request to address the case. There is no need for special ceremony to create separate issues. The pull request **IS** the issue and it will be tracked and tagged as such. 

# How do I report issues then?

You are welcome to submit issues via the [project's issue tracker](https://github.com/apereo/cas/issues). Someone will review the report and will try to evaluate whether this is a geniune RFE or defect in which case the issue will be closed with a follow-up request for contributions and patches. 

The issue tracker is only a simple communication tool to assess a given problematic case or enhancement request. It's not tracking anything, really. You are for the most part and at all costs encouraged to submit patches that fix the reported issue and remove pain, rather than waiting for someone to come along and fix it. As prescribed, there is no *"we vs. you"*.

Very simply put:

> You are the one you have been waiting for.

<div class="alert alert-success">
  <a href="#" class="close" data-dismiss="alert" aria-label="close">&times;</a>
  <strong>Notepad Works</strong><br/>Try not to use the issue tracker as a backlog for items that need fixes from others. Any good task management software on your laptop will do instead. 
</div> 

# How do I know who's working on what?

- Follow the *WIP Pattern* and submit [early pull requests](https://ben.straub.cc/2015/04/02/wip-pull-request/). This is in fact the recommended strategy from Github:

> Pull Requests are a great way to start a conversation of a feature, so start one as soon as possible- even before you are finished with the code. Your team can comment on the feature as it evolves, instead of providing all their feedback at the very end.

Or put another way:

> You’re opening pull requests when you start work, not when you’re finished. 

There is of course the alternative: [ask](https://apereo.github.io/cas/Mailing-Lists.html).

# Can I backport a change to a maintenance branch?

Yes, absolutely. Provided the change fits the scope of the maintenance branch and its tracking release and assuming the branch is still under care, you are more than welcome to move changes across the codebase various branches as much as needed to remove pain and improve.  

# What if the change is too big?

Start by reviewing the [release policy](https://apereo.github.io/cas/developer/Release-Policy.html). The change you have in mind should fit the scope of the release that is planned. If needed, [please discuss](https://apereo.github.io/cas/Mailing-Lists.html) the release schedule and policy with other community members to find alternative solutions and strategies for delivery.

# Is it worth it?

The CAS project generally operates based on its own [maintenance policy](https://apereo.github.io/cas/developer/Maintenance-Policy.html). Before making changes, you want to cross check the CAS deployment you have today and ensure it is still and to what extent considered viable and maintained by the project.

# How do I get on the roadmap?

By simply delivering the change and having it get merged into the codebase relevant branches. There is no predefined roadmap for the project. The roadmap is what you intend to work on. Work items get completed based on community's availability, interest, time and money.

# Practically, how soon is that exactly?

You can review the [release schedule](https://github.com/apereo/cas/milestones) from here. Note that the dates specified for each are somewhat tentative, and may be pushed around depending on need and severity. 

As for general contributions, patches in form of pull requests are generally merged as fast as possible provided they are in *good health*. This means a given pull request must pass a series of automated checks that examine style, tests and such before it becomes eligible for a merge. If your proposed pull request does not yet have the green marking, worry not. Keep pushing to the branch that contains your change to auto-update the pull request and make life green again.

If you find that the project is not moving forward at a pace you find reasonable, simply *ping* the pull request and gently remind someone to step forward and review the issue with you.

# How do I do this?

There is the [contributor guide](https://apereo.github.io/cas/developer/Contributor-Guidelines.html), for sure. However, in this section we are going to practically take a look at the entire process from start to finish and see the patch all the way through. 

In order to successfully finish this exercise you need:

1. [Git](https://git-scm.com/downloads)
2. [IntelliJ IDEA](https://www.jetbrains.com/idea/download/), eclipse or NetBeans (Depending on the change, `vim` may be perfectly fine too)
3. [Java (JDK)](http://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html)

## Fork the repository

First thing you need to do is to [fork the CAS repository](https://help.github.com/articles/fork-a-repo/) under your own account. The CAS repository is hosted on Github and is available [here](https://github.com/apereo/cas).

## Clone repositories

There are much faster ways of cloning the codebase, but let's keep it simple for now:

```bash
git clone git@github.com:apereo/cas.git
cd cas
git remote add mmoayyed git@github.com:mmoayyed/cas.git
git checkout master
```

Next, if you simply list the remotes you should see:

```bash
origin  git@github.com:apereo/cas.git (fetch)
origin  git@github.com:apereo/cas.git (push)
mmoayyed  git@github.com:mmoayyed/cas.git (fetch)
mmoayyed  git@github.com:mmoayyed/cas.git (push)
```

You want to isolate your changes inside individual topics branches and never commit anything to the `master` branch. The workflow more or less is the following:

1. Create topic branch.
2. Make changes and test.
3. Commit changes to branch.
4. Go back to #2 until you are satisified.

<div class="alert alert-success">
  <a href="#" class="close" data-dismiss="alert" aria-label="close">&times;</a>
  <strong>Functional Build</strong><br/>You may want to ensure the codebase can be built locally from source. <a href="https://apereo.github.io/cas/developer/Build-Process.html">Follow this guide</a> to learn more.
</div>

## Create branch

To create a topic branch for the change, execute:

```bash
git status
git checkout -b my-topic-branch-which-fixes-something
```

## Commit changes

When you're ready to commit changes after having made changes, execute:

```bash
git add --all && git commit -am "This change fixes a problem"
```

Note that the `--all` flag adds *all* modified files in the project directory. If you wish to pick and choose, you can either individually add files via a `git add fileName` command one at a time or perhaps, it might be best to simplt opt for a GUI client such as [SourceTree](https://www.sourcetreeapp.com/) or [Git Extensions](https://github.com/gitextensions/gitextensions). 

## Push changes

Push your changes from the *local* branch to a *remote* branch of your own fork:

```bash
git push mmoayyed my-topic-branch-which-fixes-something
```

## Submit pull request

Follow the [guide here](https://help.github.com/articles/about-pull-requests/) to create a pull request based on your branch to the CAS project. In this particular case, the *target* branch is the `master` branch because your own branch was created off of the `master` branch.

# How fast can I consume the change?

`SNAPSHOT` releases are published by the automatic [Travis CI process](https://travis-ci.org/apereo/cas/builds). As soon as a patch is merged, you want to track its build status and once it turns green, you should be good to update snapshots in your build script. Practically, this process can take up to 50 minutes or less.

# So...

I hope this brief overview was of some assistance to you. If you happen to come across other ideas that would make all our CAS lives easier, by all means and without hesitation, [please get involved](https://apereo.github.io/cas/developer/Contributor-Guidelines.html).

[Misagh Moayyed](https://twitter.com/misagh84)
