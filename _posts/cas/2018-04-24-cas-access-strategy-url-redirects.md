---
layout:     post
title:      Apereo CAS - Access Strategy External URL Redirects
summary:    A quick use case walkthrough where the authentication flows in CAS is to be redirected to a customized external URL if service access is denied.
tags:       [CAS]
---

<div class="alert alert-success">
<strong>Collaborate</strong><br/>This blog is managed and hosted on GitHub. If you wish to update the contents of this post or if you have found an inaccuracy and wish to make corrections, we recommend that you please submit a pull request to <a href="https://github.com/apereo/apereo.github.io">this repository</a>.
</div>

# Overview

CAS has long had support for centralized authorization and [access control policies](https://apereo.github.io/cas/development/installation/Configuring-Service-Access-Strategy.html) on a per-application basis, I believe starting from CAS `4.2.x`. These policies come in a variety of strategies with a number of options to control application access, SSO participation, the presence of a certain number of required claims before access can be granted and so on. In the event that the policy denies user access, it may often be desirable to redirect the authentication flow to a URL that would have instructions for the end-user and it might even be ideal if the construction of that URL could be customized in dynamic ways for better user experience.

This tutorial specifically focuses on:

- CAS `5.3.0-RC4`
- Java 8
- [Maven WAR Overlay](https://github.com/apereo/cas-overlay-template)
- [Delegated Authentication](https://apereo.github.io/cas/development/integration/Delegate-Authentication.html)

You may also be interested in this related blog post, detailing [attribute-based access control](https://apereo.github.io/2018/02/20/cas-service-rbac-attributeresolution/) in CAS.

# Use Case

Given our starting position of defining a customized unauthorized redirect URL in situations where access to a CAS-enabled service is denied, you should take note of the following service definition that may be recognized as part of CAS using a [JSON service registry](https://apereo.github.io/cas/development/installation/JSON-Service-Management.html):

```json
{
  "@class" : "org.apereo.cas.services.RegexRegisteredService",
  "serviceId" : "https://app.example.org",
  "name" : "Awesome Example App",
  "id" : 1,
  "description" : "The example application is an application that provides examples",
  "evaluationOrder" : 100,
  "accessStrategy" : {
    "@class" : "org.apereo.cas.services.DefaultRegisteredServiceAccessStrategy",
    "enabled" : true,
    "unauthorizedRedirectUrl": "https://billboard.example.org"
  }
}
```

It should be obvious that the `unauthorizedRedirectUrl` field of the configured access strategy allows one to define a URL to which CAS might redirect once service access is denied. Of course, we have not defined any particular rules that would prevent one from accessing this application via CAS so let's do just that with a few modifications:

```json
{
  "@class" : "org.apereo.cas.services.RegexRegisteredService",
  "serviceId" : "https://app.example.org",
  "name" : "Awesome Example App",
  "id" : 1,
  "description" : "The example application is an application that provides examples",
  "evaluationOrder" : 100,
  "accessStrategy" : {
    "@class" : "org.apereo.cas.services.DefaultRegisteredServiceAccessStrategy",
    "enabled" : true,
    "unauthorizedRedirectUrl": "https://billboard.example.org",
    "requiredAttributes" : {
      "@class" : "java.util.HashMap",
      "userAccessLevel" : [ "java.util.HashSet", [ "system" ] ]
    }
  }
}
```

With the above changes, CAS will present access to our example application if the authenticated user does *not* have a claim `userAccessLevel` with a possible value of `system`. If that condition holds true, CAS should try to redirect the flow back to `https://billboard.example.org`. Fairly simple.

However, one issue remains which is the ability to customize the redirect URL in more dynamic ways, depending on the properties of the service definition, etc. The URL might need special query parameters, or different enoding semantics, etc. How could that be done?

# Dynamic Unauthorized URLs

We can start by preparing CAS with a [customized configuration component](https://apereo.github.io/cas/development/installation/Configuration-Management-Extensions.html) that would house our customizations for this use case. Once that is done, take note of the following bean definition posted in `CasSupportActionsConfiguration.java` today:


```java
@RefreshScope
@Bean
@ConditionalOnMissingBean(name = "redirectUnauthorizedServiceUrlAction")
public Action redirectUnauthorizedServiceUrlAction() {
    return new RedirectUnauthorizedServiceUrlAction(servicesManager);
}
```

Note how the bean is marked as conditional, meaning it will only be used by CAS if an alternative definition by the same is *not* found. So, in order for CAS to pick up our own alternative implementation, we are going to provide that bean definition in our own configuration class as such:

```java
@Bean
public Action redirectUnauthorizedServiceUrlAction() {
    return new MyRedirectUnauthorizedServiceUrlAction(servicesManager);
}
```

<div class="alert alert-info">
<strong>Compile Dependencies</strong><br/>Note that in order for the CAS overlay build to compile our changes and put them to good use, the overlay must be prepared with the required module used during the compilation phase. Otherwise, there will be errors complaining about missing symbols, etc.</div>

Now, it's time to actually design our very own `DynamicRedirectUnauthorizedServiceUrlAction`. Here is a modest example:

```java
public class MyRedirectUnauthorizedServiceUrlAction extends RedirectUnauthorizedServiceUrlAction {
    ...

    @Override
    protected URI determineUnauthorizedServiceRedirectUrl(RequestContext context) {
        final URI redirectUrl = WebUtils.getUnauthorizedRedirectUrlIntoFlowScope(context);

        final Event currentEvent = context.getCurrentEvent();
        final AttributeMap eventAttributes = currentEvent.getAttributes();

        final PrincipalException error = (PrincipalException)
            eventAttributes.get("error", PrincipalException.class);
        final UnauthorizedServiceForPrincipalException serviceError = (UnauthorizedServiceForPrincipalException)
            error.getHandlerErrors().get(UnauthorizedServiceForPrincipalException.class.getSimpleName());

        LOGGER.info("Calculating URL for service {} & principal {} with attributes {}",
            serviceError.getRegisteredService().getName(),
            serviceError.getPrincipalId(),
            serviceError.getAttributes());

        /*
           Calculate the required URI, or simply return the default...
        */
        return redirectUrl;
    }
}
```

That should do it. The very next time you build and deploy the changes, CAS should pick up our own bean definition and accompanying implementation class. It should be obvious that inside the class above, you have options to calculate the unauthorized redirect URL as you wish while having access to the underlying service definition object, the authenticated principal, and any retrieved attributes.

# Summary

I hope this review was of some help to you and I am sure that both this post as well as the functionality it attempts to explain can be improved in any number of ways. Please feel free to [engage and contribute](https://apereo.github.io/cas/developer/Contributor-Guidelines.html) as best as you can.

Happy Coding,

[Misagh Moayyed](https://twitter.com/misagh84)
