---
layout:     post
title:      CAS 5.0.x Deployment - WAR Overlays
summary:    Learn how to configure and build your own CAS deployment via the WAR overlay method, get rich quickly, stay healthy indefinitely and respect family and friends in a few very easy steps. 
tags:       [CAS]
---

This is a short and sweet tutorial on how to deploy CAS via [the WAR Overlay method](https://apereo.github.io/cas/5.0.x/installation/Maven-Overlay-Installation.html).

This tutorial specifically requires and focuses on:

- CAS `5.0.x`
- Java 8

<!--
Furthermore, this tutorial assumes that you are running CAS in its `standalone` mode, [described here](https://apereo.github.io/cas/5.0.x/installation/Configuration-Server-Management.html).
-->

# Overlay...What?

Overlays are a strategy to combat repetitive code and/or resources. Rather than downloading the CAS codebase and building it from source, overlays allow you to download a pre-built vanilla CAS web application server provided by the project itself, override/insert specific behavior into it and then merge it all back together to produce the final (web application) artifact. You can find a lot more about how overlays work [here](https://apereo.github.io/cas/5.0.x/installation/Maven-Overlay-Installation.html).

<div class="alert alert-info">
  <strong>Note</strong><br/>The concept of the WAR Overlay is NOT a CAS invention. It's specifically an <a href="https://maven.apache.org/plugins/maven-war-plugin/overlays.html">Apache Maven</a> feature and of course there are techniques and plugins available to apply the same concept to Gradle-based builds as well.
</div>

You are free to choose between Maven or Gradle. For this tutorial I opted into the [Maven WAR ovelay](https://github.com/apereo/cas-overlay-template).

Once you have forked and cloned the repository locally, you're ready to begin.

<div class="alert alert-info">
  <strong>Note</strong><br/>Remember to switch to the appropriate branch. Today, the <code>master</code> branch of the repository applies to CAS <code>5.0.x</code> deployments. That may not necessarily remain true when you start your own deployment. So examine the branches and make sure you <code>checkout</code> the one matching your intended CAS version.
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
    <cas.version>5.0.4</cas.version>
    <springboot.version>1.4.2.RELEASE</springboot.version>
    <maven.compiler.source>1.8</maven.compiler.source>
    <maven.compiler.target>1.8</maven.compiler.target>
    <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
</properties>
```

This is the bit that describes build settings, and specifically here, what versions of CAS, Spring Boot and Java are required for the deployment. You are in practice mostly concerned with the `<cas.version>` setting and as new (maintenance) releases come out, it would be sufficient to simply update that version and re-run the build.

This might be a good time to review the CAS project's [Release Policy](https://apereo.github.io/cas/developer/Release-Policy.html) as well as [Maintenance Policy](https://apereo.github.io/cas/developer/Maintenance-Policy.html).

## Dependencies

The next piece describes the *dependencies* of the overlay build. These are the set of components almost always provided by the CAS project that will be packaged up and put into the final web application artifact. At a minimum, you need to have the `cas-server-webapp` module available because that is the web application into which you intend to inject your settings and customizations, if any. Also, note that the module declarations are typically configured to download the CAS version instructed by the property `${cas.version}`.

Here is an example:

```xml
<dependencies>
    <dependency>
        <groupId>org.apereo.cas</groupId>
        <artifactId>cas-server-webapp</artifactId>
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

Now that you have a basic understanding of the build descriptor, it's time to actually run the build. An Apache Maven build is often executed by passing specific goals/commands to Apache Maven itself, aka `mvn`. So for instance in the the terminal and once inside the project directory you could execute things like:

```bash
cd cas-overlay-template
mvn clean
```

...which may be a problem if you don't have already have Apache Maven downloaded and installed. While you can do that separate install, the WAR Overlay project provides you with an embedded Apache Maven instance whose job is to first determine whether you have Maven installed and if not, download and configure one for you based on the project's needs. So you can replace that command above with:

```bash
cd cas-overlay-template
mvnw clean
```

...which may be a problem because, how are you supposed to know what commands/goals can be passed to the build? You can [study them](https://maven.apache.org/guides/introduction/introduction-to-the-lifecycle.html) for sure, but the project provides you with a shell script that wraps itself around the Maven wrapper and provides an easy facade for you remember commands and their use. This is the `build.sh` file, which you can run as such:

```bash
cd cas-overlay-template
./build.sh help
Usage: build.sh [copy|clean|package|run|debug|bootrun]
```

What do these commands do?

| Type                    | Description
|-------------------------|----------------------------------------------------------------------------------------------------
| `copy`                  | Copies the configuration from the local `etc/cas/config` directory to `/etc/cas/config`. [See this guide](https://apereo.github.io/cas/5.0.x/installation/Configuration-Server-Management.html) to learn more.
| `clean`                 | Deletes any previously-built and leftover artifacts from the `target` directory.
| `package`               | Runs `clean` and `copy`. Then packages the CAS web application artifact and run through the overlay to inject local customizations. The outcome is a `target/cas.war` file which is ready to be deployed.
| `run`                   | Invokves `package` and then deploys and runs the CAS web application via its own embedded server container.
| `debug`                 | Same thing as `run`, except that you can remote-debug the CAS web application over port `5000`.
| `bootrun`               | Same thing as `run`, except the deployment is managed by the [Spring Boot Maven plugin](http://docs.spring.io/spring-boot/docs/current/reference/html/build-tool-plugins-maven-plugin.html). This command has very specialized and limited use cases. Please [review this issue](https://github.com/apereo/cas/issues/2334) to learn more.

<div class="alert alert-info">
  <strong>Remember</strong><br/>Docs grow old. Always consult the overlay project's <code>README</code> file to keep to date.
</div>

As an example, here's what I see if I were to run the `package` command:

```bash
./build.sh package

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
[INFO] Processing overlay [ id org.apereo.cas:cas-server-webapp]
[INFO] Webapp assembled in [786 msecs]
[INFO] Building war: /cas-overlay-template/target/cas.war
[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------
[INFO] Total time: 2.504 s (Wall Clock)
[INFO] Finished at: 2017-03-23T14:57:11+04:30
[INFO] Final Memory: 12M/441M
[INFO] ------------------------------------------------------------------------
```

You can see that the build attempts to download, clean, compile and package all artifacts, and finally it produces a `/cas-overlay-template/target/cas.war` which you can then use for actual deployments.

<div class="alert alert-info">
  <strong>Remember</strong><br/>You are allowed to pass any of Maven's native command-line arguments to the <code>build.sh</code> file. Things like <code>-U</code> or <code>-X</code> might be useful to have handy.
</div>

# Configuration

I am going to skip over the configuartion of `/etc/cas/config` and all that it deals with. If you need the reference, you may always [use this guide](https://apereo.github.io/cas/5.0.x/installation/Configuration-Management.html) to study various aspects of CAS configuration.

Suffice it to say that, quite simply, CAS deployment expects *the main* configuration files to be found under `/etc/cas/config/cas.properties`. This is a key-value store tha is able to dictate and alter behavior of the running CAS software.
As an example, you might encouter something like:

```properties
cas.server.name=https://cas.example.org:8443
cas.server.prefix=https://cas.example.org:8443/cas
logging.config=file:/etc/cas/config/log4j2.xml
```

...which at a minimum, the above settings identify the CAS server's url and prefix and instruct the running server to locate the logging configuration at the specified location. The overlay by default ships with a `log4j2.xml` that you can use to customize logging locations, levels, etc. Note that the presense of all that is contained inside `/etc/cas/config/` is optional. CAS will continue to fall back onto defaults if the directory and the files within are not found.

# Overlay Customization

If I `cd` into the `target/cas` directory, I can see an *exploded* version of the `cas.war` file. This is the directory that contains the results of the overlay process. Since I have not actually customized and overlaid anything yet, all configuration files simply match their default and are packaged as such. So as an example, let's change something.

Digging further down, I notice there exists a `/target/cas/WEB-INF/classes/messages.properties` file, which is [the default message bundle](https://apereo.github.io/cas/5.0.x/installation/User-Interface-Customization-Localization.html). I decide that I am going to change the text associated with `screen.welcome.instructions`.

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
[INFO] Assembling webapp [cas-overlay] in [/Users/Misagh/Workspace/GitWorkspace/cas-overlay-template/target/cas]
[info] Copying manifest...
[INFO] Processing war project
[INFO] Processing overlay [ id org.apereo.cas:cas-server-webapp]
[INFO] Webapp assembled in [1005 msecs]
[INFO] Building war: /Users/Misagh/Workspace/GitWorkspace/cas-overlay-template/target/cas.war
[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
...

```

If I look at `target/cas/WEB-INF/classes/messages.properties` after the build, I should see that the overlay process has picked and overlaid onto the default *my version* of the file.

<div class="alert alert-info">
  <strong>Remember</strong><br/>Only overlay and modify files you actually need, and try to use externalized resources and configuration as much as possible. Just because you CAN override something in the default package, it doesn't mean that you can or should.
</div>

# Deploy



[Misagh Moayyed](https://twitter.com/misagh84)