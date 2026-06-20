---
layout:     post
title:      Changes to CAS Security Vulnerability Response
summary:    Apereo CAS is shortening the security disclosure grace window.
tags:       [CAS]
---

# TL;DR

The Apereo CAS project has approved a proposal to shorten our security grace window from **four weeks** to **two weeks**.

Going forward, security fixes will follow a two-week grace period before broader public disclosure and announcement. This change reflects both the current pace of software delivery and the evolving security landscape in which fixes, diffs, source artifacts, and public hints can be analyzed far more quickly than in the past.

# Why the Change?

The previous four-week window was established at a time when many organizations still relied heavily on manual build, release, and deployment processes. It was intended to give adopters a reasonable amount of time to upgrade before security issues were more widely announced.

That environment has changed significantly. Today, automated builds, dependency management tools, CI/CD pipelines, containerized deployments, and release automation are far more common. At the same time, security reports are arriving more frequently, and AI-assisted analysis has shortened the time between a fix being published and the underlying vulnerability being understood. In practice, this means the effective secrecy window around a security fix is much shorter than it used to be. Once a fix is available, motivated observers can often infer the nature of the issue without a lot of hassle.

Given that reality, maintaining a four-week delay before wider disclosure no longer provides the same level of protection it once did.

# What Is Changing?

For future security fixes, the grace window will be shortened from 4 weeks to 2 weeks. This means adopters will have two weeks after a security fix is published before broader public disclosure and announcement. The project documentation has been updated to reflect the new two-week security grace window. 

# What Is Not Changing?

This change does not affect security fixes that have already been published. Any security fix already operating under the previous four-week window will continue to follow that original timeline. The new two-week window applies only to future security fixes.

# Expectations for Adopters

We recognize that this change means organizations will need to respond more quickly to security releases. However, this is also an intentional nudge toward more automated, repeatable, and reliable upgrade processes. Projects and organizations that still depend on manual upgrade and deployment steps should use this change as an opportunity to review their release workflows, dependency management practices, and deployment automation. Today, the ability to apply security updates quickly is no longer just operationally convenient. It is part of maintaining a responsible security posture.

The goal is to strike a better balance between giving adopters time to upgrade and ensuring the wider community receives timely information about security issues. We appreciate the community’s continued attention to responsible disclosure, timely upgrades, and the ongoing security of the ecosystem.

On behalf of the CAS Project,

[Misagh Moayyed](https://fawnoos.com)
