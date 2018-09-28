---
layout:     post
title:      CAS Vulnerability Disclosure
summary:    Disclosure of a security issue with the MFA features.
tags:       [CAS]
---

# Overview

This is the public version of an [Apereo CAS project vulnerability disclosure](https://groups.google.com/a/apereo.org/forum/#!topic/cas-appsec-public/zXqxDN9rB8A), describing an issue in CAS
where an adversary may be able to bypass the second factor (token) although MFA is requested during the login process.

This issue applies to all MFA providers **except the Duo provider** (which is therefore NOT vulnerable).


# Affected Deployments

The attack vector applies to all deployments of the CAS server for the versions:

- 5.3.0, 5.3.1 and 5.3.2
- lower or equal to 5.2.6.

If you have deployed the version 5.3.0, 5.3.1 or 5.3.2, you **MUST** upgrade to the version 5.3.3.

If you have deployed a version lower or equal to version 5.2.6, you **MUST** upgrade to the version 5.2.7.


# Severity

This is a serious issue where successfully exercising this vulnerability allows the adversary
to bypass the second factor (token) required by the MFA policy.
This makes any MFA configuration to re-inforce security completely useless.


# Patching

Patch releases are available to address CAS vulnerable deployments.
Upgrades to the next patch version for each release should be a drop-in replacement.
The patch simply ensures that the MFA factor (token) is effectively required when MFA is requested.


## Timeline

The issue was originally reported to the CAS application security team on August, 2018 and upon confirmation, CAS was patched.


## Procedure

Modify your CAS overlay to point to the version `5.2.7` or `5.3.3`. A snippet of a `pom.xml` for a CAS overlay follows:

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
    <cas.version>5.3.3</cas.version>
</properties>
```


# Support

If you have questions on the details of this vulnerability and how it might be reproduced,
please contact `security@apereo.org` or `cas-appsec-public@apereo.org`.


# Resources

* [Original Announcement](https://groups.google.com/a/apereo.org/forum/#!topic/cas-appsec-public/zXqxDN9rB8A)
* [CAS Security Vulnerability Response Model](https://apereo.github.io/cas/developer/Sec-Vuln-Response.html)

[Jérôme LELEU](https://github.com/leleuj)
