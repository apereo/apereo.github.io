---
layout:     post
title:      Apereo CAS 6.1.x - Attribute Repositories w/ Person Directory
summary:    An overview of CAS attribute repositories and strategies on how to fetch attributes from a variety of sources in addition to the authentication source, merge and combine attributes from said sources to ultimately release them to applications with a fair bit of caching.
tags:       [CAS]
---

<div class="alert alert-success">
<strong>Collaborate</strong><br/>This blog is managed and hosted on GitHub. If you wish to update the contents of this post or if you have found an inaccuracy and wish to make corrections, we recommend that you please submit a pull request to <a href="https://github.com/apereo/apereo.github.io">this repository</a>.
</div>

# Overview

The ability to fetch attributes from external data stores has been present in CAS since the days of `3.x`. This functionality was and, to this day, is provided by an Apereo project called [Person Directory](https://github.com/apereo/person-directory) which is a Java framework for resolving persons and attributes from a variety of underlying sources. It consists of a collection of components that retrieve, cache, resolve, aggregate and merge person attributes from JDBC, LDAP and more. CAS attempts to take advantage of this framework through a concept called `PrincipalResolver` whose goal is to construct a final identifiable authenticated principal for CAS which carries a number of attributes inside it fetched from attribute repository sources. This meant that for instance, one could authenticate with LDAP in one query and then turn around the ask the same LDAP, a relational database and a Groovy script to fetch attributes for the resolved principal and combine all results into a final collection.

Note that in most cases, and starting around CAS `4.x`, the authentication engine has been enhanced to be able to retrieve and resolve attributes from the authentication source, which would eliminate the need for configuring a separate attribute repository especially if both the authentication and the attribute source are the same. Using separate resolvers and sources should only be required when sources are different, or when there is a need to tackle more advanced attribute resolution use cases such as cascading, merging, etc.

<div class="alert alert-info">
  <strong>What About...?</strong><br/>Note that attribute resolution via <code>PrincipalResolver</code> components and Person Directory's attribute repositories shall always execute, if and when configured, <i>regardless</i> of how the authentication event occurs. Whether the user is authenticating against a CAS-owned account store or is handed off to an external identity provider, in either scenario CAS is able to put together attributes from both the authentication source as well as any and all attribute repositories configured.
</div>

This tutorial focuses on a number of use case involving attribute repositories, fetching attributes from an external store a JSON file and a collection of hard-coded stubbed attributes. We will demonstrate variations on how attribute sources may be cached, filtered and released in a number of fancy ways.

Our starting position is based on:

- CAS `6.1.x`
- Java `11`
- [CAS WAR Overlay](https://github.com/apereo/cas-overlay-template)
- [JSON Service Registry](https://apereo.github.io/cas/development/services/JSON-Service-Management.html)
- Using CAS default credentials, `casuser` and `Mellon` via static authentication.

* A markdown unordered list which will be replaced with the ToC
{:toc}

## Baseline Configuration

Our JSON attribute repository source, separate from the CAS authentication store is fairly simple:

```json
{
    "casuser": {
        "firstName": ["Bob"],
        "employeeNumber": ["123456"],
        "lastName": ["Johnson"]
    }
}
```

Our external attribute repositories are then taught to CAS:

```properties
cas.authn.attributeRepository.json[0].location=file://etc/cas/config/attribute-repository.json
cas.authn.attributeRepository.json[0].id=MyJson

cas.authn.attributeRepository.stub.id=StaticStub
cas.authn.attributeRepository.stub.attributes.uid=mmoayyed
cas.authn.attributeRepository.stub.attributes.displayName=Misagh Moayyed
cas.authn.attributeRepository.stub.attributes.firstName=Misagh
cas.authn.attributeRepository.stub.attributes.lastName=Moayyed
```

Note that each attribute repository is given an `id` which can the be used as a filter to narrow the resolution logic down to matching repositories.

## Use Cases

### 1

The requirements for this use case are as follows:

- Disable attribute resolution from external attribute repositories via Person Directory.
- Resolve attributes at release time for a given application only using the `MyJson` attribute repository.
- No caching of attributes shall happen either globally or for the application.

The relevant properties for this use case are:

```properties
cas.authn.attributeRepository.expirationTime=0
cas.authn.attributeRepository.expirationTimeUnit=seconds
cas.authn.attributeRepository.merger=multivalued

cas.personDirectory.attributeResolutionEnabled=false
```

Our service definition matches the following:

```json
{
  "@class" : "org.apereo.cas.services.RegexRegisteredService",
  "serviceId" : "https://app.example.org",
  "name" : "ExampleApplication",
  "id" : 1,
  "attributeReleasePolicy" : {
    "@class" : "org.apereo.cas.services.ReturnAllAttributeReleasePolicy",
    "principalAttributesRepository" : {
      "@class" : "org.apereo.cas.authentication.principal.DefaultPrincipalAttributesRepository",
      "attributeRepositoryIds": ["java.util.HashSet", [ "myjson" ]]
    }
  }
}
```

Since caching is disabled, you can change the underlying attribute value in the JSON attribute repository
and CAS should pick up the change and release the new attribute value to the example application.

## 2

The requirements for this use case are as follows:

- Disable attribute resolution from external attribute repositories via Person Directory.
- Resolve attributes at release time for a given application only using the `MyJson` attribute repository.
- Turn on global caching of attributes for `60` seconds.

The relevant properties for this use case are:

```properties
cas.authn.attributeRepository.expirationTime=60
cas.authn.attributeRepository.expirationTimeUnit=seconds
cas.authn.attributeRepository.merger=multivalued

cas.personDirectory.attributeResolutionEnabled=false
```

Our service definition matches the following:

```json
{
  "@class" : "org.apereo.cas.services.RegexRegisteredService",
  "serviceId" : "https://app.example.org",
  "name" : "ExampleApplication",
  "id" : 1,
  "attributeReleasePolicy" : {
    "@class" : "org.apereo.cas.services.ReturnAllAttributeReleasePolicy",
    "principalAttributesRepository" : {
      "@class" : "org.apereo.cas.authentication.principal.DefaultPrincipalAttributesRepository",
      "attributeRepositoryIds": ["java.util.HashSet", [ "myjson" ]]
    }
  }
}
```

Since caching is disabled, you can change the underlying attribute value in the JSON attribute repository
and CAS should pick up the change and release the new attribute value to the example application in about `60` seconds.

## 3

The requirements for this use case are as follows:

- Disable attribute resolution from external attribute repositories via Person Directory.
- Resolve attributes at release time for a given application only using the `MyJson` attribute repository.
- Turn on global caching of attributes for `5` seconds and service-level caching for `30` seconds.

The relevant properties for this use case are:

```properties
cas.authn.attributeRepository.expirationTime=5
cas.authn.attributeRepository.expirationTimeUnit=seconds
cas.authn.attributeRepository.merger=multivalued

cas.personDirectory.attributeResolutionEnabled=false
```

Our service definition matches the following:

```json
{
  "@class" : "org.apereo.cas.services.RegexRegisteredService",
  "serviceId" : "https://app.example.org",
  "name" : "ExampleApplication",
  "id" : 1,
  "attributeReleasePolicy" : {
    "@class" : "org.apereo.cas.services.ReturnAllAttributeReleasePolicy",
    "principalAttributesRepository" : {
      "@class" : "org.apereo.cas.authentication.principal.cache.CachingPrincipalAttributesRepository",
      "duration" : {
        "@class" : "javax.cache.expiry.Duration",
        "timeUnit" : [ "java.util.concurrent.TimeUnit", "SECONDS" ],
        "expiration" : 30
      },
      "attributeRepositoryIds": ["java.util.HashSet", [ "myjson" ]]
    }
  }
}
```

Attributes fetched and released for this example application may be updated after `30` seconds, while the global cache attempts to expire and resolve attributes for other applications after `5` seconds.

## 4

The requirements for this use case are as follows:

- Enable attribute resolution from external attribute repositories via Person Directory.
- However, let CAS resolve attributes from our `StaticStub` attribute repository.
- Resolve attributes at release time for a given application only using the `MyJson` attribute repository.
- Combine all attributes into one collection as multi-valued attributes where necessary.
- Turn on global caching of attributes for `30` seconds.

The relevant properties for this use case are:

```properties
cas.authn.attributeRepository.expirationTime=30
cas.authn.attributeRepository.expirationTimeUnit=seconds
cas.authn.attributeRepository.merger=multivalued

cas.personDirectory.attributeResolutionEnabled=true
cas.personDirectory.activeAttributeRepositoryIds=StaticStub
```

Our service definition matches the following:

```json
{
  "@class" : "org.apereo.cas.services.RegexRegisteredService",
  "serviceId" : "https://app.example.org",
  "name" : "ExampleApplication",
  "id" : 1,
  "attributeReleasePolicy" : {
    "@class" : "org.apereo.cas.services.ReturnAllAttributeReleasePolicy",
    "principalAttributesRepository" : {
      "@class" : "org.apereo.cas.authentication.principal.DefaultPrincipalAttributesRepository",
      "attributeRepositoryIds": ["java.util.HashSet", [ "myjson" ]],
      "mergingStrategy" : "MULTIVALUED"
    }
  }
}
```

## 5

The requirements for this use case are identical to the one above. The only difference is, we are going to ignore attributes resolved at authentication time from our `StaticSub` attribute repository for the example application and only hit our selected attribute repository, `MyJson`.

Our service definition matches the following:

```json
{
  "@class" : "org.apereo.cas.services.RegexRegisteredService",
  "serviceId" : "https://app.example.org",
  "name" : "ExampleApplication",
  "id" : 1,
  "attributeReleasePolicy" : {
    "@class" : "org.apereo.cas.services.ReturnAllAttributeReleasePolicy",
    "principalAttributesRepository" : {
      "@class" : "org.apereo.cas.authentication.principal.DefaultPrincipalAttributesRepository",
      "attributeRepositoryIds": ["java.util.HashSet", [ "myjson" ]],
      "ignoreResolvedAttributes": true,
      "mergingStrategy" : "MULTIVALUED"
    }
  }
}
```

## 6

The requirements for this use case are as follows:

- Enable attribute resolution from external attribute repositories via Person Directory.
- However, let CAS resolve attributes from our `StaticStub` attribute repository.
- Resolve attributes at release time for a given application only using the `MyJson` attribute repository.
- Combine all attributes into one collection as multi-valued attributes where necessary.
- Turn on global caching of attributes for `30` seconds, and service-level caching for `30` minutes.

The relevant properties for this use case are:

```properties
cas.authn.attributeRepository.expirationTime=10
cas.authn.attributeRepository.expirationTimeUnit=seconds
cas.authn.attributeRepository.merger=multivalued

cas.personDirectory.attributeResolutionEnabled=true
cas.personDirectory.activeAttributeRepositoryIds=StaticStub
```

Our service definition matches the following:

```json
{
  "@class" : "org.apereo.cas.services.RegexRegisteredService",
  "serviceId" : "https://app.example.org",
  "name" : "ExampleApplication",
  "id" : 1,
  "attributeReleasePolicy" : {
    "@class" : "org.apereo.cas.services.ReturnAllAttributeReleasePolicy",
    "principalAttributesRepository" : {
      "@class" : "org.apereo.cas.authentication.principal.cache.CachingPrincipalAttributesRepository",
      "duration" : {
        "@class" : "javax.cache.expiry.Duration",
        "timeUnit" : [ "java.util.concurrent.TimeUnit", "MINUTES" ],
        "expiration" : 30
      },
      "attributeRepositoryIds": ["java.util.HashSet", [ "myjson" ]]
    }
  }
}
```

# So...

I hope this review was of some help to you and I am sure that both this post as well as the functionality it attempts to explain can be improved in any number of ways. Please know that all other use cases, scenarios, features and theories certainly [are possible](https://apereo.github.io/2017/02/18/onthe-theoryof-possibility/) as well. Please feel free to [engage and contribute][contribguide] as best as you can.

Happy Coding,

[Misagh Moayyed](https://twitter.com/misagh84)