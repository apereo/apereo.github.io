---
layout:     post
title:      Apereo CAS Swag with Swagger
summary:    Enable Swagger integration with your Apereo CAS APIs.
tags:       [CAS]
---

<div class="alert alert-success">
  <strong>Collaborate</strong><br/>The blog is managed and hosted on GitHub. If you wish to update the contents of this post or if you have found an inaccuracy and wish to make corrections, we recommend that you please submit a pull request to <a href="https://github.com/apereo/apereo.github.io">this repository</a>.
</div>

For some time now, CAS has had the ability to take advantages of Swagger natively to produce API documentation automatically. The generated documentation supports all CAS endpoints and REST APIs provided they are made available to the runtime application context. This means that any and all modules that declare API endpoints will automatically
be recognized by the CAS Swagger integration, provided of course the module is activated and included in your CAS configuration.

If you wish to learn more about Swagger, please [visit this link](https://swagger.io/) and the reference documentation for CAS `5.3.x` as of this writing is available [here](https://apereo.github.io/cas/5.3.x/integration/Swagger-Integration.html).

Our starting position is based on the following:

- CAS `5.3.x`
- Java 8
- [Maven Overlay](https://github.com/apereo/cas-overlay-template)

## Configuration

The setup is in fact super simple; as the documentation describes you simply need to add the required dependency in your overlay:

```xml
<dependency>
  <groupId>org.apereo.cas</groupId>
  <artifactId>cas-server-documentation-swagger</artifactId>
  <version>${cas.version}</version>
</dependency>
```

...and just to keep things more interesting, I also chose to include support for [CAS REST Protocol](https://apereo.github.io/cas/5.3.x/protocol/REST-Protocol.html):

```xml
<dependency>
    <groupId>org.apereo.cas</groupId>
    <artifactId>cas-server-support-rest</artifactId>
    <version>${cas.version}</version>
</dependency>
```

That's it. Package and run the overlay as usual. Once the server is up and running, simply navigate to `https://<your-cas-server-address>/cas/swagger-ui.html` and examine the APIs presented to you via Swagger. For instance, this is what I see:

![image](https://user-images.githubusercontent.com/1205228/43123901-d4321800-8f3a-11e8-81ac-57d8a472d427.png)

Notice how certain entries are surrounded in a blue square. This is not a Swagger feature; rather this is me trying to outline that the endpoints and APIs
that are presented as part of the CAS protocol are also automatically picked up by Swagger and presented to you beautifully via this user interface. This behavior, as a reminder,
applies to any module that presents APIs.

## Finale

I hope this review was of some help to you and I am sure that both this post as well as the functionality it attempts to explain can be improved in any number of ways. Please feel free to [engage and contribute](https://apereo.github.io/cas/developer/Contributor-Guidelines.html) as best as you can.

[Misagh Moayyed](https://twitter.com/misagh84)
