---
layout:     post
title:      Hope for GitHub Pages
summary:    GitHub Pages could be a win for Apereo beyond blogging.
tags:       [Blog]
---

# Short version

+ "+1" for Apereo adoption of [GitHub Pages][] for this website.
+ I'm hopeful for applying this approach beyond blogging.
+ Static site generators have lots of advantages. Those advantages align with Apereo values and realities.
+ Call to action to use [GitHub Pages][] more and better and thereby make Apereo websites better.


# +1

I'm really excited and supportive about Apereo's adopting [GitHub Pages][] for this website, and I'm hopeful about using it for more than just a blog.

Not only do I concur that this is a good idea,

<iframe width="560" height="315" src="https://www.youtube.com/embed/dm1p9mE9RBw?rel=0&t=2s" frameborder="0" allowfullscreen></iframe>

(Which is to say, "+1", in Apache parlance.)

# Advantages of static site generator websites

[Jekyll][]-driven [GitHub Pages][] has tremendous advantages aligned with Apereo values and operations.

+ Driving the website by [a public Git repository](https://github.com/apereo/apereo.github.io) improves **transparency**. It means anyone can inspect the content and [history](https://github.com/apereo/apereo.github.io/commits/master) of the site to understand just what is being said and the history of saying it. And anyone can inspect the program that generates the site from the content files. Not just the open source technology used in the abstract - the [specific configuration](https://github.com/apereo/apereo.github.io/tree/master/_layouts), instantiation of that automation.
* Driving the website by a public GitHub repository improves **openness**. It means [anyone can propose a change](https://help.github.com/articles/creating-a-pull-request/). Anyone can even [edit through the GitHub UI in a Web browser](https://help.github.com/articles/editing-files-in-another-user-s-repository/) if working with text files locally is off-putting.
* Driving the website by a public GitHub repository improves **meritocracy**. It means when anyone proposes a change, that proposed change can be publicly evaluated on its merits. GitHub Pull Requests and their [review features](https://help.github.com/articles/reviewing-changes-in-pull-requests/) are a beautiful thing.
* Driving the website by a public GitHub repository improves **collaboration**. It means anyone can collaborate with anyone in any branches they need, in public or private forks if need be.
* Modeling the website content as text files in a public GitHub repository better enables (much) **better tools for working on the content**. Programmers edit text files. A website that is fundamentally text files as content is more amenable to programmers and technically minded people doing great things efficiently. `grep` and its kin are beautiful and powerful. As is your text editor of choice.
* Driving the website by an open and openly configured static site generator enables (much) **better tools for working on the website framework**. To the extent necessary, programmers can collaborate not just on the content but also on the "program" that generates the website from the content -- the CSS, the templating, all the way through [the free and open source static site generator framework itself][Jekyll].
* GitHub Pages is much better aligned with affordable and sustainable Apereo operations practices. Apereo runs very thin on infrastructure and even thinner on staff and volunteer bandwidth to wrangle infrastructure. GitHub Pages **adds zero to Apereo's server and database footprint**.
* GitHub Pages websites are also **free as in cheapness**, which lines up well with Apereo funding levels. Apereo maybe should pay someone to develop awesome website content (arguable). Apereo definitely shouldn't be paying anyone to host a website, operate its database, keep WordPress patched. Accept free-as-in-cheapness infrastructure for commodity website hosting and repurpose scarce resources for something more higher-ed-open-source-IT-aligned.
* Static site generators enable higher quality results. It's easier for web developers to collaborate on making a website much sharper, much snappier, much better when using sharper tools.
* Using [Jekyll][]-driven [GitHub Pages][] **eases future migrations**. While GitHub Pages operates with panache, [Jekyll][] is open source and generates a static website that can be served up from just about anywhere on just about any technology stack. Using GitHub Pages *doesn't* entail vendor lock-in.
* Using [Jekyll][]-driven [GitHub Pages][] eases future migrations. If Apereo ever wants to port this content to a different website management platform, well, all the content is just text files. It's hard to beat that as a friendly starting point for laying hands on this content and importing it into something else.

(These are advantages of open source public-git-repository-driven static site generators more generally. Jekyll-driven GitHub Pages is a particularly nice implementation of an approach that can be achieved with more hassle using other specific technologies.)

# Examples of use of GitHub Pages, outside and within Apereo

Okay, so [GitHub Pages][] in particular, and static site generators more generally, are technically awesome. You might reasonably ask, why is this website nonetheless so very ugly?

I want to assure that GitHub Pages sites can be beautiful, usable, arbitrarily comprehensive, etc.

GitHub has a [showcase of GitHub Pages examples][]. These are some of the more website-flavored examples:

+ [Electron](http://electron.atom.io/community/)
+ [react](https://facebook.github.io/react/)
+ [developer.github](https://developer.github.com/)

We need not look so far afield to find examples of using GitHub Pages to make websites happen: there are usages within Apereo already.

* [CAS](https://apereo.github.io/cas/)
* [OpenDashboard](http://apereo-learning-analytics-initiative.github.io/OpenDashboard/)
* [OAE][oaeproject.org] (note this demonstrates that GitHub Pages sites can have arbitrary hostnames, don't have to be .github.io branded.)
* [Tsugi](https://csev.github.io/tsugi/)

# Next steps

Better is better. Make things better, and then make things better again. Repeat.

I believe that static site generator approaches are better than database-backed-web-application approaches (WordPress, Drupal, even my beloved Ghost) for web sites, more often than not.

GitHub Pages-driven [oaeproject.org][] feels more awesome, more beautiful, more full of potential to me than does [its equivalent pages within apereo.org](https://www.apereo.org/projects/apereo-oae).

The next step is to do more of that. To keep making Apereo content better using better tools. And then to repeat.

I hope these steps will add up to a walk will be a walk out of database-backed website solutions and into static site generator solutions, for the better productivity, quality, openness, transparency, and sustainability of Apereo website delivery.

# Disclaimer

Opinions expressed are my own and are not necessarily those of Apereo, of my employer, of the uPortal project, or of other projects and organizations with which I am involved.

[Andrew Petro](https://twitter.com/awpetro)

[GitHub Pages]: https://pages.github.com/
[Jekyll]: https://jekyllrb.com/
[Showcase of GitHub Pages examples]: https://github.com/showcases/github-pages-examples
[oaeproject.org]: http://oaeproject.org/
