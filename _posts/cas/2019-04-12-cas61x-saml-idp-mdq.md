---
layout:     post
title:      Apereo CAS 6.1.x - SAML2 Metadata Query Protocol
summary:    Learn how you may configure Apereo CAS to fetch and validate SAML2 metadata for service providers from InCommon's MDQ server using the metadata query protocol.

tags:       [CAS]
---

<div class="alert alert-success">
<strong>Collaborate</strong><br/>This blog is managed and hosted on GitHub. If you wish to update the contents of this post or if you have found an inaccuracy and wish to make corrections, we recommend that you please submit a pull request to <a href="https://github.com/apereo/apereo.github.io">this repository</a>.
</div>

# Overview

Per-entity metadata allows CAS acting as a SAML2 identity provider to consume only metadata for specific service providers as needed instead of having to load the entire XML aggregate. Metadata is delivered through a protocol called MDQ ("Metadata Query" resulting in a significantly lower memory footprint in addition to quicker startup times by not having to verify the entirety of the XML aggregate at startup.

In this blog post, we will take a look at [InCommon MDQ server](https://spaces.at.internet2.edu/display/MDQ/The+Guide) and how Apereo CAS may be configured to fetch and validate service provider metadata on demand using MDQ and family.

<div class="alert alert-warning">
<strong>Preview Phase</strong><br/>The signing certificate (public key) for the Technology Preview version of this service may be changed with little notice. The production public key and its certificate will be stable and long-lived.
</div>

Our starting position is based on:

- CAS `6.1.x`
- Java `11`
- [CAS WAR Overlay](https://github.com/apereo/cas-overlay-template)
- [JSON Service Registry](https://apereo.github.io/cas/development/services/JSON-Service-Management.html)

# Configuration

Once you have configured CAS to act as a [SAML2 identity provider](https://apereo.github.io/cas/development/installation/Configuring-SAML2-Authentication.html), the following service definition can be a reasonable starting template for fetching service provider metadata from InCommon's MDQ server:

```json
{
  "@class" : "org.apereo.cas.support.saml.services.SamlRegisteredService",
  "serviceId" : ".+",
  "name" : "SAMLMDQ",
  "id" : 1,
  "requireSignedRoot": true,
  "evaluationOrder" : 1000,
  "metadataSignatureLocation": "file:/etc/cas/incommon-mdq.pem",
  "metadataLocation" : "http://mdq-preview.incommon.org/entities/{0}"
}
```

The `serviceId` field above indicates that all SAML2 service provider entity ids are recognized and accepted by CAS so long metadata associated with entity ids can be found and fetched from the MDQ server.

<div class="alert alert-info">
<strong>Evalaution Order</strong><br/>If you have more than one metadata provider, you will want to carefully examine the <code>evaluationOrder</code> of the above service definition to make sure it executes after all other metadata providers. If you do not do this, CAS will try to fetch your static entities from InCommon each time it is requested before falling back to your static metadata providers.
</div>

So if you could imagine that a service provider with the entity id of `https://studypages.com/saml-sp` sends an authentication request to CAS, the following picture is what you should expect:

![image](https://user-images.githubusercontent.com/1205228/56044562-47ecfd00-5cf4-11e9-9bc2-dd0794135d8d.png)

Not the prettiest picture in the world for sure, and with a little bit of CSS magic it can be as glamorous as you could want.

# So...

I hope this review was of some help to you and I am sure that both this post as well as the functionality it attempts to explain can be improved in any number of ways. Please know that all other use cases, scenarios, features, and theories certainly [are possible](https://apereo.github.io/2017/02/18/onthe-theoryof-possibility/) as well. Feel free to [engage and contribute](https://apereo.github.io/cas/developer/Contributor-Guidelines.html) as best as you can.

Happy Coding,

[Misagh Moayyed](https://twitter.com/misagh84)