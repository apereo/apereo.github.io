---
layout:     post
title:      Apereo CAS - Jib at CAS Docker Images
summary:    Learn how you may use Jib, an open-source Java containerizer from Google, and its Gradle plugin to build CAS docker images seamlessly without stepping too deep into scripting Dockerfile commands.
tags:       [CAS]
---

<div class="alert alert-success">
  <strong>Collaborate</strong><br/>The blog is managed and hosted on GitHub. If you wish to update the contents of this post or if you have found an inaccuracy and wish to make corrections, we recommend that you please submit a pull request to <a href="https://github.com/apereo/apereo.github.io">this repository</a>.
</div>

Unless you've been living under a rock, you've probably heard about [Docker](https://www.docker.com/). By combining its container engine technology and container platform, Docker enables you to bring traditional and cloud-native applications into an automated and secure supply chain, advancing dev to ops collaboration and reducing time to value.

CAS [embraced Docker](https://github.com/apereo/cas-webapp-docker) a while ago by providing a sample `Dockerfile` template to kickstart the builds. This template simply wraps the necessary environment and components, such as OS and Java, around an existing WAR Overlay project. There is a fair amount of smarts and creativity that could go into the build to optimize build layers, take advantage of Docker *multi-stage builds* and more to produce an ideal CAS image for deployment.

This tutorial focuses on an alternative approach to building CAS docker images by using [Jib](https://github.com/GoogleContainerTools/jib). Jib is an open-source Java containerizer from Google that lets Java developers build containers using the tools they know. It is a container image builder that handles all the steps of packaging your application into a container image. It does not require you to write a Dockerfile or have Docker installed, and it is directly integrated into Maven and Gradle.

Starting with CAS `6`, The existing Gradle overlay embraces the [Jib Gradle Plugin](https://github.com/GoogleContainerTools/jib/tree/master/jib-gradle-plugin#quickstart) to provide easy-to-use out-of-the-box tooling for building CAS docker images. Our starting position is based on the following:

- CAS `6.0.0-RC4`
- Java 11
- [CAS Overlay](https://github.com/apereo/cas-overlay-template) (The `master` branch specifically)
- [Docker](https://www.docker.com/get-started)


## Overview

Once you have cloned the CAS WAR overlay, a rather simplified workflow for building a CAS Docker image using `jib` is as follows:

1. Create a valid keystore at `${overlay-path}/etc/cas/thekeystore`
2. Massage your CAS configuration for settings and logging at `${overlay-path}/etc/cas/config`
3. Build the CAS overlay to produce and run the docker image.

Assuming you have completed the first two steps, let's move on to the build step.

## Docker Image

If you execute the build shell script, you should be greeted with a new `docker` command as such:

```bash
./build.sh help

Apereo CAS
Enterprise Single SignOn for all earthlings and beyond
*****************************************************
Usage: build.sh [...]
    ...
    docker: Build a Docker image based on the current build and configuration
    ...
```

Seems like the one we might need. Let's run it:

```bash
./build.sh docker

...
Configuration on demand is an incubating feature.
warning: Setting image creation time to current time; your image may not be reproducible.

Containerizing application to Docker daemon as org.apereo.cas/cas...
Getting base image adoptopenjdk/openjdk11:jdk11-alpine-nightly-slim...
Building dependencies layer...
Building snapshot dependencies layer...
Building resources layer...
Building classes layer...
The base image requires auth. Trying again for adoptopenjdk/openjdk11:jdk11-alpine-nightly-slim...
Finalizing...

Container entrypoint set to [docker/entrypoint.sh]
Loading to Docker daemon...

Built image to Docker daemon as org.apereo.cas/cas
```

What's happening here is that the Gradle build is invoking the `jib` plugin to fetch a base image, and then build all other required layers on top of it. Our CAS settings and logging configuration, etc as well as the `cas.war` are moved into the image to subsequently be handled via the startup shell script, which is the point where we instruct the build and Docker to use an *entrypoint* allowing our image to turn into a running container.

If you query for available Docker images, you might see:

```bash
docker images
...
org.apereo.cas/cas latest 34a3d3502970 4 minutes ago 551MB
...
```

...which may then conveniently be executed via the following:

```bash
docker run --name cas -p 8443:8443 -d org.apereo.cas/cas
docker logs -f cas
```

That is all it takes.

## Aftermath

It is evidently very convenient to use the same CAS build to generate a Docker image without dabbling too much into the specifics and nuances of a `Dockerfile` syntax. There are also few configuration options available in the Gradle build that allow one to decide the base image, expose ports and assign tags and labels. More interestingly and while the CAS build tries to keep things simple, `jib` really makes pushing images to remote registries easy by supporting the likes of Docker Hub, Google Container Registry and Amazon Elastic Container Registry all in on spot using a familiar consistent syntax.

In doing so, it should be noted that the `jib` plugin and project is relatively new with the initial project announcement dating back to July 2018. Furthermore, support for Spring Boot projects and especially those that build WARs and double-specifically those that depend and work with WAR Overlays such as CAS is extremely brand new. It is completely plausible that future iterations of the plugin allow tighter integrations with the Docker engine to produce better-optimized images, expose more configuration knobs and keep improving WAR support. If the current behavior and capabilities of this plugin do not meet the requirements, you're welcome to continue using the native `Dockerfile` approach and keep an eye towards newer versions of the plugin.

## Finale

I hope this review was of some help to you and I am sure that both this post as well as the functionality it attempts to explain can be improved in any number of ways. Please feel free to [engage and contribute](https://apereo.github.io/cas/developer/Contributor-Guidelines.html) as best as you can.

[Misagh Moayyed](https://twitter.com/misagh84)