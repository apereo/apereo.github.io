---
layout:     post
title:      Multitenancy With CAS
summary:    A short review of multitenancy feature variants and equivalents in Apereo CAS.
tags:       [CAS]
---

<!--
<div class="alert alert-danger">
  <strong>WATCH OUT!</strong><br/>This post is not official yet and may be heavily edited as CAS development makes progress. <a href="https://apereo.github.io/feed.xml">Watch</a> for further updates.
</div>
-->

<div class="alert alert-success">
  <strong>Collaborate</strong><br/>This blog is managed and hosted on GitHub. If you wish to update the contents of this post or if you have found an inaccuracy and wish to make corrections, we recommend that you please submit a pull request to <a href="https://github.com/apereo/apereo.github.io">this repository</a>.
</div>

According to [Wikipedia](https://www.wikiwand.com/en/Multitenancy), the term "software multitenancy" is defined as:

> ...a software architecture in which a single instance of software runs on a server and serves multiple tenants. A tenant is a group of users who share a common access with specific privileges to the software instance.

I have been asked on and off about multitenancy capabilities of CAS and whether [it is possible](https://apereo.github.io/2017/02/18/onthe-theoryof-possibility/) to have one CAS deployment serve many tenants. To be clear, multitenancy in a CAS context would cover the following areas for each tenant:

- Brand and theme the user interface.
- Define and limit authentication sources including attribute retrieval and release.
- Control logging strategies and audits in different granular details.
- Define and limit enabled/supported authentication protocols both as an IdP and IdP Proxy (delegated authentication).
- Feature management, such as tickets, security, access strategy, flow customizations, etc.
- ...

In addition to the problem of isolating configuration per tenant, there also needs to be a mechanism by which CAS may shake hands with each tenant to recognize and activate their connected configuration. Furthermore, any design needs to also carefully weigh and evaluate possibilities of *feature imbalance* which is the problem of introducing capabilities requested by a tenant without impact and side-effects to others and doing so in such a way to ensure all tenants can get their fair share of system capabilities if and when asked.

If all of this sounds complex and seems like a lot of work, it is simply because it is. If this is something you desire to see in your deployment, please [reach out](https://fawnoos.com).

While support for multi-tenancy in the above terms and conditions is absent in CAS today, in this tutorial I wish to uncover *a few* aspects of the CAS software that may prove as viable alternatives or shortcuts for the time being to handle multitenancy-like features.

# Scenario

Let's suppose we are in charge of a CAS deployment that is tasked to serve two distinct tenants A and B each of which wish to register a few different applications registered with CAS with a variety of other rules that affect attribute release, themes, etc.

## Constraints

It is important to treat these tenants as generic as possible and not make any assumptions about their underlying deployment or architecture. Equally significant, note that our tenants are simply *unable* to make changes whatsoever on their end to make our lives easier on this end. We might be able to relax this clause and make amends later in the future, (assuming fairly tight control over the environment) but until then, tenants' expectation is to integrate with a given CAS deployment as if it was only their own completely ignorant of its multitenancy capabilities. Everything that can be done should be done with CAS to see that expectation to reality.

# Poor Man's Multitenancy

One possible solution is to turn the problem from one of software into one of deployment topology. Rather than having *a single* CAS deployment serving many tenants, you would simply have many smaller deployments serving each tenant and you would assign each tenant a specific endpoint that handles their needs exclusively. For our tenants, we could have `https://sso.example.org/tenantA/cas/` and `https://sso.example.org/tenantB/cas` endpoint and so on. (If you care, rewrite the URLs prettier at some level to hide details) All CAS functionality is scoped to the specific endpoints that are shared with each tenant and the software itself cares not how it is contacted and by whom so long as requests are well-formed. 

While arguably this is the simplest of all options and grants the most flexibility, it goes without saying that managing many small deployments, upgrades and maintenance efforts across the platform does incur cost and risk and requires quite a bit of automation, technique and infrastructure support to let all play nice.

# Authentication

To further complicate the scenario, let’s suppose that tenant A uses a MySQL database for its account source and authentication while tenant B uses Active Directory. Our goal is to let tenant A users only use MySQL while tenant B users are limited to Active Directory and we want to do so based on the semantics of the credential passed. Simply put, if the credential id matches the syntax of `xyz@tenantA.org`, we would want CAS to use MySQL and if the credential matches `xyz@tenantB.org`, CAS would use Active Directory instead.

I am of course assuming, rather obviously, that tenants support username/password authentication modes. Fancier forms of authentication are left out for brevity. Let’s also assume that we know how to configure CAS to use MySQL and Active Directory as authentication sources. With that, the first question we might ask is: Can CAS be configured to use a specific authentication strategy based on the properties of the credential?

The answer is, yes.

Most authentication strategies in CAS are given a [predicate to examine the requested credential]( https://apereo.github.io/cas/development/installation/Configuration-Properties-Common.html#authentication-credential-selection) for eligibility. This predicate is simply a fancy a condition whose outcome determines whether the authentication strategy/handler should proceed to operate on the credential.

So, we can design the following conditions for our MySQL and Active Directory authentication modes:

```properties
...
cas.authn.jdbc.search[0].credentialCriteria=.+@tenantA\.org
...
cas.authn.ldap[0].credentialCriteria=.+@tenantB\.org
...
```

In the above settings, the `credentialCriteria` is a regular expression pattern that is tested against the credential identifier. A successful match indicates credential eligibility.

# Attribute Retrieval

Having configured authentication sources for each tenant, how could we retrieve attributes in much the same way? 

A number of authentication strategies in CAS have the ability to fetch attributes from the same source in which the account was found. In our case above, we want `firstName` and `lastName` to be retrieved from MySQL and `cn` and `givenName` from Active Directory once the authentication attempt is successful. The requirements are translated as below:

```properties
...
cas.authn.jdbc.search[0].principalAttributeList=firstName,lastName
...
cas.authn.ldap[0].principalAttributeList=cn,givenName
...
```

Simple, eh?

# Attribute Release
 
In our quest to multi-tenancy, we need to design a strategy to release bundles of attributes to each tenant. One option is to simply register all applications with CAS and design attribute release policies for each. While reasonable, this approach might lead to some maintenance overhead, especially as you begin to design attribute release rules from a tenant perspective and as that number grows over time. To elaborate, let's say all applications managed by tenant A should receive the `firstName` attribute but only a few privileged applications in the same group need access to `lastName`. Are we to duplicate the same attribute release policy rules for each service definition with `firstName` as the allowed attribute and only in special cases then make room for `lastName`? Not quite. What might be more desirable is if we had a way to *share policy rules* across tenants and definitions to centralize configuration and policy.

One option is to [use a Groovy script](https://apereo.github.io/cas/development/integration/Attribute-Release-Policies.html#groovy-script) shared across members of a given tenant. For instance, our release policy includes something like this:

```json
{
  "@class" : "org.apereo.cas.services.RegexRegisteredService",
  "serviceId" : "some-application-part-of-tenant-A",
  "name" : "Example Tenant A application",
  "id" : 10,
  "attributeReleasePolicy" : {
    "@class" : "org.apereo.cas.services.GroovyScriptAttributeReleasePolicy",
    "groovyScript" : "classpath:/tenantA-attr-release-policy.groovy"
  }
}
```

...and the shared script would have the following outline:

```groovy
import java.util.*

def Map<String, List<Object>> run(final Object... args) {
    def currentAttributes = args[0]
    def logger = args[1]
    def principal = args[2]
    def service = args[3]

    ...
}
```

You may also want to get even fancier by assigning [arbitrary tags to each service definition](https://apereo.github.io/cas/development/installation/Configuring-Service-Custom-Properties.html) to further control different sorts of centralized policies in the script.

# Themes

Based on the [CAS documentation for dynamic themes](https://apereo.github.io/cas/development/installation/User-Interface-Customization-Themes.html),

> CAS can also utilize a service’s associated theme to selectively choose which set of UI views will be used to generate the standard views. This is especially useful in cases where the set of pages for a theme that is targeted for a different type of audience are entirely different structurally that simply using a simple theme is not practical to augment the default views.

Sounds exactly like what we might want to use for our tenants. In my example, I am simply going to customize the CAS login view fragment for each tenant and then assign the special theme identifier to all tenant A members. Let's say I am going to call the theme identifier `tenantATheme`:

```json
{
  "@class" : "org.apereo.cas.services.RegexRegisteredService",
  "serviceId" : "some-application-part-of-tenant-A",
  "name" : "Example Tenant A application",
  "id" : 10,
  "theme": "tenantATheme",
  "attributeReleasePolicy" : {
    "@class" : "org.apereo.cas.services.GroovyScriptAttributeReleasePolicy",
    "groovyScript" : "tenantATheme"
  }
}
```

Then, I would create the theme directory which would contain the customized login view for tenant A members:

```bash
mkdir -p src/main/resources/templates/tenantATheme
cd src/main/resources/templates/tenantATheme
touch casLoginView.html
```

My theme may also contain its own CSS and Javascript variants under a `src/main/resources/tenantATheme.properties`:

```properties
standard.custom.css.file=/themes/[theme_name]/css/cas.css
cas.javascript.file=/themes/[theme_name]/js/cas.js
admin.custom.css.file=/themes/[theme-name]/css/admin.css
```

The `casLoginView.html` found at `src/main/resources/templates/tenantATheme` will now always be used for applications that are members of tenant A and carry the assigned theme in their definition.

# Summary

I hope this review was of some help to you. As you have been reading, I can guess that you have come up with a number of missing bits and pieces that would satisfy your use cases more comprehensively with CAS. In a way, that is exactly what this tutorial intends to inspire. Please feel free to [engage and contribute](https://apereo.github.io/cas/developer/Contributor-Guidelines.html) as best as you can.

[Misagh Moayyed](https://fawnoos.com)
