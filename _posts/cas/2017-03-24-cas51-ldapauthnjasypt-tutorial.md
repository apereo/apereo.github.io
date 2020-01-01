---
layout:     post
title:      CAS 5 LDAP AuthN and Jasypt Configuration
summary:    Learn how to configure LDAP AuthN with CAS and secure LDAP credentials via Jasypt.
tags:       [CAS]
---

This is a short and sweet tutorial on how to configure CAS for LDAP authentication and secure bind credentials via Jasypt encryption.
Most of the material is based on the available documentation [here](https://apereo.github.io/cas/development/installation/Configuration-Properties-Security.html) and [here](https://apereo.github.io/cas/development/installation/LDAP-Authentication.html).

This tutorial specifically focuses on:

- CAS `5.1.0-RC3-SNAPSHOT`
- Java 8
- Docker 1.13.x
- Apache Tomcat `8.5.x`
- [Jasypt CLI](http://www.jasypt.org/cli.html). You can download the distribution [from here](http://www.jasypt.org/download.html).

This tutorial assumes that you are running CAS in its `standalone` mode, [described here](https://apereo.github.io/cas/development/installation/Configuration-Server-Management.html).

# LDAP Setup

For this tutorial, I am using a 398-ds LDAP server [from this docker image](https://github.com/jtgasper3/docker-images/tree/master/389-ds).
Once you have the image running, you can connect to the underlying LDAP server at `localhost:10389` with `cn=Directory Manager` and `password`. The LDAP server is also prepped with a `users.ldif` file that contains the test account `jsmith:password`.

```bash
docker ps

CONTAINER ID        IMAGE                   COMMAND                  CREATED             STATUS              PORTS                    NAMES
0f2a75441fb5        jtgasper3/389ds-basic   "/bin/sh -c '/usr/..."   11 days ago         Up 6 minutes        0.0.0.0:10389->389/tcp   ldap-server
```

Sweet! Moving on...

# Deploy CAS

Hop over to [the overlay installation](https://apereo.github.io/cas/development/installation/Maven-Overlay-Installation.html) and get CAS built and deployed. The CAS version I am using today is `5.1.0-RC3-SNAPSHOT`. It does not matter whether you end up using Maven or Gradle. Choose what fits you best. When you have a baseline functioning build, continue on.

# Configure CAS

Once you have added the LDAP module to your build as is described [here](https://apereo.github.io/cas/development/installation/LDAP-Authentication.html), you then need to teach CAS about the running LDAP server.

Here is what I did in the `cas.properties` file, along with all the other usual suspects:

```properties
cas.authn.ldap[0].type=AUTHENTICATED
cas.authn.ldap[0].ldapUrl=ldap://localhost:10389
cas.authn.ldap[0].useSsl=false
cas.authn.ldap[0].baseDn=ou=People,dc=example,dc=edu
cas.authn.ldap[0].userFilter=uid={user}
cas.authn.ldap[0].bindDn=cn=Directory Manager
cas.authn.ldap[0].bindCredential=password
```

I also need to disable static authentication. It would also be very nice if I could turn on `DEBUG` logs and see what CAS attempts to do:

```properties
logging.level.org.apereo=DEBUG
cas.authn.accept.users=
```

# Build and Deploy

Once you get CAS built and deployed, logs should indicate something like this:

```bash
2017-03-22 16:01:06,915 INFO [o.a.c.c.LdapAuthenticationConfiguration] - <Ldap authentication for [LdapAuthenticationHandler] is to chain principal resolvers via [[org.apereo.cas.authentication.principal.resolvers.ChainingPrincipalResolver@1452f4cb[chain=[org.apereo.cas.authentication.principal.resolvers.PersonDirectoryPrincipalResolver@1b7c5e6a[returnNullIfNoAttributes=false,principalAttributeName=<null>], org.apereo.cas.authentication.principal.resolvers.EchoingPrincipalResolver@6824495c[]]]]] for attribute resolution>
```

Great. Next, pull up CAS in your browser and log in with `jsmith` and `password` and you should be in. Viola!

# Jasypt Encryption

You may have noted that the LDAP `bindCredential` is put into the `cas.properties` file in plain-text. As the next steps:

- We will first encrypt the `bindCredential` value via Jasypt and put it into CAS.
- We will instruct CAS to decrypt the setting at runtime invisibly and resume as usual.

Note that there is nothing stopping you from encrypting any other setting!

## Encrypt via Jasypt

Once you download the [Jasypt CLI](http://www.jasypt.org/cli.html), at a minimum you need to decide which algorithm you want to use for encryption and what your encryption key/password should be which is the thing that is later taught to CAS to decode the value. In the `bin` directory of the distribution, you can invoke `./listAlgorithms.sh|bat` to see what may be possible for algorithms and then use the `./encrypt.sh|bat` to encrypt values.

So for me to encrypt the value of `bindCredential`, I ran the following command:

```bash
./encrypt.sh input=password algorithm=PBEWithMD5AndTripleDES password=MySuperPassword

----ENVIRONMENT-----------------
Runtime: Oracle Corporation Java HotSpot(TM) 64-Bit Server VM 25.121-b13 

----ARGUMENTS-------------------
algorithm: PBEWithMD5AndTripleDES
input: password
password: MySuperPassword

----OUTPUT----------------------
mqWuN+/U7oofNhdSVNcEgmVcwGmxiOaS
```

I can also confirm that this value can be decoded as well:

```bash
./decrypt.sh input=mqWuN+/U7oofNhdSVNcEgmVcwGmxiOaS algorithm=PBEWithMD5AndTripleDES password=MySuperPassword

----ENVIRONMENT-----------------
Runtime: Oracle Corporation Java HotSpot(TM) 64-Bit Server VM 25.121-b13 

----ARGUMENTS-------------------
algorithm: PBEWithMD5AndTripleDES
input: mqWuN+/U7oofNhdSVNcEgmVcwGmxiOaS
password: MySuperPassword

----OUTPUT----------------------
password
```

Cool. Let's move on.

## Configure CAS

So now that I have encrypted value in the `OUTPUT` section, I am going to slightly massage my configuration as such:

```properties
...
cas.authn.ldap[0].bindCredential={cipher}mqWuN+/U7oofNhdSVNcEgmVcwGmxiOaS
...
```

Finally, we need to teach CAS to handle the reverse of this operation. Consulting the docs [here](https://apereo.github.io/cas/development/installation/Configuration-Properties-Security.html), I ended up adjusting my configuration as such:

```properties
cas.standalone.config.security.alg=PBEWithMD5AndTripleDES
```

Using the embedded tomcat container, I configured my "run CAS" command to pass along the encryption key as a command-line parameter. If you prefer, you could do the same thing with environment variables and system properties.

```bash
java -jar target/cas.war --cas.standalone.config.security.psw=MySuperPassword
```

Next time when attempt to deploy and run CAS, you should be able to bind and connect to LDAP and authenticate as before.

That's it!

[Misagh Moayyed](https://fawnoos.com)
