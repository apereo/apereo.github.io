---
layout:     post
title:      Apereo CAS - Scripting Multifactor Authentication Triggers
summary:    Learn how Apereo CAS may be configured to trigger multifactor authentication using Groovy conditionally decide whether MFA should be triggered for internal vs. external access, taking into account IP ranges, LDAP groups, etc.
tags:       [CAS,MFA]
---

<div class="alert alert-success">
  <strong>Collaborate</strong><br/>The blog is managed and hosted on GitHub. If you wish to update the contents of this post or if you have found an inaccuracy and wish to make corrections, we recommend that you please submit a pull request to <a href="https://github.com/apereo/apereo.github.io">this repository</a>.
</div>

<div class="alert alert-info">
  <strong>Contributed Content</strong><br/>Keith Conger of Colorado College, an active member of the CAS community, was kind enough to contribute this guide.
</div>

If you have configured multifactor authentication with CAS with a provider (i.e. [Duo Security](https://apereo.github.io/cas/5.3.x/installation/DuoSecurity-Authentication.html)), you may find yourself in need of conditionally triggering MFA based on a variety of factors rather dynamically. Here is a possible scenario:

- Allow internal access to a service without forcing MFA via IP range
- Rejecting external access to a service unless in MFA LDAP group

CAS provides a large number of strategies to [trigger multifactor authentication](https://apereo.github.io/cas/5.3.x/installation/Configuring-Multifactor-Authentication-Triggers.html). To deliver the use case, we can take advantage of a Groovy-based trigger to implement said conditions. The script is invoked by CAS globally (regardless of application, user, MFA provider, etc) whose outcome should determine whether an MFA provider can take control of the subsequent step in the authentication flow.

Our starting position is based on the following:

- CAS `5.3.x`
- Java `8`
- [Maven Overlay](https://github.com/apereo/cas-overlay-template) (The `5.3` branch specifically)

## Configuration

With [Duo Security](https://apereo.github.io/cas/5.3.x/installation/DuoSecurity-Authentication.html) configured as our multifactor authentication provider, we can start off with the following settings:

```properties
cas.audit.alternateClientAddrHeaderName=X-Forwarded-For
cas.authn.mfa.groovyScript=file:/path/to/GroovyScript.groovy
```

Here, we are teaching CAS to use the `X-Forwarded-For` header when fetching client IP addresses, and we are also indicating a reference path to our yet-to-be-written Groovy script.

The script itself would have the following structure:

```groovy
import java.util.*
import org.apereo.inspektr.common.web.*;

class GroovyMfaScript {

    String privateIPPattern = "(^127\\.0\\.0\\.1)";
    String mfaGroupPattern = "CN=MFA-Enabled";
    String servicePattern = "https://app.example.org";

    def String run(final Object... args) {
        def service = args[0];
        def registeredService = args[1];
        def authentication = args[2];
        def logger = args[3];

        if (service.id.contains(servicePattern)) {
            def clientInfo = ClientInfoHolder.getClientInfo();
            def clientIp = clientInfo.getClientIpAddress();
            logger.info("Client IP [{}]", clientIp);
            if (clientIp.find(privateIPPattern)) {
                logger.info("Internal IP address");

                def memberOf = authentication.principal.attributes['memberOf']
                for (String group : memberOf) {
                    if (group.contains(mfaGroupPattern)) {
                        logger.info("In MFA group");
                        return "mfa-duo";
                    }
                }
                return null;
            }
            return "mfa-duo";
        }
        return null;
    }
}
```

The above script goes through the following conditions:

- The requesting application is `https://app.example.org`.
- The incoming client IP address matches the pattern `(^127\\.0\\.0\\.1)`.
- The authenticated user carries a `memberOf` attribute with a value of `CN=MFA-Enabled`.

If all of those conditions are true, then MFA is activated...or else ignored. Note that the function of a Groovy trigger is not specific to a multifactor authentication provider. So long as the conditions execute correctly and the provider is configured properly, it can be used to signal any provider back to the authentication flow.

## Finale

Thanks to Keith Conger of Colorado College who was kind enough to share the above integration notes.

[Misagh Moayyed](https://fawnoos.com)
