---
layout:     post
title:      Apereo CAS - Ticket Distribution with JMS
summary:    Learn to configure Apereo CAS to JMS and messages queues to broadcast tickets and tokens across a deployment cluster.
tags:       [CAS]
---

<div class="alert alert-success">
<strong>Collaborate</strong><br/>This blog is managed and hosted on GitHub. If you wish to update the contents of this post or if you have found an inaccuracy and wish to make corrections, we recommend that you please submit a pull request to <a href="https://github.com/apereo/apereo.github.io">this repository</a>.
</div>

# Overview

CAS can be enabled with a variety of messaging systems to distribute and share ticket data: from simplified use of the JMS API to a complete infrastructure to receive messages asynchronously. This is the capability where CAS uses a specialized form of the default in-memory ticket registry with the main difference that ticket operations applied to the registry are broadcasted using a messaging queue to other listening CAS nodes on the queue. Each node keeps copies of ticket state on its own and only instructs others to keep their copy accurate by broadcasting messages and data associated with each. Each message and ticket registry instance running inside a CAS node in the cluster is tagged with a unique identifier to avoid endless looping behavior and recursive needless inbound operations.

In this tutorial, we are going to briefly review the JMS configuration in Apereo CAS and steps required to use message queues to [distribute tickets and tokens](https://apereo.github.io/cas/development/ticketing/Messaging-JMS-Ticket-Registry.html) across a cluster. Our starting position is based on:

- CAS `6.1.x`
- Java `11`
- [CAS WAR Overlay](https://github.com/apereo/cas-overlay-template)
- Docker

# Configuration

## ActiveMQ

We are going to be using ActiveMQ as our message broker whose job is to act as a hub and distribute tickets to subscribers. The quickest way to bring up ActiveMQ would be using the following command:

```bash
docker run -d --name activemq-server -p 61616:61616 -p 8161:8161 rmohr/activemq
```

That should be all, for now.

## CAS

Once you have prepped your CAS overlay with the correct [auto-configuration module](https://apereo.github.io/cas/development/ticketing/Messaging-JMS-Ticket-Registry.html), you will need to instruct CAS to try and connect to ActiveMQ for which you will need, at a minimum, the following settings:

```properties
spring.activemq.broker-url=tcp://localhost:61616
spring.activemq.user=admin
spring.activemq.password=admin
```

## Test

Let's bring up a CAS server node on port `8444`:

```bash
java -jar build/libs/cas.war --server.port=8444
```

...and then, let's bring up another on port `8445`:

```bash
java -jar build/libs/cas.war --server.port=8445
```

In the CAS logs, you should be able to notice the following statements:

```bash
<Established shared JMS Connection: ActiveMQConnection {id=ID:misaghmoayyed.local-65269-1569759674508-1:1,clientId=null,started=false}>
....
<Configuring JMS ticket registry with identifier [JmsTicketRegistryQueueIdentifier(id=d6b0927b-5c08-4c97-b0aa-02d5d8e709f5)]>
```

At this point, you should be able to access `https://localhost:8445/cas/login` and attempt to login. Once you have successfully authenticated, you should observe the distribution of tickets in the CAS logs from one node to the other.

# So...

I hope this review was of some help to you and I am sure that both this post as well as the functionality it attempts to explain can be improved in any number of ways. Please know that all other use cases, scenarios, features, and theories certainly [are possible](https://apereo.github.io/2017/02/18/onthe-theoryof-possibility/) as well. Feel free to [engage and contribute](https://apereo.github.io/cas/developer/Contributor-Guidelines.html) as best as you can.

Happy Coding,

[Misagh Moayyed](https://fawnoos.com)
