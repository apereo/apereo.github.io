---
layout:     post
title:      CAS Vulnerability Disclosure
summary:    Disclosure of a security issue with the CAS software.
tags:       [CAS]
---

# Overview

This is the initial version of an [Apereo CAS project vulnerability disclosure](https://apereo.github.io/cas/developer/Sec-Vuln-Response.html), describing an issue 
in CAS that affects surrogate authentication and impersonation.

This post will be updated with additional details once the grace period has passed.

# Affected Deployments

The attack vector applies to deployments of the CAS server for the following versions:

```    
- 5.3.x
- 6.0.x
- 6.1.x
```

# Severity

It is recommended that upgrades be carried out to removes any chances of security breaches.

# Patching

Patch releases are available to address CAS deployments. Upgrades to the next patch version for each release should be a drop-in replacement.

## Timeline

The issue was originally reported to the CAS application security team on December 18th, 2019 and upon confirmation, CAS was patched on December 20th.

## Procedure

### 5.3.x

Modify your CAS overlay to point to version `5.3.15`. A snippet of a `pom.xml` for a CAS overlay follows:

```xml
<properties>
    <cas.version>5.3.15</cas.version>
</properties>
```      

### 6.0.x

Modify your CAS overlay to point to the version `6.0.8`. A snippet of a `gradle.properties` for a CAS overlay follows:

```properties
cas.version=6.0.8
```

### 6.1.x

Modify your CAS overlay to point to the version `6.1.3`. A snippet of a `gradle.properties` for a CAS overlay follows:

```properties
cas.version=6.1.3
```

### 6.2.x

Modify your CAS overlay to point to the version `6.2.0-RC2`, *when released*. A snippet of a `gradle.properties` for a CAS overlay follows:

```properties
cas.version=6.2.0-RC2
```

# Support

CAS is Apache v2 open source software under the sponsorship of the Apereo Foundation, supported by community 
volunteers and enthusiasts. Support options may be [found here](https://apereo.github.io/cas/Support.html).

# Resources

* [CAS Security Vulnerability Response Model](https://apereo.github.io/cas/developer/Sec-Vuln-Response.html)
* [CAS Maintenance Policy](https://apereo.github.io/cas/developer/Maintenance-Policy.html)

On behalf of the CAS Application Security working group,

[Misagh Moayyed](https://fawnoos.com)
