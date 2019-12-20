---
layout:     post
title:      Apereo CAS - Managing Configuration Metadata
summary:    Learn how to manage CAS configuration and properties using Spring Boot Configuration metadata.
tags:       [CAS]
---

<div class="alert alert-success">
<strong>Collaborate</strong><br/>This blog is managed and hosted on GitHub. If you wish to update the contents of this post or if you have found an inaccuracy and wish to make corrections, we recommend that you please submit a pull request to <a href="https://github.com/apereo/apereo.github.io">this repository</a>.
</div>

# Overview

Based on the results of the most recent [CAS Survey](https://apereo.github.io/2019/10/09/cas-survey-results2019/) and the many conversations I have had throughout the years
with CAS deployers, one item that is frequently debated and requested from the project is better documentation especially around CAS settings and properties. In this blog
post, I am going to demonstrate a few ways where one can query the CAS documentation to look up settings, review notes, examine default values, etc.

# Foreword

Let's address the obvious question:

> Why isn't every single setting and property documented on the project website?

Simply put, 

- The project does not sufficient resources, time and energy to manage and maintain a large body of configuration settings *manually* over a long period of time and take care of their maintenance as progress is made. Doing this would mean that every single CAS setting, along with notes and explanations, would 
not only be equipped with adequate javadocs, but also would be *duplicated* in the project documentation, in the installation script 
and overlays, and possibly a few other places for this effort to truly be comprehensive. *Duplication is baad, mkay?* 
- This process needs to be carefully reviewed, examined and controlled if a setting is removed, renamed or changed in any way, and furthermore, this process would not only have to be supported and followed by the project's core developers, but also by every single contributor with an accompanying patch.
- This process would not only have to be followed for CAS-owned settings, but also for those that are introduced and controlled by 
projects and libraries on which CAS depends. So the maintenance effort would have to be multiplied by any number of libraries that present a certain functionality to CAS. 

Needless to say, manual maintenance efforts and risking inaccuracies and duplications do not make this effort worthwhile. 

# Strategy

There are easier ways to accomplish this if we ditch the traditional approach to documentation and look at this from an API point of view. Every setting, whether owned by CAS or some other library, can and may be controlled by a schema and an API. Things that you generally want to know about a CAS setting are usually available as part of its very definition; type, name, default value, explanation, etc. So, what if there was an API that could allow one to query and list *metadata* 
about a setting, thus making the process much more automated? 

Good question. This is what [Configuration Metadata](https://docs.spring.io/spring-boot/docs/current/reference/html/appendix-configuration-metadata.html) is all about. CAS artifacts include metadata files that provide details of all supported configuration properties. Let's take a look at how they may be used.

Our starting position is based on:

- CAS `6.2.x`
- Java `11`
- [CAS WAR Overlay](https://github.com/apereo/cas-overlay-template)

# Interactive Shell

One approach would be to use the [CAS Command-line Shell](https://apereo.github.io/cas/development/installation/Configuring-Commandline-Shell.html). If you examine the [CAS WAR Overlay](https://github.com/apereo/cas-overlay-template), you will find a Gradle task for running the shell. Let's give it a try:

```bash
gradlew runShell
...
Run the following command to launch the shell:
        java -jar build/libs/cas-server-support-shell-xyz.jar
```    

If you run the command instructed above, you will see the following:

```bash
No active profile set, falling back to default profiles: default
...
Started CasCommandLineShellApplication in 9.151 seconds (JVM running for 11.384)
cas>
```

If you run `help`, you will see a number of CAS shell commands related to properties:

```bash 
CAS Properties
    ...
    find: Look up properties associated with a CAS group/module.
    ...
```  

The `find` command is most interesting. Let's look up properties related to `duo`:

```bash
cas> find --name duo
```      

Let's try the same thing in summary mode:

```bash
cas> find --name duo --summary
```

As you can see, you can query settings or groups of them to look up notes, default values, types, etc for each field. This *documentation* is automatically provided
to you and is available in the overlay.

# Configuration Metadata Report

Another option is to take advantage of the `exportConfigMetadata` task available in [CAS WAR Overlay](https://github.com/apereo/cas-overlay-template). This task
allows you to export collection of CAS properties as a report into a file that can later be examined. Let's try it:

```bash
gradlew exportConfigMetadata

> Task :exportConfigMetadata
Configuration metadata is available at /cas-overlay-template/config-metadata.properties
```

If you examine the produced file, you will find a full list of CAS settings along with notes, types, default and accepted values. You will also see
whether the setting requires a particular module in the build and whether that module is automatically included. There is additional metadata to explain
whether the setting is required and one that is expected to be defined and tweaked by you, or optional with a default value.

<div class="alert alert-success">
<strong>Note</strong><br/>If you really wanted to be creative, you could examine the <code>exportConfigMetadata</code> and observe how it builds the final
report. Then, use the same strategy to dynamically build a web page, a PDF file or a markdown template of all settings.
</div>

Note the report does **NOT** only include settings that are owned and used by CAS but also, others that are controlled and used by other frameworks and libraries
such as Spring Boot, Spring Cloud, etc. Of course, just as before, this *documentation* is too automatically provided to you and is available in the overlay.

# Developer Tooling

Configuration metadata has very good support for most modern integrated development environments, such as eclipse or Intellij IDEA. The environment can
recognize the presence of configuration metadata and assist with tooltips, auto-completion of settings, values and many other related features:

![image](https://user-images.githubusercontent.com/1205228/70863349-ba3b6e80-1f60-11ea-907c-c75008d48d4a.png)

For those who contribute to CAS or build extensions on top of the CAS platform, this is a great tool to assist with fine-tuning of the configuration
compared to chasing settings and notes in docs spread around on the web. The documentation ships with the code and the tooling that supports and recognizes
its schema is readily available.

# Property Migration Reports

Configuration properties that are removed, renamed, etc can always be tracked by the configuration metadata to advertise the change
and provide guidance on replacements. In certain cases, the replacement setting can be automatically applied by CAS with a simple warning to follow-up
if a replacement is indeed available. In other cases, a warning will show up in the logs instructing you to take action and update your configuration
with notes and explanations.

Note that automatic replacements of properties may only take place if they are type-compatible.

Let's say we have the following two settings in our CAS configuration:

```properties     
# This setting can be replaced with its compatible alternative
# automatically, with a warning in the logs
server.context-path=/cas

# There is no compatible replacement property for this setting
cas.service-registry.config.location=file:/etc/cas/config/services  
```      

If you run CAS, the following report in the logs will guide you with instructions:

```bash
WARN [o.s.b.c.p.m.PropertiesMigrationListener] - <
The use of configuration keys that have been renamed was found in the environment:

Property source 'bootstrapProperties':
    Key: server.context-path
        Replacement: server.servlet.context-path
        
Each configuration key has been temporarily mapped to its replacement for your convenience. \
To silence this warning, please update your configuration to use the new keys.
```

...and:

```bash
ERROR [o.s.b.c.p.m.PropertiesMigrationListener] - <
The use of configuration keys that are no longer supported was found in the environment:

Property source 'bootstrapProperties':
    Key: cas.service-registry.config.location
        Reason: Property renamed due to cas.service-registry.json.location instead.


Please refer to the migration guide or reference guide for potential alternatives.
```                                                                               

<div class="alert alert-success">
<strong>Note</strong><br/>It does not matter where the properties come from. As long as the CAS runtime receives a setting,
the validation rules and migration assistance will kick into apply. This assistant is also not limited to CAS-specific properties,
but to <i>every single setting</i> that the CAS runtime can use, regardless of ownership.
</div>

This is a much easier and much more automated version of a transition strategy from one CAS version to the next
and allows for a more comfortable maintenance and adoption experience. No longer should one have to track down detailed
release notes and guides to observe and apply changes. The software takes care of all, if possible, and otherwise issues
appropriate warnings for one to take action.

## Limitations

Configuration metadata, when it comes to migration reports, does not support collection-based settings. For example,
if the original version of a CAS setting is at `cas.something.blah=blah` in one version and its new replacement is transformed
to support multiple `something`s with `cas.something[0].blah=blah` in another version, then this change is usually ignored by the reporter facility
provided by Spring Boot. In such scenarios, you will have check with the project documentation, release notes
or source code to note the correct syntax. 

# Epilogue

The strategies and ideas outlined in this post go as far back 
as CAS [`5.2.x`](https://apereo.github.io/cas/5.2.x/installation/Configuration-Metadata-Repository.html). We have had to carefully 
tune and modify the *configuration metadata generation process* over time and the years to make sure such metadata about settings 
can be recognized, parsed and packed for wider use. We have added on layers and constructs to make sure settings be understood and picked up regardless of their physical 
placement (i.e. inner classes) or complication of type (i.e. enums, collections, etc). In short, while the result is still far from perfect, it is a large improvement
over the manual maintenance tasks previously discussed, given project's availability of resources and funding. 

Now that we have configuration metadata available as an API, there are many other things that can also be automated such as the automatic 
generation of a CAS installation script or overlay perhaps using a graphical user interface in wizard-like fashion. The possibilities are quite exciting!

# Bonus

To see what Gradle tasks are available, run:

 ```bash
gradlew tasks
```

# So...

I hope this review was of some help to you and I am sure that both this post as well as the functionality it attempts to explain can be improved in any number of ways. Please know that all other use cases, scenarios, features, and theories certainly [are possible](https://apereo.github.io/2017/02/18/onthe-theoryof-possibility/) as well. Feel free to [engage and contribute](https://apereo.github.io/cas/developer/Contributor-Guidelines.html) as best as you can.

Finally, if you benefit from Apereo CAS as free and open-source software, we invite you to [join the Apereo Foundation](https://www.apereo.org/content/apereo-membership) and financially support the project at a capacity that best suits your deployment. If you consider your CAS deployment to be a critical part of the identity and access management ecosystem and care about its long-term success and sustainability, this is a viable option to consider.

Happy Coding,

[Misagh Moayyed](https://twitter.com/misagh84)
