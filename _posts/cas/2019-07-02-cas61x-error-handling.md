---
layout:     post
title:      Apereo CAS - Handling Errors with Grace
summary:    Learn how to modify Apereo CAS to customize exception handling and produce localized error messages for your deployment.
tags:       [CAS]
---

<div class="alert alert-success">
<strong>Collaborate</strong><br/>This blog is managed and hosted on GitHub. If you wish to update the contents of this post or if you have found an inaccuracy and wish to make corrections, we recommend that you please submit a pull request to <a href="https://github.com/apereo/apereo.github.io">this repository</a>.
</div>

# Overview

An Apereo CAS server deployment can run into many errors at runtime during the authentication flow, some of which are by design and deliberately produced by the system and some can be created and massaged by custom code outside the core framework. Either way, there are flexibilities and extension points in place to allow a deployer to customize the authentication webflow when it comes to its error handling logic. This tutorial walks through a few strategies that expand on these features to create meaningful and specific error messages given locale and audience.

Our starting position is based on:

- CAS `6.1.x`
- Java `11`
- [CAS WAR Overlay](https://github.com/apereo/cas-overlay-template)

# Error Messages

When it comes to handling authentication failures, CAS ships with a few predefined messages baked into its own language bundles that map an error code to an error message. Customizations to error message should then require modifying a given language bundle to alter messages or add new error codes. 

The default language bundle is for the English language and is thus called `messages.properties` found at `src/main/resources` which you may need to pull into your own overlay but there may be an easier option. If there are any custom messages that need to be presented into views, they may also be formatted under `custom_messages.properties` files which allow you to both defined custom messages as well as those by CAS that need to be overwritten.

So this means I can simply create the language bundle for custom changes in my CAS overlay:

```bash
touch src/main/resources/custom_messages.properties
```

...and then add the following message:

```properties
authenticationFailure.FailedLoginException=Something went wrong!
```

Error codes that are relevant for webflow authentication failures are constructed using the prefix `authenticationFailure` and the simple name of the underlying exception. For example, if the authentication system in CAS prevents a login attempt due to an `AccountLockedException`, the relevant error code to put inside the language bundle as an override would be:

```properties
authenticationFailure.AccountLockedException=Your account is locked.
```

The error message should get picked up by CAS and displayed, once an `AccountLockedException` is recognized and handled.

# Custom Exceptions

Custom Java classes that model an `Exception` can be injected into CAS and recognized during the error handling process. For example, a custom `org.example.cas.VeryFancyException` Java exception thrown somewhere in the system by an entity during the authentication webflow can be taught to CAS using the following setting:

```properties
cas.authn.errors.exceptions=org.example.cas.MyFancyException
```

...and the relevant message code would be:

```properties
authenticationFailure.MyFancyException=Noooo...too much fanciness!
```

# Webflow Exception Handling

Webflow authentication errors may also be directly handled by tapping into the webflow error handling logic. This is the most flexible and yet more complicated approach that requires one to [extend the CAS configuration](https://apereo.github.io/cas/development/configuration/Configuration-Management-Extensions.html) to then inject the following component into the runtime:

```java
@Bean
public CasWebflowExceptionHandler myCasWebflowExceptionHandler() {
    return new MyCasWebflowExceptionHandler();
}
```

The bean name doesn't matter; only its type. The actual implementation of `MyCasWebflowExceptionHandler` would be similar to the following:

```java
@Getter
public class MyCasWebflowExceptionHandler
        implements CasWebflowExceptionHandler<MyFancyException> {

    private int order = 0;

    @Override
    public Event handle(Exception exception, 
                        RequestContext requestContext) {
      // return an event id that signals the transition in the authn webflow
    }

    @Override
    public boolean supports(Exception exception, 
                            RequestContext requestContext) {
        return exception instanceof MyFancyException;
    }
}
```

All implementations of `CasWebflowExceptionHandler` are *discovered* at runtime and then sorted based on their defined order. Those handlers
that declare their support and capability in dealing with the defined exception are iterated through to respond to the error and produce a meaningful event.

# So...

I hope this review was of some help to you and I am sure that both this post as well as the functionality it attempts to explain can be improved in any number of ways. Please know that all other use cases, scenarios, features, and theories certainly [are possible](https://apereo.github.io/2017/02/18/onthe-theoryof-possibility/) as well. Feel free to [engage and contribute](https://apereo.github.io/cas/developer/Contributor-Guidelines.html) as best as you can.

Happy Coding,

[Misagh Moayyed](https://twitter.com/misagh84)