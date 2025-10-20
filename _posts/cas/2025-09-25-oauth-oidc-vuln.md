---
layout:     post
title:      CAS OAuth/OpenID Connect Vulnerability Disclosure
summary:    Disclosure of a security issue with the Apereo CAS software acting itself as an OAuth/OpenID Connect provider.
tags:       [CAS]
---

# Overview

This is an [Apereo CAS project vulnerability disclosure](https://apereo.github.io/cas/developer/Sec-Vuln-Response.html),
describing an issue in CAS acting as an OAuth/OpenID Connect provider.

For additional details on how security issues, patches and announcements are handled, please read the [Apereo CAS project vulnerability disclosure](https://apereo.github.io/cas/developer/Sec-Vuln-Response.html) process.

# Credits

This issue was originally reported by Luca Famà and was later corroborated by the team at [Coop (Switzerland)](https://www.coop.ch/), namely Artur Stoecklin and David Roth. The group was kind enough to thoroughly investigate the issue, discuss the problem in detail, provide steps to reproduce the problem and offer insight to diagnose the root cause. 

Thank you everyone!

# Affected Deployments

The problem addressed here, [per the CAS maintenance policy](https://apereo.github.io/cas/developer/Maintenance-Policy.html), affects the Apereo CAS server for the following versions:

```
- 7.1.x
- 7.2.x
```

If your CAS version is not listed above **AND** is still part of an active maintenance cycle [per the CAS maintenance policy](https://apereo.github.io/cas/developer/Maintenance-Policy.html), then best effort (analysis or confirmation from reporters/testers) indicates that the version is not affected by this issue. That said, please note that per the project's Apache2 license, *software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied*. For additional information, please [see the project license](https://github.com/apereo/cas/blob/master/LICENSE).

If you or your institution is a member of the Apereo foundation with an active support subscription supporting the CAS project, please [contact the CAS subs working group](https://apereo.github.io/cas/Mailing-Lists.html) to learn more about this security vulnerability report.

# Severity

You are effected by this security vulnerability if your CAS deployment is acting as an OAuth/OpenID Connect identity provider. 

The issue primarily presents itself when CAS receives an OAuth or OpenID Connect authorization request, and in the absense of an SSO session, attempts to route the request to the login endpoint, constructing a special *callback* URL that is passed as the `service` parameter to the login endpoint. This callback URL essentially points back to CAS itself and restarts the flow once the login attempt is completed. The attacker could somehow hijack this callback URL and modify it in such a way that would fool CAS into redirecting to an unauthorized URL. This is caused given the fact that the callback URL is registered with CAS as an internal service whose matching policy is based on regular expressions and pattern matching, and as a result, the attacker could manipulate the `service` parameter such that the pattern enforced is bypassed.

In summary, this is an "Open Redirect" security vulnerability. We believe this is fairly low risk, and does not allow one to cause any major material damage to the CAS server. 

If your deployment does not pass the noted condition(s) above, there is nothing for you to do here. Keep calm and carry on.

# Timeline

The issue was originally reported on September 17th, 2025 and upon confirmation, CAS releases were patched and eventually published on September 25th, 2025.

# Patching

Patch releases are available to address CAS deployments. Upgrades to the next patch version for each release should be a drop-in replacement.

## Affected Versions

### 7.1.x

Modify your CAS overlay to point to the version `7.1.6.2`.

### 7.2.x

Modify your CAS overlay to point to the version `7.2.7`.

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
