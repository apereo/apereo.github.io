---
layout:     post
title:      CAS 5 SAML2 Delegated AuthN Tutorial
summary:    Learn how to delegate authentication requests to external SAML2 identity providers.
---

This is a short and sweet tutorial on how to configure CAS to delegate authentication to an external SAML2 identity provider.
Most of the material is based on the [available documentation](https://apereo.github.io/cas/development/integration/Delegate-Authentication.html).

This tutorial specifically focuses on:

- CAS `5.1.0-RC3-SNAPSHOT`
- Java 8
- Apache Tomcat `8.5.11`
- [Okta Developer account](http://developer.okta.com/standards/SAML/setting_up_a_saml_application_in_okta)

# Deploy CAS

Hop over to [the overlay installation](https://apereo.github.io/cas/development/installation/Maven-Overlay-Installation.html) and get CAS built and deployed. The CAS version I am using today is `5.1.0-RC3-SNAPSHOT`. It does not matter whether you end up using Maven or Gradle. Choose what fits you best. When you have a baseline functioning build, continue on.

# Configure CAS

Add the required module specified here in the [documentation](https://apereo.github.io/cas/development/integration/Delegate-Authentication.html) to your build. Next, we need to teach CAS about the external SAML2 Identity Provider. The configuration displayed below simply wants to have CAS act as a sevice provider with its own unique entity id, keystore, etc. CAS itself will generate the relevant service-provider credentials, keystores and metadata and will then examine the identity provider metadata document to learn about endpoints, etc. So you only really have to provide the values and let the software handle the rest.

```properties
cas.authn.pac4j.saml[0].keystorePassword=pac4j-demo-passwd
cas.authn.pac4j.saml[0].privateKeyPassword=pac4j-demo-passwd
cas.authn.pac4j.saml[0].serviceProviderEntityId=urn:mace:saml:pac4j.org
cas.authn.pac4j.saml[0].serviceProviderMetadataPath=/etc/cas/config/sp-metadata.xml
cas.authn.pac4j.saml[0].keystorePath=/etc/cas/config/samlKeystore.jks
cas.authn.pac4j.saml[0].identityProviderMetadataPath=https://dev-12345.oktapreview.com/app/486ngfgf/sso/saml/metadata
```

Note that the above settings are indexed, which means that if you needed to, you could delegate authentication to more than one identity provider. Also remember that metadata, keystores and such are only created if they are absent from the specified locations. You can certainly hand-massage them if needed, and CAS will let them be as they are without complaints.

# Configure Okta

Follow the documentation [described here](http://developer.okta.com/standards/SAML/setting_up_a_saml_application_in_okta)
to create a developer account and add a new application as SAML2 IdP. At a minimum, you need to provide Okta with the SSO (ACS) url and entity id of the service provider, that being CAS in this case. You do have the entity id above and the ACS url takes on the following form:

```bash
https://sso.example.org/cas/login?client_name=SAML2Client
```

The configuration would look something like the following image:

![image](https://cloud.githubusercontent.com/assets/1205228/24192129/9d0f828c-0f0b-11e7-8cec-698be1b31cee.png)

Finally you need to assign people/users SAML2 Identity Provider application to allow for authentication:

![image](https://cloud.githubusercontent.com/assets/1205228/24192186/c09b0ad2-0f0b-11e7-9e6a-12752de7c125.png)

Okta is then able to provide you with a metadata for this instance, which you can then use to plug back into the above settings.

# That's It

When you deploy CAS, your default logs (though you could certainly turn on `DEBUG` to observe a lot more) would indicate something along the following lines:

```bash
2017-03-22 13:33:59,147 INFO [o.a.c.s.p.c.s.a.Pac4jAuthenticationEventExecutionPlanConfiguration] - <Located and prepared [1] delegated authentication clients>
2017-03-22 13:33:59,182 INFO [o.a.c.s.p.c.s.a.Pac4jAuthenticationEventExecutionPlanConfiguration] - <Registering delegated authentication clients...>
```

...and when you get to the login page, you will see the following:

![image](https://cloud.githubusercontent.com/assets/1205228/24192477/c4bb918a-0f0c-11e7-94b9-ac2187588b9c.png)

The same strategy simply applies to all other forms of delegated authentication, such as social identity providers or other CAS servers.

[Misagh Moayyed](https://twitter.com/misagh84)