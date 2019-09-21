---
layout:     post
title:      Apereo CAS - SMS Notifications via Twilio
summary:    Learn to configure Apereo CAS for SMS notifications via Twilio.
tags:       [CAS]
---

<div class="alert alert-success">
<strong>Collaborate</strong><br/>This blog is managed and hosted on GitHub. If you wish to update the contents of this post or if you have found an inaccuracy and wish to make corrections, we recommend that you please submit a pull request to <a href="https://github.com/apereo/apereo.github.io">this repository</a>.
</div>

# Overview

CAS has the ability to [send notifications via SMS](https://apereo.github.io/cas/development/notifications/SMS-Messaging-Configuration.html) for a variety of functions such as one-time passwords for multifactor authentication, service expiration notifications, and more. In this tutorial, 
we are going to take a look at configuring CAS for [SMS notifications via Twilio](https://www.twilio.com/) where we'll be using notifications to notify relevant contacts when services in the service registry are considered expired. 

Our starting position is based on:

- CAS `6.1.x`
- Java `11`
- [CAS WAR Overlay](https://github.com/apereo/cas-overlay-template)
- [JSON Service Registry](https://apereo.github.io/cas/development/services/JSON-Service-Management.html)

# Configuration

## Registered Service Policy

Once we have CAS up and running, let's start with the following sample service file as `Sample-100.json` in our JSON service registry:

```json
{
  "@class" : "org.apereo.cas.services.RegexRegisteredService",
  "serviceId" : "^https://app.example.org",
  "name" : "Sample",
  "id" : 100,   
  "contacts": [
    "java.util.ArrayList", [{
        "@class": "org.apereo.cas.services.DefaultRegisteredServiceContact",
        "name": "Misagh Moayyed",
        "phone": "+11234567890"
      }
    ]
  ],
  "expirationPolicy": {
    "@class": "org.apereo.cas.services.DefaultRegisteredServiceExpirationPolicy",
    "notifyWhenExpired": true,   
    "deleteWhenExpired": true,
    "expirationDate": "2019-09-22"
  }
}
```    

We have set up [contacts for our service](https://apereo.github.io/cas/development/services/Configuring-Service-Contacts.html).
These are the folks primarily in charge of this application who shall be notified once the service is considered expired. More importantly,
we have set up an expiration policy for the service where it will be considered expired and **removed** from the registry on the specified expiration date, `2019-09-22`.

## SMS Configuration via Twilio

Once our overlay is prepped with the [configuration module for Twilio](https://apereo.github.io/cas/development/notifications/SMS-Messaging-Configuration.html), we'll need to teach CAS about our [Twilio subscription](https://www.twilio.com/) using the following settings:

```properties 
# cas.smsProvider.twilio.accountId=...
# cas.smsProvider.twilio.token=...
```  

So, at this point we have CAS set up with Twilio and all that is left to 
configure the system for notifications when services are deemed expired:

```properties
cas.serviceRegistry.sms.from=1234567890
cas.serviceRegistry.sms.text=The service %s is expired and removed from CAS.
```

# Thou Shall Test

Once CAS is restarted, services in the registry will be reloaded and process to evaluate expiration dates. If an expired service is found, you might see something similar in the logs:

```bash 
<Registered service ... has expired on [2019-08-22]>
<Contacts for registered service ... will be notified of service expiry>  
...
<Deleting expired registered service ... from registry.>
```    

At this point, you should have received an SMS from CAS with the 
message `The service Sample is expired and removed from CAS.`

# So...

I hope this review was of some help to you and I am sure that both this post as well as the functionality it attempts to explain can be improved in any number of ways. Please know that all other use cases, scenarios, features, and theories certainly [are possible](https://apereo.github.io/2017/02/18/onthe-theoryof-possibility/) as well. Feel free to [engage and contribute](https://apereo.github.io/cas/developer/Contributor-Guidelines.html) as best as you can.

Happy Coding,

[Misagh Moayyed](https://twitter.com/misagh84)
