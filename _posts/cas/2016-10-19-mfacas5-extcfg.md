---
layout:     post
title:      Activating MFA in CAS 5
summary:    Learn and master custom MFA triggers in CAS 5.
tags:       [CAS]
---

Perhaps one of the more attractive features of [CAS 5](https://apereo.github.io/cas/development) is the ability to support [multifactor authentication](https://apereo.github.io/cas/development/installation/Configuring-Multifactor-Authentication.html)
via a number of providers/vendors that can be triggered in many ways. While support for triggers may seem extensive, there is always
that edge use case that would have you trigger MFA based on a special set of requirements.

Here is what you can do.

# Audience

This post is intended for java developers with a basic-to-medium familiarity with Spring, Spring Boot and Spring Webflow.
This is **NOT** a tutorial to be used verbatim via copy/paste. It is instead a recipe for developers to extend CAS
based on specialized requirements.

# Stop Coding

> Hearken to the reed flute, how it complains, lamenting its banishment from its home: “Ever since they tore me from my osier bed, my plaintive notes have moved men and women to tears. I burst my breast, striving to give vent to sighs, and to express the pangs of my yearning for my home. He who abides far away from his home is ever longing for the day he shall return.
>
> [The Reed Flute's Song, Rumi, 1207-1273]

Before diving into code, I **MUST** emphasize that developing custom extensions/addons, while certainly keeewl and exciting, would eventually lead to long-term maintenance/upgrade burdens. Consider direct contributions to the project if/when feasible and solve the problem where it needs solving.

If you are going to write code, you might as well write it where it belongs.

# Requirements

You will need to have compile-time access to the following modules:

- `org.apereo.cas:cas-server-core-webflow`
- `org.apereo.cas:cas-server-core-web`

These are modules that ship with CAS by default and thou shall mark them with a `compile` or `provided` scope in your build configuration.

# Create MFA Triggers

You should create an event resolver that houses and implements your special requirements for MFA. A typical example might be: *Activate MFA provider `mfa-duo` if the request client IP address matches the pattern `123.+`*

```java
package org.apereo.cas.custom.mfa;

public class CustomWebflowEventResolver extends AbstractCasWebflowEventResolver {

    @Autowired
    private CasConfigurationProperties casProperties;

    @Override
    protected Set<Event> resolveInternal(final RequestContext context) {
        final RegisteredService service = WebUtils.getRegisteredService(context);
        final Authentication authentication = WebUtils.getAuthentication(context);
        final HttpServletRequest request = WebUtils.getHttpServletRequest(context);

        final Map<String, MultifactorAuthenticationProvider> providerMap =
            WebUtils.getAllMultifactorAuthenticationProviders(this.applicationContext);

        // Somehow, select a provider based on the above map...    
        final MultifactorAuthenticationProvider provider = ...

        if (areWeDoingMfa()) {
            final Event event = validateEventIdForMatchingTransitionInContext(provider.getId(), context,
                        buildEventAttributeMap(authentication.getPrincipal(), service, provider)));
            return ImmutableSet.of(event);
        }
        logger.warn("Not doing MFA, sorry.");
        return null;
    }
}
```

Note that you have full access to the resolved CAS authentication, the principal associated with it, the service requesting authentication as well as the original web request. You also have access to the full body of CAS configuration settings, should you need to externalize values.

# Register MFA Triggers

Your trigger then needs to be registered. We do this via CAS' native auto-configuration strategy, which scans the application context
for relevant annotations inside `org.apereo.cas` sub-packages. If you change package names, you **MUST** account for the custom context scan too.

```java
package org.apereo.cas.custom.config;

@Configuration("SomethingConfiguration")
public class SomethingConfiguration {

    @Autowired
    @Qualifier("initialAuthenticationAttemptWebflowEventResolver")
    private CasDelegatingWebflowEventResolver initialEventResolver;

    @RefreshScope
    @Bean
    public CasWebflowEventResolver customWebflowEventResolver() {
        return new CustomWebflowEventResolver();
    }

    @PostConstruct
    public void initialize() {
        initialEventResolver.addDelegate(customWebflowEventResolver());
    }
}
```

We simply register our trigger as a Spring `@Bean` and add it to the
chain of event resolvers that kick into action as part of CAS authentication machinery.

# So...

Note that:

- You are really not doing anything *custom*. All CAS triggers behave in the same exact way when
they attempt to resolve the next event.
- The API is completely oblivious to multifactor authentication; all it cares about is finding the next event in the chain in a very generic way. Our custom implementation of course makes the next event be concerned about MFA but in theory we could have resolved the next event to be `hello-world` and CAS would not have cared.

Happy Coding!

[Misagh Moayyed](https://twitter.com/misagh84)
