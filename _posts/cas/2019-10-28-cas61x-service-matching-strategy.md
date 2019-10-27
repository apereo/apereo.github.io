---
layout:     post
title:      Apereo CAS - Service Matching Strategies
summary:    Learn to customize Apereo CAS to modify the default strategy used for matching services.
tags:       [CAS]
---

<div class="alert alert-success">
<strong>Collaborate</strong><br/>This blog is managed and hosted on GitHub. If you wish to update the contents of this post or if you have found an inaccuracy and wish to make corrections, we recommend that you please submit a pull request to <a href="https://github.com/apereo/apereo.github.io">this repository</a>.
</div>

# Overview

Per the [CAS Protocol](https://apereo.github.io/cas/development/protocol/CAS-Protocol-Specification.html), validating service tickets requires a `service` parameter that is expected to be the identifier of the service for which the service ticket was issued. In other words, CAS requires and enforces an exact match between the given service identifier and one that was supplied originally for ticket creation.

In this short tutorial, we are briefly going to review the specifics of this matching strategy and ways that it might be customized. Our starting position is based on:

- CAS `6.1.x`
- Java `11`
- [CAS WAR Overlay](https://github.com/apereo/cas-overlay-template)

# Configuration

The default service matching strategy is exact and enforced by `DefaultServiceMatchingStrategy`. The strategy can be replaced if, for example, you wanted to disregard query string parameters and extract service identifiers solely by their URL.

<div class="alert alert-warning">
<strong>Caution</strong><br/>Altering the internal mechanics of a CAS server may lead to a problematic insecure configuration and <i>may</i> also jeopradize the population of giant pandas. Such customizations should only be applied if absolutely necessary when all other alternatives are considered and ruled out.
</div>

To do so, you should start by [designing your own configuration component](https://apereo.github.io/cas/development/configuration/Configuration-Management-Extensions.html) to include the following bean:

```java
@Bean
public ServiceMatchingStrategy serviceMatchingStrategy() {
    return new MyServiceMatchingStrategy(...);
}
```

The general outline of `MyServiceMatchingStrategy` should have to follow the below example:

```java
public class MyServiceMatchingStrategy implements ServiceMatchingStrategy {
    @Override
    public boolean matches(final Service service, final Service serviceToMatch) {
        /*
        service - the original service supplied when the ticket was created.
        serviceToMatch - the provided service requesting the ticket to be validated.

        Figure out what needs to be done and return either true or false.
        */
        return ...;
    }
}
```

That's all.

# So...

I hope this review was of some help to you and I am sure that both this post as well as the functionality it attempts to explain can be improved in any number of ways. Please know that all other use cases, scenarios, features, and theories certainly [are possible](https://apereo.github.io/2017/02/18/onthe-theoryof-possibility/) as well. Feel free to [engage and contribute](https://apereo.github.io/cas/developer/Contributor-Guidelines.html) as best as you can.

Finally, if you benefit from Apereo CAS as free and open-source software, we invite you to [join the Apereo Foundation](https://www.apereo.org/content/apereo-membership) and financially support the project at a capacity that best suits your deployment. If you consider your CAS deployment to be a critical part of the identity and access management ecosystem and care about its long-term success and sustainability, this is a viable option to consider.

Happy Coding,

[Misagh Moayyed](https://twitter.com/misagh84)