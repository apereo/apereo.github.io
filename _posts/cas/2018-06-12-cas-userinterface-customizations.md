---
layout:     post
title:      Apereo CAS - User Interface Customizations
summary:    A short tutorial on Apereo CAS user interface customizations, including themes, localization and dynamic views for all those who enjoy front-end development and suffer from instant gratification.
tags:       [CAS]
---

<div class="alert alert-danger">
  <strong>WATCH OUT!</strong><br/>This post is not official yet and may be heavily edited as CAS development makes progress. <a href="https://apereo.github.io/feed.xml">Watch</a> for further updates.
</div>

<div class="alert alert-success">
<strong>Collaborate</strong><br/>This blog is managed and hosted on GitHub. If you wish to update the contents of this post or if you have found an inaccuracy and wish to make corrections, we recommend that you please submit a pull request to <a href="https://github.com/apereo/apereo.github.io">this repository</a>.
</div>

# Overview

When it comes to implementing CAS user interface customizations, there are many options and strategies one can use to deliver a unique user experience. There are ways one can customize the default views to overlay changes top of provided HTML files. These views may then be customized and loaded from a variety of locations, and just as well, may be themed using both static and dynamic strategies either globally or on a per-application basis. In this post, we shall review such customization strategies at a high-level, and also touch upon developer tools and methods that allow the changes to quickly go into effect and get deployed.

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

CAS application views are found at `src/main/resources/templates` which is a location within the CAS web application itself. In order to modify the CAS HTML views, each view file first needs to be brought over into the overlay. You can use the `build.sh listviews` command to see what HTML views are available for customizations. Note that CAS views are broken up into smaller fragments, allowing you to customize and change specific portions of a particular page, if needed. At any rate, once the file is chosen simply use `build.sh getview $NAME` to bring the `$NAME` view into your overlay:

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
<strong>The CAS Watch</strong><br/>Files must exist in the overlay before they can be watched. If you add a new local resource into the overlay, you may need to run the <code>bootrun</code> command again so the file becomes watchable.</a>.
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
cas.view.rest.url=https://rest.somewhere.org/attributes
```

# Default Service URL

In the event that no `service` is submitted to CAS, you may specify a default service url to which CAS will redirect. Note that this default service, much like all other services, MUST be authorized and registered with CAS and is taught to CAS using the following setting:

```properties
cas.view.defaultRedirectUrl=https://www.github.com
```

Of course, you can also the opposite of this behavior which is to disallow CAS to accept authentication requests if no `service` parameter is provided:

```properties
cas.sso.allowMissingServiceParameter=false
```

# Localization

The CAS Web application includes a number of localized message files for a variety of languages. While the user interface reacts dynamically as `locale` is detected automatically, you may forcefully switch the locale and localize the contents of the page using the `locale` parameter. 

For example, the following command:

```bash
https://cas.server.edu/login?locale=it
```

...allows CAS to render the page using the Italian language.

<div class="alert alert-success">
<strong>Remember</strong><br/>Note that not all languages are complete and accurate across CAS server releases as translations are entirely dependent upon community contributions. For an accurate and complete list of localized messages, always refer to the English language bundle.</a>.
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

The first key is picked and used by CAS automatically since it's referenced in the main login view. The second key however is a custom one specific to the deployment at hand that needs to be pulled into the CAS overlay and relevant views. For simplicity, let's modify the same `footer.html` file we externalized to display this text:

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

# So...

I hope this review was of some help to you and I am sure that both this post as well as the functionality it attempts to explain can be improved in any number of ways. Please feel free to [engage and contribute](https://apereo.github.io/cas/developer/Contributor-Guidelines.html) as best as you can.

Happy Coding,

[Misagh Moayyed](https://twitter.com/misagh84)
