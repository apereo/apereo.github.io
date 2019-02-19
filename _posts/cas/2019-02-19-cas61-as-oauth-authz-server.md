---
layout:     post
title:      Apereo CAS as an OAuth2 Authorization Server
summary:    Learn how to configure CAS as an OAuth2 Authorization Server and configure Spring Boot client app to work with it
tags:       [CAS,OAuth2]
---

<div class="alert alert-success">
  <strong>Collaborate</strong><br/>The blog is managed and hosted on GitHub. If you wish to update the contents of this post or if you have found an inaccuracy and wish to make corrections, we recommend that you please submit a pull request to <a href="https://github.com/apereo/apereo.github.io">this repository</a>.
</div>

## CAS
Apereo CAS can authenticate users in many ways, including by delegating to other authentication providers, and it can get attributes about those users from many places, and finally it can communicate that identity along with those attributes to applications (aka services) via various protocols such as the CAS Protocol, SAML, and OpenID Connect.

## Outline
In this blog post we are going describe how to configure CAS server to act as Oauth2 authorization server as well as how to set up a sample Spring Boot based web app acting as an Oauth2 client, delegating to CAS to do authentication transactions using `authorization_code` grant type as well as `code` response type.

The starting position is based on the following:
- CAS `6.1.0-RC1` overlay
- CAS Oauth2 sample client web app
- [Java 11] for CAS server (https://adoptopenjdk.net/?variant=openjdk11&jvmVariant=hotspot)
- Java 8 to run client app
- Edit `/etc/hosts` with:

```
1.2.3.4 casoauth.example.org
```
where `1.2.3.4` is replaced with the main IP address of your workstation.

## CAS server set up

In your standard CAS 6 overlay project (we're going to use Gradle-based one), add the following module in `build.gradle`:

```gradle
compile "org.apereo.cas:cas-server-support-oauth-webflow:${project.'cas.version'}"
```

Add OAuth2 registered service representing out client application to CAS' service registry (we're using JSON one with hjson syntax flavor):

```
{
  @class : org.apereo.cas.support.oauth.services.OAuthRegisteredService
  clientId: exampleOauthClient
  clientSecret: exampleOauthClientSecret
  serviceId: ^https://casoauth.example.org:9999/.*
  name: OAuthService
  id: 1000
  supportedGrantTypes: [ "java.util.HashSet", [ "authorization_code" ] ]
  supportedResponseTypes: [ "java.util.HashSet", [ "code" ] ]
}
```

Note the `clientId` and `clientSecret` values are significant here as we'll use those in the client app configuration

## Oauth2 client web application set up

Download/clone [CAS Oauth2 client sample web app](https://github.com/cas-projects/oauth2-sample-java-webapp)

Modify oauth2 configuration section like so `src/main/resources/application.yml`:

```yaml
security:
  oauth2:
    client:
      clientId: exampleOauthClient
      clientSecret: exampleOauthClientSecret
      accessTokenUri: https://casoauth.example.org:8443/cas/oauth2.0/accessToken
      userAuthorizationUri: https://casoauth.example.org:8443/cas/oauth2.0/authorize
      clientAuthenticationScheme: form
    resource:
      userInfoUri: https://casoauth.example.org:8443/cas/oauth2.0/profile
      preferTokenInfo: false
```

# Run server and client

On JDK 11, build and run CAS server as per usual e.g. using `java -jar ...` Make sure it starts on the default port of `8443`.
Switch to JDK 8 and build and run sample app by invoking `./run.sh` from the root of its directory structure.

Then visit `https://casauth.example.org:9999/dashboard/login` and watch redirect to CAS, login and redirect back using OAuth2 "protocol dance" with `authorization_code` grant type and `code` response type.

For more info on other OAuth2 flow types, see the [documentation page](https://apereo.github.io/cas/development/installation/OAuth-OpenId-Authentication.html)

## Finale
Hopefully this helped you learn about how to set up CAS's support for Oauth2 authorization server as well as integrate Oauth2 client application with it.

[Dmitriy Kopylenko](https://github.com/dima767)
