---
layout:     post
title:      Effective Software Troubleshooting Tactics
summary:    A collection of what hopefully are obvious troubleshooting tactics when it comes to diagnosing software deployment issues and configuration problems.
tags:       [Blog]
---

As an [IAM consultant](https://unicon.net/solutions/identity-and-access-management), a good portion of my time throughout the day is spent troubleshooting issues, analyzing logs, helping client and colleagues figure out how to make sense of a seemingly impossible situation when it comes to production system failures, behavioral weirdness or just simply getting something to work per a piece of documentation. I have found that having a documented set of steps and methods proves helpful at a high level as you set out a strategy to solve *almost any* issue dealing with software.

In this blog post, I am sharing a few tactics I have learned and gathered over the years to help boost up my problem-solving foo and I hope that these continue to serve as helpful reminders for you as you troubleshoot software issues or diagnose deployment failures. Please note that these techniques are not listed in any particular order and all weigh more or less equally in terms of importance and priority. *Use what works best for you, in the order that works best for you*.

# Component Break-down

As you set to configure and deploy a piece of software, one of the very first things you should do is to identify the *key actors* and their role in your particular deployment. For instance, if you are deploying a Java-based web application somewhere, your component break-down would include:

- The application itself
- Server deployment environment
- Dependent libraries/tooling
- Operating system
- Network
- Underlying programming language/framework
- ...

As you enumerate the components, it is important that you get to know each player to a reasonable degree. Be suspicious of everything. Once you have identified the key suspects, start working down the list and question everything.

# Start Simple

The weirdness you are trying to diagnose may, in fact, be a consequence of a rather complicated use case that involves many players, ugly preconditions and a decent weather forecast. It is generally rather difficult and sometimes impossible to get every aspect of that difficult use case configured and developed in one initial attempt, specifically if you are not too familiar with the technical solution or even the use case at hand. So, start simple and break down the use case into logical, concrete, bounded chunks. Shoot for best case scenarios small enough to be manageable in your starting attempts. Once successful, tweak one aspect of the configuration in oh-so-small ways, introduce a variable and observe how the behavior changes. Repeat this process until you get home.

Not too long ago, a colleague and I were trying to figure out how to let Apache Tomcat handle [`clientAuth`](https://tomcat.apache.org/tomcat-8.5-doc/config/http.html). After a component break-down, we had the following _key_ actors:

- Apache Tomcat
- Application Realm Configuration
- SSL Certificate Setup
- Browser Setup
- ...

Then we broke the use case down:

1. Visit URL in application
2. Browser presents certificate choice
3. Apache Tomcat processes that choice
4. Application accepts certificate
5. Other stuff happens...

So, we started to work down the list: *Can the URL be accessed without Tomcat's interference? What browser version/type is used? Is our test certificate sane and valid?*, etc. Our very best initial outcome simply was the success of getting to a particular URL. We did not necessarily care what the URL looked like, whether it could or should be changed or rewritten, how one could end up at that URL, web access vs non-web access, etc. All those details were entirely irrelevant and we would get to them later.

Things must be simple before they are complicated.

# Thou Shall Log

Application logs are **THE BEST RESOURCE** for determining the root cause of a problem, provided you have configured the appropriate log levels. Specifically, you want to make sure `DEBUG` or `TRACE` levels are turned on for the relevant packages and components in your logging configuration. Know where the logging configuration is, become familiar with its syntax when changes are due and know where the output data is saved.

Also:

- When changes are applied, you may need to restart the server environment and observe the log files to get a better understanding of behavior.

- Remember that you may not always be dealing with a _single_ log file. Various events may get logged to different files at different locations on the system and you will need to be mindful of all locations where diagnostic data may be. For example, Apache Tomcat has a `catalina.out` log file, then some kind of a `localhost-xyz` file, then some sort of a `accesslog` file, then you have the application log files which may or may not choose to use the same the log files as target destinations for data, etc. *Know your toolset*. Remember to look at everything.

- Nuke all logs before you start the next test attempt. **ALWAYS** start clean. When you or anyone else analyzes diagnostics data, there should never be a question of *Wait. Is this recent? Is this actually my attempt at doing X? It says there is an error, but the date goes back to 2 years ago. How?*. Put a stop to all that. Stop wasting time. Save lives.

If there is one take away in this section for you, dear reader, and one that you should take to heart, internalize, build statues for in tribute and pray to in the morning when you wake up, is this: **REVIEW LOGS**.

Put another way:

- Are you troubleshooting software? Please review logs.
- Cannot get some vendor integration working? Please review logs.
- Neighbor's loud music keeping you up at night? Please review logs.
- Ran out of milk? Please review logs.
- Dog shedding on the carpet? Cat doesn't approve of your life choices? Sure. Please review logs.

In summary, the answer is almost always in the logs.

# Compare Solutions

If you can afford it, another helpful technique is to find environments and/or solutions that actually deliver the use case you need so that you can begin to compare differences. Your objective here is to try to eliminate variables that make the job unnecessarily unique and bothersome and remove those. Identification of these gotchas is the first step, but perhaps more importantly, understanding them and their effect is more ideal. For example, when we were trying to figure out Apache Tomcat's way of handling `clientAuth`, we started asking the following questions:

- *This is Apache Tomcat 8. Does it work with 7? Does it work with 6?*
- *Do we have a certificate that actually does work? How is that different from ours?*
- *Docs say we need file `X` at THIS location, but we have `X` at THAT location. Is that important?*
- *Logs say we cannot connect to our new LDAP. Can we connect to our old LDAP? What's changed?*

Again, you want to find a solution that works and start comparing to identify differences and variables. Find working examples. Try different versions of software components with the same configuration you have today.

Once you have spotted the difference, it's important that you establish a baseline first *and then* start tweaking that baseline one small step at a time in configuration and elsewhere to find the missing element or changing behavior. If you thought option `X` in the configuration does blah, it's important to figure out why it does or does not do as advertised. Identify what works and what doesn't. Getting something to work is important and is one best case scenario sure, but you should not have to stop there, as there will come a time where you would have to go above and beyond option X and getting something to work might bring about other (usually security-related) consequences of which you should be mindful.

# Code Speaks Truth

So, thus far you have identified the key components, broke down the use case, examined logs, and played around with alternative solutions. `X` works but `X+1` does not. You know that. Your logs know that. Your previous working examples and legacy environments and your cat know that. What's next?

*Truth can only be found in one place: the code*, and surely, you must handle the truth.

In my earlier anecdote of dealing with Apache Tomcat and `clientAuth`, all the steps led us to a suspicious [realm](https://github.com/Unicon/x509authentication-bypassing-tomcat-realm) configuration that was not activated quite correctly. We knew the realm worked and we know it was recognized by Apache Tomcat, yet it was never invoked at the right moment. So we started out by configuring Apache Tomcat for [remote debugging](https://blog.trifork.com/2014/07/14/how-to-remotely-debug-application-running-on-tomcat-from-within-intellij-idea/), got the source code, compiled it and connected it via IntelliJ IDEA to a live running Tomcat instance so we could step through each statement. This method allowed us to debug the application, the realm, specific portion of Apache Tomcat code dealing with the realm...and surely, the cat.

What I am trying to say here is that, (if you have access and a permitting license), you must be prepared for stepping down into the code to either trace the flow and logic statically by simply reading (between) the lines or begin a remote debugging session as we did to figure out how it is actually executing. Logs, comparable solutions and such can only take you so far. In the end, code speaks the truth.

# Share Pain, Responsibly

With enough collected data, you should, of course, ask for help and guidance as time and opportunity allows. Sharing data and problem reports requires a degree of discipline to make it easy for others to understand the request easily and respond to it quickly. While there would always be room for follow-up questions and clarifications, it is best to produce and collect as much data as possible and share them using well-understood conventional formats and channels for the best outcome.

A very good discipline is to use a starting template for sharing such reports. A template is basically a stubbed out application, categorized with a series of questions relevant for diagnostics where you fill in the gaps and state the problem description. Again, whether or not the project or community asks this of you, try to provide the following data points:

- *Problem Statement*

State the problem description. *What* are you trying to do? *Why* are you doing it at all? This is where you behind to explain the use case at hand, and circumstances that led you to it.

Be brief but precise:

1. Avoid statements such as *We have X and it doesn't work*. That statement simply doesn't work.
2. Reformulate statements such as *Is it possible to do X?* to explain the why, the what and the how.

- *Expected Outcome*

As the title suggests, what do you expect to happen? What should be the end result in your view?

- *Current Outcome*

As the title suggests, what do you see happening today?

- *Reproduce*

How exactly should one go about reproducing the current outcome? Do you have a series of test cases that demonstrate some faulty behavior? Do you have a sample, a test application to exhibit the issue at hand?

- *Diagnostics*

What steps have you taken to identify and diagnose what you consider to be an issue? How far down the rabbit hole have you traveled to debug the code, analyze the logs, find comparable solutions and track breaking change and incompatibility across software releases?

- *Workarounds*

Do you have a solution at hand today that does the job? Have you experimented with code and configuration to determine the root cause and come up with a suggestion on how X may be improved, fixed, etc?

- *Logs*

It is important that you provide the full story given to you by log data. You may either attach a clean log file that shows the faulty sequence of operations from start to finish, or (and you should avoid this where you can) you may decide to paste relevant sections of the log although this option is usually risky since the portions you think are relevant may not, in fact, be the entire story. If you do decide to share snippets of logs, remember to *not* paste the entire log output into a forum or description field, and learn to format and organize the data so it can be easily and readily understood by others quickly.

- *Environment*

Describe the environment you have today. What are the key components at play here? What precise version of the software do you run? Where did you download it? How old is it and have you considered upgrading? How did you install it? What changes have been applied to the software or its surrounding ecosystem, etc?

Stick to a template. Less guesswork leads to quicker responses and better outcomes. Practice.

# Eat, Sleep, Think

This particular item may not be all too relevant when it comes to troubleshooting software, as issue resolution is usually time-sensitive and a task with a fair amount of pressure and stress, but I personally find this to be very valuable during design or coding session. At times, where you are stumped for a solution and have been staring at the screen and logs for a long time, unsure of how to connect certain pieces together and pigeonholed into a particular line of thinking, it is very useful to leave it all behind for a period of time and switch to a more *physical activity*. Go for a walk around the neighborhood's park, take a nap, shoot a few free throws, etc and allow your brain to reset itself and subconsciously work on the problem in the background. Once you come back, you would have the equivalent of a second pair of eyes and a fresh perspective on how to attack the problem.

In the same category, I find that re-iterating the problem and insofar solutions using a whiteboard, pen/pencil, chatting with a colleague or just about any other type of physical activity outside the use of electronics has the same effect. This effectively tickles your brain to get moving on a solution without you actively realizing it, and of course, a short break every once in a while can do a lot of good. My personal best is around 40-minute mark where I get up, walk around and try to do something totally different and silly, like attempting to train the pigeons outside to dubstep. 

Believe me, it works. (The technique, not the dubstep).

# Start Early

![image](https://user-images.githubusercontent.com/1205228/45082890-9b202100-b10f-11e8-9e28-c02251d3271a.png)

[This](https://apereo.github.io/2017/03/08/the-myth-of-ga-rel/).

# So...

I hope this review was of some help to you. This is by no means a comprehensive list; a lot of is subjective and could be entirely inapplicable to you, your personality and work etiquette. Either way, if you have other tactics and strategies to share please feel free to edit this post as best you can.

Also, many thanks to [@jtgasper3](https://github.com/jtgasper3) for reviewing this post and providing feedback.

[Misagh Moayyed](https://twitter.com/misagh84)