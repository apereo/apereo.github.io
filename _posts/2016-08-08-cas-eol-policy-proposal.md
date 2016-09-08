---
layout:     post
title:      CAS EOL Policy Proposal
summary:    In which I attempt to provide an overview of the new CAS EOL policy.
date:       2016-08-08 12:32:18
categories: cas
---

The CAS project management committee has been reviewing a proposal on CAS release policies, maintenance and lifetime. In particular, this proposal attempts to provide answers to the following questions:

- How long should a CAS release be maintained?
- What is the appropriate scope for release maintenance once a release is retired?

## Today

The project has been handling release management and maintenance in a semi-official capacity. Today's release practices typically are:

- Patch releases, once every 30 days.
- Minor releases, once every 3-4 months.
- Major releases, where appropriate based on community demand and technical landscape.
- Security patches, whenever needed and preferably as soon as humanly possible.

There is no official policy to indicate the lifespan of a CAS release. Maintaining multiple release lines in an adhoc fashion is a very time-consuming and difficult process where the development team has to ensure patches across releases are ported backward or forward correctly and that changesets are properly cherry-picked into the target release, tested, documented and made available.

This process is simply not sustainable.

## Proposal

To mitigate some of this pain, the following proposal and a decidedly simple one at that is in the making:

- CAS adopters **MAY EXPECT** a CAS release to be maintained for one calendar year, starting from [the original release date](https://github.com/apereo/cas/milestones).
- Maintenance during this year includes bug fixes, security patches and general upkeep of the release.
- Once the year is passed, maintenance of the release is **STRICTLY** limited to security patches and fixing vulnerabilities for another calendar year.  
- The lifespan of a release **MAY** be extended beyond a single year, to be decided by the CAS PMC and the community at large when and where reasonable.

By "CAS Release", we mean anything that is a minor release and above. (i.e. `4.1.x`, `4.2.x`, `5.0.0`, `5.1.0`, etc).


## What does this mean?

The above policy, once in effect, implies that the following CAS releases will transition into a security-patch mode (SPM) only and will be EOLed at the indicated dates.

| Release        | SPM Starting Date  | Full EOL  |
| -------------- |:-------------:| --------------:|
| `4.0.x`        | October 31st, 2016 | October 31st, 2017 |
| `4.1.x`        | January 31st, 2017 | January 31st, 2018 |
| `4.2.x`        | January 31st, 2017  | January 31st, 2018 |
| `5.0.x`        | September 30th, 2017  | September 30th, 2018 |

All past releases that are absent in the above table are considered EOLed.


[Misagh Moayyed](https://twitter.com/misagh84)
