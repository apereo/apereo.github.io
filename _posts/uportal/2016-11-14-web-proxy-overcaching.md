---
layout:     post
title:      uPortal 2016-11-14 Webproxy Portlet caching vulnerability
summary:    Webproxy Portlet v2 is bugged; upgrade.
tags:       [uPortal]
---

This is a **public disclosure of a security vulnerability**, near the tail end of applying [the uPortal Security Incident Response Plan](https://docs.google.com/document/d/1s-xvqbeHS_EjU6EKlv8ftXgQ-R56CU0tAjuQE3SSH4s/edit) to [this issue](https://issues.jasig.org/browse/WPP-101).

Affected software products:

* Webproxy Portlet , versions `2.0.0` through `2.2.1` . [`2.2.2`](https://github.com/Jasig/WebproxyPortlet/releases/tag/WebProxyPortlet-2.2.2) includes a fix.

Recent uPortal versions ship with bugged Webproxy Portlet versions.

# Problem:

Affected versions

* By default, cache proxied content, and
* Require a source code edit to turn off this default behavior, and
* Improperly compute the cache keys such that in some cases too little information is considered in computing cache keys.

## Consequence:

* Most adopters will not have locally turned off this caching strategy even if it is inappropriate for local usages, and
* Usages where different users proxy the same backing URL may yield improper cross-user cache hits, with user B seeing content proxied for user A.

## Saving graces:

* For security purposes, this only matters if the proxies are interesting, providing personalized content.
* Usages with unique URLs, such as where user attributes are conveyed as request parameters in the URL or the initial request in a typical Proxy CAS integration, will not yield improper cache hits.

# Solutions:

* Upgrade to Webproxy Portlet version `2.2.2` or later.
* Locally modify your Webproxy Portlet 2 implementation to turn off caching, [by](https://github.com/Jasig/WebproxyPortlet/pull/24) de-activating or removing `CachingHttpContentServiceImpl` and instead activating `HttpContentServiceImpl`.

-[Andrew](https://apetro.ghost.io)
