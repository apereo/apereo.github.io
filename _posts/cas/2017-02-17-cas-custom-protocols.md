---
layout:     post
title:      Design CAS-Enabled Custom Protocols 
summary:    Learn how to design and mass-promote your very own custom authentication protocol, get rich quickly, stay healthy indefinitely and reach a new state of enlightenment in a few very easy steps. 
tags:       [CAS]
---

![](https://cloud.githubusercontent.com/assets/1205228/23062372/c06e1e1a-f51a-11e6-8e5a-60692af7728c.jpg)

That's right. If you enjoy designing your own authentication protocols, integration strategies and workflows and then face the requirement of letting your Apereo CAS deployment support them, you have come to the right place. This is a guide for you.

Today, [Apereo CAS](https://apereo.github.io/cas) presents itself as a multilingual platform supporting protocols such as CAS, SAML2, OAuth2 and OpenID Connect. There are even [plans and projections](https://github.com/apereo/cas/issues/2340) to provide support for the necessary parts of the `WS-*` protocol stack. Support and functionality for each of these protocols continually improves per every iteration and release of the software thanks to excellent community feedback and adoption. While almost all such protocols are similar in nature and intention, they all have their own specific bindings, parameters, payload and security requirements. So, in order for you to understand how to add support for yet another protocol into CAS, it's very important that you first begin to study and understand how existing protocols are supported in CAS. The strategy you follow and implement will most likely be very similar.

It all starts with something rather trivial: The Bridge. Pay attention. This one actually does go somewhere.

# The Bridge

If you have ever deployed the [ShibCas AuthN plugin](https://github.com/Unicon/shib-cas-authn3) to *bridge* the gap between the Shibboleth IdP and Apereo CAS, then you are very familiar with this pattern. The plugin simply acts as a link between the two platforms, allowing authentication requests from the IdP to be routed "invisibly" to CAS and then back. It sits between the two platforms and knows how to translate one protocol (SAML) to another (CAS) and then does it all in reverse order on the trip back to the SAML service provider.

This is a neat trick because to the SAML Service Provider, that fact that authentication from the IdP is delegated to somewhere else is entirely irrelevant and unimportant. Likewise, the IdP also does not care what external authentication system handles and honors that request. All it cares about is, "I routed the request to X. As long as X gives me back the right stuff, I should be fine to resume".

So the bridge for the most part is the "control tower" of the operation. It speaks both languages and protocols, and just like any decent translator, it knows about the quirks and specifics of each language and as such is able to dynamically translate the technical lingo.

So far, so good.

# CAS Supported Protocols

If you understand the above strategy, then you would be glad to learn that almost all protocols supported by CAS operate with the same exact intentions. A given CAS deployment is equipped with an embedded “plugin” that knows how to speak SAML2 and CAS, OAuth2 and CAS, or OpenID Connect and CAS or whatever. The right-hand side of that equation is always CAS when you consider, as an example, the following authentication flow with an OAuth2-enabled client application:

1. The CAS deployment has turned on the OAuth2 plugin.
2. An OAuth2 authorization request is submitted to the relevant CAS endpoint.
3. The OAuth2 plugin verifies the request and translates it to a CAS authentication request!
4. The authentication request is routed to the relevant CAS login endpoint.
5. User authenticates and CAS routes the flow back to the OAuth2 plugin, having issued a service ticket for the plugin.
6. The OAuth2 plugin attempts to validate that ticket to retrieve the necessary user profile and attributes.
7. The OAuth2 plugin then proceeds to issue the right OAuth2 response by translating and transforming the profile and validated assertions into what the client application may need.

## Notes 

1. The right-hand side of the flow is always CAS, because the plugin always translates protocol requests into CAS requests. 
2. Another way of looking at it is that all protocol plugins and modules are themselves clients of the CAS server! They are issued service tickets and they proceed to validate them just like any other CAS-enabled client.
3. Just like above, to the OAuth2-enabled client all such details are totally transparent and as long as “the right stuff” is produced back to the client, it shall not care.

## Advantages

There are some internal technical and architectural advantages to this approach. Namely:

1. The core of the CAS authentication engine, flow and components need not be modified at all. After all, we are just integrating yet another client even if it’s embedded directly in CAS itself. (If you recall and are familiar, the original Clearpass integration via authentication proxying worked in very similar terms).
2. ...and because of that, support for that protocol can be very easily removed, if needed. After all, protocols come and go every day. That’s why you’re reading this blog post, right?!
3. ...and because of that and just like any other CAS client, all features of the CAS server are readily available and translated to the relevant client removing the need to duplicate and re-create protocol-specific configuration as much as  possible. Things like access strategies, attribute release, username providers, etc.

## Challenges

This process is rather difficult to get right, because just like any other decent translator, you do have to learn and speak both languages just-in-time. The plugin module needs to be designed generically and with a reasonable degree of abstraction such that it can dynamically insert itself into the right core areas of CAS without getting too entangled in the internal architecture.

# Your Road to Fame

So if you mean to build support for your very own authentication protocol, you’d do well to follow in the same footsteps. Take inspiration from the approach that current plugins and modules implement and design your own plugin that itself is the client of the CAS server hosting and housing it.

Happy Designing.

[Misagh Moayyed](https://fawnoos.com)
