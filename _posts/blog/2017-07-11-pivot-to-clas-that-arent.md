---
layout:     post
title:      Lighter than CLAs
summary:    One path away from requiring Contributor License Agreements.
tags:       [Licensing]
---

(This post is written as an individual Apereo participant. I also serve as chair of the Apereo Licensing group but this post is not written from the perspective of that hat.)

# The situation

Apereo

1. Uses Apache-style Contributor License Agreements.
2. Has evolved to include a diversity of projects under a diversity of licenses.

Small sample suggesting license diversity:

+ apereo.githib.io (CC-BY)
+ uPortal (Apache 2)
+ Sakai CLE (ECLv2)
+ POET (GPL)
+ cpsolver (LGPL)

# The Fedora example

Fedora found itself in this situation. It had been using Apache-style Contributor License Agreements and came to have a diversity of sub-projects.

Fedora evolved to stop using Apache-style Contributor License Agreements and instead use a lighter-weight agreement, the Fedora Project Contributor Agreement.

What's brilliant about the FPCA is that it's not a license agreement. Not really. It's more a Developer Certificate of Origin.

Via an Apache-style Contributor License Agreement, the Contributor contributes other than via the open source license of the project. They grant special extra rights to some but not other participants in the open source project, namely to the Foundation itself.

Via the FPCA, the Contributor

+ reassures that they have the rights to Contribute the Contribution.
+ sets default licensing terms for cases where the Contributor wasn't explicit in marking the Contribution with licensing but it's clear from context what the marking should have been (as in, the license of the Work being contributed to)


Fedora participants signify agreement to the FCLA via a checkbox in user account creation, which is pre-requisite to access to systems for submitting an issue or patch.

This drove down the barrier to contribution.

# Be like Fedora

Path forward:

+ Introduce a lighter-weight not-actually-a-CLA contributor agreement.
+ Introduce lighter-weight ways of agreeing to that agreement.
+ Retire usage of the heavier-weight Apache Contributor License Agreements.
+ Thereby reduce barriers to contribution, document retention burdens, worries.
+ Deliver tremendous value to humankind through excellent open source collaboration in support of higher education.


-[Andrew](https://apetro.ghost.io)
