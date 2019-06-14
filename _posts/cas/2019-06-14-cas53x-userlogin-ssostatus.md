---
layout:     post
title:      Apereo CAS - Are We Logged In Yet?
summary:    Learn how to modify and extend a CAS deployment to determine whether an SSO session is still valid and tied to a user authentication session.
tags:       [CAS]
---

<div class="alert alert-success">
<strong>Collaborate</strong><br/>This blog is managed and hosted on GitHub. If you wish to update the contents of this post or if you have found an inaccuracy and wish to make corrections, we recommend that you please submit a pull request to <a href="https://github.com/apereo/apereo.github.io">this repository</a>.
</div>

# Overview

As users navigate back and forth between applications that are integrated with CAS, SSO sessions are established for each browser session where a special cookie is exchanged with the browser to maintain a link between the user SSO session and the underlying CAS server managing that state typically via its ticket registry. This special cookie typically is restricted to the CAS server only and is also signed and encrypted to protect replay attacks, etc.

Of course, users may log out of CAS removing the SSO session and the cookie, or the SSO session might timeout on its own thus invalidating the cookie state. In either scenario, a valid question might be:

> How could an application determine whether an SSO session tied to the user's browser is still valid and accepted by CAS?

A more traditional approach would be to try to take advantage of the `gateway` feature of the [CAS protocol](https://apereo.github.io/cas/development/protocol/CAS-Protocol-Specification.html):

> If this parameter is set, CAS will not ask the client for credentials. If the client has a pre-existing single sign-on session with CAS, or if a single sign-on session can be established through non-interactive means (i.e. trust authentication), CAS MAY redirect the client to the URL specified by the service parameter, appending a valid service ticket...If the client does not have a single sign-on session with CAS, and a non-interactive authentication cannot be established, CAS MUST redirect the client to the URL specified by the service parameter with no “ticket” parameter appended to the URL.

The basic premise is receiving a `ticket` back from CAS indicates a valid SSO session and its absence indicates otherwise. In this scenario, CAS does attempt to validate and verify the SSO session tied to the CAS cookie to determine whether or not a ticket should be issued.

While this works for certain scenarios, it is quite chatty and does involve quite of bit of back and forth. As an alternative, another approach would be to build a special endpoint inside CAS that would be more *REST* friendly to check on the status of SSO without involving the browser as much with ‍`302` redirects and without the implicit assumption of the CAS protocol as the mediator. Note that one caveat with this new approach would be that the caller, our application, would need to have access to the CAS special cookie to pass it onto our endpoint for follow-up processing and reporting on the SSO session status.

<div class="alert alert-info">
<strong>Existing Functionality</strong><br/>Note that an <code>sso</code> endpoint does exist in CAS already that is modeled as a Spring Boot Actuator endpoint which more or less delivers this functionality. Our use case here is slightly more custom, thus the need for a new special endpoint that is in concept similar to the <code>sso</code> endpoint.
</div>

Let's get started with a prototype. Our starting position is based on:

- CAS `5.3.x`
- Java `8`
- [CLI JSON Processor `jq`](https://stedolan.github.io/jq/)
- [CAS WAR Overlay](https://github.com/apereo/cas-overlay-template/tree/5.3)

# Configuration

Let's [extend our CAS configuration](https://apereo.github.io/cas/5.3.x/installation/Configuration-Management-Extensions.html) to include a special endpoint to report back on SSO status:

```java
@Configuration("SomeConfiguration")
public class SomeConfiguration {
    @Autowired
    @Qualifier("defaultTicketRegistrySupport")
    private TicketRegistrySupport ticketRegistrySupport;

    @Autowired
    @Qualifier("cookieValueManager")
    private CookieValueManager cookieValueManager;

    @Bean
    public IsLoggedInController isLoggedInController() {
        return new IsLoggedInController(cookieValueManager,
            ticketRegistrySupport);
    }
}
```

Our humble endpoint, simply named as `isloggedin`, could be something as follows:

```java
@RequiredArgsConstructor
@RestController("isLoggedInController")
public class IsLoggedInController {
    private final CookieValueManager cookieValueManager;
    private final TicketRegistrySupport ticketRegistrySupport;

    @GetMapping(path = {"/isloggedin"},
                produces = MediaType.APPLICATION_JSON_VALUE)
    public Map isLoggedIn(@RequestParam("tgc")
                          String cookieValue) {
        try {
            String tgtId = cookieValueManager.obtainCookieValue(cookieValue, request);
            Authentication auth = ticketRegistrySupport.getAuthenticationFrom(tgtId);
            if (auth != null) {
                Principal principal = auth.getPrincipal();
                Map attributes = principal.getAttributes();
                Map results = new HashMap();
                /*
                Populate the results with values
                from the principal and/or attributes...
                */
                return results;
            }
            return new HashMap<>();
        catch (Exception e) {
            LOGGER.error(e.getMessage(), e);
            return new HashMap<>();
        }
    }
}
```

The response type returned is set to `application/json` and the response status code is `200`.

We should also turn off cookie session pinning:

```bash
cas.tgc.pinToSession=false
```

Finally, to invoke the script a client application would invoke the equivalent of the following request:

```bash
curl https://sso.example.org/cas/isloggedin?tgc=[ticket-granting cookie value]
```

Remember that the caller should be able to read the CAS cookie. Its only job is to pass it onto CAS, as the cookie content is entirely meaningless and the CAS server is the only authority who can decrypt and parse its contents.

# So...

I hope this review was of some help to you and I am sure that both this post as well as the functionality it attempts to explain can be improved in any number of ways. Please know that all other use cases, scenarios, features, and theories certainly [are possible](https://apereo.github.io/2017/02/18/onthe-theoryof-possibility/) as well. Feel free to [engage and contribute](https://apereo.github.io/cas/developer/Contributor-Guidelines.html) as best as you can.

Happy Coding,

[Misagh Moayyed](https://twitter.com/misagh84)