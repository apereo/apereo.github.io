---
layout:     post
title:      CAS Vulnerability Disclosure
summary:    Disclosure of a security issue with the CAS software.
tags:       [CAS]
---

# Overview

This is the initial version of an [Apereo CAS project vulnerability disclosure](https://groups.google.com/a/apereo.org/forum/#!topic/cas-appsec-public/zXqxDN9rB8A), describing an issue in CAS that affects random number generation. This post will be updated with additional details once the grace period has passed.

# Credits

Special thanks to Jonathan Leitschuh for originally reporting the issue to the CAS application security group, and the good folks at [snyk.io](https://snyk.io) who graciously and patiently provided additional guidance and assistance.

# Affected Deployments

The attack vector applies to deployments of the CAS server for the versions:

```
- 5.3.x
- 6.0.x
- 6.1.x
```

Previous CAS versions are considered [EOL](https://apereo.github.io/cas/developer/Maintenance-Policy.html) and are advised to upgrade.

# Severity

Details will be posted here publicly once the [grace period](https://apereo.github.io/cas/developer/Sec-Vuln-Response.html) has passed.

# Patching

Patch releases are available to address CAS deployments. Upgrades to the next patch version for each release should be a drop-in replacement.

## Timeline

The issue was originally reported to the CAS application security team on September 17th, 2019 and upon confirmation, CAS was patched.

## Procedure

### 5.3.x

Modify your CAS overlay to point to the version `5.3.12.1`. A snippet of a `pom.xml` for a CAS overlay follows:

```xml
<dependencies>
    <dependency>
        <groupId>org.apereo.cas</groupId>
        <artifactId>cas-server-webapp</artifactId>
        <version>${cas.version}</version>
        <type>war</type>
        <scope>runtime</scope>
    </dependency>
</dependencies>

<properties>
    <cas.version>5.3.12.1</cas.version>
</properties>
```

### 6.0.x

Modify your CAS overlay to point to the version `6.0.5.1`. A snippet of a `gradle.properties` for a CAS overlay follows:

```properties
cas.version=6.0.5.1
```

### 6.1.x

Modify your CAS overlay to point to the version `6.1.0-RC6`, once released. A snippet of a `gradle.properties` for a CAS overlay follows:

```properties
cas.version=6.1.0-RC6
```

**As of this writing, CAS `6.1` still is in development**. The patch will be available and released per the [CAS release schedule](https://github.com/apereo/cas/milestones). For the time being, you may be able to switch your overlay to point to `6.1.0-RC6-SNAPSHOT` instead.

# Support

CAS is Apache v2 open source software under the sponsorship of the Apereo Foundation, supported by community volunteers and enthusiasts. Support options may be [found here](https://apereo.github.io/cas/Support.html).

# Resources

* [CAS Security Vulnerability Response Model](https://apereo.github.io/cas/developer/Sec-Vuln-Response.html)

On behalf of the CAS Application Security working group,
[Misagh Moayyed](https://twitter.com/misagh84)