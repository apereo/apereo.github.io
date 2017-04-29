---
layout:     post
title:      CAS 5.0.x Integration w/ Apache ZooKeeper
summary:    Learn how to have Apache ZooKeeper manage the configuration of CAS 5.0.x
tags:       [CAS]
---

<div class="alert alert-info">
  <strong>Contributed Content</strong><br/>Giovanni Morelli (Email: <kbd>giannimorell at gmail.com</kbd>, Github: <kbd>@GiovanniMorelli</kbd>) was kind enough to share this guide.
</div>

I have created a `cas-server-core-configuration-cloud-zookeeper` module for CAS `5.0.4` based on `cas-server-core-configuration-cloud-mongo`
When CAS is started, it reads all properties under zookeeper's path: `/cas/config/cas` without the need to configure `cas.properties`.

The project source code is [available here](https://drive.google.com/file/d/0B984z5r9uFKgR3dNa3JIbm1lRnM/view).

# Configuration

- Add parameter `cas.spring.cloud.zookeeper.uri=localhost:2181` in `bootstrap.properties`
- Add configurations on Zookeeper. Example: `cas.server.name: https://localhost:9327`
- Start CAS.

# Build

Download the codebase for CAS `5.0.4` first and add the project source code into the `core` directory.

Make the following changes:

- `settings.gradle` (Root project)
  - Add `include "core:cas-server-core-configuration-cloud-zookeeper"`
- `gradle.properties` (Root project)
    - Update version zookeeper : `zookeeperVersion=3.4.10`
    - Add `springCloudZookeeperVersion=1.0.4.RELEASE`
- `build.gradle` (into project `cas-server-core-configuration-cloud-zookeeper`)

```groovy
description = "Apereo CAS Core Configuration - Zookeeper"

dependencies {
  compile libraries.springboot
  compile libraries.spring
  compile libraries.springcloud
  compile libraries.zookeeper
}
```

Classes used in the ZooKeeper project:

```bash
/cas-server-core-configuration-cloud-zookeeper/src/main/java/org/apereo/cas/ZookeeperPropertySource.java
/cas-server-core-configuration-cloud-zookeeper/src/main/java/org/apereo/cas/ZookeeperPropertySourceLocator.java
/cas-server-core-configuration-cloud-zookeeper/src/main/java/org/apereo/cas/config/ZookeeperCloudConfigBootstrapConfiguration.java
```

Build the codebase with `gradlew clean build --parallel -x test -x javadoc -x check`.

# Overlay

Add this configuration in `pom.xml`:

```xml
<dependency>
    <groupId>org.apereo.cas</groupId>
    <artifactId>cas-server-core-configuration-cloud-zookeeper</artifactId>
    <version>${cas.version}</version>
</dependency>
```

# TODO

- When you add a new configuration to Zookeeper, reload the configuration property automatically in CAS.
