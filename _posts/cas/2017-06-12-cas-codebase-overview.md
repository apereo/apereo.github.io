---
layout:     post
title:      CAS Codebase Overview
summary:    An overview of the CAS codebase organization and layout in which I also dig into the rationale behind project's efforts on modularization and code decomposition. 
tags:       [CAS]
---

Over the past couple of weeks, I have received a lot of positive feedback on CAS codebase organization and management. This blog post attempts to provide an overview of the current codebase status and offers to explain the supporting rationale and the decisions made to cleanup, break down and decompose the monolithic structure of the CAS project whose latest release as of today is [available here](https://github.com/apereo/cas/releases/tag/v5.1.0).

# The 1000-Foot View

If you were to clone [the CAS project on Github](https://github.com/apereo/cas/) and count the provided subprojects, as of this writing you might see something like the following snippet:

```bash
> cd cas-server
> gradlew projects | wc -l
221
```

That's a lot of projects! How is this managed and who can make sense of this beast?

At a very high-level, the project is broken into the following categories:

| Module        | Description                                                                                        |
| ------------- | -------------------------------------------------------------------------------------------------- |
| `api`         | CAS APIs that generically define the outline of a given behavior, such as authentication.          |
| `core`        | Implementations of said APIs. The presence of *almost everything* under this category is absolutely required for the CAS runtime to function correctly.  |
| `docker`      | Build configuration for automatic builds invoked by [Docker Cloud](https://cloud.docker.com/).     |
| `docs`        | [Project documentation](https://apereo.github.io/cas) artifacts managed by [Github Pages](https://pages.github.com/).     |
| `etc`         | Miscellaneous configuration files used by the build or the documentation site.                     |
| `gradle`      | Houses [the gradle wrapper](https://docs.gradle.org/current/userguide/gradle_wrapper.html) used for internal builds.   |
| `style`       | Guidelines and rules enforced and consumed by project's various static analysis checkers, such as Checkstyle and Findbugs.   |
| `support`     | Extensions that enrich one's CAS experience with lots and lots of functionality and integrations. (i.e. LDAP, MFA, etc)      |
| `travis`      | Configuration artifacts used by [Travis CI](travis-ci.org/apereo/cas/builds).          |
| `webapp-mgmt` | Artifacts that pertain to the configuration and deployment of the [CAS Service Management Web Application](https://apereo.github.io/cas/5.1.x/installation/Installing-ServicesMgmt-Webapp.html).           |
| `webapp`      | Artifacts that pertain to the deployment of the core CAS web application and its many sisters.     |

As you drill into each category, you are presented with a hierarchy and a naming scheme that intends to explain what each project folder is all about. Note that the above organization is not only rather *pleasing* to the eye, but it also tries to reduce the initial *scare factor* to some degree. All visitors, friend and foe alike, who happen to step into the project space on Github are not immediately greeted with a structure that demonstrates 221+ things, forcing them to endlessly scroll downward to finally get to the actual `README.md` file. So, this model is a representation of the project's organization and essential components, gently and without risk to gradually boil the proverbial frog and get one acclimated for contributions.

After all, that is what we want we to do. 

# No Feature Left Behind

Core CAS components aside, there are a lot of other individual modules (i.e. `JAR` artifacts) which act as support modules or more accurately put, *intentions*. What is that about?

In order to ease the maintenance burden of both code and documentation and to create a sustainable development environment for the project to grow and keep up with the times and additions of new [more complicated] features (i.e. multifactor authentication), CAS 5 took an orthogonal approach where most if not all CAS features are [automatically configured](https://apereo.github.io/2017/02/21/cas-autocfg-strategy/) by CAS itself, given deployer’s consent, relieving the deployer from having to deal with manual configuration. This is a model referred to as **Intention-driven configuration**.

Each support module essentially focuses on a single feature or intention or a particular variation of one. It latches onto the runtime and does what it should, inserting itself in all the right places dynamically in order to provide the intended functionality in an automated way. It's nice that one can fiddle with a variety of configuration files to make something work. It's a whole lot better though ambitious to *automate once, run everywhere*.

Modules are super cheap and modest. Sometimes they only provide the necessary dependencies to provide functionality. Sometimes they provide a specific implementation for an existing feature, such as the ability to store device registrations into a relational database during multifactor authentication flows. Sometimes they actually provide essential functionality, such as multifactor authentication support via Google Authenticator.

Whatever it may be, the question ultimately for the deployer is:

> I intend to do X with the software and there is a module that lets me.

You want the feature? Drop the module in and it does stuff. You don't want the feature? Remove the module and it will stop doing that. 
Is it perfect? Surely not, but it should be THAT simple.

<div class="alert alert-info">
<strong>Not OSGi</strong><br/>The project structure might seemingly have you suppose that this all somehow stemmed from or was inspired by OSGi principals. While that claim is not entirely false, you should know that CAS today does [and has] nothing to do with OSGi.
</div>

# Delete: Such Joy

One of the more important advantages of such decomposition is that it allows one to write code that is very easy, nay, a joy to delete. If the configuration and logic of a given behavior are all housed inside a subproject, you should be able to press delete at any given time without causing mass chaos in other parts of the codebase. This is the concept of encapsulation and self-containment. With proper design and organization, removing cruft should be as easy as striking the appropriate key on the keyboard.

# Challenges

Of course, not everything is peachy all the time. There are a number of concerns that one needs to take into account. Summarily, here are a few:

## Circular Dependencies

As the codebase is broken apart, it will slowly become apparent that certain modules require a dependency on other modules. If not done carefully, these relationships very quickly turn into an unending cat-and-mouse game. Tread lightly.

## When Enough Is Enough

In certain literatures, it is argued that managing one big thing is much easier, conceptually, than managing 100 small things. That's not entirely false. It, decomposition, requires not only skill and command but also capacity, availability and self-control. All good things are usually done in moderation; so do not overdo. The boundaries of where one module stops and another begins should be designed and apparent at reasonable granular levels and no more, where you decide what *reasonable* and *granular* mean.

## Talk Is Cheap; Show Me The Code

> Don't suggest code improvements. Code your suggested improvements.

Remember that nothing is perfect; Improve and iterate as often as possible. There will always be better ways. There will always be better ideas. Jot them down and encourage friend and foe to starting executing on such ideas rather than merely suggesting them.

# So...

I hope this brief overview was of some assistance to you. If you happen to come across other ideas and innovative solutions that would make all our CAS lives easier, by all means and without hesitation, [please get involved](https://apereo.github.io/cas/developer/Contributor-Guidelines.html).

[Misagh Moayyed](https://fawnoos.com)
