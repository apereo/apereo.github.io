---
layout:     post
title:      CAS Codebase Overview
summary:    An overview of the CAS codebase organization and layout in which I also dig into the rationale behind project's efforts on modularization and code decomposition. 
tags:       [CAS]
---

# Overview

notes on categorizing modules on initial page; reduce scare factor and present readme immediately.
feature focused modules; no feature left behind. one feature per jar, where makes sense.
modules are cheap. builds are fast. gradle, etc.
intention-driven development; drop jar, it does stuff automatically. Remove the jar? you're done.
Highlight This is not OSGI.
Write code that is a pleasure to delete; modules can removed. Stormpath removed. Remove jar, remove the doc.
Docs are a module; Should be.
review CAS codebase; decomposition started around CAS 4.1. Gradually.
modules that contain only dependencies and glue code. "jetty" in cas.
uportal taking similar approaches. very good.

challenges

circular dependencies.
master command of the codebase
remember that nothing is perfect; improve/interate.
Ignore grand-planning suggestions altogether. Jot them down, or ask for a PR. Always ask: how badly do I hate this? rank yourself and then move on.
scanning for jars, startup time,  etc.

# Decomposition

[Misagh Moayyed](https://twitter.com/misagh84)
