---
layout:     post
title:      Apereo CAS - SAML2 Identity Provider Integration w/ InCommon
summary:    Learn how Apereo CAS may act as a SAML2 identity provider to integrate with service providers from metadata aggregates such as InCommon with various attribute release policies for research and scholarship, etc.
tags:       [CAS,SAML]
---

<div class="alert alert-success">
  <strong>Collaborate</strong><br/>The blog is managed and hosted on GitHub. If you wish to update the contents of this post or if you have found an inaccuracy and wish to make corrections, we recommend that you please submit a pull request to <a href="https://github.com/apereo/apereo.github.io">this repository</a>.
</div>

Apereo CAS, acting as a SAML2 identity provider, has the capability to integrate with SAML2 service providers from metadata aggregates such as InCommon. To handle these types of integrations successfully, one must note that CAS services (aka relying parties) are fundamentally recognized by service identifiers taught to CAS typically via regular expressions using the `serviceId` field. This allows for common groupings of applications and services by URL patterns (i.e. *Everything that belongs to example.org is registered with CAS*). A bilateral SAML2 SP integration is fairly simple in this regard as one might find an easy one-to-one relationship between a `serviceId` from CAS and the `entityId` from a SAML2 SP. With aggregated metadata, this behavior becomes more complicated since a CAS relying-party definition typically represents a single group of applications while aggregated metadata, given its very nature, represents many different SAML2 services from a variety of organizations and domains.

In this tutorial, we are going to review a number of use cases dealing with multilateral integrations from the SAML2 metadata aggregate offered by InCommon. We will also briefly address configuration of various attribute release policies, specifically those that may belong to the *Research and Scholarship* group of service providers expecting a standard pre-defined bundle of attributes.

Our starting position is based on the following:

