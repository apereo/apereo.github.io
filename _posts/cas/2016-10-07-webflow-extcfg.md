---
layout:     post
title:      Extending CAS 5 Webflows
summary:    Learn and master extending CAS 5 Spring Webflow definitions.
---

Unlike previous versions, CAS 5 attempts to automate all required Spring Webflow changes on a per-module basis. This aligns well with the new `IDD` (Intention-Driven Development) model where all one should have to do is, declare the appropriate module in the build script...and viola. CAS will take care of the rest.

You may ask: Wait! What's really happening? How can it accomplish everything that we had to apply manually before? Why am I being asked to do less work? What exactly do the CAS internals look like? Did machines finally take over? Most importantly, Turkey's [tombili](http://ind.pn/2dsJ0iV) died?!

Some answers follow.

# Hakuna Matata

Stop worrying. Stop coding. You are no longer required to become a Spring Webflow ninja or Java champion overnight to apply a myriad of XML configuration snippets here and there to get something to work. That's all taken care of for you. Sit back and relax.

More importantly, avoid making ad-hoc changes to the Webflow as much as possible. Consider how the change you have in mind might be more suitable as a direct contribution to CAS itself so you can just take advantage of its configuration; NOT its maintenance.

If you find something that is broken where the auto-configuration strategy fails to deliver as advertised, discuss that with the project community. Submit an issue and/or file a patch. Avoid one-off changes.

# The "Flexibility" Argument

You may have been illusioned to think that the auto-configuration strategy is less powerful because much of the configuration is hidden away and you no longer have the flexibility to change anything and everything.

Consider:

- Just because you had access to 20 configuration files, that did not mean that you could go about changing anything and everything. This claim is not a question of capability. It's a question of sanity and rationale. Is there a reason the project should expose you to 20 files where in reality, you mostly should, nay, MUST care about just a few?
- Similarly, just because you now have access to only a few configuration files that does not mean your capabilities of modifying the software internals are now diminished and your freedom lost. The mechanics may have changed but not the underlying principals.

In fact, you can do A LOT MORE.

# What Did You Do?

So in the olden days, the following recipe was *more or less* what was done:

1. Write a Spring Webflow `Action` in Java that does X.
2. Declare a Spring bean definition in `XML` that configures that action class.
3. Modify the Spring Webflow configuration to point to that action at the right injection point.

Wait. I may have missed a few steps. The recipe did also include:

1. A degree in software engineering and/or computer science may be needed.
2. Learn Java
3. Learn Spring; Convince yourself that this is really expected of you.
4. Learn Spring Webflow; Convince yourself that this is really expected of you.
5. Learn CAS APIs
6. Learn CAS Spring Webflow

What is also inconsistent with this strategy is that a perhaps-simple change spanned across multiple unfamiliar barriers. Even if you learned and mastered all the underlying technologies, you still needed to touch Java, Spring XML and Spring Webflow XML configuration to get something to work.

Is that verbosity the same thing as flexibility?

# So, Now What?

Every CAS module that needs to dynamically augment the Spring Webflow routes simply takes on the following form:

```java
public class SomethingWebflowConfigurer extends AbstractCasWebflowConfigurer {
    @Override
    protected void doInitialize() throws Exception {
        final Flow flow = super.getLoginFlow();
        // Magic happens; Call 'super' to see what you have access to...
    }
}
```

CAS modules register their `WebflowConfigurer` instances in `@Configuration` classes:

```java
@Configuration("SomethingConfiguration")
public class SomethingConfiguration {

    @Autowired
    @Qualifier("loginFlowRegistry")
    private FlowDefinitionRegistry loginFlowDefinitionRegistry;

    @Autowired
    private FlowBuilderServices flowBuilderServices;

    @ConditionalOnMissingBean(name = "somethingWebflowConfigurer")
    @Bean
    public CasWebflowConfigurer somethingWebflowConfigurer() {
        final SomethingWebflowConfigurer w = new SomethingWebflowConfigurer();
        w.setLoginFlowDefinitionRegistry(this.loginFlowDefinitionRegistry);
        w.setFlowBuilderServices(this.flowBuilderServices);
        ...
        return w;
    }
}
```

When CAS comes up, it scans the context to find `@Configuration` classes and then will invoke each and every `WebflowConfigurer` to execute changes.

# What About You?

CAS itself handles Spring Webflow changes related to its first-class features by default automatically. That strategy equally applies, should you need to write your own configurers if you absolutely need to.

## Accidents Happen

What if you have two `WebflowConfigurer`s who all decide to inject actions and state into the same Spring Webflow areas? What if multiple `WebflowConfigurer`s are competing to set themselves up as starting points of the CAS webflow? Who wins, who mourns?

Indeed, these are questions you ought to be thinking about as a *developer*. With power comes responsibility.

# Summary

Today:

- Changes are all scoped to one technology, that is Java.
- You have the full power of Java to dynamically augment the Spring Webflow as you see fit.
- Your changes are all self-contained.
- Unlike XML, your changes are now part of the CAS APIs. If you upgrade and something breaks, you will be notified immediately at build time.

That's all.

[Misagh Moayyed](https://twitter.com/misagh84)
