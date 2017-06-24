---
layout:     post
title:      CAS 5 - Maintaining Protocol Compatibility
summary:    A short and sweet CAS 5 guide on how to get CAS Protocol v2 to act as v3.
tags:       [CAS]
---

The [third specification of the CAS protocol](https://apereo.github.io/cas/5.1.x/protocol/CAS-Protocol.html) was released around the time CAS `v4.0.0` came into existence. The primary objective of the revision was to bring the spec up to speed with common community practices and extensions, one of which most significantly was the ability to let CAS release attributes to authorized relying parties and applications.

In order to preserve protocol backward-compatibility, a new `/p3/serviceVaildate` endpoint was added whose only job was to release attributes to be consumed by clients. This way, existing CAS clients unable to parse the new `<cas:attributes>` block in the validation response could continue to function as they did. Newer clients could simply hit the new endpoint to receive attributes.

# Problem Statement

There are cases where a certain number of today's CAS clients are perfectly able to consume attributes from CAS protocol `v2`. How? Because support for attributes was an accepted *mod* made by most deployers and client developers. A deployer running some version of CAS `3.x` for instance had already applied the change to CAS for attribute release and had built clients or instructed vendors to build clients such that they all could consume attributes and enjoy coolness.

How's that situation convered in the most recent CAS 5 release line?

# Solution

The trick is to ensure that the component responsible for validating tickets and producing the final payload is using the *correct* versions of the view/response which match that of CAS protocol `v3`. The most bullet-proof way of applying this change is with CAS 5's auto-configuration strategy described below.

## CAS 5.0.x

Design your own `@Configuration` class and have it simply match the following body. This component will be placed inside the CAS overlay under `/src/main/java/org/apereo/cas/config` and it must be housed inside the Java package `org.apereo.cas`. You may need to create the directory structure and you may also need to ensure relevant dependencies are under the `compile` scope so the configuration below can properly compile.

As you can see below, all we are doing is swapping out one set of views with another.

```java
package org.apereo.cas.config;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.View;
import org.apereo.cas.web.ServiceValidateController;

import javax.annotation.PostConstruct;

/**
 * This is {@link CustomConfiguration} that replaces the CAS Protocol 2 validation endpoint (/serviceValidate)
 * with the CAS Protocol 3 (essentially applying the attribute modification to CAS protocol 2..
 *
 * @author John Gasper
 * @since 5.0.x
 */

@Configuration("CustomConfiguration")
public class CustomConfiguration
{
    private static final Logger LOGGER = LoggerFactory.getLogger(CustomConfiguration.class);

    @Autowired
    @Qualifier("serviceValidateController")
    ServiceValidateController serviceValidateController;

    @Autowired
    @Qualifier("cas3ServiceSuccessView")
    View cas3ServiceSuccessView;

    @Autowired
    @Qualifier("cas3ServiceFailureView")
    View cas3ServiceFailureView;

    @PostConstruct
    protected void initializeRootApplicationContext() {
        serviceValidateController.setSuccessView(cas3ServiceSuccessView);
        serviceValidateController.setFailureView(cas3ServiceFailureView);
    }
}
```

## CAS 5.1.x

Same exact strategy as `5.0.x`, except that now you're given the freedom to put the Java component anywhere inside any package in the overlay project, provided it's [correctly registered](https://apereo.github.io/cas/development/installation/Configuration-Management-Extensions.html) with the CAS auto configuration engine.

## CAS 5.2.x

All that is still way too much work,  right? So starting with CAS `5.2.x` all one should have to do is to introduce the following setting in the `cas.properties`:

```properties
cas.view.cas2.v3ForwardCompatible=true
```

That's it.

# So...

Special thanks to [@jtgasper3](https://github.com/jtgasper3) for sharing this neat trick and letting me brag about it. 

[Misagh Moayyed](https://twitter.com/misagh84)
