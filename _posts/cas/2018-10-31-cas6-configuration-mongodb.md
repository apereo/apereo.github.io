---
layout:     post
title:      Apereo CAS - Configuration Management with MongoDb
summary:    CAS distributed configuration management using MongoDb, where you learn how to store and secure CAS configuration settings and properties inside MongoDb.
tags:       [CAS]
---

<div class="alert alert-success">
  <strong>Collaborate</strong><br/>The blog is managed and hosted on GitHub. If you wish to update the contents of this post or if you have found an inaccuracy and wish to make corrections, we recommend that you please submit a pull request to <a href="https://github.com/apereo/apereo.github.io">this repository</a>.
</div>

[MongoDB](https://www.mongodb.com) is a free and open-source cross-platform document-oriented database program. Classified as a NoSQL database program, MongoDB uses JSON-like documents with schemata. MongoDB is developed by MongoDB Inc., and is published under a combination of the Server Side Public License and the Apache License.

MongoDB is supported in CAS in many different ways. In this walkthrough, we are going to take a pass at getting [CAS connected to MongoDB](https://apereo.github.io/cas/development/configuration/Configuration-Server-Management.html#mongodb) to store properties and settings. We will also try to reload settings dynamically in real-time as they are changed and updated inside MongoDB databases.

Our starting position is based on the following:

- CAS `6.0.0-RC4`
- Java 11
- [CAS Overlay](https://github.com/apereo/cas-overlay-template) (The `master` branch specifically)
- [Docker](https://www.docker.com/get-started)
- [CLI JSON Processor `jq`](https://stedolan.github.io/jq/)

## MongoDB

To run MongoDB for development and testing, we can use the provided Docker image:

```bash
docker run -d -p 27017:27017 -e MONGO_INITDB_ROOT_USERNAME=root \
  -e MONGO_INITDB_ROOT_PASSWORD=secret --name="mongodb-server" mongo:4.0-xenial
docker ps
```

This runs a MongoDB database server which is useful for development but **SHOULD NOT** be used in production.

To access the MongoDB instance using a UI, run:

```bash
docker run --link mongodb-server -d -p 8081:8081 \
  -e 'ME_CONFIG_MONGODB_ADMINUSERNAME=root' \
  -e 'ME_CONFIG_MONGODB_ADMINPASSWORD=secret' \
  -e 'ME_CONFIG_MONGODB_SERVER=mongodb-server' mongo-express
```

The `ME_CONFIG_MONGODB_SERVER` is the address of the docker container that runs the MongoDB server. By default, Docker containers use the container as the DNS host name. So we can just specify the `mongodb-server` the name of the container that runs our MongoDB instance. 


Shell into the container:

```bash
CID=docker ps -aqf name=mongodb-server
docker exec -it $CID /bin/bash
```

When inside the container:

```bash
mongo --host mongodb://root:secret@localhost:27017
use database cas;

# Create a database user for authentication
db.createUser({user:"casuser", pwd:"Mellon", roles: ["readWrite", "dbAdmin"]})
```

When ready, point your browser to `http://localhost:8081` and let's create a few documents with CAS settings in them. MongoDb documents are required to be found in the collection `MongoDbProperty`, as the following document:

```json
{
    "id": "...",
    "name": "the-setting-name",
    "value": "the-setting-value"
}
```

So I am going to create a MongoDB database called `cas` inside which the `MongoDbProperty` needs to be created. Next, each of the below settings will be housed inside an indibidual MongoDB document that matches the above JSON structure:

```properties
cas.authn.accept.users=casuser::MongoDB
management.endpoints.web.exposure.include=*
management.endpoints.enabled-by-default=true
cas.monitor.endpoints.endpoint.defaults.access=AUTHENTICATED
spring.security.user.name=casuser
spring.security.user.password=Mellon
```

The end result will look something like this:

![image](https://user-images.githubusercontent.com/1205228/47649468-9e291200-db92-11e8-8cac-c993411c697b.png)

<div class="alert alert-warning">
  <strong>WATCH OUT!</strong><br/>The above collection of settings <strong>MUST</strong> only be used for demo purposes and serve as an <strong>EXAMPLE</strong>. It is not wise to enable and expose all actuator endpoints to the web and certainly, the security of the exposed endpoints should be taken into account very seriously. None of the CAS or Spring Boot actuator endpoints are enabled by default. For production, you should carefully choose which endpoints to expose.
</div>

You may also want to create an index on `name`:

![image](https://user-images.githubusercontent.com/1205228/47649572-f3652380-db92-11e8-9762-aaef042c7c58.png)

That should do for now. Let's get CAS running.

## CAS

Integration with MongoDB in CAS to manage configuration can be done in a number of ways:

- If you have the [Spring Cloud Config Server](https://apereo.github.io/2018/10/25/cas6-cloud-config-server/) deployed, MongoDB could be one of its many sources for settings and properties. In this scenario, you will just need to make sure the CAS server can talk to the Spring Cloud Config Server correctly, and the Config Server is then in charge of communicating with MongoDB to fetch settings, etc.

- Alternatively, you may decide to connect your CAS server directly to MongoDB and fetch settings. This is the approach we are going to try in this tutorial for a quick win, but do note that the strategy is almost the same if we were to use the Cloud Config server.

So in order to enable a CAS integration with MongoDB *directly*, you want to start with the [CAS Overlay](https://github.com/apereo/cas-overlay-template), clone the project and then put the following settings into a `src/main/resources/bootstrap.properties` file:

```properties
spring.application.name=cas
spring.profiles.active=mongodb
cas.spring.cloud.mongo.uri=mongodb://casuser:Mellon@localhost:27017/cas
```

Of course, don't forget to include the required module in your CAS build:

```gradle
compile "org.apereo.cas:cas-server-support-configuration-cloud-mongo:${project.'cas.version'}"
```

Build and deploy. At this point, you should be able to log into CAS using `casuser` and `MongoDB` as the credentials!

### Refresh & Reload

If a setting changes, MongoDB has no way to broadcast the updated value(s) to its own clients, such as the CAS server itself. Therefore, in order to broadcast such change events, CAS presents various endpoints that allow the user to [refresh the configuration](https://apereo.github.io/cas/development/configuration/Configuration-Management-Reload.html) as needed. This means that an adopter would simply change a required CAS setting and then would submit a request to CAS to *refresh* its current state. At runtime! All CAS internal components that are affected by the external change are quietly reloaded and the setting takes immediate effect, completely removing the need for container restarts or CAS re-deployments.

For example, start by changing the value of `cas.authn.accept.users` in MongoDB to something like `casuser::HelloWorld`. Then, execute the following command to refresh the CAS application context:

```bash
curl -k -u casuser:Mellon https://sso.example.org/cas/actuator/refresh -d {} -H "Content-Type: application/json"

...
["cas.authn.accept.users"]
```

At this point, you should be able to log into CAS using `casuser` and `HelloWorld` as the credentials!

## Finale

I hope this review was of some help to you and I am sure that both this post as well as the functionality it attempts to explain can be improved in any number of ways. Please feel free to [engage and contribute](https://apereo.github.io/cas/developer/Contributor-Guidelines.html) as best as you can.

[Misagh Moayyed](https://fawnoos.com)
