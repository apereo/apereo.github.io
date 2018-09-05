---
layout:     post
title:      Apereo CAS - dotCMS SAML2 Integration
summary:    Learn how to integrate dotCMS, a Content Management System and Headless CMS, with Apereo CAS running as a SAML2 identity provider.
tags:       [CAS]
---

<div class="alert alert-success">
  <strong>Collaborate</strong><br/>The blog is managed and hosted on GitHub. If you wish to update the contents of this post or if you have found an inaccuracy and wish to make corrections, we recommend that you please submit a pull request to <a href="https://github.com/apereo/apereo.github.io">this repository</a>.
</div>

<div class="alert alert-info">
  <strong>Contributed Content</strong><br/>Keith Conger of Colorado College, an active member of the CAS community, was kind enough to contribute this guide.
</div>

dotCMS is an open source content management system (CMS) written in Java for managing content and content-driven sites and applications. As a SAML2 service provider, dotCMS can be integrated with CAS running as a SAML identity provider and this blog post provides a quick walkthrough of how to make that integration possible.

Our starting position is based on the following:

- CAS `5.3.x`
- Java 8
- [Maven Overlay](https://github.com/apereo/cas-overlay-template) (The `5.3` branch specifically)

# Configuration

First, ensure that your CAS deployment is equipped to act as a [SAML2 identity provider](https://apereo.github.io/cas/5.3.x/installation/Configuring-SAML2-Authentication.html). Next, you may also use the [JSON Service Registry](https://apereo.github.io/cas/5.3.x/installation/JSON-Service-Management.html) to keep track of the dotCMS relying-party registration record in JSON definition files.

The JSON file to contain the dotCMS registration record would be as follows:

```json
{
  @class: org.apereo.cas.support.saml.services.SamlRegisteredService
  serviceId: your-dotcms-entity-id
  name: dotCMS
  id: 1
  description: dotCMS Content Mangement System
  attributeReleasePolicy:
  {
    @class: org.apereo.cas.services.ReturnAllowedAttributeReleasePolicy
    attributeFilter:
    {
      @class: org.apereo.cas.services.support.RegisteredServiceMutantRegexAttributeFilter
      patterns:
      {
        @class: java.util.LinkedHashMap
        memberOf: (?<=CN=)([^,]+)->$1
      }
    }
    allowedAttributes:
    [
      java.util.ArrayList
      [
        mail
        givenName
        memberOf
        sn
      ]
    ]
  }
  metadataLocation: https://path.to.your.dotcmscloud.com/dotsaml/metadata/3dd4ad1e-e2ab-492e-a428-87af35d341fd
  signAssertions: true
  skipGeneratingSubjectConfirmationNotBefore: true
  signResponses: true
}
```

A few things to point out:

- You will of course need to adjust the `serviceId` and `metadataLocation` to match your data and dotCMS instance.
- Make sure the `AssertionConsumerService` endpoint in the dotCMS metadata contains the ` urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect` binding.
- Make sure CAS has retrieved the allowed attributes (i.e. `mail`, `givenName`, etc) listed in the JSON definition file.
- Regarding the `memberOf` attribute, the values fetched from the directory are typically in the format of `CN=WebAdmin,OU=something,OU=something,DC=somewhere,DC=edu`. The service provider requires only the `CN` portion of the attribute value where CAS would need to produce `<saml2:AttributeValue>WebAdmin</saml2:AttributeValue>` instead of `<saml2:AttributeValue>CN=WebAdmin,OU=something,OU=something,DC=somewhere,DC=edu</saml2:AttributeValue>`. This bit is handled via the `RegisteredServiceMutantRegexAttributeFilter` element in the JSON file.

# Finale

Thanks to Keith Conger of Colorado College who was kind enough to share the above integration notes. If you too have an integration with a well-known SAML2 service provider, please consider sharing that guide in form of a blog post here as well.

[Misagh Moayyed](https://twitter.com/misagh84)