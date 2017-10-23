---
layout:     post
title:      CAS 5.1.x Load Tests by Lafayette College 
summary:    Lafayette College shares the results of stress tests executed against a recent CAS 5.1.x deployment.
tags:       [CAS]
---

<div class="alert alert-info">
  <strong>Contributed Content</strong><br/><a href="mailto:waldbiec@lafayette.edu">Carl Waldbieser</a>, an active member of the CAS community, was kind enough to share this analysis.
</div>

Lafayette College has an active user base of XXX and regularly records 78 CAS authentication events/minute on average with peaks of 220 events/minute. In preparation of deploying CAS `5.1.x`, locust.io was used to put CAS under load and soak and stress tests. Results indicate that CAS `5.1.x` deployed with reasonable hardware in a multi-node deployment architecture using nginx+ and hazelcast. Deployment architecture, testing scenarios and results are detailed in the rest of this blogs post.

In preparation for a service upgrade from CAS server version `5.0.x` to version `5.1.x`, load testing trials were conducted on the CAS stage environment. All trials were carried out against the same deployment architecture, with all nodes configured identically. The deployment architecture and nodes have not changed since the last load test was conducted around April 25, 2017.

# Overview

The deployment architecture itself consists of 3 virtual machine nodes: 

- cas3.stage.lafayette.edu
- cas4.stage.lafayette.edu
- cas5.stage.lafayette.edu

