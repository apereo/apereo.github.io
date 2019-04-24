---
layout:     post
title:      Apereo CAS - Webflow Decorations
summary:    Learn how you may decorate the Apereo CAS login webflow to inject data pieces and objects into the processing engine for display purposes, peace on earth and prosperity of all mankind, etc. Mainly, etc.

tags:       [CAS]
---

<div class="alert alert-success">
<strong>Collaborate</strong><br/>This blog is managed and hosted on GitHub. If you wish to update the contents of this post or if you have found an inaccuracy and wish to make corrections, we recommend that you please submit a pull request to <a href="https://github.com/apereo/apereo.github.io">this repository</a>.
</div>

# Overview

There are times where you may need to modify the CAS login webflow to include additional pieces of data, typically fetched from outside resources and endpoints. Examples include displaying announcements on the CAS login screen or calling a REST API to fetch today's Cafeteria menu, etc. While the webflow itself can certainly be extended in many fancy ways, one easy option is to let CAS *decorate* the login webflow automatically by reaching out outside sources to fetch data while taking care of the internal webflow configuration and injections on its own. Of course, once data is fetched and made available to CAS you still have the responsibility of using that data to properly display it in the appropriate view and style it correctly...and that's what we are going to do here!

Our use case is such:

- Examine the incoming application URL that has submitted a login request to CAS.
- If it's an `https` URL, display a message on the screen to reassure the user of their security and safety.
- If it's *NOT* an `https` URL, display a message on the screen anyway to frighten and notify the user!

Our starting position is based on:

- CAS `6.1.x`
- Java `11`
- [CAS WAR Overlay](https://github.com/apereo/cas-overlay-template)
- [JSON Service Registry](https://apereo.github.io/cas/development/services/JSON-Service-Management.html)

# Configuration

Imagine we have the following service definition registered with CAS:

```json
{
  "@class": "org.apereo.cas.services.RegexRegisteredService",
  "serviceId": "^https://.*",
  "name": "HTTPS and IMAPS",
  "id": 10000001,
  "description": "This service definition authorizes all application urls that support HTTPS and IMAPS protocols.",
}
```

The `serviceId` field above indicates that all URLs starting with `https://` are recognized by our CAS server. Later on, we may relax this pattern to allow `http`-based URLs as well so as to allow our logic for URL detection and follow-up messages on the screen.

Next, we are going to teach CAS about the location of a script that would handle the execution of our use case and conditions:

```properties
cas.webflow.login-decorator.groovy.location=file:/path/to/GroovWebflowDecorator.groovy
```

...of course, our Groovy script would be:

```groovy
import java.util.*
import java.io.*
import org.apereo.cas.web.support.*

def run(Object[] args) {
    def requestContext = args[0]
    def applicationContext = args[1]
    def logger = args[2]

    def service = WebUtils.getService(requestContext)
    logger.info("Decorating the login view for ${service}")
    if (service != null) {
        if (service.id.startsWith("https://")) {
            requestContext.flowScope.put("decoration", 
                new Decoration(title: "decoration.title.secure",
                            description: "decoration.description.secure"))
        } else {
            requestContext.flowScope.put("decoration", 
                new Decoration(title: "decoration.title.insecure",
                            description: "decoration.description.insecure"))
        }
    }
}

class Decoration implements Serializable {
    private static final long serialVersionUID = 8517547235465666978L
    String title
    String description
}
```

The above script simply attempts to stuff a `Decoration` object into the webflow using the lookup key `decoration`. Our object carries two fields for `title` and `description` that point to keys in our language bundles. The webflow will be decorated based on the incoming service and our condition therein, exposing access to our data object under the key `decoration`, which can then be used in CAS views to display data, etc. Mainly, etc.

<div class="alert alert-success">
<strong>Groovy Script</strong><br/>The script is cached and watched for changes. As you adjust the logic and update the script, CAS may detect changes to the file and auto-refresh its cached version of it after a small delay.
</div>


Of course, the CAS message/language bundle (typically `custom_messages.properties` file) should also contain the text for our message keys/codes as well:

```properties
decoration.title.secure=Secured!
decoration.title.insecure=Insecure!

decoration.description.secure=This application runs behind https.
decoration.description.insecure=This application runs behind http!
```

At this point, the webflow is properly decorated with the data we need to display. All we have to do is find a relevant CAS view and display that data, perhaps in `serviceui.html` somewhere:

```html
<div th:if="${decoration}">
    <h3 th:utext="#{${decoration.title}}" />
    <p th:utext="#{${decoration.description}}" />
</div>
```

That should do it.

# Test

If you attempt to access CAS using an application that does in fact run behind `https`, the following picture is what you should expect:

![image](https://user-images.githubusercontent.com/1205228/56655233-0b4fc880-6647-11e9-8a41-7fccdde920e5.png)

Next, if you relax the `serviceId` requirement to allow for `http` applications as well, you might see the following outcome:

![image](https://user-images.githubusercontent.com/1205228/56655214-fecb7000-6646-11e9-9076-d73db686ccaa.png)

# So...

I hope this review was of some help to you and I am sure that both this post as well as the functionality it attempts to explain can be improved in any number of ways. Please know that all other use cases, scenarios, features, and theories certainly [are possible](https://apereo.github.io/2017/02/18/onthe-theoryof-possibility/) as well. Feel free to [engage and contribute](https://apereo.github.io/cas/developer/Contributor-Guidelines.html) as best as you can.

Happy Coding,

[Misagh Moayyed](https://twitter.com/misagh84)