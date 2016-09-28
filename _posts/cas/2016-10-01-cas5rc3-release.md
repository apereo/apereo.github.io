---
layout:     post
title:      CAS 5 RC3 Released
summary:    ...in which I present an overview of CAS 5 RC3 release.
---

We are excited to announce the 3rd release candidate in the CAS 5 series. There are a [few  items](https://github.com/apereo/cas/releases/tag/v5.0.0.RC3) packed into this release that are worthy to publicize. So here it goes.

Before we get started, it should be pointed out that [releases of CAS 5 are available to adopters to try](https://github.com/apereo/cas-overlay-template/tree/5.0). Deployers are more than welcome to try out the milestone releases and share feedback.

The current in-development documentation of CAS 5 is also [available here](https://apereo.github.io/cas/development/index.html).

# MFA

A series of patches have been applied to address issues related to multi-factor authentication:

- Activating MFA based on multi-valued principal attributes
- Activating MFA for non-interactive authentication flows such as SPNEGO

# Password Management

The CAS self-service password management functionality is patched to better report back password policy requirements on the screen, and changes have gone in to ensure password updates can successfully be executed against Active Directory.

# Delegated AuthN

Summary of fixes are:

- Better reporting of authentication failures in case a provider (i.e. Facebook) denies user access.
- Better management of locating resources through CAS properties, specially when dealing with delegated SAML AuthN.

# Admin UIs

Some adjustments have been made to the way admin user interfaces are protected via CAS itself. A few additional screens have also been worked into interface to display the CAS audit log as well as a list of trusted devices registered for MFA bypass.

# JWT AuthN

Thanks to Pac4J, A number of fixes have gone to ensure JWTs can successfully be validated based on customizable encryption and signing algorithms, which can now be specified for a given CAS service definition. Additional checks are also in place to report on the validity of the JWT itself and its required fields.

# Dependency Upgrades

We have taken a pass at the core CAS dependencies to ensure we are running on the latest stable component releases, some of which include:

- Spring Core
- Spring Boot
- Spring Cloud
- Thymeleaf
- Pac4J
- Hazelcast

...and plenty more.

# What's Next?

Short of a few more last rounds to ensure everything is tested as much as possible. The release schedule will likely be adjusted to note the correct final release date, and when all is said and done, there will be a few planning sessions to discuss the project roadmap for the next upcoming release.

There is plenty of work left to do!

# How can you help?

Do NOT wait for the final GA release to begin your deployment. If you do discover a problem after the GA is out, it may be a while for you to receive the next upgrade with the fix in place. Now is the best time to start trying out the release candidates and report back findings. The software is only as stable and bug-free as it is reported back community members!


- Start your early [CAS 5 deployment](https://github.com/apereo/cas-overlay-template/tree/5.0) today. Try out features and [share feedback](https://apereo.github.io/cas/Mailing-Lists.html).
- Better yet, [contribute patches](https://apereo.github.io/cas/developer/Contributor-Guidelines.html).
- Review and suggest documentation improvements.
- Review the release schedule and make sure you report your desired feature requests on the project's issue tracker.


# Das Ende

A big hearty thanks to all who participated in the development of this release to submit patches, report issues and suggest improvements. Keep'em coming!

[Misagh Moayyed](https://twitter.com/misagh84)
