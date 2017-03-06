---
layout:     post
title:      CAS Vulnerability Disclosure
summary:    Disclosure of a security issue with the CAS administrative endpoints exposure.
---

# Overview

This is the public version of an Apereo CAS project vulnerability disclosure describing an issue in CAS
where an adversary may be able to bypass certain administrative endpoints, in spite of
CAS access rule in place. The following administrative endpoints are exposed
and vulnerable to this attack:

- `/configserver/`
- `/cas/status/metrics`

# Affected Deployments

The attack vector specifically applies to all deployments of CAS `5.0.x` deployments.
If you have deployed **any version** of CAS `5.0.x`, you **MUST** take action to upgrade.
If you have deployed any **other** versions of CAS, disregard this announcement.

# Severity

This is a serious issue where successfully exercising this vulnerability allows the adversary
gain insight into the running CAS software, collect stats and metrics and potentially observe the collection
of configured CAS settings in configuration files.

# Patching

Patch releases are available to address CAS `5.0.x` deployments.
Upgrades to the next patch version for each release should be a drop-in replacement.
The patch simply ensures that the exposed endpoints honor the CAS access rules,
and otherwise block attempts. When you have applied the patch, please double check all endpoints
and ensure access is appropriately controlled.

## Timeline

The issue was originally reported to the CAS application security team
on February 20, 2017. Upon confirmation, CAS was patched on February 22, 2017
and released. The original release
announcement is [available here](https://github.com/apereo/cas/releases/tag/v5.0.3.1).

## Procedure

### Update Version

Modify your CAS overlay to point to version `5.0.3.1`. A snippet of a `pom.xml` for a CAS overlay follows:

```xml
<dependencies>
    <dependency>
        <groupId>org.jasig.cas</groupId>
        <artifactId>cas-server-webapp</artifactId>
        <version>${cas.version}</version>
        <type>war</type>
        <scope>runtime</scope>
    </dependency>
</dependencies>

<properties>
    <cas.version>5.0.3.1</cas.version>
</properties>
```

Double check your `cas.properties` file for the following setting:

```properties
# cas.adminPagesSecurity.ip=the-authorized-ip-pattern
```

### Adjust Overlay

If your CAS build has overlaid the `src/main/resources/bootstrap.properties` file, 
make sure the following line is corrected there:

```properties
spring.cloud.config.server.prefix=/status/configserver
```

## Alternatives

If you are unable to apply the patch, it's then best to ensure the outlined
endpoints are blocked completely via load balancers, proxies, firewalls, etc.

# Support

If you have questions on the details this vulnerability and how it might be reproduced,
please contact `security@apereo.org` or `cas-appsec-public@apereo.org`.

# Resources

* [CAS Security Vulnerability Response Model](https://apereo.github.io/cas/developer/Sec-Vuln-Response.html)
