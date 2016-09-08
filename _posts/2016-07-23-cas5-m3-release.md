---
layout:     post
title:      CAS 5 M3 Released
summary:    ...in which I present an overview of CAS 5 M3 release.
date:       2016-07-23 12:32:18
categories: cas
---

Based on the [CAS project release schedule](https://github.com/apereo/cas/milestones), today we are execited to announce the 3rd milestone release in the CAS 5 series. There are a [few significant enhancements](https://github.com/apereo/cas/releases/tag/v5.0.0.M3) packed into this release that are worthy to publicize. So here it goes.

Before we get started, it should be pointed out that [such milestone releases of CAS 5 are available to adopters to try](https://github.com/apereo/cas-overlay-template/tree/5.0). Deployers are more than welcome to try out the milestone releases and share feedback.

The current in-development documentation of CAS 5 is also [available here](https://apereo.github.io/cas/development/index.html).

# Type-safe Properties

The [entire collection of CAS settings](https://apereo.github.io/cas/development/installation/Configuration-Properties.html) are now redesigned to take advantage of [Spring Boot's typesafe properties](http://docs.spring.io/spring-boot/docs/current/reference/html/boot-features-external-config.html#boot-features-external-config-typesafe-configuration-properties). These settings are safely mapped to a corresponding `SomeCasComonentProperties` Java class at runtime, support lists, sets and maps and can easily be refactored to contain more than one batch of settings.

As an example, to define LDAP authentication handlers:

{% highlight properties lineanchors %}
...
cas.authn.ldap[0].ldapUrl=ldaps://ldap1.example.edu,...
cas.authn.ldap[0].baseDn=dc=example,dc=org
cas.authn.ldap[0].userFilter=cn={user}
cas.authn.ldap[0].bindDn=cn=Directory Manager,dc=example,dc=org
cas.authn.ldap[0].bindCredential=Password
...
{% endhighlight %}


Additional handlers can be defined by simply incrementing that `0` index.

Furthermore, this release takes on a super comprehensive approach into allowing the adopter to control all aspects of authentication handlers via such typesafe properties. You can now define individual password encoders, principal transformers and password policy settings for a given handler all via the same collection set. No need to resort to any sort of XML configuration file.

Note all that sensitive CAS settings [can be encrypted and secured](https://apereo.github.io/cas/development/installation/Configuration-Properties-Security.html). At runtime, CAS will auto-decrypt settings, making the configuration that much easier to be shared centrally in a central repository of some sort.

There are many other small little enhancements packed into this particular area that remove the need for **explicit** XML configuration. Things such as attribute resolution, PersonDirectory configuration, and more.

As you observe, **ALL** CAS properties are now collected inside a single page on the documentation site; they are no longer spread around here and there. This makes it easier for project developers to maintain them, and for you as deployers to find them all in one spot.

# Bootiful Management Webapp

The CAS management webapp is now bootified. It also boasts support for a few other additinal UI panes and sections that deal with MFA, OIDC, SAML, and more. Work continues to make sure all properties of a given CAS registered service can be configured and controlled via the UI.

{% highlight bash %}
:cas-management-webapp:bootRun
Listening for transport dt_socket at address: 5000


  ____     _     ____    __  __                                                            _   
 / ___|   / \   / ___|  |  \/  |  __ _  _ __    __ _   __ _   ___  _ __ ___    ___  _ __  | |_
| |      / _ \  \___ \  | |\/| | / _` || '_ \  / _` | / _` | / _ \| '_ ` _ \  / _ \| '_ \ | __|
| |___  / ___ \  ___) | | |  | || (_| || | | || (_| || (_| ||  __/| | | | | ||  __/| | | || |_
 \____|/_/   \_\|____/  |_|  |_| \__,_||_| |_| \__,_| \__, | \___||_| |_| |_| \___||_| |_| \__|
                                                      |___/                                    

{% endhighlight %}

# Dependency Upgrades

This milestone builds on top of some significant dependency upgrades that include:

- Spring Boot 1.4 *
- Ldaptive 1.2 *
- Pac4j 1.9.1

(*) These components are today in `RC` or `SNAPSHOT` mode, and will be switched to their appropriate `GA` release prior to the official CAS 5 release.

I am most excited about Pac4j 1.9.1, which allows CAS easier support for delegated social authentication to:

- Github
- Dropbox
- Yahoo!
- FourSquare
- Windows Live
- Google Plus

# Digest AuthN

Taking advantage of Pac4j 1.9, CAS now presents support for [Digest authentication](https://apereo.github.io/cas/development/installation/Digest-Authentication.html) as another form of non-interactive authentication.

# WS-Fed Encrypted Assertions

In this milestone, the WS-FED CAS module starts to support encrypted assertions issued by ADFS. This change is also ported to the `4.2.x` release line.

# Authy OTP MFA

Finally, CAS adds [Authy](https://www.authy.com) to its collection of supported MFA providers. At this time, support is limited to [Authy's OTP REST API](https://apereo.github.io/cas/development/installation/AuthyAuthenticator-Authentication.html). Given community demand and interest, support for Authy's OneTouch API may be worked out in the future.

# What's Next?

The development team is working hard to make sure the CAS 5 release is right on [schedule](https://github.com/apereo/cas/milestones).

This is likely the last milestone for v5. As the milestones schedule shows, the project will be preparing for its first release candidate in about a month. Please keep an eye out for further announcements.

# How can you help?

- Start your early [CAS 5 deployment](https://github.com/apereo/cas-overlay-template/tree/5.0) today. Try out features and [share feedback](https://apereo.github.io/cas/Mailing-Lists.html).
- Better yet, [contribute patches](https://apereo.github.io/cas/developer/Contributor-Guidelines.html).
- Review and suggest documentation improvements.
- Review the release schedule and make sure you report your desired feature requests on the project's issue tracker.

# Das Ende

A big hearty thanks to all who participated in the development of this release to submit patches, report issues and suggest improvements. Keep'em coming!

[Misagh Moayyed](https://twitter.com/misagh84)
