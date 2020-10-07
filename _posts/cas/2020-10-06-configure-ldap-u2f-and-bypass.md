---
layout:     post
title:      CAS Multifactor Authentication with  U2F and Bypass
summary:    A short walkthrough to demonstrate how one might turn on multifactor authentication with CAS using U2F and default bypass rule.
tags:       []
---

In some CAS deployments multifactor authentication can be done using U2F keys. Sometimes not all the users have the key, but they want to use the service. On the other hand there are machine to machine users that cannot push the button on USB key. For this two kinds of users U2F bypass is the only way to use CAS in such deployment.

# Environment

- CAS `6.2.2`

# Configuring Authentication

```properties
cas.authn.ldap[0].type=AUTHENTICATED
cas.authn.ldap[0].ldapUrl=ldap://10.30.10.10:389
cas.authn.ldap[0].useSsl=false
cas.authn.ldap[0].searchFilter=cn={user}
cas.authn.ldap[0].baseDn=ou=users,dc=domain11
cas.authn.ldap[0].bindDn=cn=admin,dc=domain11
cas.authn.ldap[0].bindCredential=1221

cas.authn.ldap[0].principalAttributeList=memberOf,memberof,cn
```

# Configuring U2F as second factor

```properties
cas.authn.mfa.globalProviderId=mfa-u2f

cas.authn.mfa.u2f.rank=0
cas.authn.mfa.u2f.name=AAA

cas.authn.mfa.u2f.expireRegistrations=300
cas.authn.mfa.u2f.expireRegistrationsTimeUnit=SECONDS
cas.authn.mfa.u2f.expireDevices=30
cas.authn.mfa.u2f.expireDevicesTimeUnit=DAYS

cas.authn.mfa.u2f.json.location=file:///etc/cas/config/u2.json
```

# Default Bypass Configuration

We have CAS configured with LDAP and U2F support and we need to bypass second factor to certain users.
To do so we can:
1) In LDAP add description field to exact users.
2) In cas.properties add "description" attribute to cas.authn.ldap[0].principalAttributeList option

```properties
cas.authn.ldap[0].principalAttributeList=memberOf,memberof,cn,description
```

3) Set bypass type and bypass criteria

```properties
cas.authn.mfa.u2f.bypass.type=DEFAULT 
cas.authn.mfa.u2f.bypass.principalAttributeName=description
```

All users with description attribute present should bypass second factor.

[Egor Ivanov](https://baltinfocom.ru/BigData)
