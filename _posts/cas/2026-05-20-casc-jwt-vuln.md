---
layout:     post
title:      Java CAS Client JWT Vulnerability Disclosure
summary:    Disclosure of a security issue with the Java CAS Client validating JWTs.
tags:       [CAS]
---

# Overview

This is an [Apereo CAS project vulnerability disclosure](https://apereo.github.io/cas/developer/Sec-Vuln-Response.html),
describing an issue in the Java CAS Client while validating tickets issued as JWT.

For additional details on how security issues, patches and announcements are handled, please read the [Apereo CAS project vulnerability disclosure](https://apereo.github.io/cas/developer/Sec-Vuln-Response.html) process.

# Credits

This issue was reported to the project by a third-party researcher and was then further validated tested by Mr. Jérôme Leleu, who is a project member and an active committer.

Thank you everyone!

# Affected Deployments

If you have an application that uses the Java CAS client to intergrate with a CAS server and is configured to accept and validate JWTs from that server, you are affected and do need to upgrade. If this condition does not pass for your application deployments, there is nothing for you to do here. Keep calm and carry on.

If you or your institution is a member of the Apereo foundation with an active support subscription supporting the CAS project, please [contact the CAS subs working group](https://apereo.github.io/cas/Mailing-Lists.html) to learn more about this security vulnerability report.

# Timeline

The issue was originally reported on May 2nd 2026, and upon confirmation, Java CAS client releases were patched and eventually published on May 20th, 2026.

# Patching

Upgrade your applications to use Java CAS client's version `4.1.1`.

# Support

Apereo CAS is Apache v2 open source software under the sponsorship of the Apereo Foundation. Support options may be [found here](https://apereo.github.io/cas/Support.html).

If you or your institution is a **member** of the Apereo foundation with an **active CAS subscription** supporting the CAS project, please [contact the CAS subs working group](https://apereo.github.io/cas/Mailing-Lists.html) to learn more about this security vulnerability.

# Resources

* [CAS Security Vulnerability Response Model](https://apereo.github.io/cas/developer/Sec-Vuln-Response.html)
* [CAS Maintenance Policy](https://apereo.github.io/cas/developer/Maintenance-Policy.html)
* [CAS Mailing Lists](https://apereo.github.io/cas/Mailing-Lists.html)

On behalf of the CAS Application Security working group,

[Misagh Moayyed](https://fawnoos.com)
