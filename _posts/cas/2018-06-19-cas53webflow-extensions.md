---
layout:     post
title:      Apereo CAS - Extending Webflows
summary:    Learn and master extending CAS 5 Spring Webflow definitions.
tags:       [CAS]
---

<div class="alert alert-success">
  <strong>Collaborate</strong><br/>The blog is managed and hosted on GitHub. If you wish to update the contents of this post or if you have found an inaccuracy and wish to make corrections, we recommend that you please submit a pull request to <a href="https://github.com/apereo/apereo.github.io">this repository</a>.
</div>

Unlike previous versions, CAS 5 attempts to automate all required Spring Webflow changes on a per-module basis. In this new model, all one should have to do is to declare the appropriate module in the build script...and viola! CAS will take care of the rest.

If you wish to learn how that is done internally and furthermore, how you may take advantage of the same approach to extend CAS webflows and introduce your own, this is the right post for you.

This tutorial specifically requires and focuses on:

- CAS `5.3.x`
- Java 8
- [Maven WAR Overlay](https://apereo.github.io/cas/development/installation/Maven-Overlay-Installation.html)

To learn the same answers with CAS `5.0.x`, please [see this post](https://apereo.github.io/2016/10/07/webflow-extcfg/).

# Webflow Configurers

Every CAS module that needs to dynamically augment the Spring Webflow routes simply takes on the following form:

```java
package com.example.cas;

public class SomethingWebflowConfigurer extends AbstractCasWebflowConfigurer {

    public SomethingWebflowConfigurer(final FlowBuilderServices flowBuilderServices,
                                    final FlowDefinitionRegistry loginFlowDefinitionRegistry,
                                    final ApplicationContext applicationContext,
                                    final CasConfigurationProperties casProperties) {
        super(flowBuilderServices, loginFlowDefinitionRegistry, applicationContext, casProperties);
    }

    @Override
    protected void doInitialize() throws Exception {
        final Flow flow = super.getLoginFlow();
        // Magic happens; Call 'super' to see what you have access to...
    }
}
```

CAS modules register their `WebflowConfigurer` instances in `@Configuration` classes:

```java
package com.example.cas;

@Configuration("SomethingConfiguration")
public class SomethingConfiguration implements CasWebflowExecutionPlanConfigurer  {

    @Autowired
    @Qualifier("loginFlowRegistry")
    private FlowDefinitionRegistry loginFlowDefinitionRegistry;

    @Autowired
    private FlowBuilderServices flowBuilderServices;

    @Autowired
    private ApplicationContext applicationContext;

    @Autowired
    private CasConfigurationProperties casProperties;

    @ConditionalOnMissingBean(name = "somethingWebflowConfigurer")
    @Bean
    @DependsOn("defaultWebflowConfigurer")
    public CasWebflowConfigurer somethingWebflowConfigurer() {
        return new ConsentWebflowConfigurer(flowBuilderServices, loginFlowDefinitionRegistry,
            applicationContext, casProperties);
    }
}
```

Note that each `CasWebflowConfigurer` implementation may be assigned a specific *order* which is a numeric weight that determines its execution position once webflow auto-configuration kicks into action.

<div class="alert alert-warning">
  <strong>Remember</strong><br/>If you are looking for XML flow definitions to extend CAS, you are simply holding it wrong. While you may be creative enough to find a solution and make that approach work, it is pretty much guaranteed that your design will break quite quickly in the next upgrade.
</div>

Next, we just need to ensure that CAS is able to pick up our special configuration. To do so, create a `src/main/resources/META-INF/spring.factories` file and reference the configuration class in it as such:

```properties
org.springframework.boot.autoconfigure.EnableAutoConfiguration=com.example.cas.SomethingConfiguration
```

...and that should be it.

# So...

CAS itself handles Spring Webflow changes related to its first-class features by default automatically. That strategy equally applies, should you need to write your own configurers if you absolutely need to. Be sure to take extra as accidents may happen. What if you have two `WebflowConfigurer`s who all decide to inject actions and state into the same Spring Webflow areas? What if multiple `WebflowConfigurer`s are competing to set themselves up as starting points of the CAS webflow? Who wins, who mourns?

Indeed, these are questions you ought to be thinking about as a *developer*. With power comes responsibility.

# Remember

- Changes are all scoped to one technology, that is Java.
- You have the full power of Java to dynamically augment the Spring Webflow as you see fit.
- Your changes are all self-contained.
- Unlike XML, your changes are now part of the CAS APIs. If you upgrade and something breaks, you will be notified immediately at build time.

That's all.

[Misagh Moayyed](https://twitter.com/misagh84)