- CAS `6.1.x`
- Java `11`
- [CAS WAR Overlay](https://github.com/apereo/cas-overlay-template)

## CAS Configuration

In order to allow CAS to become a SAML2 identity provider, the overlay needs to be prepped based on the instructions provided [here](https://apereo.github.io/cas/development/installation/Configuring-SAML2-Authentication.html). Remember to add the relevant module to the overlay along with the list of required build repositories.

The SAML2 IdP configuration will need to minimally match the following settings:

```properties
cas.authn.samlIdp.entityId=https://sso.example.org/idp
cas.authn.samlIdp.scope=example.org
cas.authn.samlIdp.metadata.location=file:/etc/cas/saml
```

You will, of course, need to adjust your entityId and scope as needed. Upon startup, CAS will attempt to generate the appropriate metadata based on provided settings and produced artifacts will be placed at `/etc/cas/saml`. Of course, the running CAS process will need to have the right permissions in order to create this directory and the contents within it. Furthermore, to keep things simple, this post will assume that CAS is already configured to use [LDAP authentication](https://apereo.github.io/cas/development/installation/LDAP-Authentication.html) and is set to fetch all needed attributes such as `givenName`, `eduPersonPrincipalName` from LDAP, etc. We shall also assume that relying party registration records are handled in CAS via the [JSON Service Registry](https://apereo.github.io/cas/development/services/JSON-Service-Management.html).

## Relying-Party Integrations

Let's consider the following fictitious use cases:

| Service Provider  | Entity ID             | Expected Attributes
| ----------------- | --------------------- | ------------------------------------------
| Almond            | `almond.example.org`  | InCommon R&S bundle, `department`, `title`
| Coconut           | `coconut.example.org` | `givenName`, `title`
| All Others        | `*`                   | InCommon R&S bundle, REFEDS R&S bundle

The above relying parties may be registered with CAS using the following sample records. As you browse through, you should pay attention to the following:

- There is a fair amount of duplication when it comes to the definition of the metadata location and anything else applicable to fetching, parsing and validating the metadata such as the signing signature, etc. Solutions to this issue to simplify maintenance and remove duplication may be worked out in future CAS releases.
- The metadata is downloaded once and cached, even though it is repeatedly specified for all relying parties. Caching rules are controlled by the service provider metadata tags, and/or the CAS service definition for that service provider as an override.
- Given a service definition file typically is entirely self-contained, a certain number of attribute release policies may need to be repeated in the event that a relying party definition needs to override or complement the default *catch-all* policy. Solutions to this issue to simplify maintenance and remove duplication may be worked out in future CAS releases.

### Almond Service Registration

```json
{
  "@class": "org.apereo.cas.support.saml.services.SamlRegisteredService",
  "serviceId": "almond.example.org",
  "name": "almond",
  "id": 1,
  "evaluationOrder": 1,
  "metadataLocation": "https://[metadata-aggregate-address].xml",
  "attributeReleasePolicy": {
    "@class": "org.apereo.cas.services.ChainingAttributeReleasePolicy",
    "policies": [
      "java.util.ArrayList",
      [
        { "@class": "org.apereo.cas.support.saml.services.InCommonRSAttributeReleasePolicy" },
        {
          "@class": "org.apereo.cas.services.ReturnAllowedAttributeReleasePolicy",
          "allowedAttributes" : [ "java.util.ArrayList", [ "department", "title" ] ]
        }
      ]
    ]
  }
}
```

### Coconut Service Registration

```json
{
  "@class" : "org.apereo.cas.support.saml.services.SamlRegisteredService",
  "serviceId" : "coconut.example.org",
  "name" : "coconut",
  "id" : 2,
  "evaluationOrder": 2,
  "metadataLocation": "https://[metadata-aggregate-address].xml",
  "attributeReleasePolicy" : {
    "@class" : "org.apereo.cas.services.ReturnAllowedAttributeReleasePolicy",
    "allowedAttributes" : [ "java.util.ArrayList", [ "givenName", "title" ] ]
  }
}
```

### All Others

Note the `serviceId` field here contains a regular expression that is very friendly to all relying parties. The `evaluationOrder` field is set to a sufficiently large number to ensure this definition is considered very late into the process.

```json
{
  "@class": "org.apereo.cas.support.saml.services.SamlRegisteredService",
  "serviceId": ".+",
  "name": "All",
  "id": 3,
  "evaluationOrder": 10000,
  "metadataLocation": "https://[metadata-aggregate-address].xml",
  "attributeReleasePolicy": {
    "@class": "org.apereo.cas.services.ChainingAttributeReleasePolicy",
    "policies": [
      "java.util.ArrayList",
      [
        { "@class": "org.apereo.cas.support.saml.services.InCommonRSAttributeReleasePolicy" },
        { "@class": "org.apereo.cas.support.saml.services.RefedsRSAttributeReleasePolicy" }
      ]
    ]
  }
}
```

## Metadata Administration

There is also the ability to observe and manage the service provider metadata cache administratively, using a dedicated [actuator endpoint](https://apereo.github.io/2018/11/06/cas6-admin-endpoints-security/). Let's demonstrate this with a few examples:

- Retrieve the current state of the service provider metadata cache for `coconut`:

```bash
curl -k -X GET https://sso.example.org/cas/actuator/samlIdPRegisteredServiceMetadataCache?serviceId=All'&'entityId=coconut.example.org
```

Likewise, the following command may do just as well:

```bash
curl -X GET https://sso.example.org/cas/actuator/samlIdPRegisteredServiceMetadataCache?serviceId=coconut
```

- Invalidate the current state of the service provider metadata cache for `coconut`:

```bash
curl -X DELETE https://sso.example.org/cas/actuator/samlIdPRegisteredServiceMetadataCache?serviceId=coconut
```

- Invalidate the current state of the service provider metadata cache:

```bash
curl -X DELETE https://sso.example.org/cas/actuator/samlIdPRegisteredServiceMetadataCache
```

Better details [may be found here](https://apereo.github.io/cas/development/installation/Configuring-SAML2-DynamicMetadata.html#administrative-endpoints).

## Finale

I hope this review was of some help to you and I am sure that both this post as well as the functionality it attempts to explain can be improved in any number of ways. Please feel free to [engage and contribute](https://apereo.github.io/cas/developer/Contributor-Guidelines.html) as best as you can.

[Misagh Moayyed](https://twitter.com/misagh84)