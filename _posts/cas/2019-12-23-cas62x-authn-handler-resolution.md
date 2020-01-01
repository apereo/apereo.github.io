---
layout:     post
title:      Apereo CAS - Authentication Handler Resolution
summary:    Learn how to resolve and select authentication handlers based on configurable and flexible filtering criteria.
tags:       [CAS]
---

<div class="alert alert-success">
<strong>Collaborate</strong><br/>This blog is managed and hosted on GitHub. If you wish to update the contents of this post or if you have found an inaccuracy and wish to make corrections, we recommend that you please submit a pull request to <a href="https://github.com/apereo/apereo.github.io">this repository</a>.
</div>

# Overview

Nobody enjoys restrictions and limitations but when it comes to Apereo CAS and dealing with authentication transactions,
there may be a few cases where you would want to limit or choose a select collection of authentication handlers to respond
to a request. The selection criteria could be based on the format or syntax of the credential, the requesting application
or some other arbitrary rule. In this post, we are going to briefly look at strategies that allow one to narrow down
the list of authentication handler candidates from a global set.

Our starting position is based on:

- CAS `6.2.x`
- Java `11`
- [CAS WAR Overlay](https://github.com/apereo/cas-overlay-template)

# Credential Criteria

Most authentication strategies in CAS are given a [predicate to examine the requested credential](https://apereo.github.io/cas/development/configuration/Configuration-Properties-Common.html#authentication-credential-selection) for eligibility. This predicate is simply a fancy a condition whose outcome determines whether the authentication strategy/handler should proceed to operate on the credential:

```properties                                     
...
cas.authn.accept.credentialCriteria=.+@example.org
cas.authn.accept.name=Default
...
```

In the above example, the `credentialCriteria` is a regular expression pattern that is tested against the credential identifier. In other words, if an authentication request is submitted to CAS with a credential
whose identifier is `test@example.org`, this `Default` authentication handler will be selected to validate the credential.

# Per Application

Imagine that we have defined the following authentication handlers/schemes in our CAS configuration:

```properties                                     
...                  
cas.authn.accept.users=casuser::Mellon
cas.authn.accept.credentialCriteria=.+@example.org
cas.authn.accept.name=Static 

cas.authn.json.location=file:/etc/cas/config/json-authn.json
cas.authn.json.name=JSON
...
```     

When an authentication request is submitted to CAS, both of the above strategies are made available and selected to respond
and verify the given credential. However, you may want to ignore the `Static` strategy and restrict the selection 
criteria to only have the `JSON` authentication handler respond in case the authentication request 
is submitted from an `https://app.example.org` application:

```json
{
  "@class" : "org.apereo.cas.services.RegexRegisteredService",
  "serviceId" : "https://app.example.org/.+",
  "name" : "ExampleApp",
  "id" : 1,
  "requiredHandlers" : [ "java.util.HashSet", [ "JSON" ] ]
}
```

# Groovy

In more flexible yet programmatic ways, the selection of authentication handlers can also be delegated to a Groovy script. This is the option where
you get to have complete control over the selection process and are tasked with designing the script to return the final filtered collection
of authentication handlers that should operate on the credential:

```groovy
cas.authn.core.groovy-authentication-resolution.location=file:/etc/cas/config/AuthenticationSelection.groovy
```

The `AuthenticationSelection.groovy` may look like this:

```groovy
def run(Object[] args) {
    def handlers = args[0]
    def transaction = args[1]
    def servicesManager = args[2]
    def logger = args[3]

    logger.trace("Resolving authentication handlers ${handlers}...") 
    /*
        Return the final Set of AuthenticationHandler
        components from the provided handlers
        back to CAS to try this transaction.
    */
    handlers
}

def supports(Object[] args) {
    def handlers = args[0]
    def transaction = args[1]
    def servicesManager = args[2]
    def logger = args[3]      

    /*
        Determine if the script should be run,
        and whether it can support the given transaction.
    */
    true
}
```

# Bonus

The most extreme option of all is to simply supply your overall strategy for authentication management and override the CAS-provided engine. 
To do this, you should start by [designing your configuration component](https://apereo.github.io/cas/development/configuration/Configuration-Management-Extensions.html) to include the following bean:

```java
@Bean
public AuthenticationManager casAuthenticationManager() {
    ...
}
```

You should only take up this option as a last resort, [and maybe not even then](https://apereo.github.io/2017/09/10/stop-writing-code/).

# So...

I hope this review was of some help to you and I am sure that both this post as well as the functionality it attempts to explain can be improved in any number of ways. Please know that all other use cases, scenarios, features, and theories certainly [are possible](https://apereo.github.io/2017/02/18/onthe-theoryof-possibility/) as well. Feel free to [engage and contribute](https://apereo.github.io/cas/developer/Contributor-Guidelines.html) as best as you can.

Finally, if you benefit from Apereo CAS as free and open-source software, we invite you to [join the Apereo Foundation](https://www.apereo.org/content/apereo-membership) and financially support the project at a capacity that best suits your deployment. If you consider your CAS deployment to be a critical part of the identity and access management ecosystem and care about its long-term success and sustainability, this is a viable option to consider.

Happy Coding,

[Misagh Moayyed](https://fawnoos.com)
