---
layout:     post
title:      Design Authentication Handlers in CAS 5.1.x
summary:    Learn and master writing custom authentication handlers/schemes in CAS 5.1.x
tags:       [CAS]
---

While [authentication support](https://apereo.github.io/cas/development/installation/Configuring-Authentication-Components.html)
in CAS for a variety of systems is somewhat comprehensive and complex, a common deployment use case 
is the task of designing custom authentication schemes. This post describes the necessary steps needed to design
and register a custom authentication strategy (i.e. `AuthenticationHandler`) in CAS `5.1.x`. 

## Audience

This post is intended for java developers with a basic-to-medium familiarity with Spring, Spring Boot and Spring Webflow. This is **NOT** a tutorial to be used verbatim via copy/paste. It is instead a recipe for developers to extend CAS based on specialized requirements.

## Steps

The overall tasks may be categorized as such:

1. Design the authentication handler
2. Register the authentication handler with the CAS authentication engine.
3. Tell CAS to recognize the registration record and authentication configuration.

## Step 1: Design Authentication Handlers

First step is to define the skeleton for the authentication handler itself. This is the core principal component whose job is to declare support for a given type of credential only to then attempt validate it and produce a successful result. The core parent component from which all handlers extend is the `AuthenticationHandler` interface.

With the assumption that the type of credentials used here deal with the traditional username and password, noted by the infamous `UsernamePasswordCredential` below, a more appropriate skeleton to define for a custom authentication handler may seem like the following:

```java
public class MyAuthenticationHandler extends AbstractUsernamePasswordAuthenticationHandler {
    ...
    protected HandlerResult authenticateUsernamePasswordInternal(final UsernamePasswordCredential credential,
                                                                 final String originalPassword) {
        if (everythingLooksGood()) {
            return createHandlerResult(credential, 
                    this.principalFactory.createPrincipal(username), null);
        }
        throw new FailedLoginException("Sorry, you are simply a big huge failure!");
    }
    ...
}
```

### Review

- Authentication handlers have the ability to produce a fully resolved principal along with attributes. If you have the ability to retrieve attributes
from the same place as the original user/principal account store, the final `Principal` object that is resolved here must then be able to carry all 
those attributes and claims inside it at construction time.

- The last parameter, `null`, is effectively a collection of warnings that is eventually worked into the authentication chain and conditionally
shown to the user. Examples of such warnings include password status nearing an expiration date, etc.

- Authentication handlers also have the ability to block authentication by throwing a number of specific exceptions. A more common exception to throw 
back is `FailedLoginException` to note authentication failure. Other specific exceptions may be thrown to indicate abnormalities with the account status
itself, such as `AccountDisabledException`. 

- Various other components such as `PrincipalNameTransformer`s, `PasswordEncoder`s and such may also be injected into our handler if need be, though these are skipped for now in this post for simplicity.

## Step 2: Register Authentication Handlers

Once the handler is designed, it needs to be registered with CAS and put into the authentication engine.
This is done via the magic of `@Configuration` classes that are picked up automatically at runtime, per your approval,
whose job is to understand how to dynamically modify the application context.


So let's design our own `@Configuration` class:

```java
package com.example.cas;

@Configuration("MyAuthenticationEventExecutionPlanConfiguration")
@EnableConfigurationProperties(CasConfigurationProperties.class)
public class MyAuthenticationEventExecutionPlanConfiguration 
                    implements AuthenticationEventExecutionPlanConfigurer {
    @Autowired
    private CasConfigurationProperties casProperties;

    @Bean
    public AuthenticationHandler myAuthenticationHandler() {
        final MyAuthenticationHandler handler = new MyAuthenticationHandler();
        /*
            Configure the handler by invoking various setter methods.
            Note that you also have full access to the collection of resolved CAS settings.
            Note that each authentication handler may optionally qualify for an 'order` 
            as well as a unique name.
        */
        return h;
    }

    @Override
    public void configureAuthenticationExecutionPlan(final AuthenticationEventExecutionPlan plan) {
        if (feelingGoodOnASundayMorning()) {
            plan.registerAuthenticationHandler(myAuthenticationHandler());
        }
    }
}
```

## Step 3: Register Configuration

Now that we have properly created and registered our handler with the CAS authentication machinery, we just need to ensure that CAS is able to pick up our special configuration. To do so, create a `src/main/resources/META-INF/spring.factories` file and reference the configuration class in it as such:

```properties
org.springframework.boot.autoconfigure.EnableAutoConfiguration=com.example.cas.MyAuthenticationEventExecutionPlanConfiguration
```

Note that the configuration registration is not of CAS doing. It's a mechanism provided to CAS via [Spring Boot](http://docs.spring.io/spring-boot/docs/current/reference/html/boot-features-developing-auto-configuration.html)
and it's an efficient way to pick up and register components into the runtime application context without the additional overhead of component-scanning and such.


### Review

At runtime, CAS will try to automatically detect all components and beans that advertise themselves as `AuthenticationEventExecutionPlanConfigurer`s. Each detected `AuthenticationEventExecutionPlanConfigurer` is then invoked to register its own authentication execution plan. The result of this operation at the end will produce
a ready-made collection of authentication handlers that are ready to be invoked by CAS in the given order defined, if any.

## What's Next?

CAS `5.1.0` is not released today in GA form. The development team is working to make sure the CAS `5.1.0` release is 
on [schedule](https://github.com/apereo/cas/milestones). Additional release candidates
and more updates will likely be released prior to the official GA release.

## Get Involved

- Start your CAS deployment today. Try out features and [share feedback](https://apereo.github.io/cas/Mailing-Lists.html).
- Better yet, [contribute patches](https://apereo.github.io/cas/developer/Contributor-Guidelines.html).
- Review and suggest documentation improvements.
- Review the release schedule and make sure you report your desired feature requests on the project's issue tracker.

[Misagh Moayyed](https://fawnoos.com)
