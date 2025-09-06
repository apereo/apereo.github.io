---
layout:     post
title:      CAS Simple Multifactor Authentication Vulnerability Disclosure
summary:    Disclosure of a security issue with the Apereo CAS software acting itself as an MFA provider.
tags:       [CAS]
---

# Overview

This is an [Apereo CAS project vulnerability disclosure](https://apereo.github.io/cas/developer/Sec-Vuln-Response.html),
describing an issue in CAS acting as a simple multifactor authentication provider.

For additional details on how security issues, patches and announcements are handled, please read the [Apereo CAS project vulnerability disclosure](https://apereo.github.io/cas/developer/Sec-Vuln-Response.html) process.

# Credits

This issue was originally reported, researched and tested by Mr. Jérôme Leleu, who is a project member and an active committer. Jérôme was kind enough to thoroughly investigate the issue, discuss the problem in detail, provide steps to reproduce the problem and offer insight to diagnose the root cause. 

Thank you Jérôme!

# Affected Deployments

The problem addressed here, [per the CAS maintenance policy](https://apereo.github.io/cas/developer/Maintenance-Policy.html), affects the Apereo CAS server for the following versions:

```
- 7.1.x
- 7.2.x
```

If your CAS version is not listed above **AND** is still part of an active maintenance cycle [per the CAS maintenance policy](https://apereo.github.io/cas/developer/Maintenance-Policy.html), then best effort (analysis or confirmation from reporters/testers) indicates that the version is not affected by this issue. That said, please note that per the project's Apache2 license, *software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied*. For additional information, please [see the project license](https://github.com/apereo/cas/blob/master/LICENSE).

If you or your institution is a member of the Apereo foundation with an active support subscription supporting the CAS project, please [contact the CAS subs working group](https://apereo.github.io/cas/Mailing-Lists.html) to learn more about this security vulnerability report.

# Severity

You are effected by this security vulnerability if your CAS deployment is acting as a multifactor authentication provider and is using the CAS Simple MFA module. 

Simple MFA in CAS generates its own codes using a secure random strategy to ensure generated IDs cannot collide with previously generated codes. One controlling factor here is the code length (6 by default). In scenarios where the code length is lowered to smaller lengths and typically under high traffic and load, it's quite possible for one to run into code collisions and duplicates. As a result, two separate different users might be sharing the same code and may be able to log in as one another.

Fixes in this area force CAS to never a generate a code that was already generated and remains valid. The generate function should take this rule into account and will attempt to re-generate the code if it runs into a collision.

If your deployment does not pass the noted condition(s) above, there is nothing for you to do here. Keep calm and carry on.

# Timeline

The issue was originally reported on August 18th, 2025 and upon confirmation, CAS releases were patched and eventually published on August 19th, 2025.

# Patching

Patch releases are available to address CAS deployments. Upgrades to the next patch version for each release should be a drop-in replacement.

## Affected Versions

### 7.1.x

Modify your CAS overlay to point to the version `7.1.6.1`.

### 7.2.x

Modify your CAS overlay to point to the version `7.2.6`.

## How to upgrade

- Locate your `gradle.properties` file in your CAS overlay, found at the root of the project.
- Modify your CAS version to point to the approriate release by updating the `cas.version` property.
- Follow the instructions in the `README.md` file to build the server.

# Support

Apereo CAS is Apache v2 open source software under the sponsorship of the Apereo Foundation. Support options may be [found here](https://apereo.github.io/cas/Support.html).

If you or your institution is a **member** of the Apereo foundation with an **active CAS subscription** supporting the CAS project, please [contact the CAS subs working group](https://apereo.github.io/cas/Mailing-Lists.html) to learn more about this security vulnerability.

# Resources

* [CAS Security Vulnerability Response Model](https://apereo.github.io/cas/developer/Sec-Vuln-Response.html)
* [CAS Maintenance Policy](https://apereo.github.io/cas/developer/Maintenance-Policy.html)
* [CAS Mailing Lists](https://apereo.github.io/cas/Mailing-Lists.html)

On behalf of the CAS Application Security working group,

[Misagh Moayyed](https://fawnoos.com)
