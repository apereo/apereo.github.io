---
layout:     post
title:      Apereo CAS - Riffing on Attribute Release Policies
summary:    Learn how to release the kraken of attributes to CAS clients, relying parties and service providers using a variety of attribute release policies and authentication protocols, sampled and collected here to fun and profit.
tags:       [CAS]
---

<div class="alert alert-success">
  <strong>Collaborate</strong><br/>The blog is managed and hosted on GitHub. If you wish to update the contents of this post or if you have found an inaccuracy and wish to make corrections, we recommend that you please submit a pull request to <a href="https://github.com/apereo/apereo.github.io">this repository</a>.
</div>

The process of dealing with attributes in Apereo CAS is twofold. First, CAS begins to fetch and resolve attributes from configured data sources, which may or may not be the same as the authentication source, usually as part of or right after the authentication transaction. Once attributes are found, they may be conditionally released to integrated service providers and registered clients and relying parties using a variety of [attribute release policies](https://apereo.github.io/cas/development/integration/Attribute-Release.html).

In this blog post, I attempt to collect a number of attribute release policy samples and snippets that demonstrate the capabilities of the CAS attribute release engine to some degree. Some are rather modest and hopefully self-explanatory, and some are more advanced tapping into the particulars of a given authentication protocol to take advantage of fancier features such as *scopes*, *chains*, etc.

<div class="alert alert-info">
  <strong>Docs Grow Old</strong><br/>This is a partial list and is expected to grow over time with more examples. Keep an eye out for future updates.
</div>

In all such examples, the underlying assumptions are:

- The registration records for CAS-integrated applications are managed as stand-alone JSON files using the [JSON Service Registry](https://apereo.github.io/cas/development/services/JSON-Service-Management.html).
- Indicated attributes in all samples are fetched, resolved and made available from data sources and other attribute repositories. We assume the attribute is available in pool before it can be released.

Let's begin. Our starting position is based on:

- CAS `6.1.x`
- Java `11`
- [CAS WAR Overlay](https://github.com/apereo/cas-overlay-template)

* A markdown unordered list which will be replaced with the ToC
{:toc}

## Scenarios
{:.no_toc}

### SAML2 Metadata R&E Bundle

CAS running as SAML2 identity provider, releasing the R&E bundle of attributes to service providers found in a metadata aggregate in addition to a number of other *freelancing* attributes.

```json
{
  "@class": "org.apereo.cas.support.saml.services.SamlRegisteredService",
  "serviceId": ".+",
  "name": "example",
  "id": 1,
  "evaluationOrder": 1,
  "metadataLocation": "https://server-url/saml-metadata-aggregate.xml",
  "attributeReleasePolicy": {
    "@class": "org.apereo.cas.services.ChainingAttributeReleasePolicy",
    "policies": [
      "java.util.ArrayList",
      [
        { "@class": "org.apereo.cas.support.saml.services.InCommonRSAttributeReleasePolicy" },
        { "@class": "org.apereo.cas.support.saml.services.RefedsRSAttributeReleasePolicy" },
        {
          "@class": "org.apereo.cas.services.ReturnAllowedAttributeReleasePolicy",
          "allowedAttributes" : [ "java.util.ArrayList", [ "emplId", "department" ] ]
        }
      ]
    ]
  }
}
```

### Remapping Attributes Virtually

Release `employeeId` as `UDC_IDENTIFIER` typically done for Ellucian Banner SSO Manager.

```json
{
  "@class" : "org.apereo.cas.services.RegexRegisteredService",
  "serviceId" : "https://example.banner.edu",
  "name" : "banner",
  "id" : 1,
  "attributeReleasePolicy" : {
    "@class" : "org.apereo.cas.services.ReturnMappedAttributeReleasePolicy",
    "allowedAttributes" : {
      "@class" : "java.util.TreeMap",
      "employeeId" : "UDC_IDENTIFIER"
    }
  }
}
```

### SAML2 Service Provider w/ Transient NameID

CAS running a SAML2 identity provider is set to release all attributes to the SAML2 service provider, while generating a transient name identifier.

```json
{
  "@class" : "org.apereo.cas.support.saml.services.SamlRegisteredService",
  "serviceId" : "service-provider-entity-id",
  "name" : "SAML",
  "id" : 1,
  "metadataLocation" : "/path/to/metadata.xml",
  "requiredNameIdFormat": "urn:oasis:names:tc:SAML:2.0:nameid-format:transient",
  "attributeReleasePolicy" : {
    "@class" : "org.apereo.cas.services.ReturnAllAttributeReleasePolicy"
  },
  "usernameAttributeProvider" : {
    "@class" : "org.apereo.cas.services.AnonymousRegisteredServiceUsernameAttributeProvider",
  }
}
```

### SAML2 Service Provider w/ Persistent NameID

CAS running a SAML2 identity provider is set to release all attributes to the SAML2 service provider, while generating a persistent name identifier using a pre-defined salt.

```json
{
  "@class" : "org.apereo.cas.support.saml.services.SamlRegisteredService",
  "serviceId" : "service-provider-entity-id",
  "name" : "SAML",
  "id" : 1,
  "metadataLocation" : "/path/to/metadata.xml",
  "attributeReleasePolicy" : {
    "@class" : "org.apereo.cas.services.ReturnAllAttributeReleasePolicy"
  },
  "usernameAttributeProvider" : {
    "@class" : "org.apereo.cas.services.AnonymousRegisteredServiceUsernameAttributeProvider",
    "persistentIdGenerator" : {
      "@class" : "org.apereo.cas.authentication.principal.ShibbolethCompatiblePersistentIdGenerator",
      "salt" : "aGVsbG93b3JsZA==",
    }
  }
}
```

### OAuth Simple Relying Party

CAS running as OAuth identity provider, releasing a number of attributes.

```json
{
  "@class" : "org.apereo.cas.support.oauth.services.OAuthRegisteredService",
  "clientId": "client",
  "clientSecret": "secret",
  "serviceId" : "https://app.example.org/dashboard/login",
  "name" : "OAUTH",
  "id" : 1,
  "attributeReleasePolicy" : {
    "@class" : "org.apereo.cas.services.ReturnAllowedAttributeReleasePolicy",
    "allowedAttributes" : [ "java.util.ArrayList", [ "cn", "mail", "givenName" ] ]
  }
}
```

### OpenID Connect Chained Relying Party

CAS running as an OpenID Connect identity provider, releasing the dynamically-built attribute `user-x` off of `uid` as well as all other attributes (i.e. *claims*) defined by the standard `email` scope.

```json
{
  "@class": "org.apereo.cas.services.OidcRegisteredService",
  "clientId": "client",
  "clientSecret": "secret",
  "serviceId": "^https://app.example.org/.*",
  "name": "OIDC",
  "id": 1000,
  "attributeReleasePolicy": {
    "@class": "org.apereo.cas.services.ChainingAttributeReleasePolicy",
    "policies": [
      "java.util.ArrayList",
      [
        {
          "@class": "org.apereo.cas.services.ReturnMappedAttributeReleasePolicy",
          "allowedAttributes": {
            "@class": "java.util.TreeMap",
            "user-x": "groovy { return attributes['uid'].get(0) + '-X' }"
          },
          "order": 0
        },
        {
          "@class": "org.apereo.cas.oidc.claims.OidcEmailScopeAttributeReleasePolicy",
          "order": 2
        }
      ]
    ]
  }
}
```

### WS-FED Simple Relying Party

CAS running as a WS-FED identity provider releasing `employeeNumber` off of `givenName` via a custom namespace.

```json
{
  "@class" : "org.apereo.cas.ws.idp.services.WSFederationRegisteredService",
  "serviceId" : "https://url.to.example/app.*",
  "name" : "WSFED",
  "id" : 2,
  "attributeReleasePolicy" : {
    "@class" : "org.apereo.cas.ws.idp.services.CustomNamespaceWSFederationClaimsReleasePolicy",
    "namespace": "https://github.com/apereo/cas",
    "allowedAttributes" : {
      "@class" : "java.util.TreeMap",
      "employeeNumber" : "givenName"
    }
  },
  "tokenType": "http://docs.oasis-open.org/wss/oasis-wss-saml-token-profile-1.1#SAMLV1.1"
}
```

### Chained Attribute Consent

CAS is releasing attributes `cn`, `mail` and `sn` as well as `displayName` to a client, where the user is asked to consent to the release of attributes `displayName` and `cn`.

```json
{
  "@class" : "org.apereo.cas.services.RegexRegisteredService",
  "serviceId" : "https://example.app.org",
  "name" : "ConsentChained",
  "id" : 1,
  "evaluationOrder" : 1,
  "attributeReleasePolicy": {
    "@class": "org.apereo.cas.services.ChainingAttributeReleasePolicy",
    "mergingPolicy": "replace",
    "policies": [ "java.util.ArrayList",
      [
        {
          "@class" : "org.apereo.cas.services.ReturnAllowedAttributeReleasePolicy",
          "allowedAttributes" : [ "java.util.ArrayList", [ "cn", "mail", "sn" ] ],
          "consentPolicy": {
            "@class": "org.apereo.cas.services.consent.DefaultRegisteredServiceConsentPolicy",
            "includeOnlyAttributes": ["java.util.LinkedHashSet", ["cn"]],
            "enabled": true
          }
        },
        {
          "@class" : "org.apereo.cas.services.ReturnAllowedAttributeReleasePolicy",
          "allowedAttributes" : [ "java.util.ArrayList", [ "displayName" ] ],
          "consentPolicy": {
            "@class": "org.apereo.cas.services.consent.DefaultRegisteredServiceConsentPolicy",
            "includeOnlyAttributes": ["java.util.LinkedHashSet", ["displayName"]],
            "enabled": true
          }
        }
      ]
    ]
  }
}
```

### Complicated Chained Attribute Consent

This one is way more complicated! CAS is releasing attributes:

- `cn`, `department`, `mail` and `sn` only if the value of each attribute has exactly 3 characters.
- `displayName`

The user is asked to consent to the release of `cn`, `department` and `displayName` out of the calculated released bundle.

```json
{
  "@class" : "org.apereo.cas.services.RegexRegisteredService",
  "serviceId" : "^(https|imaps)://app.example.org",
  "name" : "example",
  "id" : 1,
  "evaluationOrder" : 1,
  "attributeReleasePolicy": {
    "@class": "org.apereo.cas.services.ChainingAttributeReleasePolicy",
    "mergingPolicy": "replace",
    "policies": [ "java.util.ArrayList",
      [
        {
          "@class" : "org.apereo.cas.services.ReturnAllowedAttributeReleasePolicy",
          "allowedAttributes" : [ "java.util.ArrayList", [ "cn", "department", "mail", "sn" ] ],
          "attributeFilter" : {
            "@class" : "org.apereo.cas.services.support.RegisteredServiceChainingAttributeFilter",
            "filters": [ "java.util.ArrayList",
              [
                {
                  "@class" : "org.apereo.cas.services.support.RegisteredServiceRegexAttributeFilter",
                  "pattern" : "^\\w{3}$",
                  "order": 1
                }
              ]
            ]
          },
          "consentPolicy": {
            "@class": "org.apereo.cas.services.consent.DefaultRegisteredServiceConsentPolicy",
            "includeOnlyAttributes": ["java.util.LinkedHashSet", ["cn", "department"]],
            "enabled": true
          }
        },
        {
          "@class" : "org.apereo.cas.services.ReturnAllowedAttributeReleasePolicy",
          "allowedAttributes" : [ "java.util.ArrayList", [ "displayName" ] ],
          "consentPolicy": {
            "@class": "org.apereo.cas.services.consent.DefaultRegisteredServiceConsentPolicy",
            "includeOnlyAttributes": ["java.util.LinkedHashSet", ["displayName"]],
            "enabled": true
          }
        }
      ]
    ]
  }
}
```

## Finale
{:.no_toc}

I hope this review was of some help to you and I am sure that both this post as well as the functionality it attempts to explain can be improved in any number of ways. Please feel free to [engage and contribute](https://apereo.github.io/cas/developer/Contributor-Guidelines.html) as best as you can.

[Misagh Moayyed](https://twitter.com/misagh84)
