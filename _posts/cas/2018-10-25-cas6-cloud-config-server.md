---
layout:     post
title:      Apereo CAS - Integration with Spring Cloud Config Server
summary:    CAS distributed configuration management using Spring Cloud Server for fun and profit. Learn how to centralize and setup configuration and property sources as part of the Cloud Config server and how to connect your Apereo CAS deployment to the Cloud Config server to receive real-time configuration updates per environment and deployment tier.
tags:       [CAS]
---

<div class="alert alert-success">
  <strong>Collaborate</strong><br/>The blog is managed and hosted on GitHub. If you wish to update the contents of this post or if you have found an inaccuracy and wish to make corrections, we recommend that you please submit a pull request to <a href="https://github.com/apereo/apereo.github.io">this repository</a>.
</div>

As your CAS deployment moves through the deployment pipeline from dev to test to production, you can manage the configuration between those environments and be certain that applications have everything they need to run when they migrate through the use of an external configuration server provided by the [Spring Cloud project](https://github.com/spring-cloud/spring-cloud-config). While most CAS deployments tend to fall into the simpler category of managing CAS configuration directly alongside the CAS server deployment, this tutorial focuses on allowing CAS to work with the Spring Cloud Config server for distributed configuration management.

The [Spring Cloud Config server](https://apereo.github.io/cas/development/configuration/Configuration-Server-Management.html) is an external and central configuration server to keep state and settings for all sorts of applications, CAS included. It provides an abstract way for CAS (and all of its other clients) to obtain settings from a variety of sources such as file system, git or svn repositories, MongoDb databases, Vault, etc. The beauty of this solution is that to the CAS web application server, (or the clients of the Spring Cloud Config server in general), it matters not where settings come from since CAS has no knowledge of the underlying property sources. It simply talks to the configuration server to locate settings and move on.

In this walkthrough, we will focus on the following tasks:

- Spring Cloud Config Server deployment
  - Property source configuration
  - Endpoint and operational security
  - Managing sensitive settings via encryption
  - Distributed real-time updates to settings
- CAS server integration with the Config server

Our starting position is based on the following:

- CAS `6.0.0-RC3`
- Java 11
- [CAS Overlay](https://github.com/apereo/cas-overlay-template) (The `master` branch specifically)
- [CAS Spring Cloud Config server overlay](https://github.com/apereo/cas-configserver-overlay)
- [CLI JSON Processor `jq`](https://stedolan.github.io/jq/)

## Spring Cloud Config Server Configuration

### Overlay Basics

The Spring Cloud Config server runs a standalone Spring Boot application on its own with a setup that is very similar to the CAS server itself. There is a [WAR overlay](https://github.com/apereo/cas-configserver-overlay) that can be used to configure and deploy the server. By default, the application runs on port `8888` and is available at `/casconfigserver` and does require SSL with a keystore that is expected at `file:/etc/cas/thekeystore`. The default settings should match the following:

```properties
server.port=8444

server.ssl.key-store=file:/etc/cas/thekeystore
server.ssl.key-store-password=changeit
server.ssl.key-password=changeit
```

### Security

In order to secure the Config server, we can create a `src/main/resources/application-security.properties` to contain the following settings:

```properties
spring.security.user.name=casuser
spring.security.user.password=Mellon

management.endpoints.web.base-path=/actuator
management.endpoints.env.enabled=true
management.endpoints.web.exposure.include=env
```

### Run

We should also modify the `build.sh` file to auto-activate the `security` profile to allow our security-related settings to be loaded:

```bash
function run() {
    package && java -jar -Dspring.profiles.include=security build/libs/casconfigserver.war
}
```

Once you're ready, execute the following:

```bash
./build.sh run
```

...at which point a successful startup attempt would demonstrate the following in the logs:

```
<The following profiles are active: security,native>
...
<Starting Servlet Engine: Apache Tomcat/9.0.12>
...
<Starting ProtocolHandler ["https-jsse-nio-8888"]>
...
<Started CasConfigurationServerWebApplication in 14.823 seconds (JVM running for 16.248)>
```

...and the server should be available at `https://admin.example.org:8888/casconfigserver`.

### Configuration Sources

The Spring Cloud Config server by default runs under a `native` profile, which basically allows it to locate properties and settings under the `/etc/cas/config` folder, which is very similar to the default CAS server setup. We are going to take this one step further and allow it to also load settings from a git repository. To do this, we need a `src/main/resources/bootstrap.properties` file with the following:

```properties
spring.application.name=casconfigserver
spring.profiles.active=native,default,security
spring.cloud.config.server.native.searchLocations=file:///etc/cas/config
spring.cloud.config.server.git.uri=file://path/to/config-server-repo
# spring.cloud.config.server.bootstrap=true
```

Not only the Config server is loading properties from embedded resources on the classpath, but it is also configured to look at `/etc/cas/config` as well as our Git repository at `config-server-repo` which is expected to contain properties and settings. As an example, we can create and initialize the `config-server-repo` directory as a Git repository and then **add and commit** the following files to it:

#### `application.yml`

Global settings regardless of the application:

```yml
info:
  description: Spring Cloud Config Server
```

#### `cas.properties`

Global settings for the `cas` application:

```properties
server.port=8555
```

#### `cas-dev.properties`

Settings for the `cas` application under the `dev` profile:

```properties
cas.authn.accept.users=casuser::Devel
```

#### `cas-qa.properties`:

Settings for the `cas` application under the `qa` profile:

```properties
cas.authn.accept.users=casuser::QA
```

Build and run as usual.

### Query Configuration

Now that the Config server is connected to a number of property sources with a number of files organized in fancy ways, we can query the server and ask for application settings.

For example, ask the server to get all the configuration settings for `cas` under the `qa` profile:

```bash
curl -k -u casuser:Mellon https://config.example.org:8888/casconfigserver/cas/qa | jq
```

...or the `dev` profile:

```bash
curl -k -u casuser:Mellon https://config.example.org:8888/casconfigserver/cas/dev | jq
```

Notice how in each scenario, global settings, and common application settings and then profile-specific settings are returned back to you. As the caller, you don't know where the settings come from or how they are controlled and by whom. All you need to know is: *Get me the right set of settings for my app at this profile*.

Let's make a change. Navigate to the `cas-qa.properties` file and add the following, then commit the change to the repository:

```properties
cas.authn.accept.users=casuser::QASomething
```

...and the call the Config server again:

```bash
curl -k -u casuser:Mellon https://config.example.org:8888/casconfigserver/cas/qa | jq
```

Notice how your change was picked up automatically. As a bonus exercise, push your git repository to a cloud provider such as Github or Bitbucket and modify the Config server with the URL of the new Git repository. Then make a change using the Github/BitBucket online editor to one of the settings and observe how the Config server recognizes changes automatically. Very cool!

### Sensitive Configuration

So far, we have been embedding values directly in configuration files. Let's try to make our setup a bit more secure by encrypting values before they are added to our repository. In the `bootstrap.properties` file add the following settings:

```properties
encrypt.key-store.location=file:///etc/cas/casconfigserver.jks
encrypt.key-store.password=changeit
encrypt.key-store.alias=cas
encrypt.key-store.secret=changeit
```

You will, of course, need to create the above keystore using `keytool`:

```bash
keytool -genkeypair -alias cas -keyalg RSA \
  -dname "CN=CAS,OU=Unit,O=Organization,L=City,S=State,C=US" \
  -keypass changeit -keystore /etc/cas/casconfigserver.jks -storepass changeit
  ```

The keystore above is what controls the semantics of encryption/decryption of settings. The encryption is done with the public key, and a private key is needed for decryption.

As a test, I am going to ask the Config server to encrypt the text `casuser::QASomething` for me:

```bash
curl -k -u casuser:Mellon https://config.example.org:8888/casconfigserver/encrypt -d casuser::QASomething
```

If you take the encrypted value and simply try to decrypt it you should see the original:

```bash
curl -k -u casuser:Mellon https://config.example.org:8888/casconfigserver/encrypt -d $ENCRYPTED_VALUE
```

Once the value is encrypted, it can be put back into the `cas-qa.properties` configuration file:

```properties
cas.authn.accept.users={cipher}$ENCRYPTED_VALUE
```

If you ask the Config server for the `qa` profile of the `cas` application, you should see the *decrypted value* in the results:

```bash
curl -k -u casuser:Mellon https://config.example.org:8888/casconfigserver/cas/qa | jq
```

That's it for now. Let's move onto the CAS server configuration and let it fetch settings from the Config server.

## CAS Server Configuration

The task at hand is to describe the Spring Cloud Config server to the CAS server so it can begin to configure itself via provided settings. To do so, you want to start with the [CAS Overlay](https://github.com/apereo/cas-overlay-template), clone the project and then put the following settings into a `src/main/resources/bootstrap.properties` file:

```properties
spring.application.name=cas

spring.profiles.active=default

spring.cloud.config.uri=https://casuser:Mellon@config.example.org.unicon.net:8888/casconfigserver
spring.cloud.config.profile=qa
spring.cloud.config.label=master

spring.cloud.config.enabled=true

spring.cloud.config.watch.enabled=true
spring.cloud.config.watch.initialDelay=30000
spring.cloud.config.watch.delay=1000

spring.cloud.config.fail-fast=true
health.config.enabled=true
```

In summary, we have the Spring Cloud config enabled with a location to the Config server. Next, we teach CAS to activate the `qa` profile when it asks for configuration settings, and we switch the CAS server application profile to `default` to disable the standalone strategy of locating settings. As for the other settings, hold onto them right now and we'll review them in just a bit.

The `label` setting is useful for rolling back to previous versions of configuration; with the default Config Server implementation it can be a git label, branch name or commit id. A label can also be provided as a comma-separated list, in which case the items in the list are tried one-by-one until one succeeds. This can be useful when working on a feature branch, for instance, when you might want to align the config label with your branch, but make it optional.

So at this point, our expectation is that CAS will load its own `application.properties` file by default which has a bunch of settings that for instance deal with SSL, keystores, ports, etc. Then we expect CAS to load any and all settings from the Spring Cloud config server that are associated with `cas` and `qa` where these settings should override anything that CAS by default handles and provides. This means that when it's all said and done, our CAS server should be running on port `8555` (as opposed to the default `8443`) and the static credentials used to authenticate users should include the username/password `casuser` and `QASomething` (as opposed to the default `casuser` and `Mellon`). 

Right?

If you have followed the story so far, crank up the your CAS server deployment and examine the above scenario. Works as advertised, doesn't it?!

### Refresh & Reload

The CAS spring cloud configuration server is constantly monitoring changes to the underlying property sources automatically but has no way to broadcast those changes to its own clients, such as the CAS server itself. Therefore, in order to broadcast such change events, CAS presents various endpoints that allow the user to [refresh the configuration](https://apereo.github.io/cas/development/configuration/Configuration-Management-Reload.html) as needed. This means that an adopter would simply change a required CAS setting and then would submit a request to CAS to *refresh* its current state. At runtime! All CAS internal components that are affected by the external change are quietly reloaded and the setting takes immediate effect, completely removing the need for container restarts or CAS re-deployments.

In order to handle automatic updates to CAS settings from the Spring Cloud Config server, we can try the following:

First, we are going to switch the CAS server to activate the `dev` profile (instead of the current `qa`) when querying for settings in the `bootstrap.properties` file:

```properties
spring.cloud.config.profile=dev
```

Then, we are going to modify and commit the `cas-dev.properties` file of the Spring Cloud Config server in our Git repository to enable CAS actuator endpoints by default which will allow us to invoke the `actuator/refresh` endpoint provided by Spring Boot:

```properties
management.endpoints.web.exposure.include=*
management.endpoints.enabled-by-default=true
cas.monitor.endpoints.endpoint.defaults.access=AUTHENTICATED
spring.security.user.name=casuser
spring.security.user.password=Mellon
```

<div class="alert alert-warning">
  <strong>WATCH OUT!</strong><br/>The above collection of settings <strong>MUST</strong> only be used for demo purposes and serve as an <strong>EXAMPLE</strong>. It is not wise to enable and expose all actuator endpoints to the web and certainly, the security of the exposed endpoints should be taken into account very seriously. None of the CAS or Spring Boot actuator endpoints are enabled by default. For production, you should carefully choose which endpoints to expose.
</div>

Once the changes are committed, we can switch back to the CAS server and re-run it one more time for it to pick up the `dev` profile settings and give us access to the relevant endpoints. When the CAS server is up, try invoking the `refresh` endpoint of the CAS server:

```bash
curl -k -u casuser:Mellon https://sso.example.org:8555/cas/actuator/refresh -d {} -H "Content-Type: application/json"
```

Watch the CAS server logs where you see something like:

```
INFO [...CasConfigurationEventListener] - <Refreshing CAS configuration. Stand by...>
```

Let's change something then. Switch over to the `cas-dev.properties` file of the Spring Cloud Config server and change and commit the following setting:

```properties
cas.authn.accept.users=casuser::Developers
```

Once the change is committed, invoke the refresh endpoint again just as before and observe the output:

```json
["config.client.version","cas.authn.accept.users"]
```

At this point, we should be able to pull up the CAS server in the browser and log in using `casuser` and `Developers` as credentials. Right? Give it a shot. Works as advertised, doesn't it?!

<div class="alert alert-info">
  <strong>Remember</strong><br/>CAS components that qualify for the refresh operations need to have been marked with a special Java annotation that is <code>@RefreshScope</code>. If you find that the refresh operation does not actually do its job, chances are the components that are affected and controlled by the setting are not marked that way. A pull request should fix that right up!</div>

This is very handy. You can make a change to a given application and profile in a centralized configuration server and simply invoke the client, that is the CAS server to refresh itself. Imagine the possibilities with distributed development and configuration management! 

### What About...

There a few things that we have yet to address that would be outside the scope of this document. Here they are:

#### Spring Cloud Config Bus

If we have more than one CAS server we need to invoke the `refresh` endpoint for each and every single server node for it to refresh itself and pick up changes. To solve this problem, we can use Spring Cloud Bus. The bus acts as the communication channel across all CAS server nodes and can be backed via RabbitMQ, Kafka, Redis, etc. Each CAS server will be connected to the bus and gains a special endpoint called `bus-refresh`. Calling this endpoint will cause the receiving node to:

- Get the latest configuration from the config server and update its configuration annotated by `@RefreshScope`
- Send a message to the bus informing about refresh event
- All subscribed CAS nodes will update their configuration as well

#### Spring Cloud Config Monitor

How does the Spring Cloud Config server detect changes from property sources? Could we make that process automatic, and have it broadcast a notification to CAS server nodes? This is where the Spring Cloud Config Monitor comes in handy. Similar to the above, the Config server can take advantage of this monitor that may be backed by a bus via AMQP. As changes are detected, they are broadcasted via events on the bus for the receiving CAS nodes to recognize and update themselves automatically, without manual refresh invocations.

## Final Thoughts

So, as you can observe there is quite a lot involved here to make for a cloud-ready distributed configuration management system. For many CAS deployments, this might seem overkill as most simply just rely on a standalone type of deployment where there is only a couple of CAS server nodes each feeding off of a simple `cas.properties` file adjacent to the node itself. It is true that the setting up CAS in the cloud using the described strategies in this post can take quite a bit of time and expertise. Thus, evaluate options carefully before jumping into coolness. If you have a strategic vision of managing configuration in distributed cloud-ready fashion, this is a good long-term investment. If you are thinking about centralizing application configuration across your entire institution and manage the configuration in a distributed and real-time fashion, it's worth it to go through the setup. If you have use cases that require configuration changes in real-time without downtime and restarts in a distributed environment, it makes sense to explore such options. Otherwise, you may find the pain and the cons outweigh the pros.

## Finale

I hope this review was of some help to you and I am sure that both this post as well as the functionality it attempts to explain can be improved in any number of ways. Please feel free to [engage and contribute](https://apereo.github.io/cas/developer/Contributor-Guidelines.html) as best as you can.

[Misagh Moayyed](https://twitter.com/misagh84)