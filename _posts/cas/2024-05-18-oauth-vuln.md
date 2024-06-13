---
layout:     post
title:      CAS OAuth/OpenID Connect Vulnerability Disclosure
summary:    Disclosure of a security issue with the Apereo CAS software acting as an OAuth/OpenID Connect provider.
tags:       [CAS]
---

# Overview

This is an [Apereo CAS project vulnerability disclosure](https://apereo.github.io/cas/developer/Sec-Vuln-Response.html),
describing an issue in CAS acting as an OAuth/OpenID Connect provider. If your CAS server is not acting as an OAuth/OpenID Connect provider, there is nothing for you to do here. Keep calm and carry on.

For additional details on how security issues, patches and announcements are handled, please read the [Apereo CAS project vulnerability disclosure](https://apereo.github.io/cas/developer/Sec-Vuln-Response.html) process.

# Credits

This issue was originally reported, researched and tested by Mr. Jérôme Leleu, who is a project member and an active committer. Jérôme was kind enough to thoroughly investigate the issue, discuss the problem in detail, provide steps to reproduce the problem with an actual puppeteer test and offer insight to diagnose the root cause. 

Thank you Jérôme!

# Affected Deployments

The problem addressed here, [per the CAS maintenance policy](https://apereo.github.io/cas/developer/Maintenance-Policy.html), affects the Apereo CAS server for the following versions:

```
- 6.6.x
- 7.0.x
```

If your CAS version is not listed above **AND** is still part of an active maintenance cycle [per the CAS maintenance policy](https://apereo.github.io/cas/developer/Maintenance-Policy.html), then best effort (analysis or confirmation from reporters/testers) indicates that the version is not affected by this issue. That said, please note that per the project's Apache2 license, *software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied*. For additional information, please [see the project license](https://github.com/apereo/cas/blob/master/LICENSE).

If you or your institution is a member of the Apereo foundation with an active support subscription supporting the CAS project, please [contact the CAS subs working group](https://apereo.github.io/cas/Mailing-Lists.html) to learn more about this security vulnerability report.

# Severity

CAS presnts the ability to pin the single sign-on cookie to an authentication session that typically linked to the user's environment such as the browser user agent or the IP address. This behavior would, for example, prevent the single sign-on session to be recognized and accepted if the user's IP address changes between authentication attempts. However, this behavior was not corrected handled for OpenID Connect authentication requests and cookie session-pinning was effectively bypassed. 

Session pinning is typically controlled via:

```properties
cas.tgc.pin-to-session=true|false
```

So,

- If you have cookie session pinning turned off, this vulnerability and the listed patch releases do not apply to you.
- If you have cookie session pinning turned on, (which usually is the default CAS behavior), you may upgrade to the patch releases listed below.

# Timeline

The issue was originally reported on May 15th, 2024 and upon confirmation, CAS releases were patched and published on May 17th, 2023.

# Patching

Patch releases are available to address CAS deployments. Upgrades to the next patch version for each release should be a drop-in replacement.

## Procedure

### 6.6.x

Modify your CAS overlay to point to the version `6.6.15.1`.

### 7.0.x

Modify your CAS overlay to point to the version `7.0.4.1`.

# Support

Apereo CAS is Apache v2 open source software under the sponsorship of the Apereo Foundation. Support options may be [found here](https://apereo.github.io/cas/Support.html).

If you or your institution is a **member** of the Apereo foundation with an **active CAS subscription** supporting the CAS project, please [contact the CAS subs working group](https://apereo.github.io/cas/Mailing-Lists.html) to learn more about this security vulnerability.

# Resources

* [CAS Security Vulnerability Response Model](https://apereo.github.io/cas/developer/Sec-Vuln-Response.html)
* [CAS Maintenance Policy](https://apereo.github.io/cas/developer/Maintenance-Policy.html)

On behalf of the CAS Application Security working group,

[Misagh Moayyed](https://fawnoos.com)