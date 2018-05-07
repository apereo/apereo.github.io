---
layout:     post
title:      Apereo CAS - Customized Settings
summary:    Extend the Apereo CAS server to allow custom configuration properties and settings.
tags:       [CAS]
---

<div class="alert alert-success">
<strong>Collaborate</strong><br/>This blog is managed and hosted on GitHub. If you wish to update the contents of this post or if you have found an inaccuracy and wish to make corrections, we recommend that you please submit a pull request to <a href="https://github.com/apereo/apereo.github.io">this repository</a>.
</div>

# Overview

Starting with version `5.3.x`, CAS begins to own its own configuration namespace rather more seriously, rejecting any settings that are no longer supported or recognized. While this works quite well for configuration settings that tend to get deprecated and moved about from release to release, it also has a side-effect of not allowing any custom settings to be defined by the adopter. In practice, adding custom settings to a `cas` namespace is likely less than ideal, as it would be best to denote localized changes using their own specific namespaces and settings. So, in this tutorial, a short overview of extending CAS to use customized properties is presented as well as an alternative simplified strategy to introduce configuration options into the runtime without dabbling into much code.

Our starting position is based on the following:

- CAS `5.3.0-RC4`
- Java 8
- [Maven](https://github.com/apereo/cas-overlay-template) Or [Gradle](https://github.com/apereo/cas-gradle-overlay-template) WAR Overlays

# Custom Properties: Take #1

This strategy more or less applies to any CAS `5.x` deployment as more of a heavyweight approach most useful when you are about to extend the CAS configuration to alter its workings by overriding conditional beans or introducing new components and behavior into the runtime engine.

You will need to start by defining your collection of settings first:

```java
@ConfigurationProperties(value = "custom")
public class CustomConfigurationProperties {
    private String settingName;

    public String getSettingName() {
        return settingName;
    }

    public void setSettingName(final String value) {
        this.settingName = value;
    }
}
```

Or, if you can afford a bit of syntactic sugar with Lombok:

```java
@Getter
@Setter
@ConfigurationProperties(value = "custom")
public class CustomConfigurationProperties {
    private String settingName;
}
```

Next, you need to [extend the CAS configuration](https://apereo.github.io/cas/development/installation/Configuration-Management-Extensions.html) to have your configuration settings be recognized by the runtime:

```java
@Configuration("SomethingConfiguration")
@EnableConfigurationProperties(CustomConfigurationProperties.class)
public class SomethingConfiguration {

    @Autowired
    private CustomConfigurationProperties customProperties;
}
```

...and then, you should be able to define settings in your `cas.properties` file such as:

```properties
custom.settingName=some-value
```

...and have them be recognized by `SomethingConfiguration` in all of its inner beans that you shall design and build.

Of course, this is a fair amount of work to get something so seemingly simple done. Let's try to simplify this a bit.

# Custom Properties: Take #2

Starting with CAS `5.3.x`, a new `cas.custom.properties` namespace is introduced that is able to own all arbitrary settings. An example for this new syntax would be:

```properties
cas.custom.properties.customPropertyName1=customPropertyValue1
cas.custom.properties.customPropertyName2=customPropertyValue2
cas.custom.properties.customPropertyName3=customPropertyValue3
```

...that is to say, you can substitute anything you prefer for the customized property name and values.

Additionally, all CAS-owned properties including the `custom` namespace of course are now accessible in CAS views and templates such that one is able to do:

```html
<p th:text="${casProperties.custom.properties.customPropertyName1}" />
```

...or:

```html
<p th:text="${casProperties.server.name`}" />
```

Of course, note that the above syntax only works for settings that are provided by CAS. If you need access anything that is provided by Spring Boot, such as `server.port` or anything that pretty much does not have the `cas.` prefix, then you need to fall back onto fancier strategies of working with Thymeleaf to access application beans and pull up those settings where needed. Needless to say, that likely is a futile endeavor.

# So...

I hope this review was of some help to you and I am sure that both this post as well as the functionality it attempts to explain can be improved in any number of ways. Please feel free to [engage and contribute](https://apereo.github.io/cas/developer/Contributor-Guidelines.html) as best as you can.

Happy Coding,

[Misagh Moayyed](https://twitter.com/misagh84)
