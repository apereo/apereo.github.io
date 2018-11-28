---
layout:     post
title:      Why does uPortal use Apache 2 license?
summary:    Apache2 chose uPortal.
tags:       [uPortal, Licensing]
---

> [I’d be interested to hear what licenses other projects were using, and 
why?][2018-02-08 licensing-discuss]

## What license does uPortal use?

The easy part of the question: uPortal is using [Apache License 2.0][].

## Why did uPortal license away from New BSD, its original license?

The hard part of the question: why?

In the beginning (in the JA-SIG, or JASIG, or Jasig days), uPortal used the 
[BSD 3-Clause aka New BSD license][New BSD].

In the run up to merging with the Sakai Foundation to become the Apereo 
Foundation, Jasig adopted the position that New BSD is not good enough, which 
is now [Apereo's documented position][apereo licensing].

> This license simply does not provide enough protection for either 
contributors or adopters to really understand the terms under which the 
software is being shared.

(I don't agree with this statement. New BSD meets the [Open Source 
Definition][], and it thoroughly disclaims warranties and liabilities. Good 
enough is good enough. I'd have no qualms about contributing to or adopting a 
New BSD licensed software product.)

[GNU says this about 3-clause BSD][gnu license-list ModifiedBSD]:

> The modified BSD license is not bad, as lax permissive licenses go, though 
the Apache 2.0 license is preferable. ... the Apache 2.0 license is better for 
substantial programs, since it prevents patent treachery.

Maybe how badly you want to re-license away from New BSD hinges on how worried 
you are about patent treachery.

Some people worried. So Jasig required uPortal to re-license.

So that's why not New BSD.


## Why did uPortal re-license to Apache2, its current license?

I don't recall just how Apache2 was selected, who did the selecting, what alternatives were considered. I don't even recall if this is something I once knew and have forgotten.

A 2008 document in the Jasig wiki, [Open Source Licensing][Open Source 
Licensing doc], (by Unicon / John Lewis) recommends Apache2 for the 
non-copyleft case and might have been influential.

Guessing at what might have happened:

Do what the Apache Software Foundation does.

Apache2 is widely adopted, widely understood, well documented, the practices 
around it are well documented and honed by the Apache Software Foundation. It's 
not just a viable license, it's a viable license ecosystem.

Nobody has to apologize for adopting Apache2, it's one of those default, 
acceptable, generally recognized as safe licenses?

[ECLv2][ecl-2.0] would also be fine, it's just less mainstream. uPortal's 
adopters and communities weren't already worked up about Apache2's patent 
language so there wasn't enough reason to start getting worked up about that.

\- Andrew Petro

wearing individual contributor [hat][ASF hats].

The views expressed herein are not necessarily those of Apereo, nor of uPortal, nor of my employer, nor of...


[2018-02-08 licensing-discuss]: https://groups.google.com/a/apereo.org/d/msg/licensing-discuss/kac2gzuHf6E/2Y9OzdRjBQAJ
[apereo licensing]: https://www.apereo.org/licensing
[New BSD]: https://choosealicense.com/licenses/bsd-3-clause/
[Open Source Definition]: https://opensource.org/osd
[Apache License 2.0]: https://choosealicense.com/licenses/apache-2.0/
[gnu license-list ModifiedBSD]: https://www.gnu.org/licenses/license-list.en.html#ModifiedBSD
[ecl-2.0]: https://choosealicense.com/licenses/ecl-2.0/
[ASF hats]: https://www.apache.org/foundation/how-it-works.html#hats
[Open Source Licensing doc]: https://wiki.jasig.org/download/attachments/25002436/open-source-licensing-paper.pdf?version=1&modificationDate=1236022038650&api=v2