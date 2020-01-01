---
layout:     post
title:      Apereo CAS 6.2.x - Building CAS Feature Modules
summary:    An overview of how various CAS features modules today can be changed and tested from the perspective of a CAS contributor working on the codebase itself to handle a feature request, bug fix, etc.
tags:       [CAS]
---

<div class="alert alert-success">
<strong>Collaborate</strong><br/>This blog is managed and hosted on GitHub. If you wish to update the contents of this post or if you have found an inaccuracy and wish to make corrections, we recommend that you please submit a pull request to <a href="https://github.com/apereo/apereo.github.io">this repository</a>.
</div>

# Overview

This quick walkthrough effectively aims for the following objectives:

- A quick development environment setup using IntelliJ IDEA.
- Building and running the CAS web application using Gradle.
- Changing feature modules and testing out behavior.
- Testing changes and writing unit tests.
- Stepping into the code using a debugger.

# Development Environment

Follow the [instructions posted here][buildprocess] to obtain the CAS source code. Remember to indicate the relevant `branch` in the commands indicated to obtain the right source code for the CAS version at hand. In this tutorial and just like before, the branch to use would be `6.0.x` (at the time of writing this post, the appropriate branch is `master`).

To understand what branches are available, [see this link](https://github.com/apereo/cas/branches). Your CAS version is closely tied to the branches listed in the codebase. For example, if you are deploying CAS `5.1.8`, then the relevant branch to check out would be `5.1.x`. Remember that branches always contain the most recent changeset and version of the release line. You might be deploying `5.1.8` while the `5.1.x` might be marching towards `5.1.10`. This requires that you first upgrade to the latest available patch release for the CAS version at hand and if the problem or use case continues to manifest, you can then check out the appropriate source branch and get fancy <sub>[1]</sub>.

<div class="alert alert-info">
<strong>Keep Up</strong><br/>It is <b>STRONGLY</b> recommended that you keep up with the patch releases as they come out. Test early and have the environment on hand for when the time comes to dabble into the source. Postponing patch upgrades in the interest of time will eventually depreciate your lifespan.</div>

It is important that to let IntelliJ IDEA open and refresh the Gradle project (using the *Refresh* button on the Gradle window's toolbar) once you do the initial import. Running `./gradlew idea` **MAY** work but it may also completely mess up the project structure especially if the plugin is not quite compatible with your IDE version. Note that similar tasks are available for eclipse.

For best results, try with IntelliJ IDEA `2019.3` (Ultimate Edition). Given the size of the CAS projects and the number of sub-modules, you need to make sure you have enough memory available for IDEA and that your custom JVM settings are correctly set per [the instructions here][buildprocess] for IntelliJ IDEA.

# System Requirements

It's best to get familiar with [CAS system requirements][systemrequirements]. Most importantly, this means that your system must be prepped with JDK `11`. Just about any JDK variant from any JDK vendor would do the job.

<div class="alert alert-danger">
  <strong>Important changes in Oracle JDK 11 License</strong><br/>With JDK 11 Oracle has updated the license terms on which Oracle JDK is offered. The new Oracle Technology Network License Agreement for Oracle Java SE is substantially different from the licenses under which previous versions of the JDK were offered. <b>Please review</b> the new terms carefully before downloading and using this product. Oracle also offers this software under the GPL License on jdk.java.net/11.</div>

For basic development and prototyping, try with:

```bash                                                                 
java -version

java version "11.0.5" 2019-10-15 LTS
Java(TM) SE Runtime Environment 18.9 (build 11.0.5+10-LTS)
Java HotSpot(TM) 64-Bit Server VM 18.9 (build 11.0.5+10-LTS, mixed mode)
```

# Running CAS

The CAS web application itself can be started from the command prompt using an embedded Apache Tomcat container. In fact, this process is no different from deploying CAS using the same embedded Apache Tomcat container which means you will need to follow the [instructions posted here][buildprocess] in the way that certificates and other configurations are needed in `/etc/cas/config`, etc to ensure CAS can function as you need it. All feature modules and behavior that would be stuffed into the web application artifact continue to read settings from the same location, as they would be when activated from an overlay. The process is the same.

I use the following alias in my bash profile to spin up CAS using an embedded Apache Tomcat container. You might want to do the same thing:

```bash
alias bc='clear; cd ~/Workspace/cas/webapp/cas-server-webapp-tomcat; \
    ../../gradlew build bootRun --configure-on-demand --build-cache --parallel \
    -x test -x javadoc -x check -DenableRemoteDebugging=true --stacktrace \
    -DskipNestedConfigMetadataGen=true -DskipGradleLint=true'
```

Then, I simply execute the following in the terminal:

```bash
> bc
```

Since you're running `bootRun` under the `cas-server-webapp-tomcat` module, the servlet container used will be based on Apache Tomcat. You can navigate to a different module that bases itself on top of a different servlet container such as Jetty.

<div class="alert alert-info">
<strong>On Windows</strong><br/>You can apply the same strategy on Windows by creating a <code>bc.bat</code> file and making sure it's available on the <code>PATH</code>. The syntax of course needs to be adjusted to account for file paths and commands.</div>

To understand the meaning and function behind various command-line arguments, please see [instructions posted here][buildprocess]. You may optionally decide to tweak each setting if you are interested in a particular build variant, such as generating javadocs, running tests, etc. One particular flag of interest is the addition of `enableRemoteDebugging`, which allows you, later on, to connect a remote debugger to CAS on a specific port (i.e. `5000`) and step into the code. More on that later.

# Testing Modules

Per [instructions posted here][buildprocess], the inclusion of a particular build module in the Gradle build script of the CAS web application should allow the build process to automatically allow the module to be packaged and become available to the runtime. You may include the module reference in the [`webapp.gradle`][webappgradlefile] file, which is the common parent to build descriptors that do stuff with CAS web applications. Making changes in this file will ensure that it will be included *by default* in the generic CAS web application, regardless of how it is configured to run using a servlet container, which means you need to be extra careful about the sort of changes you make here and what is kept and what is checked in for follow-up pull requests and reviews.

So for reference and our task at hand, the file would look like the following:

```groovy
dependencies {
    ...
    implementation project(":support:cas-server-support-some-module")
    ...
}
```

Note the reference locates the module using its full path. The next time you run `bc`, the final CAS web application will have enabled `some-module` functionality when it's booting up inside Apache Tomcat allowing you to make changes to the said module and begin testing. The same command, `bc`, can be used over and over again to run CAS locally and test the change until the desired functionality is there.

Once done, you may then commit the change to a relevant branch (of your fork, which is something you should have done earlier when you cloned the codebase) and push upstream (again, to your fork) in order to prepare a pull request and send in the change targetted at the right destination branch. More info on that workflow [is available here][contribguide].

# Debugging CAS

One of the very useful things you can include in your build is the ability to allow for remote debugging via `-DenableRemoteDebugging=true`. Both [IntelliJ IDEA](https://www.jetbrains.com/help/idea/run-debug-configuration-remote-debug.html) and eclipse allow you ways to connect to a port remotely and activate a debugger to step into the code and troubleshoot. This is hugely useful, especially in cases where you can make a change to a source file and *rebuild* the component live hot-reloading the `.class` file to allow the changes to kick in the very next time execution passes through without restarting the servlet container. Depending on how significant the change is, this should save you quite a bit of time.

There are also many fancier tools such as [JRebel](https://zeroturnaround.com/software/jrebel/) that let you do the same with a lot more power and flexibility.

The remote debugging port by default is `5000` and should be auto-incremented in case the port is busy or occupied by some other process. You should get notices and prompts from the build, if and when that happens.

A very useful flag that you may consider adding to your shell alias is `-DremoteDebuggingSuspend=true`, which allows you to suspend the JVM until a debugger tool is attached to the running process. This is handy in situations where you need to debug and troubleshoot a particular component or behavior that executes early during startup (i.e. fetching CAS configuration settings or servlet container bootstrapping) and you don't want the runtime to proceed too quickly and forcing you to miss the troubleshooting window.

With the inclusion of this new flag, the build outcome sort of looks like this:

```bash
> Task :webapp:cas-server-webapp-tomcat:bootRun
Listening for transport dt_socket at address: 5000
```

# Overlay

Sometimes, it's useful to test the new change from the perspective of the [CAS Overlay][overlay]. While the behavior should be identical, this step can be used in quick smoke tests and to ensure the proper set of dependencies and modules are published and *installed* correctly and picked up by the overlay build process without any conflicts or duplicates.

To publish and *install* CAS artifacts locally, you may try the following:

```bash
# Build CAS and install...
alias bci='clear; cd ~/Workspace/cas \
    ./gradlew clean build install --configure-on-demand --build-cache --parallel \
    -x test -x javadoc -x check --stacktrace \
    -DskipNestedConfigMetadataGen=true -DskipGradleLint=true \
    -DskipBootifulArtifact=true'
```

Be patient. This might take some time.

A rather important flag in the above build is `-DskipBootifulArtifact=true`. This stops the Gradle build from applying the Spring Boot plugin to bootify application components, mainly the various CAS web application artifacts. This is required because the [CAS Overlay][overlay] needs to operate on a *vanilla* web application untouched by Spring Boot plugins (a.k.a *non-bootiful*) before it can explode and repackage it with Spring Boot. Note that the CAS build and release processes automatically take this flag into account when snapshots or releases are published and more conveniently, whether you are working on the CAS codebase or overlay, you get to work with the same bootiful web application without any extra hassle.

Once the artifacts are successfully installed, you can pick up the `-SNAPSHOT` artifacts in overlay by changing the CAS version and resume testing.

# Writing Tests

Ideally, changes that are introduced need to be tested using either simple unit tests or integration tests.

<div class="alert alert-info">
<strong>JUnit Tests</strong><br/>As of this writing, CAS uses the JUnit framework <code>5.5</code> to design and execute tests. All test cases need to be aligned with the specific requirements of the JUnit framework properly before they can pass. This means the correct use of package imports, assertions, method lifecycle annotations, etc.</div>

## Unit Tests

Writing unit tests is rather easy. If you have added a few changes to `src/main/java/org/apereo/cas/SomeCasComponent.java`, you will need to create the corresponding test component under `src/test/java/org/apereo/cas/SomeCasComponentTests.java` for the build to identify and execute it. The outline of `SomeCasComponentTests` would look something like this:

```java
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest(classes = {
    SomeCasComponentConfiguration.class
})
@TestPropertySource(properties = {"cas.some.property=value"})
@EnableConfigurationProperties(CasConfigurationProperties.class)
public class SomeCasComponentTests {
    /*
        Injected via SomeCasComponentConfiguration...
    */
    @Autowired
    @Qualifier("someCasComponent")
    private SomeCasComponent someCasComponent;

    @BeforeEach
    public void initialize() {

    }

    @Test
    public void verifyStuffHappens() throws Exception {
        // Invoke someCasComponent.someMethod() and examine/assert the output
    }
}
```

In short, you need to make sure all the correct *Configuration* classes are included to bootstrap the build so that the required objects can be injected into the test class at runtime. You may also need to include additional modules and dependencies in the `build.gradle` file of the project to make sure the test runner has access to all required classes:

```groovy
dependencies {
    testImplementation project(":support:cas-server-support-xyz")
    testImplementation project(path: ":support:cas-server-support-xyz", configuration: "tests")
}
```

- You can also *tag* your test so its put into a specific execution category (i.e. `@Tag("Groovy")`).
- You can also ensure your test is only executable as part of the CI build process by annotating it via `@EnabledIfContinuousIntegration`. The opposite is also possible using `@DisabledIfContinuousIntegration`.

For best examples, scan the codebase to find similar test classes and try to follow the same pattern and structure as others to keep things as consistent as possible.

## Integration Tests

If the change you are working on has a dependency on an external system such as a REST API or SQL database, you will need to make sure the test class is categorized appropriately. For example, let's assume that `SomeCasComponentTests` requires an external Redis NoSQL database which means that your test class should indicate this as such:

```java
@Tag("Redis")
@EnabledIfContinuousIntegration
public class SomeCasComponentTests {
    ...
}
```

Note that the test execution would always fail if the Redis database isn't installed, running and configured correctly for everyone else working on the same CAS codebase. To work around this, we have also added a condition for the test runner to only execute the test when the [CAS CI environment][castravisci] is handling the test execution. The CI environment, given the appropriate category, will bootstrap and initialize the required dependencies and systems (typically via Docker) for the tests to execute which allows you to run the tests locally with a (Redis) database of your own while allowing the CI process to handle the test execution all the same, automatically and with the needed external dependencies.

Again, for better examples simply scan the codebase to find similar test classes.

# Running Tests

Our Gradle test commands need to be slightly modified to only run the tests that need to run based on the category of interest. For example, to run all Redis-related tests our test command would look like this:

```bash
clear
cd ~/Workspace/cas
./gradlew clean testRedis -x test -x javadoc \
    --build-cache --configure-on-demand -DtestCategoryType=REDIS
    -x check --parallel -DskipNestedConfigMetadataGen=true \
    -DskipNestedConfigMetadataGen=true'
```

Or, to run simple unit tests our test command would look like this:

```bash
clear
cd ~/Workspace/cas
./gradlew clean test -x javadoc \
    --build-cache --configure-on-demand -DtestCategoryType=SIMPLE
    -x check --parallel -DskipNestedConfigMetadataGen=true \
    -DskipNestedConfigMetadataGen=true'
```

Note the use of the `testCategoryType` parameter as well as the actual task that runs the tests (`test` vs `testRedis`). To learn more about other available categories and how they are executed, please [take a look here][cascitests].

To make things more comfortable, you can put the above into some sort of bash function. Here's an outline of said function that supports a number of categories for CAS integration tests:

```bash
function testcas() {
  task="$1"
  tests="$2"
  debug="$3"

  case $task in
  test|simple|run|basic|unit)
    task="test"
    category="SIMPLE"
    ;;
  memcached|memcache|kryo)
    task="testMemcached"
    category="MEMCACHED"
    ;;
  filesystem|files|file)
    task="testFileSystem"
    category="FILESYSTEM"
    ;;
  groovy)
    task="testGroovy"
    category="GROOVY"
    ;;
  ldap)
    task="testLdap"
    category="LDAP"
    ;;
  mongo|mongodb)
    task="testMongoDb"
    category="MONGODB"
    ;;
  couchdb)
    task="testCouchDb"
    category="COUCHDB"
    ;;
  rest|restful)
    task="testRestful"
    category="RESTFULAPI"
    ;;
  mysql)
    task="testMySQL"
    category="MYSQL"
    ;;
  cassandra)
    task="testCassandra"
    category="CASSANDRA"
    ;;
  mail|email)
    task="testMail"
    category="MAIL"
    ;;
  dynamodb|dynamo)
    task="testDynamoDb"
    category="DYNAMODB"
    ;;
  redis)
    task="testRedis"
    category="REDIS"
    ;;
  esac

  if [ -z "${tests}" ] || [ "${tests}" == "-" ]; then
    tests=""
  else
    tests="--tests \"${tests}\""
  fi

  if [ ! -z "${debug}" ]; then
    debug="--debug-jvm"
  fi

  # clear
  echo -e "${BLUE}Running Gradle with task ${CYAN}[$task]${NORMAL}${BLUE}, category ${CYAN}[$category]${NORMAL} \
${BLUE}including ${CYAN}[$tests]${NORMAL}${BLUE} with debug ${CYAN}[$debug]${NORMAL}"

  cmd="gradle $task $debug -DtestCategoryType=$category $tests \
--build-cache --parallel -x javadoc -x check -DignoreTestFailures=false -DskipNestedConfigMetadataGen=true \
-DskipGradleLint=true -DshowStandardStreams=true \
--no-daemon --configure-on-demand "

  echo -e "$cmd\n"
  # set -E
  # set -o functrace
  # set -x
  eval "$cmd"
}
```

As an example, let CAS run all basic unit tests:

```bash
testcas simple
```

Run all integration tests that are tagged as `Mail`:

```bash
testcas mail
```

Run all MySQL tests that belong to the `SomeJpaTests` component in a particular CAS module inside and enable remote debugging over port `5005`:

```bash
cd path/to/some/cas/module
testcas mysql org.apereo.cas.SomeJpaTests true
```

Run `verifyStuffHappensCorrectly` that belongs to the `SomeJpaTests` component in a particular CAS module inside and enable remote debugging over port `5005`:

```bash
cd path/to/some/cas/module
testcas mysql org.apereo.cas.SomeJpaTests.verifyStuffHappensCorrectly true
```

<div class="alert alert-info">
<strong>But it works on my machine...</strong><br/>Ultimately, all tests need to execute and pass on the CAS CI environment. There are the occasional phantom and unrelated failures which can usually be safely ignored but the canonical reference for tests and verifications is always the CI environment. When you write tests, try not to make assumptions that would later fail when the test is examined by CI.</div>

# So...

I hope this review was of some help to you and I am sure that both this post as well as the functionality it attempts to explain can be improved in any number of ways. Please feel free to [engage and contribute][contribguide] as best as you can.

Happy Coding,

[Misagh Moayyed](https://fawnoos.com)

[1] There are ways to get around this *limitation*, by specifically downloading the source code for the exact CAS version at hand. I am skipping over those since they only lead to complications, suffering and further evil in most cases.

[castravisci]: https://travis-ci.org/apereo/cas/builds
[cascitests]: https://github.com/apereo/cas/tree/6.1.x/ci/tests
[overlay]: https://github.com/apereo/cas-overlay-template
[contribguide]: https://apereo.github.io/cas/developer/Contributor-Guidelines.html
[webappgradlefile]: https://github.com/apereo/cas/blob/6.2.x/gradle/webapp.gradle
[systemrequirements]: https://apereo.github.io/cas/6.2.x/planning/Installation-Requirements.html
[buildprocess]: https://apereo.github.io/cas/developer/Build-Process-6X.html
