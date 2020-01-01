---
layout:     post
title:      Apereo CAS 2019 Survey Results
summary:    ...in which I present a summarized view of the latest CAS community survey.
tags:       [CAS]
---

<div class="alert alert-success">
<strong>Collaborate</strong><br/>This blog is managed and hosted on GitHub. If you wish to update the contents of this post or if you have found an inaccuracy and wish to make corrections, we recommend that you please submit a pull request to <a href="https://github.com/apereo/apereo.github.io">this repository</a>.
</div>

A [while ago](https://groups.google.com/a/apereo.org/d/msg/cas-user/U-35VSV4JlY/UTSff3s_AwAJ) the CAS project management committee prepared a survey to request feedback from CAS deployers. The goal of the survey was to help clarify specific areas in the CAS software ecosystem that need attention and improvement, understand user demographics and common use cases and attempt to explore routes and opportunities to better support and prioritize funding of development activities.

This post presents a summarized view of the survey results.

# Before We Start

On behalf of the [Apereo CAS project management committee](https://apereo.github.io/cas/developer/Project-Commitee.html),

I'd like to thank all survey participants who graciously took time out to provide focused, constructive and detailed feedback. Your engagement and involvement in the CAS community are very much appreciated.

I'd like to send a shout-out to all contributors who continuously and actively have tried out, shared constructive feedback and contributed to the development **and** support of the CAS software. We will continue to make the [path to contributions](https://apereo.github.io/cas/developer/Contributor-Guidelines.html) easier and as always, your time, patience and efforts are noted and appreciated by the CAS project management committee and the community overall, regardless of the type or impact of the contribution. Please, keep'em coming!

Finally, a much-deserved thank you to all members of the Apereo Foundation who take concrete action beyond words to financially sponsor and support the CAS project. We appreciate your support and membership and hope to see more institutions join and contribute to the development of free and open-source software in more sustainable ways.

# Apereo Membership

If you benefit from Apereo CAS as free and open-source software, we invite you to [join the Apereo Foundation](https://www.apereo.org/content/apereo-membership) and financially support the project at a capacity that best suits your deployment. Note that all development activity is performed *almost exclusively* on a voluntary basis with no expectations, commitments or strings attached. Having the financial means to better sustain engineering activities will allow the developer community to allocate *dedicated and committed* time for long-term support, maintenance and release planning, especially when it comes to addressing critical and security issues in a timely manner. Funding will ensure support for the software you rely on and you gain an advantage and say in the way Apereo, and the CAS project at that, runs and operates. If you consider your CAS deployment to be a critical part of the identity and access management ecosystem, this is a viable option to consider.

# Statistics

## Demographics

There were approx. `70` responses to the survey from both individuals and institutions. Some responses were submitted by consulting firms or contractors who provide CAS services or support which indicates the actual number of deployers may be larger. Participants reported affiliations with a variety of industry sectors most notable of which are Higher Education (`46%`), Finance (`5%`), Travel (`5%`), R & S (`3%`), Healthcare (`7%`), Government (`8%`), etc.

## Versions

The following CAS release lines were reported to be in active production:

| Release  | Adoption | Notes |
| ------------- | ------------- | ---------- |
| `4.x` | `12%` | |
| `5.x` | `59%` | |
| `6.x`  | `22%`  | |
| Other  | `7%`  | `3.x` or non-standard/forked versions

## Traffic

The statistics below indicate the active user population of CAS deployments in production:

| Volume  | Percentage | Notes |
| ------------- | ------------- | ---------- |
| `50K`-`200K` | `6%` | |
| `10K`-`50K` | `34%` | |
| `5K`-`10K` | `19%` | |
| `1K-5K`  | `17%`  | |
| Other  | `24%`  | Less than `1K` or more than `200K`.

# Features & Improvements

Participants were asked to propose a single new feature or improvement to an existing feature, given assumed availability of one week's development time (5 days - 40 hours) and funding of 10,000 USD. What follows is a summary of reported ideas and suggestions:

- UI to manage personal account activity log, possibly in CAS management
- AWS deployment configuration templates
- Built-in Duo Security enrollment for first-time users
- Extensible self-service user portal used to update account security questions, passwords, etc.
- Dynamic configuration of delegated reconfiguration (i.e add a SAML IdP at runtime)
- Web AuthN / FIDO2 as a multifactor provider
- Documentation improvements with better examples and guides
- Built-in solutions to prevent spoofing; rotating images, beacons, etc.
- AUP configurable on a per-service basis
- Multitenancy, combining a medley of CAS server deployments and configurations into one.

Suggestions and feedback on improving the state of the Apereo CAS software will certainly be taken into consideration and possible action over time. Please note that the CAS project does not have an official roadmap, as in, there is no piece of literature foretelling promises of fame and fortune as commitments based on volunteer activity tend to, disappointingly and understandably, be premature and go awry. Instead, we recommend that you consider the roadmap to be that which *you intend to work on and contribute*. Therefore and as guestimated previously, if you have an idea that could be done in a week's worth of time with about $10,000, the very best next thing to do would be to pursue the concept and allocate the estimated time, money and resources to get the job done. Learn, find someone to teach you or find someone to do it for you. Remember that [help is available](https://apereo.github.io/cas/Support.html) to get you to the finish line successfully, and by all means, feel free to contribute or share the results with the rest of the community if time and policy allow. You'd be most welcome.

# Support

## Channels

|  Percentage | Type |
| ------------- | ------------- |
| `90%` | In-house or Apereo's free community support
| `10%` | Contracted with a commercial entity.

A large number of participants indicated:

1. No adequate funding to join the Apereo foundation or contract with a commercial support provider.
2. (Surprisingly) Unaware that membership or commercial support providers were possible and available.

## Budgets

|  Percentage | Type |
| ------------- | ------------- |
| `40%` | 0 to 25 million USD |
| `6%` | 25 to 50 million USD |
| `22%` | 100 to 750 million USD |
| `32%` | Uncertain, more than 750 million, etc. |

## Activity

|  Percentage | Type |
| ------------- | ------------- |
| `39%` | Supporter, via mailing lists, chatrooms, etc. |
| `20%` | Developer, contributor of code and documentation |
| `75%` | User, quietly monitoring activity |

Note that participants were allowed to select more than one category.

# So...

We suggest that you reconsider support options for funding Apereo CAS more sustainably, if possible at all. Most, if not all, CAS development is advanced by volunteers whose time and contribution are supported by a supporting member of the Apereo Foundation, a gracious employer or a loving family. While code contributions, documentation improvements, etc. are always very much welcomed, having institutions join the Apereo Foundation to support the CAS project financially will allow the developer community to continue and further sustain CAS development, extend and allow for longer maintenance periods and better support the user community overall. As indicated by the survey and for those who might have missed it, [support is available](https://apereo.github.io/cas/Support.html).

# Finally

Once again, thanks for sharing. We invite you to [engage and contribute](https://apereo.github.io/cas/developer/Contributor-Guidelines.html) as best as you can.

On behalf of the [Apereo CAS project management committee](https://apereo.github.io/cas/developer/Project-Commitee.html),

[Misagh Moayyed](https://fawnoos.com)
