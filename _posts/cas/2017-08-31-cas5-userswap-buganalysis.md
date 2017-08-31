---
layout:     post
title:      CAS 5.1.x User Swap - Cause and Analysis
summary:    Travis Schmidt shares an analysis of chasing down a bug in CAS 5.1.x where user identities were swapped.
tags:       [CAS]
---

<div class="alert alert-info">
  <strong>Contributed Content</strong><br/>Travis Schmidt (<code>travis.schmidt [at] gmail.com</code>), an active member of the CAS community, was kind enough to share this analysis.
</div>

# Problem

Shortly after deploying CAS `5.1.2` to our production environment, we received incident reports of users signing into various systems as themselves, but were presented with the accounts of other random users.  The first applications we received reports on were GMail and Box, which both used Shibboleth and the ShibCAS plugin to authenticate, so that is where we first focused our attention. Later that day after investigating the first incidents, another was reported on a system that only used CAS to authenticate and our attention switched solely to CAS.  After the CAS only incident was reported we did an emergency roll back to our previous CAS `4.2.6` version.  After the rollback, no new incidents have been reported.

# Reproducing the Error

## First Attempt

In order to try and identify a cause we looked at the differences between our development environment and our production environment.  The most obvious difference is that production is four nodes while development is only three nodes.  Since it appeared user info was swapped, the Hazelcast ticket registry was our first suspect and we focused our initial efforts there.  We added a fourth node to match production and began load testing again, but were not able to reproduce the error with just this added.  

## Second Attempt

We next focused on our JMeter script used to load test the application.  We modified it to put random delays between users being presented with the login page and posting the login page, calls to all three service validate protocols, and a delayed logout to about half the user threads.  We still did not produce the error with this new script.

## Third Attempt

Lastly we tried a massive amount of load, significant factor higher than what we expect in production.  We saw significant amount of timeout errors and where the system could not keep up, but not the user swap error.

## Finally

I realized that a significant difference between this deployment and our previous deployment was the removal of the `statistics/ping` endpoint.  This meant that the F5 load balancer, and the monitoring systems were changed to call the `cas/status` endpoint.  In production this meant that the `cas/status` endpoint was being called on each node once every 2-3 seconds.  For all the load testing we did before deployment and after, the development nodes were removed from the load balancer and a static page was being sent to the F5 from Apache.  This extra load was never present when running load test before deployment. After running the load test with this `cas/status` being called by the F5, we started to see the timeouts happen earlier in the run.  

For all test runs to this point I was stopping the test at the first error, and then trying to exam the state of the system.  No real information was gleamed from looking at logs.  After one test had stopped I tried doing a `cas/login` to the node that produced the error.  This is where our breakthrough came.  Instead of being presented with the login page, I was looking at the status page. I set the tests to only stop the thread that caused the error and continued running the test.  This is when we started to see the responses start to be mixed.  It would always start with AJP timeouts, but after a bit we start seeing responses being mixed, and eventually two service validate calls would hit just right and `tesuserYYY` would be validated as `testuserXXX`. 

Now we were able to consistently reproduce the error.

# Identifying the Cause

## Deployment Infrastructure 

CAS is run on Apache Tomcat servers that are fronted on each instance by an Apache httpd web server that uses AJP to proxy request to the application.  I think this configuration is quite normal and probably used widely elsewhere.  We focused our attention on Apache, firstly because they were upgraded the same time as the deployment, and secondly because restarting the web server on an affected node cleared the swapping issue.  We tried downgrading, and applying even newer updates, but the problem still persisted.

We then tried to upgrade Tomcat to `8.5.x` from our current `8.0.x` version that we are using, but the problem still persisted.  

## Analyzing Customizations

We have quite a few customizations that we make to the CAS application.  In order to rule out that we introduced the issue with our code, we created clean version of the CAS `5.1.x` branch with [Hazelcast](https://apereo.github.io/cas/5.1.x/installation/Hazelcast-Ticket-Registry.html, [LDAP](https://apereo.github.io/cas/5.1.x/installation/LDAP-Authentication.html) and [Duo Security](https://apereo.github.io/cas/5.1.x/installation/DuoSecurity-Authentication.html) modules compiled in.  The error still occurred with this version of CAS.

## Analyzing the Network

We next focused on the AJP proxy between Apache and Tomcat.  We reconfigured Tomcat to accept connections on 8443 and called it directly bypassing Apache.  This somewhat mitigated the issue.  After several runs this way we always saw swapping occur, but it always seemed to just swap the status page with a login or service validate call, but never saw the CAS protocol end points swap, or a user swap on validate.  

## Viola!

Our focus was then on to the component that produces the status page, `HealthCheckController`.  After numbly staring at the code for a while, and trying a few things, we finally noticed that the mapped method for the status page was coded to return a `WebAsyncTask`. How the callable object was being used would turn out to be the cause of our issue.

# Fixing the Problem 
 
I [put together a patch]( https://github.com/apereo/cas/pull/2891) targeted at the next CAS `5.1.x` release (`5.1.4` at the time of this writing) to address this problem. The patch is of course merged, and it is also brought forward to `master`. You should be able to mitigate this problem, the very next time you upgrade your CAS `5.1.x` instance.

To see the CAS release schedule, please [click here](https://github.com/apereo/cas/milestones).

[Travis Schmidt](travis.schmidt@gmail.com)