---
layout:     post
title:      Apereo CAS - Fun with HashiCorp Consul
summary:    Learn to register your CAS server deployment with HashiCorp Consul discovery server while also taking advantage of other advanced features such as the Consul Key/Value Store for storing configuration and other metadata.
tags:       [CAS]
---

<div class="alert alert-success">
  <strong>Collaborate</strong><br/>The blog is managed and hosted on GitHub. If you wish to update the contents of this post or if you have found an inaccuracy and wish to make corrections, we recommend that you please submit a pull request to <a href="https://github.com/apereo/apereo.github.io">this repository</a>.
</div>

Consul is a distributed, highly-available, and multi-datacenter aware tool for service discovery, configuration, and orchestration. Consul enables rapid deployment, configuration, and maintenance of service-oriented architectures at a massive scale. For more information, please see the [consul documentation](https://www.consul.io/).

The [CAS integration with Consul](https://apereo.github.io/cas/development/installation/Service-Discovery-Guide-Consul.html) has been available for some time and comes in multiple flavors. First, the server can use Consul for service discovery which is one of the key tenets of a cloud-based HA architecture. As Josh Long puts it:

> A service registry is a phone book for your microservices. Each service registers itself with the service registry and tells the registry where it lives (host, port, node name) and perhaps other service-specific metadata - things that other services can use to make informed decisions about it.

In our case, we could have each CAS server instance in a cluster register itself with the discovery server automatically, (i.e. the CAS server is a client of the discovery server), and then have individual discovery-aware CAS clients query the discovery server to figure out the availability and location of each CAS server node. Throw in a software load-balancer like [Netflix Ribbon](https://github.com/Netflix/ribbon) and things begin to get interesting.

<div class="alert alert-success">
  <strong>Netflix Eureka</strong><br/>A similiar integration with <a href="https://apereo.github.io/cas/development/installation/Service-Discovery-Guide-Eureka.html">Netflix Eureka Server</a> is also available and supported by CAS.
</div>

The other available [CAS integration with Consul](https://apereo.github.io/cas/development/installation/Service-Discovery-Guide-Consul.html) deals with managing distributed configuration using the Consul Key/Value store. Consul provides a Key/Value Store for storing configuration and other metadata. CAS takes advantage of the [Spring Cloud Consul Config integration library](http://cloud.spring.io/spring-cloud-consul/single/spring-cloud-consul.html) to fetch such configuration and metadata as an alternative to the [Config Server and Client](https://apereo.github.io/cas/development/configuration/Configuration-Server-Management.html). 

To learn more about the Consul Key/Value store, please [see this page](https://www.consul.io/api/kv.html).

In this tutorial, we will focus on a *simple walkthrough* of how to integrate Consul with CAS for both service discovery and configuration management. Our starting position is based on the following:

- CAS `6.0.0-RC3`
- Java 11
- [CAS Overlay](https://github.com/apereo/cas-overlay-template) (The `master` branch specifically)
- [CLI JSON Processor `jq`](https://stedolan.github.io/jq/)
- [Docker](https://www.docker.com/get-started)

## Consul Configuration

To configure a simple Consul server, we can use the [available Docker image](https://hub.docker.com/_/consul/) which is perfectly good for demos and testing. Use the following command to run the Consul server:

```bash
docker run --name=consul -p8500:8500 -e CONSUL_BIND_INTERFACE=eth0 consul
```

By default, Consul allows connections to these ports only from the loopback interface (`127.0.0.1`). When you run the Consul agent, it listens on 6 ports all of which serve different functions. The three ports essential to our discussion are:

- HTTP API (default port: `8500`): handles HTTP API requests from clients
- CLI RPC (default port: `8400`): handles requests from CLI
- DNS (default port: `8600`): answers DNS queries

Our Docker command runs a completely in-memory Consul server agent with default bridge networking and no services exposed on the host, which is useful for development but **SHOULD NOT** be used in production. Once you have the server running, you can point your browser to `http://localhost:8500/ui` where you will see something like this:

![image](https://user-images.githubusercontent.com/1205228/47265207-22471e00-d531-11e8-9291-3c2970b18c6e.png)

There is nothing registered with the server yet. As the next step, we will connect the CAS server to Consul.

## CAS Server Configuration

### Service Discovery

#### Registration

Each individual CAS server is given the ability to auto-register itself with the Consul server. This is done using the following module that should go into the CAS overlay:

```gradle
compile "org.apereo.cas:cas-server-support-consul-client:${project.'cas.version'}"
```

Of course, we need to teach CAS about our Consul server using the `cas.properties` file:

```properties
spring.cloud.consul.port=8500
spring.cloud.consul.enabled=true
spring.cloud.consul.host=localhost

spring.cloud.consul.discovery.heartbeat.enabled=true
spring.cloud.consul.discovery.heartbeat.ttlValue=60
spring.cloud.consul.discovery.heartbeat.ttlUnit=s
```

These settings are primarily offered and controlled by Spring Cloud that teaches CAS the location of the Consul server and how it may register itself with that server as a Consul client.

When you build and deploy CAS next, the Consul server should properly recognize the registration request and display something like this:

![image](https://user-images.githubusercontent.com/1205228/47265240-b0230900-d531-11e8-9ed8-dc8a6ce30e63.png)

...where you can drill into the `cas` service and look at various screens:

![image](https://user-images.githubusercontent.com/1205228/47265243-ca5ce700-d531-11e8-95dd-5757264d00a6.png)

As extra proof, CAS logs would indicate the following too:

```
INFO [ConsulServiceRegistry] - <Registering service with consul: NewService{id='cas-8443', name='cas'...
```

#### Discovery

So far, we have only been reviewing the service registration aspect. As the next step, you would want to build and configure clients that are able to contact the discovery server, asking about available `CAS` instances. Spring Cloud makes this rather easy. As an example your Java client would look something like this:

```java
@EnableDiscoveryClient
@SpringBootApplication
public class SampleClientApplication {
    public static void main(String[] args) {
        SpringApplication.run(SampleClientApplication.class, args);
    }
}

@RestController
class ServiceInstanceRestController {
    @Autowired
    private DiscoveryClient discoveryClient;

    @RequestMapping("/service-instances/{applicationName}")
    public List<ServiceInstance> serviceInstances(
            @PathVariable String applicationName) {
        return discoveryClient.getInstances(applicationName);
    }
}
```

...where you'd have:

```properties
spring.application.name=cas
```

With the above code snippet, our sample CAS client defines a Spring MVC REST endpoint that returns an enumeration of all the `ServiceInstance` instances registered in the Consul registry. From then on, the client may proceed deal with each `ServiceInstance` that would be refreshed automatically as CAS servers come and go in the discovery server.

### Configuration Management

Consul provides a Key/Value Store for storing configuration and other metadata. Configuration is loaded into the CAS environment during the special *bootstrap* phase at runtime. Configuration is stored in the `/config` folder by default. Multiple `PropertySource` instances are created based on the application’s name and the active profiles that mimic the Spring Cloud Config order of resolving properties.

For example, an application with the name `cas` and with the `dev` profile will have the following property sources created:

```
config/cas,dev/
config/cas/
config/application,dev/
config/application/
```

The most specific property source is at the top, with the least specific at the bottom. Properties in the `config/application` folder are applicable to all applications using consul for configuration. Properties in the `config/cas/` folder are only available to the instances of the service named cas.

<div class="alert alert-info">
  <strong>Configuration</strong><br/>There is no other extra step required in CAS to make distributed configuration management work with Consul. If you have the discovery piece working, you will be able to automatically take advantage of the Key/Value store.
</div>

So let's create `config/cas/` folder in Consul and add a sample property `cas.authn.accept.users` which controls static authentication in CAS with a list of hardcoded credentials:

![image](https://user-images.githubusercontent.com/1205228/47265712-195a4a80-d539-11e8-9124-b2421e53c7ed.png)

Once you save the setting, CAS logs should indicate the application context refreshing to recognize the change:

```
INFO [RefreshEventListener] - <Refresh keys changed: [cas.authn.accept.users]>
```

After the change is picked up, you should be able to log into CAS using `casuser` and `Misagh` as the credentials! Just as well, we can delete the setting from Consul, let CAS pick up the change and we should be able to fall back onto the default credentials for static authentication which are `casuser` and `Mellon`.

How is this possible? There is a thing called *Consul Config Watch* which in CAS takes advantage of the ability of consul to watch a key prefix. It makes a blocking Consul HTTP API call to determine if any relevant configuration data has changed for the current application. If there is new configuration data a `Refresh Event` is published and captured by CAS to refresh the status of the application context, as is demonstrated by the logs. 

Pretty cool!

## Finale

I hope this review was of some help to you and I am sure that both this post as well as the functionality it attempts to explain can be improved in any number of ways. Please feel free to [engage and contribute](https://apereo.github.io/cas/developer/Contributor-Guidelines.html) as best as you can.

[Misagh Moayyed](https://twitter.com/misagh84)