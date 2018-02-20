---
layout:     post
title:      Apereo CAS - Attribute-based Application Authorization
summary:    A walkthrough to demonstrate how one might fetch attributes from a number of data sources, turning them into roles that could then be used to enforce application access and authorization.
tags:       [CAS]
---

<div class="alert alert-success">
<strong>Collaborate</strong><br/>This blog is managed and hosted on GitHub. If you wish to update the contents of this post or if you have found an inaccuracy and wish to make corrections, we recommend that you please submit a pull request to <a href="https://github.com/apereo/apereo.github.io">this repository</a>.
</div>

A fairly common CAS deployment use case is to enforce access to a particular set of applications via user attributes and roles. One the authentication/authorization server passed on the required attributes and entitlements to the application, each service might individually be tasked with controlling entry access and once authorized, enforcement a set of specific functions inside the application which the user may be allowed to carry out. The purpose of this tutorial is to present an alternative to the first scenario, by providing options to centrally control and manage that ruleset that allows the user to enter an application that is integrated with Apereo CAS.

Our task list is rather short:

1. Configure CAS to fetch attributes from LDAP, JDBC and other potential sources.
2. Register an application with CAS and define authorization rules for access based on retrieved attributes.

To keep this tutorial simple, we are going to stick with the default CAS method of authentication with the obvious assumption that our authentication sources shall be different from sources that may produce user attributes.

# Environment

