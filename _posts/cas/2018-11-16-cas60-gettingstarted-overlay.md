---
layout:     post
title:      CAS 6.0.x Deployment - WAR Overlays
summary:    Learn how to configure and build your own CAS deployment via the WAR overlay method, get rich quickly, stay healthy indefinitely and respect family and friends in a few very easy steps.
tags:       [CAS]
---

This is a short and sweet tutorial on how to deploy CAS via [the WAR Overlay method](https://apereo.github.io/cas/6.0.x/installation/WAR-Overlay-Installation.html).

This tutorial specifically requires and focuses on:

- CAS `6.0.x`
- Java 11

<div class="alert alert-info">
  <strong>Need Help?</strong><br/>If you ever get stuck and are in need of additional assistance, start by reviewing the suggestions <a href="https://apereo.github.io/cas/6.0.x/installation/Troubleshooting-Guide.html">provided here</a>. You may also look at available support options <a href="https://apereo.github.io/cas/Support.html">provided here</a>.
</div>

* A markdown unordered list which will be replaced with the ToC
{:toc}

# Overlay...What?

Overlays are a strategy to combat repetitive code and/or resources. Rather than downloading the CAS codebase and building it from source, overlays allow you to download a pre-built vanilla CAS web application server provided by the project itself, override/insert specific behavior into it and then merge it all back together to produce the final (web application) artifact. You can find a lot more about how overlays work [here](https://apereo.github.io/cas/6.0.x/installation/WAR-Overlay-Installation.html).

The concept of the WAR Overlay is NOT a CAS invention. It's specifically an *Apache Maven* feature and of course, there are techniques and plugins available to apply the same concept to Gradle-based builds as well. For this tutorial, the Gradle overlay we will be working with is [available here](https://github.com/apereo/cas-overlay-template).

<div class="alert alert-info">
  <strong>Gradle WAR Overlay</strong><br/>The Maven WAR overlay template is now deprecated and moved aside. The reference overlay project simply resides here and is transformed to use the Gradle build tool instead. This is done to reduce maintenance overhead and simplify the deployment strategy while allowing future attempts to make auto-generation of the overlay as comfortable as possible.
</div>

Once you have forked and cloned the repository locally, you're ready to begin.

<div class="alert alert-info">
  <strong>Note</strong><br/>Remember to switch to the appropriate branch. Today, the <code>master</code> branch of the repository applies to CAS <code>6.0.x</code> deployments. That may not necessarily remain true when you start your own deployment. So examine the branches and make sure you <code>checkout</code> the one matching your intended CAS version.
</div>

# Overlay's Anatomy

Similar to Grey's, a *Gradle* WAR overlay is composed of several facets the most important of which are the `build.gradle` and `gradle.properties` file. These are build-descriptor files whose job is to teach Gradle how to obtain, build, configure (and in certain cases deploy) CAS artifacts.

<div class="alert alert-info">
  <strong>KISS</strong><br/>You do not need to download Gradle separately. The project provides one for you automatically with the embedded Gradle Wrapper.
</div>

The CAS Gradle Overlay is composed of several sections. The ones you need to worry about are the following.

## Properties

In `gradle.properties` file, project settings and versions are specified:

```properties
cas.version=6.0.0
springBootVersion=2.1.0.RELEASE

appServer=-tomcat

gradleVersion=4.10.2
tomcatVersion=9
tomcatFullVersion=9.0.12

group=org.apereo.cas
sourceCompatibility=11
targetCompatibility=11
```

The `gradle.properties` file describes what versions of CAS, Spring Boot, and Java are required for the deployment. You are in practice mostly concerned with the `cas.version` setting and as new (maintenance) releases come out, it would be sufficient to simply update that version and re-run the build.

This might be a good time to review the CAS project's [Release Policy](https://apereo.github.io/cas/developer/Release-Policy.html) as well as [Maintenance Policy](https://apereo.github.io/cas/developer/Maintenance-Policy.html).

## Dependencies

The next piece describes the *dependencies* of the overlay build. These are the set of components almost always provided by the CAS project that will be packaged up and put into the final web application artifact. At a minimum, you need to have the `cas-server-webapp-${appServer}` module available because that is the web application into which you intend to inject your settings and customizations if any. Also, note that the module declarations are typically configured to download the CAS version instructed by the property `cas.version`.

Here is an example:

```groovy
dependencies {
    if (project.hasProperty("external")) {
        compile "org.apereo.cas:cas-server-webapp:${casServerVersion}"
    } else {
        compile "org.apereo.cas:cas-server-webapp${project.appServer}:${casServerVersion}"
    }
    // Other dependencies may be listed here...
}
```

Including a CAS module/dependency in the `build.gradle` simply advertises to CAS *your intention* of turning on a new feature or a variation of a current behavior. Do NOT include something in your build just because it looks and sounds cool. Remember that the point of an overlay is to only keep track of things you actually need and care about, and no more.

<div class="alert alert-warning">
  <strong>Remember</strong><br/>Keep your build clean and tidy. A messy build often leads to a messy deployment, complicates your upgrade path and is a documented cause of early hair loss. Keep changes down to the absolute essentials and document their need for your deployment. If you review the configuration a year from now, you should have an idea of why things are the way they are.
</div>

# The Build

Now that you have a basic understanding of the build descriptor, it's time to actually run the build. A Gradle build is often executed by passing specific goals/commands to Gradle itself, aka `gradlew`. So for instance in the terminal and once inside the project directory you could execute things like:

```bash
cd cas-overlay-template
gradlew clean
```

The WAR Overlay project provides you with an embedded Gradle *wrapper* whose job is to first determine whether you have Gradle installed. If not, it will download and configure one for you based on the project's needs.

So, how are you supposed to know what commands/goals can be passed to the build? You can hit the Gradle guides and docs to study these for sure, but the Overlay project also provides you with a shell script that wraps itself around the Gradle wrapper and provides an easy facade for you to remember commands and their use.

<div class="alert alert-info">
  <strong>Note</strong><br/>When in doubt, <code>gradlew tasks</code> is a good starting position to learn what tasks are available in the project.
</div>

This is the `build.sh` file, which you can run as such:

```bash
cd cas-overlay-template
./build.sh help
Usage: build.sh ...
```

The `help` command describes the set of available operations you may carry out with the build script.

<div class="alert alert-info">
  <strong>Remember</strong><br/>Docs grow old. Always consult the overlay project's <code>README</code> file to keep to date.
</div>

As an example, here's what I see if I were to run the `package` command:

```bash
./build.sh copy package

Creating configuration directory under /etc/cas
Copying configuration files from etc/cas to /etc/cas/config
etc/cas/config/application.yml -> /etc/cas/config/application.yml
etc/cas/config/cas.properties -> /etc/cas/config/cas.properties
etc/cas/config/log4j2.xml -> /etc/cas/config/log4j2.xml

Starting a Gradle Daemon (subsequent builds will be faster)
Configuration on demand is an incubating feature.

BUILD SUCCESSFUL in 14s
2 actionable tasks: 2 executed
...
```

You can see that the build attempts to download, clean, compile and package all artifacts, and finally, it produces a `build/libs/cas.war` which you can then use for actual deployments.

<div class="alert alert-info">
  <strong>Remember</strong><br/>You are allowed to pass any of Gradle's native command-line arguments to the <code>build.sh</code> file.
</div>

# Configuration

I am going to skip over the configuration of `/etc/cas/config` and all that it deals with. If you need the reference, you may always [use this guide](https://apereo.github.io/cas/6.0.x/configuration/Configuration-Management.html) to study various aspects of CAS configuration.

Suffice it to say that, quite simply, CAS deployment expects *the main* configuration file to be found under `/etc/cas/config/cas.properties`. This is a key-value store that is able to dictate and alter the behavior of the running CAS software.

As an example, you might encounter something like:

```properties
cas.server.name=https://cas.example.org:8443
cas.server.prefix=https://cas.example.org:8443/cas
logging.config=file:/etc/cas/config/log4j2.xml
```

...which at a minimum, identifies the CAS server's URL and prefix and instructs the running server to locate the logging configuration at `file:/etc/cas/config/log4j2.xml`. The overlay by default ships with a `log4j2.xml` that you can use to customize logging locations, levels, etc. Note that the presence of all that is contained inside `/etc/cas/config/` is optional. CAS will continue to fall back onto defaults if the directory and the files within are not found.

## Keep Track

It is **VERY IMPORTANT** that you contain and commit the entire overlay directory (save the obvious exclusions such as the `build` directory) into some sort of source control system, such as `git`. Treat your deployment just like any other project with tags, releases, and functional baselines.

# LDAP Authentication

We need to first establish a primary mode of validating credentials by sticking with [LDAP authentication](https://apereo.github.io/cas/6.0.x/installation/LDAP-Authentication.html). The strategy here, as indicated by the CAS documentation, is to declare the intention/module in the build script:

```groovy
compile "org.apereo.cas:cas-server-support-ldap:${casServerVersion}"
```

...and then configure the relevant `cas.authn.ldap[x]` settings for the directory server in use. Most commonly, that would translate into the following settings:

```properties
cas.authn.ldap[0].type=AUTHENTICATED
cas.authn.ldap[0].ldapUrl=ldaps://ldap1.example.org
cas.authn.ldap[0].baseDn=dc=example,dc=org
cas.authn.ldap[0].searchFilter=cn={user}
cas.authn.ldap[0].bindDn=cn=Directory Manager,dc=example,dc=org
cas.authn.ldap[0].bindCredential=...
```

To resolve and fetch the needed attributes which will be used later by CAS for release, the simplest way would be to let LDAP authentication retrieve the attributes directly from the directory server.  The following setting allows us to do just that:

```properties
cas.authn.ldap[0].principalAttributeList=memberOf,cn,givenName,mail
```

# Registering Applications

Client applications that wish to use the CAS server for authentication must be registered with the server apriori. CAS provides a number of [facilities to keep track of the registration records](https://apereo.github.io/cas/6.0.x/services/Service-Management.html#storage) and you may choose any that fits your needs best. In more technical terms, CAS deals with service management using two specific components: Individual implementations that support a form of a database are referred to as *Service Registry* components and they are many. There is also a parent component that sits on top of the configured service registry as more of an orchestrator that provides a generic facade and entry point for the rest of CAS without entangling all other operations and subsystems with the specifics and particulars of a storage technology.

In this tutorial, we are going to try to configure CAS with [the JSON service registry](https://apereo.github.io/cas/6.0.x/services/JSON-Service-Management.html).

## Configuration

First, ensure you have declared the appropriate module/intention in the build:

```groovy
compile "org.apereo.cas:cas-server-support-json-service-registry:${casServerVersion}"
```

Next, you must teach CAS how to look up JSON files to read and write registration records. This is done in the `cas.properties` file:

```properties
cas.serviceRegistry.initFromJson=false
cas.serviceRegistry.json.location=file:/etc/cas/services
```

...where a sample `ApplicationName-1001.json` would then be placed inside `/etc/cas/services`:

```json
{
  "@class" : "org.apereo.cas.services.RegexRegisteredService",
  "serviceId" : "https://app.example.org",
  "name" : "ApplicationName",
  "id" : 1001,
  "evaluationOrder" : 10
}
```

# Ticketing

A robust CAS deployment requires the presence and configuration of an *internal* database that is responsible for [keeping track of tickets](https://apereo.github.io/cas/6.0.x/ticketing/Configuring-Ticketing-Components.html) issued by CAS. CAS itself comes by default with a memory-based node-specific cache that is often more than sufficient for smaller deployments or certain variations of a [clustered deployment](https://apereo.github.io/cas/6.0.x/planning/High-Availability-Guide.html). Just like the service management facility, large variety of databases and storage options are supposed by CAS under the facade of a *Ticket Registry*.

In this tutorial, we are going to configure CAS to use a [Hazelcast Ticket Registry](https://apereo.github.io/cas/6.0.x/ticketing/Hazelcast-Ticket-Registry.html) with the assumption that our deployment is going to be deployed in an AWS-sponsored environment. Hazelcast Ticket Registry is often a decent choice when deploying CAS in a cluster and can take advantage of AWS's native support for Hazelcast in order to read node metadata properly and locate other CAS nodes in the same cluster in order to present a common, global and shared ticket registry. This is an ideal choice that requires very little manual work and/or troubleshooting, comparing to using options such as Multicast or manually noting down the address and location of each CAS server in the cluster.

## Configuration

First, ensure you have declared the appropriate module/intention in the build:

```groovy
compile "org.apereo.cas:cas-server-support-hazelcast-ticket-registry:${casServerVersion}"
```

Next, the AWS-specific configuration of Hazelcast would go into our `cas.properties`:

```properties
cas.ticket.registry.hazelcast.cluster.discovery.enabled=true
cas.ticket.registry.hazelcast.cluster.discovery.aws.accessKey=...
cas.ticket.registry.hazelcast.cluster.discovery.aws.secretKey=...
cas.ticket.registry.hazelcast.cluster.discovery.aws.region=us-east-1
cas.ticket.registry.hazelcast.cluster.discovery.aws.securityGroupName=...
# cas.ticket.registry.hazelcast.cluster.discovery.aws.tagKey=
# cas.ticket.registry.hazelcast.cluster.discovery.aws.tagValue=
```

That should do it.

Of course, if you are working on a more modest CAS deployment in an environment that is more or less owned by you and you prefer more explicit control over CAS node registrations in your cluster, the following settings would be more ideal:

```properties
# cas.ticket.registry.hazelcast.cluster.instanceName=localhost
# cas.ticket.registry.hazelcast.cluster.port=5701
# cas.ticket.registry.hazelcast.cluster.portAutoIncrement=true
cas.ticket.registry.hazelcast.cluster.members=123.321.123.321,223.621.123.521,...
```

# Multifactor Authentication via Duo Security

As a rather common use case, the majority of CAS deployments that intend to turn on multifactor authentication support tend to do so via [Duo Security](https://apereo.github.io/cas/6.0.x/installation/DuoSecurity-Authentication.html). We will be going through the same exercise here where we let CAS trigger Duo Security for users who belong to the `mfa-eligible` group, indicated by the `memberOf` attribute on the LDAP user account.


## Configuration

First, ensure you have declared the appropriate module/intention in the build:

```groovy
compile "org.apereo.cas:cas-server-support-duo:${casServerVersion}"
```

Then, put specific Duo Security settings in `cas.properties. Things such as the secret key, integration key, etc which should be provided by your Duo Security subscription:

```properties
cas.authn.mfa.duo[0].duoSecretKey=
cas.authn.mfa.duo[0].duoApplicationKey=
cas.authn.mfa.duo[0].duoIntegrationKey=
cas.authn.mfa.duo[0].duoApiHost=
```

At this point, we have enabled Duo Security and we just need to find a way to instruct CAS to route the authentication flow over to Duo Security in the appropriate condition. Our task here is to build a special condition that activates multifactor authentication if any of the values assigned to the attribute `memberOf` contain the value `mfa-eligible`. This condition is placed in the `cas.properties` file:

```properties
cas.authn.mfa.globalPrincipalAttributeNameTriggers=memberOf
cas.authn.mfa.globalPrincipalAttributeValueRegex=mfa-eligible
```

If the above condition holds true and CAS is to route to a multifactor authentication flow, that would obviously be one supported and provided by Duo Security since that’s the only provider that is currently configured to CAS.

# Monitoring & Status

Many CAS deployments rely on the `/status` endpoint for monitoring the health and activity of the CAS deployment. This endpoint is typically secured via an IP address, allowing external monitoring tools and load balancers to reach the endpoint and parse the output. In this quick exercise, we are going to accomplish that task, allowing the `status` endpoint to be available over HTTP to `localhost`.

## Configuration

To enable and expose the `status` endpoint, the following settings should come in handy:

```properties
management.endpoints.web.base-path=/actuator
management.endpoints.web.exposure.include=status
management.endpoint.status.enabled=true

cas.monitor.endpoints.endpoint.status.access=IP_ADDRESS
cas.monitor.endpoints.endpoint.status.requiredIpAddresses=127.0.0.1
```

Remember that the default path for endpoints exposed over the web is at `/actuator`, such as `/actuator/status`.

# Overlay Customization

The `build/libs` directory contains the results of the overlay process. Since I have not actually customized and overlaid anything yet, all configuration files simply match their default and are packaged as such. As an example, let's grab [the default message bundle](https://apereo.github.io/cas/6.0.x/ux/User-Interface-Customization-Localization.html) and change the text associated with `screen.welcome.instructions`.

<div class="alert alert-warning">
  <strong>Remember</strong><br/>Do NOT ever make changes in the <code>build</code> directory. The changesets will be cleaned out and set back to defaults every time you do a build. Follow the overlay process to avoid surprises.
</div>

First, I will need to move the file to my project directory so that during the overlay process Gradle can use that instead of what is provided by default.

Here we go:

```bash
./build.sh getresource messages.properties

Exploded the CAS web application file at build/cas
Searching for resource name messages.properties...
Found resource(s):
build/cas/WEB-INF/classes/messages.properties
Created resource at src/main/resources/messages.properties
src/main/resources/messages.properties
```

Then I'll leave everything in that file alone, except the line I want to change.

```properties
...
screen.welcome.instructions=Speak friend and enter.
...
```

Then I'll package things up as usual.

```bash
./build.sh package
```

If I `explode` the built web application again and look at `build/cas/WEB-INF/classes/messages.properties` after the build, I should see that the overlay process has picked and overlaid onto the default *my version* of the file.

<div class="alert alert-info">
  <strong>Remember</strong><br/>Only overlay and modify files you actually need and try to use externalized resources and configuration as much as possible. Just because you CAN override something in the default package, it doesn't mean that you should.
</div>

# User Interface Customizations

In order to modify the CAS HTML views, each file first needs to be brought over into the overlay. You can use the `build.sh listviews` command to see what HTML views are available for customizations. Once chosen, simply use `build.sh getview footer.html` to bring the view into your overlay.

```bash
Exploded the CAS web application file at build/cas
Searching for view name footer.html...
Found view(s):
build/cas/WEB-INF/classes/templates/fragments/footer.html
Created view at src/main/resources/templates/fragments/footer.html
src/main/resources/templates/fragments/footer.htm
```

Now that you have the `footer.html` brought into the overlay, you can simply modify the file at `src/main/resources/templates/fragments/footer.html`, and then repackage and run the build as usual.

# Deploy

You have a number of options when it comes to deploying the final `cas.war` file. The easiest approach would be to simply use the `build.sh run` command and have the overlay be deployed inside an embedded container. By default, the CAS web application expects to run on the secure port `8443` which requires that you create a keystore file at `/etc/cas/` named `thekeystore`.

## Deploy Behind a Proxy

Using the embedded Apache Tomcat container provided by CAS automatically is the recommended approach in almost all cases (The embedded bit; not the Apache Tomcat bit) as the container configuration is entirely automated by CAS and its version is guaranteed to be compatible with the running CAS deployment. Furthermore, updates and maintenance of the servlet container are handled at the CAS project level where you as the adopter are only tasked with making sure your deployment is running the latest available release to take advantage of such updates.

If you wish to run CAS via the embedded Apache Tomcat container behind a proxy or load balancer and have that entity terminate SSL, you will need to open up a communication channel between the proxy and CAS such that (as an example):

- Apache Tomcat runs on port 8080, assuming that’s what the proxy uses to talk to CAS.
- Apache Tomcat has SSL turned off.
- Apache Tomcat connector listening on the above port is marked as secure.

The above tasklist translates to the following properties expected to be found in your `cas.properties`:

```properties
server.port=8080
server.ssl.enabled=false
cas.server.tomcat.http.enabled=false
cas.server.tomcat.httpProxy.enabled=true
cas.server.tomcat.httpProxy.secure=true
cas.server.tomcat.httpProxy.scheme=https
```

# What About...?

For more content, [please see this link](https://apereo.github.io/tags/#CAS).

# So...

It's important that you start off simple and make changes one step at a time. Once you have a functional environment, you can gradually and slowly add customizations to move files around.

I hope this review was of some help to you and I am sure that both this post as well as the functionality it attempts to explain can be improved in any number of ways. Please feel free to [engage and contribute](https://apereo.github.io/cas/developer/Contributor-Guidelines.html) as best as you can.

[Misagh Moayyed](https://fawnoos.com)
