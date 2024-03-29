---
layout:     post
title:      CAS Groovy Vulnerability Disclosure
summary:    Disclosure of a security issue with the Apereo CAS software when using Groovy.
tags:       [CAS]
---

# Overview

This is an [Apereo CAS project vulnerability disclosure](https://apereo.github.io/cas/developer/Sec-Vuln-Response.html),
describing an issue in CAS when using Groovy. If you are not using Groovy in your CAS deployment to process data, there is nothing for you to do here. Keep calm and carry on.

For additional details on how security issues, patches and announcements are handled, please read the [Apereo CAS project vulnerability disclosure](https://apereo.github.io/cas/developer/Sec-Vuln-Response.html) process.

# Credits

This issue was originally reported, researched and tested by [Georgia Tech](https://www.gatech.edu/)'s Enterprise Application and Identity teams. Georgia Tech was kind enough to thoroughly investigate the issue, discuss the problem and their research results in detail, finance the time spent on developing fixes and follow up with additional tests to verify fixes. Thank you!

# Affected Deployments

The problem addressed here, [per the CAS maintenance policy](https://apereo.github.io/cas/developer/Maintenance-Policy.html), affects the Apereo CAS server for the following versions:

```
- 6.5.x
- 6.6.x
```

If your CAS version is not listed above **AND** is still part of an active maintenance cycle [per the CAS maintenance policy](https://apereo.github.io/cas/developer/Maintenance-Policy.html), then best effort (analysis or confirmation from reporters/testers) indicates that the version is not affected by this issue. That said, please note that per the project's Apache2 license, *software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied*. For additional information, please [see the project license](https://github.com/apereo/cas/blob/master/LICENSE).

If you or your institution is a member of the Apereo foundation with an active support subscription supporting the CAS project, please [contact the CAS subs working group](https://apereo.github.io/cas/Mailing-Lists.html) to learn more about this security vulnerability report.

# Severity

The issue affects all uses of Groovy in CAS, but in particular, embedded/inline groovy scripts and specially those that create or release attributes. Because Groovy scripts are precompiled, cached and reused, under super heavy load and given concurrent requests, a groovy script can be interrupted half way through its processing, and change its context from one request/payload to another. In other words, two simultaneous concurrent requests may cause a Groovy script to start off with one batch of input attributes and data, and finish up with another batch that belongs to a second request/user. As a result, it's possible (depending on the app) that user X might log into application A and be recognized as user Y because X and Y were processed by the same Groovy script (that produces attributes) at the same exact time, down to the (milli/nano)second.

# Timeline

The issue was originally reported on August 23rd, 2023 and upon confirmation, CAS releases were patched and published on August 30th, 2023.

# Patching

Patch releases are available to address CAS deployments. Upgrades to the next patch version for each release should be a drop-in replacement.

## Procedure

### 6.5.x

Modify your CAS overlay to point to the version `6.5.9.3`.

### 6.6.x

Modify your CAS overlay to point to the version `6.6.11`.

# Support

Apereo CAS is Apache v2 open source software under the sponsorship of the Apereo Foundation, supported by community volunteers and enthusiasts. Support options may be [found here](https://apereo.github.io/cas/Support.html).

If you or your institution is a member of the Apereo foundation with an active subscription supporting the CAS project, please [contact the CAS subs working group](https://apereo.github.io/cas/Mailing-Lists.html) to learn more about this security vulnerability report.

# Resources

* [CAS Security Vulnerability Response Model](https://apereo.github.io/cas/developer/Sec-Vuln-Response.html)
* [CAS Maintenance Policy](https://apereo.github.io/cas/developer/Maintenance-Policy.html)

On behalf of the CAS Application Security working group,

[Misagh Moayyed](https://fawnoos.com)