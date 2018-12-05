---
layout:     post
title:      Apereo CAS - HappyFox SAML2 Integration
summary:    Learn how to integrate HappyFox with Apereo CAS running as a SAML2 identity provider.
tags:       [CAS,SAML]
---

<div class="alert alert-success">
  <strong>Collaborate</strong><br/>The blog is managed and hosted on GitHub. If you wish to update the contents of this post or if you have found an inaccuracy and wish to make corrections, we recommend that you please submit a pull request to <a href="https://github.com/apereo/apereo.github.io">this repository</a>.
</div>

HappyFox is an all-in-one help desk ticketing system. As a SAML2 service provider, HappyFox can be integrated with CAS running as a SAML identity provider and this blog post provides a quick walkthrough of how to make that integration possible.

Our starting position is based on the following:

- CAS `5.3.x`
- Java 8
- [Maven Overlay](https://github.com/apereo/cas-overlay-template) (The `5.3` branch specifically)

# HappyFox Configuration

Use [these instructions](https://support.happyfox.com/kb/article/515-using-saml-for-single-sign-on/) to set up HappyFox as a SAML2 service provider.

# CAS Configuration

First, ensure that your CAS deployment is equipped to act as a [SAML2 identity provider](https://apereo.github.io/cas/5.3.x/installation/Configuring-SAML2-Authentication.html). Next, you may also use the [JSON Service Registry](https://apereo.github.io/cas/5.3.x/installation/JSON-Service-Management.html) to keep track of the HappyFox relying-party registration record in JSON definition files.

The JSON file to contain the service provider relying-party record would be as follows:

```json
{
  "@class" : "org.apereo.cas.support.saml.services.SamlRegisteredService",
  "serviceId" : "https://[name].happyfox.com/saml/metadata/",
  "name" : "HappyFox",
  "description": "HappyFox",
  "id" : 1,
  "evaluationOrder" : 1,
  "metadataLocation" : "file:/etc/cas/config/saml/happyfox-metadata.xml",
  "usernameAttributeProvider" : {
    "@class" : "org.apereo.cas.services.PrincipalAttributeRegisteredServiceUsernameProvider",
    "usernameAttribute" : "mail"
  }
}
```

Note that HappyFox does not provide its own SP metadata and you will have to create it youself. The following is example of what that metadata may look like:

```xml
<?xml version="1.0"?>
<md:EntityDescriptor xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"
                     validUntil="2050-12-05T19:27:46Z"
                     cacheDuration="PT604800S"
                     entityID="https://[name].happyfox.com/saml/metadata/">
    <md:SPSSODescriptor AuthnRequestsSigned="false" WantAssertionsSigned="false"
                        protocolSupportEnumeration="urn:oasis:names:tc:SAML:2.0:protocol">
        <md:NameIDFormat>urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress</md:NameIDFormat>
        <md:AssertionConsumerService Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST"
                                     Location="https://[name].happyfox.com/saml/callback/"
                                     index="0" />
    </md:SPSSODescriptor>
</md:EntityDescriptor>
```

A few things to point out:

- You will need to adjust the `serviceId` and `metadataLocation` to match your data and the HappyFox instance.
- Make sure CAS has retrieved the allowed attributes (i.e. `mail` etc) listed in the JSON definition file. This is required in the final generated SAML2 response to create the proper `NameIDFormat` element.
- Make sure the SP metadata has the correct entity id, matching your HappyFox instance address.

# Finale

If you too have an integration with a well-known SAML2 service provider, please consider sharing that guide in form of a blog post here as well.

[Misagh Moayyed](https://twitter.com/misagh84)