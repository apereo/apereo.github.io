---
layout:     post
title:      Summer 2017 uPortal Roadmap Update
summary:    Primarily summarizing the Open Apereo 2017 uPortal Roadmap BOF.
tags:       [uPortal]
---

# Summary
Almost two dozen conference attendees came to the uPortal Roadmap BOF at the Open Apereo 2017 conference. Prior to the conference, members of the community were invited to submit and comment on roadmap ideas in [a shared google doc](https://goo.gl/wZ7VTC). 15 items were suggested but during the BOF we focused on which ones we anticipated someone would actually devote time and resources to. In the end, we anticipate making progress over the next year on the 8 items listed below.

# Release of uPortal 5
This long awaited release includes a refactoring of the build system using a Gradle-based build in the uPortal-start repository. We are currently aiming for a mid-September release candidate and feature freeze followed by a GA release by the end of October.

# Semantic versioning and releasing often
While no specific action items were identified, we renewed our commitment to ship releases more often and use semantic versioning when doing so. We should not be afraid of doing more frequent major releases.

# Better web service API documentation
Most of the existing web service APIs are not well documented. This makes them harder to use or sometimes even be aware of. There was a commitment to documenting new APIs that are developed. UW-Madison committed to documenting APIs it depends on.

# Easier adoption: Complete and accurate documentation
A work in progress, we are looking at shifting uPortal 5 documentation to github.io with an initial focus on installing and configuring core uPortal. This remains in early stages and the details are in flux. Discussion continues on the uportal email lists.

# Separation of presentation layer
This will be a work in progress for some time. While uPortal Home has adopted this modern architecture, uPortal core is being refactored piecemeal. It is anticipated that developers will move towards more modularization as they work with specific parts of the codebase.

# uPortal install - demo edition (fka QuickStart)
This would be a modern version of the quick start we used to publish with uPortal releases. Someone interested in seeing uPortal in action would be able to download the demo edition and have it running locally within minutes. 

# uPortal install - front end developer edition
While the demo edition is targeted for demonstration purposes only, this version of uPortal is an easy way for front end developers to stand up a uPortal server locally, turn it on, and start developing the front ends of applications. The only additional requirements would be downloading a JDK and git client and cloning the uPortal-start repo.

# Develop a lightweight uPortal ecosystem incubation process
Developers in the uPortal community are doing interesting innovative work for local campuses that others could benefit from yet this work cannot be easily adopted. This roadmap item is an effort to lower the barriers to local work participating more directly in the greater uPortal ecosystem. The uPortal Steering Committee is close to issuing a draft of a process that, given certain assumptions, will make it easier for someone to share code without having to go through the full Apereo project incubation process. Everyone has some code to share. Borrowing from the Sirius Cybernetics Corporation, “Share and enjoy!”
