---
layout:     post
title:      Apereo CAS is now on Develocity
summary:    An overview of how Apereo CAS is using Gradle and Develocity to improve its build and test execution cycle.
tags:       [CAS]
---

[Apereo CAS](https://github.com/apereo/cas) is free and open-source software published under the Apache v2 license, built primarily on the Java platform and uses [the Gradle build tool](https://gradle.com/) extensively for its builds, tests, releases, deployments and more.

CAS is now relying on Develocity to improve build and test feedback cycle times. The [Apereo CAS Develocity instance](https://develocity.apereo.org/) is completely public and provides the project with a dashboard to analyze build scans as well as powerful build caching techniques making both CI and local builds extremely fast and efficient.

Furthermore, CAS has also turned on Develocity's [Predictive Test Selection](https://develocity.apereo.org/scans/test-selection) features for all of its unit tests. This is a superb Develocity feature that saves testing time by identifying, prioritizing, and running only tests that are likely to provide useful feedback during test runs.

## How did we get here?

Gradle accepts and supports select open-source projects with **FREE** instances of Develocity. I had applied to the program a WHILE ago and was pleasantly surprised to hear back from Gradle with the good news that CAS was accepted into the project. Over a few months and a series of sessions, I worked with Gradle solution engineers, [Gasper Kojek](https://github.com/ribafish) and [Nelson Osacky](https://github.com/runningcode) to evaluate the CAS codebase, its integration with Gradle and various build plugins and ways it could be optimized. 

Our primary tool to identify and fix inefficiencies in the CAS Gradle build was to complete a series of [build validation exercises](https://github.com/gradle/gradle-enterprise-build-validation-scripts/blob/main/Gradle.md). These experiments come in the form of dedicated scripts that were run against the CAS codebase where each run published build scans for us to analyze, review, and improve. Throughout the experiments, we tried to optimize the CAS Gradle build for:

1. ... incremental builds when invoked from the same location.
2. ... local build caching when invoked from the same location.
3. ... local build caching when invoked from different locations.
4. ... remote build caching when invoked from different CI agents.
5. ... remote build caching when invoked on CI agent and local machine.

One interesting challenge with the CAS codebase is that tests backed by JUnit are split up into many different test categories, across many many subprojects. Initially, the experiments only were run using a handful of relevant test categories and as issues were identified and fixed, we expanded the coverage to more test categories.

Fixes applied to the CAS codebase mainly include:

- removal of absolute paths.
- making sure build tasks define their inputs and outputs correctly.
- removing dynamic values, system/environment variables from the build to remove cache invalidation.
- removal of non-deterministic native image JSON hints, fixed by the [Spring team](https://github.com/spring-projects/spring-framework/issues/31852).

Overall, the CAS build is now healthier and more predictable.

## Predictive Test Selection

Develocity also offers fantastic [Predictive Test Selection](https://develocity.apereo.org/scans/test-selection) features and this is now turned on for all CAS test categories. As was indicated earlier, this feature saves testing time by identifying and running only tests that are likely to provide useful feedback and Develocity accomplishes this by applying a machine learning model that uniquely incorporates fine-grained code snapshots, comprehensive test analytics, and flaky test data. More build data and runs would allow the machine learning model to improve its prediction engine and offer better decisions as time goes on. To accommodate this better and reduce the chance of incorrect predictions and accidental slip-ups, CAS will also run its suite of unit tests using a fixed schedule with predictive test selection disabled.

This capability is proving to be extremely valuable in cutting down test execution time and therefore resulting in a quicker feedback loop. You can evaluate the data produced by simulations and actual usage to get an idea of the serial test time saved. 

## Credits

I want to thank Gradle for their commitment to supporting open-source and for providing Apereo CAS with a **FREE** Develocity instance. The series of improvements that were identified via the Develicity instance and build scan results were quite impressive and educational, and certainly allowed the project to build, fix, and release more efficiently. This is excellent news for developers, contributors, and users of the software.

I am also thankful for [Gasper](https://github.com/ribafish) and [Nelson's](https://github.com/runningcode) time and expertise in our sessions together. They were quite helpful and patient with me, explained every topic and technical challenge in great detail, followed up and responded to my comments and questions super quickly and even got hands-on and contributed a few fixes to the CAS project itself! You guys rock! 

[Misagh Moayyed](https://fawnoos.com)