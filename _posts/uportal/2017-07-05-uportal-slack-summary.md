---
layout:     post
title:      June 2017 uPortal Slack summary
summary:    Summarizing Slack traffic about uPortal in June 2017.
tags:       [uPortal]
---

In June 2017, 11 people participated substantially in conversation in the [slack.apereo.org #uportal channel].

+ Aaron Grant
+ Andrew Petro
+ Brandon Powell
+ Christian Cousquer
+ Christian Murphy
+ David Sibley
+ Drew Wills
+ Jim Helwig
+ Marissa Warner-Wu
+ Matt Clare
+ Tim Vertein


Conversation highlights include:

+ Aaron Grant's [uportal_commit_stats] script and its findings about uPortal contributions. [gitinspector] might also be useful for uPortal-related Git history analysis.
+ Internationalization of documentation stored in Git. What Symfony does in its [primary][symfony-docs] and [French-translation][symfony-docs-fr] documentation. (Separate repos.). Alternatively, the [jekyll-multiple-languages-plugin] . Example [ReactJS portlet with i18n support] based in [i18next].
+ Sharing resources from the Open Apereo 2017 conference, including [Portal?! uPortal! What is this Béchamel], [Speeding up uPortal with ReactJS], [two-hard-problems]. (Cf. [uportal-dev@ thread re conference artifacts].)
+ Encouraging interest in the new [Accessibility group]. (Cf. [Accessibility Across Apereo thread on uportal-user@])
+ [styled-components] for styling React.js apps, [browser support for Polymer].
+ [conversational UI example]
+ Weather API options, including World Weather Online, Weather Underground, weather.gov, DarkSky API.
+ The [@uPortal] Twitter account.
+ The role of some CSS classes ` <xsl:attribute name="class">up-portlet-control focus externalLink</xsl:attribute>` (turns out to be used in some JavaScript associated with the maximize menu option).
+ uPortal 5 [fanciness for setting up Tomcat][uPortal-start PR 6] and [deployment via Gradle][uPortal-start PR 8]. [Renaming the overlays directory][uPortal-start PR 10] (cf. [uportal-dev@ thread on overlays directory renaming] or [another][another uportal-dev@ thread on overlays directory renaming]).
+ [myday cloud-based portal]
+ [sonar][sonarwhal], a linting tool for the web



## On Slack

I have some [concerns about the openness properties of Slack as implemented by Apereo][open@ 2017-06-15]. You can't read its logs anonymously; you have to log in to access it and you can't come across its content via a Google search. Only the most recent ten thousand messages are available, so in practice this means logs are lost about a month back.

Summarizing the conversations in this anonymously, publicly accessible and Google indexable context somewhat mitigates these problems.

Arguably, all of the conversations held in the `#uportal` Slack channel this month could have been held via email on `uportal-dev@` or `uportal-user@` email lists additionally or instead. Some relevant email list threads are linked above.

-[Andrew](https://apetro.ghost.io)

[@uPortal]: https://twitter.com/uPortal
[Accessibility group]: https://groups.google.com/a/apereo.org/forum/#!forum/accessibility
[another uportal-dev@ thread on overlays directory renaming]: https://groups.google.com/a/apereo.org/d/topic/uportal-dev/uaeYARDVRZY/discussion
[browser support for Polymer]: https://www.polymer-project.org/2.0/docs/browsers
[conversational UI example]: http://azumbrunnen.me/
[gitinspector]: https://github.com/ejwa/gitinspector
[i18next]: https://www.i18next.com/
[jekyll-multiple-languages-plugin]: https://github.com/Anthony-Gaudino/jekyll-multiple-languages-plugin
[myday cloud-based portal]: https://www.collabco.co.uk/features/dashboards/
[open@ 2017-06-15]: https://groups.google.com/a/apereo.org/d/msg/open/cbk9NLb43LQ/btRpD_09AwAJ
[Portal?! uPortal! What is this Béchamel]: https://cousquer.github.io/apereo2017/
[ReactJS portlet with i18n support]: https://github.com/bpowell/i18n-react-portlet
[slack.apereo.org #uportal channel]: https://apereo.slack.com/messages/C0MNUQDN3/
[sonarwhal]: https://sonarwhal.com/
[Speeding up uPortal with ReactJS]: https://www.slideshare.net/bpowell29a/speeding-up-uportal-with-reactjs
[styled-components]: https://www.styled-components.com/
[symfony-docs-fr]: https://github.com/symfony-fr/symfony-docs-fr
[symfony-docs]: https://github.com/symfony/symfony-docs
[two-hard-problems]: https://www.icloud.com/keynote/0vEJysMgblVjGUv0ystx1xWrA#two-hard-problems
[uportal_commit_stats]: https://github.com/blamonet/uportal_commit_stats
[uportal-dev@ thread on overlays directory renaming]: https://groups.google.com/a/apereo.org/d/topic/uportal-dev/7Fu4UfnXpQE/discussion
[uportal-dev@ thread re conference artifacts]: https://groups.google.com/a/apereo.org/d/topic/uportal-dev/24RjwcDhtOg/discussion
[uPortal-start PR 10]: https://github.com/Jasig/uPortal-start/pull/10
[uPortal-start PR 6]: https://github.com/Jasig/uPortal-start/pull/6
[uPortal-start PR 8]: https://github.com/Jasig/uPortal-start/pull/8
[Accessibility across Apereo thread on uportal-user@]: https://groups.google.com/a/apereo.org/d/topic/uportal-user/KQbBMtUHHFY/discussion