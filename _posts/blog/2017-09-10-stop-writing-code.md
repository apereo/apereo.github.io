---
layout:     post
title:      Stop Writing Code
summary:    A legitimate, comprehensive and inescapably detailed account of the spiderweb of deceit in today’s technology scene; The open-source software ecosystem where victims fall prey to the Goldilocks Syndrome of software customizations and home-grown functionality. This guide aims to uncover the deepest darkest secrets of this treacherous path and yet intentionally offers no hopes or viable solutions at all…except one.
tags:       [Blog]
---

As a fellow somewhat active in the technology space and that of open-source identity and access management, a reasonable portion of my time throughout the week is loaned to conference calls reviewing and discussing the viability of software upgrades and feature deployments. Much of this is spent on reviewing what already exists, analyzing any and all available documentation at luck’s behest and finally enumerating approaches to the ultimate upgrade goal. Take note that in the majority of these conversations, the underlying motivation first and foremost is to fall back to stock functionality and try-remove most if not all of the existing *local* customizations for which at one point significant time and investment was made. 

 “Why?“ That is an excellent question. This post intends to provide a local and customized answer.

# The Trap

Amongst many other factors, a significant and common motivation for one to adopt and deploy open-source software is to avoid vendor lock-in and feel empowered by a permitting license to tailor the packaging to one’s needs. Indeed, the source is open and you are for the most part allowed and encouraged to ride the freedom train and turn the package inside out where needed. As time marches on with more applications on-boarded and newer systems integrated, your deployment would be bombarded with all sorts of new and unfamiliar requirements whose successful delivery at times would undoubtedly require writing code.

Take a deep breath and pause when you get to this stage, for there be dragons here. 

# Customizations

Let’s get the obvious out of the way; not all customizations are “evil". In my experience, the opposite is usually far truer. In fact, most open-source projects likely have a documented set of guidelines where a certain batch of changes in particular areas of the system is recommended or even expected. In such scenarios, the *internals* of the deployment are treated very much like a black-box and the software is considered **more like a product rather than a platform**. Common examples include providing one’s  own strategy for authentication, content, user interface and logging where you are expected to make the system uniquely yours. So long as you stay within these boundaries, you will do perfectly fine. 

It’s when you have to step out of bounds that things get more interesting.

# Let There Be Change

As much you would try to avoid this, there will be requirements and integrations whose implementation requires you to step out of bounds and write the code. These are the most common rationales I have learned:

-	Integration with home-grown legacy system/behavior.
-	NIH syndrome.
-	*"But that’s how we have always done things"*.
-	Integration with black box whose design philosophy is immune to reasonable thought and suggestion.
-	Inability or unwillingness to reason with certain stakeholders with sensitive requirements.
-	*"Meh…it was faster this way"*.
-	Toying around with an exciting new idea with merit for wider adoption. (By far, the most prevalent).

So you step into it. Deadlines begin to breath down your neck. Management continues to push for 5am Saturday production deployments to minimize downtime and risk. The inner-child in you continues to have reservations about the nature of the change, the rightness of it all pondering if there is a better path yet you keep reminding yourself to side-step doubt and consider the code and change a *temporary* solution that would surely be revisited, refactored and hopefully removed some day after production.

Of course, that day rarely comes. What’s more alarming that over time, you continue this exercise again and again such that a year from now, the thing no longer resembles anything of its original nature.

# Potential Problems

Such extensions to software are like bad roommates that rarely move out. They sit on your couch all day, eat your food and insist on watching Grey’s Anatomy all the day fascinated by life and love. They require continuous care to ensure the system as a whole would not remain stale and maintenance to warrant unbroken paths to future upgrades. Substantial effort may need to be spent during the design phase as you have to account for best security/coding/deployment practices; Then you would need to document the behavior and share, review and teach it to other coworkers who one day might step into your position. All of this is a very long way of saying: hidden cost. 
But on the other hand, let’s not forget though that you might have immense satisfaction once you deliver because you very proudly were able to analyze, understand, design, implement and deliver a useful practical needed change. So, good for you. Very well done!

It’s quite obvious that none of us can stop change. The legacy systems, the vendors, the integrations, the requirements…they will continue to come and as much as disagree with intent or behavior, *thou shall deliver*. When you start to make changes, the *Why* and the *How* are important but those are not this post’s concern. For the purposes of this rant, the Where is where it’s at. 

Literally. 

# The Where

Let me reemphasize that I think the majority of all changes are well intentioned, solve an underlying pain point and on the surface look reasonable and attractive. As a colleague, my personal and professional position is to just evaluate and yet never argue the Why with you, because after all I am just guest in your house and once I leave, you are responsible for the mortgage. So I might express concerns about the validity and soundness of the use case, but ultimately, it is always and forever will be your decision. 

Now that we have gotten that out of the way, let’s figure out how we are going to implement the change together. Rather than firing up your workstation immediately to redefine HTTP, exchange passwords in plain-text, design your own message queue or REST-based content protocol and replace XML with JSON because *readability* or any other creative solutions, I recommend you take the following approach instead.

## Talk

It is likely that someone else in your open-source community has already coded and delivered the very same thing. Nowadays, it’s very difficult to come up with something that hasn’t already been thought of and [done by the Simpsons]( https://www.wikiwand.com/en/Simpsons_Already_Did_It).

Ask around. Chances are you will find similarities and opportunities for collaboration.

## Negotiate

So it might turn out that you essentially need to start from *scratch*. Great. This is your moment in the spotlight to negotiate a contribution agreement with the community. Questions you should be asking might include *“Is anyone else interested in this functionality? Is anyone else interested to collaborate on this? Is the community interested in adopting this if and when we deliver?"*

These are excellent questions.

As I have repeatedly outlined, it most often does not matter what *this* is. Maybe you are working on a brand new capability absent in the current software stack…or maybe you’re adding a new variation to an existing feature, like the ability to use a relational database instead of a NoSQL database…or perhaps you want the system to dance for you based on the native and traditional customs of the end-user’s current region determined by the browser’s locale…who knows. 

Ordinarily, [it’s all good]( https://apereo.github.io/2017/02/18/onthe-theoryof-possibility/). The worst that could happen is, *“No, sorry. Code this for you only"*. 

## Execute

Assuming positive reception and answers to the above questions, the task would then turn into one of contributing back and figuring out the quirks and the specifics as to make the intended behavior and feature generic and useful enough for the masses. Do not overdo. Do not pre-optimize. Remove institution-specific assumptions, write a bit of documentation and share. Do it all out in the open, from the start without fear. Others will step up to adopt, collaborate and improve the functionality over time, or else it’s perfect just as you intended it to be. 

With time, it will either get better, or [the trainman]( http://matrix.wikia.com/wiki/The_Trainman) will take it back to the machine world.

## WIP

[Read this](https://ben.straub.cc/2015/04/02/wip-pull-request/).

# So

What this post is trying to say, if it’s saying anything, is that your goal in all such endeavors should be to avoid marooning changes on islands whose only citizens are you and your company. At rare times, it might be that the change is so unique enough for others to dissuade them from ever bunking with you on that island and that might be just fine, but most usually the use case is objective, shareable and reasonable. So avoid making *custom* changes; Being a single parent is tough, so avoid carrying the maintenance burden solely on your own. Avoid treating your deployment unreasoningly unique. You are not that special.

Stop writing code. Write it where it belongs.

[Misagh Moayyed](https://twitter.com/misagh84)