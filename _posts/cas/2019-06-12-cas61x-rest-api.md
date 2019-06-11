---
layout:     post
title:      Apereo CAS - REST API Integrations
summary:    Learn how to integrate with CAS using its REST API to authenticate, exchange tickets and get access to user profiles and attributes.
tags:       [CAS]
---

<div class="alert alert-success">
<strong>Collaborate</strong><br/>This blog is managed and hosted on GitHub. If you wish to update the contents of this post or if you have found an inaccuracy and wish to make corrections, we recommend that you please submit a pull request to <a href="https://github.com/apereo/apereo.github.io">this repository</a>.
</div>

# Overview

[REST protocol support](https://apereo.github.io/cas/development/protocol/REST-Protocol.html) in Apereo CAS has been available since the early days of CAS `3.x`. Since then, a lot of additional REST-based features and extensions are brought into the software to enable one to not only authenticate and/or exchange tokens but also add service definitions for relying parties or fetch attributes from remote REST endpoints, etc. The focus of this tutorial is to provide a brief overview of *some* of the REST-based features of CAS.

Our starting position is based on:

- CAS `6.1.x`
- Java `11`
- [CLI JSON Processor `jq`](https://stedolan.github.io/jq/)
- [CAS WAR Overlay](https://github.com/apereo/cas-overlay-template)
- [JSON Service Registry](https://apereo.github.io/cas/development/services/JSON-Service-Management.html)
- [REST Protocol](https://apereo.github.io/cas/development/protocol/REST-Protocol.html)

# Configuration

Let's assume that we have the following service definition in [CAS JSON service registry]((https://apereo.github.io/cas/development/services/JSON-Service-Management.html)):

```json
{
  "@class": "org.apereo.cas.services.RegexRegisteredService",
  "serviceId": "https://app.example.org",
  "name": "ExampleApp",
  "id": 1,
  "description": "This service definition defined our example application.",
}
```

Let's also instruct CAS to fetch attributes (i.e. `email`) from a static/stubbed attribute repository source:

```properties
cas.authn.attributeRepository.stub.attributes.email=casuser@example.org
```

Next, to enable the CAS REST protocol the overlay must primarily be prepped with the following modules:

```groovy
compile "org.apereo.cas:cas-server-support-rest:${project.'cas.version'}"
compile "org.apereo.cas:cas-server-support-rest-services:${project.'cas.version'}"
```

## Exchange Tokens

Let's invoke the REST API to authenticate a user and get back a ticket-granting ticket:

```bash
curl -k -X POST -H "Content-Type: Application/x-www-form-urlencoded" \
  https://sso.example.org/cas/v1/tickets \
  -d "username=casuser&password=Mellon"
```

...where the response would be:

```html
<!DOCTYPE HTML PUBLIC \"-//IETF//DTD HTML 2.0//EN\">
<html>
  <head><title>201 CREATED</title></head>
  <body><h1>TGT Created</h1>
    <form action="https://sso.example.org/cas/v1/tickets/TGT-2-abcdefg"
      method="POST">Service:<input type="text" name="service" value="">
      <br><input type="submit" value="Submit">
    </form>
  </body>
</html>
```
The ticket produced in the response is embedded inside an HTML form. We can adjust the `Accept` header to produce a more JSON-friendly response:

```bash
curl -X POST -H "Content-Type: Application/x-www-form-urlencoded" \
  -H "Accept: application/json" https://sso.example.org/cas/v1/tickets \
  -d "username=casuser&password=Mellon"
...
TGT-2-abcdefg
```

The ticket-granting ticket that is produced can be used to obtain a service ticket:

```bash
curl -X POST -H "Content-Type: Application/x-www-form-urlencoded" \
  -H "Accept: application/json" https://sso.example.org/cas/v1/tickets/ \
  TGT-2-abcdefg?service=https://www.google.com
ST-1-VGF-yzB8
```

The service ticket can then be validated so we could obtain the user profile:

```bash
curl -k https://sso.example.org/cas/p3/serviceValidate\
  ?service=https://www.google.com"&"ticket=ST-1-VGF-yzB8
```

...where the response would be:

```xml
<cas:serviceResponse xmlns:cas='http://www.yale.edu/tp/cas'>
    <cas:authenticationSuccess>
        <cas:user>casuser</cas:user>
        <cas:attributes>
            <cas:credentialType>UsernamePasswordCredential</cas:credentialType>
            <cas:isFromNewLogin>true</cas:isFromNewLogin>
            ...
            </cas:attributes>
    </cas:authenticationSuccess>
</cas:serviceResponse>
```

You could also specify a `format=json` parameter to produce a more JSON-friendly response:

```bash
curl -k https://sso.example.org/cas/p3/serviceValidate\
  ?service=https://www.google.com"&"ticket=ST-1-VGF-yzB8"&"format=json
```

## Registering Applications

REST calls to CAS to register applications must be authenticated using basic authentication where credentials are authenticated and accepted by the existing CAS authentication strategy, which in our case would be `casuser` and `Mellon`.

Furthermore, the authenticated principal must be authorized with a pre-configured role/attribute name and value that is designated in the CAS configuration via the CAS properties:

```properties
cas.rest.attributeName=email
cas.rest.attributeValue=.+example.*
```

The above outlines only users who carry an `email` attribute with a value that matches the above pattern can be authorized to add application definitions to CAS. In our case, we should be able to successfully do so with our sample `casuser` since the test account has a stubbed `email` attribute with a value of `casuser@example.org` that matches the above pattern.

Finally, the body of the request must be the service definition that shall be registered in JSON format and of course, CAS must be configured to accept the particular service type defined in the body.

So, the final call to CAS would be as such:

```bash
curl -k -H "Content-Type: application/json" -X POST \
  https://sso.example.org/cas/v1/services \
  -u casuser:Mellon -d@/path/to/app2.json
```

...where our `app2.json` would be as:

```json
{
  "@class" : "org.apereo.cas.services.RegexRegisteredService",
  "serviceId" : "https://app2.example.org.+",
  "name" : "ExampleApp2",
  "id" : 2,
  "description": "This is our second application"
}
```

Upon success, the CAS server would produce a `200` status code and its audit logs would indicate the successful registration of the application:

```bash
=============================================================
WHO: casuser
WHAT: AbstractRegisteredService(serviceId=https://app2.example.org.+...
ACTION: SAVE_SERVICE_SUCCESS
APPLICATION: CAS
WHEN: Mon Jun 12 14:46:58 MST 2019
CLIENT IP ADDRESS: 0:0:0:0:0:0:0:1
SERVER IP ADDRESS: 0:0:0:0:0:0:0:1
=============================================================
```

If you attempt the same operation with an unauthorized user:

```bash
curl -i -H "Content-Type: application/json" \
  -X POST https://sso.example.org/cas/v1/services \
  -u otheruser:somePassword -d@/path/to/app2.json
```

...you might see the following in the response with a `403` status code:

```bash
Request is not authorized
```

## RESTful Attribute Resolution

CAS can be configured to fetch attributes from a remote REST endpoint. This functionality stands on its own, and does not require the presence of any extensions or modules in the overlay. It is offered by default, and activated only if the following CAS configuration is defined:

```properties
cas.authn.attributeRepository.rest[0].basicAuthUsername=uid
cas.authn.attributeRepository.rest[0].basicAuthPassword=password
cas.authn.attributeRepository.rest[0].method=GET
cas.authn.attributeRepository.rest[0].url=https://rest.somewhere.org/casattributes
```

The authenticating user id is passed in form of a request parameter under `username`. The response is expected to be a JSON map as such:

```json
{
  "name" : "JohnSmith",
  "age" : 29,
  "groups": ["g1", "g2", "g3"]
}
```

Upon a successful authentication attempt, CAS would reach out to the REST endpoint to fetch attributes. The results are then merged with our stubbed collection of attributes and aggregated into one collection that would be available for attribute release. Specifically, in the end, the final collection of attributes for our `casuser` would be:

```json
{
  "name" : "JohnSmith",
  "age" : 29,
  "email" : "casuser@example.org",
  "groups": ["g1", "g2", "g3"]
}
```

# So...

I hope this review was of some help to you and I am sure that both this post as well as the functionality it attempts to explain can be improved in any number of ways. Please know that all other use cases, scenarios, features, and theories certainly [are possible](https://apereo.github.io/2017/02/18/onthe-theoryof-possibility/) as well. Feel free to [engage and contribute](https://apereo.github.io/cas/developer/Contributor-Guidelines.html) as best as you can.

Happy Coding,

[Misagh Moayyed](https://twitter.com/misagh84)