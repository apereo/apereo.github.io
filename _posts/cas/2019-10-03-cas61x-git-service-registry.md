---
layout:     post
title:      Apereo CAS - Managing Services via Git
summary:    Learn to configure Apereo CAS to fetch application policy files and service records for its service registry from remote git repositories.
tags:       [CAS]
---

<div class="alert alert-success">
<strong>Collaborate</strong><br/>This blog is managed and hosted on GitHub. If you wish to update the contents of this post or if you have found an inaccuracy and wish to make corrections, we recommend that you please submit a pull request to <a href="https://github.com/apereo/apereo.github.io">this repository</a>.
</div>

# Overview

Applications that are integrated with the Apereo CAS server typically are registered with the system as [JSON](https://apereo.github.io/cas/development/services/JSON-Service-Management.html) or [YAML](https://apereo.github.io/cas/development/services/YAML-Service-Management.html) files. Such files can be stored in a remote git repository to take advantage of all native operations and benefits of *distributed* source control such as version tracking, history, etc, given they are considered source code after all.

Using a git-backed service registry, CAS is given the ability to pull down and *clone* a repository and watch for changes at defined intervals. In this tutorial, we are going to quickly review the steps required to [manage application records via Git](https://apereo.github.io/cas/development/services/Git-Service-Management.html).

Our starting position is based on:

- CAS `6.1.x`
- Java `11`
- [CAS WAR Overlay](https://github.com/apereo/cas-overlay-template)
- [CLI JSON Processor `jq`](https://stedolan.github.io/jq/)

# Configuration

Once you have prepped your CAS overlay with the correct [auto-configuration module](https://apereo.github.io/cas/development/services/Git-Service-Management.html), you will need to instruct CAS to try and connect to the repository:

```properties
cas.serviceRegistry.initFromJson=false

cas.serviceRegistry.git.repositoryUrl=https://github.com/cas-server/sample-data
cas.serviceRegistry.git.branchesToClone=master
cas.serviceRegistry.git.activeBranch=master
cas.serviceRegistry.git.cloneDirectory=file:/tmp/cas-service-registry
cas.serviceRegistry.git.pushChanges=true
```

I am using a public repository on Github whose `master` branch. If you are working with a private git repository that requires credentials for access, you can specify those as well:

```properties
# cas.serviceRegistry.git.username=
# cas.serviceRegistry.git.password=
```

My current contains the following two files. One is a `Test-1.json` file at the root of the repository with the following content:

```json
{
  "@class" : "org.apereo.cas.services.RegexRegisteredService",
  "serviceId" : "testId",
  "name" : "TEST",
  "id" : 1,
  "evaluationOrder" : 1
}
```

...and the other is a `SAMPLE-2.yaml` inside a `test` folder:

```yaml
--- !<org.apereo.cas.services.RegexRegisteredService>
serviceId: "testId-yaml"
name: "SAMPLE"
id: 2
description: "description"
attributeReleasePolicy: !<org.apereo.cas.services.ReturnAllAttributeReleasePolicy> {}
accessStrategy: !<org.apereo.cas.services.DefaultRegisteredServiceAccessStrategy>
  enabled: true
  ssoEnabled: true
```

We expect that CAS would connect to the repository's `master` branch to pull down the above files regardless of where they are physically located in the repository directory structure.

To make it easier to test the changes, I am also going to include the [auto-configuration module for reporting](https://apereo.github.io/cas/development/monitoring/Monitoring-Statistics.html#cas-endpoints) in the CAS overlay to take advantage of `registeredServices` [actuator endpoint](https://apereo.github.io/cas/development/services/Service-Management.html#administrative-endpoints). With the inclusion of this module, I can instruct CAS to enable it and allow anonymous requests for easy testing:

```properties
management.endpoints.web.exposure.include=registeredServices
management.endpoint.registeredServices.enabled=true

cas.monitor.endpoints.endpoint.registeredServices.access=ANONYMOUS
```

At this point, we should be ready to test.

## Test

Once you build and bring up the deployment, the following should be apparent in the CAS `DEBUG` logs:

```bash
<[Pull] -> [1], total [2] [50]% Completed>
<[Pull] -> [2], total [2] [100]% Completed>
<Finished [Pull] -> [2], total [2] [100]% Completed>
<Successfully pulled changes from the remote repository>
<Adding registered service [testId-yaml] with name [SAMPLE] and internal identifier [2]>
<Adding registered service [testId] with name [TEST] and internal identifier [1]>
<Loaded [2] service(s) from [GitServiceRegistry].>
<Service registry [GitServiceRegistry] contains [2] service definitions>
```

Note that since CAS is by default configured to periodically reload the contents of the service registry, from time to time based on the pre-defined interval, the following log messages should appear:

```bash
Loaded [2] service(s) from [GitServiceRegistry].
```

...which means we can go to the repository and make a change to the `description` field of our YAML service file:

```yaml
--- !<org.apereo.cas.services.RegexRegisteredService>
serviceId: "testId-yaml"
name: "SAMPLE"
id: 2
description: "Description is updated to be more interesting"
attributeReleasePolicy: !<org.apereo.cas.services.ReturnAllAttributeReleasePolicy> {}
accessStrategy: !<org.apereo.cas.services.DefaultRegisteredServiceAccessStrategy>
  enabled: true
  ssoEnabled: true
```

...and CAS should be able to *pull* down the change and reload the corresponding service file. To observe that change is activated, we can submit a request to CAS and ask for our service:

```bash
curl https://sso.example.org/cas/actuator/registeredServices/2 | jq
```

By default, the response type is always in JSON. If you prefer YAML, by all means:

```bash
curl  -H "Accept: application/vnd.cas.services+yaml" https://sso.example.org/cas/actuator/registeredServices/2
```

Of if you wish to force-reload the contents of the service registry:

```bash
curl https://sso.example.org/cas/actuator/registeredServices
```

# So...

I hope this review was of some help to you and I am sure that both this post as well as the functionality it attempts to explain can be improved in any number of ways. Please know that all other use cases, scenarios, features, and theories certainly [are possible](https://apereo.github.io/2017/02/18/onthe-theoryof-possibility/) as well. Feel free to [engage and contribute](https://apereo.github.io/cas/developer/Contributor-Guidelines.html) as best as you can.

Happy Coding,

[Misagh Moayyed](https://twitter.com/misagh84)