---
layout:     post
title:      Apereo CAS - Microsoft Office 365 SAML2 Integration
summary:    Learn how to integrate Microsoft Office 365 with Apereo CAS running as a SAML2 identity provider.
tags:       [CAS,SAML]
---

<div class="alert alert-success">
  <strong>Collaborate</strong><br/>The blog is managed and hosted on GitHub. If you wish to update the contents of this post or if you have found an inaccuracy and wish to make corrections, we recommend that you please submit a pull request to <a href="https://github.com/apereo/apereo.github.io">this repository</a>.
</div>

<div class="alert alert-info">
  <strong>Contributed Content</strong><br/>Paul Spaude of Unicon, Inc was kind enough to contribute this guide.
</div>

Office 365 is a line of subscription services offered by Microsoft, as part of the Microsoft Office product line. As a SAML2 service provider, Office 365  can be integrated with CAS running as a SAML identity provider and this blog post provides a quick walkthrough of how to make that integration possible.

Our starting position is based on the following:

- CAS `5.3.x`
- Java 8
- [Maven Overlay](https://github.com/apereo/cas-overlay-template) (The `5.3` branch specifically)

# Office 365 Configuration

The following resources should come in handy:

- [Azure Active Directory: Single Sign-On SAML protocol](https://docs.microsoft.com/en-us/azure/active-directory/develop/single-sign-on-saml-protocol)
- [Office 365 – Why You Need to Understand ImmutableID](https://blogs.perficient.com/2015/04/01/office-365-why-you-need-to-understand-immutableid/)

Azure Active Directory SAML2 metadata may be [found here](https://nexus.microsoftonline-p.com/federationmetadata/saml20/federationmetadata.xml).

# CAS Configuration

First, ensure that your CAS deployment is equipped to act as a [SAML2 identity provider](https://apereo.github.io/cas/5.3.x/installation/Configuring-SAML2-Authentication.html). Next, you may also use the [JSON Service Registry](https://apereo.github.io/cas/5.3.x/installation/JSON-Service-Management.html) to keep track of the relying-party registration record in JSON definition files.

The JSON file to contain the service provider relying-party record would be as follows:

```json
{
  "@class" : "org.apereo.cas.support.saml.services.SamlRegisteredService",
  "serviceId" : "urn:federation:MicrosoftOnline",
  "name" : "Office365_SP",
  "description" : "Microsoft Office 365 / Azure AD",
  "id" : 10,
  "metadataLocation" : "file:///path/to/WindowsAzureAD-metadata.xml",
  "encryptAssertions" : false,
  "signAssertions" : true,
  "signResponses" : false,
  "requiredNameIdFormat" : "urn:oasis:names:tc:SAML:2.0:nameid-format:persistent",
  "usernameAttributeProvider" : {
    "@class" : "org.apereo.cas.services.PrincipalAttributeRegisteredServiceUsernameProvider",
    "usernameAttribute" : "objectGUID"
  },
  "attributeReleasePolicy" : {
    "@class" : "org.apereo.cas.services.ReturnMappedAttributeReleasePolicy",
    "allowedAttributes" : {
      "@class" : "java.util.TreeMap",
      "userPrincipalName" : "IDPEmail"
    }
  }
}
```

A few things to point out:

- You will need to adjust the `metadataLocation` to match your data and the Office 365 instance.
- Make sure CAS has retrieved the allowed attributes (i.e. `IDPEmail`, `objectGUID` etc) listed in the JSON definition file. This is required in the final generated SAML2 response to create the proper `NameIDFormat` element.
- Make sure the SP metadata has the correct entity id, matching your Office 365 instance address.

# Finale

Thanks to Paul Spaude of Unicon, Inc who was kind enough to share the above integration notes. If you too have an integration with a well-known SAML2 service provider, please consider sharing that guide in form of a blog post here as well.

[Misagh Moayyed](https://fawnoos.com)
