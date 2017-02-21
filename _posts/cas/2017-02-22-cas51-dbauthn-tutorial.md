---
layout:     post
title:      CAS 5 Database Authentication Tutorial
summary:    Learn how to configure database authentication in CAS 5
---

# Overview

This is a short and sweet tutorial on how to configure CAS to authenticate against a database and then resolve/release attributes.
Most of the material is based on the [available documentation](https://apereo.github.io/cas/development/installation/Database-Authentication.html).

This tutorial specifically focuses on:

- CAS `5.1.0-RC2-SNAPSHOT`
- HSQLDB `2.3.4`
- Java 8
- Apache Tomcat `8.5.11`

# Database

To keep things rather simple, we'll be installing an instance of [HSQLDB](http://hsqldb.org/). For this exercise, I am running `2.3.4`, though note that the recipe is for the most part the same when dealing with other database instances as well, whether installed manually or run in a dockerized fashion.

So running HSQL shows me:

```bash
[Server@2ff4acd0]: [Thread[main,5,main]]: checkRunning(false) entered
[Server@2ff4acd0]: [Thread[main,5,main]]: checkRunning(false) exited
[Server@2ff4acd0]: Startup sequence initiated from main() method
[Server@2ff4acd0]: Could not load properties from file
[Server@2ff4acd0]: Using cli/default properties only
[Server@2ff4acd0]: Initiating startup sequence...
[Server@2ff4acd0]: Server socket opened successfully in 46 ms.
[Server@2ff4acd0]: Database [index=0, id=0, db=file:mydb, alias=xdb] opened successfully in 349 ms.
[Server@2ff4acd0]: Startup sequence completed in 396 ms.
[Server@2ff4acd0]: 2017-02-21 13:44:37.717 HSQLDB server 2.3.4 is online on port 9001
[Server@2ff4acd0]: To close normally, connect and execute SHUTDOWN SQL
[Server@2ff4acd0]: From command line, use [Ctrl]+[C] to abort abruptly
```

Great. Moving on...

# Create Schema

In my setup, I have two tables: one called `USERS` where user accounts are kept and another called `USERATTRS` where user attributes are kept. My `USERS` table is rather simple, but the `USERATTRS` follows something of a *multi-row* setup. You want to learn more about this setup [here](https://apereo.github.io/cas/development/integration/Attribute-Resolution.html#person-directory).

So here goes the SQL:

```sql
DROP TABLE IF EXISTS USERS;
DROP TABLE IF EXISTS USERATTRS;

CREATE TABLE USERATTRS (
  id INT NOT NULL IDENTITY ,
  uid VARCHAR(50) NOT NULL,
  attrname VARCHAR(50) NOT NULL,
  attrvalue VARCHAR(50) NOT NULL
);


CREATE TABLE USERS (
  id INT NOT NULL IDENTITY ,
  uid VARCHAR(50) NOT NULL,
  psw VARCHAR(50) NOT NULL
);

INSERT INTO USERS (uid, psw)
VALUES ('mmoayyed', 'TheBestPasswordEver');

INSERT INTO USERATTRS (uid,  attrname, attrvalue)
VALUES ('mmoayyed', 'firstname', 'Misagh');

INSERT INTO USERATTRS (uid, attrname, attrvalue)
VALUES ('mmoayyed', 'lastname', 'Moayyed');

INSERT INTO USERATTRS (uid, attrname, attrvalue)
VALUES ('mmoayyed', 'phone', '+13476452319');
```

Note that for the time being, I am just keeping the password as plain-text in the table. No encoding or anything has taken place.

# Deploy CAS

Hop over to [the overlay installation](https://apereo.github.io/cas/development/installation/Maven-Overlay-Installation.html) and get CAS built and deployed. The CAS version I am using today is `5.1.0-RC2-SNAPSHOT`. It does not matter whether you end up using Maven or Gradle. Choose what fits you best. When you have a baseline functioning build, continue on.

# Configure CAS

Follow the steps [described here](https://apereo.github.io/cas/development/installation/Database-Authentication.html) to add the needed CAS modules. Once the module/dependency is added to your build, hop over to [the settings page](https://apereo.github.io/cas/development/installation/Configuration-Properties.html#database-authentication) and add the properties. 

*Note that I did not have to add any additional JARs and such for database drivers. CAS ships with a few [automatically and by default](https://apereo.github.io/cas/development/installation/JDBC-Drivers.html)*

For this tutorial, this is what I actually needed to make this work:

```properties
cas.authn.jdbc.query[0].sql=SELECT * FROM USERS WHERE uid=?
cas.authn.jdbc.query[0].url=jdbc:hsqldb:hsql://localhost:9001/xdb
cas.authn.jdbc.query[0].dialect=org.hibernate.dialect.HSQLDialect
cas.authn.jdbc.query[0].user=sa
cas.authn.jdbc.query[0].password=
cas.authn.jdbc.query[0].driverClass=org.hsqldb.jdbcDriver
cas.authn.jdbc.query[0].fieldPassword=psw
```

I also need to disable static authentication. It would also be very nice if I could turn on `DEBUG` logs and see what CAS attempts to do:

```properties
logging.level.org.apereo=DEBUG
cas.authn.accept.users=
```

# Build and Deploy

Once you get CAS built and deployed, logs should indicate something like this:

```bash
2017-02-21 14:20:18,267 DEBUG [org.apereo.cas.configuration.support.Beans] - <No password encoder shall be created given the requested encoder type [NONE]>
2017-02-21 14:20:18,277 DEBUG [org.apereo.cas.adaptors.jdbc.config.CasJdbcAuthenticationConfiguration] - <Created authentication handler [QueryDatabaseAuthenticationHandler] to handle database url at [jdbc:hsqldb:hsql://localhost:9001/xdb]>
```

Log in with `mmoayyed` and `TheBestPasswordEver` and you should be in. Viola!

# Password Encoding

As an extra bonus exercise, let's turn on `MD5` password encoding. The MD5 hash of `TheBestPasswordEver` is `ca541f57a3041c3b85c553d12d3e64a8`.

So we will update the database accordingly.

```sql
UPDATE USERS SET psw='ca541f57a3041c3b85c553d12d3e64a8' WHERE uid='mmoayyed';
```

Then configure CAS to handle `MD5` password encoding:

```properties
cas.authn.jdbc.query[0].passwordEncoder.type=DEFAULT
cas.authn.jdbc.query[0].passwordEncoder.encodingAlgorithm=MD5
cas.authn.jdbc.query[0].passwordEncoder.characterEncoding=UTF-8
```

# Build and Deploy

Once you get CAS built and deployed, logs should indicate something like this:

```bash
2017-02-21 14:44:31,884 DEBUG [org.apereo.cas.configuration.support.Beans] - <Creating default password encoder with encoding alg [MD5] and character encoding [UTF-8]>
```

Build and deploy. Log in with `mmoayyed` and `TheBestPasswordEver` and you should be in. Logs may indicate:

```bash
2017-02-21 14:45:55,517 DEBUG [org.apereo.cas.util.crypto.DefaultPasswordEncoder] - <Encoded password via algorithm [MD5] and character-encoding [UTF-8] is [ca541f57a3041c3b85c553d12d3e64a8]>
2017-02-21 14:45:55,517 DEBUG [org.apereo.cas.util.crypto.DefaultPasswordEncoder] - <Provided password does match the encoded password>
2017-02-21 14:45:55,519 DEBUG [org.apereo.cas.authentication.AbstractAuthenticationManager] - <Authentication handler [QueryDatabaseAuthenticationHandler] successfully authenticated [mmoayyed]>
```

Good job! Lets get some attributes now.

# Attributes

Because the `USERATTRS` follows something of a *multi-row* setup, we want to make sure CAS [can understand]((https://apereo.github.io/cas/development/integration/Attribute-Resolution.html#person-directory)) the specifics of this schema model. Today, CAS is unable to retrieve attributes as part of authentication directly so we need to set up a separate attribute repository instance that CAS will contact once the user is fully authenticated. In our case, the attribute repository is the same database instance. So the configuration may look something like this:

```properties
cas.authn.attributeRepository.jdbc[0].singleRow=false
cas.authn.attributeRepository.jdbc[0].sql=SELECT * FROM USERATTRS WHERE {0}
cas.authn.attributeRepository.jdbc[0].username=uid
cas.authn.attributeRepository.jdbc[0].url=jdbc:hsqldb:hsql://localhost:9001/xdb
cas.authn.attributeRepository.jdbc[0].columnMappings.attrname=attrvalue
```

Once CAS understands the schema, we should then specify which attributes really should be retrieved by CAS.

```properties
cas.authn.attributeRepository.attributes.firstname=firstname
cas.authn.attributeRepository.attributes.lastname=lastname
# cas.authn.attributeRepository.attributes.phone=phone
```

Note how I am skipping over `phone`.

The above says, *Retrieve attributes `firstname` and `lastname` from the repositories and keep them as they are*.
If we wanted to, we could virtually rename the attributes to for instance `TheFir$tN@me` and `simpleL@stnam3`.

# Release Attributes

There are multiple ways of [releasing attributes](https://apereo.github.io/cas/development/integration/Attribute-Release.html). For this tutorial, I am going to release them globally to all applications:

```properties
cas.authn.attributeRepository.defaultAttributesToRelease=firstname,lastname
```

Note how I am skipping over `phone`.

# Build and Deploy

For this to actually be tested, we need a client to which we can release attributes, right? You can use whatever client/application you like, as long as it's able to retrieve attributes. I ended up using [this](https://github.com/cas-projects/cas-sample-java-webapp). When attempting to access the application, I get redirected to CAS. Once I log in and return, I see the following in the CAS logs on startup:

```bash
2017-02-21 14:54:04,885 DEBUG [org.apereo.cas.config.CasPersonDirectoryConfiguration] - <Configured multi-row JDBC attribute repository for [jdbc:hsqldb:hsql://localhost:9001/xdb]>
2017-02-21 14:54:04,889 DEBUG [org.apereo.cas.config.CasPersonDirectoryConfiguration] - <Configured multi-row JDBC column mappings for [jdbc:hsqldb:hsql://localhost:9001/xdb] are [{attrname=attrvalue}]>
2017-02-21 14:54:04,890 DEBUG [org.apereo.cas.config.CasPersonDirectoryConfiguration] - <Configured result attribute mapping for [jdbc:hsqldb:hsql://localhost:9001/xdb] to be [{firstname=firstname, lastname=lastname}]>
```

Which shows that CAS has been able to understand the schema and map columns to attributes. Logging into the client application also shows me:

![image](https://cloud.githubusercontent.com/assets/1205228/23163353/5c39f42a-f847-11e6-806e-6d4e3ca88805.png)

# So...

I hope this brief tutorial was of some assistance to you. Remember that the point here is not to enumerate best practices and such. It's just to show the possibilities. It's important that you start off simple and make changes one step at a time. Once you have a functional environment, you can gradually and slowly add customizations to move files, tables and queries around.

[Misagh Moayyed](https://twitter.com/misagh84)