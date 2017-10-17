---
layout:     post
title:      JWT Of All Things With CAS
summary:    A short tutorial on how to let Apereo CAS handle authentication events accompanied by JWTs.
tags:       [CAS]
---

<!--
<div class="alert alert-danger">
  <strong>WATCH OUT!</strong><br/>This post is not official yet and may be heavily edited as CAS development makes progress. <a href="https://apereo.github.io/feed.xml">Watch</a> for further updates.
</div>
-->

<div class="alert alert-success">
  <strong>Collaborate</strong><br/>The blog is managed and hosted on GitHub. If you wish to update the contents of this post or if you have found an inaccuracy and wish to make corrections, we recommend that you please submit a pull request to <a href="https://github.com/apereo/apereo.github.io">this repository</a>.
</div>

Apereo CAS has had built-in support for [JWTs](https://jwt.io/) for some time now in a variety of different ways. Notions of JWT support really date back to CAS `3.5.x` with the work [@epierce](https://github.com/epierce/cas-server-extension-token) did as a CAS extension to enable token authentication support. Since then, support for JWTs has significantly improved and grown over the years and continues to get better with an emerging number of use cases whose chief concern is improving performance and removing round-trip calls, among other things.

In this tutorial, I am going to briefly review various forms of JWT functionality in CAS. Specifically, the following topics will be reviewed:

- [JWT Authentication](https://apereo.github.io/cas/development/installation/JWT-Authentication.html): Allowing CAS to accept JWTs as credentials in non-interactive authentication modes mostly.
- JWTs with [Duo Security Multifactor Authentication](https://apereo.github.io/cas/development/installation/DuoSecurity-Authentication.html): Exploring an approach where a non-interactive authentication request may be routed to a multifactor authentication flow and back.
- [JWTs as Service Tickets](https://apereo.github.io/cas/development/installation/Configure-ServiceTicket-JWT.html): Allowing CAS to transform service tickets issued for applications into JWTs.


# Environment

- Apereo CAS `5.2.0-SNAPSHOT`
- curl `7.54.0`

...and last but not least, a functional vanilla CAS overlay. For this tutorial, I am using the [CAS Maven WAR Overlay](https://github.com/apereo/cas-overlay-template) project.

# JWT Authentication

CAS provides support for token-based authentication on top of JWTs, where an authentication request can be granted an SSO session based on a form of credentials that are JWTs. CAS expects a `token` parameter (or request header) to be passed along to the `/login` endpoint as the credential. The parameter value must of course be a JWT.

## Let There Be JWT

To generate a JWT, I ended up using the [CAS Command-line Shell](https://apereo.github.io/cas/development/installation/Configuring-Commandline-Shell.html):

```bash
cd cas-overlay-template
./build.sh cli -sh
```

This will allow you to enter the interactive shell, where you have documentation, tab-completion and history for all commands. 

```bash
Welcome to CAS Command-line Shell. For assistance press or type "help" then hit ENTER.
cas>

cas>generate-jwt --subject Misagh

==== Signing Secret ====
MY4Jpxr5VeZsJ...

==== Encryption Secret ====
MZCjxBbDFq9cHPdy...

Generating JWT for subject [Misagh] with signing key size [256], signing algorithm [HS256], encryption key size [48], encryption method [A192CBC-HS384] and encryption algorithm [dir]

==== JWT ====
eyJjdHkiOiJKV1QiLCJ...
```

Hooray! We have a JWT.

There are a variety of other parameters such as encryption methods and signing algorithms you can choose from to generate the JWT. For the purposes of this tutorial, let's keep things simple. Of course, you don't have to use the shell. Any valid and compliant JWT generator would do fine.

<div class="alert alert-info">
  <strong>Don't Take Things Literally</strong><br/>I am abbreviating the secrets and the generated JWT above. Do NOT copy paste these into your environment and configuration, thinking they might do the trick.
</div>

## Configure Application

CAS [needs to be taught](https://apereo.github.io/cas/development/installation/JWT-Authentication.html) the security properties of the JWT so it can unpack and validate it and produce the relevant authenticated session. For a given authentication request, CAS will try to find the matching record for the application in its registry that is capable of validating JWTs. If such a record is found and the request is in fact accompanied by JWT credentials, the credential is validated and the service ticket issued.

My CAS overlay is already equipped with the [relevant configuration module](https://apereo.github.io/cas/development/installation/JWT-Authentication.html) and my application record using [the JSON service registry](https://apereo.github.io/cas/development/installation/JSON-Service-Management.html) looks something like this:

```json
{
  "@class" : "org.apereo.cas.services.RegexRegisteredService",
  "serviceId" : "https://www.example.org",
  "name" : "Example",
  "id" : 1000,
  "properties" : {
    "@class" : "java.util.HashMap",
    "jwtSigningSecret" : {
      "@class" : "org.apereo.cas.services.DefaultRegisteredServiceProperty",
      "values" : [ "java.util.HashSet", [ "MY4Jpxr5VeZsJ..." ] ]
    },
    "jwtEncryptionSecret" : {
      "@class" : "org.apereo.cas.services.DefaultRegisteredServiceProperty",
      "values" : [ "java.util.HashSet", [ "MZCjxBbDFq9cHPdy..." ] ]
    }
  }
}
```

Now, we are ready to start sending requests.

## Authenticate

Using `curl` from a terminal, here is the authentication sequence:

```bash
$ curl -i "https://mmoayyed.example.net/cas/login?service=https://www.example.org&token=eyJjdHkiOiJKV1QiLCJ..."

HTTP/1.1 302
...
Location: https://www.example.org?ticket=ST-1-zmEt1zfAuHv9vG6DogfBeH5ylmc-mmoayyed-4
...
```

A few things to note:

- The `-i` option allow curl to output the response headers where `Location` in the above case contains the redirect URL with the issued service ticket.
- The entire url in the `curl` command in encased in double-quoted. This is necessary for `curl` to ensure the query string is entirely passed along to CAS.

Of course, I can pass the JWT as a request header too:

```bash
$ curl -i "https://mmoayyed.example.net/cas/login?service=https://www.example.org" --header "token:eyJjdHkiOiJKV1QiLCJ..."

HTTP/1.1 302
...
Location: https://www.example.org?ticket=ST-1-qamgyzfAuHv9vG6DogfBeH5ylmc-mmoayyed-4
...
```

Grab the `ticket` from the `Location` header and proceed to validate it, as you would any regular service ticket.

# Duo Security MFA With JWTs

I want to be able to use my JWT to authenticate with CAS and get a service ticket issued to my application at `https://www.example.org`, but I also want the request to be verified via second-factor credentials and an MFA flow provided by Duo Security. How do I do that?

[Duo Security integration support](https://apereo.github.io/cas/development/installation/DuoSecurity-Authentication.html) of CAS is able to also support non-browser based multifactor authentication requests. In order to trigger this behavior, applications (i.e. `curl`, REST APIs, etc.) need to specify a special `Content-Type` to signal to CAS that the request is submitted from a non-web based environment. The multifactor authentication request is submitted to Duo Security in `auto` mode which effectively may translate into an out-of-band factor (push or phone) recommended by Duo as the best for the user’s devices.

## Configure Duo Security

My overlay needs to be prepped with the [relevant configuration module](https://apereo.github.io/cas/development/installation/DuoSecurity-Authentication.html) of course and settings that include integration keys, secret keys, etc.

## Application MFA Trigger

I am also going to configure [an application-based trigger](https://apereo.github.io/cas/development/installation/Configuring-Multifactor-Authentication-Triggers.html#applications) for `https://www.example.org` so that authentication requests are routed to the relevant multifactor authentication provider.

So my application record will take on the following form:

```json
{
  "@class" : "org.apereo.cas.services.RegexRegisteredService",
  "serviceId" : "https://www.example.org",
  "name" : "Example",
  "id" : 1000,
  "multifactorPolicy" : {
    "@class" : "org.apereo.cas.services.DefaultRegisteredServiceMultifactorPolicy",
    "multifactorAuthenticationProviders" : [ "java.util.LinkedHashSet", [ "mfa-duo" ] ]
  }
  "properties" : {
    "@class" : "java.util.HashMap",
    "jwtSigningSecret" : {
      "@class" : "org.apereo.cas.services.DefaultRegisteredServiceProperty",
      "values" : [ "java.util.HashSet", [ "MY4Jpxr5VeZsJ..." ] ]
    },
    "jwtEncryptionSecret" : {
      "@class" : "org.apereo.cas.services.DefaultRegisteredServiceProperty",
      "values" : [ "java.util.HashSet", [ "MZCjxBbDFq9cHPdy..." ] ]
    }
  }
}
```

## Authenticate

Using `curl` again from a terminal, here is the authentication sequence:

```bash
$ curl -i "https://mmoayyed.example.net/cas/login?service=https://www.example.org" --header "token:eyJjdHkiOiJKV1QiLCJ..." --header "Content-Type: application/cas"

HTTP/1.1 302
...
Location: https://www.example.org?ticket=ST-1-gdfe1zfAuHv9vG6DogfBeH5ylmc-mmoayyed-4
...
```

Things should work exactly the same as before, except that this time your device registered with Duo Security will receive a `push` notification where your approval will authorize CAS to establish a session and generate a ticket.

# JWT Service Tickets

All operations so far have issued a regular service ticket back to the application that must be validated in a subsequent trip so the application can retrieve the authenticated user profile. In a different variation, it's possible for the service ticket itself to [take on the form of a JWT](https://apereo.github.io/cas/development/installation/Configure-ServiceTicket-JWT.html). JWT-based service tickets are issued to applications based on the same semantics defined by the CAS Protocol. CAS having received an authentication request via its `/login endpoint` will conditionally issue back JWT service tickets to the application in form of a `ticket` parameter via the requested http method.

## Configure JWTs

In order for CAS to transform service tickets into JWTs, essentially we need to execute the reverse of the configuration steps. We will need to ensure CAS is provided with relevant keys to generate JWTs and these keys are in turn used by the application to unpacked the service ticket that is now a JWT. The overlay also needs to be equipped with [the relevant extension module](https://apereo.github.io/cas/development/installation/Configure-ServiceTicket-JWT.html) of course.

You may generate the required secrets manually per the above link. In this example, I left them undefined in my properties which forced CAS to generate a few on its own and warn me about them:

```bash
... - <Secret key for encryption is not defined for [Token/JWT Tickets]; CAS will attempt to auto-generate the encryption key>
... - <Generated encryption key [...] of size [256] for [Token/JWT Tickets]. The generated key MUST be added to CAS settings under setting [cas.authn.token.crypto.encryption.key].>
... - <Secret key for signing is not defined for [Token/JWT Tickets]. CAS will attempt to auto-generate the signing key>
... - <Generated signing key [...] of size [512] for [Token/JWT Tickets]. The generated key MUST be added to CAS settings under setting [cas.authn.token.crypto.signing.key].>
```

Fine! Let's proceed.

## Configure Application

JWTs as service tickets are issued on a per-application basis. This means once CAS finds a matchin record for the application in its registry, it will try to determine if the application requires JWTs as service tickets. So my application record will take on the following form:

```json
{
  "@class" : "org.apereo.cas.services.RegexRegisteredService",
  "serviceId" : "https://www.example.org",
  "name" : "Example",
  "id" : 1000,
  "multifactorPolicy" : {
    "@class" : "org.apereo.cas.services.DefaultRegisteredServiceMultifactorPolicy",
    "multifactorAuthenticationProviders" : [ "java.util.LinkedHashSet", [ "mfa-duo" ] ]
  }
  "properties" : {
    "@class" : "java.util.HashMap",
    "jwtSigningSecret" : {
      "@class" : "org.apereo.cas.services.DefaultRegisteredServiceProperty",
      "values" : [ "java.util.HashSet", [ "MY4Jpxr5VeZsJ..." ] ]
    },
    "jwtEncryptionSecret" : {
      "@class" : "org.apereo.cas.services.DefaultRegisteredServiceProperty",
      "values" : [ "java.util.HashSet", [ "MZCjxBbDFq9cHPdy..." ] ]
    },
    "jwtAsResponse" : {
      "@class" : "org.apereo.cas.services.DefaultRegisteredServiceProperty",
      "values" : [ "java.util.HashSet", [ "true" ] ]
    }
  }
}
```

Now, we are ready to start sending requests.

## Authenticate

Using `curl` again from a terminal, here is the authentication sequence:

```bash
$ curl -i "https://mmoayyed.example.net/cas/login?service=https://www.example.org" --header "token:eyJjdHkiOiJKV1QiLCJ..." --header "Content-Type: application/cas"

HTTP/1.1 302
...
Location: https://www.example.org?ticket=eyJhbGciOiJIUzUxMiJ9.WlhsS05tRllRV2xQYVVwRlVsV...
...
```

This works exactly the same as before, except that now the `ticket` parameter contains a JWT as a service ticket. 
 
# Summary

I hope this tutorial was of some help to you. As you have been reading, I can guess that you have come up with a number of missing bits and pieces that would satisfy your JWT needs more comprehensively with CAS. In a way, that is exactly what this tutorial intends to inspire. Please feel free to [engage and contribute](https://apereo.github.io/cas/developer/Contributor-Guidelines.html) as best as you can.

[Misagh Moayyed](https://twitter.com/misagh84)