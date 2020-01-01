---
layout:     post
title:      Apereo CAS SAML Integration With ADFS
summary:    A short tutorial on how to integrate CAS, acting as a SAML identity provider, with ADFS.
tags:       [CAS,SAML]
---

<div class="alert alert-success">
  <strong>Collaborate</strong><br/>This blog is managed and hosted on GitHub. If you wish to update the contents of this post or if you have found an inaccuracy and wish to make corrections, we recommend that you please submit a pull request to <a href="https://github.com/apereo/apereo.github.io">this repository</a>.
</div>

This is a short and sweet tutorial on how to integrate Apereo CAS, acting as a SAML identity provider, with ADFS.
 
# Environment

- CAS `5.2.0-SNAPSHOT`
- [CAS Maven WAR Overlay](https://github.com/apereo/cas-overlay-template)

# CAS Configuration

In order to allow CAS to become a SAML2 identity provider, the overlay needs to be prepped based on the [instructions provided here](https://apereo.github.io/cas/development/installation/Configuring-SAML2-Authentication.html). Remember to add the relevant module to the overlay along with the list of required build repositories. 

The SAML IdP configuration will need to minimally match the following settings:

```properties
cas.authn.samlIdp.entityId=https://cas.example.edu/idp
cas.authn.samlIdp.scope=example.edu
cas.authn.samlIdp.metadata.location=file:/etc/cas/saml
```

You will, of course, need to adjust your entityId and scope as needed. Upon startup, CAS will attempt to generate the appropriate metadata based on provided settings and produced artifacts will be placed at `/etc/cas/saml`. Of course, the running CAS process will need to have the right permissions in order to create this directory and the contents within it.

To keep things simple, we will also configure CAS to use [LDAP authentication](https://apereo.github.io/cas/development/installation/LDAP-Authentication.html) such that the established single sign-on session is based on the authenticated principal whose is based on the `sAMAccountName` attribute.

The ADFS instance needs to be registered with CAS as a service provider. You can choose a variety of [service management options](https://apereo.github.io/cas/development/installation/Service-Management.html). For this tutorial, I will be using the [JSON Service Registry](https://apereo.github.io/cas/development/installation/JSON-Service-Management.html) with the following snippet as the ADFS registration record:

```json
{
  "@class": "org.apereo.cas.support.saml.services.SamlRegisteredService",
  "serviceId": "http://adfs.example.edu/adfs/services/trust",
  "name": "adfs",
  "id": 10000007,
  "description": "adfs service",
  "logoutType": "NONE",
  "attributeReleasePolicy": {
    "@class": "org.apereo.cas.services.ReturnMappedAttributeReleasePolicy",
    "allowedAttributes": {
      "@class": "java.util.TreeMap",
      "upn": "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/upn",
      "http://schemas.microsoft.com/ws/2008/06/identity/claims/windowsaccountname": "groovy { return 'DOMAIN\\\\' + attributes['username'][0] }"
    }
  },
  "requiredNameIdFormat": "urn:oasis:names:tc:SAML:1.1:nameid-format:unspecified",
  "metadataLocation": "/path/to/adfs-metadata.xml",
  "signAssertions": true,
  "signResponses": false
}
```

You certainly need to modify the `serviceId` and `metadataLocation` for your configuration but the most important bit in the above snippet is the blob that controls the `allowedAttributes`. The attribute release policy is essentially doing the following:

- `upn` is released and mapped to the ADFS-required SAML name `http://schemas.xmlsoap.org/ws/2005/05/identity/claims/upn`.
-    `http://schemas.microsoft.com/ws/2008/06/identity/claims/windowsaccountnwin` is required by ADFS and is released here as a custom attribute. Since it requires a value in the format of `DOMAIN\\username`, this value is constructed via an inline groovy script, with each `\` escaped with another `\`. Remember that `username` here is the name mapped to the attribute `sAMAccountName` that is retrieved from LDAP and is the CAS principal id. Also note that because all attributes in CAS are sort of treated and assumed to be multi-valued, we need to ensure that we grab the attribute value for `username` by indexing it with `[0]`.

# ADFS Configuration

Start with adding a Claims Provider Trust. In the screenshot below, ours is called `CAS Login –TEST`.

![image](https://user-images.githubusercontent.com/1205228/33142854-1222951c-cf75-11e7-8921-79f38283ffaa.png)

On the “Monitoring” tab, enter the URL of your CAS IdP metadata into the “Claims provider’s federation metadata URL:” field (i.e `https://cas.example.edu/cas/idp/metadata`).

![image](https://user-images.githubusercontent.com/1205228/33142888-2ef45d88-cf75-11e7-877c-17fb83758b57.png)

On the “Identifiers” tab, enter a “Display name:” and enter the entity ID that you specified in your CAS IdP configuration into the ”Claims provider identifier” field (i.e. `https://cas.example.edu/idp`).

![image](https://user-images.githubusercontent.com/1205228/33142917-45d59bc0-cf75-11e7-9a60-407f70b4dd76.png)

On the “Endpoints” tab, enter the endpoints for “SAML Single Sign-On Endpoints” and “SAML Logout Endpoints”. These can be found from your CAS IdP metadata. The first two values entered here are based on the “SingleSignOnService” bindings at the following endpoints:

- `https://cas.example.edu/cas/idp/profile/SAML2/POST/SSO`
- `https://cas.example.edu/cas/idp/profile/SAML2/Redirect/SSO`

The logout endpoint is based on the “SingleLogoutService” binding located at the following endpoint:

- `https://cas.example.edu/cas/idp/profile/SAML2/POST/SLO`

![image](https://user-images.githubusercontent.com/1205228/33142928-57e82dc8-cf75-11e7-9ef8-2d22b0f9f3f0.png)

To enable CAS only (ADFS will auto-redirect to CAS), run the following PowerShell command on the ADFS server:

`Set-AdfsRelyingPartyTrust -TargetName "Microsoft Office 365 Identity Platform" -ClaimsProviderName "CAS Login - TEST"`

To revert back to Active Directory, run the following PowerShell command on the ADFS server:

`Set-AdfsRelyingPartyTrust -TargetName "Microsoft Office 365 Identity Platform" -ClaimsProviderName "Active Directory"`

# Summary

I hope this review was of some help to you. As you have been reading, I can guess that you have come up with a number of missing bits and pieces that would satisfy your use cases more comprehensively with CAS. In a way, that is exactly what this tutorial intends to inspire. Please feel free to [engage and contribute](https://apereo.github.io/cas/developer/Contributor-Guidelines.html) as best as you can.

[Misagh Moayyed](https://fawnoos.com)
