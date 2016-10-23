---
layout:     post
title:      CAS Vulnerability Disclosure
summary:    Disclosure of a security issue with the CAS administrative endpoints exposure.
---

# Overview

This is the public version of an [Apereo CAS project vulnerability disclosure](https://groups.google.com/a/apereo.org/d/msg/cas-announce/Xt-quYhBV7w/oCpvF0caCAAJ), describing an issue in CAS
where an adversary may be able to bypass certain administrative endpoints, in spite of
CAS access rule in place. The following administrative endpoints are exposed
and vulnerable to this attack:

- `/statistics/ping`
- `/statistics/threads`
- `/statistics/metrics`
- `/statistics/healthcheck`
- `statistics/ssosessions` and all sub endpoints

The nature of the vulnerability is such that an adversary is able to bypass CAS security rules
to get to the above endpoints.

# Affected Deployments

The attack vector specifically applies to all deployments of CAS `v4.2.x` deployments.
If you have deployed **any version** of CAS 4.2.x, you **MUST** take action to upgrade.
If you have deployed any **other** versions of CAS, disregard this announcement.

# Severity

This is a serious issue where successfully exercising this vulnerability allows the adversary
gain insight into the running CAS software, collect running threads, DOS the server repeatedly
via `ping`s and potentially observe the collection of active SSO sessions and meddle with user single sign-on activity.

# Patching

Patch releases are available to address CAS `v4.2.x` deployments.
Upgrades to the next patch version for each release should be a drop-in replacement.
The patch simply ensures that the exposed endpoints honor the CAS access rules,
and otherwise block attempts. When you have applied the patch, please double check all endpoints
and ensure access is appropriately controlled.

## Timeline

The issue was originally reported to the CAS application security team
on September 27, 2016. Upon confirmation, CAS was patched on September 28, 2016
and released. The original release
announcement is [available here](https://groups.google.com/a/apereo.org/d/msg/cas-announce/Xt-quYhBV7w/oCpvF0caCAAJ).

## Procedure

Modify your CAS overlay to point to version `4.2.6`. A snippet of a `pom.xml` for a CAS overlay follows:

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
    <cas.version>4.2.6</cas.version>
</properties>
```

Double check your `cas.properties` file for the following setting:

```properties
# cas.securityContext.adminpages.ip=127\.0\.0\.1
```

Make sure the correct IP pattern is authorized to access admin pages.

## Alternatives

If you are unable to apply the patch, it's then best to ensure the outlined
endpoints are blocked completely via load balancers, proxies, firewalls, etc.

# Support

If you have questions on the details this vulnerability and how it might be reproduced,
please contact `security@apereo.org` or `cas-appsec-public@apereo.org`.

# Resources

* [Original Announcement](https://groups.google.com/a/apereo.org/d/msg/cas-announce/Xt-quYhBV7w/oCpvF0caCAAJ)
* [CAS Security Vulnerability Response Model](https://apereo.github.io/cas/developer/Sec-Vuln-Response.html)
