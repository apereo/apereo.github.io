---
layout:     post
title:      Apereo CAS - OAuth JWT Access Tokens
summary:    Learn to customize Apereo CAS to issue OAuth Access Tokens as JWTs.
tags:       [CAS]
---

<div class="alert alert-success">
<strong>Collaborate</strong><br/>This blog is managed and hosted on GitHub. If you wish to update the contents of this post or if you have found an inaccuracy and wish to make corrections, we recommend that you please submit a pull request to <a href="https://github.com/apereo/apereo.github.io">this repository</a>.
</div>

# Overview

When CAS is configured to act as an OAuth identity provider, it begins to issue access tokens that are by default opaque identifiers. There is also the option to generate JWTs as access tokens on a per-application basis. Using JWTs, CAS can create JSON documents to encode all relevant parts of an access token into the token itself. The main benefit of this is that API servers can verify access tokens without doing a token lookup on every API request, making the API much more easily scalable. Also, this means that applications don’t need to be aware of 
how CAS implements access tokens which makes it possible to change the implementation later without affecting clients.


Our starting position is based on:

- CAS `6.2.x`
- Java `11`
- [JSON Service Registry](https://apereo.github.io/cas/development/services/JSON-Service-Management.html)
- [CAS WAR Overlay](https://github.com/apereo/cas-overlay-template)
- [CLI JSON Processor `jq`](https://stedolan.github.io/jq/)

# Configuration

First, let's create a few mock attributes that ought to be released to our sample yet-to-be-registered OAuth application:

```properties
cas.authn.attributeRepository.stub.attributes.cn=Misagh
cas.authn.attributeRepository.stub.attributes.sn=Moayyed
cas.authn.attributeRepository.stub.attributes.mail=mm1844@gmail.com
```    

Once the OAuth module [is included in the WAR Overlay](https://apereo.github.io/cas/development/installation/OAuth-OpenId-Authentication.html#configuration), we can 
begin to register a simple OAuth application with CAS using 
the following [JSON service definition](https://apereo.github.io/cas/development/services/JSON-Service-Management.html):

```json
{
  "@class" : "org.apereo.cas.support.oauth.services.OAuthRegisteredService",
  "clientId": "client",
  "clientSecret": "secret",
  "serviceId" : "https://example.net/dashboard",
  "name" : "OAUTH",
  "id" : 1,
  "attributeReleasePolicy" : {
    "@class" : "org.apereo.cas.services.ReturnAllowedAttributeReleasePolicy",
    "allowedAttributes" : [ "java.util.ArrayList", [ "cn", "mail", "sn" ] ]
  },
  "supportedGrantTypes": [ "java.util.HashSet", [ "password" ] ]
}
```

A few things to note:

- Our application has the usual `clientId`, `clientSecret` and `redirectUri` (i.e. `serviceId`) defined.
- The `cn`, `mail`, and `sn` attributes are selectively defined to be released to the application.
- CAS will only interact with the application using the `password` grant, which we will use to request access tokens
either in plain or JWT format. 

# Plain Access Tokens

[Let's start simple](https://apereo.github.io/2018/09/05/effective-diagnostics/#start-simple), by using the `password` grant to request 
an access token without any extra configurations:

```bash
$ curl https://sso.example.org/cas/oauth2.0/token?grant_type=password'&'\
    client_id=client'&'client_secret=secret'&'username=casuser'&'password=Mellon | jq
```

The above request first authenticates the request using the provided `username` and `password`. Once the application policy is located 
and verified by CAS, an access token can be provided in the response:

```json
{
  "access_token": "AT-1-wiNsTgaHzXLUIyaaoFoip-znohWPihea",
  "token_type": "bearer",
  "expires_in": 28800,
  "scope": ""
}      
```

We can, of course, use the access token in exchange for user profile information:

```bash
curl -k --user client:secret https://sso.example.org/cas/oauth2.0/profile?\
    access_token=AT-1-wiNsTgaHzXLUIyaaoFoip-znohWPihea
```

...where the result would give us access to allowed claims: 

```json
{
  "cn": "Misagh",
  "mail": "mm1844@gmail.com",
  "sn": "Moayyed",
  "service": "client",
  "id": "casuser",
  "client_id": "client"
}
```  

# JWT Access Tokens

As a next step, let's modify our service definition to ask for access tokens as JWTs:

```json
{
  "@class" : "org.apereo.cas.support.oauth.services.OAuthRegisteredService",
  "clientId": "client",
  "clientSecret": "secret",
  "serviceId" : "https://example.net/dashboard",
  "name" : "OAUTH",  
  "jwtAccessToken": true, 
  "id" : 1,
  "attributeReleasePolicy" : {
    "@class" : "org.apereo.cas.services.ReturnAllowedAttributeReleasePolicy",
    "allowedAttributes" : [ "java.util.ArrayList", [ "cn", "mail", "sn" ] ]
  },
  "supportedGrantTypes": [ "java.util.HashSet", [ "password" ] ]
}
```

With the addition of the `jwtAccessToken` field, CAS will render access tokens as JWTs that are by default signed and encrypted using (pre-generated, if undefined) keys. So, let's start simple and force CAS to disable signing and encryption of such tokens so we can 
unpack them easier later for verification:

```properties   
# Force keys to be blank
cas.authn.oauth.access-token.crypto.encryption.key=
cas.authn.oauth.access-token.crypto.signing.key= 

cas.authn.oauth.access-token.crypto.enabled=false
cas.authn.oauth.access-token.crypto.signing-enabled=false
cas.authn.oauth.access-token.crypto.encryption-enabled=false
```                                                        

Using the same command to request an access token, the response now delivers a JWT instead:

```properties
{
  "access_token": "eyJhbGciOi...",
  "token_type": "bearer",
  "expires_in": 28800,
  "scope": ""
}
```

Since the JWT is plain this time around, we can easily unpack it using a service like [jwt.io](https://jwt.io/) to verify the embedded JSON:

```json
{
  "sub": "casuser",
  "mail": "mm1844@gmail.com",
  "roles": [],
  "iss": "https://sso.example.org/cas",
  "cn": "Misagh",
  "nonce": "",
  "client_id": "client",
  "aud": "client",
  "grant_type": "PASSWORD",
  "permissions": [],
  "scope": [],
  "claims": [],
  "scopes": [],
  "state": "",
  "sn": "Moayyed",
  "exp": 1572837100,
  "iat": 1572808300,
  "jti": "AT-1-ibYxeSXhcU1N-0sF1JQXdgX4YAmBgCXY"
}
``` 

Of course, we can exchange the very same JWT for user profile information just as we did with a plain access token:

```json
{
  "cn": "Misagh",
  "mail": "mm1844@gmail.com",
  "sn": "Moayyed",
  "service": "client",
  "id": "casuser",
  "client_id": "client"
}
```

## Signing & Encryption

If we wanted, we could turn on signing and encryption of our JWT access tokens:

```properties
cas.authn.oauth.accessToken.crypto.encryption.key=4fdqpa_mlx1XMtQR...
cas.authn.oauth.accessToken.crypto.signing.key=FXdUERkUNGqmai8oociQOyrHCQVYSW...
cas.authn.oauth.accessToken.crypto.enabled=true
cas.authn.oauth.accessToken.crypto.signing-enabled=true
cas.authn.oauth.accessToken.crypto.encryption-enabled=true
```                                                       

The same exercise can be repeated to make sure an encrypted/signed JWT can be decoded back to produce user profile information.

Of course, keys can always belong to a specific service definition, overriding the global default. If we wanted to, we could modify our sample service definition as such:

```json
{
  "@class" : "org.apereo.cas.support.oauth.services.OAuthRegisteredService",
  "clientId": "client",
  "clientSecret": "secret",
  "serviceId" : "https://example.net/dashboard",
  "name" : "OAUTH",  
  "jwtAccessToken": true, 
  "id" : 1,
  "attributeReleasePolicy" : {
    "@class" : "org.apereo.cas.services.ReturnAllowedAttributeReleasePolicy",
    "allowedAttributes" : [ "java.util.ArrayList", [ "cn", "mail", "sn" ] ]
  },
  "supportedGrantTypes": [ "java.util.HashSet", [ "password" ] ],
   "properties" : {
      "@class" : "java.util.HashMap",
      "accessTokenAsJwtSigningKey" : {
         "@class" : "org.apereo.cas.services.DefaultRegisteredServiceProperty",
         "values" : [ "java.util.HashSet", [ "..." ] ]
      },
      "accessTokenAsJwtEncryptionKey" : {
           "@class" : "org.apereo.cas.services.DefaultRegisteredServiceProperty",
           "values" : [ "java.util.HashSet", [ "..." ] ]
      },
      "accessTokenAsJwtSigningEnabled" : {
         "@class" : "org.apereo.cas.services.DefaultRegisteredServiceProperty",
         "values" : [ "java.util.HashSet", [ "true" ] ]
      },
      "accessTokenAsJwtEncryptionEnabled" : {
         "@class" : "org.apereo.cas.services.DefaultRegisteredServiceProperty",
         "values" : [ "java.util.HashSet", [ "true" ] ]
      }
    }
}
```

All properties should be optional; You may only specify that which you intend to override.

## What About...?

While it's nice to allow JWT access tokens on a per-service basis, you may want to extend that behavior to all applications and make JWT access tokens the global default. To do, you would need to turn on the following setting:

```properties 
cas.authn.oauth.accessToken.createAsJwt=true
```

When ciphers are turned on, JWT access tokens are by default (whether it's global or for a specific service) are always encrypted first and then signed. You can certainly
change the strategy type to reverse this behavior either globally or for a specific relying party:

```properties 
# cas.authn.oauth.accessToken.crypto.strategy-type=ENCRYPT_AND_SIGN
cas.authn.oauth.accessToken.crypto.strategy-type=SIGN_AND_ENCRYPT
```

## Bonus

You may have noticed that our JSON service definition contains a client secret in plain text. However,  client secrets can also be kept as encrypted secrets; To be clear, authorized relying parties always have 
access to and submit the client secret in plain text and CAS will auto-reverse the encryption of the secret found
in the service definition file for verification and matching.

Skipping other details for brevity, our service file could take on the following form:

```json
{
  "@class" : "org.apereo.cas.support.oauth.services.OAuthRegisteredService",
  "clientId": "client",
  "clientSecret": "{cas-cipher}eyJhbGciOiJIUzUxMiIs...",
  "serviceId" : "https://example.net/dashboard",
  "name" : "OAUTH",  
  "jwtAccessToken": true, 
  "id" : 1
 ...      
}
```

All you'd have to do is to take a plain secret and use the [CAS Command-line Shell](https://apereo.github.io/cas/development/installation/Configuring-Commandline-Shell.html) to transform it into encrypted 
form. The encryption and signing keys for client secrets may be defined via the following settings:

```properties 
cas.authn.oauth.crypto.encryption.key=...
cas.authn.oauth.crypto.signing.key=...
cas.authn.oauth.crypto.enabled=true
cas.authn.oauth.crypto.signing-enabled=true
cas.authn.oauth.crypto.encryption-enabled=true
```

<div class="alert alert-info">
<strong>Configuration Namespaces</strong><br/>Note the similarities of the above configuration block
and that of access tokens when it comes to the <code>crypto</code> namespace. This is not by chance,
as configuration namespaces in CAS are internally reused everywhere to streamline the specification
and validation process as much as possible for maximum code re-use. In <i>most cases</i>, such namespaces
in CAS configuration settings are transferable to other areas that declare support for the same feature
or namespace.  
</div>

# So...

I hope this review was of some help to you and I am sure that both this post as well as the functionality it attempts to explain can be improved in any number of ways. Please know that all other use cases, scenarios, features, and theories certainly [are possible](https://apereo.github.io/2017/02/18/onthe-theoryof-possibility/) as well. Feel free to [engage and contribute](https://apereo.github.io/cas/developer/Contributor-Guidelines.html) as best as you can.

Finally, if you benefit from Apereo CAS as free and open-source software, we invite you to [join the Apereo Foundation](https://www.apereo.org/content/apereo-membership) and financially support the project at a capacity that best suits your deployment. If you consider your CAS deployment to be a critical part of the identity and access management ecosystem and care about its long-term success and sustainability, this is a viable option to consider.

Happy Coding,

[Misagh Moayyed](https://fawnoos.com)
