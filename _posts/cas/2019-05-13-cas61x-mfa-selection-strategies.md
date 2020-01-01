---
layout:     post
title:      Apereo CAS - Multifactor Provider Selection
summary:    Learn how to configure CAS to integrate with and use multiple multifactor providers at the same time. This post also reveals a few super secret and yet open-source strategies one may use to select appropriate providers for authentication attempts, whether automatically or based on a menu.
tags:       [CAS]
---

<div class="alert alert-success">
<strong>Collaborate</strong><br/>This blog is managed and hosted on GitHub. If you wish to update the contents of this post or if you have found an inaccuracy and wish to make corrections, we recommend that you please submit a pull request to <a href="https://github.com/apereo/apereo.github.io">this repository</a>.
</div>

# Overview

Sometimes, it takes more than one multifactor provider to change a lightbulb. With CAS, it is certainly possible to configure more than one provider integration at the same time. The trick, however, is to decide the appropriate provider, should more than one qualify for the same transaction. Imagine you have an application registered with CAS whose multifactor authentication policy is equally deserving of, let's say, Duo Security as well as Google Authenticator. How would you go about choosing one that makes the most sense? 

Our starting position is based on:

- CAS `6.1.x`
- Java `11`
- [CAS WAR Overlay](https://github.com/apereo/cas-overlay-template)
- [JSON Service Registry](https://apereo.github.io/cas/development/services/JSON-Service-Management.html)

# Configuration

So, let's pretend that our application is registered with CAS as such:

```json
{
  "@class": "org.apereo.cas.services.RegexRegisteredService",
  "serviceId": "^(https|imaps)://.*",
  "name": "Example",
  "id": 1,
  "description": "This service definition defines a service.",
  "evaluationOrder": 1,
  "multifactorPolicy" : {
    "@class" : "org.apereo.cas.services.DefaultRegisteredServiceMultifactorPolicy",
    "multifactorAuthenticationProviders" : [ "java.util.LinkedHashSet", [ "mfa-duo", "mfa-gauth" ] ]
  }
}
```

## Provider Rankings

The first and default strategy is to assign ranks to each provider. Ranking of authentication methods is done per provider via specific properties for each in CAS settings. Note that the higher the rank value is, the higher on the security scale it remains. A provider that ranks higher with a larger weight value override others with a lower value.

In practice, this would be:

```properties
...
cas.authn.mfa.duo[0].rank=1
...
cas.authn.mfa.gauth.rank=10
```

When CAS sees that the application policy allows for both `mfa-duo` and `mfa-gauth`, it evaluates the rank for each and picks the one that outranks the other. In the above example, Google Authenticator will be chosen over Duo Security. If ranks are equal, that would be the equivalent of *I am feeling lucky* behavior, which is to say unspecified.

Ranking strategies are fine if you are willing to make a decision on behalf of all users. This is CAS, forming an opinion based on pre-defined configuration without taking into account user choice.

## Selection Menu

Another option is to put the power back into people's hands and let them decide. CAS may also be configured to present a menu of qualifying multifactor provider integrations for the authentication attempt, asking the user to choose one that makes the most sense. To enable the selection menu and remove ranking strategies, one would do this:

```properties
cas.authn.mfa.provider-selection-enabled=true
```

...which may result into this:

![image](https://user-images.githubusercontent.com/1205228/57374168-1a5a6e80-714f-11e9-838a-7b5d37837826.png)

## Selection Script

Sometimes, you need more control over the selection process; to account for external system behavior, other variables, etc. In situations like this, CAS allows you to *script* the selection logic via the magic of Groovy:

```properties
cas.authn.mfa.provider-selector-groovy-script=file:/etc/cas/config/mfaGroovySelector.groovy
```

...and the script would be as:

```groovy
import java.util.*

class SampleGroovyProviderSelection {
  String run(final Object... args) {
      def service = args[0]
      def principal = args[1]
      def providers = args[2]
      def logger = args[3]

      logger.info("Selecting a provider for ${principal} from ${providers}")
      /*
        Work out the selection process...
        Here, we are taking the easy route to return
        the very first provider available to us.
        You should do better.
      */
      return providers.iterator().next().id
  }
}
```

# So...

I hope this review was of some help to you and I am sure that both this post as well as the functionality it attempts to explain can be improved in any number of ways. Please know that all other use cases, scenarios, features, and theories certainly [are possible](https://apereo.github.io/2017/02/18/onthe-theoryof-possibility/) as well. Feel free to [engage and contribute](https://apereo.github.io/cas/developer/Contributor-Guidelines.html) as best as you can.

Happy Coding,

[Misagh Moayyed](https://fawnoos.com)
