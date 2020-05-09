---
layout:     post
title:      Apereo CAS - SAML2 Metadata Overrides
summary:    Learn how to manage SAML2 service provider registrations in CAS and override metadata artifacts on a per-application basis.
tags:       [CAS]
---

<div class="alert alert-success">
<strong>Collaborate</strong><br/>This blog is managed and hosted on GitHub. If you wish to update the contents of this post or if you have found an inaccuracy and wish to make corrections, we recommend that you please submit a pull request to <a href="https://github.com/apereo/apereo.github.io">this repository</a>.
</div>

# Overview

One of the more recent additions to CAS, as a SAML2 identity provider, is the ability to override the identity provider metadata and keys on a per-service basis. This capability has been extended to support all identity provider metadata sources and storage services
beyond the typical file system. To keep things simple in this blog post, we are going to focus on a sample SAML2 service provider integration
backed by CAS as a SAML2 identity provider whose metadata (and all other overrides) are managed by the filesystem.

Our starting position is based on:

- CAS `6.2.x`
- Java `11`
- [CAS WAR Overlay](https://github.com/apereo/cas-overlay-template)

# The Basics

Start with the [CAS Overlay](https://github.com/apereo/cas-overlay-template), clone the project and follow [the notes here](https://apereo.github.io/cas/development/installation/Configuring-SAML2-Authentication.html) to get CAS acting as SAML2 identity provider. In its simplest form, it comes to 
down to the following settings:

```properties
cas.authn.saml-idp.entityId=https://sso.example.org/idp
cas.authn.saml-idp.scope=example.org
cas.authn.saml-idp.metadata.location=file:/etc/cas/config/saml
```

...and this module in the CAS build:

```gradle
implementation "org.apereo.cas:cas-server-support-saml-idp:${project.'cas.version'}"
```

Note how identity provider artifacts such as metadata and keys are backed by the filesystem and stored inside the `/etc/cas/config/saml`:

```bash
$ ls /etc/cas/saml/ 

Permissions Size User   Group Date Modified Name 
-------------------------------------------------
.rw-r--r--  1.1k Misagh wheel  1 Dec 17:45  idp-encryption.crt
.rw-r--r--  1.7k Misagh wheel  1 Dec 17:45  idp-encryption.key
.rw-r--r--  8.1k Misagh wheel  1 Dec 17:45  idp-metadata.xml
.rw-r--r--  1.1k Misagh wheel  1 Dec 17:45  idp-signing.crt
.rw-r--r--  1.7k Misagh wheel  1 Dec 17:45  idp-signing.key
```

Next, we could use [JSON service registry](https://apereo.github.io/cas/development/services/JSON-Service-Management.html) to manage 
our SAML2 service provider definitions. Here is what our service definition might look like for 
SAML2 service provider in a `SAML-1.json` file:

```json
{
  "@class": "org.apereo.cas.support.saml.services.SamlRegisteredService",
  "serviceId": "sp.example.org",
  "name": "Example",
  "id": 1,
  "evaluationOrder": 1,
  "metadataLocation": "/sample/metadata/sp-metadata.xml"
}      
```

# Overrides

Let's say our service provider wanted to use a different set of signing keys, encryption keys or metadata completely separate from the global SAML2 
artifacts listed above. Since we are using the filesystem, these overriding artifacts are expected to be found at `/etc/cas/config/saml/Example`. The formula is, you should create a directory using the name of your service definition (i.e. `Example`) and this directly should be created inside the canonical global SAML2 metadata directory. 

```bash
$ tree /etc/cas/saml/
/etc/cas/saml/
├── Example
│   ├── idp-encryption.crt
│   ├── idp-encryption.key
│   ├── idp-metadata.xml
│   ├── idp-signing.crt
│   └── idp-signing.key
├── idp-encryption.crt
├── idp-encryption.key
├── idp-metadata.xml
├── idp-signing.crt
└── idp-signing.key
``` 

Note that you do not have to override every single certificate and/or artifact. Depending on the use case, you may be quite selective in choosing
the appropriate file for overrides. The bottom line is, if an override is found for a service provider it would be used in combination with everything else.
If there are no overrides, then the global artifact would be used for the requested operation.

Furthermore, note that the `/idp/metadata` endpoint does also accept a `service` parameter either by entity id or numeric identifier. This parameter
is matched against the CAS service registry allowing the endpoint to calculate and combine any identity provider metadata overrides that may have been specified.

# So...

I hope this review was of some help to you and I am sure that both this post as well as the functionality it attempts to explain can be improved in any number of ways. Please know that all other use cases, scenarios, features, and theories certainly [are possible](https://apereo.github.io/2017/02/18/onthe-theoryof-possibility/) as well. Feel free to [engage and contribute](https://apereo.github.io/cas/developer/Contributor-Guidelines.html) as best as you can.

Finally, if you benefit from Apereo CAS as free and open-source software, we invite you to [join the Apereo Foundation](https://www.apereo.org/content/apereo-membership) and financially support the project at a capacity that best suits your deployment. If you consider your CAS deployment to be a critical part of the identity and access management ecosystem and care about its long-term success and sustainability, this is a viable option to consider.

Happy Coding,

[Misagh Moayyed](https://fawnoos.com)
