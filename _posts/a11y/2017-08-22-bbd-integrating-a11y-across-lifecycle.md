---
layout:     post
title:      Better by design 2017: Integrating accessibility across design and development lifecycle
summary:    Notes from Karl Groves workshop on integrating a11y across design and development lifecycle at Better By Design 2017.
tags:       [a11y]
---

I recently attended a day-long workshop on [Integrating accessibility across the design and development lifecycle][] by [Karl Groves][] at [Better By Design][] 2017.

The most important point I took from the workshop was a reminder to **automate functionally testing the front end for those usability characteristics and WCAG targets amenable to automated testing**.

Mostly the workshop was a call-to-action to care about accessibility, to comply with law and regulation about accessibility, and to avoid expensive legal liability. The workshop motivated thinking about accessibility and usability through the lens of fictional startups wherein, contrary to our typical lived developer experience, accessibility would be prioritized in product vision, design, hiring, corporate priorities, technical support, etc. A healthy thought experiment perhaps too far from my lived reality to be fully relatable.


## Automate front-end testing.

Suggested tech stack:

+ [Selenium WebDriver][] : drive web browsers via automation
+ [Mocha][]: JavaScript test framework
+ [Chai][]: assertion library
+ [Should][]: another assertion library
+ [Cucumber][] : executable specifications

The speaker's product, [tenon.io][] , has something to offer for a11y checking automation.


## It's usability

Don't primarily think of it as a11y, as extra stuff to do to accommodate disability. Think of it as making your app usable for everyone.

Focusing on a11y and disability is useful for legal compliance and to help broaden thinking of all the users and all their needs. If it takes thinking about blindness specifically to get you to pay attention to screen reader experiences, so be it. But mostly if you build it right, if it's clear **what things are and what they do**, if it's usable and thoughtful and high quality, accessibility takes care of itself.

And of course automate testing for any code quality characteristics that can be automatically detected, because that's what computers are for.


## Software development has a quality and a culture problem

The problem is

+ Software products are of agonizingly poor quality.
+ Software development culture is often broken, with lack of empathy, empowerment, attention to quality and detail, resources.

Of course low quality software built in agonizing culture has poor usability and poor accessibility.

Do less. Do it with radically higher quality. Win.


## The different versions and levels of WCAG

WCAG 1: three priority levels (1, 2, 3) organized by importance to the usability.

WCAG 2: A, AA, and AAA levels organized by expected cost to implement. 

WCAG A is no-UI-impact stuff that you have no excuse not to do. Very low cost.

WCAG AA is modest-impact stuff that you really ought to do but it comes at a cost. This is de-facto where the industry has landed as acceptable. You're liable to suit if you don't meet WCAG AA; remediation will likely be to meet WCAG AA.

WCAG AAA is potentially tremendously expensive stuff.


All of A, AA, and AAA are important to accessibility, usability. It's not that the AAA stuff isn't important, it's that it's potentially expensive to comply.

Good practice: **meet all of AA. Meet parts of AAA that you can feasibly** achieve.
Good practice: **don't volunteer to meet AAA** -- you're probably just not going to do it.

Recommendation: lurk or participate directly in WCAG 3 standard development. ( [community group][WCAG Silver community group])


## Performance budget analogy

Concept: performance budget. From the outset, how slow will we allow our site / application / pages to be? By what measures? Then work within that budget.

Analogous concept: accessibility budget. How un-usable will we allow our site / application / pages to be? Then work within that budget.  Don't remediate to WCAG AA. Decide WCAG AA is your "accessibility budget" from the outset and anything violating WCAG AA, it's just not in your project's budget.


## Drag-and-drop re-ordering as a11y challenge

Almost any UI control can be made usable and accessible for all users.

Drag-and-drop re-ordering is a notorious exception to this. Provide an alternative experience so that users who cannot easily use visual drag-and-drop controls can instead re-order or re-arrange objects in another way.


## Misc

Other grab bag of points made, references.

+ **Accessibility** as differentiator on resume. a11y is important and getting more important; companies are hiring for it.
+ Paciello Group: [inclusive design principles][Inclusive Design Principles].
+ Inclusive Design Patterns book by Heydon Pickering . Seems to be [available online as a PDF][Inclusive Design Patterns book PDF].
+ [Brad Frost atomic design][], [pattern lab][]
+ [Inclusive Design Principles][]
+ [Josh Blue][] (comedian)
+ [DHS Trusted Tester program][]
+ [Just Ask: Integrated Accessibility throughout Design][] (book) (contents available online)
+ [Lean UX][] (book)
+ [ARIA practices guide][] , [as published][WAI-ARIA Authoring Practices 1.1]

## Planning to automate MyUW accessibility testing

Added to draft Q4 MyUW roadmap an item to automate functionally testing a11y criteria in MyUW as deployed to a test tier. This doesn't guarantee we'll actually do this in Q4 -- it just places a reminder to consider it when tightening up Q4 planning.

-[Andrew](https://apetro.ghost.io)

[ARIA practices guide]: https://github.com/w3c/aria-practices
[Better By Design]: http://betterbydesignconference.com/
[Brad Frost atomic design]: http://atomicdesign.bradfrost.com/
[Chai]: http://chaijs.com/
[Cucumber]: https://cucumber.io/
[DHS Trusted Tester program]: https://www.dhs.gov/trusted-tester
[Inclusive Design Patterns book PDF]: http://smashingconf.com/pdf/inclusive-design-patterns.pdf
[Inclusive Design Principles]: http://inclusivedesignprinciples.org/
[Integrating accessibility across the design and development lifecycle]: http://betterbydesignconference.com/workshops/workshop-accessibility-design-development-life-cycle/
[Josh Blue]: http://www.joshblue.com/
[Just Ask: Integrated Accessibility throughout Design]: http://uiaccess.com/accessucd/
[Karl Groves]: http://www.karlgroves.com/
[Lean UX]: http://www.jeffgothelf.com/lean-ux-book/
[Mocha]: https://mochajs.org/
[pattern lab]: http://patternlab.io/
[Selenium WebDriver]: http://www.seleniumhq.org/projects/webdriver/
[Should]: https://github.com/shouldjs/should.js
[tenon.io]: https://tenon.io/
[WAI-ARIA Authoring Practices 1.1]: https://www.w3.org/TR/wai-aria-practices-1.1/
[WCAG Silver community group]: https://www.w3.org/community/silver/
