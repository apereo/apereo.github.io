---
layout:     post
title:      CAS Vulnerability Disclosure
summary:    Disclosure of a security issue with the CAS software.
tags:       [CAS]
---

# Overview

This is an [Apereo CAS project vulnerability disclosure](https://groups.google.com/a/apereo.org/forum/#!topic/cas-appsec-public/zXqxDN9rB8A), describing an issue in CAS that affects random number generation.

Apereo CAS is using an insecure source of randomness to generate it's password reset URL among other things. This is because Apereo CAS relies upon apache commons lang3 `RandomStringUtils`. From the documentation:

> Caveat: Instances of Random, upon which the implementation of this class relies, are not cryptographically secure.
> https://commons.apache.org/proper/commons-lang/javadocs/api-3.9/org/apache/commons/lang3/RandomStringUtils.html

The following areas and components in CAS make use of `RandomStringUtils` to generate a random number:

- Password reset URL, when CAS Password Management is turned on.
- Generating internal token identifiers when CAS is acting as a simple multifactor authentication provider.
- JWT encryption key generation, when used specifically via the CAS command-line shell.
- Generation of an OAuth user device code
- Generation of anonymous or transient username identifiers

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

Most if not all references to `RandomStringUtils` in CAS are purely used internally and have no significant impact to the security of the deployment or connected integrations. The only *possible* exception might be the generation of password reset urls when the password management functionality is turned on with the assumption that one can craft a reset URL which:

- contains a compromised token that is identical to the one tracked and created by CAS.
- is still valid within the configured expiration timeframe.
- is signed and encrypted using the same keypair shared by CAS.

The significant of this issue is considered low for CAS, though it is recommended that upgrades be carried out to removes any chances of security breaches.

# Patching

Patch releases are available to address relevant CAS deployments. The effectively replaces usages of `RandomStringUtils` for random number generation with one that relies on a more secure strategy. Upgrades to the next patch version for each release should be a drop-in replacement.

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

Modify your CAS overlay to point to the version `6.1.0`. A snippet of a `gradle.properties` for a CAS overlay follows:

```properties
cas.version=6.1.0
```

# Support

CAS is Apache v2 open source software under the sponsorship of the Apereo Foundation, supported by community volunteers and enthusiasts. Support options may be [found here](https://apereo.github.io/cas/Support.html).

# Resources

* [CAS Security Vulnerability Response Model](https://apereo.github.io/cas/developer/Sec-Vuln-Response.html)

On behalf of the CAS Application Security working group,

[Misagh Moayyed](https://twitter.com/misagh84)