---
layout:     post
title:      Apereo CAS Best [Mal]Practice - Supercharged Overlays
summary:    An overview of how a CAS overlay prepped for deployment can tap into internal components, altering logic and behavior for good and evil...but mostly evil.
tags:       [CAS]
---

<div class="alert alert-success">
<strong>Collaborate</strong><br/>This blog is managed and hosted on GitHub. If you wish to update the contents of this post or if you have found an inaccuracy and wish to make corrections, we recommend that you please submit a pull request to <a href="https://github.com/apereo/apereo.github.io">this repository</a>.
</div>

# Overview

There are a number of [tutorials and overviews](https://apereo.github.io/tags/#CAS) that describe the purpose and anatomy of a [CAS Overlay](https://apereo.github.io/cas/development/installation/Maven-Overlay-Installation.html). What is often left unsaid in these posts is the note that a CAS overlay, regardless of how it is orchestrated by your favorite hipster build tool of the week, can be used to override *any and all* CAS components that are configured and available at runtime where this not only includes somewhat static configuration such as property files, HTML views, and YAML configuration but also Java classes, solid source code and beyond.

This brief walkthrough aims to uncover the magical ways one can tap into and alter the CAS source code from an overlay perspective, without quite dealing with the CAS codebase, for good and evil...but mostly evil.

# Why

The most immediate question to address is along the lines of...

> Why would anyone ever want to do this?

It more or less comes down to the following categories of rationale:

- There may be cases where analysis and troubleshooting of a CAS feature are not quite possible by simply reviewing `DEBUG` logs or changing configuration. You may need to access the source code to put in additional diagnostic information, include extra conditions to validate values, enforce availability of systems, etc.

- Likewise, there may be requirements whose implementation may need tapping into an internal CAS component for a change in behavior. This is the case where things work as intended, but not quite the way you envision the change to execute for your deployment. So you step in to change a `false` to `true`, remove an extra condition or add minimal behavior to support a new syntax for a configuration value, rename a field, etc.

In *almost* all cases the changes that go into the overlay, specifically dealing with core components, are decent candidates for contributions and pull requests and ultimately should be removed from the overlay.

# Why Not

Any time you are about to tap into CAS internals, you should pause and reconsider alternative approaches and subsequently the overall maintenance strategy of the change, especially if the reason for the change has to do with the second category of modifications noted above. Depending on scope and component, the change may not be forward-compatible at all, the original component may be heavily refactored or removed in future versions without mercy, the feature may get removed entirely and you may be forever left with local customizations that require maintenance and care for every build and future upgrade. This is the power of open-source where modifications come freely with code at hand...with the understanding that *"You can do things on your own, but then, you would [mostly] be on your own"*.

Though put in somewhat extreme terms, consider this a best malpractice that if your CAS deployment overlay contains any `.java` code, chances are you are doing something *wrong*. There should be [better routes and strategies](https://apereo.github.io/2017/09/10/stop-writing-code/) on how to deliver the same end result and those should not solely and exclusively belong to your deployment. You are not that special. Given timeline and budget if you find no other strategy, always label the changes to be temporary and work as hard as you can to remove it. I could not tell you how many times I have been involved in deployments where the prospect has made significant modifications to CAS internals and...

- Has no clue how the changes work.
- ...or the person responsible for the changes is no longer with the organization.
- ...or there is no documentation and rationale for the now-outdated change.
- ...or the organization has completely lost the original source code.
- ...or the change is implemented in such a way that is not sustainable without major editorials.
- ...or the change opens up the deployment to a security vulnerability.
- ...or the change prevents the deployment from gaining a fix for a security vulnerability.
- etc.

<div class="alert alert-success">
<strong>A Pinch of Salt</strong><br/>Of course, there are reasonable exceptions here especially in areas where there are documented and/or recommended approaches to customizations and extending system behavior. The point is, consider all alternatives before stepping into a development mood.</div>

# Having Said That

Let's consider a quick hypothetical use case with CAS `5.2.x` and its support for [Google reCAPTCHA](https://apereo.github.io/cas/5.2.x/integration/Configuring-Google-reCAPTCHA.html). Suppose that you have an overlay that is adequately prepped with relevant intention modules and properties to make reCAPTCHA work. Things have been running just fine. Then comes a change in protocol from Google that changes the validation response to include the now-renamed field `successful` instead of the old `success`. The reCAPTCHA module in CAS obviously has not had a chance to catch up to this change and is still looking out for `success` in the validation response and begins to error out. What to do?

Step #1: Identify the need to tap into the source code.
Step #2: Rename the flag in the right `.java` component.
Step #3: Build and test the behavior.

A quick analysis of the reCAPTCHA module in CAS reveals `src/main/java/org/apereo/cas/web/flow/ValidateCaptchaAction.java` that in fact handles the validation by checking for the value of the `success` field in the response. Here is the relevant code snippet:

```java
...
final String response = in.lines().collect(Collectors.joining());
LOGGER.debug("Google captcha response received: [{}]", response);
final JsonNode node = READER.readTree(response);
if (node.has("success") && node.get("success").booleanValue()) {
    ...
}
...
```

The above snippet attempts read and transform the response into a JSON object, checking for the trueness of the `success` field. How do we apply the source code change in the overlay to now examine for `successful`?

# Overlay The Code

In the root directory of the overlay project, (assuming a Maven overlay), run the following commands:

```bash
# Create the directory path to match the component's package name
mkdir -p src/main/java/org/apereo/cas/web/flow

# Download the source file for the CAS version
wget https://raw.githubusercontent.com/apereo/cas/5.2.x/support/cas-server-support-captcha
        /src/main/java/org/apereo/cas/web/flow/ValidateCaptchaAction.java \
        -P src/main/java/org/apereo/cas/web/flow/

# Run a sanity build to ensure the overlay is functional
./mvnw clean package
```

<div class="alert alert-info">
<strong>Remember</strong><br/>All source code that is put into the overlay must be housed inside the <code>src/main/java</code> directory, followed by the exact path to the component noted by its package name. If the package name, for instance, is <code>org.apereo.cas.support.web.flow</code>, then the full path for the overlaid component would be <code>src/main/java/org/apereo/cas/support/web/flow</code>. All source code is compiled and placed inside the <code>WEB-INF/classes</code> parent directory.</div>

Notice there are a number of failures now reported by the Maven build complaining about missing symbols. This is due to the fact that the build is now trying to compile our downloaded version of `ValidateCaptchaAction.java` which itself depends on a number of other components and libraries that must be available at compile-time for the task to succeed. So we need to locate what and where the missing items are and get them added to the build script.

# Add Dependencies

Modify the `pom.xml` to include the following:

```xml
...
<dependency>
    <groupId>org.apereo.cas</groupId>
    <artifactId>cas-server-support-captcha</artifactId>
    <version>${cas.version}</version>
</dependency>
<dependency>
    <groupId>org.apereo.cas</groupId>
    <artifactId>cas-server-core-web</artifactId>
    <version>${cas.version}</version>
</dependency>
<dependency>
    <groupId>org.apereo.cas</groupId>
    <artifactId>cas-server-core-webflow</artifactId>
    <version>${cas.version}</version>
</dependency>
<dependency>
    <groupId>org.apereo.cas</groupId>
    <artifactId>cas-server-core-configuration</artifactId>
    <version>${cas.version}</version>
</dependency>
<dependency>
    <groupId>javax.servlet</groupId>
    <artifactId>javax.servlet-api</artifactId>
    <version>3.1.0</version>
    <scope>provided</scope>
</dependency>
...
```

<div class="alert alert-info">
<strong>Good Dependency Hunting</strong><br/>To know which dependencies and versions should be included when the build reports back errors on missing symbols, you will need to become familiar with the CAS codebase and the dependencies upon which this particular module (i.e. reCACAPTCHA) depends, both locally and globally. At this point, the code itself is the best documentation you could have available.</div>

Now we run the build again:

```bash
# Run a sanity build to ensure the overlay is functional
./mvnw clean package
```

...and the build should proceed normally. Great! Let's make the change now.

# Make The Change

Our next step is to find our Java code snippet above and make the following change:

```java
...
final String response = in.lines().collect(Collectors.joining());
LOGGER.debug("Google captcha response received: [{}]", response);
final JsonNode node = READER.readTree(response);
if (node.has("successful") && node.get("successful").booleanValue()) {
    ...
}
...
```

Rebuild and deploy. Things should now work as expected with the above change. Cool, eh?

# Wait...How?

The short and simplified answer is that similar to how static content is overlaid and then *preferred* over what's provided by default, local source code components are also made available in a similar fashion on a classpath route that is slightly prioritized over what is buried in some CAS `.jar` file. Due to this *trick*, when the runtime begins to locate the compiled `ValidateCaptchaAction.class` file, it scans the specialized classpath route first and thus finds our overlaid copy of it, deferring the default for later use. If you end up deleting the `ValidateCaptchaAction.java` from the overlay and thus removing its binary brother from the packaged build, the runtime will simply fall back onto what is provided by the `cas-server-support-captcha` module.

# So, Now What?

As you can see, there are inherent dangers in this approach:

- The original contents of `ValidateCaptchaAction` could change from CAS version to version, thus invalidating your local copy of it.
- Your build is now that more complicated with the inclusion of a handful of extra modules to make a simple one-liner change work.
- Any of the now-included modules can be renamed or removed from CAS version to version, thus making your build dysfunctional in the future.
- ...and just to demonstrate the problem, our change as it is most often the case, is completely undocumented! Without comparison against the original source file, it is entirely unclear why this source file exists in an overlay which would make it difficult for the next person in line to pick up the maintenance effort, two years into the deployment.

But there is light at the end of the tunnel. Now that you have made a reasonable change and are satisfied with its behavior, the next best course of action would be to remove the file altogether (and every other change you made along with it) and contribute the fix back to the CAS codebase. This is *NOT* the sort of change that should be specialized for any single deployment and in the interest of "*It Should Just Work*", the behavior of `ValidateCaptchaAction` should just do the correct thing by default, removing any learning curve or need for one to make changes.

As a [follow-up to this blog post](https://apereo.github.io/2018/04/05/cas-codebase-feature-build), I will outline how the change can be developed and tested from the perspective of the CAS codebase itself.

Stay tuned!

# Finale

I hope this review was of some help to you and I am sure that both this post as well as the functionality it attempts to explain can be improved in any number of ways. Please feel free to [engage and contribute](https://apereo.github.io/cas/developer/Contributor-Guidelines.html) as best as you can.

Happy Coding,
[Misagh Moayyed](https://twitter.com/misagh84)