---
layout:     post
title:      Apereo CAS - MaxMind Geo2IP ISP Integration
summary:    Learn how you may determine the Internet Service Provider, organization name, and autonomous system organization and number associated with the user's IP address in CAS using MaxMind services and present warnings in the authentication flow for the end-user if an IP address is matched.
tags:       [CAS]
---

<div class="alert alert-success">
  <strong>Collaborate</strong><br/>The blog is managed and hosted on GitHub. If you wish to update the contents of this post or if you have found an inaccuracy and wish to make corrections, we recommend that you please submit a pull request to <a href="https://github.com/apereo/apereo.github.io">this repository</a>.
</div>

I have been consulting on a CAS project with the main requirement of doing an integration with [MaxMind](https://www.maxmind.com/) GeoIP2 services. 

According to the MaxMind website:

> MaxMind GeoIP2 offerings identify the location and other characteristics of Internet users for a wide range of applications including content personalization, fraud detection, ad targeting, traffic analysis, compliance, geo-targeting, geo-fencing and digital rights management.

There certainly is an [existing integration](https://apereo.github.io/cas/5.3.x/installation/GeoTracking-Authentication-Requests.html) already with MaxMind and CAS, which is primarily giving CAS the ability to cross-check a browser-provided IP address against the MaxMind database to geolocate the request and perform additional processing later on, such as auditing the event with richer information or executing [risk-based authentication decisions](https://apereo.github.io/cas/5.3.x/installation/Configuring-Adaptive-Authentication.html).

Our particular use case here was a bit different. We were presented with a MaxMind database file that contained a list of IP addresses known to be linked to VPN services and anonymous service providers. Our objective was to examine the request for the provided IP address, cross-check against the MaxMind database and ultimately present a warning to the user if a match is found. Our initial assumption was that such a warning is presented to the after the _primary authentication_ event inclusive of any and all multifactor authentication flows such as [Duo Security](https://apereo.github.io/cas/5.3.x/installation/DuoSecurity-Authentication.html).

This sort of use case can easily be done in form of [webflow interrupts](https://apereo.github.io/cas/5.3.x/installation/Webflow-Customization-Interrupt.html). 

> CAS has the ability to pause and interrupt the authentication flow to reach out to external services and resources, querying for status and settings that would then dictate how CAS should manage and control the SSO session. Interrupt services are able to present notification messages to the user, provide options for redirects to external services, etc.

This sounds exactly like what we could use. We just need to provide our own particular interrupt services that handle the cross-examination of the IP address with MaxMind and we should be good to go. Let's do it.

<div class="alert alert-info">
  <strong>Collaborate</strong><br/>If you want to learn more about webflow interrupts, please see <a href="https://apereo.github.io/2017/08/30/cas-loginflow-interrupt/">this post</a>.
</div>

Our starting position is based on the following:

- CAS `5.3.x`
- Java 8
- [Maven Overlay](https://github.com/apereo/cas-overlay-template) (The `5.3` branch specifically)


## Configuration

First, we need to prepare the CAS overlay with the right set of dependencies to enable interrupt functionality and get access to the [MaxMind APIs](http://maxmind.github.io/GeoIP2-java/):

```xml
<dependency>
  <groupId>org.apereo.cas</groupId>
  <artifactId>cas-server-support-interrupt-webflow</artifactId>
  <version>${cas.version}</version>
</dependency>

<dependency>
    <groupId>com.maxmind.geoip2</groupId>
    <artifactId>geoip2</artifactId>
    <version>2.12.0</version>
</dependency>
```

Next, we can create our own [configuration component](https://apereo.github.io/cas/5.3.x/installation/Configuration-Management-Extensions.html) and design the declaration of our interrupt service, tasked to talk to MaxMind APIs:

```java
@Configuration("SomeConfiguration")
@EnableConfigurationProperties(CasConfigurationProperties.class)
public class SomeConfiguration {

    @Value("${our.maxmind.isp-file:file:/etc/cas/config/maxmind/GeoIP2-ISP.mmdb}")
    private Resource ispDatabase;

    @Bean
    public InterruptInquirer interruptInquirer() {
        return new MaxmindInterruptInquirer(ispDatabase);
    }
}
```

Note that out particular `MaxmindInterruptInquirer` gains access to the MaxMind ISP database file to be used for cross-examination of IP addresses. Obviously, we need to design the `MaxmindInterruptInquirer` itself:

```java
public class MaxmindInterruptInquirer implements InterruptInquirer {
    private final DatabaseReader ispDatabaseReader;

    public MaxmindInterruptInquirer(final Resource ispResource) {
        try {
            File ispFile = ispResource.getFile();
            ispDatabaseReader = new DatabaseReader.Builder(ispFile).build();
        } catch (final Exception e) {
            throw new RuntimeException(e);
        }
    }

    @Override
    public InterruptResponse inquire(Authentication authentication,
                                     RegisteredService registeredService,
                                     Service service,
                                     Credential credential) {
        HttpServletRequest request = WebUtils.getHttpServletRequestFromExternalWebflowContext();
        String address = request.getRemoteAddr();
        /*
            Check the address in Maxmind database and return back the proper response
        */
        ...
    }
}
```

Here is what happens:

After all authentication flows have completed, the interrupt webflow kicks in and picks up our `MaxmindInterruptInquirer` component. It begins to examine the IP address linked to this request and does a look-up to find a match in the MaxMind database. If and when found, it will pass a response back up which would then get translated and stuff into the webflow available to the warning page for your user's pleasure. 

That's it. 

_I should note that our requirement later on changed to present the same sort of warning **before** any of the authentication flows have commenced. An interesting nuance indeed, as the user must face the warning page before CAS presents the login screen and family in the browser, and one we might cover in a separate blog post._


## Finale

I hope this review was of some help to you and I am sure that both this post as well as the functionality it attempts to explain can be improved in any number of ways. Please feel free to [engage and contribute](https://apereo.github.io/cas/developer/Contributor-Guidelines.html) as best as you can.

[Misagh Moayyed](https://fawnoos.com)
