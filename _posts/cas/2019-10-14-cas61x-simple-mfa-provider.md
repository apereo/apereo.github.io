---
layout:     post
title:      Apereo CAS - Simple Multifactor Authentication
summary:    Learn to configure Apereo CAS to act as a simple multifactor provider itself.
tags:       [CAS]
---

<div class="alert alert-success">
<strong>Collaborate</strong><br/>This blog is managed and hosted on GitHub. If you wish to update the contents of this post or if you have found an inaccuracy and wish to make corrections, we recommend that you please submit a pull request to <a href="https://github.com/apereo/apereo.github.io">this repository</a>.
</div>

# Overview

The Apereo CAS portfolio presents support for an impressive number of [multifactor authentication providers](https://apereo.github.io/cas/development/mfa/Configuring-Multifactor-Authentication.html) out of the box. One such option is to remove dependencies to an external vendor integration and let the CAS server itself become a provider. This is a rather [simplified multifactor authentication](https://apereo.github.io/cas/development/mfa/Simple-Multifactor-Authentication.html) solution where after primary authentication, CAS begins to issue time-sensitive tokens to end-users via pre-defined communication channels such as email or text messages.

In this tutorial, we are going to briefly review the steps required to turn on [Simple Multifactor Authentication](https://apereo.github.io/cas/development/mfa/Simple-Multifactor-Authentication.html).

Our starting position is based on:

- CAS `6.1.x`
- Java `11`
- [MockMock](https://github.com/tweakers/MockMock)
- [CAS WAR Overlay](https://github.com/apereo/cas-overlay-template)

# Configuration

Prepare your CAS overlay with the correct [auto-configuration module](https://apereo.github.io/cas/development/mfa/Simple-Multifactor-Authentication.html). Next, we will first instruct CAS to trigger *simple mfa* for all requests and applications:

```properties
cas.authn.mfa.globalProviderId=mfa-simple
```

<div class="alert alert-info">
<strong>Why All?</strong><br/>This is done to keep things simple for purposes of this blog post. You are of course welcome to choose any multifactor trigger that works best for you. It should work all the same.
</div>

Then, let's choose email as our preferred communication mechanism for sharing tokens. To do so, let's teach CAS about [our email server](https://github.com/tweakers/MockMock):

```properties
spring.mail.host=localhost
spring.mail.port=25000
spring.mail.testConnection=true
```

<div class="alert alert-info">
<strong>Why Spring?</strong><br/>Settings and properties that are directly controlled by the CAS platform always begin with the prefix <code>cas</code>. All other settings are controlled and provided to CAS via other underlying frameworks and may have their schemas, syntax and validation rules. In this case, the presence of the above settings will instruct <i>Spring Boot</i> to create the required components internally for sending an email and make them available to CAS.
</div>

Then, let's instruct CAS to share tokens via email:

```properties
cas.authn.attributeRepository.stub.attributes.mail=misagh@somewhere.com

cas.authn.mfa.simple.mail.from=wolverine@example.org
cas.authn.mfa.simple.mail.subject=CAS MFA Token
cas.authn.mfa.simple.mail.text=Hello! Your requested CAS token is %s
cas.authn.mfa.simple.mail.attributeName=mail

cas.authn.mfa.simple.timeToKillInSeconds=30
```

A few things to note:

- The `%s` acts as a placeholder for the generated token in the body of the message.
- The expiration of the generated token is set to `30` seconds.
- User email addresses are expected to be found under a `mail` attribute. In this example, this is done as a static attribute via the stub attribute repository configuration.

At this point, we should be ready to test.

# Test

Once you build and bring up the deployment, let's simulate an authentication attempt from a made-up application, `https://app.example.org`, by submitting the following request:

```bash
https://sso.example.org/cas/login?service=https://app.example.org
```

After authentication, you should see the following entries in the CAS log:

```bash
- <Added ticket [CASMFA-004291] to registry.>
- <Successfully submitted token via SMS and/or email to [misagh]>
```

The screen should ask for the token:

![image](https://user-images.githubusercontent.com/1205228/66712549-4d182b00-edaf-11e9-8ab8-2ce916577eac.png)

If you check your email, you should have received a token:

![image](https://user-images.githubusercontent.com/1205228/66712619-78e7e080-edb0-11e9-97bc-0d908d1052d8.png)

Submit the generated token `CASMFA-004291` back to CAS and you should be allowed to proceed.

# Bonus

To control the length of the generated token, use:

```properties
# cas.authn.mfa.simple.tokenLength=6
```

You can take direct control of the token generation logic by [designing your own configuration component](https://apereo.github.io/cas/development/configuration/Configuration-Management-Extensions.html) with the following bean in place:

```java
@Bean
public UniqueTicketIdGenerator casSimpleMultifactorAuthenticationUniqueTicketIdGenerator() {
    return new MyUniqueTicketIdGenerator();
}
```

Implement the `MyUniqueTicketIdGenerator` as you see fit or better yet, use the `GroovyUniqueTicketIdGenerator` instead to hand off the implementation to an external Groovy script with the following body:

```groovy
def run(Object... args) {
    def prefix = args[0]
    def logger = args[1]
    return ...
}
```

You can also control the token validation logic by supplying the following bean that should respond to credentials of type `CasSimpleMultifactorTokenCredential`:

```java
@Bean
public AuthenticationHandler casSimpleMultifactorAuthenticationHandler() {
    return ...
}
```

# So...

I hope this review was of some help to you and I am sure that both this post as well as the functionality it attempts to explain can be improved in any number of ways. Please know that all other use cases, scenarios, features, and theories certainly [are possible](https://apereo.github.io/2017/02/18/onthe-theoryof-possibility/) as well. Feel free to [engage and contribute](https://apereo.github.io/cas/developer/Contributor-Guidelines.html) as best as you can.

Finally, if you benefit from Apereo CAS as free and open-source software, we invite you to [join the Apereo Foundation](https://www.apereo.org/content/apereo-membership) and financially support the project at a capacity that best suits your deployment. If you consider your CAS deployment to be a critical part of the identity and access management ecosystem and care about its long-term success and sustainability, this is a viable option to consider.

Happy Coding,

[Misagh Moayyed](https://fawnoos.com)

