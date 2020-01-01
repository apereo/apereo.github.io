---
layout:     post
title:      Forced Authentication with Apereo CAS
summary:    Discourse on supporting forced authentication with the Apereo CAS server from the perspective of an application protected with mod-auth-cas, the Apache httpd module for CAS.
tags:       [CAS]
---

<div class="alert alert-success">
<strong>Collaborate</strong><br/>This blog is managed and hosted on GitHub. If you wish to update the contents of this post or if you have found an inaccuracy and wish to make corrections, we recommend that you please submit a pull request to <a href="https://github.com/apereo/apereo.github.io">this repository</a>.
</div>

This post summarizes a recent conversation I had with a few colleagues on strategies one may use to support forced authentication with CAS and the journey we went on to discover and diagnose a few integration issues with an application protected by [mod_auth_cas](https://github.com/apereo/mod_auth_cas).

Let's begin.

# The Problem

Some CAS deployments present with the rather common requirement to challenge the user to re-enter credentials in some applications. To accommodate this, it's likely that deployments may opt into creative yet *non-standard* solutions such as applications themselves prompting for credentials to replay them in a back-end call. This is problematic for a number of reasons:

- Applications present a differently styled login form.
- Applications directly get involved in handling user credentials.

Last but most important:

> The only thing necessary for the triumph of evil is for good men to replay credentials.

So, is there a way to force re-authentication with CAS?

# Forced Authentication

The [CAS protocol](https://apereo.github.io/cas/development/protocol/CAS-Protocol-Specification.html) has a specific parameter dedicated to forced authentication, named as `renew=true`.

If supplied as part of an authentication request:

> Single sign-on will be bypassed. In this case, CAS will require the client to present credentials regardless of the existence of a single sign-on session with CAS.

If supplied as part of a validation request:

> Ticket validation will only succeed if the service ticket was issued from the presentation of the user’s primary credentials. It will fail if the ticket was issued from a single sign-on session.

<div class="alert alert-info">
<strong>Version Caveat</strong><br/>If you have deployed CAS <code>5.2.x</code>, you need to at least be on <code>5.2.3</code> for the renew parameter to function correctly.</div>

It goes without saying that `renew=true` works best if you wish to let the application make that decision when needed. Alternatively, you may also control this behavior centrally by [marking the relevant application/service](https://apereo.github.io/cas/development/installation/Configuring-Service-Access-Strategy.html#disable-service-sso-access) in the CAS service registry (JSON file, etc) such that it would not participate in SSO and would always be asked for credentials regardless of what the application says.

# Real Life Example

Let's say we have an application at `https://secure-dev.example.org/groups/` that has SSO enabled.  We need one subfolder of that app at `https://secure-dev.example.org/groups/reauth/` to require re-authentication to access.

So, (assuming a [JSON service registry](https://apereo.github.io/cas/development/installation/JSON-Service-Management.html)), we have one service registration record requiring SSO to cover any app on the host. Note that SSO participation is by default on and it's perfectly good for us to practice laziness here.

```json
{
  @class: org.apereo.cas.services.RegexRegisteredService
  serviceId: ^https?://[\w]+-dev.example.org/.*
  name: secure-dev.example.org
  id: 1200
  description: Everything
  evaluationOrder: 1200
}
```

We set up another service registration with a lower (i.e. processed first; think of it like the Olympics rankings) evaluation order and `ssoEnabled: false` to cover the subfolder:

```json
{
  @class: org.apereo.cas.services.RegexRegisteredService
  serviceId: ^https?://[\w]+-dev.example.org/groups/reauth/.*
  name: secure-dev.example.org Groups Reauth
  id: 1200
  description: Groups Reauth
  evaluationOrder: 1100
  accessStrategy: {
    @class: org.apereo.cas.services.DefaultRegisteredServiceAccessStrategy
    ssoEnabled: false
  }
}
```

Our application, protected by [mod-auth-cas](https://github.com/apereo/mod_auth_cas) has the following configuration:

```xml
<Location /groups/reauth>
    AuthType CAS
    AuthName "CAS"
    CASScope /groups/reauth
    CASAuthNHeader SOME_LoginID
    CASScrubRequestHeaders On
    CASCookie MOD_AUTH_CAS_REAUTH
    Options None
    require valid-user
    Order allow, deny
    Allow from all
</Location>

<Location /groups>
    AuthType CAS
    AuthName "CAS"
    CASScope /
    CASAuthNHeader SOME_LoginID
    CASScrubRequestHeaders On
    CASCookie MOD_AUTH_CAS
    Options None
    require valid-user
    Order allow, deny
    Allow from all
</Location>
```

At first glance, this should do exactly as you would expect if only it weren't for a small caveat.

## The Caveat

If the request begins with `https://secure-dev.example.org/groups/reauth/` first and then goes to `https://secure-dev.example.org/groups/`, the user would be prompted to log in - as expected because those locations use different cookie names.  However, once logged in, the user would get caught in a redirect loop between `mod_auth_cas` and CAS.  It turns out that there were two issues.  One was that more precise location is placed first in the config:

```xml
<Location /groups/reauth>
   CASCookie MOD_AUTH_CAS_REAUTH
   CASScope /groups/reauth/
   ...
<Location>

<Location /groups>
   CASCookie MOD_AUTH_CAS
   CASScope /
   …
<Location>
```

This made mod_auth_cas use the last applicable `CASScope` directive which meant that the `MOD_AUTH_CAS_REAUTH` cookie was being set at `Path=/` instead of `Path=/groups/reauth/`.

This might have been fine except for the way mod_auth_cas parses the values in the `Cookie` header.  It *tokenizes* the header on `;` then iterates through each cookie string by matching the number of characters equal to the length of the expected cookie name defined by the `CASCookie` directive.  If the cookie string starts with the `CASCookie` name, it skips the next character,  assuming that it's `=` and takes all remaining characters. So what was happening was that, given the cookie header `Cookie: BLARG=WuzzleWuzzle;MOD_AUTH_CAS_REAUTH=foofoofoofoo;`, mod_auth_cas was matching the cookie string `MOD_AUTH_CAS_REAUTH=foofoofoofoo` with the `CASCookie` name of `MOD_AUTH_CAS`.  Finding that, it skipped the `_` and returned `REAUTH=foofoofoofoo` as the CAS cookie value.  That isn't a valid format for a CAS cookie so it redirected back to CAS.  CAS, finding a valid `TGC`, then performed SSO and redirected back to the service.  The service ticket was never validated because mod_auth_cas checks for the presence of a cookie before it checks for the ticket parameter.  Finding the invalid cookie again, it redirected back to CAS and so on until the browser threw up its hands in defeat.

So, just something to look out for:

- When using mod_auth_cas, configuration elements that share a scope (e.g. `/groups`, `/groups/reauth`) **MUST be listed in order of least to most precise**.
- The `CASCookie` directives that share a scope **MUST NOT be substrings of each other**.

# Summary

I hope this review was of some help to you and I am sure that both this post as well as the functionality it attempts to explain can be improved in any number of ways. Please feel free to [engage and contribute](https://apereo.github.io/cas/developer/Contributor-Guidelines.html) as best as you can.

...and of course, a very special thanks to all colleagues who took part in this post, exchanged dialogue, verified behavior and generously took the time to share their analysis and findings. Thank you.

[Misagh Moayyed](https://fawnoos.com)
