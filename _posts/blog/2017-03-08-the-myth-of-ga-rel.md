---
layout:     post
title:      Busting the Myth - GA Release
summary:    Musings on the trustworthiness of a general availability (GA) release and its production-readiness calibre in open source. 
tags:       [Blog]
---

If you are a member of an open source community, currently waiting for something to be *officially* tagged as a GA release so you can begin planning your production deployments and schedule, this post is for you.

You are holding it wrong.

# The GA Release

A GA release is typically the last step in the software release life cycle. It is the point where the overall developer and user communities have reasonable confidence in the viability of the software and consider the release physique to generally be in a good-enough shape.

How is a release beaten into shape?

A GA release typically follows after one or more *release candidates*. The release candidate is a beta version of the software with potential to be a final product unless significant bugs are discovered during trials. Release candidates provide opportunities for the community to begin testing new and old product features to the extent and interest reasonable, until show-stopper defects are all evaluated and possibly removed.

# To GA or Not to GA


There are a number of risky assumptions made about GA releases that typically end up affecting the overall [production] deployment schedule in negative ways. Here is what I have learned.

## No Magic

Some deployments tend to consider a GA release as "This is good to go". This statement may be true in larger communities (and not even then) with many active participants, testers and enthusiasts who get involved and step forward to test features, troubleshoot and diagnose issues, provide feedback and patches. After all, that's how one develops confidence for a release, right? *"This was tested by 20 people and in the end they were all found with a smile on their face."* 

If your community and your membership does not filter through those parameters and yet you're planning your production rollouts and schedules based on the availability of that release, I promise, you have set yourself up for surprises. Of course, some tend to assume that confidence in a given release somehow stems from the deep chasms of the Misty Mountains. While an avid hiker myself and having not visited the place for certain, I find that claim to be suspicious.

A GA tag is just a tag. That's all....Yes, it's just a tag. It holds no magical powers. Really.

## Love Thyself

I might be stating the obvious here...

>The only person that really cares about you...is you.

Why does that matter and how is that relevant?

When you begin to plan your production deployment, you inevitably have to make a number of assumptions about your overall environment. You may be upgrading from a previous version and need to figure out how to transition the old to the new. The product may also bring about a few new features in which you may want to invest and then have other applications and systems utilize. You may have to strengthen and modify the infrastructure, security policy, integrations, high-availability and scalability requirements, etc. It's not an easy thing.

Are you willing to trust your plans with the (possible, if any) test results of other beta testers in the community? Does your community even have beta testers? Do you know if they might have the same interests and needs in the software capabilities as you? Do you have access to their test results? Are you aware of their testing policies? What sort of tests anyway? Integration tests, functional tests, HA tests, accessibility tests, smoke tests...?

In my experience, it's much more effective to take direct control of the situation beforehand. Community members and testers test and spend time on features they care about. That may not necessarily include yours.

## Another Left Turn

Sigh. This is my least favorite thing to jot down. Here's how it goes:

1. You are waiting for *others* (developers, beta testers, goblins, etc) to test features before it's to become GA.
2. Others are waiting for you and *others* to test features before it's to become GA.
3. Tail-recursion back to #1.

Something eventually breaks that cycle; it's usually the release schedule. Most development communities find themselves saying *"We have tested what we could. Nobody else has reported anything. It's been 6 months. This is good-enough"*.

Do not put yourself in situations where you have to face the question of the falling tree not having any witnesses. Your time is better spent elsewhere on other things...like testing!

# OK. What Now? 

In short, I have learned that early involvement is tremendously valuable. Sure, it is very helpful to rely on others' vote of confidence and make plans. It's immensely better if YOU are that confidence.

[Misagh Moayyed](https://twitter.com/misagh84)