- CAS `5.2.x`
- [CAS Maven WAR Overlay](https://github.com/apereo/cas-overlay-template)

Follow the instructions provided by the `README` file to produce a functional build.

# Attribute Retrieval

Attribute resolution strategies in CAS are controlled by the [Person Directory project](https://github.com/apereo/person-directory). The Person Directory dependency is automatically bundled with the CAS server and provides a number of options to fetch attributes and user data from sources such as LDAP, JDBC, etc. Since we do have multiple sources of attributes, the Person Directory component is also able to aggregate and merge the results and has options to decide how to deal with disagreements in case two sources produce conflicting data.

There is very little left for us to do other than to teach CAS about our specific data sources.

## LDAP Attribute Retrieval

In the given `cas.properties` file, the following settings allow us to fetch attributes from LDAP:

```properties
cas.authn.attributeRepository.ldap[0].baseDn=ou=people,dc=example,dc=org
cas.authn.attributeRepository.ldap[0].ldapUrl=ldap://localhost:1385
cas.authn.attributeRepository.ldap[0].userFilter=uid={0}
cas.authn.attributeRepository.ldap[0].useSsl=false
cas.authn.attributeRepository.ldap[0].bindDn=...
cas.authn.attributeRepository.ldap[0].bindCredential=...

cas.authn.attributeRepository.ldap[0].attributes.displayName=displayName
cas.authn.attributeRepository.ldap[0].attributes.givenName=givenName
cas.authn.attributeRepository.ldap[0].attributes.mail=email
```

The above configuration defined the very basic essentials as far as LDAP connection information while also teaching CAS the set of attributes that should be first *retrieved* and optionally *remapped*. In practice, CAS would begin to fetch `displayName`, `givenName` and `mail` from the directory server and then process the final collection to include `displayName`, `givenName` and `email`. From this point on, CAS only knows of the user's email address under the `email` attribute and needless to say, this is the attribute name that should be used everywhere else in the CAS configuration.

<div class="alert alert-info">
<strong>Multiple Sources</strong><br/>CAS settings able to accept multiple values are typically documented with an index, such as <code>cas.some.setting[0]=value</code>. The index [0] is meant to be incremented by the adopter to allow for distinct multiple configuration blocks
</div>

## JDBC Attribute Retrieval

The  table `table_users` in our HyperSQL database contains the user attributes we need:

| `uid`                   |    `attribute`                          | `value`
|-------------|------------------------|------------------------------
| `casuser`                  |       `role`                            |  `Manager`
| `casuser`                  |       `role`                            |  `Supervisor`
| `user2`                        |       `role`                             |  `Engineer`

The above schema is what's referred to as a *Multi-Row* setup in the Person Directory configuration. In other words, this is the sort of setup that has more than one row dedicated to a user entry and quite possibly similar to above, multiple rows carry out multiple values for a single attribute definition (i.e. `role`. In order to teach CAS about this setup, we could start with the following settings:

```properties
cas.authn.attributeRepository.jdbc[0].attributes.role=personRole

cas.authn.attributeRepository.jdbc[0].singleRow=false
cas.authn.attributeRepository.jdbc[0].columnMappings.attribute=value

cas.authn.attributeRepository.jdbc[0].sql=SELECT * FROM table_users WHERE {0}
cas.authn.attributeRepository.jdbc[0].username=uid
cas.authn.attributeRepository.jdbc[0].driverClass=...
cas.authn.attributeRepository.jdbc[0].user=...
cas.authn.attributeRepository.jdbc[0].password=...
```

Pay attention to how the `columnMappings` setting defines a set of 1-1 mappings between columns that contain the attribute name vs the attribute value. Furthermore and similar to the LDAP setup, we are teaching CAS to fetch the attribute `role` (again, determined based on the mappings defined) and virtually *rename* the attribute to `personRole`. Just like the LDAP setup and from this point on, CAS only knows of the user's role under the `personRole` attribute and needles to say, this is the attribute name that should be used everywhere else in the CAS configuration.

# Smoke Test

At this point, you should be able to authenticate into CAS and observe in the logs that the constructed authenticated principal contains the following attributes:

```bash
... <Authenticated principal [casuser] with attributes [{role=[Manager, Supervisor], 
displayName=Test User, givenName=CAS, email=casuser@example.org}] ...>
```

If you [need to troubleshoot](https://apereo.github.io/cas/development/installation/Troubleshooting-Guide.html), the best course of action would be to adjust logs to produce `DEBUG` information.

# Application Registration

The CAS service management facility allows CAS server administrators to declare and configure which services/applications may make use of CAS in different ways. The core component of the service management facility is the service registry that stores one or more registered services containing metadata that drives a number of CAS behaviors including authorization rules.

To keep this tutorial simple, we are going to use the [JSON Service Registry](https://apereo.github.io/cas/development/installation/JSON-Service-Management.html). This registry reads services definitions from JSON configuration files on startup. JSON files are expected to be found inside a configured directory location and this registry will recursively look through the directory structure to find relevant JSON files.

For this turorial, we expect CAS to find our JSON registration record files using the following setting:

```properties
cas.serviceRegistry.initFromJson=false
cas.serviceRegistry.json.location=file:/etc/cas/config/services
```

...and inside the above directory, we are going to create an `ExampleApplication-100.json` file that contains the following:

```json
{
  "@class" : "org.apereo.cas.services.RegexRegisteredService",
  "serviceId" : "https://example\\.application\\.edu.*",
  "name" : "ExampleApplication",
  "id" : 100,
  "evaluationOrder" : 1
}
```

All that remains for us is to decorate the registration record with the authorization rules.

# Application Authorization Rules

The access strategy of a registered service provides fine-grained control over the application authorization rules. It describes whether the service is allowed to use the CAS server, allowed to participate in single sign-on authentication, and (as it's relevant for our use case here) it may also be configured to require a certain set of attributes that must exist before access can be granted to the service.

<div class="alert alert-info">
<strong>Remember</strong><br/>CAS is only gatekeeping here, deciding whether entrance is allowed to the given application. Once the user is allowed to enter, the extent of capabilities and functions available to the user are and must be decided by the application itself where CAS at that point would completely step aside.
</div>

Our JSON registration record could be modified as such:

```json
{
  "@class" : "org.apereo.cas.services.RegexRegisteredService",
  "serviceId" : "https://example\\.application\\.edu.*",
  "name" : "ExampleApplication",
  "id" : 100,
  "evaluationOrder" : 1,
  "accessStrategy" : {
    "@class" : "org.apereo.cas.services.DefaultRegisteredServiceAccessStrategy",
    "requiredAttributes" : {
      "@class" : "java.util.HashMap",
      "role" : [ "java.util.HashSet", [ "Manager" ] ]
    }
  }
}
```

In simpler terms, the above configuration is saying: *Access to applications that interact with CAS whose URL matches the pattern defined by the `serviceId` is only granted if authenticating the user has an attribute `role` that contains the value `Manager`*.

# Summary

I hope this review was of some help to you and I am sure that both this post as well as the functionality it attempts to explain can be improved in any number of ways. Please feel free to [engage and contribute](https://apereo.github.io/cas/developer/Contributor-Guidelines.html) as best as you can.

[Misagh Moayyed](https://twitter.com/misagh84)