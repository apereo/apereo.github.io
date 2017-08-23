---
layout:     post
title:      "React is not open source"
summary:    An allergic reaction to the React Facebook-3-clause-BSD-plus-PATENTS license.
tags:       [licensing]
---

No, you shouldn't use React in an Apereo project, or in any Apache2-licensed project, or in any other project either.

_Disclaimer: I am not a lawyer; this is not legal advice; I do not speak authoritatively for Apereo about this or anything else; while I serve as chair of the Apereo Licensing group **this post is written wearing my individual contributor hat, not my chair hat**._

"Open source" means something. That something isn't merely access to the source code. (This is part of why I prefer the term "FLOSS" aka "Free-libre open source software", because it reminds that it's essential to consider not just access to the source code but what freedoms are afforded over that source code.)

Fundamentally, software is open source if you can

+ access the source code and the necessary tooling to build that source code to a working product
+ redistribute that source code
+ modify that source code
+ redistribute your modifications to the source code

Fortunately, there's the Open Source Initiative and its work to independently evaluate and catalog the open source licenses in the world.

So, React. React is licensed under the three-clause BSD license, a perfectly acceptable open source software license. With some additional licensing terms around patents that specifically terminate patent licenses necessary to use React in the case where you bring a patent claim against Facebook. Any patent claim. Even an unrelated patent claim.


This isn't an accident. Facebook is doing this on purpose. They're trying to reduce the ability of others to bring patent claims against Facebook through popular adoption of Facebook products under terms that make those claims less feasible.


Here's the thing. Maybe you have a legitimate patent claim against Facebook, or maybe sometime in the future you will. That's not really any of my business. My software shouldn't come with strings attached that make those potential claims less viable for you, the adopter.

