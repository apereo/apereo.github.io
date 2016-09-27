---
layout:     post
title:      Singing "I Love Bug Reports"
summary:    A personal, painfully obvious recipe for handling bug reports in open source.
---

Having been involved in the open-source space for some time, I have noticed that various communities and software engineers react differently to bug reports and issue submissions. Some tend to discuss issues and shortcomings of the software *in private* as developers may consider those defects cause for embarrassment and failure! Some tend to disregard issues and close the conversation loop immediately, routing the user to other *appropriate* channels and reemphasizing a *this is not a bug* mentality without any sort of user education or guidance. Some welcome bug reports in all shapes and sizes and consider those an acknowledgement and positive feedback even when/if the underlying reported problem turns out to be moot.

Here is my personal recipe.

## If you are about to submit a bug

### Data, Data, Data

Always ensure you have enough diagnostics data in your report. Are you reporting the exact version numbers that exhibit the seemingly-faulty behavior? Have you described your deployment/development environment in enough detail? Have you included error logs, screenshots and other useful snippets of your configuration to demonstrate the issue? Have you included steps to explain how one might duplicate the problem? Unit tests to recreate the issue?

Put another way; readers of your case aren’t necessarily housed in your head! They don’t know what you know. Help them out. Would you want to respond to your own report? Think about that before you press submit.

### Is this a bug?

Research the issue and be sure to do your due diligence. Have you scanned the web archives for similar cases? Have you looked at the project’s documentation to find better explanations? Have you reviewed the project’s mailing lists, chatrooms and other facilities to find possible solutions?

### Should I submit?

Some projects consider their issue tracking system as a placeholder to track genuine traceable issues and tasks. If you have a general question about the workings of the software, or if you’re unsure how something is supposed to work and are in need of an analysis and further discussion, consider choosing alternative vessels for contact. Use mailing lists, chatrooms, Stackoverflow and other similar tools to engage with the project owners. When the dust has settled and you have arrived at a legitimate theory to explain the root cause of the problem, file a submission.

### Be part of the solution

If you can, always volunteer to post a patch and work up a solution. Be prepared to follow up to test the produced patch in your environment and always try to provide a confirmation. Simply complaining about something and letting it sit in the issue tracker for someone else to handle isn't going to get you much.

If you find something that you deem worth someone else's time to fix for you, be sure to demonstrate the issue is first and foremost worth your own time as well. “It ain’t a problem for me if it ain’t a problem for you”, sort of thing.

## If you are responding to a bug

### Collaborate

Bugs are an opportunity for collaboration. They allow you to engage with the community and start a conversation. It's a two-way street. After all, that's why you're involved in open-source, right?

### Marketing

Bug reports are the perfect opportunity for marketing. It’s free data! You get to learn which entities and companies from which industry sectors use the software. And how. The more you get involved, the more advertising and marketing is going to flood your way and that might radically change the way you think about the original platform requirements.

### Learn

Bug reports are fun; you learn how people are actually using the software in ways you had never imagined, which may influence you more on a technical level to rethink design, implementation and learn about new integration prospects and partners.

### Be nice

This is perhaps **the most important bit of all**. Do NOT ever create an atmosphere where the user community feels like they are being treated as buffoons with severe visual impairments who are dispossessed of the ability to read your perfect documentation and walkthroughs. As far as you should be concerned, [albeit a tad too extreme perhaps], if someone can’t figure out how to use the solution in reasonable time, then the bug is on you. Resists the urge to call out folks on their “stupid mistakes” and don’t be inclined to respond to every single “foolish” post. Eat something sweet. The feeling will pass, I promise you.

Be nice. Welcome bug reports with open arms.

[Misagh Moayyed](https://twitter.com/misagh84)
