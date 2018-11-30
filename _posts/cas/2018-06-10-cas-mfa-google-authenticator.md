---
layout:     post
title:      CAS Multifactor Authentication with Google Authenticator
summary:    A short walkthrough to demonstrate how one might turn on multifactor authentication with CAS using Google Authenticator, leveraging a variety of triggers.
tags:       [CAS,MFA]
---

<div class="alert alert-success">
<strong>Collaborate</strong><br/>This blog is managed and hosted on GitHub. If you wish to update the contents of this post or if you have found an inaccuracy and wish to make corrections, we recommend that you please submit a pull request to <a href="https://github.com/apereo/apereo.github.io">this repository</a>.
</div>

A number of CAS deployments that intend to turn on multifactor authentication support tend to do so via Google Authenticator. This is a quick and *simplified* guide to demonstrate an approach to that use case along with some additional explanations regarding specific multifactor triggers and bypass options supported in CAS today.

Our task list is rather short:

1. Configure LDAP authentication with CAS
2. Trigger Google Authenticator for users who belong to the `mfa-eligible` group, indicated by the `memberOf` attribute on the LDAP user account.
3. Design and explore bypass options that would override the above trigger where needed.

# Environment

- CAS `5.3.x`
- [CAS Maven WAR Overlay](https://github.com/apereo/cas-overlay-template) (The `5.3` branch specifically)

# Configuring Authentication

Prior to configuring *multiple* factors of authentication, we need to first establish a primary mode of validating credentials. To kill two birds with one stone [1], we are going to o address yet another common use case and keep things simple by sticking with [LDAP authentication](https://apereo.github.io/cas/development/installation/LDAP-Authentication.html). The strategy here, as indicated by the CAS documentation, is to declare the intention/module in the build script and then configure the relevant `cas.authn.ldap[x]` settings for the directory server in use. Most commonly, that would translate into the following settings:

```properties
cas.authn.ldap[0].type=AUTHENTICATED
cas.authn.ldap[0].ldapUrl=ldaps://ldap1.example.org
cas.authn.ldap[0].baseDn=dc=example,dc=org
cas.authn.ldap[0].searchFilter=cn={user}
cas.authn.ldap[0].bindDn=cn=Directory Manager,dc=example,dc=org
cas.authn.ldap[0].bindCredential=...
```

Note that the method of authentication, whether on its own or using separate attribute repositories and queries must have the ability to resolve the needed attribute which will be used later by CAS to trigger multifactor authentication. For this context, the simplest way would be to let LDAP authentication retrieve the attribute directly from the directory server.  The following setting allows us to do just that:

```properties
cas.authn.ldap[0].principalAttributeList=memberOf
```

At this point in the authentication flow, we have established an authenticated subject that would be populated with fetched attribute `memberOf`.

# Configuring Google Authenticator

Here, our task is to enable [Google Authenticator](https://apereo.github.io/cas/development/installation/GoogleAuthenticator-Authentication.html) in CAS. Practically, similar to the LDAP authentication configuration, this involves declaring the right module in the build and then providing specific Google Authenticator settings to CAS properties. Things such as the issuer, label, etc.

Most commonly, the required settings would translate into the following:

```properties
cas.authn.mfa.gauth.issuer=CAS
cas.authn.mfa.gauth.label=CASLabel
```

At this point, we have enabled Google Authenticator and we just need to find a way to instruct CAS to route the authentication flow over to Google Authenticator in the appropriate condition. This is where triggers come into place.

# Configuring Multifactor Authentication Triggers

The entire purpose of a trigger here is to detect a condition by which the authentication flow should be rerouted. There are a large number of [triggers supported by CAS](https://apereo.github.io/cas/development/installation/Configuring-Multifactor-Authentication-Triggers.html), all of which kick into action and behave all the same regardless of the multifactor authentication provider. Our task here is to build a special condition that activates multifactor authentication if any of the values assigned to the attribute `memberOf` contain the value `mfa-eligible`:

```properties
cas.authn.mfa.globalPrincipalAttributeNameTriggers=memberOf
cas.authn.mfa.globalPrincipalAttributeValueRegex=mfa-eligible
```

Notice that the conditions above do not indicate anything about Google Authenticator. If the above condition holds true, how does CAS know that the authentication flow should be routed to *Google Authenticator*?

Per the CAS documentation:

> Trigger MFA based on a principal attribute(s) whose value(s) matches a regex pattern. Note that this behavior is only applicable if there is only a single MFA provider configured since that would allow CAS to know what provider to next activate.

In other words, if the above condition holds true and CAS is to route to *a* multifactor authentication flow, that would obviously be one supported and provided by Google Authenticator since that's the only provider that is currently configured to CAS. Of course, if there are multiple providers available at runtime (i.e. U2F FIDO, YubiKey, etc) then we would need massage the condition since the automatic detection of the multifactor provider would not be immediately obvious...and that sort of thing would be outside the scope of this tutorial.

# Google Authenticator Device Registration

Per the CAS documentation, you need to decide the type of registry that would hold onto devices registered with CAS, authorized to use Google Authenticator. A more common use case here would be to use a relational database to manage issued tokens and devices. There is very little for you to do here, since the device registration flow is built into CAS by default, allowing new devices to register themselves with the system by scanning a QR code and holding on the scratch codes that are produced by CAS.

# Multifactor Authentication Bypass

Once the above conditions determine that Google Authenticator may be activated as the next step in the authentication flow, CAS presents bypass rules are then consulted to calculate whether the provider should ignore the request and skip MFA conditionally. There are a variety of strategies you may choose to bypass multifactor authentication, one of which is a more static strategy of defining the ignore rule at the service policy level:

```json
{
  "@class" : "org.apereo.cas.services.RegexRegisteredService",
  "serviceId" : "^(https|imaps)://.*",
  "id" : 100,
  "multifactorPolicy" : {
    "@class" : "org.apereo.cas.services.DefaultRegisteredServiceMultifactorPolicy",
    "bypassEnabled" : "true"
  }
}
```

A more dynamic strategy, of course, would be to calculate the end result via a Groovy script. The outcome of the script, if `true` indicates that multifactor authentication for the requested provider should proceed. Otherwise `false` indicates that multifactor authentication for this provider should be skipped and bypassed.

The path to the groovy script must surely be taught to CAS as a setting:

```properties
cas.authn.mfa.gauth.bypass.type=GROOVY
cas.authn.mfa.gauth.bypass.groovy.location=file:/etc/cas/config/MultifactorBypass.groovy
```

...and a `MultifactorBypass.groovy` script would be:

```groovy
import java.util.*

def boolean run(final Object... args) {
    def authentication = args[0]
    def principal = args[1]
    def registeredService = args[2]
    def provider = args[3]
    def logger = args[4]
    def httpRequest = args[5]

    // Ignore MFA for everyone, except casuser
    logger.info("Evaluating multifactor authn bypass rules for {}", principal)
    return principal.id.equalsIgnoreCase("casuser")
}
```

# Summary

I hope this review was of some help to you and I am sure that both this post as well as the functionality it attempts to explain can be improved in any number of ways. Please feel free to [engage and contribute](https://apereo.github.io/cas/developer/Contributor-Guidelines.html) as best as you can.

[Misagh Moayyed](https://twitter.com/misagh84)

[1] No birds were harmed during the production of this blog post.
