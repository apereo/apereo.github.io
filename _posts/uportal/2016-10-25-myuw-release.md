---
layout:     post
title:      MyUW 2016-10-25 release
summary:    A modest MyUW release
tags:       [uPortal, Releases]
---

Today MyUW promoted a new release to production. This post highlights some aspects of this.

Edits:

+ Updated to reflect new name `uPortal home` and new git repository location for what was once called `AngularJS-portal`

## This release

[This release](https://kb.wisc.edu/myuw/page.php?id=68015) upgraded MyUW to `uPortal home` [v5.4.1](https://github.com/uPortal-project/uportal-home/releases/tag/angularjs-portal-parent-5.4.1) from [v5.2.4](https://github.com/uPortal-project/uportal-home/releases/tag/angularjs-portal-parent-5.2.4).

## Highlights for Apereo community

+ Continued implementation of [Material Design][]. Piggybacking on Google's Material Design in higher education web applications is an opportunity to raise the baseline for design and consistency without having to invent and maintain that design guidance using scarce higher education resources. To the extent feasible, we're trying to use MyUW design resources on unique-to-MyUW design problems rather than on web-application-general design problems. Also, Material Design theming is rocking the skinning problem, supporting different color treatments across the many Wisconsin system campuses MyUW serves.
+ Continued development of lightweight notifications technology. Notifications now have optional associated actions and more options for priority treatment and end-user option to dismiss unneeded notifications.

### Lessons to learn

+ Semantic versioning is important. We had a hiccup in this release because a `rest-proxy` change wasn't backwards-compatible as regards `endpoints.properties`. In retrospect, the properties file configuring this product *is* its API so breaking changes would be better signaled with a `MAJOR` version change (and avoided when not strictly necessary).
+ Deep linking is important, enabling better communication about and leverage of content in your portal. This release fixed support for deep links into `uPortal home` content.


## Calls to action

### Talk about what you are doing. 

It is only possible to discover opportunities to collaborate, to share code, to compare notes on the practices of portals in higher education if we talk about what we are doing.


### Adopt and collaborate on microservices. 

You don't have to adopt everything MyUW has adopted to find something that would add value to your local projects.

+ [KeyValueStore][]
+ [rest-proxy][]
+ [Token Crypt](https://github.com/UW-Madison-DoIT/token-crypt) : A project that can encrypt/decrypt tokens and files using public/private key pairs.

Likewise, maybe you've got some microservice projects and products we could be collaborating on if we knew about them.

### Adopt `uPortal home`. 

[uPortal home][] is a modern user experience layer to plop down in front of your uPortal. 

* You don't have to adopt it all at once, for everyone, for every user experience in your portal. MyUW variously implemented it as opt-in, opt-out, at certain hostnames, for certain identities, for certain experiences within MyUW. It's been a long walk using the new technology for more and more experiences, and we're still using the traditional uPortal rendering pipeline to render some maximized portlet user experiences. `uPortal home` is engineered to be flexible because it had to be.
* You don't have to stay stuck on AngularJS 1. We too want to migrate forward to AngularJS2, when time and technology allow.


[Andrew Petro](http://apetro.ghost.io/)


[uPortal home]: https://github.com/uPortal-project/uportal-home
[KeyValueStore]: https://github.com/UW-Madison-DoIT/KeyValueStore
[rest-proxy]: https://github.com/UW-Madison-DoIT/rest-proxy
[Material Design]: https://material.google.com/
