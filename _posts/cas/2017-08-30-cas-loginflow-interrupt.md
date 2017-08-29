---
layout:     post
title:      Interrupt CAS With Class
summary:    An overview of a recent CAS 5.2.x feature that allows one to interrupt the authentication flow with notifications and advertisements, dictating CAS should treat the authenticated session with configuration and compassion.
tags:       [CAS]
---

> The fastest route to a 10X engineer is to give them 0.1X the distractions." - Eric Meyer

While that is generally sensible advice, when it comes to CAS there are times where you wish to interrupt the CAS authentication flow and the present the end-user with notifications and annoucements. A common use case deals with presenting a bulletin board during the authentication flow to select users and then optionally require the audience to complete a certain task before CAS is able to honor the authentication request and establish a session. Examples of such messages tasks may include: _"The kitchen’s menu today features <a href="https://www.wikiwand.com/en/Khash_(dish)">Khash</a>. Click here to get directions."_ or _"The office of compliance and regulations has announced a new policy on using forks. Click to accept, or forever be doomed with spoons"_.

This is a tutorial on how to present such interruptions to your CAS audience, as a fairly recent feature in CAS `5.2.x` and beyond. To learn more about this behavior, please [see this guide](https://apereo.github.io/cas/development/installation/Webflow-Customization-Interrupt.html).

<div class="alert alert-info">
  <a href="#" class="close" data-dismiss="alert" aria-label="close">&times;</a>
  <strong>WATCH OUT!</strong><br/>As of this writing, CAS <code>5.2.x</code> is not officially released. See the <a href="https://github.com/apereo/cas/milestones">release schedule</a> for more info.
</div>

# Interrupt Source

First and foremost, there needs to be an engine of some sort that is able to produce notifications and interruptions. CAS supports a range of such engines that are backed by JSON & Groovy resources, REST endpoints or one you decide to create and inject into the runtime. 

For the purposes of this tutorial, I will be using the static JSON resource which is a perfectly suitable option for super small deployments or relevant during development and testing. The JSON resource path is taught to CAS via the following setting:

```properties
cas.interrupt.json.location=file:/etc/cas/config/interrupt.json
```

# Interrupt Rules

Once you have defined the above setting and assuming your overlay is prepped with relevant [configuration module](https://apereo.github.io/cas/development/installation/Webflow-Customization-Interrupt.html), CAS will attempt to understand the interruption rules that are defined in the `interrupt.json` file. My rules are defined as such:

```json
{
  "casuser" : {
    "message" : "We have interrupted your CAS authentication workflow to bring you the following information. Select one of the links below to go somewhere and do something fun and then come back to continue with <strong>CAS</strong>.",
    "links" : {
      "Go to Google" : "https://www.google.com",
      "Go to Yahoo" : "https://www.yahoo.com"
    },
    "ssoEnabled" : false,
    "interrupt" : true,
  }
}
```

The above ruleset simply says: _Whenever <code>casuser</code> authenticates, present the `message` to the user with a number of `links`. So simply `interrupt` but make sure an SSO session is not established which would have the user present credentials again in subsequent attempts.

# The Looks

Once that is all in place, _casuser_ will see the following screen, after having authenticated successfully:

![image](https://user-images.githubusercontent.com/1205228/29816821-eb5a597a-8cca-11e7-8ee8-f5433b01f90d.png)

It's that simple. Of course, for more advanced and production-quality interruptions you likely need to write a Groovy script or design a REST endpoint that ties CAS with your own institutional messages.

Given this is so new, I am sure you will find plenty of opportunities to improve this functionality with additional bells and whistles. [Please do](https://apereo.github.io/cas/developer/Contributor-Guidelines.html).

[Misagh Moayyed](https://twitter.com/misagh84)