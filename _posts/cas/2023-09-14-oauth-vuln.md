---
layout:     post
title:      CAS OAuth/OpenID Connect Vulnerability Disclosure
summary:    Disclosure of a security issue with the Apereo CAS software acting as an OAuth/OpenID Connect provider.
tags:       [CAS]
---

# Overview

This is an [Apereo CAS project vulnerability disclosure](https://apereo.github.io/cas/developer/Sec-Vuln-Response.html),
describing an issue in CAS acting as an OAuth/OpenID Connect provider. If your CAS server is not acting as an OAuth/OpenID Connect provider producing claims and attributes, there is nothing for you to do here. Keep calm and carry on.

For additional details on how security issues, patches and announcements are handled, please read the [Apereo CAS project vulnerability disclosure](https://apereo.github.io/cas/developer/Sec-Vuln-Response.html) process.

# Credits

This issue was originally reported, researched and tested by Mr. Terry Appleby, who is a senior developer at [wicket.io](https://wicket.io/.) Terry was kind enough to thoroughly investigate the issue, discuss the problem in detail, provide steps to reproduce the problem with an actual CAS overlay and puppeteer test and offer insight to diagnose the root cause. 

Thank you!

# Affected Deployments

The problem addressed here, [per the CAS maintenance policy](https://apereo.github.io/cas/developer/Maintenance-Policy.html), affects the Apereo CAS server for the following versions:

```
- 6.5.x
- 6.6.x
```

If your CAS version is not listed above **AND** is still part of an active maintenance cycle [per the CAS maintenance policy](https://apereo.github.io/cas/developer/Maintenance-Policy.html), then best effort (analysis or confirmation from reporters/testers) indicates that the version is not affected by this issue. That said, please note that per the project's Apache2 license, *software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied*. For additional information, please [see the project license](https://github.com/apereo/cas/blob/master/LICENSE).

If you or your institution is a member of the Apereo foundation with an active support subscription supporting the CAS project, please [contact the CAS subs working group](https://apereo.github.io/cas/Mailing-Lists.html) to learn more about this security vulnerability report.

# Severity

CAS incorrectly returns and releases a number of internal data structures and attributes in response to OAuth or OpenID Connect requests sent to the *User Profile* endpoint. Such internal data structures often tend to contain sensitive data such as the application policy record, details and metadata describing the authentication attempt, client secret assigned to the relying party, geo-location details when activated and more in plain JSON. 

This mistake is corrected in the patch releases described below.

# Timeline

The issue was originally reported on September 13th, 2023 and upon confirmation, CAS releases were patched and published on September 14th, 2023.

# Patching

Patch releases are available to address CAS deployments. Upgrades to the next patch version for each release should be a drop-in replacement.

## Procedure

### 6.5.x

Modify your CAS overlay to point to the version `6.5.9.4`.

### 6.6.x

Modify your CAS overlay to point to the version `6.6.12`.

# Support

Apereo CAS is Apache v2 open source software under the sponsorship of the Apereo Foundation, supported by community volunteers and enthusiasts. Support options may be [found here](https://apereo.github.io/cas/Support.html).

If you or your institution is a member of the Apereo foundation with an active subscription supporting the CAS project, please [contact the CAS subs working group](https://apereo.github.io/cas/Mailing-Lists.html) to learn more about this security vulnerability report.

# Resources

* [CAS Security Vulnerability Response Model](https://apereo.github.io/cas/developer/Sec-Vuln-Response.html)
* [CAS Maintenance Policy](https://apereo.github.io/cas/developer/Maintenance-Policy.html)

On behalf of the CAS Application Security working group,

[Misagh Moayyed](https://fawnoos.com)