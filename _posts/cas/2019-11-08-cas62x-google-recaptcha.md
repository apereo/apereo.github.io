---
layout:     post
title:      Apereo CAS - Google reCAPTCHA Integration
summary:    Learn to set up an integration between Apereo CAS and Google reCAPTCHA.
tags:       [CAS]
---

<div class="alert alert-success">
<strong>Collaborate</strong><br/>This blog is managed and hosted on GitHub. If you wish to update the contents of this post or if you have found an inaccuracy and wish to make corrections, we recommend that you please submit a pull request to <a href="https://github.com/apereo/apereo.github.io">this repository</a>.
</div>

# Overview

[reCAPTCHA](https://developers.google.com/recaptcha) is a Google service that protects websites from 
spam and abuse. It uses advanced risk analysis techniques to tell humans and bots apart. This brief 
demonstrates how Apereo CAS may be configured to integrate with the Google reCAPTCHA API v2 and v3. 

Our starting position is based on:

- CAS `6.2.x`
- Java `11`
- [CAS WAR Overlay](https://github.com/apereo/cas-overlay-template)
- [CLI JSON Processor `jq`](https://stedolan.github.io/jq/)

# Configuration

## reCAPTCHA v2

Let's register our CAS server instance with Google to obtain a few integration keys:

![image](https://user-images.githubusercontent.com/1205228/68384146-66bf4f00-0170-11ea-83be-0839615921fc.png)

Next, once [the reCAPTCHA module](https://apereo.github.io/cas/development/integration/Configuring-Google-reCAPTCHA.html) is included in the WAR Overlay, we can begin to register the integration keys with CAS configuration:

```properties
cas.google-recaptcha.siteKey=6Let...
cas.google-recaptcha.secret=6Let...
```

That should be all. Build and deploy and the very next time you bring up the CAS login screen, you should automatically be presented with reCAPTCHA:

![image](https://user-images.githubusercontent.com/1205228/68384529-3cba5c80-0171-11ea-8e21-304938be08d4.png)

## reCAPTCHA v3

Integration with reCAPTCHA v3 is exactly the same; you will need to register CAS with Google reCAPTCHA v3 again to obtain v3-specific integration keys. Then, 
the reCAPTCHA version needs to be updated to match the integration version:

```properties
cas.google-recaptcha.siteKey=6Ld5...
cas.google-recaptcha.secret=6Ld5I...
cas.google-recaptcha.version=V3
```                           

## reCAPTCHA Score

Google reCAPTCHA returns a score (`1.0` is very likely a good interaction, `0.0` is very likely a bot). Based on the score, one can take variable action in a specific context. By default, CAS allows for a static single score in the configuration that is compared against the reCAPTCHA response. If the returned score is less than what CAS requires, the authentication attempt would be blocked.

```properties 
cas.google-recaptcha.score=0.5
```  

## Bonus

You can of course inject your own reCAPTCHA validation logic into CAS for more advanced scenarios. To supply your own validator, you should 
start by [designing your own configuration component](https://apereo.github.io/cas/development/configuration/Configuration-Management-Extensions.html) to 
include the following bean:

```java
@Bean
public Action validateCaptchaAction() {
    return new MyValidateCaptchaAction(...);
}
```

All you would have to do is to implement the `org.springframework.webflow.execution.Action` interface in the `MyValidateCaptchaAction`. 

# So...

I hope this review was of some help to you and I am sure that both this post as well as the functionality it attempts to explain can be improved in any number of ways. Please know that all other use cases, scenarios, features, and theories certainly [are possible](https://apereo.github.io/2017/02/18/onthe-theoryof-possibility/) as well. Feel free to [engage and contribute](https://apereo.github.io/cas/developer/Contributor-Guidelines.html) as best as you can.

Finally, if you benefit from Apereo CAS as free and open-source software, we invite you to [join the Apereo Foundation](https://www.apereo.org/content/apereo-membership) and financially support the project at a capacity that best suits your deployment. If you consider your CAS deployment to be a critical part of the identity and access management ecosystem and care about its long-term success and sustainability, this is a viable option to consider.

Happy Coding,

[Misagh Moayyed](https://fawnoos.com)
