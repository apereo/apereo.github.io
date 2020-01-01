---
layout:     post
title:      CAS 5.3.x Deployment - WAR Overlays
summary:    Learn how to configure and build your own CAS deployment via the WAR overlay method, get rich quickly, stay healthy indefinitely and respect family and friends in a few very easy steps.
tags:       [CAS]
---

This is a short and sweet tutorial on how to deploy CAS via [the WAR Overlay method](https://apereo.github.io/cas/5.3.x/installation/Maven-Overlay-Installation.html).

This tutorial specifically requires and focuses on:

- CAS `5.3.x`
- Java 8

<div class="alert alert-info">
  <strong>Need Help?</strong><br/>If you ever get stuck and are in need of additional assistance, start by reviewing the suggestions <a href="https://apereo.github.io/cas/5.3.x/installation/Troubleshooting-Guide.html">provided here</a>. You may also look at available support options <a href="https://apereo.github.io/cas/Support.html">provided here</a>.
</div>

<!--
Furthermore, this tutorial assumes that you are running CAS in its `standalone` mode, [described here](https://apereo.github.io/cas/5.3.x/installation/Configuration-Server-Management.html).
-->

# Overlay...What?

Overlays are a strategy to combat repetitive code and/or resources. Rather than downloading the CAS codebase and building it from source, overlays allow you to download a pre-built vanilla CAS web application server provided by the project itself, override/insert specific behavior into it and then merge it all back together to produce the final (web application) artifact. You can find a lot more about how overlays work [here](https://apereo.github.io/cas/5.3.x/installation/Maven-Overlay-Installation.html).

The concept of the WAR Overlay is NOT a CAS invention. It's specifically an Apache Maven feature and of course, there are techniques and plugins available to apply the same concept to Gradle-based builds as well.You are free to choose between Maven or Gradle. For this tutorial, I opted into the [Maven WAR overlay](https://github.com/apereo/cas-overlay-template).

Once you have forked and cloned the repository locally, you're ready to begin.

<div class="alert alert-info">
  <strong>Note</strong><br/>Remember to switch to the appropriate branch. Today, the <code>master</code> branch of the repository applies to CAS <code>5.2.x</code> deployments. That may not necessarily remain true when you start your own deployment. So examine the branches and make sure you <code>checkout</code> the one matching your intended CAS version.
</div>

# Overlay's Anatomy

Similar to Grey's, a *Maven* WAR overlay is composed of several facets the most important of which is the `pom.xml` file. This is a build descriptor file whose job is to teach Apache Maven how to obtain, build, configure (and in certain cases deploy) artifacts.

<div class="alert alert-info">
  <strong>KISS</strong><br/>You do not need to download Apache Maven separately. The project provides one for you automatically with the embedded Maven Wrapper.
</div>

The `pom.xml` is composed of several sections. The ones you need to worry about are the following.

## Properties

```xml
<properties>
    <cas.version>5.3.5</cas.version>
    <springboot.version>1.5.16.RELEASE</springboot.version>
    <maven.compiler.source>1.8</maven.compiler.source>
    <maven.compiler.target>1.8</maven.compiler.target>
    <app.server>-tomcat</app.server>
    <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
</properties>
```

This is the bit that describes build settings, and specifically, here, what versions of CAS, Spring Boot, and Java are required for the deployment. You are in practice mostly concerned with the `<cas.version>` setting and as new (maintenance) releases come out, it would be sufficient to simply update that version and re-run the build.

This might be a good time to review the CAS project's [Release Policy](https://apereo.github.io/cas/developer/Release-Policy.html) as well as [Maintenance Policy](https://apereo.github.io/cas/developer/Maintenance-Policy.html).

## Dependencies

The next piece describes the *dependencies* of the overlay build. These are the set of components almost always provided by the CAS project that will be packaged up and put into the final web application artifact. At a minimum, you need to have the `cas-server-webapp-${app.server}` module available because that is the web application into which you intend to inject your settings and customizations if any. Also, note that the module declarations are typically configured to download the CAS version instructed by the property `${cas.version}`.

Here is an example:

```xml
<dependencies>
    <dependency>
        <groupId>org.apereo.cas</groupId>
        <artifactId>cas-server-webapp${app.server}</artifactId>
        <version>${cas.version}</version>
        <type>war</type>
        <scope>runtime</scope>
    </dependency>
</dependencies>
```

Including a CAS module/dependency in the `pom.xml` simply advertises to CAS *your intention* of turning on a new feature or a variation of a current behavior. Do NOT include something in your build just because it looks and sounds cool. Remember that the point of an overlay is to only keep track of things you actually need and care about, and no more.

<div class="alert alert-warning">
  <strong>Remember</strong><br/>Keep your build clean and tidy. A messy build often leads to a messy deployment, complicates your upgrade path and is a documented cause of early hair loss. Keep changes down to the absolute essentials and document their need for your deployment. If you review the configuration a year from now, you should have an idea of why things are the way they are.
</div>

## And What About...?

There are many other pieces in the `pom.xml`, such as repositories, profiles, plugins, etc that I skipped. For everything else, there is MasterCard...and of course the official [Apache Maven guides](http://maven.apache.org/guides/). Enjoy!

# The Build

Now that you have a basic understanding of the build descriptor, it's time to actually run the build. An Apache Maven build is often executed by passing specific goals/commands to Apache Maven itself, aka `mvn`. So for instance in the terminal and once inside the project directory you could execute things like:

```bash
cd cas-overlay-template
mvn clean
```

...which may be a problem if you don't have already have Apache Maven downloaded and installed. While you can do that separate install, the WAR Overlay project provides you with an embedded Apache Maven instance whose job is to first determine whether you have Maven installed and if not, download and configure one for you based on the project's needs. So you can replace that command above with:

```bash
cd cas-overlay-template
mvnw clean
```

...which may be a problem because, how are you supposed to know what commands/goals can be passed to the build? You can [study them](https://maven.apache.org/guides/introduction/introduction-to-the-lifecycle.html) for sure, but the project provides you with a shell script that wraps itself around the Maven wrapper and provides an easy facade for you to remember commands and their use. This is the `build.sh` file, which you can run as such:

```bash
cd cas-overlay-template
./build.sh help
Usage: build.sh [copy|clean|package|run|debug|bootrun]
```

What do these commands do?

| Type                    | Description
|-------------------------|----------------------------------------------------------------------------------------------------
| `copy`                  | Copies the configuration from the local `etc/cas/config` directory to `/etc/cas/config`. [See this guide](https://apereo.github.io/cas/5.3.x/installation/Configuration-Server-Management.html) to learn more.
| `clean`                 | Deletes any previously-built and leftover artifacts from the `target` directory.
| `package`               | Runs `clean` and `copy`. Then packages the CAS web application artifact and run through the overlay to inject local customizations. The outcome is a `target/cas.war` file which is ready to be deployed.
| `run`                   | Involves `package` and then deploys and runs the CAS web application via its own embedded server container.
| `debug`                 | Same thing as `run`, except that you can remote-debug the CAS web application over port `5000`.
| `help`                  | Display available commands.
| `listviews`             | List the current CAS UI views that are available to the overlay and can be customized.
| `getview`               | Download a CAS view into the overlay and prepare it for customizations.
| `cli`                   | Step into the command-line shell and interact with CAS.

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

[INFO] Scanning for projects...
[INFO]
[INFO] Using the MultiThreadedBuilder implementation with a thread count of 5
[INFO]
[INFO] ------------------------------------------------------------------------
[INFO] Building cas-overlay 1.0
[INFO] ------------------------------------------------------------------------
[INFO]
[INFO] --- maven-clean-plugin:2.5:clean (default-clean) @ cas-overlay ---
[INFO]
[INFO] --- maven-resources-plugin:2.6:resources (default-resources) @ cas-overlay ---
[INFO] Using 'UTF-8' encoding to copy filtered resources.
[INFO] skip non existing resourceDirectory /cas-overlay-template/src/main/resources
[INFO]
[INFO] --- maven-compiler-plugin:3.3:compile (default-compile) @ cas-overlay ---
[INFO] No sources to compile
[INFO]
[INFO] --- maven-resources-plugin:2.6:testResources (default-testResources) @ cas-overlay ---
[INFO] Using 'UTF-8' encoding to copy filtered resources.
[INFO] skip non existing resourceDirectory /cas-overlay-template/src/test/resources
[INFO]
[INFO] --- maven-compiler-plugin:3.3:testCompile (default-testCompile) @ cas-overlay ---
[INFO] No sources to compile
[INFO]
[INFO] --- maven-surefire-plugin:2.12.4:test (default-test) @ cas-overlay ---
[INFO] No tests to run.
[INFO]
[INFO] --- maven-war-plugin:2.6:war (default-war) @ cas-overlay ---
[INFO] Packaging webapp
[INFO] Assembling webapp [cas-overlay] in [/cas-overlay-template/target/cas]
[info] Copying manifest...
[INFO] Processing war project
[INFO] Processing overlay [ id org.apereo.cas:cas-server-webapp-tomcat]
[INFO] Webapp assembled in [786 msecs]
[INFO] Building war: /cas-overlay-template/target/cas.war
[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------
...
```

You can see that the build attempts to download, clean, compile and package all artifacts, and finally, it produces a `/cas-overlay-template/target/cas.war` which you can then use for actual deployments.

<div class="alert alert-info">
  <strong>Remember</strong><br/>You are allowed to pass any of Maven's native command-line arguments to the <code>build.sh</code> file. Things like <code>-U</code> or <code>-X</code> might be useful to have handy.
</div>

# Configuration

I am going to skip over the configuration of `/etc/cas/config` and all that it deals with. If you need the reference, you may always [use this guide](https://apereo.github.io/cas/5.3.x/installation/Configuration-Management.html) to study various aspects of CAS configuration.

Suffice it to say that, quite simply, CAS deployment expects *the main* configuration file to be found under `/etc/cas/config/cas.properties`. This is a key-value store that is able to dictate and alter the behavior of the running CAS software.

As an example, you might encounter something like:

```properties
cas.server.name=https://cas.example.org:8443
cas.server.prefix=https://cas.example.org:8443/cas
logging.config=file:/etc/cas/config/log4j2.xml
```

...which at a minimum, identifies the CAS server's URL and prefix and instructs the running server to locate the logging configuration at `file:/etc/cas/config/log4j2.xml`. The overlay by default ships with a `log4j2.xml` that you can use to customize logging locations, levels, etc. Note that the presence of all that is contained inside `/etc/cas/config/` is optional. CAS will continue to fall back onto defaults if the directory and the files within are not found.

## Keep Track

It is **VERY IMPORTANT** that you contain and commit the entire overlay directory (save the obvious exclusions such as the `target` directory) into some sort of source control system, such as `git`. Treat your deployment just like any other project with tags, releases, and functional baselines.

# LDAP Authentication

We need to first establish a primary mode of validating credentials by sticking with [LDAP authentication](https://apereo.github.io/cas/5.3.x/installation/LDAP-Authentication.html). The strategy here, as indicated by the CAS documentation, is to declare the intention/module in the build script:

```xml
<dependency>
     <groupId>org.apereo.cas</groupId>
     <artifactId>cas-server-support-ldap</artifactId>
     <version>${cas.version}</version>
</dependency>
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

Client applications that wish to use the CAS server for authentication must be registered with the server a-priori. CAS provides a number of [facilities to keep track of the registration records](https://apereo.github.io/cas/5.3.x/installation/Service-Management.html#storage) and you may choose any that fits your needs best. In more technical terms, CAS deals with service management using two specific components: Individual implementations that support a form of a database are referred to as *Service Registry* components and they are many. There is also a parent component that sits on top of the configured service registry as more of an orchestrator that provides a generic facade and entry point for the rest of CAS without entangling all other operations and subsystems with the specifics and particulars of a storage technology.

In this tutorial, we are going to try to configure CAS with [the JSON service registry](https://apereo.github.io/cas/5.3.x/installation/JSON-Service-Management.html).

## Configuration

First, ensure you have declared the appropriate module/intention in the build:

```xml
<dependency>
      <groupId>org.apereo.cas</groupId>
      <artifactId>cas-server-support-json-service-registry</artifactId>
      <version>${cas.version}</version>
</dependency>
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

A robust CAS deployment requires the presence and configuration of an *internal* database that is responsible for [keeping track of tickets](https://apereo.github.io/cas/5.3.x/installation/Configuring-Ticketing-Components.html) issued by CAS. CAS itself comes by default with a memory-based node-specific cache that is often more than sufficient for smaller deployments or certain variations of a [clustered deployment](https://apereo.github.io/cas/5.3.x/planning/High-Availability-Guide.html). Just like the service management facility, large variety of databases and storage options are supposed by CAS under the facade of a *Ticket Registry*.

In this tutorial, we are going to configure CAS to use a [Hazelcast Ticket Registry](https://apereo.github.io/cas/5.3.x/installation/Hazelcast-Ticket-Registry.html) with the assumption that our deployment is going to be deployed in an AWS-sponsored environment. Hazelcast Ticket Registry is often a decent choice when deploying CAS in a cluster and can take advantage of AWS's native support for Hazelcast in order to read node metadata properly and locate other CAS nodes in the same cluster in order to present a common, global and shared ticket registry. This is an ideal choice that requires very little manual work and/or troubleshoot, comparing to using options such as Multicast or manually noting down the address and location of each CAS server in the cluster.

## Configuration

First, ensure you have declared the appropriate module/intention in the build:

```xml
<dependency>
      <groupId>org.apereo.cas</groupId>
      <artifactId>cas-server-support-hazelcast-ticket-registry</artifactId>
      <version>${cas.version}</version>
</dependency>
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

# Overlay Customization

If I `cd` into the `target/cas` directory, I can see an *exploded* version of the `cas.war` file. This is the directory that contains the results of the overlay process. Since I have not actually customized and overlaid anything yet, all configuration files simply match their default and are packaged as such. So as an example, let's change something.

Digging further down, I notice there exists a `/target/cas/WEB-INF/classes/messages.properties` file, which is [the default message bundle](https://apereo.github.io/cas/5.3.x/installation/User-Interface-Customization-Localization.html). I decided that I am going to change the text associated with `screen.welcome.instructions`.

<div class="alert alert-warning">
  <strong>Remember</strong><br/>Do NOT ever make changes in the <code>target</code> directory. The changesets will be cleaned out and set back to defaults every time you do a build. Follow the overlay process to avoid surprises.
</div>

First, I will need to move the file to my project directory so that Apache Maven during the overlay process can use that instead of what is provided by default.

Here we go:

```bash
cd cas-overlay-template
mkdir -p src/main/resources
cp target/cas/WEB-INF/classes/messages.properties src/main/resources/
```

Then I'll leave everything in that file alone, except the line I want to change.

```properties
...
screen.welcome.instructions=Speak Friend and you shall enter.
...
```

Then I'll package things up as usual.

```bash
./build.sh package

...
[INFO] --- maven-war-plugin:2.6:war (default-war) @ cas-overlay ---
[INFO] Packaging webapp
[INFO] Assembling webapp [cas-overlay] in [/cas-overlay-template/target/cas]
[info] Copying manifest...
[INFO] Processing war project
[INFO] Processing overlay [ id org.apereo.cas:cas-server-webapp-tomcat]
[INFO] Webapp assembled in [1005 msecs]
[INFO] Building war: /cas-overlay-template/target/cas.war
[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
...

```

If I look at `target/cas/WEB-INF/classes/messages.properties` after the build, I should see that the overlay process has picked and overlaid onto the default *my version* of the file.

<div class="alert alert-info">
  <strong>Remember</strong><br/>Only overlay and modify files you actually need and try to use externalized resources and configuration as much as possible. Just because you CAN override something in the default package, it doesn't mean that you should.
</div>

# User Interface Customizations

In order to modify the CAS HTML views, each file first needs to be brought over into the overlay. You can use the `build.sh listviews` command to see what HTML views are available for customizations. Once chosen, simply use `build.sh getview footer.html` to bring the view into your overlay.

```bash
Exploded the CAS web application file.
Searching for view name footer.html...
Found view(s):
/cas-overlay-template/target/cas/WEB-INF/classes/templates/fragments/footer.html
Created view at /cas-overlay-template/src/main/resources/templates/fragments/footer.html
/cas-overlay-template/src/main/resources/templates/fragments/footer.html
```

Now that you have the `footer.html` brought into the overlay, you can simply modify the file at `cas-overlay-template/src/main/resources/templates/fragments/footer.html`, and then repackage and run the build as usual.

# Deploy

You have a number of options when it comes to deploying the final `cas.war` file. [This post](https://apereo.github.io/2016/10/04/casbootoverlay/) should help. The easiest approach would be to simply use the `build.sh run` command and have the overlay be deployed inside an embedded container.

# What About...?

- [CAS Multifactor Authentication with Duo Security](https://apereo.github.io/2018/01/08/cas-mfa-duosecurity/)
- [CAS 5 LDAP AuthN and Jasypt Configuration](https://apereo.github.io/2017/03/24/cas51-ldapauthnjasypt-tutorial/)
- [CAS 5 SAML2 Delegated AuthN Tutorial](https://apereo.github.io/2017/03/22/cas51-delauthn-tutorial/)

For more content, [please see this link](https://apereo.github.io/tags/#CAS).

# So...

It's important that you start off simple and make changes one step at a time. Once you have a functional environment, you can gradually and slowly add customizations to move files around.

I hope this review was of some help to you and I am sure that both this post as well as the functionality it attempts to explain can be improved in any number of ways. Please feel free to [engage and contribute](https://apereo.github.io/cas/developer/Contributor-Guidelines.html) as best as you can.

[Misagh Moayyed](https://fawnoos.com)
