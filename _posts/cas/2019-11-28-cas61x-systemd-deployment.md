---
layout:     post
title:      Apereo CAS - Deployment Using systemd
summary:    Fabio Martelli of Tirasa S.r.l reviews the setup required to deploy Apereo CAS as a system service using systemd.
tags:       [CAS]
---

<div class="alert alert-success">
<strong>Collaborate</strong><br/>This blog is managed and hosted on GitHub. If you wish to update the contents of this post or if you have found an inaccuracy and wish to make corrections, we recommend that you please submit a pull request to <a href="https://github.com/apereo/apereo.github.io">this repository</a>.
</div>

<div class="alert alert-info">
  <strong>Contributed Content</strong><br/><a href="https://www.tirasa.net/tirasa/team/fabio-martelli">Fabio Martelli of Tirasa S.r.l</a>, an active member of the CAS community, was kind enough to share this analysis.
</div>

# Overview

The following is a short and sweet tutorial on how to deploy Apereo CAS using an embedded servlet container and as `systemd` service.

Our starting position is based on:

- CAS `6.1.x`
- Java `11`
- [CAS WAR Overlay](https://github.com/apereo/cas-overlay-template)

# Configuration

To make the instances start automatically, you need to add the following cas.service script to the `/ etc / systemd / system directory`:

```
[Unit]
Description = making network connection up
After = network.target

[Service]
ExecStart = java -server -noverify -Xmx2048M -XX:+TieredCompilation \
    -XX:TieredStopAtLevel=1 -Dcas.standalone.configurationDirectory=/opt/cas/conf \
    -DKEYSTORE_PASSWORD=... -jar /opt/cas/cas.war

[Install]
WantedBy = multi-user.target
```

Then run the following commands:

```
systemctl enable cas.service
```

Configure the necessary security policies by creating the `cas.te` file as shown below.
This file was obtained by analyzing the audit file with the command:

```
sudo cat  /var/log/audit/audit.log | audit2allow -m cas
```

The resulting file was as follows (as mentioned, saved under `cas.te`):

```
case module 1.0;

require {
    type user_tmp_t;
    type init_t;
    type http_port_t;
    type root_t;
    type unreserved_port_t;
    type usr_t;
    type default_t;
    class file { append create map open rename unlink write };
    class process execmem;
    class dir create;
    class tcp_socket name_connect;
}

#============= init_t ==============

allow init_t default_t:dir create;
allow init_t default_t:file create;
allow init_t default_t:file { append open };
allow init_t http_port_t:tcp_socket name_connect;
allow init_t root_t:dir create;
allow init_t root_t:file { create append open };
allow init_t self:process execmem;
allow init_t unreserved_port_t:tcp_socket name_connect;
allow init_t user_tmp_t:file { create map write };
allow init_t usr_t:file { append create rename unlink };
```

Transform the file cas.te into a binary `cas.mod`:

```
checkmodule -M -m -o cas.mod cas.te
```

Create the policy package with the following command:

```
semodule_package -o cas.pp -m cas.mod
```

Install the defined security policies:

```
sudo semodule -i cas.pp
```

Then run CAS:

```
systemctl start cas
```

# So...

I hope this review was of some help to you and I am sure that both this post as well as the functionality it attempts to explain can be improved in any number of ways. Please know that all other use cases, scenarios, features, and theories certainly [are possible](https://apereo.github.io/2017/02/18/onthe-theoryof-possibility/) as well. Feel free to [engage and contribute](https://apereo.github.io/cas/developer/Contributor-Guidelines.html) as best as you can.

Finally, if you benefit from Apereo CAS as free and open-source software, we invite you to [join the Apereo Foundation](https://www.apereo.org/content/apereo-membership) and financially support the project at a capacity that best suits your deployment. If you consider your CAS deployment to be a critical part of the identity and access management ecosystem and care about its long-term success and sustainability, this is a viable option to consider.

Happy Coding,

[Misagh Moayyed](https://twitter.com/misagh84)
