---
layout: post
title: Performance improvements on the service registry
summary: An overview of the work done on performance.
tags: [CAS]
---

This is a task planned through NLNet funding.


# Context

When it comes to the CAS server, performance is generally not a concern. Going with the defaults should be enough in 99% of cases.

However, in some rare edge cases, the performance of the service registry can become a problem. The service registry is the storage used to define all the applications allowed to authenticate with the CAS server via the CAS, OAuth, SAML, or OpenID Connect protocols.

With a few hundred services, performance can drastically deteriorate. Therefore, we have worked on improving the performance of the service registry for all use cases.

Benchmarks and profiling have been conducted to understand the main hotspots of time consumption. Two features are particularly resource-consuming: sorting services and matching services.


# Better sorting

Despite careful code reviews, there is always room to improve the source code. The first action we took was to turn the internal `Comparator` used in the `BaseRegisteredService` component into a singleton shared across all instances:

```java
    private static final Comparator<RegisteredService> INTERNAL_COMPARATOR = Comparator
        .comparingInt(RegisteredService::getEvaluationPriority)
        .thenComparingInt(RegisteredService::getEvaluationOrder)
        .thenComparing(service -> StringUtils.defaultString(service.getName()), String.CASE_INSENSITIVE_ORDER)
        .thenComparing(RegisteredService::getServiceId)
        .thenComparingLong(RegisteredService::getId);
```

as well as improving string comparison by using `String.CASE_INSENSITIVE_ORDER`.


# Better matching

In Java pattern matching, creating regex patterns is always very time-consuming, and a global cache was already available to improve performance.

However, thorough tests have shown that things could be improved further in this area by using a specific property to store the regex pattern in `BaseRegisteredService`:

```java
    @JsonIgnore
    @Getter(AccessLevel.NONE)
    @Setter(AccessLevel.NONE)
    @Transient
    private transient Pattern patternServiceId;

    ...
    
    /**
     * Set the service identifier and pre-compute its regex pattern.
     *
     * @param serviceId the service id
     */
    @CanIgnoreReturnValue
    public BaseRegisteredService setServiceId(final String serviceId) {
        Assert.notNull(serviceId, "Service id cannot be null");
        this.serviceId = serviceId;
        this.patternServiceId = RegexUtils.createPattern(serviceId);
        return this;
    }
    
    @Override
    public Pattern compileServiceIdPattern() {
        if (this.patternServiceId == null) {
            setServiceId(this.serviceId);
        }
        return this.patternServiceId;
    }
```

And to use it for matching:

```java
    @Override
    public boolean matches(final RegisteredService registeredService, final String serviceId) {
        return registeredService.compileServiceIdPattern().matcher(serviceId).matches();
    }
```

With these two improvements, the benchmark (on a CAS server with 1000 services) between version `8.0.0-RC1` and the latest version `8.0.0-SNAPSHOT` shows that _the reference time drops from 81 seconds to 51 seconds_!


# Going further

Despite these improvements, the benchmarks still show that a lot of time is spent in the "sorting phase":

<img src="{{ site.url }}/images/perfservregis_flamegraph.png" />

The slowdown is located in the `getCandidateServicesToMatch` method of the `DefaultServicesManager` component. Indeed, despite the cache of services, the `sorted` clause is still applied and consumes a lot of time.

So, in the case of a cache size set to 0:

```yaml
cas.service-registry.cache.initial-capacity: 0
cas.service-registry.cache.cache-size: 0
```

we now keep a copy of the sorted list of services, which makes processing much faster.

With this change in place and enabled (size set to 0), _the benchmark time drops again to 24 seconds!_

This might be a new option to enable if you have clearly identified that the service registry does not perform well in your CAS deployment.


# Availability

The performance improvements described in this document will ultimately be available in CAS `8.0.0`, and you should be able to benefit from them as of `8.0.0-RC2`.

On behalf of the CAS project,

[Jerome LELEU](https://github.com/leleuj)
