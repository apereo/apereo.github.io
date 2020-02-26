---
layout:     post
title:      Apereo CAS - Bootiful CAS Client
summary:    Easy to use CAS Client
tags:       [CAS]
---

<div class="alert alert-success">
<strong>Collaborate</strong><br/>This blog is managed and hosted on GitHub. If you wish to update the contents of this post or if you have found an inaccuracy and wish to make corrections, we recommend that you please submit a pull request to <a href="https://github.com/apereo/apereo.github.io">this repository</a>.
</div>

# Overview
CAS Developer Scenario:
```text
After spending a few days in trying to stand up a newer version CAS IdP, you realize that you
finally have it running! You are so ecstatic that you stand up and start dancing and 
singing, "I did it! I did it! Woohoo!", to the dismay of your office mates.

Now you are ready to test and verify that your new CAS instances is working. 
You start thinking to yourself:
"How am I going to test CAS?"
"Hmm...Should I re-point a Prod app to the new CAS instance for a few minutes?"
"Maybe I can do this late at night, around 2 a.m. or so?"
Then you realize what you are saying
"What! Am I crazy!"
"The last thing I need is for the boss to run in here threatening to fire me!" 
"I'm still paying off my awesome CosPlay outfit from last years Comic-Con!"

"Maybe there is some open source CAS SP I can download and use?"
"This one sucks!"
"This one looks cool, but I could probably write one from scratch before I will figure out these directions!" 

"What to do?"
```
Does this sounds like something you have gone through?

Stumped on how to test CAS?  

Then I have something for you!  

The answer my friend is not blowing in the wind, it is rather just one small click away at [Bootiful CAS Client](https://github.com/UniconLabs/bootiful-cas-client)! 

An easy peasy CASified Client!


# Bootiful CAS Client

### Installation
* Clone or download the source code from [Bootiful CAS Client](https://github.com/UniconLabs/bootiful-cas-client)
* Update the file `src/main/resources/application.yml` with the URL's needed to test:
```text
cas:
  #Required properties
  server-url-prefix: https://localhost:8143/cas
  server-login-url: https://localhost:8143/cas/login
  client-host-url: https://localhost:8443
```
* Update the same file to point to the keystore that will need to be created:
```text
server:
  port: 8443
  ssl:
    enabled: true
    key-store: /directory/tothe/.keystore
    key-store-password: changeit  
```
* Now from the command line run: ./gradlew clean bootRun
* Visit the `client-host-url` you entered, in our case it is https://localhost:8443, in your browser of choice and enjoy the CASified Spring Boot app!

# So...

I hope you enjoy this easy peasy CASy client on all your future CAS testing!

Finally, if you benefit from Apereo CAS as free and open-source software, we invite you to [join the Apereo Foundation](https://www.apereo.org/content/apereo-membership) and financially support the project at a capacity that best suits your deployment. If you consider your CAS deployment to be a critical part of the identity and access management ecosystem and care about its long-term success and sustainability, this is a viable option to consider.

As [Misagh Moayyed](https://fawnoos.com) says 'Happy Coding'!

[Axel Stohn](https://github.com/astohn)
