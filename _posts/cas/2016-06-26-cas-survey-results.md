---
layout:     post
title:      CAS Survey Results
summary:    ...in which I present a summarized view of the latest CAS community survey and discuss results.
categories: cas
date:       2016-04-19 12:32:18
---

A [while ago](https://groups.google.com/a/apereo.org/forum/#!searchin/cas-user/survey/cas-user/vQr3eBdHNg8/eKm9gkpxIwAJ) the CAS project management committee prepared a [survey](http://goo.gl/forms/rF9EeCN6GH) to help plan the future roadmap of the project. The primary objectives of the survey were to gain a better understanding of the current configuration pain points from a deployer point of view and learn what additional features and enhancements should have to be prioritized for development.

In this post, I intend to provide a summarized view of the survey results and discuss what has or will be done to address the feedback.

# Results

There were about 200 responses to the survey from both individuals and institutions. Some responses were submitted by consulting firms who provide CAS commercial services for their clients which indicates the actual number of deployers may be larger than the reported 200.

Participants of the survey indicated that on average, they have been running CAS for more than 10 years in a variety of industry sectors such as Government, Higher-Ed, Insurance, Finance, Travel and Health. More than 50% of the results indicated a CAS server deployment size of more than 10K users which is considered a rather large deployment of the platform.

The table below demonstrates what percentage of the community has chosen a given form of primary authentication:


| Method  | Adoption |
| ------------- | ------------- |
| LDAP/AD | 82% |
| RDBMS  | 8%  |
| Other  | 10%  |

The "Other" category being: NoSQL, X509, Rest, Social AuthN and many other forms of authentication supported by CAS.

## CAS Version

The table below shows what percentage of the community is using a given CAS server version.

| Version  | Adoption |
| ------------- | ------------- |
| 3.x  | 53% |
| 4.0.x  | 22%  |
| 4.1.x  | 14%  |
| 4.2.x  | 4%  |
| Other  | 7%  |

It's important to note that CAS 3.x has been EOLed for almost 2 years. What this means is that CAS 3.x will no longer be maintained, fixed or (in case of security vulnerabilities) patched by the development team. Therefor, it is strongly recommended that those deployments switch and upgrade to a more recent and stable version of the platform, which at the time of this writing is CAS 4.2.x.

## Features

Survey participants were also asked to vote on a number of proposed features on a 1-5 scale with 5 being most desirable. The following table shows an aggregated view of the results for each given feature where the adoption percentage is a summary of category 4 and 5 response types, indicating  development should strongly focus on the completion or improvement of the proposed item.

| Feature  | Vote |
| ------------- | ------------- |
| Admin UIs  | 60%  |
| SAML2  | 60%  |
| MFA  | 52% |
| Surrogate AuthN  | 43%  |
| Adaptive AuthN  | 42%  |
| Rest APIs  | 40%  |
| GUI Wizard  | 33%  |
| Front-Channel SLO  | 33%  |
| WS-Fed  | 31%  |
| OIDC  | 29%  |
| OAuth2  | 28%  |
| FIDO  | 16%  |
| Dynamic Registration  | 11%  |


## Additional Feedback

The following items were also reported by the community as areas that require improvement and clarification:

### Better Documentation

The current CAS documentation assumes a high degree of familiarity with deployment tools such as Maven, Tomcat/Jetty, etc. The adopter also at times has to deal with multiple XML configuration files for enabling features such as LDAP authentication. This presents varying degrees of difficulty for a novice deployer to quickly get started with a CAS deployment. Step-by-step installation instructions, more samples and clarity in the documentation when it comes to dealing with specific CAS modules and features would be strongly desirable. A non-Maven deployment strategy could also be devised to relieve some of that pain when it comes to managing dependencies and CAS artifacts.

### Easier Upgrades

The current CAS deployment strategy consists of [constructing a Maven overlay](https://github.com/apereo/cas-overlay-template) in order to combine and merge local customizations with the original CAS distribution. This at times can morph into a complicated CAS upgrade process, specially if local customizations end up at odd conflicts with the new CAS distribution. Adopters are invariably forced to compare locally overlaid artifacts with their original version and fill in the gaps where necessary. Needless to say, this process for a novice deployer is less than obvious to understand and utilize.

### Other Features

A number of other features were requested by participants that were not part of proposed scope. These included:

1. JWT authentication
2. Integrated Password Management
3. Tracking and Geo-profiling authentication requests.
4. Other registry types for managing CAS tickets and service definitions, such as YAML, Redis, ZeroMQ, etc.

# Response

The CAS development team has been working on the next major release of the platform, that is 5.0.0. Taking into account the community survey and feedback, here are a few notes to help clarify how CAS 5 attempts to address some of the reported issues.

Before we get started, it should be pointed out that [early milestone releases of CAS 5 are available](https://github.com/apereo/cas-overlay-template/tree/5.0). Deployers are more than welcome to try out the milestone releases and share feedback.

The current in-development documentation of CAS 5 is also [available here](https://apereo.github.io/cas/development/index.html).

## Features

### Core

CAS 5 will have built-in support for:

- [MFA](https://apereo.github.io/cas/development/installation/Configuring-Multifactor-Authentication.html) based on Duo Security, Google Authenticator and more.
- [SAML2 authentication](https://apereo.github.io/cas/development/installation/Configuring-SAML2-Authentication.html), acting as an identity provider consuming and producing SAML metadata.
- [OpenID Connect](https://apereo.github.io/cas/development/installation/OIDC-Authentication.html), acting as an OP producing claims for RPs.
- A YAML-based service registry.
- Delegating authentication to a remote REST endpoint.
- Recording and Geotracking authentication events.

Since CAS 4.2.x, the platform has supported:

- [JWT authentication](https://apereo.github.io/cas/4.2.x/installation/JWT-Authentication.html).
- [Delegating authentication](https://apereo.github.io/cas/4.2.x/integration/Delegate-Authentication.html) to [ADFS](https://apereo.github.io/cas/4.2.x/integration/ADFS-Integration.html), CAS, SAML2 IdPs and a large variety of social authentication providers such as Facebook, Twitter and more.
- Ticket registry implementations based on [Redis and Apache Cassandra](https://apereo.github.io/cas/4.2.x/installation/Infinispan-Ticket-Registry.html).

### Auto Configuration

Loudly pointed out by the survey, a much-needed overhaul of the CAS documentation is needed to enable configuration of CAS features in a more intuitive and sustainable way. To address this issue, CAS 5 takes an orthogonal approach where most if not all CAS features are **automatically configured** by CAS itself, given deployer's consent, relieving the deployer from having to deal with XML configuration. This is a model we refer to as **Intention-driven configuration**.

In the past in order to turn on a particular CAS feature, the adopter had to:

- Find and declare the module as a dependency
- Fiddle with a variety of XML configuration files to declare components
- Touch a few properties and settings supplying the appropriate values for those components.
- Repackage and redeploy.

This process was much prone to errors and at times had to be repeated over and over again until the final works was in place. It also was extremely dependent on an accurate and reasonably detailed and clear documentation. It goes without saying that sustaining this model of development and configuration presents a high degree of difficulty for maintainers of the project and adopters of the platform.

To remove some of this pain, CAS 5 presents the following approach to the deployer:

- Find and declare the feature module as a dependency, thus **announcing your intention** of enabling a particular feature in CAS.
- **Optionally**, configure the module by supplying settings via a simple `.properties` file.


At deployment time, CAS will auto-determine every single change that is required for the functionality of declared modules and will auto-configure it all in order to remove the extra XML configuration pain. This is a strategy that is put into place for nearly **ALL** modules and features.

This strategy helps with the documentation noise as well to a large degree because there is no longer a need to document every single XML configuration file and change required for each module for a given needed feature. The CAS 5 platform starts to have very low expectations of the adopter in terms of learning its internals and different configuration mechanics. Simply declaring an intention and optionally configuring it should be more than sufficient.

This strategy also greatly assists with future upgrades because there would be very few, if any, local configuration files lying around in a deployment environment. The adopter should mostly care about the appropriate settings and values supplied to CAS that describe the core intended business functionality desired.

As an example, in order to configure LDAP authentication, all an adopter has to do is **declare his/her intention**:

```xml
<dependency>
     <groupId>org.apereo.cas</groupId>
     <artifactId>cas-server-support-ldap</artifactId>
     <version>${cas.version}</version>
</dependency>
```

...and **declare the relevant settings**:

```xml
...
# cas.authn.ldap[0].ldapUrl=ldaps://ldap1.example.edu,...
# cas.authn.ldap[0].baseDn=dc=example,dc=org
# cas.authn.ldap[0].userFilter=cn={user}
# cas.authn.ldap[0].bindDn=cn=Directory Manager,dc=example,dc=org
# cas.authn.ldap[0].bindCredential=Password
...
```

That's all. There is no other change required.

This model would not have been possible without CAS taking full advantage of [Spring Boot](http://projects.spring.io/spring-boot/).

Note that auto configuration of modules not only takes into account core what-used-to-be XML configuration but also any additions that may be required for the CAS webflows.

Note that CAS 5 does not remove one's ability to declare relevant changes and customizations in an XML file. There will be a `deployerConfigContext.xml` file, much like the old days, for those who feel more comfortable with an XML-friendly explicit form of configuration. However, for most if not ALL changes this strategy is completely unnecessary.

### Managing Configuration

Previously, adopters had to repackage and redeploy the CAS web application if a configuration property (i.e. LDAP URL) had to be changed. This will no longer be true in CAS 5 where **most if not ALL** CAS components become reloadable. What this means is, specific endpoints (and administrative UIs) are exposed to adopters which can receive a reload request (permissions granting) and auto-configure the running CAS application context with the new state of the world WITHOUT the need to repackage and/or deploy the CAS software.

This model would not have been possible without CAS taking full advantage of [Spring Cloud](http://projects.spring.io/spring-cloud/).

To learn more about how CAS manages the deployer configuration, particularly in a clustered environment, please [review this page](http://unicon.github.io/cas/development/installation/Configuration-Management.html).

### Deployment

Once packaged, adopters previously had to grab the final CAS web application and deploy it into a servlet container of choice such as Tomcat or Jetty. While this model is and will be supported, CAS 5 takes this one step further and ships with a built-in Tomcat container that can simply launch the CAS application directly from the command line. The recipe is as simple as:

```bash
...
mvn clean package
java -jar target/cas.war

...

  __  ____     _     ____  __
 / / / ___|   / \   / ___| \ \
| | | |      / _ \  \___ \  | |
| | | |___  / ___ \  ___) | | |
| |  \____|/_/   \_\|____/  | |
 \_\                       /_/

CAS Version: 5.0.0.M3-SNAPSHOT
Build Date/Time: 2016-06-26T20:55:15.345Z
Java Home: C:\Program Files\Java\jdk1.8.0_92\jre
Java Vendor: Oracle Corporation
Java Version: 1.8.0_92
OS Architecture: amd64
OS Name: Windows 10
OS Version: 10.0
...
```

Every attempt has been made to ensure every aspect of the built-in Tomcat container (such as SSL, context path, etc) is configurable via the same `.properties` file that houses all other CAS configuration.

Built-in containers are also available, optionally, for Jetty and Undertow.

### User Interfaces

CAS 5 starts use to use [Thymeleaf](http://www.thymeleaf.org/) as a rendering engine for its user interfaces. Thymeleaf's main goal is to bring elegant natural templates to your development workflow — HTML that can be correctly displayed in browsers.

The old JSP model required adopters to test out UI-related changes directly inside a running servlet container such as Tomcat. Thymeleaf allows CAS to present HTML-native pages that can easily be viewed in the browser without requiring an underlying container engine.

CAS 5 also attempts to improve the user experience for the administrator in a cloud-friendly manner. There are many administrative control panels that expose insight into the running CAS software. The screens report back on the health of the running CAS server, various configuration options and status of active SSO sessions, etc. There is also additional upcoming work to further improve these control panels, allowing the adopter to monitor and configure logs, adjust CAS settings and manage SSO sessions more effectively without resorting access to the native command-line.

Of course if you wish, you can always resort back to the command-line if you wish to manually hand-massage the configuration.

Here are a few screenshots of the new CAS 5 user interfaces:

<div align="center">
<blockquote class="imgur-embed-pub" lang="en" data-id="a/6uq4s"><a href="//imgur.com/a/6uq4s">View post on imgur.com</a></blockquote><script async src="//s.imgur.com/min/embed.js" charset="utf-8"></script>
</div>

# What's Next?

The development team is working hard to make sure the CAS 5 release is right on [schedule](https://github.com/apereo/cas/milestones).

For the time being, CAS 4.1.x and 4.2.x release lines will be maintained by the development team. However, the primary development focus and time will be dedicated to CAS 5, addressing bugs and extending the platform to be a more comfortable experience specially for some of the brand new features presented in this release.

# How can you help?

- Start your early [CAS 5 deployment](https://github.com/apereo/cas-overlay-template/tree/5.0) today. Try out features and [share feedback](https://apereo.github.io/cas/Mailing-Lists.html).
- Better yet, [contribute patches](https://apereo.github.io/cas/developer/Contributor-Guidelines.html).
- Review and suggest documentation improvements.


# Das Ende

I would like to thank all survey participants. None of this would have been possible without your engagement and involvement in a vibrant community.

Thank you for sharing. Thank you very much for all the kind words.

On behalf of the CAS project,

[Misagh Moayyed](https://twitter.com/misagh84)
