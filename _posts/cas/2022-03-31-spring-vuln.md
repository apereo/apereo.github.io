---
layout:     post
title:      CAS OpenID Connect Vulnerability Disclosure
summary:    Disclosure of the Spring framework RCE security issue with the Apereo CAS software.
tags:       [CAS]
---

# Overview

This is the version of an [Apereo CAS project vulnerability disclosure](https://apereo.github.io/cas/developer/Sec-Vuln-Response.html), describing an issue in CAS that results in an RCE vulnerability in the Spring framework.

For additional details on how security issues, patches and announcements are handled, please read the [Apereo CAS project vulnerability disclosure](https://apereo.github.io/cas/developer/Sec-Vuln-Response.html) process.

# Affected Deployments

The security issue described here, [per the CAS maintenance policy](https://apereo.github.io/cas/developer/Maintenance-Policy.html), affects the Apereo CAS server for the following versions:

```
- 6.4.x
- 6.5.x
```

If your CAS version is not listed above *AND* is still part of an active maintenance cycle [per the CAS maintenance policy](https://apereo.github.io/cas/developer/Maintenance-Policy.html), then best effort (analysis or confirmation from reporters/testers) indicates that the version is not affected by this issue. That said, please note that per the project's Apache2 license, *software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.*. For additional information, please [see the project license](https://github.com/apereo/cas/blob/master/LICENSE).

If you or your institution is a member of the Apereo foundation with an active support subscription supporting the CAS project, please [contact the CAS subs working group](https://apereo.github.io/cas/Mailing-Lists.html) to learn more about this security vulnerability report.

# Severity

[See this](https://spring.io/blog/2022/03/31/spring-framework-rce-early-announcement).

The specific exploit requires the CAS application to run on Tomcat as a WAR deployment. If CAS is deployed as a Spring Boot executable jar, i.e. the default, it is not vulnerable to the exploit. However, the nature of the vulnerability is more general, and there may be other ways to exploit it.

# Timeline

The issue was originally reported on March 30th, 2022 and upon confirmation, CAS releases were patched on March 31st, 2022 and released on the same day.

# Patching

Patch releases are available to address CAS deployments. Upgrades to the next patch version for each release should be a drop-in replacement.

## Procedure

### 6.4.x

Modify your CAS overlay to point to the version `6.4.6.2`.

### 6.5.x

Modify your CAS overlay to point to the version `6.5.2`.

# Support

Apereo CAS is Apache v2 open source software under the sponsorship of the Apereo Foundation, supported by community volunteers and enthusiasts. Support options may be [found here](https://apereo.github.io/cas/Support.html).

If you or your institution is a member of the Apereo foundation with an active subscription supporting the CAS project, please [contact the CAS subs working group](https://apereo.github.io/cas/Mailing-Lists.html) to learn more about this security vulnerability report.

# Resources

* [CAS Security Vulnerability Response Model](https://apereo.github.io/cas/developer/Sec-Vuln-Response.html)
* [CAS Maintenance Policy](https://apereo.github.io/cas/developer/Maintenance-Policy.html)

On behalf of the CAS Application Security working group,

[Misagh Moayyed](https://fawnoos.com)