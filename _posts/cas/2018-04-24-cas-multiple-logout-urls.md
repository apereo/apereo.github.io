---
layout:     post
title:      Apereo CAS - Handling Multiple Logout URLs
summary:    Extend the Apereo CAS server to allow for multiple logout URLs during SLO operations.
tags:       [CAS]
---

<div class="alert alert-success">
<strong>Collaborate</strong><br/>This blog is managed and hosted on GitHub. If you wish to update the contents of this post or if you have found an inaccuracy and wish to make corrections, we recommend that you please submit a pull request to <a href="https://github.com/apereo/apereo.github.io">this repository</a>.
</div>

# Overview

CAS has had [support for single logout](https://apereo.github.io/cas/development/installation/Logout-Single-Signout.html) for quite a while. This feature basically means that CAS is able to invalidate client application sessions in addition to its own SSO session, assuming client applications are ready to honor and accept logout requests with special configuration. When a CAS session ends, it notifies each of the services that the SSO session is no longer valid, and that relying parties need to invalidate their own session by processing a special logout request. Remember that the callback submitted to each CAS-protected application is simply *a notification*; nothing more. It is the *responsibility of the application* to intercept that notification and properly destroy the user authentication session, either manually, via a specific endpoint or more commonly via a CAS client library that supports SLO.

By default, applications are contacted by CAS using their *original URL* to receive the logout notification; which is simply the purified service URL used when an authentication request on behalf of the application is submitted to CAS. This tutorial focuses on ways one can customize the logout URL in more dynamic ways.

This tutorial deals with:

- CAS `5.3.0-RC4`
- Java 8
- [Maven](https://github.com/apereo/cas-overlay-template) Or [Gradle](https://github.com/apereo/cas-gradle-overlay-template) WAR Overlays
- [Single Logout](https://apereo.github.io/cas/development/installation/Logout-Single-Signout.html)

# Single Logout URL

In dealing with single logout operations, the URL endpoint to receive the logout notification can be customized on a per-application basis:

```json
{
  "@class" : "org.apereo.cas.services.RegexRegisteredService",
  "serviceId" : "https://\\w+.example.org",
  "name" : "Our Example Domain",
  "id" : 1,
  "description" : "The example domain provides examples in examplish ways",
  "logoutUrl" : "https://logout.example.org"
}
```

This is, of course, the simplest option and means that if CAS has established sessions with one or more applications that qualify for the above definition, those applications will receive logout notifications at the specified URL above when the logout engine in CAS begins to process records.

# Many Logout URLs

One should note that the `logoutUrl` above not only static but also singular. With configuration only, there is not a way for one to specify more than one URL in cases where that might be needed. While the service configuration above presents a rather simplified version of the feature, CAS itself provides the internal mechanics to recognize and handle a collection of logout URLs for a given application. Our task here would be to extend the configuration slightly to implement this scenario and inject the behavior into the runtime.

We can start by preparing CAS with a [customized configuration component](https://apereo.github.io/cas/development/installation/Configuration-Management-Extensions.html) that would house our customizations for this use case. Once that is done, take note of the following bean definition posted in `CasCoreLogoutConfiguration.java` today:


```java
@ConditionalOnMissingBean(name = "singleLogoutServiceLogoutUrlBuilder")
@Bean
public SingleLogoutServiceLogoutUrlBuilder singleLogoutServiceLogoutUrlBuilder() {
    return new DefaultSingleLogoutServiceLogoutUrlBuilder(this.urlValidator);
}
```

Note how the bean is marked as conditional, meaning it will only be used by CAS if an alternative definition by the same is *not* found. So, in order for CAS to pick up our own alternative implementation, we are going to provide that bean definition in our own configuration class as such:

```java
@Bean
public SingleLogoutServiceLogoutUrlBuilder singleLogoutServiceLogoutUrlBuilder() {
    return new CustomSingleLogoutServiceLogoutUrlBuilder(this.urlValidator);
}
```

<div class="alert alert-info">
<strong>Compile Dependencies</strong><br/>Note that in order for the CAS overlay build to compile our changes and put them to good use, the overlay must be prepared with the required module used during the compilation phase. Otherwise, there will be errors complaining about missing symbols, etc.</div>

Now, it's time to actually design our very own `CustomSingleLogoutServiceLogoutUrlBuilder`. Here is a modest example:

```java
public class CustomSingleLogoutServiceLogoutUrlBuilder extends DefaultSingleLogoutServiceLogoutUrlBuilder {

    ...
    public Collection<URL> determineLogoutUrl(RegisteredService registeredService, WebApplicationService service) {

        /*
            Stuff happens to determine the collection of the logout URLs
            given the provided service and its registered definition in the registry.
        */
    }

}
```

That should do it. The very next time you build and deploy the changes, CAS should pick up our own bean definition and accompanying implementation class. It should be obvious that inside the class above, you have options to calculate the logout URLs as you wish since the builder object is expected to return a collection of URLs. To fully make this behavior dynamic, you may want to invest time researching [service custom properties](https://apereo.github.io/cas/development/installation/Configuring-Service-Custom-Properties.html) and externalize the logout function with special tags designed as properties that would then be consumed and processed in the above component.

# So...

I hope this review was of some help to you and I am sure that both this post as well as the functionality it attempts to explain can be improved in any number of ways. Please feel free to [engage and contribute](https://apereo.github.io/cas/developer/Contributor-Guidelines.html) as best as you can.

Happy Coding,

[Misagh Moayyed](https://fawnoos.com)
