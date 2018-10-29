---
layout:     post
title:      Apereo CAS - Integration with HashiCorp Vault
summary:    CAS distributed configuration management using HashCorp Vault, where you learn how to store and secure CAS configuration settings and properties inside Vault.
tags:       [CAS]
---

<div class="alert alert-success">
  <strong>Collaborate</strong><br/>The blog is managed and hosted on GitHub. If you wish to update the contents of this post or if you have found an inaccuracy and wish to make corrections, we recommend that you please submit a pull request to <a href="https://github.com/apereo/apereo.github.io">this repository</a>.
</div>

[Vault](https://www.vaultproject.io/) is a tool for securely accessing secrets. A secret is anything that you want to tightly control access to, such as API keys, passwords, certificates, and more. Vault provides a unified interface to any secret while providing tight access control and recording a detailed audit log.

The CAS integration with vault [has been available](https://apereo.github.io/cas/development/configuration/Configuration-Properties-Security.html#vault) for some time. In this walkthrough, we are going to take a pass at getting CAS connected to Vault to store properties and settings. We will also try to reload settings dynamically in real-time as they are changed and updated inside Vault.

<div class="alert alert-success">
  <strong>More HashiCorp</strong><br/>You may also be interested in a CAS integration with <a href="https://apereo.github.io/2018/10/22/cas6-consul-discovery/">HashCorp Consul</a>.
</div>

Our starting position is based on the following:

- CAS `6.0.0-RC4`
- Java 11
- [CAS Overlay](https://github.com/apereo/cas-overlay-template) (The `master` branch specifically)
- [Docker](https://www.docker.com/get-started)
- [CLI JSON Processor `jq`](https://stedolan.github.io/jq/)

## Vault

To run Vault for development and testing, we can use the provided Docker image:

```bash
docker run --cap-add=IPC_LOCK -d -e 'VAULT_DEV_ROOT_TOKEN_ID=CAS' -p 8200:8200 --name=vault vault
docker ps
```

This runs a completely in-memory Vault server, which is useful for development but **SHOULD NOT** be used in production. Note the environment variable `VAULT_DEV_ROOT_TOKEN_ID` which sets the ID of the initially generated root token to the given value. We will use this token, later on, to log into the Vault UI and it will be also be utilized when CAS attempts to connect to Vault.

To access the Vault UI, point your browser to `http://localhost:8200/ui` and use the above token to log into Vault where you'd be greeted with the following screen:

![image](https://user-images.githubusercontent.com/1205228/47616833-06b2b900-dad7-11e8-99bc-5c44c0d900d2.png)


So, let's create a few secrets. Secrets inside Vault can be managed inside folders where from the CAS perspective, the folder hierarchy is expected to match the following:

```
/secret/{application}/{profile}
/secret/{application}
```

...where `application` is the value of `spring.application.name` which is by default `cas` and the `profile` is any a tag/label assigned to a collection of settings that would be activated and fetched if the CAS server is deployed using said profile(s). So, as an example, we can create a secret for `cas.authn.accept.users` with the value of `casuser::Vault`. We will put this secret inside the path `/secret/cas/vault` where `cas` is the name of our application and `vault` is the profile name we shall activate when running CAS.

![image](https://user-images.githubusercontent.com/1205228/47643977-35399e00-db82-11e8-9ca3-4202c3125476.png)

Note that I have added a number of other settings to allow access to the CAS actuator endpoints. This will allow us to refresh the state of CAS application context, once a setting is updated with a new value.

<div class="alert alert-warning">
  <strong>WATCH OUT!</strong><br/>The above collection of settings <strong>MUST</strong> only be used for demo purposes and serve as an <strong>EXAMPLE</strong>. It is not wise to enable and expose all actuator endpoints to the web and certainly, the security of the exposed endpoints should be taken into account very seriously. None of the CAS or Spring Boot actuator endpoints are enabled by default. For production, you should carefully choose which endpoints to expose.
</div>

That should do for now. Let's get CAS running.

## CAS

Integration with Vault in CAS is handled using [Spring Cloud Vault](https://cloud.spring.io/spring-cloud-vault/) and can be done in a number of ways:

- If you have the [Spring Cloud Config Server](https://apereo.github.io/2018/10/25/cas6-cloud-config-server/) deployed, Vault could be one of its many sources for settings and properties. In this scenario, you will just need to make sure the CAS server can talk to the Spring Cloud Config Server correctly, and the Config Server is then in charge of communicating with Vault to fetch settings, etc.

- Alternatively, you may decide to connect your CAS server directly to Vault and fetch settings. This is the approach we are going to try in this tutorial for a quick win, but do note that the strategy is almost the same if we were to use the Cloud Config server.

So in order to enable a CAS integration with Vault *directly*, you want to start with the [CAS Overlay](https://github.com/apereo/cas-overlay-template), clone the project and then put the following settings into a `src/main/resources/bootstrap.properties` file:

```properties
spring.application.name=cas
spring.profiles.active=vault

spring.cloud.vault.host=localhost
spring.cloud.vault.port=8200
spring.cloud.vault.token=CAS
spring.cloud.vault.enabled=true
spring.cloud.vault.reactive.enabled=false
spring.cloud.vault.fail-fast=true
spring.cloud.vault.scheme=http

spring.cloud.vault.kv.enabled=true
spring.cloud.vault.kv.backend=secret
```

We are teaching CAS to find our Vault server at `http://localhost:8200` and use the generated token `CAS` for authenticated requests.

<div class="alert alert-warning">
  <strong>Authentication</strong><br/>Besides a token, there are many other ways to ensure requests to Vault are authenticated such AppIds, roles, AWS-EC2, etc. See <a href="https://cloud.spring.io/spring-cloud-vault/">Spring Cloud Vault</a> for more info.
</div>

We have also enabled the versioned Key-Value secret backend. The key-value backend allows storage of arbitrary values as key-value store. A single context can store one or many key-value tuples. Contexts can be organized hierarchically. Per our previous work in Vault, the backend is called `secret`.

Note that there are many other types of backends supported. See [Spring Cloud Vault](https://cloud.spring.io/spring-cloud-vault/) for more info.

Of course, don't forget to include the required module in your CAS build:

```gradle
compile "org.apereo.cas:cas-server-support-configuration-cloud-vault:${project.'cas.version'}"
```

Build and deploy. At this point, you should be able to log into CAS using `casuser` and `Vault` as the credentials!

### Refresh & Reload

If a secret changes, Vault has no way to broadcast the updated value(s) to its own clients, such as the CAS server itself. Therefore, in order to broadcast such change events CAS presents various endpoints that allow the user to [refresh the configuration](https://apereo.github.io/cas/development/configuration/Configuration-Management-Reload.html) as needed. This means that an adopter would simply change a required CAS setting and then would submit a request to CAS to *refresh* its current state. At runtime! All CAS internal components that are affected by the external change are quietly reloaded and the setting takes immediate effect, completely removing the need for container restarts or CAS re-deployments.

For example, start by changing the value of `cas.authn.accept.users` in Vault to something like `casuser::HelloWorld`. Then, execute the following command to refresh the CAS application context:

```bash
curl -k -u casuser:Mellon https://sso.example.org/cas/actuator/refresh -d {} -H "Content-Type: application/json"

...
["cas.authn.accept.users"]
```

At this point, you should be able to log into CAS using `casuser` and `HelloWorld` as the credentials!

## Finale

I hope this review was of some help to you and I am sure that both this post as well as the functionality it attempts to explain can be improved in any number of ways. Please feel free to [engage and contribute](https://apereo.github.io/cas/developer/Contributor-Guidelines.html) as best as you can.

[Misagh Moayyed](https://twitter.com/misagh84)