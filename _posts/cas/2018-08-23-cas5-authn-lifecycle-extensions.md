---
layout:     post
title:      Apereo CAS - Authentication Lifecycle Phases
summary:    Tap into the Apereo CAS authentication engine from outside, and design extensions that prevent an unsuccessful authentication attempt or warn the user after-the-fact based on specific policies of your choosing.
tags:       [CAS]
---

<div class="alert alert-success">
  <strong>Collaborate</strong><br/>The blog is managed and hosted on GitHub. If you wish to update the contents of this post or if you have found an inaccuracy and wish to make corrections, we recommend that you please submit a pull request to <a href="https://github.com/apereo/apereo.github.io">this repository</a>.
</div>

There may come a time in your CAS deployment where you realize that simple username/password type of authentication strategy is no longer sufficient and you need to introduce additional policies that sanitize the credentials before submission, check for account status, reach out to external systems and more before you can vouch for a valid authentication request to proceed.

The authentication engine in Apereo CAS is most flexible, where there are specific phases throughout the lifecycle of a given in-process request that can be extended and massaged for prosperity and fancy use cases. In this tutorial, we'll quickly tap into a few of these phases, where our objectives are as follows:

1. Before credentials are validated, we shall reach out to an external system (such as a REST API) to check for user account status. Depending on the response, we may decide to entirely block the request and prevent the user from actually authenticating.
2. After a successful authentication attempt though before a single sign-on session is established, we would want to check the authentication result and reach out to an external API/system to determine whether we need to inform the user about any particular messages or warnings. Whatever the result, we do not intend to block the request and it would be great if the end-user is still given the ability to proceed, despite the forewarned dangers.

Cool, eh?

Our starting position is based on the following:

- CAS `5.3.x`
- Java 8
- [Maven Overlay](https://github.com/apereo/cas-overlay-template) (The `5.3` branch specifically)


## Configuration

As the first step, we need to figure out an authentication strategy. For this tutorial, I taught CAS to use [JAAS for authentication](https://apereo.github.io/cas/5.3.x/installation/JAAS-Authentication.html) in my  `cas.properties`:

```properties
cas.authn.jaas[0].realm=CAS
cas.authn.jaas[0].loginConfigType=JavaLoginConfig
cas.authn.jaas[0].loginConfigurationFile=/etc/cas/config/jaas.conf
```

Of course, my `/etc/cas/config/jaas.conf` file is fairly simple:

```bash
CAS {
    org.apereo.cas.authentication.handler.support.jaas.AccountsPreDefinedLoginModule required
        accounts="casuser::Mellon";
};
```

This basically means that I can authenticate using the static credentials `casuser` and `Mellon`. Not too impressive yet, I suppose, but let's kick this into gear and address our first objective, which is pre-validation of authentication attempts. There are many ways of doing this and as an option, we are going to examine the use case with _Authentication PreProcessor_ components.

## Pre-Processing Authentications

The authentication engine in CAS is in fact quite elaborate. It is composed of my distinct steps, sort of like a factory production line, where some piece of data whether input by the user or from the browser, etc comes in from the outside and is transformed into a form of credential whereby a series of actions and surgeries take place to operate on the credential. One of these steps early on in the process is a component referred to as _Authentication PreProcessor_, which does exactly what its name suggests. This component registers itself with the engine and is tasked with any pre-vetting the credential before any particular authentication strategy kicks into action.

<div class="alert alert-info">
  <strong>Remember</strong><br/>Note that this sort of thing may be considered overkill if your user account store is capable of detecting user account status and blocking the authentication attempt. Using <code>Authentication PreProcessor</code> is generally only required if you have a rather fancy use case with unusual requirements and workflows, and dependencies to outside systems. If you do not, close your eyes and head into the next section.
</div>

So in order to create our own _Authentication PreProcessor_, we'll need to design our own [configuration class](https://apereo.github.io/cas/5.3.x/installation/Configuration-Management-Extensions.html) and register the pre-processor as such:

```java
@Configuration("FancyCasConfiguration")
@EnableConfigurationProperties(CasConfigurationProperties.class)
public class FancyCasConfiguration implements AuthenticationEventExecutionPlanConfigurer {

    @Override
    public void configureAuthenticationExecutionPlan(final AuthenticationEventExecutionPlan plan) {
        plan.registerAuthenticationPreProcessor(accountStatusRetrievalPreProcessor());
    }

    @RefreshScope
    @Bean
    public AuthenticationPreProcessor fancyPreProcessor() {
        return new FancyPreProcessor();
    }
}
```

Our `FancyPreProcessor` then could look like this:

```java
public class FancyPreProcessor implements AuthenticationPreProcessor {
    @Override
    public boolean process(final AuthenticationTransaction transaction) throws AuthenticationException {
        transaction.getPrimaryCredential().ifPresent(c -> {
            /*
              Replace with your own condition...
            */
            if (checkExternalSystemOrApiAndFail()) {
                final Map<String, Throwable> errors = new HashMap<>();
                errors.put(AccountPasswordMustChangeException.class.getSimpleName(), 
                  new AccountPasswordMustChangeException("Expired account"));
                throw new AuthenticationException(errors);
            }
        });
        return true;
    }
}
```

<div class="alert alert-info">
  <strong>Remember</strong><br/>You will need to include a number of CAS module dependencies in your build process for the above snippets to properly compile.
</div>

All that is happening here is that the authentication engine keeps track of this pre-processor and invokes before it does anything else. Our `FancyPreProcessor` when invoked, simply goes in to contact needed systems and check for conditions as needed and finally proper errors are thrown back to CAS that halt the authentication flow and get translated by the upper layers into reasonable messages for the end-user.

## Post-Processing Authentications

Our second objective can in fact be done in form of a normal password policy for JAAS, implemented in your favorite toolkit ever that is Groovy. As you might guess, we need to teach CAS to activate the policy when JAAS completes:

```properties
cas.authn.jaas[0].passwordPolicy.enabled=true
cas.authn.jaas[0].passwordPolicy.strategy=GROOVY
cas.authn.jaas[0].passwordPolicy.groovy.location=/etc/cas/config/SomePasswordPolicyStrategy.groovy
```

...and of course, we need to write the `SomePasswordPolicyStrategy.groovy` script:

```groovy
import org.apereo.cas.*
import java.util.*
import org.apereo.cas.authentication.*

def List<MessageDescriptor> run(final Object... args) {
    def response = args[0]
    def configuration = args[1]
    def logger = args[2]

    logger.debug("Things are happening for [{}]", response)

    if (thereBeDragonsAhead())
      return [new DefaultMessageDescriptor("be.afraid.message.code")]

    return []
}
```

If the policy sees the need, it will collect messages and warnings that would be passed up to the login flow which tries to navigate and switch to a screen where such messages are pulled from language bundles using their code and displayed back for the end-user to examine.

## Finale

I hope this review was of some help to you and I am sure that both this post as well as the functionality it attempts to explain can be improved in any number of ways. Please feel free to [engage and contribute](https://apereo.github.io/cas/developer/Contributor-Guidelines.html) as best as you can.

[Misagh Moayyed](https://twitter.com/misagh84)