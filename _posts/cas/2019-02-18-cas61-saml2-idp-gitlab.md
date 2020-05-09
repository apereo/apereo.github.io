---
layout:     post
title:      Apereo CAS - SAML2 Identity Provider Integration w/ Gitlab (also starting HAProxy and LDAP)
summary:    Learn how Apereo CAS may act as a SAML2 identity provider for Gitlab and run everything locally on a workstation with Docker and Java.
tags:       [CAS,SAML,Gitlab,HAProxy,LDAP]
---

<div class="alert alert-success">
  <strong>Collaborate</strong><br/>The blog is managed and hosted on GitHub. If you wish to update the contents of this post or if you have found an inaccuracy and wish to make corrections, we recommend that you please submit a pull request to <a href="https://github.com/apereo/apereo.github.io">this repository</a>.
</div>

## CAS
Apereo CAS can authenticate users in many ways, including by delegating to other authentication providers, and it can get attributes about those users from many places, and finally it can communicate that identity along with those attributes to applications (aka services) via various protocols such as the CAS Protocol, SAML, and OpenID Connect.

## Exercise Outline
In this exercise, we configure CAS to authenticate users via username/password against LDAP, we retrieve attributes from LDAP and we then we communicate the identity and attributes to Gitlab via the SAML2 protocol. While not required, we run both CAS and Gitlab behind HAProxy and we run LDAP, Gitlab, and HAProxy in Docker containers. 

Everything should be able to run on a workstation (Windows/Mac/Linux) if you have >8GB of memory with 4GB available to Docker but it has only been tested on a Windows computer with an Intel I7-860 (from circa 2009) with 16GB and an SSD drive. There are some scripts for use on Mac and Linux that haven't been tested on either OS. 

