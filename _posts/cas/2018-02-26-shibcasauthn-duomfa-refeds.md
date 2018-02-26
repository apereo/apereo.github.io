---
layout:     post
title:      Apereo CAS - REFEDS MFA Profile with shib-cas-authn3
summary:    An overview of the shib-cas-authn3 project and its support for the REFEDS MFA profile with both the Shibboleth Identity Provider and Apereo CAS lending a hand.
tags:       [CAS]
---

<div class="alert alert-success">
<strong>Collaborate</strong><br/>This blog is managed and hosted on GitHub. If you wish to update the contents of this post or if you have found an inaccuracy and wish to make corrections, we recommend that you please submit a pull request to <a href="https://github.com/apereo/apereo.github.io">this repository</a>.
</div>

This is a short story on the birth of the [shib-cas-authn3 plugin](https://github.com/Unicon/shib-cas-authn3) and its newfound support for the [REFEDS MFA Profile](https://refeds.org/profile/mfa).

# Overview

Though nowadays less so, you may have an IAM deployment composed of both an [Apereo CAS Server](https://github.com/apereo/cas) and a [Shibboleth Identity Provider](https://www.shibboleth.net/). The original premise for managing such a deployment dates back to days where CAS v3 had [almost] no support for the SAML2 protocol and likewise, the Shibboleth Identity Provider v2 lacked support for the CAS protocol. To accommodate all integration needs, institutions deployed both solutions and then set in pursuit of a way to close the space between the two to provide a seamless user experience.

...and by seamless, I mean:

- How could one manage SSO sessions between the two platforms?
- How could one fetch and release attributes to SAML2 SPs?
- How could one handle single logout?
- How would the user interface elements behave with regards to SAML2 MDUI?
- ...

# Viola!

So was born the [shib-cas-authn3 plugin](https://github.com/Unicon/shib-cas-authn3). The plugin simply acts as a link between the two platforms, allowing authentication requests from the Shibboleth IdP to be routed “invisibly” to CAS and then back. Conceptually it sits between the two systems, (though physically it lives inside the IdP), and knows how to translate one protocol (SAML2) to another (CAS) and then does it all in reverse order on the trip back to the SAML service provider.

![untitled](https://user-images.githubusercontent.com/1205228/36662801-d91e9aa6-1af4-11e8-9206-7f4b88632173.png)

This is a neat trick because to the SAML2 Service Provider, that fact that authentication from the IdP is delegated to somewhere else is entirely irrelevant. Likewise, the Shibboleth IdP also does not care what external authentication system handles and honors that request. All it cares about is, “I routed the request to X. As long as X gives me back the right stuff, I should be fine to resume”.

## Author's Note

I say *nowadays less so* because today, the Shibboleth IdP v3 has great [support for the CAS protocol](https://wiki.shibboleth.net/confluence/display/IDP30/CasProtocolConfiguration) and Apereo CAS v5 has native [support for the SAML2 Protocol](https://apereo.github.io/cas/development/installation/Configuring-SAML2-Authentication.html). While "separation of concerns", "leaving each to its own" and having "boxes and arrows" pointing back and forth and living in perfect harmony in a pretty diagram are excellent conditions to live by, it would be best to consolidate down to one system since the concerns are no longer separate and more so, they tend to cost money and strands of hair quite a bit over time.

Given the right circumstances and support, [the Majestic Monolith](https://m.signalvnoise.com/the-majestic-monolith-29166d022228) can be sweet.

# Handling REFEDS MFA Profile

So then comes the REFEDS MFA Profile:

> This Multi-Factor Authentication (MFA) Profile specifies requirements that an authentication event must meet in order to communicate the usage of MFA. It also defines a SAML authentication context for expressing this...

And:

> The MFA Authentication Context can be used by Service Providers to request that Identity Providers perform MFA as defined below and by IdPs to notify SPs that MFA was used.

In more complicated terms, if a SAML SP were to specify `https://refeds.org/profile/mfa` as the required authentication context, the identity provider would need to translate and find the appropriate MFA solution to execute in order to satisfy that requirement and then reassuringly convey the result back to the SP.

How could we do this with the Shibboleth Identity Provider, Apereo CAS server, and the shib-cas-authn3 plugin all having their bit of fun in the flow?

# One Solution

Consider the following starting positions:

- Since Apereo CAS is ultimately in charge of executing authentication, it would also be the party in charge of executing multifactor authentication.
- Our strategy for delivering MFA in response to `https://refeds.org/profile/mfa` would be one backed by Duo Security, [easily supported by CAS](https://apereo.github.io/2018/01/08/cas-mfa-duosecurity/).

Our task list then would be to find ways to:

- ...communicate the requested authentication context to CAS.
- ...translate the requested authentication context to something CAS would understand as a trigger for Duo Security MFA.
- ...ensure the requested authentication context is satisfied by CAS, before handing off a response to the SP.

Say hello to [shib-cas-authn3](https://github.com/Unicon/shib-cas-authn3#handling-refeds-mfa-profile) v.3.2.4.

<div class="alert alert-info">
<strong>Collaborate</strong><br/>As of this writing, <code>3.2.4</code> is still in beta. Download, deploy, verify and contribute back enhancements as time and DNA permits.
</div>

Staring with `3.2.4`, the plugin has native support for REFEDS MFA profile. The requested authentication context class that is `https://refeds.org/profile/mfa` is passed along from the Shibboleth IdP over to this plugin and is then translated to a multifactor authentication strategy supported by and configured CAS (i.e. Duo Security). The CAS server is notified of the required authentication method via a special `authn_method` parameter by default. Once a service ticket is issued and plugin begins to validate the service ticket, it will attempt to ensure that the CAS-produced validation payload contains and can successfully assert the required/requested authentication context class.

For additional info on configuring the plugin, please see [the project's README](https://github.com/Unicon/shib-cas-authn3#handling-refeds-mfa-profile).

# Summary

I hope this review was of some help to you and I am sure that both this post as well as the functionality it attempts to explain can be improved in any number of ways. Please feel free to [engage and contribute](https://apereo.github.io/cas/developer/Contributor-Guidelines.html) as best as you can.


[Misagh Moayyed](https://twitter.com/misagh84)