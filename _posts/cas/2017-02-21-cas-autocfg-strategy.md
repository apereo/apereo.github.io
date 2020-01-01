---
layout:     post
title:      Intro To CAS Auto Configuration Strategy
summary:    A short and painless introduction into how CAS uses Spring Boot to tickle the runtime conditionally.
tags:       [CAS]
---

> The post specifically applies to CAS 5.1.x which, as of this writing today, is still in development.

If you scan the recent literature on [CAS configuration model and strategy](https://apereo.github.io/cas/development/installation/Configuration-Management.html#auto-configuration-strategy), you would notice that there is a great amount of emphasis on letting CAS modules dynamically alter the application context at runtime to activate features, massage webflow definitions and move settings around without asking for a whole lot of manual input.

How does this all work?

# Java-based Configuration

Given CAS' adoption of [Spring Boot](https://github.com/spring-projects/spring-boot), most if not all of the old XML configuration is transformed into `@Configuration` components. These are classes declared by each relevant module that are automatically picked up at runtime whose job is to declare and configure beans and register them into the application context. Another way of thinking about it is, components that are decorated with `@Configuration` are loose equivalents of old XML configuration files that are highly organized where `<bean>` tags are translated to java methods tagged with `@Bean` and configured dynamically.

Sidestepping irrelevant details, here is an example:

```java
package org.apereo.cas.config;

@Configuration("casCoreMonitorConfiguration")
public class CasCoreMonitorConfiguration {

    @ConditionalOnMissingBean(name = "healthCheckMonitor")
    @Bean
    public Monitor healthCheckMonitor() {
        final List<Monitor> monitors = new ArrayList<>();

        // Add monitors to the list as needed dynamically

        return new HealthCheckMonitor(monitors);
    }
}
```

The above done in XML form manually in a `monitors-configuration.xml` file
would roughly translate into the following:

```xml
<bean id="healthCheckMonitor" class="org.apereo.cas.monitor.HealthCheckMonitor">
    <property name="monitors">
      <list>
        <!-- Add monitors to the list as needed dynamically. -->
      </list>
    </property>
</bean>
```

# `@Configuration` Registration

How are `@Configuration` components picked up? Each CAS module declares its set of configuration components as such, [per guidelines laid out by Spring Boot](http://docs.spring.io/spring-boot/docs/current/reference/html/boot-features-developing-auto-configuration.html):

- Create a `src/main/resources/META-INF/spring.factories` file
- Add the following into the file:

```properties
org.springframework.boot.autoconfigure.EnableAutoConfiguration=\
org.apereo.cas.config.CasCoreMonitorConfiguration
```

The above done in XML form would roughly translate into the following:

```xml
<import resource="monitors-configuration.xml"/>
```

Note that the you can use the same exact technique in CAS overlays to register your own configuration components, or remove/disable CAS' auto-configuration strategy. For instance, if you prefer to not let CAS bootstrap its monitoring configuration automatically, you can remove it from the registration process in the `application.properties` file:

```properties
spring.autoconfigure.exclude=org.apereo.cas.config.CasCoreMonitorConfiguration
```

# Overrides and `@Conditional`

What if you needed to override the definition of that `healthCheckMonitor` bean to add/remove monitors? Or perhaps entirely remove and disable it? This is where `@Conditional` components come to aid. Most component/bean definitions in CAS are registered with some form of `@Conditional` tag that indicates to the bootstrapping process to ignore them, if *a bean definition with the same id* is already defined. This means you can create your own configuration class, register it and the design a `@Bean` definition only to have the context utilize yours rather than what ships with CAS by default:

```java
package org.custom.mine.config;

@Configuration("MyOwnMonitorConfiguration")
public class MyOwnMonitorConfiguration {

    @Bean
    public Monitor healthCheckMonitor() {
        final List<Monitor> monitors = new ArrayList<>();

        // Do what you will to replace the provided CAS monitor.

        return new HealthCheckMonitor(monitors);
    }
}
```

Make sure your component is registered:

```properties
org.springframework.boot.autoconfigure.EnableAutoConfiguration=\
org.custom.mind.config.MyOwnMonitorConfiguration
```

The trick here is, in order to override a bean definition, you need to know its name as your own structure identified by the method name must *exactly* match that of CAS or the process fails. This is where you look into the CAS source code to learn about various beans, etc.

I *strongly* advise against making this sort of change, unless absolutely warranted and reasonable (To learn why, please read on).

# What Else?

- Your `@Bean` definitions can also be tagged with `@RefreshScope` to become auto-reloadable when the CAS context is refreshed as a result of an external property change.
- `@Configuration` classes can be assigned an order with `@Order(1234)` which would place them in an ordered queue waiting to be loaded in that sequence.
- To be more explicit, `@Configuration` classes can also be loaded exactly before/after another `@Configuration` component with `@AutoConfigureBefore` or `@AutoConfigureAfter` tags and annotations.


# Why Spring Boot?

That is a fair question; Why prefer a Java-based configuration model over XML. Isn't XML, by intention and definition, more extensible and easier to modify and tweak? Why should you have to write Java-code to extend and modify the context?

There are several advantages to this model.

## Compiled

Often times when you build the CAS application package via Maven or Gradle, the build process simply outputs `BUILD SUCCESS` at the end somehow tricking you into thinking "Great! My changes are going to work." where in fact that may be entirely false. All that message tells you is that the build tool was able to assemble and package a bunch of configuration files and form a binary archive at the end. The output is going to be all the same, even if you had a typo in the configuration, a missing tag or a bad configuration piece. Also, if a new CAS version decides [for whatever reason] to move that `HealthCheckMonitor` from `org.apereo.cas.monitor` into `org.apereo.cas.monitors` or even rename it to something else, then you end up with a broken configuration when you upgrade. Why? Because it's exactly that; just configuration. A small piece of fragmented code that tells the application how to behave a tad too late in the deployment lifecycle.

Java-based configuration components are the exact opposite. They are *source code*. They compile. Any typos, mistakes or repackaging of the components will immediately stop the build from succeeding.

Think of it this way; if you are designing the electrical system of a building:

- Would you prefer the wiring system stop you from making potentially fatal mistakes as you attempt to connect the cables and wires together?
- Or would you prefer to do the whole thing in one go, turn on the lights, have the entire building blow up only to (possibly, maybe) succeed later after a few more iterations?

## Automated

The above note really may not be all that attractive, unless you start to consider that Java-based configuration components can entirely automate the behavior of the application. They can be done once and for all, with small modest options here and there to tweak certain aspects of the feature, and then can ship with the application as first-class citizens only to be activated conditionally at deployer's command. They are not affected by trivial mistakes, copy-paste errors, maintenance burdens and steep learning curves.

XML is a terribly poor choice as a programming language to automate configuration conditionally. If you were asked to turn on and configure a few different features in the application:

- Would you prefer to go to your build script, declare feature modules, tweak settings and run?
- Or would you prefer to go to the documentation, copy various [and large] pieces of XML fragments into [perhaps many] configuration files, build and run, trusting that the documentation is accurate for the deployment version, hoping that it all works so you don't have to understand what a `<bean>` is, praying you haven't fat fingered an ending XML tag?

## Self-Documented

The best advantage of configuration automation is that it removes the amount of boilerplate documentation one may have to apply or maintain. There is no longer a need to look after various XML fragments in the documentation, maintain and update them or try to verbosely explain their behavior and function in tutorials and guides [and thus duplicating what Spring or Spring Webflow may have already done in their own documentation!]. The technical details of how Spring or Spring Webflow or LDAP/JDBC libraries work have been abstracted away into what is now commonly referred to as *Intentions*.

To see this in action, see the contents of [this page](https://apereo.github.io/cas/4.1.x/installation/OAuth-OpenId-Authentication.html#add-the-oauth20wrappercontroller) and compare with [this page](https://apereo.github.io/cas/development/installation/OAuth-OpenId-Authentication.html#configuration). The former expects a lot more from the deployer while the latter simply translates a deployer's intention into a small feature module/plugin. As a result, the documentation tends to get a lot more focused and compact.

## Modernized

It would not be unfair to say that that CAS 3.x software, released almost over a decade ago, laid down the sweet architectural foundations for an open and extensible platform with flexible APIs and outlined public injection points. At the time, using technologies such as Spring, JSP and Spring Webflow were superbly attractive and significantly useful in allowing adopters to modify the platform decoratively and extend it programmatically. As a result, many extensions and add-ons and customizations flourished into existence based on the CAS 3.x platform, making the software that much more attractive [and perhaps more complicated to reason about] for adopters' evaluation.

Now a decade later, the CAS software has revitalized its roots and designs to ensure it can keep up with today's demands and resources and future's solid and stable technical trends. To that end, Spring Boot is simply the best choice available as a flexible and modern albeit opinionated platform on top of which CAS can continue to grow. With the shift towards cloud-friendly micro-services and such, CAS needed to stay on top of its game by allowing deployments to be [self-contained and self-sufficient](https://12factor.net/) by employing technologies such as Spring Boot, [Spring Cloud](http://projects.spring.io/spring-cloud/), Thymeleaf and such so development and maintenance could sustain given project's resources and team availabilities and with the presence of more complicated use cases such as [MFA](https://apereo.github.io/cas/development/installation/Configuring-Multifactor-Authentication.html), etc.

# Why Not?

There are of course many difficulties and challenges inherent in this model as well, especially if you are new to Spring Boot and have an existing background with XML-based configuration.

## Learning Curve

There is undoubtedly a learning curve here both for deployers and developers. Deployers who are used to the copy-paste XML configuration model may find the auto-configuration magic way too confusing and black-boxish while developers may find the same process to be composed of many moving and puzzling parts.

## Documentation

One could argue that XML-based configuration given its explicit nature could be reasoned about easier where injections of properties and settings into XML beans and such could be more comfortably understood and then tweaked. This is perfectly true that while the documentation has removed the boilerplate fragments needed to activate features, there is still *a most definitive need* to document and explain away [all the settings](https://apereo.github.io/cas/development/installation/Configuration-Properties.html) that activate and control behavior in CAS. The strategy certainly is not to downplay the importance of good documentation and guides; it's to only highlight what is absolutely expected of the adopter to keep around and maintain in local deployments.

It's also evident that producing good documentation is very much a time-consuming and delicate process, given various levels of technical expertise and skill. It takes time as the platform is still very very young. So by all means, [feel free to contribute](https://apereo.github.io/cas/developer/Contributor-Guidelines.html).

## Customizations

The XML configuration was right in front of you, right? All you had to do was to change an element here and a property there and you were done. It’s quite true that the old model provides easier flexibility though perhaps at the cost of complexity as the platform grows larger.

It should be noticed that the ability to configure the CAS application context via XML is *not removed*. There still exists a `deployerConfigContext.xml` that may be of assistance for truly special and customized needs and requirements. However, most everything is translated into auto-configuration modules with a specific set of externalized properties and settings that control behavior.

So what do you do if you wanted to code an extension, or plug in a component/setting to modify behavior? The following options come to mind:

-    [Talk to the project](https://apereo.github.io/cas/Support.html). Discuss use cases and requirements, [open up issues]( https://github.com/apereo/cas) and better yet [contribute patches and pull requests]( https://apereo.github.io/cas/developer/Contributor-Guidelines.html) to see your change become a first-class feature of the CAS product rather than something you specially have to control, maintain, document, teach and then understand.

-    If the use case you have in mind truly applies to your own specific workflows and integration strategies, your best option is to *not* try to find a way based on the old XML-based configuration model to shoehorn your changes into CAS. That will simply result into long-term disastrous results. Follow the same pattern discussed here. If you find anything that is missing or have suggestions for things that need to be improved or made conditional to make extensions easier, discuss those with the project and contribute back. Write the code where it belongs.
 
If none of those options appeal to you, it’s likely that you may be heavily disappointed with the CAS software.

# So...

I hope this brief tutorial was of some assistance to you. If you have other suggestions for content and material or have questions about this particular post here, please get in touch.

[Misagh Moayyed](https://fawnoos.com)
