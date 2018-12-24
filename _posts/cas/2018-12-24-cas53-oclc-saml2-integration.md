---
layout:     post
title:      Apereo CAS - Cranium Cafe SAML2 Integration
summary:    Learn how to integrate Cranium Cafe with Apereo CAS running as a SAML2 identity provider.
tags:       [CAS,SAML]
---

<div class="alert alert-success">
  <strong>Collaborate</strong><br/>The blog is managed and hosted on GitHub. If you wish to update the contents of this post or if you have found an inaccuracy and wish to make corrections, we recommend that you please submit a pull request to <a href="https://github.com/apereo/apereo.github.io">this repository</a>.
</div>

<div class="alert alert-info">
  <strong>Contributed Content</strong><br/>Paul Spaude of Unicon, Inc was kind enough to contribute this guide.
</div>

Cranium Cafe is a virtual teleconferencing platform that creates a simple, mobile in-office appointment. As a SAML2 service provider, it can be integrated with CAS running as a SAML identity provider and this blog post provides a quick walkthrough of how to make that integration possible.

Our starting position is based on the following:

- CAS `5.3.x`
- Java 8
- [Maven Overlay](https://github.com/apereo/cas-overlay-template) (The `5.3` branch specifically)

# CAS Configuration

First, ensure that your CAS deployment is equipped to act as a [SAML2 identity provider](https://apereo.github.io/cas/5.3.x/installation/Configuring-SAML2-Authentication.html). Next, you may also use the [JSON Service Registry](https://apereo.github.io/cas/5.3.x/installation/JSON-Service-Management.html) to keep track of the relying-party registration record in JSON definition files.

The JSON file to contain the service provider relying-party record would be as follows:

```json
{
  "@class" : "org.apereo.cas.support.saml.services.SamlRegisteredService",
  "serviceId" : "https://my.craniumcafe.com/login/saml2",
  "name" : "CraniumCafe",
  "id" : 1,
  "metadataLocation" : "https://my.craniumcafe.com/login/saml2_metadata",
  "encryptAssertions" : false,
  "signAssertions" : false,
  "signResponses" : true,
  "attributeReleasePolicy": {
    "@class": "org.apereo.cas.services.ReturnMappedAttributeReleasePolicy",
    "allowedAttributes": {
      "@class": "java.util.TreeMap",
      "eduPersonScopedAffiliation": "groovy { return attributes['eduPersonAffiliation'].get(0) + '@example.org' }"
      "displayName": "displayName",
      "mail": "mail",
      "eduPersonPrincipalName": "groovy { return attributes['eduPersonPrincipalName'].get(0) + '@example.org' }"
    }
  }
}
```

A few things to point out:

- You will need to adjust the `metadataLocation` to match your instance.
- Make sure CAS has retrieved the allowed attributes (i.e. `eduPersonPrincipalName`, `mail` etc) listed in the JSON definition file.
- Make sure the SP metadata has the correct entity id, matching the instance.

# Finale

Thanks to Paul Spaude of Unicon, Inc who was kind enough to share the above integration notes. If you too have an integration with a well-known SAML2 service provider, please consider sharing that guide in form of a blog post here as well.

[Misagh Moayyed](https://twitter.com/misagh84)