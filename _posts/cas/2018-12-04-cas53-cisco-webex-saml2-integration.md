---
layout:     post
title:      Apereo CAS - Cisco Webex SAML2 Integration
summary:    Learn how to integrate Cisco Webex with Apereo CAS running as a SAML2 identity provider.
tags:       [CAS,SAML]
---

<div class="alert alert-success">
  <strong>Collaborate</strong><br/>The blog is managed and hosted on GitHub. If you wish to update the contents of this post or if you have found an inaccuracy and wish to make corrections, we recommend that you please submit a pull request to <a href="https://github.com/apereo/apereo.github.io">this repository</a>.
</div>

<div class="alert alert-info">
  <strong>Contributed Content</strong><br/>Keith Conger of Colorado College, an active member of the CAS community, was kind enough to contribute this guide.
</div>

Cisco Webex, formerly WebEx Communications Inc., is a company that provides on-demand collaboration, online meeting, web conferencing and videoconferencing applications. As a SAML2 service provider, Cisco Webex can be integrated with CAS running as a SAML identity provider and this blog post provides a quick walkthrough of how to make that integration possible.

Our starting position is based on the following:

- CAS `5.3.x`
- Java 8
- [Maven Overlay](https://github.com/apereo/cas-overlay-template) (The `5.3` branch specifically)

# Cisco Webex Configuration

Download the service provider metadata and upload the CAS identity provider metadata. No other configuration is required.

# CAS Configuration

First, ensure that your CAS deployment is equipped to act as a [SAML2 identity provider](https://apereo.github.io/cas/5.3.x/installation/Configuring-SAML2-Authentication.html). Next, you may also use the [JSON Service Registry](https://apereo.github.io/cas/5.3.x/installation/JSON-Service-Management.html) to keep track of the Cisco Webex relying-party registration record in JSON definition files.

The JSON file to contain the Cisco Webex record would be as follows:

```json
{
  @class: org.apereo.cas.support.saml.services.SamlRegisteredService
  serviceId: ^https://idbroker.webex.com/.*
  name: Cisco Webex
  id: 1
  description: Cisco Webex
  usernameAttributeProvider:
  {
    @class: org.apereo.cas.services.PrincipalAttributeRegisteredServiceUsernameProvider
    usernameAttribute: mail
  }
  attributeReleasePolicy:
  {
    @class: org.apereo.cas.services.ReturnMappedAttributeReleasePolicy
    allowedAttributes:
    [
      @class: java.util.TreeMap
      givenName: [ java.util.ArrayList [ firstName ] ]
      mail: [ java.util.ArrayList [ email ] ]
      sn: [ java.util.ArrayList [ lastName ] ]
      displayName: [ java.util.ArrayList [ displayName ] ]
    ]
  }
  metadataLocation: /path/to/webex-metadata.xml
  signAssertions: true
  skipGeneratingSubjectConfirmationNotBefore: true
  requiredNameIdFormat: urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress
  signResponses: true
}
```

A few things to point out:

- You will need to adjust the `serviceId` and `metadataLocation` to match your data and the Cisco Webex instance.
- Make sure CAS has retrieved the allowed attributes (i.e. `mail`, `givenName`, etc) listed in the JSON definition file.

# Finale

Thanks to Keith Conger of Colorado College who was kind enough to share the above integration notes. If you too have an integration with a well-known SAML2 service provider, please consider sharing that guide in form of a blog post here as well.

[Misagh Moayyed](https://fawnoos.com)
