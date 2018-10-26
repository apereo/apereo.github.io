---
layout:     post
title:      Apereo CAS - Spring Boot Admin Integration
summary:    Learn to manage and monitor your Apereo CAS deployment using the Spring Boot Admin server and Spring Boot Actuator endpoints.
tags:       [CAS]
---

<div class="alert alert-success">
  <strong>Collaborate</strong><br/>The blog is managed and hosted on GitHub. If you wish to update the contents of this post or if you have found an inaccuracy and wish to make corrections, we recommend that you please submit a pull request to <a href="https://github.com/apereo/apereo.github.io">this repository</a>.
</div>

[Spring Boot Admin](https://github.com/codecentric/spring-boot-admin) is a community project to manage and monitor Spring Boot applications such as Apereo CAS. The admin server presents an AngularJS-based UI that interacts with the [actuator endpoints](https://apereo.github.io/cas/development/installation/Monitoring-Statistics.html) provided by Spring Boot in CAS. One CAS has registered itself with the admin server, either using the *Spring Admin Client* via HTTP or as part of discovery using technologies such as Eureka, Consul, etc, the admin server can begin to provide feature to monitor CAS for health status, JVM & memory metrics, environment settings, thread dumps, audit data, logs, etc.

While the CAS integration with the Spring Boot Admin server has been available for some time (likely since CAS `5.1.x`), in this tutorial we will focus on how to get the latest version of [Apereo CAS integrated with the Admin server](https://apereo.github.io/cas/development/installation/Configuring-Monitoring-Administration.html). At a high-level, we need to accomplish the following:

- Deploy and configure the Spring Boot Admin server
- Configure CAS to register with the Spring Boot Admin server

Our starting position is based on the following:

- CAS `6.0.0-RC3`
- Java 11
- [CAS Overlay](https://github.com/apereo/cas-overlay-template) (The `master` branch specifically)
- [Spring Boot Admin overlay](https://github.com/apereo/cas-bootadmin-overlay)
- [CLI JSON Processor `jq`](https://stedolan.github.io/jq/)

## Spring Boot Admin Server Configuration

The Spring Boot Admin server runs a standalone Spring Boot application on its own with a setup that is very similar to the CAS server itself. There is a [WAR overlay](https://github.com/apereo/cas-bootadmin-overlay) that can be used to configure and deploy the server. Once you clone the Admin overlay project, you may need to create a `src/main/resources/application.properties` to control the behavior of the Admin server. By default, the application runs on port `8444` and does require SSL with a keystore that is expected at `file:/etc/cas/thekeystore`. The default settings should match the following:

```properties
server.port=8444

server.ssl.key-store=file:/etc/cas/thekeystore
server.ssl.key-store-password=changeit
server.ssl.key-password=changeit

# Protect the boot-admin endpoints for basic/form authn
spring.security.user.name=casuser
spring.security.user.password=e3f98098-edb5-4217-9dcb-ad04999a8794
```

Given the Admin server itself is based on top of Spring Boot, all relevant Spring Boot settings here do also apply to control the general behavior of the web application. There are also many other settings available to tweak the behavior of the Admin server functionality itself. For a more comprehensive list, please see the [Spring Boot Admin documentation](https://codecentric.github.io/spring-boot-admin/current).

Once you're ready, execute the following:

```bash
./build.sh run
```

...at which point a successful startup attempt would demonstrate the following in the logs:

```
INFO [org.apereo.cas.CasSpringBootAdminServerWebApplication] - <No active profile set, falling back to default profiles: default>
...
INFO [org.springframework.boot.web.embedded.tomcat.TomcatWebServer] - <Tomcat started on port(s): 8444 (https) with context path ''>
...
INFO [org.apereo.cas.CasSpringBootAdminServerWebApplication] - <Started CasSpringBootAdminServerWebApplication in 20.798
```

...which allows you to navigate to Admin server in your browser at `https://admin.example.org:8444`:

![image](https://user-images.githubusercontent.com/1205228/47254172-3b859700-d46b-11e8-8ea2-9d42cb7407d6.png)

There is nothing registered with the Admin server yet. As the next step, we will connect our CAS server to the Admin server.

## CAS Server Configuration

Each individual CAS server is given the ability to auto-register itself with the Admin server. This is done using the following module that should go into the CAS overlay:

```gradle
compile "org.apereo.cas:cas-server-support-bootadmin-client:${project.'cas.version'}"
```

Of course, we need to teach CAS about our Admin server using the `cas.properties` file:

```properties
spring.boot.admin.client.enabled=true
spring.boot.admin.client.url=https://admin.example.org:8444
spring.boot.admin.client.instance.management-base-url=https://sso.example.org/cas
```

So, our CAS server is running on `https://sso.example.org/cas` which presents a number of [actuator endpoints](https://apereo.github.io/cas/development/installation/Monitoring-Statistics.html) that are used by the Admin server to monitor status and report results. Therefore, we will need to enable the endpoints in CAS in `cas.properties` so they may be consumable by the Admin server:

```properties
management.endpoints.enabled-by-default=true
management.endpoints.web.exposure.include=*

spring.security.user.name=casuser
spring.security.user.password=Mellon

cas.monitor.endpoints.endpoint.defaults.access=AUTHENTICATED
```

These settings are primarily offered and controlled by Spring Boot and accomplish the following:

- Enable all actuator endpoints by default.
- Expose all actuator endpoints over the web via http.
- Secure all actuator endpoints using basic authentication where the master credentials are `casuser` and `Mellon`.

<div class="alert alert-warning">
  <strong>WATCH OUT!</strong><br/>The above collection of settings <strong>MUST</strong> only be used for demo purposes and serve as an <strong>EXAMPLE</strong>. It is not wise to enable and expose all actuator endpoints to the web and certainly, the security of the exposed endpoints should be taken into account very seriously. None of the CAS or Spring Boot actuator endpoints are enabled by default. For production you should carefully choose which endpoints to expose.
</div>

To verify, you can try to hit a few of the endpoints to see the behavior in action:

```bash
curl -u casuser:Mellon -k https://sso.example.org/cas/actuator/status | jq
```

...where you get back:

```json
{
  "status": 200,
  "description": "OK",
  "health": "UP",
  "host": "misaghmoayyed",
  "server": "https://sso.example.org/cas",
  "version": "6.0.0-RC3 - ..."
}
```

You can also try hitting `actuator/health`, `actuator/info` and [many others]((https://apereo.github.io/cas/development/installation/Monitoring-Statistics.html)).

Now that are endpoints are enabled and secured, we need to configure CAS to use our security credentials when contacting the Admin server as well:

```properties
spring.boot.admin.client.instance.metadata.user.name=casuser
spring.boot.admin.client.instance.metadata.user.password=Mellon

# In case Spring Boot Admin endpoints are protected via basic authn
spring.boot.admin.client.username=casuser
spring.boot.admin.client.password=e3f98098-edb5-4217-9dcb-ad04999a8794
```

<div class="alert alert-warning">
  <strong>WATCH OUT!</strong><br/>While the actuator endpoints in CAS are protected in some fashion, the endpoints of the Spring Boot Admin server that are responsible for handling registration requests and more are not by default protected using the existing overlay. This is an item that will likely get worked out before the final CAS release.</a>.
</div>

When you build and deploy CAS next, the Admin server should properly recognize the registration request and display something like this:

![image](https://user-images.githubusercontent.com/1205228/47254581-58bd6400-d471-11e8-9eb4-75709190355e.png)

...where you can drill into the app and look at various screens and monitoring activity. For example, check out the available http web mappings and URLs:

![image](https://user-images.githubusercontent.com/1205228/47254701-a6869c00-d472-11e8-9e54-2123ae63c414.png)

...or logging configuration:

![image](https://user-images.githubusercontent.com/1205228/47254710-ca49e200-d472-11e8-94e8-7cb5a711f5a7.png)

There is a lot more you can do with the Admin server to add security, custom notifications, etc. Please see the [Spring Boot Admin documentation](https://codecentric.github.io/spring-boot-admin/current).

## Finale

I hope this review was of some help to you and I am sure that both this post as well as the functionality it attempts to explain can be improved in any number of ways. Please feel free to [engage and contribute](https://apereo.github.io/cas/developer/Contributor-Guidelines.html) as best as you can.

[Misagh Moayyed](https://twitter.com/misagh84)
