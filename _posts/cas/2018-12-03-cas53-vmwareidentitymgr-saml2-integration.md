---
layout:     post
title:      Apereo CAS - VMware Identity Manager SAML2 Integration
summary:    Learn how to integrate VMware Identity Manager with Apereo CAS running as a SAML2 identity provider.
tags:       [CAS]
---

<div class="alert alert-success">
  <strong>Collaborate</strong><br/>The blog is managed and hosted on GitHub. If you wish to update the contents of this post or if you have found an inaccuracy and wish to make corrections, we recommend that you please submit a pull request to <a href="https://github.com/apereo/apereo.github.io">this repository</a>.
</div>

<div class="alert alert-info">
  <strong>Contributed Content</strong><br/>Keith Conger of Colorado College, an active member of the CAS community, was kind enough to contribute this guide.
</div>

VMware Identity Manager is identity management for the mobile cloud era that delivers on consumer-simple expectations like one-touch access to nearly any app, from any device, optimized with AirWatch Conditional Access. As a SAML2 service provider, VMware Identity Manager can be integrated with CAS running as a SAML identity provider and this blog post provides a quick walkthrough of how to make that integration possible.

Our starting position is based on the following:

- CAS `5.3.x`
- Java 8
- [Maven Overlay](https://github.com/apereo/cas-overlay-template) (The `5.3` branch specifically)

# VMware Identity Manager Configuration

- Register CAS as an identity provider

<img width="1100" src="https://user-images.githubusercontent.com/1205228/49401590-d9c07a00-f704-11e8-9f65-3813a078d924.png">

- Configure authentication methods:

<img width="1000" alt="screen shot 2018-11-27 at 3 01 55 pm" src="https://user-images.githubusercontent.com/1205228/49401739-49cf0000-f705-11e8-8c7b-c862f69f7d63.png">

# CAS Configuration

First, ensure that your CAS deployment is equipped to act as a [SAML2 identity provider](https://apereo.github.io/cas/5.3.x/installation/Configuring-SAML2-Authentication.html). Next, you may also use the [JSON Service Registry](https://apereo.github.io/cas/5.3.x/installation/JSON-Service-Management.html) to keep track of the VMware Identity Manager relying-party registration record in JSON definition files.

The JSON file to contain the VMware Identity Manager registration record would be as follows:

```json
{
  @class: org.apereo.cas.support.saml.services.SamlRegisteredService
  serviceId: your-vmware-idm-entity-id
  name: VMware Identity Manager
  id: 1
  description: VMware Identity Manager
  attributeReleasePolicy:
  {
    @class: org.apereo.cas.services.ReturnMappedAttributeReleasePolicy
    allowedAttributes:
    [
      @class: java.util.TreeMap
      givenName: [ java.util.ArrayList [ firstName ] ]
      mail: [ java.util.ArrayList [ email ] ]
      sAMAccountName: [ java.util.ArrayList [ userName ] ]
      sn: [ java.util.ArrayList [ lastName ] ]
      userPrincipalName: [ java.util.ArrayList [ userPrincipalName ] ]
    ]
  }
  metadataLocation: /path/to/vmware-idm.xml
  signAssertions: true
  skipGeneratingSubjectConfirmationNotBefore: true
  signResponses: true
}
```

A few things to point out:

- You will of course need to adjust the `serviceId` and `metadataLocation` to match your data and VMware Identity Manager instance.
- Make sure CAS has retrieved the allowed attributes (i.e. `mail`, `givenName`, etc) listed in the JSON definition file.

# Finale

Thanks to Keith Conger of Colorado College who was kind enough to share the above integration notes. If you too have an integration with a well-known SAML2 service provider, please consider sharing that guide in form of a blog post here as well.

[Misagh Moayyed](https://twitter.com/misagh84)