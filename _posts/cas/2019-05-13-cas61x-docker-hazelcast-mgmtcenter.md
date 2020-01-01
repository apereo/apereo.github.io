---
layout:     post
title:      Apereo CAS - Dockerized Hazelcast Deployments
summary:    Learn how to run CAS backed by a Hazelcast cluster in Docker containers and take advantage of the Hazelcast management center to monitor and observer cluster members.
tags:       [CAS]
---

<div class="alert alert-success">
<strong>Collaborate</strong><br/>This blog is managed and hosted on GitHub. If you wish to update the contents of this post or if you have found an inaccuracy and wish to make corrections, we recommend that you please submit a pull request to <a href="https://github.com/apereo/apereo.github.io">this repository</a>.
</div>

# Overview

For a highly-available CAS deployment, running CAS backed by the [Hazelcast Ticket Registry](https://apereo.github.io/cas/development/ticketing/Hazelcast-Ticket-Registry.html) can be a great option. In the simplest scenario, CAS server nodes are registered as Hazelcast cluster members via static discovery and that is fine for most deployments. Likewise, producing a CAS docker image and running it a container is fairly straight forward, what with the scaffolding and machinery put into the [CAS Overlay]() to produce images via the `jib` plugin or a native `Dockerfile`.

This blog post focuses on marrying up the two use cases; That is, getting CAS server nodes as Hazelcast cluster members to discover each other and form a cluster while running as Docker containers. We'll also be configuring CAS to connect to a Hazelcast Management Center deployment to observe cluster members and monitor configuration and activity.


Our starting position is based on:

- CAS `6.1.x`
- Java `11`
- [CAS WAR Overlay](https://github.com/apereo/cas-overlay-template)
- [Hazlcast Ticket Registry](https://apereo.github.io/cas/development/ticketing/Hazelcast-Ticket-Registry.html)

# CAS Hazelcast Ticket Registry

Running CAS with Hazelcast, in general and without Docker, is simply as simple as including [Hazlcast Ticket Registry](https://apereo.github.io/cas/development/ticketing/Hazelcast-Ticket-Registry.html) in the overlay with the following *starter* settings:

```properties
cas.ticket.registry.hazelcast.cluster.members=127.0.0.1
cas.ticket.registry.hazelcast.cluster.port=5701

cas.ticket.registry.hazelcast.management-center.enabled=true
cas.ticket.registry.hazelcast.management-center.url=http://localhost:8080/hazelcast-mancenter/
```

Once deployed, the CAS server node will auto-register itself as a Hazelcast member with the management center, which we have yet to stand up.

# Hazelcast Management Center

[Hazelcast Management Center](https://hazelcast.com/product-features/management-center/) enables monitoring and management of nodes running Hazelcast IMDG or Jet. This includes monitoring the overall state of clusters, as well as detailed analysis and browsing of data structures in real time, updating map configurations, and taking thread dumps from nodes.

Note that using the Hazelcast Management Center is **free for clusters of 2 members**.

The management center can be fetched and deployed via Docker itself:

```bash
docker run -p 8080:8080 hazelcast/management-center:latest
```

...after which, it will be available on `http://localhost:8080/hazelcast-mancenter`.

Once you create an admin account and sign in, you'd likely see the following:

![image](https://user-images.githubusercontent.com/1205228/57580179-2ac65e00-745b-11e9-8f0b-a6076f71d72d.png)


You can also drill down into the member details:

![image](https://user-images.githubusercontent.com/1205228/57580186-4df10d80-745b-11e9-9b97-e48fbeb5b3fa.png)

You can shut down any node or the management center itself and observe how the auto-registration process continues to resume.

# Dockerized CAS Deployment

Once the overlay is prepped with the Hazelcast Ticket Registry, a simple way to produce a docker image would be to use the `jib` plugin built into the overlay. Before we do, we'll need to make sure our configuration is Docker-ready:


```properties
cas.ticket.registry.hazelcast.cluster.instanceName=localhost
cas.ticket.registry.hazelcast.cluster.portAutoIncrement=false
cas.ticket.registry.hazelcast.cluster.members=${HZ_MEMBER_LIST}
cas.ticket.registry.hazelcast.cluster.port=${HZ_PORT}
cas.ticket.registry.hazelcast.cluster.public-address=${HZ_PUBLIC_IP}

cas.ticket.registry.hazelcast.management-center.enabled=true
cas.ticket.registry.hazelcast.management-center.url=http://host.docker.internal:8080/hazelcast-mancenter/
```

`public-address` overrides the public address of a member. By default, a member selects its socket address as its public address. In this case, the public addresses of the members are not an address of the container's local network but an address defined by the host. This setting is optional to set and useful when you have a private cloud. Note that, the value for this element should be given in the format of `IP address:port`.

Also, from Docker `18.03` onwards the recommendation is to connect to the special DNS name `host.docker.internal` which resolves to the internal IP address used by the host. This is for development purpose and will not work in a production environment
 outside of Docker Desktop for Mac. You will need to adjust the url if you're using a different OS.

Now, we should be ready to build the Docker image via `jib`:

```bash
./gradlew build jibDockerBuild
```

# Running CAS Docker Containers

Let's start a docker container as `cas2`:

```bash
docker run -e HZ_PORT=5701 -e HZ_PUBLIC_IP=192.168.1.100:40002 \
    -e HZ_MEMBER_LIST=192.168.1.100:40001,192.168.1.100:40002 -p 40002:5701 \
    -p 8443:8443 -d --name="cas2" org.apereo.cas/cas:latest \
    && docker logs -f cas2
```

...where the logs would eventually indicate:

```
2019-05-12 10:12:40,497 INFO [com.hazelcast.internal.cluster.ClusterService] - <[192.168.1.100]:40002 [dev] [3.12] 

Members {size:1, ver:1} [
    Member [192.168.1.100]:40002 - dbd50864-8b8a-4356-a597-303e0291de3d this
]
>
```

Let's start another, named `cas1`:

```bash
docker run -e HZ_PORT=5701 -e HZ_PUBLIC_IP=192.168.1.100:40001 \
    -e HZ_MEMBER_LIST=192.168.1.100:40001,192.168.1.100:40002 -p 40001:5701 \
    -p 8443:8443 -d --name="cas1" org.apereo.cas/cas:latest \
    && docker logs -f cas1
```

...where the logs would eventually indicate:

```
2019-05-12 10:13:32,149 INFO [com.hazelcast.internal.cluster.ClusterService] - <[192.168.1.100]:40001 [dev] [3.12] 

Members {size:2, ver:2} [
    Member [192.168.1.100]:40002 - dbd50864-8b8a-4356-a597-303e0291de3d
    Member [192.168.1.100]:40001 - 1af4e693-c9ea-4636-a00f-5087b8f26ec3 this
]
>
```

If you circle back and watch the logs for `cas2`, you'd also see:

```
2019-05-12 10:13:32,084 INFO [com.hazelcast.internal.cluster.ClusterService] - <[192.168.1.100]:40002 [dev] [3.12] 

Members {size:2, ver:2} [
    Member [192.168.1.100]:40002 - dbd50864-8b8a-4356-a597-303e0291de3d this
    Member [192.168.1.100]:40001 - 1af4e693-c9ea-4636-a00f-5087b8f26ec3
]
>
```

The management center should also confirm this:

![image](https://user-images.githubusercontent.com/1205228/57584777-12266a00-7494-11e9-8d7c-50d5babf09f4.png)


# So...

I hope this review was of some help to you and I am sure that both this post as well as the functionality it attempts to explain can be improved in any number of ways. Please know that all other use cases, scenarios, features, and theories certainly [are possible](https://apereo.github.io/2017/02/18/onthe-theoryof-possibility/) as well. Feel free to [engage and contribute](https://apereo.github.io/cas/developer/Contributor-Guidelines.html) as best as you can.

Happy Coding,

[Misagh Moayyed](https://fawnoos.com)
