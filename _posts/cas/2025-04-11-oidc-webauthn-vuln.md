---
layout:     post
title:      CAS OAuth/OpenID Connect & WebAuthN Vulnerability Disclosure
summary:    Disclosure of a security issue with the Apereo CAS software acting as an OAuth/OpenID Connect provider, or a as a multifactor authentication provider utilizing FIDO2/WebAuthN.
tags:       [CAS]
---

# Overview

This is an [Apereo CAS project vulnerability disclosure](https://apereo.github.io/cas/developer/Sec-Vuln-Response.html),
describing an issue in CAS acting as an OAuth/OpenID Connect provider or as a multifactor authentication provider utilizing FIDO2/WebAuthN. See below for details.

For additional details on how security issues, patches and announcements are handled, please read the [Apereo CAS project vulnerability disclosure](https://apereo.github.io/cas/developer/Sec-Vuln-Response.html) process.

# Credits

The problems outlined in this security vulnerability were originally reported, researched and tested by Lucile RAZÉ and Jean-Léon CUSINATO from AMOSSYS, a cybersecurity consulting firm. They were kind enough to investigate the issue, offer insight to diagnose the root cause and took steps to verify the fix for various patch releases privately.

Thank you!

# Affected Deployments

The problem addressed here, [per the CAS maintenance policy](https://apereo.github.io/cas/developer/Maintenance-Policy.html), affects the Apereo CAS server for the following versions:

```
- 7.0.x
- 7.1.x
- 7.2.x
```

If your CAS version is not listed above **AND** is still part of an active maintenance cycle [per the CAS maintenance policy](https://apereo.github.io/cas/developer/Maintenance-Policy.html), then best effort (analysis or confirmation from reporters/testers) indicates that the version is not affected by this issue. That said, please note that per the project's Apache2 license, *software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied*. For additional information, please [see the project license](https://github.com/apereo/cas/blob/master/LICENSE).

If you or your institution is a member of the Apereo foundation with an active support subscription supporting the CAS project, please [contact the CAS subs working group](https://apereo.github.io/cas/Mailing-Lists.html) to learn more about this security vulnerability report.

# Severity

You are effected by this security vulnerability if your CAS deployment passes one of the following requirements:

- Your CAS server is acting as an OpenID Connect identity provider.
- Your CAS server is using WebAuthN as a multifactor authentication provider, responsible for FIDO2 passwordless device registration and authentication.

If your deployment does not pass one of the noted conditions above, there is nothing for you to do here. Keep calm and carry on.

## Denial of Service via OIDC Webfinger Endpoint

The vulnerability is a denial of service (DoS) attack based on a regular expression vulnerability in the OIDC webfinger endpoint. An attacker can send a specifically crafted request to the endpoint, which causes excessive and uncontrolled CPU usage (CWE-400). With the fix, no more DOS could be triggered manually or through a small fuzzing campain.

## Unauthorized Access to User Account via FIDO2 Authentication

This vulnerability allows an attacker to gain unauthorized access to another user's account on a service that uses CAS for authentication. 
The attcker can register a FIDO2 device while modifying the username in the request to that of the victim. This can be done by replacing the register function in the javascript. Then the attacker can use a registered FIDO2 device to log in to the victim's account with the compromissed password, directly through the FIDO main connection. With fixes in place, CAS should validate the username in the FIDO2 registration request and ensure that it matches the authenticated user's username. 

# Timeline

The issue was originally reported on March 17th, 2025 and upon confirmation, CAS releases were patched and eventually published on April 11th, 2025.

# Patching

Patch releases are available to address CAS deployments. Upgrades to the next patch version for each release should be a drop-in replacement.

## Affected Versions

### 7.0.x

Modify your CAS overlay to point to the version `7.0.10.1`.

### 7.1.x

Modify your CAS overlay to point to the version `7.1.6`.

### 7.2.x

Modify your CAS overlay to point to the version `7.2.1`.

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