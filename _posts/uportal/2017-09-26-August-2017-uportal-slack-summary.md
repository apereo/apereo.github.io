---
layout:     post
title:      August 2017 uPortal Slack summary
summary:    Summarizing Slack traffic about uPortal in August 2017.
tags:       [uPortal]
---

In August 2017, 2 people participated substantially in conversation in the [slack.apereo.org #uportal channel]. (This is around one fifth as many participants as in June.)

+ Andrew Petro
+ Christian Murphy

Conversation highlights include:

+ Raising awareness of an initial pass at implementing GitLocalize for internationalizing uPortal documentation c.f. [uportal-dev@ thread](https://groups.google.com/a/apereo.org/d/topic/uportal-dev/Jh5emWPXnHA/discussion).
+ Raising awareness of a branch freeze for the uPortal 4.3.2 release c.f. [uportal-dev@ thread](https://groups.google.com/a/apereo.org/d/msg/uportal-dev/ivPu41wyBJU/Cw0ANuOgBQAJ).
+ Raising awareness of [a new GitHub feature for embedding code snippets](https://github.com/blog/2415-introducing-embedded-code-snippets).
+ Raising awareness of a one liner for re-building and re-deploying skins in uPortal 5 ( `./gradlew tomcatStop overlays:uPortal:clean overlays:uPortal:tomcatDeploy tomcatStart` )
+ Raising awareness of [a tool for trying whether WIP code will pass Travis CI](https://github.com/SethMichaelLarson/trytravis) without needing to push.

## On Slack

I have [concerns about the openness properties of Slack as implemented by Apereo][open@ 2017-06-15]. 

+ You can't access it anonymously.
+ It's not Google search indexed. 
+ Older messages aren't available even if you log in.

Summarizing the conversations here on `apereo.github.io` in this anonymously, publicly accessible, and Google-indexable context somewhat mitigates these problems. But not necessarily other problems that make [email list communications preferable in open source projects][].

Arguably, all of the conversations held in the `#uportal` Slack channel could have been held via email on `uportal-dev@` or `uportal-user@` email lists additionally or instead. Some relevant email list threads are linked above.

For myself, I'm convinced that we just shouldn't use Slack in the Apereo uPortal project. Use the email lists. Possibly look to implementing Discourse for better discussion forums / "email lists".

## See also

+ [June 2017 uPortal Slack summary](https://apereo.github.io/2017/07/05/uportal-slack-summary/) (~11 participants)
+ [July 2017 uPortal Slack summary](https://apereo.github.io/2017/08/02/july-2017-uportal-slack-summary/) (~5 participants)

-[Andrew](https://apetro.ghost.io)

[email list communications preferable in open source projects]: https://dave.cheney.net/2017/04/11/why-slack-is-inappropriate-for-open-source-communications
[open@ 2017-06-15]: https://groups.google.com/a/apereo.org/d/msg/open/cbk9NLb43LQ/btRpD_09AwAJ
[slack.apereo.org #uportal channel]: https://apereo.slack.com/messages/C0MNUQDN3/

