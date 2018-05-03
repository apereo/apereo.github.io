---
layout:     post
title:      Apereo CAS - Linking Accounts with Delegated Authentication
summary:    A quick use case walkthrough where profiles provided by external identity providers to CAS need to be looked up by an identifier in internal databases before CAS can successfully establish an authenticated subject.
tags:       [CAS]
---

<div class="alert alert-success">
<strong>Collaborate</strong><br/>This blog is managed and hosted on GitHub. If you wish to update the contents of this post or if you have found an inaccuracy and wish to make corrections, we recommend that you please submit a pull request to <a href="https://github.com/apereo/apereo.github.io">this repository</a>.
</div>

# Overview

In the event that CAS is configured to [delegate authentication](https://apereo.github.io/cas/development/integration/Delegate-Authentication.html) to an external identity provider, it may be necessary to link the received profile from the identity provider to an internal account found in LDAP, SQL databases or any other systems. In this tutorial, we will  focus on how to establish the authenticated subject based on this secondary lookup, using an identifier that is provided by the identity provider.

This tutorial specifically focuses on:

- CAS `5.3.0-RC4`
- Java 8
- [Maven WAR Overlay](https://github.com/apereo/cas-overlay-template)
- [Delegated Authentication](https://apereo.github.io/cas/development/integration/Delegate-Authentication.html)

# Use Case

Our starting position is a CAS server that is configured to hand off the authentication flow to an external identity provider [described here](https://apereo.github.io/cas/development/integration/Delegate-Authentication.html). Once the response from the identity provider is validated and a profile response has been collected, CAS will get access to a profile identifier plus a number of attributes that may have been released by the provider depending on the semantics of the protocol in question. In building the authenticated subject and linking that to the SSO session, CAS by default has options to either use what is called a *typed id* which is translated as `[InternalProviderName]+[Separator]+[ProfileId]` or simply the profile id itself. This means that when the SSO session is established, the CAS authenticated subject will be communicated to all integrated applications using one of those two options.

Of course, you may run into scenarios where neither id would actually make that much sense. For example, the internal identity may be a seemly pseudorandom integer that would not be all that practical for other applications. The better scenario as an option would be for CAS to simply look up the *real record* associated with that internal id, (assuming linking between the two records is made available already), and build the principal identifier and attributes according to the data store internal to CAS.

This is tutorial on how to do just that.

# Setup

Assuming [delegated authentication](https://apereo.github.io/cas/development/integration/Delegate-Authentication.html) is configured in CAS using any of the supported identity providers, our job here is put together code that massages the principal construction in CAS once the flow travels back from the identity provider over to CAS. To do this, we are going to take advantage of CAS `PrincipalFactory` components whose job is to build authenticated subjects, or `Principal`s. Most if not all of authentication strategies in CAS are preconfigured with their own instance of a `PrincipalFactory` that would know how to translate a authenticated successful response into a `Principal` object CAS can understand.

So start to prepare CAS with a [customized configuration component](https://apereo.github.io/cas/development/installation/Configuration-Management-Extensions.html) that would house our specific choice of the `PrincipalFactory` used in delegation scenarios. Once that is done, take note of the following bean definition posted in `Pac4jAuthenticationEventExecutionPlanConfiguration` today:

    
```java
@ConditionalOnMissingBean(name = "clientPrincipalFactory")
@Bean
public PrincipalFactory clientPrincipalFactory() {
    return PrincipalFactoryUtils.newPrincipalFactory();
}
```

Note how the bean is marked as conditional, meaning it will only be used by CAS if an alternative definition by the same is *not* found. So, in order for CAS to pick up our own alternative implementation, we are going to provide that bean definition in our own configuration class as such:

```java
@Bean
public PrincipalFactory clientPrincipalFactory() {
    return PrincipalFactoryUtils.newPrincipalFactory();
}
```

<div class="alert alert-info">
<strong>Compile Dependencies</strong><br/>Note that in order for the CAS overlay build to compile our changes and put them to good use, the overlay must be prepared with the required module used during the compilation phase. Otherwise, there will be errors complaining about missing symbols, etc.</div>

Once you have the build compiling correctly, our next task would be to alter the body of our own `clientPrincipalFactory` bean definition to do what it needs, which is the establishment of the CAS principal based on provided ids, attributes, etc. You can certainly provide your own implementation of `PrincipalFactory`. What might be easier is if you were given the ability to change the implementation dynamically without having to rebuild CAS every time minor changes are required. To do this, aside from the default implementation of `PrincipalFactory`, CAS provides a built-in option to externalize all that logic to a Groovy script. The construction of that option would more or less look like this:

```java
@Autowired
private ResourceLoader resourceLoader;

@Bean
public PrincipalFactory clientPrincipalFactory() {
    Resource script = resourceLoader.getResource("file:/etc/cas/config/CustomPrincipalFactory.groovy");
    return PrincipalFactoryUtils.newGroovyPrincipalFactory(script);
}
```

...and of course, our Groovy script found at `/etc/cas/config/CustomPrincipalFactory.groovy` would have the following structure:

```groovy
import org.apereo.cas.authentication.principal.*
import org.apereo.cas.authentication.*
import org.apereo.cas.util.*

def run(Object[] args) {
    def id = args[0]
    def attributes = args[1]
    def logger = args[2]

    return new SimplePrincipal(id, attributes)
}
```

Now when CAS begins to construct the final authenticated principal, this Groovy script will be invoked to receive the identifier of the received response from the identity provider, any attributes that were submitted and extracted by CAS as a `Map` as well as a convenient logger object. Next, you can code in additional logic to contact the necessary systems and execute queries based on the id to collect the *real* record linked to that id or any of the provided attributes and ultimately, return an object of type `SimplePrincipal` that would carry the authenticated subject and its claims.

# So...

I hope this review was of some help to you and I am sure that both this post as well as the functionality it attempts to explain can be improved in any number of ways. Please feel free to [engage and contribute](https://apereo.github.io/cas/developer/Contributor-Guidelines.html) as best as you can.

Happy Coding,

[Misagh Moayyed](https://twitter.com/misagh84)
