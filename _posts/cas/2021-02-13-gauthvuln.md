---
layout:     post
title:      CAS Vulnerability Disclosure
summary:    Disclosure of a security issue with the CAS software.
tags:       [CAS]
---

# Overview

This is the initial version of an [Apereo CAS project vulnerability disclosure](https://apereo.github.io/cas/developer/Sec-Vuln-Response.html),
describing an issue in CAS that affects handling Google Authenticator accounts for multifactor authentication. If you are not using Google Authenticator for multifactor authentication there is nothing to do here. Keep calm and carry on.

For additional details on how security issues, patches and announcements are handled, please read the [Apereo CAS project vulnerability disclosure](https://apereo.github.io/cas/developer/Sec-Vuln-Response.html) process.

# Affected Deployments

The security issue described here, [per the CAS maintenance policy](https://apereo.github.io/cas/developer/Maintenance-Policy.html), affects the Apereo CAS server for the following versions:

```
- 6.2.x
- 6.3.x
```

If your CAS version is not listed above and is still part of an active maintenance cycle [per the CAS maintenance policy](https://apereo.github.io/cas/developer/Maintenance-Policy.html), then best effort (analysis or confirmation from reporters/testers) indicates that the version is not affected by this issue. That said, please note that per the project's Apache2 license, *software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.*. For additional
information, please [see the project license](https://github.com/apereo/cas/blob/master/LICENSE).

If you or your institution is a member of the Apereo foundation with an active support subscription supporting the CAS project, please [contact the CAS subs working group](https://apereo.github.io/cas/Mailing-Lists.html) to learn more about this security vulnerability report.

# Severity

The underlying issue allows the adversary to bypass the Google Authenticator 2FA mechanism, by using a mixture of uppercase and lowercase characters in the username, having compromised the user account in the first place. The component abstractions that are responsible for locating user records with Google Authenticator tend to execute search queries in a case-sensitive manner. If the given username contains mixed characters and primary authentication (such as LDAP) allows for case-insensitive usernames, the repository component in the 2FA step might fail to locate the proper user record, and in turn might ask the user/adversary to enroll their own device and log in.

It is recommended that upgrades be carried out to removes any chances of security breaches. This post will be updated with additional details once the grace period has passed.

# Timeline

The issue was originally reported on February 9th, 2021 and upon confirmation, CAS releases were patched on February 10th, 2021 and released on February 13th, 2021.

# Patching

Big thanks to Linos Giannopoulos for [reporting this issue](https://apereo.github.io/cas/developer/Sec-Vuln-Response.html), supplying a patch to fix the issue and working with the security team to test and discuss the fix.

Patch releases are available to address CAS deployments. Upgrades to the next patch version for each release should be a drop-in replacement.

## Procedure

### 6.2.x

Modify your CAS overlay to point to the version `6.2.8`.

### 6.3.x

Modify your CAS overlay to point to the version `6.3.2`.

# Support

Apereo CAS is Apache v2 open source software under the sponsorship of the Apereo Foundation, supported by community volunteers and enthusiasts. Support options may be [found here](https://apereo.github.io/cas/Support.html).

If you or your institution is a member of the Apereo foundation with an active subscription supporting the CAS project, please [contact the CAS subs working group](https://apereo.github.io/cas/Mailing-Lists.html) to learn more about this security vulnerability report.

# Resources

* [CAS Security Vulnerability Response Model](https://apereo.github.io/cas/developer/Sec-Vuln-Response.html)
* [CAS Maintenance Policy](https://apereo.github.io/cas/developer/Maintenance-Policy.html)

On behalf of the CAS Application Security working group,

[Misagh Moayyed](https://fawnoos.com)