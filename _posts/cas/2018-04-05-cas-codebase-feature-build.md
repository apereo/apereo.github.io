---
layout:     post
title:      Apereo CAS - Test-Driving Feature Modules
summary:    An overview of how various CAS features modules today can be changed and tested from the perspective of a CAS contributor working on the codebase itself to handle a feature request, bug fix, etc.
tags:       [CAS]
---

<div class="alert alert-success">
<strong>Collaborate</strong><br/>This blog is managed and hosted on GitHub. If you wish to update the contents of this post or if you have found an inaccuracy and wish to make corrections, we recommend that you please submit a pull request to <a href="https://github.com/apereo/apereo.github.io">this repository</a>.
</div>

# Overview

Following up on my previous blog post on [changing CAS source code in an overlay](https://apereo.github.io/2018/04/01/cas-overlays-supercharged/), in this exercise we are going to more or less repeat the same experience except that this time, we will be addressing the changes and workload from the perspective of the CAS codebase. This quick walkthrough effectively aims for the following objectives:

- A quick development environment setup using IntelliJ IDEA.
- Building and running the CAS web application using Gradle.
- Changing feature modules and testing out behavior.
- Stepping into the code using a debugger.

# Development Environment

Follow the [instructions posted here](https://apereo.github.io/cas/developer/Build-Process-5X.html) to obtain the CAS source code. Remember to indicate the relevant `branch` in the commands indicated to obtain the right source code for the CAS version at hand. In this tutorial and just like before, the branch to use would be `5.2.x`.

To understand what branches are available, [see this link](https://github.com/apereo/cas/branches). Your CAS version is closely tied to the branches listed in the codebase. For example, if you are deploying CAS `5.1.8`, then the relevant branch to check out would be `5.1.x`. Remember that branches always contain the most recent changeset and version of the release line. You might be deploying `5.1.8` while the `5.1.x` might be marching towards `5.1.10`. This requires that you first upgrade to the latest available patch release for the CAS version at hand and if the problem or use case continues to manifest, you can then check out the appropriate source branch and get fancy <sub>[1]</sub>.

<div class="alert alert-info">
<strong>Keep Up</strong><br/>It is <b>STRONGLY</b> recommended that you keep up with the patch releases as they come out. Test early and have the environment on hand for when the time comes to dabble into the source. Postponing patch upgrades in the interest of time will eventually depreciate your lifespan.</div>

To set up the project in IntelliJ IDEA, it might be preferable to run `./gradlew idea` at the root of the project. This will attempt to generate the needed project files beforehand, allowing the development environment setup to proceed without many delays. Note that similar tasks are available for eclipse, etc.

# Running CAS

The CAS web application itself can be started from the command-prompt using an embedded Apache Tomcat container. In fact, this process is no different than deploying CAS using the same embedded Apache Tomcat container which means you will need to follow the [instructions posted here](https://apereo.github.io/cas/developer/Build-Process-5X.html) in the way that certificates and other configurations are needed in `/etc/cas/config`, etc to ensure CAS can function as you need it. All features modules and behavior that would be stuffed into the web application artifact continue to read settings from the same location, as they would be when activated from an overlay. The process is exactly the same.

I use the following alias in my bash profile to spin up CAS using an embedded Apache Tomcat container. You might want to do the same thing, or create the equivalent script for other operating systems to reduce time and keystrokes:

```bash
alias bc='clear; cd ~/Workspace/cas/webapp/cas-server-webapp-tomcat; \
    ../../gradlew build install bootRun --configure-on-demand --build-cache --parallel \
    -x test -x javadoc -x check -DenableRemoteDebugging=true --stacktrace \
    -DskipNestedConfigMetadataGen=true -DskipGradleLint=true -DskipSass=true \
    -DskipNodeModulesCleanUp=true -DskipNpmCache=true -DskipNpmLint=true'
```

Then, I simply execute the following in the terminal:

```bash
> bc
```

To understand the meaning and function behind various command-line arguments, please see [instructions posted here](https://apereo.github.io/cas/developer/Build-Process-5X.html). You may optionally decide to tweak each setting if you are interested in a particular build variant, such as generating javadocs, running tests, etc. One particular flag of interest is the addition of `enableRemoteDebugging`, which allows you, later on, to connect a remote debugger to CAS on a specific port (i.e. `5000`) and step into the code.

<div class="alert alert-info">
<strong>Bootiful CAS</strong><br/>At this time, the availability of the <code>bootRun</code> task running from inside IntelliJ IDEA is not possible.</div>

# Testing Modules

Per [instructions posted here](https://apereo.github.io/cas/developer/Build-Process-5X.html), the inclusion of a particular build module in the `build.gradle` of the CAS web application should allow the build process to automatically allow the module to be packaged and become available. Since the CAS web application we are running is supported by Apache Tomcat, the reference to the CAS reCAPTCHA module can be included [right there](https://github.com/apereo/cas/blob/5.2.x/webapp/cas-server-webapp-tomcat/build.gradle).

Alternatively, you may also include the reference in the [`webapp.gradle`](https://github.com/apereo/cas/blob/5.2.x/webapp/gradle/webapp.gradle#L109) file, which is the common parent to build descriptors that do stuff with the CAS web application. Making changes in this file will ensure it to be included *by default* in the generic CAS web application, regardless of how it is configured to run, which means you need to be extra careful about the sort of changes you make, what is kept and what is checked in here.

That said, the `webapp.gradle` is usually where I myself put the module references in and I try to be extra careful to not keep them in the same file when I check changes in for review, etc. So for reference and our task at hand, the `webapp.gradle` file would look like the following:

```gradle
dependencies {
    ...
    implementation project(":support:cas-server-support-captcha")
    ...
}
```

Note the reference locates the module using its full path. The next time you run `bc`, the final CAS web application will have enabled reCAPTCHA functionality when it's booting up inside Apache Tomcat.

The remaining tasks are super similar to the earlier post; we locate the `ValidateCaptchaAction` component and make the relevant change there. We then run `bc` to run CAS locally again to test the change and lather-rinse-repeat until the desired functionality is there. Once done, you may the commit the change to a relevant branch (of your fork, which is something you should have done earlier when you cloned the codebase) and push upstream (again, to your fork) in order to prepare a pull request and send in the change.

# Debugging CAS

One of the very useful things you can include in your build is the ability to allow for remote debugging via `-DenableRemoteDebugging=true`. Both [IntelliJ IDEA](https://www.jetbrains.com/help/idea/run-debug-configuration-remote-debug.html) and eclipse allow you ways to connect to this port remotely and activate a debugger in order to step into the code and troubleshoot. This is hugely useful, especially in cases where you can make a change to a source file and *rebuild* the component live and hot, reloading the `.class` file and allowing the changes to kick in the very next time execution passes through without restarting Tomcat. Depending on how significant the change is, this should save you quite a bit of time.

# So...

I hope this review was of some help to you and I am sure that both this post as well as the functionality it attempts to explain can be improved in any number of ways. Please feel free to [engage and contribute](https://apereo.github.io/cas/developer/Contributor-Guidelines.html) as best as you can.

Happy Coding,

[Misagh Moayyed](https://twitter.com/misagh84)

[1] There are ways to get around this *limitation*, by specifically downloading the source code for the exact CAS version at hand. I am skipping over those since they only lead to complications, suffering and further evil in most cases.