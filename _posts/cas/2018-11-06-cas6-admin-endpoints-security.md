---
layout:     post
title:      Apereo CAS 6 - Administrative Endpoints & Monitoring
summary:    Gain insight into your running Apereo CAS 6 deployment in production. Learn how to monitor and manage the server by using HTTP endpoints and gather metrics to diagnose issues and improve performance.
tags:       [CAS]
---

<div class="alert alert-success">
<strong>Collaborate</strong><br/>This blog is managed and hosted on GitHub. If you wish to update the contents of this post or if you have found an inaccuracy and wish to make corrections, we recommend that you please submit a pull request to <a href="https://github.com/apereo/apereo.github.io">this repository</a>.
</div>

CAS, being a Spring-Boot application at heart, includes a number of endpoints to help you monitor and manage the server when it’s pushed to production. You can choose to manage and monitor the deployment using HTTP endpoints, referred to as *actuators*. This tutorial provides a basic overview of the endpoints provided by both Spring Boot and CAS and also provides instructions on how such endpoints can be secured for access and win.

Our starting position is based on the following:

- CAS `6.0.0-RC4`
- Java 11
- [CAS Overlay](https://github.com/apereo/cas-overlay-template) (The `master` branch specifically)
- [CLI JSON Processor `jq`](https://stedolan.github.io/jq/)

# Actua...What?

In essence, actuator endpoints bring production-ready features to CAS. Monitoring a running CAS instance, gathering metrics, understanding traffic or the state of our database becomes trivial with such endpoints. The main benefit of these endpoints is that we can get production grade tools without having to actually implement these features ourselves. Actuators are mainly used to expose operational information about the running application – health, metrics, info, dump, env, etc. These are HTTP endpoints or JMX beans to enable us to interact with it.

<div class="alert alert-info">
<strong>Definition</strong><br/>An actuator is a manufacturing term, referring to a mechanical device for moving or controlling something. Actuators can generate a large amount of motion from a small change.</div>

The full list of endpoints provided to your CAS deployment [is posted here](https://apereo.github.io/cas/development/monitoring/Monitoring-Statistics.html). Note that you do not need to do anything extra special to get these endpoints added to your deployment; these are all available by default and just need to be turned on and secured for access.

# Endpoints

Starting with Spring Boot `2` and CAS `6.0.x`, the actuator endpoints and their method of security are entirely revamped. Here are the main differences:

- Endpoints can individually be exposed over the web under HTTP.
- Security of each endpoint using the combo of `enabled` and `sensitive` is now gone, and each endpoint entirely embraces Spring Security for protection.
- Endpoints internally are marked as `@Endpoint` and can be standalone or extensions of existing endpoints such as `/health`.
- Enabling an endpoint may pass through several layers of security: Default setting if undefined, globally or per endpoint.

## Examples

Let's go through a number of scenarios that might be helpful. Bear in mind that in order to work with an endpoint, you must go through the following steps:

- The endpoint must be enabled.
- The endpoint may be somehow exposed.
- The endpoint may be somehow secured.

Remember that the default path for endpoints exposed over the web is at `/actuator`, such as `/actuator/status`.

### Example 1

Expose the CAS `status` endpoint over the web, enable it and make sure its protected via basic authentication:

```properties
management.endpoints.web.exposure.include=status
management.endpoint.status.enabled=true

cas.monitor.endpoints.endpoint.status.access=AUTHENTICATED

spring.security.user.name=casuser
spring.security.user.password=Mellon
```

### Example 2

Expose the CAS `status` endpoint over the web, enable it and make sure a list of IP addresses can reach it:

```properties
management.endpoints.web.exposure.include=status
management.endpoint.status.enabled=true
cas.monitor.endpoints.endpoint.status.access=IP_ADDRESS
cas.monitor.endpoints.endpoint.status.requiredIpAddresses=1.2.3.4,0.0.0.0
```

### Example 3

Expose the Spring Boot `health` and `info` endpoints over the web, enable them and make sure access to `health` is secured via basic authentication:

```properties
management.endpoints.web.exposure.include=health,info

management.endpoint.health.enabled=true
management.endpoint.health.show-details=always

management.endpoint.info.enabled=true

cas.monitor.endpoints.endpoint.health.access=AUTHENTICATED
cas.monitor.endpoints.endpoint.info.access=ANONYMOUS

spring.security.user.name=casuser
spring.security.user.password=Mellon
```

### Example 4

Enable and expose all endpoints with no regard for security:

```properties
management.endpoints.web.exposure.include=*
management.endpoints.enabled-by-default=true
cas.monitor.endpoints.endpoint.defaults.access=ANONYMOUS
```

<div class="alert alert-warning">
  <strong>WATCH OUT!</strong><br/>The above collection of settings <strong>MUST</strong> only be used for demo purposes and serve as an <strong>EXAMPLE</strong>. It is not wise to enable and expose all actuator endpoints to the web and certainly, the security of the exposed endpoints should be taken into account very seriously. None of the CAS or Spring Boot actuator endpoints are enabled by default. For production, you should carefully choose which endpoints to expose.
</div>

### Example 5

In addition to the usual, let's remap the path to endpoints to start with `endpoints` instead
of `actuator`, and lets rename the `status` endpoint to be `heartbeat`:

```properties
management.endpoints.web.path-mapping.status=heartbeat
management.endpoints.web.base-path=/endpoints
management.endpoints.web.exposure.include=status
management.endpoint.status.enabled=true
cas.monitor.endpoints.endpoint.status.access=IP_ADDRESS
cas.monitor.endpoints.endpoint.status.requiredIpAddresses=1.2.3.4
```

## Dashboard

Note that all GUIs related to CAS endpoints are removed and will be slightly transitioned over to the [CAS Management Web Application](https://apereo.github.io/cas/development/services/Installing-ServicesMgmt-Webapp.html). However, while the screens may be gone the underlying functionality remains all the same. For example, provided the endpoint is correctly enabled and secured you can invoke the `statistics` endpoint to get the required data:

```bash
curl -k https://sso.example.org/cas/actuator/statistics | jq
```

...where you'd see something like this:

```json
{
  "upTime": 64,
  "totalMemory": "1 GB",
  "expiredTgts": 0,
  "expiredSts": 0,
  "maxMemory": "4 GB",
  "freeMemory": "615 MB",
  "unexpiredTgts": 0,
  "unexpiredSts": 0
}
```

Over time, this data should become accessible via the management application. Remember that for endpoints which are native to and provided by Spring Boot, you may always try the [Spring Boot Admin Server](https://apereo.github.io/2018/10/22/cas6-springboot-admin-server/).

# So...

It's important that you start off simple and make changes one step at a time. Once you have a functional environment, you can gradually and slowly add customizations to move files around.

I hope this review was of some help to you and I am sure that both this post as well as the functionality it attempts to explain can be improved in any number of ways. Please feel free to [engage and contribute](https://apereo.github.io/cas/developer/Contributor-Guidelines.html) as best as you can.

[Misagh Moayyed](https://twitter.com/misagh84)