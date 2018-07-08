---
layout:     post
title:      "feat(conventional_commits): signal breaking changes in commit titles"
summary:    In which I suggest Conventional Commits should be enhanced to
            reflect the breakingness of commits in their commit message titles.
tags:       [Blog]
---

## Short version

+ I like [Conventional Commits][].
+ Conventional Commits miss an important opportunity to signal the breakingness
  of change in the _title_ rather than just the _body_ of a commit message.
+ Introducing a ["BREAK: " prefix][BREAK prefix idea] might be a good way to do
  this. There are other ideas.
+ Call to action: help make Conventional Commits better in this and other
  respects

Status quo:

```
feat: split `ROLE_VIEW_ABSENCE_HISTORIES`
```

(Is this a breaking change? You'll have to read the exciting commit message body
and footer to find out...)

Better:

[`BREAK: feat: split ROLE_VIEW_ABSENCE_HISTORIES`][BREAK prefix idea]

or

[`!feat: split ROLE_VIEW_ABSENCE_HISTORIES`][glyph idea]

or

[`FEAT: split ROLE_VIEW_ABSENCE_HISTORIES`][ALL-CAPS idea]

## Conventional Commits

I like [Conventional Commits][].

Conventional Commits are a commit message format specification. Much of the
value of Conventional Commits is in encouraging _semantic commits_ that thoughtfully express carefully crafted units of meaning.

[Like Jeremy Mack][Jeremy Mack on semantic commit messages], I think that taking
care to compose single-thought semantic commits makes me a better programmer.

Conventional Commits look like this:

```
feat: turbocharge the whatsit
```

That token at the front is the _type_, followed on the line by a super-brief
_description_. This first line altogether is the _title_ of the
commit message.

Conventional Commit messages have an optional body

```
fix: correct the twinkle

The twinkle was not previously astronomically correct;
this fix corrects to a precision of six decimal places.

Fixes #14
```

Conventional Commits thinks of the last part of the body as an optional
_footer_.

Conventional Commits can also express a _scope_, an area of the project where
the change type is being applied.

```
docs(song): note that carbon stars are sort-of diamonds in the sky
```

### Characterizing breaking changes in the body or footer

Conventional Commits are meant to help with [Semantic Versioning][]. A
release containing only backwards-compatible fixes like

```
fix: tighten the goober
```

would be a _patch_ release (like 2.4.1).

A _minor_ release (like 2.5) introducing new features would include commits like

```
feat: expose HRS URLs in the JSON API at /api/urls
```

One is meant to be able to take a look at the commit log and thereby figure out
what sort of Semantic Versioning bump is in order. An adopter faced with a major
release is meant to be able to look at the commit history to inspect the
breaking changes.

Conventional commits of any type can be API-breaking changes. These changes
occasion a _major_ version change (5 to 6, say) in Semantic Versioning. An
author notes the breakingness of a change (and advice for how clients of the
library might adapt to the breaking change) in the _body_ or _footer_ of a
Conventional Commit.

So,

```
fix: correct spelling of referrer in header

BREAKING CHANGE: Rather than using misspelled "Referer" as name of header,
instead use correct spelling "Referrer". Clients expecting "Referer" will no
longer receive that header  and will presumably not honor the new "Referrer"
until updated to support this new name for this header.
```

## Improving Conventional Commits: signal the breakingness in the commit title

There are contexts in which only the _title_ and not the _body_ of commit
messages display, e.g. in GitHub's presentation of a branch's history or in
some Git command line tooling.

Which of these are breaking changes?

```
fix: correct spelling of referrer in header
fix: correct spelling of referrer in label
fix: tighten the wingnut
feat: bolt on the blender
```

You can't tell from the commit title. You'd have to look at the body of the
message for each one to realize that e.g. the header spelling fix is a breaking
change.

I think Conventional Commits should be improved to reliably reflect the
breakingness of change in the _title_ of the commit rather than just in the
_body_. There are a few ideas on how to do this:

### The [sigil idea][]

```
!fix: correct spelling of referrer in header
```

A sigil is delightfully succinct. However, it might not be immediately apparent
to a naive reader what meaning that `!` is trying to convey.

Question: how would a screen reader or other accessibility tool treat that
glyph?

### The ALL-CAPS idea

```
FIX: correct spelling of referrer in header
```

This solution consumes zero characters. It's also relatable in that ALL-CAPS ON
THE INTERNET IS SHOUTING and that's just the idea, to shout out the most
important changes so that adopters can more readily identify the changes that
are breaking their usages. I think it's likely as readable and self-evident as
a glyph, and it's elegant that it consumes zero characters.

However, Conventional Commits has not to date specified the capitalization of
_type_. Some have argued for specifying the capitalization, or specifying that
the capitalization is unspecified. In any case it's the kind of thing developers
might be inconsistent about. Any inadvertent ALL-CAPS commit messages will be
false positives for this signal.

Question: how well would a screen reader or other accessibility tool present the
fact that the _type_ is ALL-CAPS rather than lowercase?

### The [prefix idea][BREAK prefix idea]

```
BREAK: fix: correct spelling of referrer in header
```

I like this solution best. It consumes 7 characters, but it's also more
self-documenting, more readily apparent even to someone unfamiliar with
Conventional Commits what it's trying to say. Which commits are the breaking
changes? Oh yeah, the ones that are shouting at me "BREAK".

## Call to action

I think that some (required!) way of indicating the breakingness
of change in Conventional Commit titles should be specified. What is often the
most important thing to say about a breaking-change commit shouldn't be only in
the body of the message.

Maybe you have other ideas for how to convey breakingness in Conventional Commit
commit titles. Maybe you have some expertise to offer about how screen readers
and other accessibility tools would present the title under the different
options under consideration. Maybe you like one of these ideas. Maybe you too
don't know which solution should be adopted but really wish Conventional Commits
would go ahead and accept _some solution_ so that identifying breaking changes
in repositories using Conventional Commits will get easier sooner. Maybe you
like the status quo just fine and don't want to see Conventional Commit titles
change for this.

However you think this ought to play out, engage
[in GitHub][Conventional Commits GitHub repo] to help make it happen.

## References and learn more

+ [Bookmarks about Conventional Commits][Conventional Commits Pinboard tag]

Author: [Andrew Petro](https://twitter.com/awpetro)

[ALL-CAPS idea]: https://github.com/conventional-changelog/conventionalcommits.org/pull/63
[BREAK prefix idea]: https://github.com/conventional-changelog/conventionalcommits.org/pull/64
[Conventional Commits]: https://conventionalcommits.org/
[Conventional Commits GitHub repo]: https://github.com/conventional-changelog/conventionalcommits.org
[sigil idea]: https://github.com/conventional-changelog/conventionalcommits.org/issues/43
[Conventional Commits Pinboard tag]: https://pinboard.in/u:microcline/t:conventional_commits/
[Jeremy Mack on semantic commit messages]: https://seesparkbox.com/foundry/semantic_commit_messages
