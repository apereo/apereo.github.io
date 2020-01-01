---
layout:     post
title:      Shibbolizing Apereo CAS
summary:    Learn about a rather fancy Apereo CAS server deployment, sitting behind the Shibboleth Service Provider.
tags:       [CAS,SAML]
---

This is a brief overview that explains how to *shibbolize* the Apereo CAS server; that is to let the CAS server be *protected* by an instance of the [Shibboleth Service Provider](https://shibboleth.net/products/service-provider.html), where the SP is then tasked to delegate authentication requests to a remote SAML2 identity provider. The entire SAML2 interaction is kept between the SP and the IdP while CAS on the return trip eventually picks up the user profile from the SP in form of special headers, etc.

# But...Why?

This is a very elaborate setup, yes. The goal originally was to let CAS simply and directly delegate authentication requests to the SAML2 identity provider. [This can very easily be done](https://apereo.github.io/2017/03/22/cas51-delauthn-tutorial/), *except* that in this particular case the SAML2 identity provider only supported a very specific and rather complicated variation of the SAML2 protocol, whose support is absent in CAS today. Convincing the identity provider to provide support for the more-mainstream *SAML2 WebSSO Browser Profile* led to a path riddled with uncertainties. After further analysis, we came to the conclusion that implementing built-in support for the IdP-supported SAML2 profile variation in CAS is unnecessarily complicated, needlessly expensive and possibly soon-to-be obsolete.

Of course, [it is certainly possible to do](https://apereo.github.io/2017/02/18/onthe-theoryof-possibility/). If you have to ask: all you need is love, coffee and access to decent hair conditioning products. 

So the path to least resistance turned out to be a deployment with a few additional components and with a clear separation of boundaries. Thanks to Docker and outstanding help from colleagues, we managed to get this working. 

Read on.

# How

Starting out with a proof of concept, we came up with a dockerized deployment as such: 

- CAS Server `5.1.0-SNAPSHOT`, running inside an embedded Apache Tomcat
- [Shibboleth Service Provider for Apache](https://wiki.shibboleth.net/confluence/display/SHIB2/Installation)
- Apache Web Server
- A sample CASified PHP application
- [Shibboleth Identity Provider](https://wiki.shibboleth.net/confluence/display/IDP30) `3.4.x` running inside Jetty

Shy of a pretty sequence diagram, here's how the interaction between the above components works:

1. Client browser attempts to access the sample CASified PHP application.
2. Requests to the CAS `/login` endpoint are intercepted by the SP and Apache.
3. The SP, configured to speak the special SAML2 protocol, routes the request to the IdP.
4. The IdP accepts user credentials and posts back the response to the SP.
5. The SP *passes* the response back to the CAS `/login` endpoint.
6. CAS is configured to *trust* the response and proceeds to extract user profile data from the request.
7. CAS proceeds to issue an `ST` for the PHP application that initiated the request.
8. Having received and validated the `ST`, user is granted entry to the PHP application.

# CAS

We also applied a few minor patches to CAS:

- Ensure CAS could easily lend itself to be intercepted by Apache when running in embedded mode.
- Ensure user profile data can correctly be recognized from the SP.
- Ensure attributes collected from the SP can be merged and combined with CAS' own, in cases where supplementary attribute sources are directly defined inside CAS.

The *trusted* authentication piece [is already handled by CAS](https://apereo.github.io/cas/development/installation/Trusted-Authentication.html) today.

# How Do I...?

All patches are contributed back to the CAS project. You are most welcome! :-)

# So...

Special thanks to [@jtgasper3](https://github.com/jtgasper3) for beautifully cementing the deployment foundation of each component via Docker, big kudos to [@scalding](https://github.com/scalding) for making the integration magic work seamlessly and to [@apetro](https://github.com/apetro) for having previously worked on the *trusted* authentication piece in CAS.

Of course, I intend to take all the credit.

[Misagh Moayyed](https://fawnoos.com)
