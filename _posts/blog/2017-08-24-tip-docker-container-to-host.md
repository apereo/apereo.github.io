---
layout:     post
title:      Let Your Docker Containers Speak
summary:    A short story on how to allow a running Docker container to get in touch with home and host.
tags:       [Blog]
---

If you are like me, you have probably come to the same conclusion that Docker does wonders with the automation of much of the needed  infrastructure while working on a particular development task. For example, I primarily keep myself busy in the realm of [Identity and Access Management (IAM)](https://www.unicon.net/solutions/identity-and-access-management) and there does not a day go by where I find myself in need of a running [SAML service provider](https://github.com/UniconLabs/spring-security-saml-java-sp), a CASified PHP application protected by [mod_auth_cas](https://github.com/apereo/mod_auth_cas) running inside Apache, or a full blown [Grouper deployment](https://github.com/Unicon/grouper-dockerized) for which I might be trying to add a changelog consumer, etc. 

Docker can automate and (more importantly) isolate all of that *noise*, allowing me to focus on the task at hand. Today and while I have opted for both approaches given context and need, my preference is to keep the core platform/application I am working on outside the running Docker ecosystem while leaving all of the stuff-I-need-for-the-integration components inside. I find that this strategy allows for faster builds and more performant/natural debugging and diagnostics. However, one problem I run into often is: how do I connect the two separate environments? Or put another way, how do I let a component running in Docker make a back-channel call to something outside running on the host?

Being so far away from home can be challenging. This blog is about that problem.

## That Problem

My Docker setup usually is based on [this project](https://github.com/UniconLabs/dockerized-idp-testbed), which is the wonderful produce of my esteemed colleague, [@jtgasper3](https://github.com/jtgasper3). As the perfect IAM testbed, it is *composed* (catch the pun?) of an LDAP server, a Shibboleth SP, Apache httpd, a CASified PHP application, simpleSAMLphp, a Shibboleth IdP and possibly more. 

I simply enable/disable components I need running in the package and viola! It takes care of the rest. I am not going to bore you with all the intricate details of how this is all organized Docker-wise, but one thing that is perhaps relevant is that each running component is tagged with a `networks` configuration that simply [controls the application networking](https://docs.docker.com/compose/networking/) via custom networks where each can be linked to a driver configuration (i.e. `bridge`, the default for the Docker engine). This might come in handy, should you decide to go fancier and beyond what I explain here for a solution.

Long story short, the issue had to do with the dockerized Shibboleth SP unable to make a SOAP query to my IdP running outside. If you think about it, this sort of makes sense. What runs inside does not necessarily know anything about what's on the outside. It might seem like everything is simply running on *the same machine*, but `localhost` for you is very different unknown to the Shibboleth SP container running in its own network.

I needed an inside man.

## One Solution

I am convinced there are better solutions that muck around with native Docker networking configuration, bridging host and container. Indeed, one can set up [extra hosts](https://docs.docker.com/compose/compose-file/#extra_hosts), perhaps define a `host` [network mode](https://docs.docker.com/compose/compose-file/#network_mode) of some kind, etc. Who knows! That was a rabbit hole I didn't want to venture into and so I settled for the following simpler albeit temporary solution.

```bash
export DOCKERHOST=$(ifconfig | grep -E "([0-9]{1,3}\.){3}[0-9]{1,3}" | \
                  grep -v 127.0.0.1 | awk '{ print $2 }' | \
                  cut -f2 -d: | head -n1)
```

If you open up your terminal and run that command, you might see something like:

```bash
> echo $DOCKERHOST
192.168.1.170
```

Sweet! Next, I was able to modify the relevant configuration files and use `192.168.1.170` anywhere the dockerized Shibboleth SP needed to make a call to the outside world. While this works fine, I should note that it is absolutely a __temporary solution__ as hardcoding an IP address that might change later on obviously is a broken path but it did suffice my development needs at the time.

# Post-credits Scene

...and oh, if you need to find a quick way to SSH into a running Docker container, put the following in your profile:

```bash
function dockerssh() {
    export CID=$(docker ps -aqf "name=$1"); docker exec -it $CID /bin/bash
}
```

Then use as follows:

```bash
dockerssh [container-name]
```

…and you’re in.

HTH.

[Misagh Moayyed](https://twitter.com/misagh84)