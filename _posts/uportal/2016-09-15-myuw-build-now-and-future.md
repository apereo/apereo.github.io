---
layout:     post
title:      MyUW (University of Wisconsin) Build Process
summary:    A look into what MyUW does now for builds and what it hopes that the future looks like.
---

During the most recent uPortal development meeting we were discussing how uPortal building and deployment currently works and ought to work. It came up that other campuses are checking out the project on each server, building the ear, and shipping it to Tomcat. UW does not take that approach and we thought it may be helpful to articulate what we do to maybe help steer the next generation uPortal project (aka uPortal 5).

## The Now

There are many pieces of technology that the UW uses. Here are the components and some other definitions that will be used in this technical document:

+ CI : Continuous integration
+ [Jenkins](https://jenkins.io/) : A platform to build and deliver projects
+ [Maven Repository](https://www.jfrog.com/artifactory/) : A storage application to place and retrieve built Java artifacts
+ [Gitlab](https://about.gitlab.com/) : A git repository GUI (UW has an on-prem instance running in Docker, very easy)
+ [Maven Overlay](http://maven.apache.org/plugins/maven-war-plugin/overlays.html) : A process in maven where you can overlay files on top of a project to change things such as configuration.
+ [Docker](https://www.docker.com/) : shipping containers with a single process* running in a encapsulated environment.
+ [Token Crypt](https://github.com/UW-Madison-DoIT/token-crypt) : A project that can encrypt/decrypt tokens and files using public/private key pairs.

We use Jenkins for two different reasons. First we build the project and deploy the snapshot to our maven repository. We also use Jenkins for CI. For example, let’s say that someone makes a change to our fork of uPortal. When we merge the merge request from Gitlab into `master`, we push out a post merge web hook to Jenkins. Then we have a Jenkins job that runs `mvn deploy` which packages all the artifacts for uPortal and deploys it to the snapshot maven repository. It is important to note that the artifact we ship to maven has no passwords or configuration files in it. These are environment agnostic artifacts.

After the environment agnostic war has been shipped to the maven repository, we trigger a test uPortal war build. This build is just an overlay.  It takes the environment agnostic war, unwraps it, injects in the configuration files for test, and wraps it back up. It is then stored in our server’s local `.m2/repository`. During this process we decrypt the tokens that are passwords using Token Crypt's maven plugin. Since it has passwords at this point, it’s important to keep it local and not push it anywhere.

At this point the ear job for test is triggered. This ear job is just a `pom.xml` that pulls in the artifacts from all the overlay projects for that given environment. You can see an example of said `pom.xml` [here](https://github.com/UW-MultiEnvironment-Build/dev-ear). All that happens is we run a `mvn package` and then ship the ear (exploded) to a directory on the build server. Do note that none of this is happening on a server that will run uPortal.

So now we have a test version of our deliverable that we want to ship to our test instances. We use Docker for our servers, running on Linux VMs. We have a Docker container that has a preconfigured Java and Tomcat with an empty webapps directory.

After the ear build runs with the test ear, we then can deliver it to test. We have a docker jenkins job that does this task. It does the following:

+ Docker pull our latest container that has java/tomcat configured
+ Copy the wars from the build directory to the running directory (versioned so we can always rollback)
+ Take an instance offline and delete the container (e.g.: `docker stop test1 && docker rm test1` )
+ Do a docker run (e.g.: `docker run myuw/tomcat7-java7:latest -v /runner/810/webapp:/home/of/tomcat/webapp`)
+ Water test the node to make sure tomcat started correctly
+ Then trigger that instance back into the cluster, and rinse/repeat for other nodes

## Looking ahead to where we would like to go

We like our current setup but we would like to improve on a few things. Here is our wish list. First we would love to stop having to fork uPortal to get our own skin and configuration (using the alternative angularjs-portal front end). If we could do a Docker overlay process that could be nice.

We would also like to have it possible to ship the content of the webapp directory instead of depending on a volume mount from the host. In order to accomplish that we need to get rid of the hard coded passwords in the configuration files. We are looking toward using [VaultProject](https://www.vaultproject.io/) for that. This would have the sided bonus of removing the complexity of maven overlays. During startup vault could go fetch the configuration for that given environment.

It could also be interesting to be able to download a docker artifact containing a configured uPortal from docker hub. The only downside is we would like to be able to control the versions of Java and Tomcat. However, if we updated this often we could be alright with relieving that control.

A single Docker container running a big JVM can be painful to scale. We would like to look into splitting out our webapps into many docker containers so we can scale only the things that need scaling. A great example of that is the wave of students who need to get to our campus course guide (which is currently a portlet). If we wanted to increase the bandwidth of that one portlet, we would need to stand up another 6GB JVM. We are migrating that application to a normal webapp so this is possible. It will still have a MyUW presence, but just through widgets and links. It will have the added bonus to look like it is part of the MyUW experience using shared angular components from [uw-frame](https://github.com/UW-Madison-DoIT/uw-frame).

We are also looking toward running on AWS, but this is in the very early stages.

## More Resources
+ [Github overlay sample project](https://github.com/orgs/UW-MultiEnvironment-Build/dashboard)

[Tim Levett](https://twitter.com/timtim192)
