---
layout:     post
title:      CAS 5 RC1 Release
summary:    ...in which I present an overview of CAS 5 RC1 release.
date:       2016-08-26 12:32:18
categories: cas
---

Based on the [CAS project release schedule](https://github.com/apereo/cas/milestones), today we are excited to announce the first release candidate in the CAS 5 series. There are a [few enhancements](https://github.com/apereo/cas/releases/tag/v5.0.0.RC1) packed into this release that are worthy to publicize. So here it goes.

Before we get started, it should be pointed out that [releases of CAS 5 are available to adopters to try](https://github.com/apereo/cas-overlay-template/tree/5.0). Deployers are more than welcome to try these out and share feedback.

The current documentation of CAS 5 is also [available here](https://apereo.github.io/cas/development/index.html).

# OpenID Connect

OIDC support in CAS gets a number of improvements and bug fixes thanks to [Jérôme](https://github.com/leleuj).

# Google reCAPTCHA

Over the years, there have been several requests on the mailing list asking for guidance to enable a CAS integration with Google's reCAPTCHA. While [a recipe](https://wiki.jasig.org/display/CASUM/Integrating+reCaptcha+with+CAS) existed for enabling this feature for older CAS versions, over time it'd gotten rusty. In this release, CAS starts to support [Google's reCAPTCHA](https://apereo.github.io/cas/development/integration/Configuring-Google-reCAPTCHA.html) natively. Just like with all other features, there will be no need to modify
the CAS login webflow or any other configuration file. Include the relevant module, and provide your settings for reCAPTCHA.

<blockquote class="imgur-embed-pub" lang="en" data-id="a/DBIcr"><a href="//imgur.com/DBIcr"></a></blockquote><script async src="//s.imgur.com/min/embed.js" charset="utf-8"></script>

[This article](http://news.softpedia.com/news/google-recaptcha-cracked-in-new-automated-attack-502677.shtml) may be of further interest to you.

# Default Redirect URL

What happens when users accidentally and incorrectly bookmark the `https://sso.example.org/cas/login` url? They get to the CAS login page, authenticate and then are greeted with a warm welcoming message that redirects them to nowhere important. Phone calls and support tickets flood IT services reporting that CAS or this/that application are broken.

That's no fun.

So to accommodate this briefly, CAS starts to support a default redirect URL to which you can redirect your audience if no target application is specified upon authentication. The URL can be just about anywhere, as long as you have authorized and registered it correctly. In most cases, it's a redirect to some sort of portal page that lists all services integrated with CAS.

# Case Insensitive Attribute Release

So you have set up CAS to retrieve attributes from your LDAP server and decided to retrieve the attribute `givenName`. You then register a few services and design them such that they would be allowed to receive `givenName`, yet nothing is released. Your logs show `givenName` is found and your LDAP queries and browsers all show that attribute has a valid value and all the right permissions are set. What's happening? Is CAS secretly biased against that attribute?

Some LDAP servers seem to change the case of the attribute name when they pass it back to the requesting application. CAS may submit `givenName`, yet it receives `givenname`. When the application asks for attributes CAS looks at the associated attribute policy and finds that it's authorized to release `givenName`, yet the actual principal has no such attribute! It only has `givenname`. As a result, the application gets nothing.

To accommodate this scenario, CAS starts to treat attributes that are specified in attribute release policies in a case insensitive manner. With this change, CAS may ask for `givenName` and the LDAP server is free to return `givenname`, `GIVENNAME` or a hyper-emo version of it, `gIvEnNaMe`. At release time, since case no longer matters the application will correctly receive `givenName`.

If it matters that much, note that you can always control the exact case of the attribute released as well and override the CAS behavior.

Also note that this behavior is applicable to all sources from which you retrieve
attributes. It's not limited to LDAP though the issue described most commonly
affects LDAP.

# Geoprofiling Authentication Requests

How do you block what you may consider a suspicious authentication attempt? For instance, you may wish to disallow requests from certain locations or IP addresses or even fancier, you may want those requests to pass through multifactor authentication for extra security.

As a variant of [adaptive authentication](https://apereo.github.io/cas/development/installation/Configuring-Adaptive-Authentication.html) and starting with this release candidate CAS allows you to geoprofile authentication requests and then based on your devised rules, reject those or force them through a particular multifactor provider. Geoprofiling can be achieved via Maxmind or GoogleMaps, both of which are services that **require a paid subscription** for full API usage.

# Groovy, maaan!

Furthermore, CAS starts to support [attribute release](https://apereo.github.io/cas/development/integration/Attribute-Release-Policies.html#groovy-script) via
the Groovy programming language. In short, you can specify a groovy script
that is executed upon attribute resolution and/or release to dynamically
and programmatically decide which application should receive a selection
of attributes.

Note that attribute resolution could always be done via Groovy. This bit is not new.
We have just made the configuration of it a whole easier. Also note that in CAS, attribute resolution is a separate process from attribute release. You can mix and match options that are available for both.

Needless to say, the script is all Groovy and and is capable of executing
any kind of operation the Groovy language itself is able to support.

# Spring Cloud: Vault & MongoDb

CAS adds support for [Vault](https://www.vaultproject.io)
and MongoDb, as options that may be used to
house [CAS configuration](https://apereo.github.io/cas/development/installation/Configuration-Management.html).

# DuoSecurity WebSDK 2.3

Thanks to contributions from DuoSecurity, the Duo WebSDK module is now
bumped to `2.3`.

# Front Channel SLO

While it has been and still is somewhat of an experimental feature,
this release candidate improves the CAS front-channel single logout functionality.
CAS attempts to collect applications that are defined to use front-channel logout and
will use a bit of fancy javascript to contact each endpoint to pass along the logout notification request.
The payload and syntax of the request is identical to the current back-channel logout, and status of each
request is tracked and displayed in the user interface.

# SAML2 SP Integrations

Now that CAS 5 starts to support the SAML2 protocol, you gotta ask: what
if we could extend the auto-configuration strategy to provide built-in SP
integrations? That is, much like anything else, you should be able to declare what
your SP metadata is, what attributes it requires and so on in a simple `.properties`
file. CAS should auto-register the SP and take care of all the other technical details.

Right?

Right! With this release, CAS starts to support the following [SP Integrations](https://apereo.github.io/cas/development/integration/Configuring-SAML-SP-Integrations.html)
out of the box:

- Dropbox
- Box
- Salesforce
- SAManage
- ServiceNow
- PowerFAIDS Net Partner
- Workday
- WebEx
- Office365

These are generally SPs for which the SAML2 integration recipe is quite simple.
As we progress forward, we hope to start collecting more and more
of such SPs, specially those that are more visible and used by the wider
community often, such that we can **configure once, run everywhere** rather than
document it repeatedly, maintain it separately and repeat it for every deployment
forever.

If you have SP suggestions, please feel free to share.

# Audit Log

In certain cases and depending on the nature of the request, CAS would produce
an `audit:unknown` in the audit log. Thanks to [Dima](https://github.com/dima767),
this behavior is corrected to ensure the audit log can produce a valid user id
for all cases.

# Logging Dashboard

CAS starts to allow its administrators, permissions granting, to observe logging configuration and view log outputs in real time. This is done via the magic of Web Sockets, where
CAS and the browser establish a light-weight TCP connection to stream log data.

Here are a few screenshots:

<blockquote class="imgur-embed-pub" lang="en" data-id="a/a2vUk"><a href="//imgur.com/a2vUk"></a></blockquote><script async src="//s.imgur.com/min/embed.js" charset="utf-8"></script>

# Custom Error Pages

Thanks to the magic of Spring Boot, CAS starts to present customized error
pages based on http error codes. You can for instance design a simple `401.html`
to explain the error to your users better. Error pages can be defined in form
of series as well, such as `5xx.html`.

Here are a few screenshots:

<blockquote class="imgur-embed-pub" lang="en" data-id="a/jGMeo"><a href="//imgur.com/jGMeo"></a></blockquote><script async src="//s.imgur.com/min/embed.js" charset="utf-8"></script>


# Password Management

Starting with this release, CAS provides very modest [password management capabilities](https://apereo.github.io/cas/development/installation/Password-Policy-Enforcement.html).
This is an optional feature which allows users to change their password in-place
when CAS detects an authentication failure due to a rejected password. LDAP is supported
as a backend option for managing the account password, though you could always extend
CAS to provide your own implementations of password management services for various backends.

Note that this feature is off by default and without it, you simply get today's CAS experience
which is a link redirecting to your own password management tool.

Here are a few screenshots:

<blockquote class="imgur-embed-pub" lang="en" data-id="a/RMC7j"><a href="//imgur.com/RMC7j"></a></blockquote><script async src="//s.imgur.com/min/embed.js" charset="utf-8"></script>

# What's Next?

The development team is working to make sure the CAS 5 release is on [schedule](https://github.com/apereo/cas/milestones).

At this point, all new development has been frozen and project is solely focusing on testing the release candidate and applying bug fixes based on community reports. There will likely be other release candidates but short of any major incidents or changes, the CAS 5 GA release should be available right on schedule.

# How can you help?

- Start your early [CAS 5 deployment](https://github.com/apereo/cas-overlay-template/tree/5.0) today. Try out features and [share feedback](https://apereo.github.io/cas/Mailing-Lists.html).
- Better yet, [contribute patches](https://apereo.github.io/cas/developer/Contributor-Guidelines.html).
- Review and suggest documentation improvements.
- Review the release schedule and make sure you report your desired feature requests on the project's issue tracker.

# Das Ende

A big hearty thanks to all who participated in the development of this release to submit patches, report issues and suggest improvements. Keep'em coming!

[Misagh Moayyed](https://twitter.com/misagh84)