![architecture-500x538](https://user-images.githubusercontent.com/1205228/30987126-c3d0618e-a4a2-11e7-8817-122c954752d3.png)

Each node has 3.7 GiB real memory available to it and 2 CPUs.  The characteristics of the CPUs are as follows:

* Architecture: x86_64
* CPU op-mode(s): 32-bit, 64-bit
* Byte Order: Little Endian
* CPU(s): 2
* On-line CPU(s) list: 0,1
* Thread(s) per core: 1
* Core(s) per socket: 2
* Socket(s): 1
* NUMA node(s): 1
* Vendor ID: GenuineIntel
* CPU family: 6
* Model: 42
* Model name: Intel Xeon E312xx (Sandy Bridge)
* Stepping: 1
* CPU MHz: 1899.999
* BogoMIPS: 3799.99
* Hypervisor vendor: KVM
* Virtualization type: full
* L1d cache: 32K
* L1i cache: 32K
* L2 cache: 4096K
* NUMA node0 CPU(s): 0,1

The nodes are deployed behind an Nginx+ proxy in an active-active-active configuration.  The nodes share ticket information using encrypted hazelcast messages, so any application state is shared.

# The Test Swarm

The testing framework used was [**locust.io**](http://locust.io/), a Python based load testing framework.  The test suite deploys a fixed number of "locusts" against a web site.  The initial population ramps up with a configurable “hatch rate”.  In the tests, locusts were conceptually divided into 3 “lifetime” categories:

* Short-lived locusts live approximately 60 seconds.
* Medium-lived locusts last for approximately 5 minutes.
* Long-lived locusts exist for approximately 2 hours.

The category to which a given locust is assigned is randomly determined with a ratio of short : medium : long being 7:2:1.  Ideally, 70% of the population is short-lived, 20% is medium lived, and 10% is long-lived.

The lifetime of a locust determines how long it will retain and make use of a single web SSO session.  Short-lived locusts discard their sessions quickly.  Long-lived locusts hold on to them for considerable time.  All locusts continually request and validate service tickets throughout their lives every 5-15 seconds.

All locusts are only 25% likely to log out upon their deaths.  The CAS service must continue to track TGTs of locusts that have not logged out until the ticket expires, so this behavior can put pressure on the memory storage resources of the nodes.

Each locust uses credentials taken randomly from one of 9 test accounts.  Each locust has a 1% chance of entering an erroneous password for an account.  Locusts that fail to authenticate will die immediately.

When a locust dies, it is reborn immediately.  Its lifetime category remains the same, but its SSO session and all other random parameters are reset.

# SSO Session Tracking

SSO sessions are tracked by the TGTs they produce.  Any event that creates or destroys a TGT is logged, and these observations are plotted after the fact.  Because only 25% of locusts will explicitly end a session, many sessions will accumulate and consume storage in the CAS ticket registry until the session times out.  Using the probability of long, medium, and short lived locusts in the population, the actual number of active sessions at any time is estimated.  The charts produced should provide a reasonable estimate of how many simultaneous sessions are being managed by the CAS service at any given time. 

<table>
  <tr>
    <td>Trial</td>
    <td>01</td>
  </tr>
  <tr>
    <td>Date / duration</td>
    <td> 2017-09-05 from 09:30:00-04:00 until 16:44:00-04:00 (7h 14m)</td>
  </tr>
  <tr>
    <td>Number of locusts</td>
    <td>150</td>
  </tr>
  <tr>
    <td>Hatch rate</td>
    <td>10/s</td>
  </tr>
</table>

![image](https://user-images.githubusercontent.com/1205228/30940336-9615a106-a3ed-11e7-99c9-4867207a1d1c.png)

The first trial produced authentication events at a rate of 1,800.11 events/minute.  The majority of these were service ticket creation and validation events.  The trial was concluded with no noticeable degradation in performance.

![image](https://user-images.githubusercontent.com/1205228/30940375-be2d7b6e-a3ed-11e7-834f-e36611196c67.png)

Net SSO sessions increased at a rate of 73.5 sessions per minute until the idle session timeout duration was reached.

<table>
  <tr>
    <td>Trial</td>
    <td>02</td>
  </tr>
  <tr>
    <td>Date / duration</td>
    <td> 2017-09-20, 09:00:00-04:00 - 17:00:00-04:00 (8 hours)</td>
  </tr>
  <tr>
    <td>Number of locusts</td>
    <td>50</td>
  </tr>
  <tr>
    <td>Hatch rate</td>
    <td>10/s</td>
  </tr>
</table>

![image](https://user-images.githubusercontent.com/1205228/30940409-dfedd104-a3ed-11e7-9dad-2a612d620a41.png)

An average of 600.46 events per second were handled by the CAS service under load during this trial.  There were no noticeable service disruptions.

![image](https://user-images.githubusercontent.com/1205228/30940430-f7330316-a3ed-11e7-978a-85e894ee1d82.png)

Net SSO sessions increased at a rate of 27.4 sessions per minute, until the session idle timeout duration was reached.

<table>
  <tr>
    <td>Trial</td>
    <td>03</td>
  </tr>
  <tr>
    <td>Date / duration</td>
    <td> 2017-09-22, 09:05:00-04:00 - 09:33:00-04:00 (28 minutes)</td>
  </tr>
  <tr>
    <td>Number of locusts</td>
    <td>175</td>
  </tr>
  <tr>
    <td>Hatch rate</td>
    <td>10/s</td>
  </tr>
</table>


![image](https://user-images.githubusercontent.com/1205228/30940483-1a8fbdae-a3ee-11e7-834c-c4195f541e1f.png)

![image](https://user-images.githubusercontent.com/1205228/30940514-2ff0260c-a3ee-11e7-8639-baa84dea93a3.png)

Net SSO sessions increased at a rate of 82.9 sessions per minute.

<table>
  <tr>
    <td>Trial</td>
    <td>04</td>
  </tr>
  <tr>
    <td>Date / duration</td>
    <td>2017-09-22, 11:49:00-04:00 - 12:30:00-04:00 (41 minutes)</td>
  </tr>
  <tr>
    <td>Number of locusts</td>
    <td>200</td>
  </tr>
  <tr>
    <td>Hatch rate</td>
    <td>10/s</td>
  </tr>
</table>
 

![image](https://user-images.githubusercontent.com/1205228/30940569-5556cda6-a3ee-11e7-8264-e8e74b0285ff.png)

![image](https://user-images.githubusercontent.com/1205228/30940590-6b3bdfee-a3ee-11e7-831b-9a94a8043b50.png)


Net SSO sessions increased at a rate of 93.0 sessions per minute.

<table>
  <tr>
    <td>Trial</td>
    <td>05</td>
  </tr>
  <tr>
    <td>Date / duration</td>
    <td>2017-09-22, 15:10:00-04:00 - 15:47:00-04:00 (37 minutes)</td>
  </tr>
  <tr>
    <td>Number of locusts</td>
    <td>125</td>
  </tr>
  <tr>
    <td>Hatch rate</td>
    <td>10/s</td>
  </tr>
</table>


![image](https://user-images.githubusercontent.com/1205228/30940615-8191ee50-a3ee-11e7-984b-7baadd2fc58d.png)

![image](https://user-images.githubusercontent.com/1205228/30940640-92a1097e-a3ee-11e7-985d-99655421f6aa.png)


Net SSO sessions increased at a rate of 64.0 sessions per minute.

<table>
  <tr>
    <td>Trial</td>
    <td>06</td>
  </tr>
  <tr>
    <td>Date / duration</td>
    <td>2017-09-22, 16:35:00-04:00 - 16:50:00-04:00 (20 minutes)</td>
  </tr>
  <tr>
    <td>Number of locusts</td>
    <td>250</td>
  </tr>
  <tr>
    <td>Hatch rate</td>
    <td>10/s</td>
  </tr>
</table>


![image](https://user-images.githubusercontent.com/1205228/30940675-ac953d28-a3ee-11e7-9864-46c3d1474961.png)

![image](https://user-images.githubusercontent.com/1205228/30940692-bf9d0266-a3ee-11e7-9ad0-ada30272a356.png)


Net SSO sessions increased at a rate of 124.6 sessions per minute.

## Effect of Number of Locusts on Mean Rate of Events

Observations from the previous trial and the current trial were plotted in order to give some sense of the influence the number of locusts in the test swarm would have on the mean rate of events processed by the service each minute.  The data suggest that for each additional locust added, there are approximately 12 more events generated per minute.

![image](https://user-images.githubusercontent.com/1205228/30955982-75549116-a442-11e7-8f9a-d250926302d4.png)

## Observed and Predicted Mean Rates

<table>
  <tr>
    <td></td>
    <td>mean_rate</td>
    <td>mean_rate_observed</td>
  </tr>
  <tr>
    <td>locusts</td>
    <td></td>
    <td></td>
  </tr>
  <tr>
    <td>0</td>
    <td>1.09</td>
    <td>N/A</td>
  </tr>
  <tr>
    <td>25</td>
    <td>300.51</td>
    <td>N/A</td>
  </tr>
  <tr>
    <td>50</td>
    <td>599.93</td>
    <td>600.46</td>
  </tr>
  <tr>
    <td>75</td>
    <td>899.35</td>
    <td>N/A</td>
  </tr>
  <tr>
    <td>100</td>
    <td>1,198.76</td>
    <td>N/A</td>
  </tr>
  <tr>
    <td>125</td>
    <td>1,498.18</td>
    <td>1,496.84</td>
  </tr>
  <tr>
    <td>150</td>
    <td>1,797.60</td>
    <td>1,800.11</td>
  </tr>
  <tr>
    <td>175</td>
    <td>2,097.02</td>
    <td>2,095.36</td>
  </tr>
  <tr>
    <td>200</td>
    <td>2,396.43</td>
    <td>2,395.12</td>
  </tr>
  <tr>
    <td>225</td>
    <td>2,695.85</td>
    <td>N/A</td>
  </tr>
  <tr>
    <td>250</td>
    <td>2,995.27</td>
    <td>2,996.53</td>
  </tr>
  <tr>
    <td>275</td>
    <td>3,294.69</td>
    <td>N/A</td>
  </tr>
  <tr>
    <td>300</td>
    <td>3,594.10</td>
    <td>N/A</td>
  </tr>
  <tr>
    <td>325</td>
    <td>3,893.52</td>
    <td>N/A</td>
  </tr>
  <tr>
    <td>350</td>
    <td>4,192.94</td>
    <td>N/A</td>
  </tr>
</table>

## Effect of Number of Locusts on Increase in SSO Sessions

The rate at which net new SSO sessions are created during the period from the beginning of a trial until the discarded TGTs begin to timeout is also useful.  Since it seems to be a linear function of the number of locusts, this figure can be used to predict the number of SSO sessions that will be present were a trial to reach the session timeout mark.

![image](https://user-images.githubusercontent.com/1205228/30955909-366a6f0c-a442-11e7-93b7-844e57c343ad.png)

# Conclusions

Measurements 1 taken from the production CAS service from September 1-22, 2017 during normal business hours (9am to 5pm) have the following characteristics:

<table>
  <tr>
    <td>mean</td>
    <td>78 events / minute</td>
  </tr>
  <tr>
    <td>median</td>
    <td>75 events / minute</td>
  </tr>
  <tr>
    <td>mode</td>
    <td>59 events / minute</td>
  </tr>
  <tr>
    <td>max</td>
    <td>220 events / minute</td>
  </tr>
  <tr>
    <td>min</td>
    <td>8 events / minute</td>
  </tr>
  <tr>
    <td>standard deviation</td>
    <td>28</td>
  </tr>
</table>


The data suggests that the production CAS service is operating well under the maximum sustainable load, and should have plenty of capacity to spare for temporary spikes in utilization.

[Carl Waldbieser](mailto:waldbiec@lafayette.edu)

<sup>1</sup> Splunk query for Sep 1-21, 2017: 

```sql
index=auth_cas (sourcetype=cas OR sourcetype=cas5) action=* date_hour >= 9 date_hour <= 16 date_wday!="saturday" date_wday!="sunday" | bin _time span=1m | stats count by _time | stats min(count) max(count)  mean(count) mode(count) median(count) stdev(count)
```