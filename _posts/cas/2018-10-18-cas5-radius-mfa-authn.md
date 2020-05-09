---
layout:     post
title:      Apereo CAS - Multifactor Authentication with RADIUS
summary:    Learn how Apereo CAS may be configured to trigger multifactor authentication using a RADIUS server and its support for the Access-Challenge response type.
tags:       [CAS,MFA]
---

<div class="alert alert-success">
  <strong>Collaborate</strong><br/>The blog is managed and hosted on GitHub. If you wish to update the contents of this post or if you have found an inaccuracy and wish to make corrections, we recommend that you please submit a pull request to <a href="https://github.com/apereo/apereo.github.io">this repository</a>.
</div>

The ability to authenticate credentials using the RADIUS protocol and a compliant RADIUS server has been [available in CAS](https://apereo.github.io/cas/development/mfa/RADIUS-Authentication.html) for some time. In more recent CAS versions, this capability has been improved to support multifactor authentication scenarios by allowing CAS to recognize the `Access-Challenge` response type. This is a special signal sent by the RADIUS server requesting more information in order to allow access. The authentication flow is typically composed of the following steps:

- Primary authentication via RADIUS typically using username+password credentials.
- Capturing the `Access-Challenge` and the session `State` passed back from the RADIUS server.
- RADIUS server provides the end-user with a one-time code, typically via SMS, email or mobile app.
- Reroute the next step in the authentication flow, allowing the end-user to enter the code.
- Submit the code and the previous `State` to the RADIUS server.
- Validate the final response which should be an `Access-Accept` type, if all goes well.

A patch [was submitted](https://github.com/apereo/cas/pull/3201/files) to the CAS project a while back to handle this exact scenario. This brief tutorial incorporates this patch into the CAS software and outlines the necessary configuration steps required to deliver multifactor authentication via RADIUS as noted above.

Our starting position is based on the following:

- CAS `5.3.6`
- Java `8`
- [Maven Overlay](https://github.com/apereo/cas-overlay-template) (The `5.3` branch specifically)

## Configuration

### RADIUS Setup

The setup is fairly simple, given CAS does all of the heavy-lifting. First, we need to prepare the CAS overlay with the right set of dependencies to enable RADIUS functionality:

```xml
<dependency>
  <groupId>org.apereo.cas</groupId>
  <artifactId>cas-server-support-radius</artifactId>
  <version>${cas.version}</version>
</dependency>

<dependency>
  <groupId>org.apereo.cas</groupId>
  <artifactId>cas-server-support-radius-mfa</artifactId>
  <version>${cas.version}</version>
</dependency>
```

...and next, we need to teach CAS about our RADIUS setup:

```properties
# Handle primary authentication via RADIUS (i.e. username+password)
cas.authn.radius.server.protocol=MSCHAPv2
cas.authn.radius.client.sharedSecret=xyz
cas.authn.radius.client.inet-address=1.2.3.4

# Handle MFA via RADIUS (i.e. one-time code)
cas.authn.mfa.radius.server.protocol=MSCHAPv2
cas.authn.mfa.radius.client.sharedSecret=xyz
cas.authn.mfa.radius.client.inet-address=1.2.3.4

# Signal webflow to handle MFA via RADIUS
cas.authn.mfa.radius.id=mfa-radius

cas.authn.mfa.radius.allowedAuthenticationAttempts=1
```

That should do it. When credentials are validated via RADIUS as part of primary authentication, the user is routed to the next screen to enter the code provided by the RADIUS server via SMS, etc. Once entered, CAS will submit the code as well as any previous session state back to the RADIUS server which would have it validate the request and produce a successful response that allows CAS to collect attributes and establish a single sign-on session.

Note that we are also configuring CAS to limit the number of authentication attempts to `1`, meaning after the first failed attempt at providing a valid token CAS would reject MFA and should route back to the login screen to restart the flow.

### Test RADIUS

To test the basic tenants of this scenario using CAS APIs, the following code snippet may be used as an example:

```java
RadiusClientFactory factory = new RadiusClientFactory(1813, 1812, 2000, "1.2.3.4", "xyz");
JRadiusServerImpl server = new JRadiusServerImpl(RadiusProtocol.MSCHAPv2, factory);
RadiusResponse response = server.authenticate("username", "password", Optional.empty());
System.out.println(response);

System.out.println("Enter code: ");
Scanner scanner = new Scanner(System.in);
String code = scanner.nextLine();

Optional<Serializable> state = Optional.of(response.getAttributes()
    .stream()
    .filter(a -> a.getAttributeName().equalsIgnoreCase("State"))
    .findFirst()
    .get()
    .getValue()
    .getValueObject());
RadiusResponse mfaResponse = server.authenticate("username", code, state);
System.out.println(mfaResponse);
```

### LDAP Attributes

Since RADIUS is used to handle primary authentication, we are going to try to switch to LDAP in order to fetch for user attributes. The following configuration should do the job:

```
cas.authn.attribute-repository.ldap[0].attributes.uid=uid
cas.authn.attribute-repository.ldap[0].attributes.displayName=displayName
cas.authn.attribute-repository.ldap[0].attributes.cn=commonName
cas.authn.attribute-repository.ldap[0].attributes.memberOf=memberOf

cas.authn.attribute-repository.ldap[0].ldap-url=ldap://...
cas.authn.attribute-repository.ldap[0].useSsl=false
cas.authn.attribute-repository.ldap[0].useStartTls=false
cas.authn.attribute-repository.ldap[0].baseDn=dc=example,dc=edu
cas.authn.attribute-repository.ldap[0].searchFilter=uid={0}
cas.authn.attribute-repository.ldap[0].bindDn=...
cas.authn.attribute-repository.ldap[0].bindCredential=...

cas.personDirectory.principalAttribute=uid
```

We are instructing CAS to build the final authenticated Principal identified by the `uid` attribute (instead of whatever the user types into the login form as the credential id). We have some settings for the LDAP attribute repository that describe the LDAP server, and of course we have a section of settings for attribute mapping where we fetch `uid` and virtually rename/remap it to `uid` or we fetch `cn` and remap it to `commonName`, etc.

After the primary authentication event, the attribute repository kicks in to determine the needed attributes for the user by running the query `uid={0}` against the LDAP server  where `{0}` is replaced with the authenticated user id (typically the credential id). Once the user entry is located, attributes are fetched and mapped and the authenticated `Principal` from the CAS perspective has an identifier determined by the `uid` attribute as well as at most four extra *person* attributes attached to it, which can then be used for attribute release.

## Credits

Huge thanks to [Jozef Kotlar](https://github.com/dodok1), [Bo Simonsen](https://github.com/bosim), Jesper Grøndahl and many others who contributed guidance, code, and working examples to see this feature to completion.

## Finale

I hope this review was of some help to you and I am sure that both this post as well as the functionality it attempts to explain can be improved in any number of ways. Please feel free to [engage and contribute](https://apereo.github.io/cas/developer/Contributor-Guidelines.html) as best as you can.

[Misagh Moayyed](https://fawnoos.com)
