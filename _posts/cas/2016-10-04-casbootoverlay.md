---
layout:     post
title:      Bootiful CAS 5 Overlay
summary:    A quick tutorial on running a CAS Overlay with Spring Boot.
tags:       [CAS]
---

# Overview

As you may know, the recommended strategy to start a CAS deployment today is via the
[WAR Overlay Installation Method](https://apereo.github.io/cas/development/installation/Maven-Overlay-Installation.html). The idea is that a deployment gets to keep only local customizations
and *inherits* everything else from a pre-built pre-configured instance. Not only this allows
one to keep track of intentional changes, but also makes it easier to upgrade
the software in place by simply bumping the CAS version in the overlay script.

CAS 5 itself is entirely based on Spring Boot. Today, CAS 5 overlays for both [Maven](https://github.com/apereo/cas-overlay-template/tree/5.0) and [Gradle](https://github.com/apereo/cas-gradle-overlay-template/tree/5.0) too are modified to accommodate easier deployment options via Spring Boot.

Here's how.

# Bootiful Overlay

Today, adopters are given 3 choices to deploy an overlay:

1. Run the CAS web application as an executable WAR via a `java -jar <cas-war-file>` type of command.
2. Deploy the `<cas-war-file>` into an external container of choice, such as Apache Tomcat.
3. [**NEW**] Run the CAS web application as an executable WAR via the Spring Boot's Maven/Gradle plugin, though you may be interested in [this issue](https://github.com/apereo/cas/issues/2334).

The 3rd option is similar to the native `java -jar ...` command with the main difference that the Spring Boot plugin is able to recognize the presence of Spring Boot's `devtools` that is shipped with CAS by default and allows for ad-hoc live monitoring of CAS resources.

This is specially helpful perhaps during UI design; such that you could keep modifying
`html`, `css`, and `js` resources and CAS will auto-detect changes and allows you to
see them via a simple refresh of your browser.

Lots quicker!

[Misagh Moayyed](https://fawnoos.com)
