---
layout:     post
title:      CAS Vulnerability Disclosure
summary:    Disclosure of a security issue with the CAS software.
tags:       [CAS]
---

# Overview

This is the initial version of an [Apereo CAS project vulnerability disclosure](https://apereo.github.io/cas/developer/Sec-Vuln-Response.html), describing an issue in CAS that affects the handling of secret keys with Google Authenticator for multifactor authentication.

This post will be updated with additional details once the grace period has passed.

# Affected Deployments

The security issue described here, [per the CAS maintenance policy](https://apereo.github.io/cas/developer/Maintenance-Policy.html), affects the Apereo CAS server for the following versions:

```   
- 5.3.x 
- 6.0.x
- 6.1.x
- 6.2.x
```

If your CAS version is not listed above and is still part of an active maintenance cycle [per the CAS maintenance policy](https://apereo.github.io/cas/developer/Maintenance-Policy.html), then best effort (analysis or confirmation from reporters/testers) indicates that the version is not affected by this issue. That said, please note that per the project's Apache2 license, *software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.*. For additional information, please [see the project license](https://github.com/apereo/cas/blob/master/LICENSE).

If you or your institution is a member of the Apereo foundation with an active subscription supporting the CAS project, please [contact the CAS subs working group](https://apereo.github.io/cas/Mailing-Lists.html) to learn more about this security vulnerability report.

# Severity

It is recommended that upgrades be carried out to removes any chances of security breaches. If an upgrade is not possible, we recommend that you carefully review HTTP and access logs to sanitize and scrub details, especially if an external log aggregation tool is in place.

This post will be updated with additional details once the grace period has passed.

# Timeline

The issue was originally reported on September 25th, 2020 and upon confirmation, CAS releases were patched and released on October 14th, 2020.

# Patching

Patch releases are available to address CAS deployments. Upgrades to the next patch version for each release should be a drop-in replacement.

## Procedure

### 5.3.x

Modify your CAS overlay to point to the version `5.3.16`. 

### 6.0.x

EOL. Upgrade your CAS overlay to point to CAS `6.1.7.2`. 

### 6.1.x

Modify your CAS overlay to point to the version `6.1.7.2`. 

### 6.2.x

Modify your CAS overlay to point to the version `6.2.4`.

### 6.3.x

Modify your CAS overlay to point to the version `6.3.0-RC4` when released.

# Support

Apereo CAS is Apache v2 open source software under the sponsorship of the Apereo Foundation, supported by community volunteers and enthusiasts. Support options may be [found here](https://apereo.github.io/cas/Support.html).

If you or your institution is a member of the Apereo foundation with an active subscription supporting the CAS project, please [contact the CAS application security working group](https://apereo.github.io/cas/Mailing-Lists.html#cas-public-security-list-cas-appsec-publicapereoorg) to learn more about this security vulnerability report.

# Resources

* [CAS Security Vulnerability Response Model](https://apereo.github.io/cas/developer/Sec-Vuln-Response.html)
* [CAS Maintenance Policy](https://apereo.github.io/cas/developer/Maintenance-Policy.html)

On behalf of the CAS Application Security working group,

[Jérôme LELEU](jerome@casinthecloud.com)