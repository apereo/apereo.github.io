---
layout:     post
title:      Apereo CAS - Administrative Endpoints & Monitoring
summary:    Gain insight into your running Apereo CAS deployment in production. Learn how to monitor and manage the server by using HTTP endpoints and gather metrics to diagnose issues and improve performance.
tags:       [CAS]
---

<div class="alert alert-success">
<strong>Collaborate</strong><br/>This blog is managed and hosted on GitHub. If you wish to update the contents of this post or if you have found an inaccuracy and wish to make corrections, we recommend that you please submit a pull request to <a href="https://github.com/apereo/apereo.github.io">this repository</a>.
</div>

CAS, being a Spring-Boot application at heart, includes a number of additional features to help you monitor and manage the server when it’s pushed to production. You can choose to manage and monitor the deployment using HTTP endpoints, referred to as *actuators*. This tutorial provides a basic overview of the endpoints provided by both Spring Boot and CAS and also provides instructions on how such endpoints can be secured for access and win.

This tutorial specifically requires and focuses on:

- CAS `5.3.x`
- Java 8
- [CLI JSON Processor `jq`](https://stedolan.github.io/jq/)
- [Maven WAR Overlay](https://apereo.github.io/cas/development/installation/Maven-Overlay-Installation.html)

# Actua...What?

In essence, actuator endpoints bring production-ready features to CAS. Monitoring a running CAS instance, gathering metrics, understanding traffic or the state of our database becomes trivial with such endpoints. The main benefit of these endpoints is that we can get production grade tools without having to actually implement these features ourselves. Actuators are mainly used to expose operational information about the running application – health, metrics, info, dump, env, etc. These are HTTP endpoints or JMX beans to enable us to interact with it.

<div class="alert alert-info">
<strong>Definition</strong><br/>An actuator is a manufacturing term, referring to a mechanical device for moving or controlling something. Actuators can generate a large amount of motion from a small change.</div>

The full list of endpoints provided to your CAS deployment [is posted here](https://apereo.github.io/cas/development/installation/Monitoring-Statistics.html). Note that you do not need to do anything extra special to get these endpoints added to your deployment; these are all available by default and just need to be turned on and secured for access.

# Endpoints

Each endpoint, whether provided by CAS or Spring Boot, is generally given two special properties:

- `enabled`: Turn on the endpoint and make it available for access by outsiders.
- `sensitive`: Determines whether endpoint security should be controlled via the likes of [Spring Security](https://spring.io/projects/spring-security) with extra configuration.

So as an example, if you wish to turn on the `status` endpoint in CAS you need to simply turn on the following settings:

```properties
cas.monitor.endpoints.status.enabled=true
cas.monitor.endpoints.status.sensitive=false
```

What the above settings indicate is that the `status` endpoint should be turned on at runtime and it's one whose security is *NOT* controlled by the Spring Security library.

<div class="alert alert-info">
<strong>Sensitivity</strong><br/>The <code>sensitive</code> flag is a rather loaded and confusing term presented by the Spring Boot library that has since been revamped and redesigned, starting with Spring Boot v2. It's quite possible that once and if CAS switches Spring Boot v2, the above property pair get cleaned up too.
</div>

So in summary, access to our `status` endpoint above is purely dictated by CAS itself which by default is controlled by an IP pattern. So here's a rule that allows access to all CAS endpoints from everywhere:

```properties
cas.adminPagesSecurity.ip=.+
```

Once you have the above in place, simply open up a command prompt and execute:

```bash
# You might need the -k flag if the server's certificate is untrusted...
$ curl https://login.example.org/cas/status

Health: UP

Host:       misaghmoayyed
Server:     https://login.example.org
Version:    5.3.0
```

# Troubleshooting

For easier diagnostics, you need to turn on the following logging configuration in your `log4j2.xml` file:

```xml
<AsyncLogger name="org.pac4j" level="debug" additivity="false">
    <AppenderRef ref="console"/>
    <AppenderRef ref="file"/>
</AsyncLogger>
<AsyncLogger name="org.springframework.security" level="debug" additivity="false">
    <AppenderRef ref="console"/>
    <AppenderRef ref="file"/>
</AsyncLogger>
```

...which then help you diagnose issues if access to an endpoint is blocked with:

```properties
cas.adminPagesSecurity.ip=192\.168\.3\.1
```

...and then when you run:

```bash
$ curl https://login.example.org/cas/status | jq
```

...you might get:

```json
{
  "timestamp": 1529124120075,
  "status": 401,
  "error": "Unauthorized",
  "message": "No message available",
  "path": "/cas/status"
}
```

...where the logs would indicate:

```bash
INFO [IpClient] - <Failed to retrieve or validate credentials: Unauthorized IP address: 0:0:0:0:0:0:0:1>
DEBUG [IpClient] - <Failed to retrieve or validate credentials>
org.pac4j.core.exception.CredentialsException: Unauthorized IP address: 0:0:0:0:0:0:0:1
    at org.pac4j.http.credentials.authenticator.IpRegexpAuthenticator.validate...
```

# Endpoint Security

CAS endpoints prior to the adoption of Spring Boot and family (i.e. CAS v4 and priors) were always protected by an IP pattern which more or less was a regular expression pattern. Today and by default, this same protection mechanism is kept as well where all CAS endpoints are considered disabled whose security is exclusively controlled by the IP pattern noted above. In other words, in the event that access to an endpoint is allowed, (i.e endpoint is enabled and is not marked as sensitive), CAS will attempt to control access by enforcing rules via IP address matching, delegating to itself, etc.

Note that while almost all CAS endpoints can be secured via other means (such as a CAS server), the `/status` endpoint is always protected by an IP pattern allowing monitoring and CLI tools to easily query the endpoint from a protected recognized IP address.

# Let's Boot

As an exercise, let us enable the Spring Boot's `health` & `info` endpoints and compare them with CAS' own `status` endpoint. We are also going to secure the `health` endpoint using the [Spring Security library](https://spring.io/projects/spring-security) by taking advantage of the basic authentication scheme.

So, the first order of business is to simply enable the endpoints:

```properties
cas.adminPagesSecurity.ip=192\.168\.3\.1

endpoints.health.enabled=true
endpoints.health.sensitive=false

endpoints.info.enabled=true
endpoints.info.sensitive=false
```

...and with executing a request from a trusted IP address that would match the above pattern:

```bash
$ curl https://login.example.org/cas/status/health | jq
```

...we shall receive:

```json
{
  "status": "UP"
}
```

...or we can try the `info` endpoint too:

```bash
$ curl https://login.example.org/cas/status/info | jq
```

...which results in a lot of information, summarized here for sanity:

```json
 "cas": {
    "version": "5.3.0",
    "java": {
      "home": "../jdk1.8.0_171.jdk/Contents/Home/jre",
      "version": "1.8.0_171",
      "vendor": "Oracle Corporation"
    }
  },
  "description": "CAS",
  ...
```

Nice. Two questions:

- How could we get more information from the `health` endpoint?
- Weren't we going to enable basic authentication for some of these endpoints? What happened there?

# Let's Health

According to the documentation, the `health` endpoint shows application health information (when the application is secure, a simple "status" when accessed over an unauthenticated connection or full message details when authenticated). That has been the case since our requests are not exactly authenticated. We have simply honored the IP rules when submitting requests but we need to take this one step further and ask for credentials. Fancier modes of authenticating requests to such endpoints are provided by Spring Security (a library Spring Boot depends upon to auto-configure the access rules for endpoints marked as `sensitive`). So, let's get that configured.

<div class="alert alert-info">
<strong>Remember</strong><br/>Regardless of your method of authentication, the IP access rules are always in effect and do not back off once you turn on Spring Security and family. If you need the IP access restrictions to go away, simply open up the pattern to allow <code>.+</code> where that would allow you to exclusively rely upon the protection offered by Spring Boot and its authentication strategy.
</div>

The first task is to configure our CAS overlay to include the relevant dependency:

```xml
<dependency>
  <groupId>org.apereo.cas</groupId>
  <artifactId>cas-server-webapp-config-security</artifactId>
  <version>${cas.version}</version>
</dependency>
```

...and then, mark the endpoint as `sensitive` in our CAS properties:

```properties
endpoints.health.enabled=true
endpoints.health.sensitive=true
```

Next order of business is to define our *master* credentials that would be asked of all requests. Note that if the password is left blank, a random password will be generated/printed in the logs by default. We can define our own using the following:

```properties
security.user.name=wade
security.user.password=de@dp00L
```

With the above settings, if you try the same request as before:

```bash
$ curl https://login.example.org/cas/status/health | jq
```

...you might see the following:

```json
{
  "timestamp": 1529126720131,
  "status": 401,
  "error": "Unauthorized",
  "message": "Full authentication is required to access this resource",
  "path": "/cas/status/health"
}
```

So we need to be fully authenticated. Let's present credentials:

```bash
$ curl -u wade:de@dp00L https://login.example.org/cas/status/health | jq
```

...and the full output shall then be something as follows where CAS presents some additional health information regarding `session` and `memory` which correspond to its own health indicators monitoring the runtime memory status as well as the ticket registry repository:

```json
{
  "status": "UP",
  "memory": {
    "status": "UP",
    "freeMemory": 3006834288,
    "totalMemory": 3817865216
  },
  "session": {
    "status": "UP",
    "sessionCount": 0,
    "ticketCount": 0,
    "message": "OK"
  },
  "diskSpace": {
    "status": "UP",
    "total": 500068036608,
    "free": 115889942528,
    "threshold": 10485760
  },
  "refreshScope": {
    "status": "UP"
  }
}
```

...and if you happen to submit an incorrect authentication request with bad credentials, you might be presented with:

```json
{
  "timestamp": 1529127019737,
  "status": 401,
  "error": "Unauthorized",
  "message": "Bad credentials",
  "path": "/cas/status/health"
}
```

Of course, this is just basic authentication with a pre-defined pair of credentials. You can get the endpoints secured with a CAS server as well, or you can try basic authentication with an underlying account store backed by LDAP or JDBC...or as always, you can take full advantage of Spring Security in all its glory and design your authentication scheme for the win.

# Looking Ahead

As an FYI, as of this writing, the CAS version at hand depends on Spring Boot `1.5.x` to deliver endpoints and get them secured. Starting with Spring Boot v2, there is no separate auto-configuration for user-defined endpoints and actuator endpoints. Security is strictly controlled and provided by Spring Security if the library is included in CAS and found on the classpath whereby the auto-configuration secures all endpoints by default. Spring Boot then relies on Spring Security’s content-negotiation strategy to determine whether to use a basic authentication mode or form-based login and just like before, a user with a default username and generated password is added, which can be used to log in.

All of that is to say, endpoint security is one area that might get heavily refactored and redesigned in the future once CAS upgrades to Spring Boot v2. This would basically affect CAS configuration in the way that `enabled` or `sensitive` properties are defined; they might get removed or renamed, etc. There will be follow-up announcements and notes on the subject once the upgrade is available in due time and for now.

# Monitors

CAS monitors may be defined to report back the health status of the ticket registry and other underlying connections to systems that are in use by CAS. Spring Boot offers a number of monitors known as `HealthIndicator`s that are activated given the presence of specific settings (i.e. `spring.mail.*`). CAS itself provides a number of other monitors based on the same component whose action may require a combination of a particular dependency module and its relevant settings.

As you saw in the output of the `health` endpoint, the default monitors report back brief memory and ticket stats. As an exercise, we shall configure CAS to monitor and report health information on the status of a mail server (the monitor is provided by Spring Boot natively) and we may also let CAS monitor the status of an LDAP server provided where the monitor is this time brought to you by CAS.

## Mail Server Monitor

First, let's get the mail server configured in CAS:

```properties
spring.mail.host=localhost
spring.mail.port=25000
spring.mail.testConnection=true
```

With the above settings, at runtime CAS begins to create and bootstrap components that need to deal with a mail server and just as well, a special health monitor will get auto-configured to watch the server status and report back results via the `health` endpoint.

<div class="alert alert-info">
<strong>Saving Lives</strong><br/>This is the power of auto-configuration, saving you time and energy and abstracting you away from all the confusing internal details. Talk about improving productivity and saving lives, the entire configuration of a mail server connector as well as its relevant monitor is done using just a few simple settings!</div>

So, let's get us a health report:

```bash
$ curl -u wade:de@dp00L https://login.example.org/cas/status/health | jq
```

...and we shall receive the same sort of report except for this time we have a small blob for `mail`:

```json
...
"mail": {
    "status": "UP",
    "location": "localhost:25000"
},
...
```

..and if you shut the server down, you might receive:

```json
...
"mail": {
    "status": "DOWN",
    "location": "localhost:25000",
    "error": "com.sun.mail.util.MailConnectException: Couldn't connect to host, port: localhost, 25000; timeout -1"
  },
  ...
```

## LDAP Monitor

First, let's add the following dependency to ensure CAS can connect to an LDAP server:

```xml
<dependency>
    <groupId>org.apereo.cas</groupId>
    <artifactId>cas-server-support-ldap-monitor</artifactId>
    <version>${cas.version}</version>
</dependency>
```

...and let's teach CAS where our LDAP server lives:

```properties
cas.monitor.ldap.ldapUrl=ldap://localhost:389
cas.monitor.ldap.useSsl=false
```

<div class="alert alert-info">
<strong>Use What You Need</strong><br/>Do <b>NOT</b> copy/paste the entire collection of LDAP settings, etc into your CAS configuration; rather pick only the properties that you need. If you do not know what a setting does or means, it's generally safe to ignore it and trust the defaults. This is similar to ordering food; if you have never tried jellyfish, it would be fairly adventurous or dangerous to put that in your burger! Go with what you know and adjust as necessary.</div>


So, once again let's get us a health report:

```bash
$ curl -u wade:de@dp00L https://login.example.org/cas/status/health | jq
```

...and we shall receive the same sort of report except for this time we have a small blob for `pooledLdapConnectionFactory`:

```json
...
"pooledLdapConnectionFactory": {
  "status": "UP",
  "message": "OK",
  "activeCount": 0,
  "idleCount": 3
},
...
```

Additional monitors and health indicators may get added in future version of CAS. Consult the CAS documentation for more info.


# What About...?

- [CAS WAR Overlays](https://apereo.github.io/2018/06/09/cas53-gettingstarted-overlay/)
- [CAS Multifactor Authentication with Duo Security](https://apereo.github.io/2018/01/08/cas-mfa-duosecurity/)
- [CAS 5 LDAP AuthN and Jasypt Configuration](https://apereo.github.io/2017/03/24/cas51-ldapauthnjasypt-tutorial/)
- [CAS 5 SAML2 Delegated AuthN Tutorial](https://apereo.github.io/2017/03/22/cas51-delauthn-tutorial/)
- [CAS User Interface Customizations](http://localhost:4000/2018/06/10/cas-userinterface-customizations/)
- [CAS Multifactor Authentication with Google Authenticator](https://apereo.github.io/2018/06/10/cas-mfa-google-authenticator/)

# So...

It's important that you start off simple and make changes one step at a time. Once you have a functional environment, you can gradually and slowly add customizations to move files around.

I hope this review was of some help to you and I am sure that both this post as well as the functionality it attempts to explain can be improved in any number of ways. Please feel free to [engage and contribute](https://apereo.github.io/cas/developer/Contributor-Guidelines.html) as best as you can.

[Misagh Moayyed](https://twitter.com/misagh84)