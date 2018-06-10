---
layout:     post
title:      Apereo CAS - User Interface Customizations
summary:    ...in which I present an overview of various strategies one may use to modify and improve UI customizations in CAS.
tags:       [CAS]
---


<div class="alert alert-success">
<strong>Collaborate</strong><br/>This blog is managed and hosted on GitHub. If you wish to update the contents of this post or if you have found an inaccuracy and wish to make corrections, we recommend that you please submit a pull request to <a href="https://github.com/apereo/apereo.github.io">this repository</a>.
</div>

# Overview

When it comes to implementing CAS user interface customizations, there are many options and strategies one can use to deliver a unique user experience. There are ways one can customize the default views to overlay changes top of provided HTML files. These views may then be customized and loaded from a variety of locations, and just as well, could be themed using both static and dynamic strategies either globally or on a per-application basis. In this post, we shall review such customization strategies at a high-level, and also touch upon developer tools and methods that allow the changes to quickly go into effect and get deployed.

Our starting position is based on the following:

- CAS `5.3.0`
- Java 8
- [Maven](https://github.com/apereo/cas-overlay-template)

# Overlay Setup

Let's assume that application registration records are going to be managed as [flat JSON files](https://apereo.github.io/cas/development/installation/JSON-Service-Management.html):

```xml
<dependency>
      <groupId>org.apereo.cas</groupId>
      <artifactId>cas-server-support-json-service-registry</artifactId>
      <version>${cas.version}</version>
</dependency>
```

Next, you must teach CAS how to load JSON registration records from disk. This is done in the `cas.properties` file:

```properties
cas.serviceRegistry.initFromJson=false
cas.serviceRegistry.json.location=file:/etc/cas/services
```

...where a sample `ApplicationName-1001.json` would then be placed inside `/etc/cas/services`:

```json
{
  "@class" : "org.apereo.cas.services.RegexRegisteredService",
  "serviceId" : "https://app.example.org",
  "name" : "ApplicationName",
  "id" : 1001,
  "evaluationOrder" : 10
}
```

Fairly simple, thus far. Now, let's customize the user interface.

# Overlaying Views

CAS application views are found at `src/main/resources/templates` which is a location within the CAS web application itself. In order to modify the CAS HTML views, each view file first needs to be brought over into the overlay. You can use the `build.sh listviews` command to see what HTML views are available for customizations. Note that CAS views are broken up into smaller fragments, allowing you to customize and change specific portions of a particular page if needed. At any rate, once the file is chosen simply use `build.sh getview $NAME` to bring the `$NAME` view into your overlay:

```bash
$ build.sh getview footer.html

Exploded the CAS web application file.
Searching for view name footer.html...
Found view(s):
/cas-overlay-template/target/cas/WEB-INF/classes/templates/fragments/footer.html
Created view at /cas-overlay-template/src/main/resources/templates/fragments/footer.html
/cas-overlay-template/src/main/resources/templates/fragments/footer.html
```

Now that you have the `footer.html` brought into the overlay, you can simply modify the file at `cas-overlay-template/src/main/resources/templates/fragments/footer.html` to introduce your own footer-related changes, and then get the CAS web application deployed to finesse.

# Deploying Views

The quickest way to test such changes is by using the `bootrun` command:

```bash
$ build.sh bootrun
```

This command simply runs the CAS web application in an isolated sandboxed mode where local resources such as HTML, CSS, Javascript and other components are *watched* and *reloaded* dynamically when changes are detected. In our above example, you can continue to make changes to the `footer.html` file and keep refreshing the browser to see the change in action.

<div class="alert alert-success">
<strong>The CAS Watch</strong><br/>Files must exist in the overlay before they can be watched. If you add a new local resource into the overlay, you may need to run the <code>bootrun</code> command again so the file becomes watchable.
</div>

Note that view definitions and files are by default cached where the file content is processed and rendered once and then cached for maximum performance. If you wish for changes to be picked up automatically, you do need to disable the cache via the following setting in your `cas.properties` file:

```properties
spring.thymeleaf.cache=false
```

# Externalized Views

## Spring Boot

The location of CAS views is by default expected to be found at `src/main/resources/templates` which is the sort of behavior controlled and provided by Spring Boot. This location can be controlled using the following setting:

```properties
spring.thymeleaf.prefix=classpath:/templates/
```

This instructs CAS to locate views at the specified location. This location can be externalized to a directory outside the cas web application. Via this option, *all CAS views* are expected to be found at the specified location and there is no fallback strategy. (Note that multiple prefixes may be specified in comma-separated syntax).

## CAS

As a native CAS feature, Views and HTML files also may be externalized outside the web application conditionally and individually, provided the external path via CAS settings is defined. If a view template file is not found at the externalized path, the default one that ships with CAS will be used as the fallback.

```properties
cas.view.templatePrefixes[0]=file:///etc/cas/templates
```

With the above setting, I can try the following command to let CAS pick up the `footer.html` file from the above location:

```properties
mv src/main/resources/templates/fragments /etc/cas/templates
```

Of course, changes should continue to get picked up and deployed dynamically just like before!

## RESTful Views

CAS views may also be 100% externalized using a REST API of your own implementation. You will be tasked to design an API endpoint which CAS may contact in order to resolve a particular view specified using a request header. Upon a successful `200` status result, the response body of the endpoint is expected to contain the HTML view that will be rendered by CAS in the browser.

To activate RESTful resolution of views, specify the URL endpoint in your CAS properties:

```properties
cas.view.rest.url=https://rest.somewhere.org/userinterface
```

# Default Service URL

In the event that no `service` is submitted to CAS, you may specify a default service URL to which CAS will redirect. Note that this default service, much like all other services, MUST be authorized and registered with CAS and is taught to CAS using the following setting:

```properties
cas.view.defaultRedirectUrl=https://www.github.com
```

Of course, you can also the opposite of this behavior which is to disallow CAS to accept authentication requests if no `service` parameter is provided:

```properties
cas.sso.allowMissingServiceParameter=false
```

# Localization

The CAS Web application includes a number of localized message files for a variety of languages. While the user interface reacts dynamically as `locale` is detected automatically, you may forcefully switch the locale and localize the contents of the page using the `locale` parameter.

For example, the following URL:

```bash
https://cas.server.edu/login?locale=it
```

...allows CAS to render the page using the Italian language.

<div class="alert alert-success">
<strong>Remember</strong><br/>Note that not all languages are complete and accurate across CAS server releases as translations are entirely dependent upon community contributions. For an accurate and complete list of localized messages, always refer to the English language bundle.
</div>

The default language bundle is for the English language and is thus called `messages.properties` found at `src/main/resources` which you may need to pull into your own overlay but there may be an easier option. If there are any custom messages that need to be presented into views, they may also be formatted under `custom_messages.properties` files which allow you to both defined custom messages as well as those by CAS that need to be overwritten.

So this means I can simply create the language bundle for custom changes:

```bash
touch src/main/resources/custom_messages.properties
```

...and then add the following messages:

```properties
# CAS provided message
cas.login.resources.contribguide=Contribute & Engage

# Custom message
my.custom.messaage=Hello, World!
```

The first key is picked and used by CAS automatically since it's referenced in the main login view. The second key, however, is a custom one specific to the deployment at hand that needs to be pulled into the CAS overlay and relevant views. For simplicity, let's modify the same `footer.html` file we externalized to display this text:

```html
...
<footer th:fragment="footer" class="footer" role="contentinfo">
    <div class="container">
        <span id="copyright" th:utext="#{copyright}"></span>
        <span th:utext="#{my.custom.messaage}">This is the text</span>
    </div>
</footer>
...
```

Now, if CAS is actively rendering the `footer.html` view then the text linked to the `my.custom.message` is displayed. But surely, you can view the HTML page directly inside a browser window without running CAS in which case you get the sample dummy text *This is the text*.

By default, message bundles are expected to be found at `src/main/resources` and are cached just like the views. Let's make sure the cache is disabled so that our changes to the message bundle can be picked up automatically:

```properties
cas.messageBundle.cacheSeconds=0
```

# Themes

CAS deployers are now able to switch the themes based on different services. For example, you may want to have different login screens (different styles) for staff applications and student applications. Or, you want to show two layouts for daytime and night time. This document could help you go through the basic settings to achieve this. Themes are generally defined statically either embedded with the CAS web application or externalized outside, and there are a number of strategies one can use to activate, trigger and switch to a theme.

## Static Themes

CAS is configured to decorate views based on the `theme` property of a given registered service in the Service Registry. The theme that is activated via this method will still preserve the default views for CAS but will simply apply decorations such as CSS and Javascript to the views. The physical structure of views cannot be modified via this method.

To achieve this, add a `dracula.properties` placed to the root of `src/main/resources` folder. Contents of this file should match the following:

```properties
cas.standard.css.file=/themes/dracula/css/cas.css
cas.javascript.file=/themes/dracula/js/cas.js
cas.admin.css.file=/themes/dracula/css/admin.css
```

Once you have created the above `/themes/dracula` directory structure with your own CSS and Javascript files, activate the theme for a relevant application in the registry:

```json
{
  "@class" : "org.apereo.cas.services.RegexRegisteredService",
  "serviceId" : "https://app.example.org",
  "name" : "ApplicationName",
  "id" : 1001,
  "evaluationOrder" : 10,
  "theme": "dracula"
}
```

To see the theme in action, navigate to `https://sso.example.edu/cas/login?service=https://app.example.org`.

## Themed Views

CAS can also utilize a service’s associated `theme` property to selectively choose which set of UI views will be used to generate the standard views (i.e. `casLoginView.html`, etc). This is especially useful in cases where the set of pages for a theme that is targeted for a different type of audience are entirely different structurally, such that simply using a simple theme is not practical. So far, we have only seen basic CSS and Javascript files associated with a theme but what if you wanted the `dracula` theme activated for a service to present a different footer? Surely, the capabilities of a theme must go beyond CSS and Javascript, right? [Is that possible?](https://apereo.github.io/2017/02/18/onthe-theoryof-possibility/)

Yes. Views associated with a particular theme by default are expected to be found at `src/main/resources/templates/<theme-id>`. For example, in addition, the CSS and Javascript files for the `dracula` theme, you can clone the default set of CAS views into a new directory at `src/main/resources/templates/dracula`. When CAS begins to render the UI for `https://app.example.org`, it would then look inside `src/main/resources/templates/dracula` to find the requested view (i.e. `casLoginView.html`) allowing you to control the HTML view on a per-application basis. A themed view will only be used if and once found; otherwise, the defaults will continue to run as expected.

<div class="alert alert-success">
<strong>View vs Fragment</strong><br/>Note that from a CAS and/or Thymeleaf perspective, there is a difference between a full view and a fragment. A view generally contains the full outline of a CAS page and may be composed of several smaller reusable fragments, typically found inside the <code>fragments</code> directory. When working with themes, you are tasked with theming the actual view such as <code>casLoginView.html</code> by pulling that file into the right location in the overlay. Attempting to only theme a fragment such as <code>footer.html</code> will not be successful.
</div>

Note that CAS views and theme-based views may both be externalized out of the web application context. When externalized, themed views are expected to be found at the specified path via CAS properties under a directory named after the theme name. For instance, if the external path for CAS views is `/etc/cas/templates`, view template files for theme `dracula` may be located at `/etc/cas/templates/dracula/`.

## Dynamic Theme Selection

So far, we have been assigning themes to CAS services rather statically using the `theme` property but we can certainly take this to the next step and attempt to trigger themes based on a variety of conditions picked at runtime. Options for dynamic theme triggers are available based on Groovy scripts and/or REST endpoints. Let's try one with a Groovy script as the trigger.

First, let's widen the definition of our service to be a slightly more forgiving and assign the groovy script as the `theme`:

```json
{
  "@class" : "org.apereo.cas.services.RegexRegisteredService",
  "serviceId" : "https://.+.example.org",
  "name" : "ApplicationName",
  "id" : 1001,
  "evaluationOrder" : 10,
  "theme": "file:///etc/cas/config/themes.groovy"
}
```

The groovy script is tasked with the responsibility of figuring out the theme name. Of course, whatever the end result, it goes without saying that the theme must itself have been defined elsewhere since we are only controlling the switch here. The script more or less would match the following:

```groovy
import java.util.*

def String run(final Object... args) {
    def service = args[0]
    def registeredService = args[1]
    def queryStrings = args[2]
    def headers = args[3]
    def logger = args[4]

    /*
      Stuff happens...
    */

    return "dracula"
}
```

In the above script, you have access to the `service` object that represents the requesting application (i.e. `service.id` would get you the service URL) as well as the current request query strings and headers and of course, a pointer to the entire body of the registered service definition just in case you need to run some additional checks or control the behavior even more dynamically via [CAS custom properties](https://apereo.github.io/cas/development/installation/Configuring-Service-Custom-Properties.html).

# So...

I hope this review was of some help to you and I am sure that both this post as well as the functionality it attempts to explain can be improved in any number of ways. Please feel free to [engage and contribute](https://apereo.github.io/cas/developer/Contributor-Guidelines.html) as best as you can.

Happy Coding,

[Misagh Moayyed](https://twitter.com/misagh84)
