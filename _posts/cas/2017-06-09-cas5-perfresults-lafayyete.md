---
layout:     post
title:      CAS 5 Load Tests by Lafayette College 
summary:    Lafayette College shares the results of stress tests executed against a recent CAS 5.0.x deployment.
tags:       [CAS]
---

<div class="alert alert-info">
  <strong>Contributed Content</strong><br/>Carl Waldbieser (<code><waldbiec [at] lafayette.edu></code>), an active member of the CAS community, was kind enough to share this analysis.
</div>

<!-- TOC -->

- [Overview](#overview)
- [Deployment Architecture](#deployment-architecture)
- [The Test Swarm](#the-test-swarm)
- [The Trials](#the-trials)
    - [Trial 1](#trial-1)
    - [Trial 2](#trial-2)
    - [Trial 3](#trial-3)
    - [Trial 4](#trial-4)
    - [Trial 5](#trial-5)
    - [Trial 6](#trial-6)
- [Conclusions](#conclusions)

<!-- /TOC -->

# Overview

Load testing trials were conducted on the CAS stage environment in order to provide insight into what kind of sustained load the production CAS service will be able to carry. All trials were carried out against the same deployment architecture, with all nodes configured identically.

# Deployment Architecture

The deployment architecture itself consists of 3 virtual machine nodes. Each node has 3.7 GiB real memory available to it and 2 CPUs.

The characteristics of the CPUs are as follows:

- Architecture: x86_64
- CPU op-mode(s): 32-bit, 64-bit
- Byte Order: Little Endian
- CPU(s): 2
- On-line CPU(s) list: 0,1
- Thread(s) per core: 1
- Core(s) per socket: 2
- Socket(s): 1
- NUMA node(s): 1
- Vendor ID: GenuineIntel
- CPU family: 6
- Model: 42
- Model name: Intel Xeon E312xx (Sandy Bridge)
- Stepping: 1
- CPU MHz: 1899.999
- BogoMIPS: 3799.99
- Hypervisor vendor: KVM
- Virtualization type: full
- L1d cache: 32K
- L1i cache: 32K
- L2 cache: 4096K
- NUMA node0 CPU(s): 0,1

The nodes are deployed behind an Nginx+ proxy in an active-active-active configuration. The nodes share ticket information using encrypted Hazelcast messages, a feature built into the CAS software, so any application state is shared.

# The Test Swarm

The testing framework used was `locust.io`, a Python based load testing framework. The test suite deploys a fixed number of “locusts” against a web site. To lean more about locust, please [see this guide](https://apereo.github.io/cas/5.1.x/planning/High-Availability-Performance-Testing.html).

The initial population ramps up with a configurable “hatch rate”. In the tests, locusts were conceptually divided into 3 “lifetime” categories:

- Short-lived locusts live approximately 60 seconds.
- Medium-lived locusts last for approximately 5 minutes.
- Long-lived locusts exist for approximately 2 hours.

The category to which a given locust is assigned is randomly determined with a ratio of short : medium : long being 7:2:1.  Ideally, 70% of the population is short-lived, 20% is medium lived, and 10% is long-lived.

The lifetime of a locust determines how long it will retain and make use of a single web SSO session.  Short-lived locusts discard their sessions quickly.  Long-lived locusts hold on to them for considerable time.  

All locusts are only 25% likely to log out upon their deaths.  The CAS service must continue to track TGTs of locusts that have not logged out until the ticket expires, so this behavior can put pressure on the memory storage resources of the nodes.

Each locust uses credentials taken randomly from one of 9 test accounts.  Each locust has a 1% chance of entering an erroneous password for an account.  Locusts that fail to authenticate will die immediately.

When a locust dies, it is reborn immediately.  Its lifetime category remains the same, but its SSO session and all other random parameters are reset.

# The Trials

## Trial 1

| # of Locusts  | Hatch Rate    |
| ------------- | ------------- |
| `300`         | `10/s`        |

![](https://user-images.githubusercontent.com/1205228/26984798-cc315252-4d0e-11e7-9802-058f29576dd9.png)

The first trial produced authentication events at a rate of over 3,500 event/minute.  The majority of these were service ticket creation and validation events.  By 13:40 (~5 hours into the trial), degraded performance became noticeable.  By 15:50 (~7 hours in), the nodes were swamped.  The trial was discontinued shortly thereafter.

## Trial 2

| # of Locusts  | Hatch Rate    |
| ------------- | ------------- |
| `300`         | `10/s`        |

![](https://user-images.githubusercontent.com/1205228/26984871-1d38b550-4d0f-11e7-8242-6e7d646f8ca4.png)

The 2nd trial was similar to the first, but the number of locusts was briefly increased to 500 for a 3 minute duration.

The characteristics of trial 2 are very similar to those of trial 1. After responding to ~3,500 / minute for close to 6 hours, the nodes were overwhelmed.

## Trial 3

| # of Locusts  | Hatch Rate    |
| ------------- | ------------- |
| `150`         | `10/s`        |

![3](https://user-images.githubusercontent.com/1205228/26984914-48d894f0-4d0f-11e7-9e68-c43eafb8804b.png)

The 3rd trial used half the number of locusts used in the first 2 trials.  The sustained event rate was ~1,700 authentication events per minute.  Unlike the previous 2 trials, this trial was concluded prior to the nodes becoming overwhelmed.  It is unknown whether the nodes could continue to sustain responding to events at this rate indefinitely.

## Trial 4

| # of Locusts  | Hatch Rate    |
| ------------- | ------------- |
| `50`          | `10/s`        |

![4](https://user-images.githubusercontent.com/1205228/26984957-68665370-4d0f-11e7-82ac-ca61673e09ec.png)

The 4th trial showed the nodes were capable of sustaining a ~600 authentication events/minute rate for a full 24 hours.  Because the maximum lifetime of a TGT is 8 hours, there is some reason to believe this rate could have been sustained indefinitely.

## Trial 5

| # of Locusts  | Hatch Rate    |
| ------------- | ------------- |
| `25`          | `10/s`        |

![5](https://user-images.githubusercontent.com/1205228/26984978-8439edbe-4d0f-11e7-992d-8a80eca2a276.png)

This trial was useful in establishing the mean rate of 291 events per minute given a swarm of 25 locusts.  This test and test 6 are notably shorter in duration than the other tests, as it is assumed at this points the nodes can sustain the loads indefinitely.

## Trial 6

| # of Locusts  | Hatch Rate    |
| ------------- | ------------- |
| `10`          | `10/s`        |

![6](https://user-images.githubusercontent.com/1205228/26985007-a23ce76c-4d0f-11e7-9ccf-670146fc8ba6.png)

The mean rate of authentication events for this trial is 118 events per minute.

# Conclusions

Measurements taken from the production CAS service from April 17-21, 2017 during normal business hours (9am to 5pm) have the following characteristics:

| Mean          | Median        | Mode          | Max           | Min           | Std Dev           |
| ------------- | ------------- | ------------- | ------------- | ------------- | ----------------- |
| 149 events/minute   | 139 events/minute | 126 events/minute | 494 events/minute | 2 events/minute | 68 |

While there appears to be some “burstiness” in the rate of authentication events, all 3 types of averages are well below the the expected threshold which the trials suggest are indefinitely sustainable.  Even the maximum rate of 494 events per minute is well below the sustained rate of trial 4 (~ 600 events / minute).

The data suggests that the production CAS service is operating well under the maximum sustainable load, and should have plenty of capacity to spare for temporary spikes in utilization.