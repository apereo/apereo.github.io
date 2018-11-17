---
layout:     post
title:      Apereo CAS 6.0.x - Building CAS Feature Modules
summary:    An overview of how various CAS features modules today can be changed and tested from the perspective of a CAS contributor working on the codebase itself to handle a feature request, bug fix, etc.
tags:       [CAS]
---

<div class="alert alert-success">
<strong>Collaborate</strong><br/>This blog is managed and hosted on GitHub. If you wish to update the contents of this post or if you have found an inaccuracy and wish to make corrections, we recommend that you please submit a pull request to <a href="https://github.com/apereo/apereo.github.io">this repository</a>.
</div>

# Overview

This quick walkthrough effectively aims for the following objectives:

- A quick development environment setup using IntelliJ IDEA.
- Building and running the CAS web application using Gradle.
- Changing feature modules and testing out behavior.
- Testing changes and writing unit tests.
- Stepping into the code using a debugger.

# Development Environment

Follow the [instructions posted here][buildprocess] to obtain the CAS source code. Remember to indicate the relevant `branch` in the commands indicated to obtain the right source code for the CAS version at hand. In this tutorial and just like before, the branch to use would be `6.0.x` (at the time of writing this post, the appropriate branch is `master`).

To understand what branches are available, [see this link](https://github.com/apereo/cas/branches). Your CAS version is closely tied to the branches listed in the codebase. For example, if you are deploying CAS `5.1.8`, then the relevant branch to check out would be `5.1.x`. Remember that branches always contain the most recent changeset and version of the release line. You might be deploying `5.1.8` while the `5.1.x` might be marching towards `5.1.10`. This requires that you first upgrade to the latest available patch release for the CAS version at hand and if the problem or use case continues to manifest, you can then check out the appropriate source branch and get fancy <sub>[1]</sub>.

<div class="alert alert-info">
<strong>Keep Up</strong><br/>It is <b>STRONGLY</b> recommended that you keep up with the patch releases as they come out. Test early and have the environment on hand for when the time comes to dabble into the source. Postponing patch upgrades in the interest of time will eventually depreciate your lifespan.</div>

It is important that to let IntelliJ IDEA open and refresh the Gradle project (using the *Refresh* button on the Gradle window's toolbar) once you do the initial import. Running `./gradlew idea` **MAY** work but it may also completely mess up the project structure especially if the plugin is not quite compatible with your IDE version. Note that similar tasks are available for eclipse.

For best results, try with IntelliJ IDEA `2018.3` (Ultimate Edition). Given the size of the CAS projects and the number of sub-modules, you need to make sure you have enough memory available for IDEA and that your custom JVM settings are correctly set per [the instructions here][buildprocess] for IntelliJ IDEA.

# System Requirements

It's best to get familiar with [CAS system requirements][systemrequirements]. Most importantly, this means that your system must be prepped with JDK `11`. Just about any JDK variant from any JDK vendor would do the job.

<div class="alert alert-danger">
  <strong>Important changes in Oracle JDK 11 License</strong><br/>With JDK 11 Oracle has updated the license terms on which Oracle JDK is offered. The new Oracle Technology Network License Agreement for Oracle Java SE is substantially different from the licenses under which previous versions of the JDK were offered. <b>Please review</b> the new terms carefully before downloading and using this product. Oracle also offers this software under the GPL License on jdk.java.net/11.</div>

For basic development and prototyping, try with:

```bash
java -version

java version "11" 2018-09-25
Java(TM) SE Runtime Environment 18.9 (build 11+28)
Java HotSpot(TM) 64-Bit Server VM 18.9 (build 11+28, mixed mode)
```

# Running CAS

The CAS web application itself can be started from the command-prompt using an embedded Apache Tomcat container. In fact, this process is no different from deploying CAS using the same embedded Apache Tomcat container which means you will need to follow the [instructions posted here][buildprocess] in the way that certificates and other configurations are needed in `/etc/cas/config`, etc to ensure CAS can function as you need it. All feature modules and behavior that would be stuffed into the web application artifact continue to read settings from the same location, as they would be when activated from an overlay. The process is exactly the same.

I use the following alias in my bash profile to spin up CAS using an embedded Apache Tomcat container. You might want to do the same thing:

```bash
alias bc='clear; cd ~/Workspace/cas/webapp/cas-server-webapp-tomcat; \
    ../../gradlew build bootRun --configure-on-demand --build-cache --parallel \
    -x test -x javadoc -x check -DenableRemoteDebugging=true --stacktrace \
    -DskipNestedConfigMetadataGen=true -DskipGradleLint=true -DskipSass=true \
    -DskipNodeModulesCleanUp=true -DskipNpmCache=true -DskipNpmLint=true'
```

Then, I simply execute the following in the terminal:

```bash
> bc
```

<div class="alert alert-info">
<strong>On Windows</strong><br/>You can apply the same strategy on Windows by creating a <code>bc.bat</code> file and making sure it's available on the <code>PATH</code>. The syntax of course needs to be adjusted to account for file paths and commands.</div>

To understand the meaning and function behind various command-line arguments, please see [instructions posted here][buildprocess]. You may optionally decide to tweak each setting if you are interested in a particular build variant, such as generating javadocs, running tests, etc. One particular flag of interest is the addition of `enableRemoteDebugging`, which allows you, later on, to connect a remote debugger to CAS on a specific port (i.e. `5000`) and step into the code. More on that later.

# Testing Modules

Per [instructions posted here][buildprocess], the inclusion of a particular build module in the Gradle build script of the CAS web application should allow the build process to automatically allow the module to be packaged and become available. You may include the module reference in the [`webapp.gradle`][webappgradlefile] file, which is the common parent to build descriptors that do stuff with CAS web applications. Making changes in this file will ensure that it will be included *by default* in the generic CAS web application, regardless of how it is configured to run using a servlet container, which means you need to be extra careful about the sort of changes you make, what is kept and what is checked in here.

So for reference and our task at hand, the file would look like the following:

```groovy
dependencies {
    ...
    implementation project(":support:cas-server-support-some-module")
    ...
}
```

Note the reference locates the module using its full path. The next time you run `bc`, the final CAS web application will have enabled reCAPTCHA functionality when it's booting up inside Apache Tomcat allowing you to make changes to said module and begin testing. The same command, `bc`, can be used over and over again to run CAS locally and test the change until the desired functionality is there.

Once done, you may then commit the change to a relevant branch (of your fork, which is something you should have done earlier when you cloned the codebase) and push upstream (again, to your fork) in order to prepare a pull request and send in the change targetted at the right destination branch. More info on that workflow [is available here][contribguide].

# Debugging CAS

One of the very useful things you can include in your build is the ability to allow for remote debugging via `-DenableRemoteDebugging=true`. Both [IntelliJ IDEA](https://www.jetbrains.com/help/idea/run-debug-configuration-remote-debug.html) and eclipse allow you ways to connect to a port remotely and activate a debugger in order to step into the code and troubleshoot. This is hugely useful, especially in cases where you can make a change to a source file and *rebuild* the component live hot-reloading the `.class` file to allow the changes to kick in the very next time execution passes through without restarting the servlet container. Depending on how significant the change is, this should save you quite a bit of time.

There are also much fancier tools such as [JRebel](https://zeroturnaround.com/software/jrebel/) that let you do the same with a lot more power and flexibility.

The remote debugging port by default is `5000` and should be auto-incremented in case the port is busy or occupied by some other process. You should get notices and prompts from the build, if and when that happens.

A very useful flag that you may consider adding to your shell alias is `-DremoteDebuggingSuspend=true`, which allows you to suspend the JVM until a debugger tool is attached to the running process. This is handy in situations where you need to debug and troubleshoot a particular component or behavior that executes early during startup (i.e. fetching CAS configuration settings or servlet container bootstrapping) and you don't want the runtime to proceed too quickly and forcing you to miss the troubleshooting window.

With the inclusion of this new flag, the build outcome sort of looks like this:

```bash
> Task :webapp:cas-server-webapp-tomcat:bootRun
Listening for transport dt_socket at address: 5000
```

# Overlay

Sometimes, it's useful to test the new change from the perspective of the [CAS Overlay][overlay]. While the behavior should be identical, this step can be used in quick smoke tests and to ensure the proper set of dependencies and modules are published and *installed* correctly and picked up by the overlay build process without any conflicts or duplicates.

To publish and *install* CAS artifacts locally, you may try the following:

```bash
# Build CAS and install...
alias bci='clear; cd ~/Workspace/cas \
    ../../gradlew clean build install --configure-on-demand --build-cache --parallel \
    -x test -x javadoc -x check -DenableRemoteDebugging=true --stacktrace \
    -DskipNestedConfigMetadataGen=true -DskipGradleLint=true -DskipSass=true \
    -DskipNodeModulesCleanUp=true -DskipNpmCache=true \
    -DskipNpmLint=true -DskipBootifulArtifact=true'
```

Be patient. This might take some time.

A rather important flag in the above build is `-DskipBootifulArtifact=true`. This stops the Gradle build from applying the Spring Boot plugin to bootify application components, mainly the various CAS web application artifacts. This is required because the [CAS Overlay][overlay] needs to operate on a *vanilla* web application untouched by Spring Boot plugins (a.k.a *non-bootiful*) before it can explode and repackage it with Spring Boot. Note that the CAS build and release processes automatically take this flag into account when snapshots or releases are published.

Once the artifacts are successfully installed, you can pick up the `-SNAPSHOT` artifacts in overlay by changing the CAS version and resume testing.

# Running Tests

# So...

I hope this review was of some help to you and I am sure that both this post as well as the functionality it attempts to explain can be improved in any number of ways. Please feel free to [engage and contribute][contribguide] as best as you can.

Happy Coding,

[Misagh Moayyed](https://twitter.com/misagh84)

[1] There are ways to get around this *limitation*, by specifically downloading the source code for the exact CAS version at hand. I am skipping over those since they only lead to complications, suffering and further evil in most cases.

[overlay]: https://github.com/apereo/cas-overlay-template
[contribguide]: https://apereo.github.io/cas/developer/Contributor-Guidelines.html
[webappgradlefile]: https://github.com/apereo/cas/blob/6.0.x/gradle/webapp.gradle
[systemrequirements]: https://apereo.github.io/cas/6.0.x/planning/Installation-Requirements.html
[buildprocess]: https://apereo.github.io/cas/developer/Build-Process-6X.html