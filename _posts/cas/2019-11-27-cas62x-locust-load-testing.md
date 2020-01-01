---
layout:     post
title:      Apereo CAS - Python Locust Load Testing
summary:    Learn to Performance Test Apereo CAS with Python Locust.
tags:       [CAS]
---

<div class="alert alert-success">
<strong>Collaborate</strong><br/>This blog is managed and hosted on GitHub. If you wish to update the contents of this post or if you have found an inaccuracy and wish to make corrections, we recommend that you please submit a pull request to <a href="https://github.com/apereo/apereo.github.io">this repository</a>.
</div>

# Overview

In this tutorial, we are going to learn how we can use the **Locust** starter scripts included in the CAS source repository to load test our CAS instances.  For those not familiar with Locust, it is a Python based load testing framework that is fairly popular in the Python community.

If you keep up with this blog, you have probably already read the [JMeter tutorial](https://apereo.github.io/2019/11/08/cas61x-jmeter-load-testing/) I wrote earlier this month. We will be using those same testing scenarios and CAS instance to run the Locust scripts against, so it may behoove you to reread that [tutorial](https://apereo.github.io/2019/11/08/cas61x-jmeter-load-testing/) or dare I say, read it for the first time. It is a thriller! ;-)

Our starting position is:

- CAS `6.2.x`
- Java `11`
- [CAS WAR Overlay](https://github.com/apereo/cas-overlay-template)
- [Python 3.7.5](https://www.python.org/downloads/release/python-375/)
- [CAS Locust scripts](https://github.com/apereo/cas/tree/master/etc/loadtests)
- [Locust - Latest Version](https://locust.io/)


# Locust Setup

Since we will be using Python for this tutorial, you will probably need to setup some sort of virtual environment to run the correct version of Python (3.7.5) for this tutorial. I use [pyenv](https://github.com/pyenv/pyenv), but any virtual environment creation tool can be used. Another popular tool is [virtualenv](https://virtualenv.pypa.io/en/latest/). Once you have the Python environment running, you will need to install the required libraries that Locust needs so it can run correctly.  You can either install each requirement manually with **pip** or you can install via the **requirements.txt** file included with the scripts.

```cmd
virtenv3.7.5> pip install <name of library>
OR
virtenv3.7.5> pip install -r requirements.txt
```
Once you get Locust running and start reviewing the scripts, you will notice is that it is quite different from JMeter. Besides it being written in Python, it also does not have a GUI interface nor does it have the great recording features that JMeter has. The Locust scripts are basically written using plain ole Python.

### Locust Script Breakdown

#### Single Protocol Script Files

File: **casLocust.py** or **samlLocust.py**
 
So let's begin by breaking down one of the scripts located in the CAS source code repository, they are located under the **https://github.com/apereo/cas/tree/master/etc/loadtests/locust** directory. I will be using the CAS protocol file (casLocust.py), but feel free to use the SAML (samlLocust.py) version, if it is more inline with how your organization uses CAS. They are both similarly laid out, so it should be easy to follow along with either script. 

Once you open the file, go to the bottom of the file where you will see a class declaration named the same as the file name, in my case that is the  **CASLocust** class. This is where Locust looks to determine how to create and run the **Locust Swarm**! The critical lines are:
```properties
    task_set = CASTaskSet
    host = "https://mysite.edu:8443"
    wait_time = between(2, 15)
```
The **task_set** parameter tells Locust where it can locate the code that will define the behavior of each Locust in the swarm, in this case it is the **CASTaskSet** class. The **host** param contains the URL of the site that the Locust simulated user will run against. For our purposes, this will point to our CAS instance. The **wait_time** param will determine the amount of seconds Locust will wait to run each task, this will be randomized between 2 and 15 seconds.

Let's take a look at the **CASTaskSet** class. For those following along, it is located towards the top of the file and contains 4 declared methods. The **on_start** and **on_stop** methods are the Locust based methods that run before a simulated user starts and after it ends. This means it is an ideal place to load any user based settings that may be required by a simulated user for traversing the CAS site. Currently, only some basic logging is setup within them. I did add some code to the **on_start** method to turn off SSL error logging, due to having self signed certs. In hindsight, I should have moved this to the Lotus method that initializes the script, I will add that to my to-do list! 

The other two methods are the user created behaviors of **login** and **logout**.  Both these behaviors have the **@seq_task** decorator added to them. This decorator tells Locust that each of these behaviors is a specific task and they are to be executed in a sequence for each simulated user. The first task will be to login a simulated user into CAS, if no errors occur, then run the second task of logging that simulated user out of CAS.

I am not going to go through each line of the **login** method, since that would be more of a lesson in Python coding than Locust script writing.

#### Multiple Protocol Script Files

File: **bothLocust.py**

This script supports both CAS **AND** SAML simulated users access to CAS. Which I think is very cool!
 
The support for both protocols is accomplished by taking advantage of the Locust **@task** decorator. Unlike the **@seq_task**, where each task is run sequentially, the Locust **@task** decorator tells Locust that this is a task, but there is no sequence order, so each task is picked at random.  Also, Lotus has added weighting to the **@task** decorator, so we can manipulate the load test to have twice as many SAML logins as CAS logins or vice versa.  With this in mind plus taking advantage of Python's support for "nested classes", we now have a script that can be easily expanded to support even more protocols!  WooHoo!

# Running Locust...

To Run Locust
```cmd
virtenv3.7.5> locust -f cas5/casLocust.py
```
* Open your browser to **http://localhost:8089/**
* Choose # of Users
* Choose Hatch rate
* Start Swarming

Now that we have an idea of how the scripts work, feel free to run Locust against the various scenarios we had setup in the [JMeter posting](https://apereo.github.io/2019/11/08/cas61x-jmeter-load-testing/).

# So...

I hope this has helped you in understanding how the Locust Load Testing Framework works and how you can use it to load test CAS.

I hope you enjoyed it!

Finally, if you benefit from Apereo CAS as free and open-source software, we invite you to [join the Apereo Foundation](https://www.apereo.org/content/apereo-membership) and financially support the project at a capacity that best suits your deployment. If you consider your CAS deployment to be a critical part of the identity and access management ecosystem and care about its long-term success and sustainability, this is a viable option to consider.

As [Misagh Moayyed](https://fawnoos.com) says 'Happy Coding'!

[Axel Stohn](https://github.com/astohn)
