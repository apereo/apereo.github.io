---
layout:     post
title:      Apereo CAS - Custom Authentication & Attribute Sources
summary:    Master writing custom authentication handlers/schemes in CAS and learn how to design custom data sources that can produce user claims and attributes.
tags:       [CAS]
---

<div class="alert alert-success">
<strong>Collaborate</strong><br/>This blog is managed and hosted on GitHub. If you wish to update the contents of this post or if you have found an inaccuracy and wish to make corrections, we recommend that you please submit a pull request to <a href="https://github.com/apereo/apereo.github.io">this repository</a>.
</div>

While [authentication support](https://apereo.github.io/cas/development/installation/Configuring-Authentication-Components.html)
in CAS for a variety of systems is somewhat comprehensive and complex, a common deployment use case
is the task of designing custom authentication schemes.

This post:

- Describes the necessary steps needed to design and register a custom authentication strategy (i.e. `AuthenticationHandler`).
- Provides an implementation overview of designing customized attribute repository sources (i.e. `IPersonAttributeDao`) to fetch user claims.

# Audience

This post is intended for Java developers with a basic-to-medium familiarity with Spring, Spring Boot, and Spring Webflow. This is **NOT** a tutorial to be used verbatim via copy/paste. It is instead a recipe for developers to extend CAS based on specialized requirements.

This tutorial specifically requires and focuses on:

- CAS `5.3.x`
- Java 8
- [Maven WAR Overlay](https://apereo.github.io/cas/development/installation/Maven-Overlay-Installation.html)

# Customized Authentication

The overall tasks may be categorized as such:

1. Design the authentication handler
2. Register the authentication handler with the CAS authentication engine.
3. Tell CAS to recognize the registration record and authentication configuration.

<div class="alert alert-success">
<strong>Collaborate</strong><br/>Before stepping into a development mode, consider whether your choice of authentication handler or attribute repository implementation may be contributed back to CAS as a first-class feature, specially if the system with which you are interfacing is somewhat mainstream, robust and in reasonable demand.</div>

## Design Authentication Handlers

The first step is to define the skeleton for the authentication handler itself. This is the core principal component whose job is to declare support for a given type of credential only to then attempt to validate it and produce a successful result. The core parent component from which all handlers extend is the `AuthenticationHandler` interface.

With the assumption that the type of credentials used here deal with the traditional username and password, noted by the infamous `UsernamePasswordCredential` below, a more appropriate skeleton to define for a custom authentication handler may seem like the following:

```java
public class MyAuthenticationHandler extends AbstractUsernamePasswordAuthenticationHandler {
    ...
    protected HandlerResult authenticateUsernamePasswordInternal(final UsernamePasswordCredential credential,
                                                                 final String originalPassword) {
        if (everythingLooksGood()) {
            return createHandlerResult(credential,
                    this.principalFactory.createPrincipal(username), new ArrayList<>());
        }
        throw new FailedLoginException("Sorry, you have failed!");
    }
    ...
}
```

Note that:

- Authentication handlers have the ability to produce a fully resolved principal along with attributes. If you have the ability to retrieve attributes
from the same place as the original user/principal account store, the final `Principal` object that is resolved here must then be able to carry all
those attributes and claims inside it at construction time.

- The last parameter, `new ArrayList<>()`, is effectively a collection of warnings that are eventually worked into the authentication chain and conditionally shown to the user. Examples of such warnings include password status nearing an expiration date, etc.

- Authentication handlers also have the ability to block authentication by throwing a number of specific exceptions. A more common exception to throw
back is `FailedLoginException` to note authentication failure. Other specific exceptions may be thrown to indicate abnormalities with the account status
itself, such as `AccountDisabledException`.

- Various other components such as `PrincipalNameTransformer`s, `PasswordEncoder`s and such may also be injected into our handler if need be, though these are skipped for now in this post for simplicity.

## Register Authentication Handlers

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

## Register Configuration

Now that we have properly created and registered our handler with the CAS authentication machinery, we just need to ensure that CAS is able to pick up our special configuration. To do so, create a `src/main/resources/META-INF/spring.factories` file and reference the configuration class in it as such:

```properties
org.springframework.boot.autoconfigure.EnableAutoConfiguration=com.example.cas.MyAuthenticationEventExecutionPlanConfiguration
```

Note that the configuration registration step is not of CAS doing. It's a mechanism provided to CAS via [Spring Boot](http://docs.spring.io/spring-boot/docs/current/reference/html/boot-features-developing-auto-configuration.html)
and it's an efficient way to pick up and register components into the runtime application context without the additional overhead of component-scanning and such.

At runtime, CAS will try to automatically detect all components and beans that advertise themselves as `AuthenticationEventExecutionPlanConfigurer`s. Each detected `AuthenticationEventExecutionPlanConfigurer` is then invoked to register its own authentication execution plan. The result of this operation at the end will produce a ready-made collection of authentication handlers that are ready to be invoked by CAS in the given order defined if any.

# Customized Attribute Repository

Sometimes the method of authentication at hand is unable to produce user attributes, or perhaps you may want to fetch user claims and attributes from a variety of other sources and combine them with the what's fetched from the authentication source. In either scenario, CAS provides a separate component called *Attribute Repository* whose task to establish a link between CAS and the *real* attribute source and its execution is simply tied to the authentication flow somewhat invisibly. There are a lot of attribute repository options supported in CAS by default, and if support for your particular attribute source is absent in CAS, you can certainly build support for that system using the following instructions.

## Design Attribute Repository

Attribute repository implementations need to be based on top of the [Person Directory](https://github.com/apereo/person-directory) project, which is a toolkit for resolving persons and attributes from a variety of underlying sources. It consists of a collection of `IPersonAttributeDao`s that retrieve, cache, resolve, aggregate and merge person attributes.

The following represents a simple outline of a given attribute repository implementation:

```java
package com.example.cas;

public class FancyPersonAttributeDao extends BasePersonAttributeDao {
    private final IUsernameAttributeProvider usernameAttributeProvider = new SimpleUsernameAttributeProvider();

    @Override
    @SneakyThrows
    public IPersonAttributes getPerson(final String uid) {
        /*
            Stuff happens to contact the downstream system and fetch attributes for [uid]...
        */
        return new CaseInsensitiveNamedPersonImpl(uid, attributes);
    }

    @Override
    public Set<IPersonAttributes> getPeople(final Map<String, Object> map) {
        return getPeopleWithMultivaluedAttributes(stuffAttributesIntoList(map));
    }

    @Override
    public Set<IPersonAttributes> getPeopleWithMultivaluedAttributes(final Map<String, List<Object>> map) {
        final Set<IPersonAttributes> people = new LinkedHashSet();
        final String username = this.usernameAttributeProvider.getUsernameFromQuery(map);
        final IPersonAttributes person = this.getPerson(username);
        if (person != null) {
            people.add(person);
        }

        return people;
    }

    @Override
    public Set<String> getPossibleUserAttributeNames() {
        ...
    }

    @Override
    public Set<String> getAvailableQueryAttributes() {
        ...
    }
}
```

## Register Attribute Repository

Once the repository is designed, it needs to be registered with CAS and put into the runtime engine. This is done via the magic of `@Configuration` classes that are picked up automatically at runtime, per your approval, whose job is to understand how to dynamically modify the application context. To do this, we can reuse the configuration class as above to declare our `IPersonAttributeDao` bean:

```java
@ConditionalOnMissingBean(name = "fancyPersonAttributeDao")
@Bean
public IPersonAttributeDao fancyPersonAttributeDao() {
    return new FancyPersonAttributeDao(...);
}
```

Note that each attribute repository implementation may be assigned a specific *order* which is a numeric weight that determines its execution position once attribute resolution kicks into action. This is a bit you can usually ignore, but it becomes rather important if you decide to design multiple repository implementations whose execution depends on one another's results. (i.e one repository might need an attribute value from another before it can run its own query).

So, once defined we can to register it with CAS inside the same configuration class:

```java
@ConditionalOnMissingBean(name = "fancyAttributeRepositoryPlanConfigurer")
@Bean
public PersonDirectoryAttributeRepositoryPlanConfigurer fancyAttributeRepositoryPlanConfigurer() {
    return new PersonDirectoryAttributeRepositoryPlanConfigurer() {
        @Override
        public void configureAttributeRepositoryPlan(final PersonDirectoryAttributeRepositoryPlan plan) {
            if (mustRegisterAttributeRepositoryForTheWin()) {
                plan.registerAttributeRepository(fancyPersonAttributeDao());
            }
        }
    };
}
```

Of course, if you decide to move the definition and registration steps into a separate `@Configuration` class, then the location of that component will need to be taught to the runtime using the same `src/main/resources/META-INF/spring.factories` file noted above.

# What About...?

- [CAS Multifactor Authentication with Duo Security](https://apereo.github.io/2018/01/08/cas-mfa-duosecurity/)
- [CAS 5 LDAP AuthN and Jasypt Configuration](https://apereo.github.io/2017/03/24/cas51-ldapauthnjasypt-tutorial/)
- [CAS 5 SAML2 Delegated AuthN Tutorial](https://apereo.github.io/2017/03/22/cas51-delauthn-tutorial/)
- [CAS 5 Linking Accounts with Delegated AuthN](https://apereo.github.io/2018/04/20/cas-delegated-authn-account-linking/)
- [CAS Multifactor Authentication with Google Authenticator](https://apereo.github.io/2018/06/10/cas-mfa-google-authenticator/)

# So...

It's important that you start off simple and make changes one step at a time. Once you have a functional environment, you can gradually and slowly add customizations to move files around.

I hope this review was of some help to you and I am sure that both this post as well as the functionality it attempts to explain can be improved in any number of ways. Please feel free to [engage and contribute](https://apereo.github.io/cas/developer/Contributor-Guidelines.html) as best as you can.

[Misagh Moayyed](https://twitter.com/misagh84)