The starting position is based on the following:
- CAS `6.1.0-RC1`
- [Java 11](https://adoptopenjdk.net/?variant=openjdk11&jvmVariant=hotspot)
- Docker (Available for Linux, [Windows](https://download.docker.com/win/stable/Docker%20for%20Windows%20Installer.exe), or [Mac](https://download.docker.com/mac/stable/Docker.dmg)) - On Windows and Mac, make sure you adjust Docker settings to share your host hard drive with docker and increase the memory available to Docker to 3 or 4 GB. 
- [CAS WAR Overlay](https://github.com/apereo/cas-overlay-template) - `git clone https://github.com/apereo/cas-overlay-template.git`
- Gitlab Community Edition - [Docker Image](https://hub.docker.com/r/gitlab/gitlab-ce) (No need to download, scripts provided)
- openssl 1.1.1+ (for creating certificates, on Windows it comes with [Git Bash](https://git-scm.com/downloads))
- [Forked CAS War Overlay](https://github.com/hdeadman/cas-overlay-template/tree/gitlab-demo) - `gitlab-demo` branch contains extra material for this demo
- Host File Entry - Cookies and SSL certificate checks work better when using a domain name rather than an IP address or localhost so please make the following entry in your hosts file: (c:\windows\system32\drivers\etc\hosts on Windows, /etc/hosts otherwise)
```
192.168.1.123 example.org
```
where `192.168.1.123` is replaced with the main IP address of your workstation. 

## Initial CAS Setup

After cloning the [CAS Overlay Template](https://github.com/apereo/cas-overlay-template), we need to add modules for SAML2, LDAP and a service registry. A service in the CAS context is an application that authenticates against CAS and it allows for service specific configurations (such as what protocol that service uses and what attributes to release). CAS supports several back-ends for storing the service definitions but in this exercise we will use the JSON service registry which is just a folder containing JSON formatted service definitions. 

#### Adding CAS Modules

Adding modules to our CAS installation involves adding the following to the dependencies section in the build.gradle file:

```gradle
    // https://apereo.github.io/cas/development/installation/Configuring-SAML2-Authentication.html
    compile "org.apereo.cas:cas-server-support-saml-idp:${casServerVersion}"
    
    // https://apereo.github.io/cas/development/installation/LDAP-Authentication.html
    compile "org.apereo.cas:cas-server-support-ldap:${casServerVersion}"
    
    // https://apereo.github.io/cas/development/services/JSON-Service-Management.html#json-service-registry
    compile "org.apereo.cas:cas-server-support-json-service-registry:${casServerVersion}"
	
    // https://apereo.github.io/cas/development/integration/Configuring-SAML-SP-Integrations.html#saml-sp-integrations
    compile "org.apereo.cas:cas-server-support-saml-sp-integrations:${casServerVersion}"
```

Optional: rather than be on the bleeding edge of the 6.1.x development, change the cas version to the a recent release rather than the current snapshot.

Modify the `cas.version` property in the `gradle.properties` file to:

```properties
cas.version=6.1.0-RC1
```

#### Starting Up CAS

After you have added the module dependencies, make sure you have [Java 11](https://adoptopenjdk.net/?variant=openjdk11&jvmVariant=hotspot) in your path and run: 

```
gradlew run
```

CAS fails to start up because we don't have any configuration set and some directories and files referenced by the default configuration don't exist yet. CAS can read configurations from many sources supported by [Spring Cloud Config](https://spring.io/projects/spring-cloud-config) but in this exercise we use the [Standalone](https://apereo.github.io/cas/development/configuration/Configuration-Server-Management.html#standalone) configuration method which consists of property files (or yaml files) in /etc/cas/config outside of the overlay project. In order to copy the configuration to that location, run the following task:

```
gradlew copyCasConfiguration
```

When you started CAS it should have failed because it couldn't find the default folder where it reads its SAML Identity Provider (IDP) metadata. CAS, as usual, supports [several options](https://apereo.github.io/cas/development/installation/Configuring-SAML2-DynamicMetadata.html) for storing SAML metadata but the default is to read it from `/etc/cas/saml`. Since there is no gradle task to create that folder for you, just create it and CAS should generate metadata in that location the next time you start up CAS.

```dosbatch
mkdir c:\etc\cas\saml
```
```bash
mkdir /etc/cas/saml
```

CAS also looks for an SSL certificate for the default built-in Tomcat server. In this case there is a gradle task to generate a key store:

```
gradlew createKeyStore
gradlew copyCasConfiguration
```

Before running CAS again, the following properties are important to set in cas.properties before CAS generates the SAML IDP metadata:

```properties
# Tell CAS what it's name is
cas-host=example.org
cas.server.name=https://${cas-host}
cas.server.prefix=https://${cas-host}/cas
```

Now if you do `gradlew copyCasConfiguration` and `gradlew run`, CAS should start up and generate metadata for the SAML IDP.  The metadata contains URLs based on the `cas.server.prefix` property. 

Before doing further CAS configuration we need to create a source of users and attributes and we need to suppress the big STOP warning by turning off the "[accept users](https://apereo.github.io/cas/development/configuration/Configuration-Properties.html#accept-users-authentication)" authentication provider. 

#### Setting up LDAP
While most of this exercise relies on the default [cas-overlay-template](https://github.com/apereo/cas-overlay-template), the docker containers and the scripts to run them are located in the [github.com/hdeadman/cas-overlay-template](https://github.com/hdeadman/cas-overlay-template) fork on a [gitlab-demo](https://github.com/hdeadman/cas-overlay-template/tree/gitlab-demo) branch in a [docker](https://github.com/hdeadman/cas-overlay-template/tree/gitlab-demo/docker) folder. 

Look at the [README.md](https://github.com/hdeadman/cas-overlay-template/blob/gitlab-demo/docker/ldap/README.md) for instructions on building and running the ldap container. It is essentially running `build.[sh|bat]` and `run.[sh|bat]` from the `docker/ldap` folder.

To configure CAS to use the local LDAP server, add the following properties to etc\config\cas.properties in the CAS overlay. 

```properties
# don't allow login of built-in users
cas.authn.accept.users=

# set some properties we can re-use in authn and attributeRepository configuration
ldap-url=ldap://localhost:10389
ldap-binddn=cn=Directory Manager
ldap-bindpw=password
ldap-auth-type=DIRECT
ldap-basedn=ou=People,DC=example,DC=edu
ldap-dnformat=uid=%s,ou=people,DC=example,DC=edu
ldap-user-filter=(uid={user})
ldap-max-pool-size=20

# configure ldap authentication
cas.authn.ldap[0].base-dn=${ldap-basedn}
cas.authn.ldap[0].bind-credential=${ldap-bindpw}
cas.authn.ldap[0].bind-dn=${ldap-binddn}
cas.authn.ldap[0].dn-format=${ldap-dnformat}
cas.authn.ldap[0].ldap-url=${ldap-url}
cas.authn.ldap[0].max-pool-size=${ldap-max-pool-size}
cas.authn.ldap[0].min-pool-size=0
cas.authn.ldap[0].subtree-search=true
cas.authn.ldap[0].type=${ldap-auth-type}
cas.authn.ldap[0].searchFilter=${ldap-user-filter}
cas.authn.ldap[0].use-ssl=false
cas.authn.ldap[0].use-start-tls=false

# configure ldap attribute repository
cas.authn.attributeRepository.ldap[0].ldap-url=${ldap-url}
cas.authn.attributeRepository.ldap[0].order=0
cas.authn.attributeRepository.ldap[0].useSsl=false
cas.authn.attributeRepository.ldap[0].useStartTls=false
cas.authn.attributeRepository.ldap[0].baseDn=${ldap-basedn}
cas.authn.attributeRepository.ldap[0].searchFilter=${ldap-user-filter}
cas.authn.attributeRepository.ldap[0].subtreeSearch=true
cas.authn.attributeRepository.ldap[0].bindDn=${ldap-binddn}
cas.authn.attributeRepository.ldap[0].bindCredential=${ldap-bindpw}
cas.authn.attributeRepository.ldap[0].minPoolSize=0
cas.authn.attributeRepository.ldap[0].maxPoolSize=${ldap-max-pool-size}
cas.authn.attributeRepository.ldap[0].validateOnCheckout=true

# configure validator for attribute repository
cas.authn.attributeRepository.ldap[0].validator.type=SEARCH
cas.authn.attributeRepository.ldap[0].validator.baseDn=${ldap-basedn}
cas.authn.attributeRepository.ldap[0].validator.searchFilter=(objectClass=*)
cas.authn.attributeRepository.ldap[0].validator.scope=OBJECT
cas.authn.attributeRepository.ldap[0].validator.attributeName=objectClass
cas.authn.attributeRepository.ldap[0].validator.attributeValues=top

# Map ldap attributes to names Gitlab wants
# Gitlab also allows for mapping attributes on its side
cas.authn.attributeRepository.ldap[0].attributes.mail=email
cas.authn.attributeRepository.ldap[0].attributes.givenName=first_name
cas.authn.attributeRepository.ldap[0].attributes.sn=last_name
cas.authn.attributeRepository.ldap[0].attributes.uid=name

```

At this point, with the LDAP container running you should be able to `gradlew copyCasConfiguration` and `gradlew run` and then browse to https://localhost:8443/cas/login and login via LDAP authentication as `casuser`/`password`. 


#### Clearing up warning messages
There are still several warning messages on CAS startup and in order to get rid of those we can add some secrets to `cas.properties` that CAS will use for signing and encrypting various things:

```properties
# CAS encryption and signing keys
cas.tgc.crypto.encryption.key=zTYaxglyeSbSZASejncaSW6T8MfdB9Vt7w3g-XbAI0M
cas.webflow.crypto.signing.key=4AlA6_fVQ-Dl4qQbVFBu3FkQnyvXB9pHNiGSIQHynf9Wffe3-bfJgDRvdGjniQVk6YqIIZ9oN-ysFv_-Dhom3g
cas.webflow.crypto.encryption.key=dq-Fv33AMUSM7bKVrbcxboKxx7qJaq_M1pmJAiNmztuSaLLY-Tq2DOvtO8dQ-m213T3I2b1lz5QnX_QzHsnd8w
cas.webflow.crypto.encryption.key=QRPKUXy8zCdk6CB94JOlkA
cas.tgc.crypto.signing.key=aAyzadftnelaY_Af6fR1kaf-314aYklTqH-cLuZymWvsZneimPEw3AsdJbSaTN3jUIygcAiS3laFeb6CuTSfQA

```

Generating values for these secrets later can be done with the CAS Shell. To run the CAS shell from the overlay, run the following (adjusted for the version of CAS in `gradle.properties`):
```dosbatch
gradlew downloadShell
java -jar build\libs\cas-server-support-shell-6.1.0-RC1.jar
```


#### Configure JSON Service Registry
In order to resolve a warning about using the default in memory service registry, create a directory based JSON registry:

```dosbatch
mkdir \etc\cas\services
```
```bash
mkdir /etc/cas/services
```
And add a property to `cas.properties` that references the location:
```properties
# Configure CAS JSON service registry
cas.service-registry.json.location=file:/etc/cas/services
```

## Gitlab Container Setup

When running Gitlab as a container, one typically volume maps in three folders from the host (or via Docker Volumes): 
- data - contains sub-directories for git repository data, postgresql data, etc)
- config - contains the main configuration file `gitlab.rb` along with ssh host keys, nginx ssl certificates, and other secrets that need to survive container image upgrades intact
- logs - if you want logs to survive removing the container then map in the logs folder

Gitlab can be started by running the scripts in the CAS overlay [github.com/hdeadman/cas-overlay-template](https://github.com/hdeadman/cas-overlay-template) fork on a [gitlab-demo](https://github.com/hdeadman/cas-overlay-template/tree/gitlab-demo) branch in a [docker/gitlab](https://github.com/hdeadman/cas-overlay-template/tree/gitlab-demo/docker/gitlab) folder. 


**Please review scripts before you run. The `run.[bat|sh]` scripts create a base folder on your computer (`c:\gitlab-demo` or `/opt/gitlab-demo`) so adjust that if you want the folder somewhere else. (They also download gitlab image and remove and start up "gitlab" container, listen on a host port, etc)**

The `gitlab.rb` configuration is pre-populated with the configuration for this exercise, but you need to modify it with the fingerprint for the CAS SAML IDP signing key that was generated when CAS was started. The fingerprint can be generated by openssl using the `fingerprint_idp.sh` script. 

### Gitlab External URL Config
Note that the `external_url 'https://example.org'` configuration setting in `gitlab.rb` is packed with non-obvious configuration magic. If you added a port, Nginx in the gitlab container would listen on that port. If you added a context (e.g. `https://example.org/gitlab`) then Gitlab would be deployed under that context. If you changed the protocol to http then Nginx would listen on port 80 and not use SSL configuration. The URL should match the URL that users are going to use taking into account the reverse proxy that will be in front of Gitlab. Even though Gitlab is listening on port 443 inside the container, from the host we use the host port specified in the docker run command (e.g. `https://localhost:8444/`). 

### Gitlab LDAP Config
The `gitlab.rb` file contains LDAP configuration which isn't strictly necessary to authenticate via CAS SAML but since we are using the LDAP server with CAS, it is easy to point at it from the gitlab container. The LDAP host is configured as `host.docker.internal` which should allow the gitlab container to talk to the ldap container if using Docker for Windows/Mac. If you are running Docker on Linux you will need to set that to the host IP or a DNS name that resolves to the host where LDAP is running. 

### Gitlab SAML Config
Make sure you have started CAS per the instructions above and that you have SAML metadata (generated by CAS) in the /etc/cas/saml folder. Run the `fingerprint_idp.sh` script (found in gitlab folder) and replace the fingerprint in `gitlab.rb` on the line that looks like:
```properties
"idp_cert_fingerprint" => '71:ED:B7:CC:92:1E:B6:D7:80:33:6D:E3:D8:0B:E1:81:34:D7:58:2D',
```
Gitlab needs that fingerprint in order to verify that the SAML response it receives was signed with the correct identity provider. The SAML protocol requires signed responses because the SAML responses may travel through the browser where they could be manipulated were they not signed. 

### Gitlab Login
The Gitlab you are running should prompt you to set a password the first time you browse to it (`https://localhost:8444/`). The admin username is `root` and the password is whatever you choose. After you set a root password, on the Login page you should have tabs for LDAP and Standard. If the LDAP container is running you should be able to login as `casuser/password` on the LDAP tab and `root` on the Standard tab. 

### Gitlab - Starting Over
If you ever feel the need to start over with your local gitlab (e.g. you forgot your root password), do a `docker stop gitlab` and `docker rm gitlab` to remove the container and then clean up the mapped in data folders or docker volumes. The windows script uses a docker volume that you can delete with `docker volume rm gitlab-data`.


## HAProxy Container Setup

Why HAProxy? It's more realistic that applications will be behind a reverse proxy and in this exercise it allows everything to be accessible behind the standard HTTPS port (even though CAS and Gitlab are listening on different ports). Could this be done without HAProxy? Yes, but having a proxy better simulates a real deployment. It also means that when dealing with SSL trust, we only have to worry about the certificate on HAProxy and not the ones used by CAS and Gitlab. 

HAProxy can be started as a container by running the scripts in the CAS overlay [github.com/hdeadman/cas-overlay-template](https://github.com/hdeadman/cas-overlay-template) fork on a [gitlab-demo](https://github.com/hdeadman/cas-overlay-template/tree/gitlab-demo) branch in a [docker/haproxy](https://github.com/hdeadman/cas-overlay-template/tree/gitlab-demo/docker/haproxy) folder. 

The `haproxy` container is configured to listen on port 443 using a certificate that is already checked-in (`site.pem`). The script to generate the key & cert with `openssl` is in the `docker/haproxy` folder. The container is also configured with a statistics port and you should be able to browse to `http://localhost:1936/haproxy?stats` to see whether the CAS and Gitlab backends are accessible. The statistics login is `admin/password`. 


## SAML Gitlab Service Provider Configuration in CAS
With SAML authentication, the Identity Provider and the Service Provider need to exchange metadata. In this case the Service Provder is Gitlab and it really just needs a URL from CAS and the fingerprint of the signing certificate CAS uses. Gitlab provides a URL that will return Gitlab's SAML service provider metadata. (See Gitlab's SAML configuration [documentation](https://docs.gitlab.com/ee/integration/saml.html))

```
https://localhost:8444/users/auth/saml/metadata
```

Note that if you browse to that in Firefox, be sure to "view source" before copying the XML because the displayed XML doesn't show the namespace declarations and CAS won't be happy without them. Use curl to be safe (e.g. from Git Bash on Windows):
```
curl -k https://localhost:8444/users/auth/saml/metadata -o gitlab_sp.xml
```

The service provider metadata XML looks something like this:
```xml
<md:EntityDescriptor xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata" xmlns:saml="urn:oasis:names:tc:SAML:2.0:assertion" ID="_14d0c512-75c6-432d-ba48-1431274079bb" entityID="https://example.org">
<md:SPSSODescriptor AuthnRequestsSigned="false" WantAssertionsSigned="false" protocolSupportEnumeration="urn:oasis:names:tc:SAML:2.0:protocol">
<md:NameIDFormat>
urn:oasis:names:tc:SAML:2.0:nameid-format:transient
</md:NameIDFormat>
<md:AssertionConsumerService Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST" Location="https://example.org/users/auth/saml/callback" index="0" isDefault="true"/>
<md:AttributeConsumingService index="1" isDefault="true">
<md:ServiceName xml:lang="en">Required attributes</md:ServiceName>
<md:RequestedAttribute FriendlyName="Email address" Name="email" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:basic" isRequired="false"/>
<md:RequestedAttribute FriendlyName="Full name" Name="name" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:basic" isRequired="false"/>
<md:RequestedAttribute FriendlyName="Given name" Name="first_name" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:basic" isRequired="false"/>
<md:RequestedAttribute FriendlyName="Family name" Name="last_name" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:basic" isRequired="false"/>
</md:AttributeConsumingService>
</md:SPSSODescriptor>
</md:EntityDescriptor>
```

Put that XML in a file called `gitlab_sp.xml` and store it in the `/etc/cas/saml` folder along with your SAML IDP metadata (because the folder is already there). 

Add the following entry to `cas.properties` in your overlay:
```
cas.samlSp.gitlab.metadata=file:/etc/cas/saml/gitlab_sp.xml
```
That property relies on some built-in support CAS has for Gitlab as a service provider and it requires the `cas-server-support-saml-sp-integrations` module already added to  build.gradle which also supports [many other applications](https://apereo.github.io/cas/development/configuration/Configuration-Properties.html#saml-sps). 

Copy the configuration and re-start CAS to get it to pick up the change:
```
gradlew copyCasConfiguration
gradlew run
```
When CAS starts up it will use information in the service provider metadata to generate a CAS service definition for Gitlab in the JSON service provider repository located at `/etc/cas/services`. 


During the course of the Gitlab/CAS/SAML login progress, CAS will make an HTTPS callback through HAProxy and it will do so through https://example.org/. The java that is running CAS will need to trust the certificate that HAProxy is using. From the `haproxy` folder containing the `example.org.crt` file, run the following (Must be run as administrator on Windows, assuming JAVA_HOME set to the same Java 11 that CAS is using.):

```
keytool -importcert -noprompt -cacerts -storepass changeit -file example.org.crt -alias example.org
```

## Login to Gitlab Via SAML
 - If you want to see SAML messages that traverse your browser, use the Chrome browser and install the `"SAML Chrome Panel"` extension from the Chrome store. It will add a SAML tab to the developer tools that will display SAML messages.
 - Make sure CAS is running along with the Gitlab, LDAP and HAProxy containers.
 - Browse to `https://example.org/` and arrive at Gitlab Login page.
 - Click the `"CAS Login"` button and arrive at `https://example.org/cas/login`
 - Login to CAS as `casuser/password`  which CAS will authenticate against LDAP and send identity back to Gitlab via SAML
 - Arrive at Gitlab logged-in as `casuser`. 

## Finale
Hopefully this helped you learn about using CAS's support for SAML to authenticate to Gitlab and provided enough detail that you could set it up and see it working before setting it up in a real environment. 

Note: If one were setting up Gitlab behind HAProxy then the haproxy config would need to include a tcp proxy that forwarded SSH traffic to gitlab but HAProxy is certainly capable of doing that: https://jonnyzzz.com/blog/2017/05/24/ssh-haproxy/


[Hal Deadman](https://github.com/hdeadman)
