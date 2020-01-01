---
layout:     post
title:      Apereo CAS - Delegated Authentication to SAML2 Identity Providers
summary:    Learn how your Apereo CAS deployment may be configured to delegate authentication to an external SAML2 identity provider.
tags:       [CAS,SAML]
---

<div class="alert alert-success">
  <strong>Collaborate</strong><br/>The blog is managed and hosted on GitHub. If you wish to update the contents of this post or if you have found an inaccuracy and wish to make corrections, we recommend that you please submit a pull request to <a href="https://github.com/apereo/apereo.github.io">this repository</a>.
</div>

Apereo CAS has had support to [delegate authentication to external SAML2 identity providers](https://apereo.github.io/cas/development/integration/Delegate-Authentication.html) for quite some time. This functionality, if memory serves me correctly, started around CAS `3.x` as an extension based on the [pac4j](https://github.com/pac4j/pac4j) project which then later found its way into the CAS codebase as a first class feature. Since then, the functionality more or less has evolved to allow the adopter less configuration overhead and fancier ways to automated workflows.

Of course, *delegation* is just a fancy word that ultimately means, whether automatically or at the click of a button, the browser is expected to redirect the user to the appropriate SAML2 endpoint and on the return trip back, CAS is tasked to parse the response and extract attributes, etc in order to establish an authentication session, issue tickets, etc. In other words, in delegated scenarios, the main identity provider is an external system and CAS simply begins to act as a client or *proxy* in between.

In the most common use case, CAS is made entirely invisible to the end-user such that the redirect simply happens automatically and as far as the audience is concerned, there are only the external identity provider and the target application that is, of course, prepped to speak the CAS protocol.

Let's begin. Our starting position is based on:

- CAS `6.1.x`
- Java `11`
- [CAS WAR Overlay](https://github.com/apereo/cas-overlay-template)

## Configuration

The initial setup is in fact simple; as the [documentation describes](https://apereo.github.io/cas/development/integration/Delegate-Authentication.html) you simply need to add the required dependency in your overlay:

```xml
<dependency>
  <groupId>org.apereo.cas</groupId>
  <artifactId>cas-server-support-pac4j-webflow</artifactId>
  <version>${cas.version}</version>
</dependency>
```

...and then in your `cas.properties`, instruct CAS to hand off authentication to the SAML2 identity provider:

```properties
cas.authn.pac4j.saml[0].keystorePassword=pac4j-demo-passwd
cas.authn.pac4j.saml[0].privateKeyPassword=pac4j-demo-passwd
cas.authn.pac4j.saml[0].keystorePath=/etc/cas/config/samlKeystore.jks
cas.authn.pac4j.saml[0].serviceProviderEntityId=urn:mace:saml:pac4j.org
cas.authn.pac4j.saml[0].serviceProviderMetadataPath=/etc/cas/config/sp-metadata.xml

cas.authn.pac4j.saml[0].identityProviderMetadataPath=https://dev.oktapreview.com/app/.../sso/saml/metadata
cas.authn.pac4j.saml[0].clientName=SAML2Client

# cas.authn.pac4j.saml[0].destinationBinding=urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST
# cas.authn.pac4j.saml[0].maximumAuthenticationLifetime=3600
```

The above settings instruct CAS to:

- Generate the service-provider metadata at `/etc/cas/config/sp-metadata.xml` using entity id `urn:mace:saml:pac4j.org` automatically. This metadata is created on CAS startup once the login page is rendered. This metadata is expected to be shared *somehow* with the SAML2 identity provider.
- The URL to the identity provider metadata is also taught to CAS; note that in this case, we are using Okta as the SAML2 external identity provider.

...and just to make things more interesting, I am going to create a *stub* attribute definition for `employeeNumber` with an always-hardcoded value of `4095712`:

```properties
cas.authn.attributeRepository.stub.attributes.employeeNumber=4095712
```

This is going to be rather interesting because I have also configured my Okta SAML2 IdP to release an attribute named `employeeNumber`. Let's see what happens with two systems competing for the same attribute.

## Da Test

If you build and then bring up CAS, the main login screen might look something like this:

![image](https://user-images.githubusercontent.com/1205228/53325646-05d13e80-38a1-11e9-99fb-1a7346717641.png)

Getting to the `SAML2Client` will redirect you to the Okta SAML2 IdP:

![image](https://user-images.githubusercontent.com/1205228/53325664-11246a00-38a1-11e9-8203-ef533c176977.png)

After authentication, CAS might greet with you with a *Hey! You logged in successfully* message. Note that this message shows up because we didn't originally specify a target application, with a `service` parameter perhaps, when we first accessed CAS.

![image](https://user-images.githubusercontent.com/1205228/53325689-1aadd200-38a1-11e9-9418-b046f629d14c.png)

If you expand the link to see attributes currently resolved, you will see everything the identity provider has released to CAS as a service provider. Interestingly, CAS has also merged the values for `employeeNumber`, effectively turning it into a multi-valued attribute honor both sources of attributes.

![image](https://user-images.githubusercontent.com/1205228/53325713-27cac100-38a1-11e9-94a4-363b3ec64cc5.png)

## Remap Attributes

To make things more exiciting, let's instruct CAS to fetch the attribute `employeeNumber` from the identity provider
and then virtually rename it to `empl_id`:
```
cas.authn.pac4j.saml[0].mappedAttributes[0].name=employeeNumber
cas.authn.pac4j.saml[0].mappedAttributes[0].mappedTo=empl_id
```

With those settings, if you go through the same sequence again you might see something like this:

![image](https://user-images.githubusercontent.com/1205228/53326019-ce16c680-38a1-11e9-8778-e8232de3d575.png)

<div class="alert alert-info">
  <strong>Remember</strong><br/>Note that we are only in the process of fetching and resolving attributes in fancy ways. The decision of which application(s) should receive which resolved attributes may come later, likely to be decided on a per-application basis as part of the registered service definition body and its attribute release policy with CAS.
</div>

## Identity Provider Authorization

Let's pretend that we are using the [JSON Service Registry](https://apereo.github.io/cas/development/services/JSON-Service-Management.html) to manage our application registration records. On a per-app basis and for a sample test application, let's make sure our app is authorized to use our SAML2 identity provider in a delegated authentication scenario. 

```json
{
  "@class" : "org.apereo.cas.services.RegexRegisteredService",
  "serviceId" : "https://www.example.org",
  "name" : "Example",
  "id" : 1,
  "evaluationOrder" : 1,
  "accessStrategy" : {
    "@class" : "org.apereo.cas.services.DefaultRegisteredServiceAccessStrategy",
    "delegatedAuthenticationPolicy" : {
      "@class" : "org.apereo.cas.services.DefaultRegisteredServiceDelegatedAuthenticationPolicy",
      "allowedProviders" : [ "java.util.ArrayList", [ "SAML2Client" ] ]
    }
  }
}
```

<div class="alert alert-info">
  <strong>Remember</strong><br/>For backward compatibility reasons, leaving the <code>allowedProviders</code> as empty does not prevent a service definition for using an external identity provider...yet. While this behavior may change in future CAS versions, (and you can expect warnings in the CAS logs if you leave this field as empty), you can still stop a service from using delegated authentication by assigning it an invalid/non-existing identity provider (i.e. client name).
</div>

## Service Access Strategy

We know our identity provider is releasing a handful of attributes to CAS. Let's play around with CAS access strategies and design a rule for our example application to only grant entry access to the application if CAS has access to a `memberOf` attribute with a value of `Administrator`. We know of course that the identity provider is not releasing this attribute yet, so we promptly should be greeted with a *Sorry you are not allowed to proceed* type of error message.

Our application policy would look similar to this:

```json
{
  "@class" : "org.apereo.cas.services.RegexRegisteredService",
  "serviceId" : "https://www.example.org",
  "name" : "Example",
  "id" : 1,
  "evaluationOrder" : 1,
  "accessStrategy" : {
    "@class" : "org.apereo.cas.services.DefaultRegisteredServiceAccessStrategy",
    "requiredAttributes" : {
      "@class" : "java.util.HashMap",
      "memberOf" : [ "java.util.HashSet", [ "Administrator" ] ]
    },
    "delegatedAuthenticationPolicy" : {
      "@class" : "org.apereo.cas.services.DefaultRegisteredServiceDelegatedAuthenticationPolicy",
      "allowedProviders" : [ "java.util.ArrayList", [ "SAML2Client" ] ]
    }
  }
}
```

Now, if you try the same sequence again, (don't forget to start with the application), you'd be greeted at the end of the flow with:

![image](https://user-images.githubusercontent.com/1205228/53349255-f7534900-38d9-11e9-84b4-ca80072d6927.png)

## Finale

I hope this review was of some help to you and I am sure that both this post as well as the functionality it attempts to explain can be improved in any number of ways. Please feel free to [engage and contribute](https://apereo.github.io/cas/developer/Contributor-Guidelines.html) as best as you can.

[Misagh Moayyed](https://fawnoos.com)
