---
layout:     post
title:      Apereo CAS - Dances With Protocols
summary:    A short overview of how Apereo CAS may support multiple authentication protocols simultaneously while acting as both the primary identity provider or proxying another. Two Socks could not be reached for comments.
tags:       [CAS]
---

<div class="alert alert-success">
<strong>Collaborate</strong><br/>This blog is managed and hosted on GitHub. If you wish to update the contents of this post or if you have found an inaccuracy and wish to make corrections, we recommend that you please submit a pull request to <a href="https://github.com/apereo/apereo.github.io">this repository</a>.
</div>

I have been consulting on variations of a deployment strategy and use case that involved CAS acting as an identity provider while also presenting the ability to [delegate authentication requests](https://apereo.github.io/cas/development/integration/Delegate-Authentication.html) to an external identity provider and act as a *proxy* in between. I had the erroneous assumption that client applications integrating with CAS in proxy mode must be those that speak the CAS protocol. This meant that while CAS itself may delegate authentication requests to a variety of identity providers that speak SAML2, OAuth2 and CAS protocols, etc the client application that ultimately would receive a response from the proxying CAS server can only understand a service ticket and the particular validation payload compliant with the CAS protocol semantics.

This post is an attempt at explaining my rationale with a follow-up explanation of why I was wrong.

# Delegated Authentication Flow

The *normal* flow for delegated authentication is something like this:

![cas](https://user-images.githubusercontent.com/1205228/36640612-b53abbd2-1a37-11e8-8f95-0179983c4c3e.jpg)

- Client application submits a *CAS Protocol* authentication request to the CAS server.
- CAS Server routes the request to an external identity provider, whether manually or automatically, and processes the response.
- When successful, CAS Server establishes an SSO session, creates a  service ticket and redirects back to the client application with that ticket.
- Client application validates the ticket and understands the user profile elements.

Once the response is processed by the external identity provider, note that the opinion is built into the CAS authentication flow to assume the next steps to be "creating a service ticket" and "redirecting back to the calling service/application with that ticket"; details which are dictated by the CAS protocol and obviously no longer apply if the client application is a SAML SP or OAuth2. 

# So...

If the client application were to submit an authentication request using a protocol other than CAS, it would be only fair for the application to expect a response using the same protocol. But, how could it ever work with the CAS server always issuing *service tickets* and *302-redirecting* back to the application?

# Explanation

It turns out that given the CAS design today, client applications can speak any type of protocol that CAS itself supports today regardless of the authentication flow. For better or worse, this feature has to do with how *secondary* protocols (those other than CAS itself) are implemented.

All *other* [authentication protocols supported by the CAS server](https://apereo.github.io/cas/development/protocol/Protocol-Overview.html) happen to be *clients* of the CAS server itself. The SAML2 module, OAuth2 module and anything else supported in CAS accept the original authentication request at the relevant endpoint, then route that request to the CAS server turning themselves into individual tiny CAS clients. At the end of the day and just like before, the CAS server creates a service ticket and issues a request back to the calling application, which in this case happens to be itself and the relevant endpoint inside itself that is to going to pick up the request and resume.

# The Protocol Dance

Let's start with a client application that speaks SAML2. This client is configured in CAS [as a SAML2 service provider](https://apereo.github.io/cas/development/installation/Configuring-SAML2-Authentication.html), while CAS itself is proxying Facebook as an external identity provider. 

This is a bit of a complicated scenario since you have about three protocols dancing together. The effective flow would be:

- The SAML2 client sends an authentication request to the CAS server.
- The SAML2 module in CAS processes the authentication request, sees the need for authentication and routes the request to the CAS server's login endpoint. Very importantly, it indicates in that request that the calling *service* is the SAML2 module and the endpoint expected to do follow-up processing.
- Just like before, CAS Server routes the request to an external identity provider (Facebook in our case), whether manually or automatically, and processes the (OAuth2) response.
- When successful, CAS Server establishes an SSO session, creates a  service ticket and redirects back to the SAML2 module (a complicated yet humble corner of itself effectively) that now is tasked to produce a SAML2 response.
- The SAML2 module receives the service ticket, validates it and understands the user profile via the provided assertion. It then produces the SAML2 response for the original client application.

<div class="alert alert-warning">
<strong>Possible Gotcha</strong><br/>The above flow <i>may</i> prove to be somewhat dysfunctional, if the delegated/proxied identity provider happens to be ADFS. If your deployment today requires the above flow with ADFS acting as the identity provider, please suspect and verify.</a>.
</div>

# So...

The trick, if I could re-emphasize, is noting that all protocols are clients of the CAS server that interact with it using the CAS protocol. This is done at the request/browser level, as opposed to doing things internally via heavily customized webflows and such that would be entangled with one another. The protocol modules that exist in CAS make zero assumptions about the internal inner workings of the CAS authentication flow/engine. They treat it just like they would an external CAS server; the only difference is, they sit and live inside the CAS server directly and yet they remain completely agnostic of that fact. Simply put in our example, the SAML2 module basically says: "this incoming request needs to be authenticated. So I'll route it to a CAS server for authentication and when it comes back, I'll do my bit".

This surely continues to maintain SSO sessions as well for all follow-up requests, because the CAS server does not care about the calling party; whether external or internal, the SSO session will be established and available for everything else. 

# References

More notes on the design are [available here](https://apereo.github.io/2017/02/17/cas-custom-protocols/). 

# Summary

Remember; the client originating the authentication request can use ANY protocol supported by CAS, so long as CAS is configured to accept and recognize that protocol and regardless of whether CAS is acting as a proxy or directly authenticating the user via its own internal data stores. 

I hope this review was of some help to you and I am sure that both this post as well as the functionality it attempts to explain can be improved in any number of ways. Please feel free to [engage and contribute](https://apereo.github.io/cas/developer/Contributor-Guidelines.html) as best as you can.

[Misagh Moayyed](https://twitter.com/misagh84)