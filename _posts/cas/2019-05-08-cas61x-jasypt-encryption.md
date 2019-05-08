---
layout:     post
title:      Apereo CAS - Configuration Security w/ Jasypt
summary:    Learn how to secure CAS configuration settings and properties with Jasypt.
tags:       [CAS]
---

<div class="alert alert-success">
<strong>Collaborate</strong><br/>This blog is managed and hosted on GitHub. If you wish to update the contents of this post or if you have found an inaccuracy and wish to make corrections, we recommend that you please submit a pull request to <a href="https://github.com/apereo/apereo.github.io">this repository</a>.
</div>

# Overview

If you are running CAS in standalone mode without the presence of the Spring Cloud configuration server, you can take advantage of built-in [Jasypt functionality](http://www.jasypt.org/) to decrypt sensitive CAS settings.

Jasypt is a java library which allows the deployer to add basic encryption capabilities to CAS. Jasypt supplies command-line tools useful for performing encryption, decryption, etc. In order to use the tools, you may download the Jasypt distribution. Once unzipped, you will find a `jasypt-$VERSION/bin` directory a number of `bat|sh` scripts that you can use for encryption/decryption operations `(encrypt|decrypt).(bat|sh)`.

However, an easier approach might be to use the native [CAS commandline shell](https://apereo.github.io/cas/development/installation/Configuring-Commandline-Shell.html). The CAS command-line shell provides the ability to query the CAS server for help on available settings/modules and various other utility functions one of which is the ability to encrypt and/or decrypt settings via Jasypt. We'll use the shell to encrypt a few settings and place them in your CAS configuration file, expecting the server to decrypt and use them as needed.

Our starting position is based on:

- CAS `6.1.x`
- Java `11`
- [CAS WAR Overlay](https://github.com/apereo/cas-overlay-template)

# Configuration

The [CAS WAR Overlay](https://github.com/apereo/cas-overlay-template) presents a few instructions on how to download and run the shell. Once you're in, you can take advantage of the following Jasypt-related commands:

```bash
help encrypt-value
...
help decrypt-value
```

So let's encrypt a setting:

```bash
cas>encrypt-value value casuser::Misagh alg PBEWithMD5AndTripleDES \
    provider SunJCE password ThisIsMyEncryptionKey iterations 1000

==== Encrypted Value ====
{cas-cipher}mMcg02NysblAcwYI+bFRpEcHBQaVQ51J
```

Nice. Let's verify that it can be decrypted back:

```bash
cas>decrypt-value value {cas-cipher}mMcg02NysblAcwYI+bFRpEcHBQaVQ51J \
    alg PBEWithMD5AndTripleDES provider SunJCE \
    password ThisIsMyEncryptionKey iterations 1000

==== Decrypted Value ====
casuser::Misagh
```

Next, let's use our typical `cas.properties` file with the encrypted value:

```properties
cas.authn.accept.users={cas-cipher}mMcg02NysblAcwYI+bFRpEcHBQaVQ51J
```

Almost there...the last task is to instruct CAS to use the proper algorithm, decryption key and other relevant parameters when attempting to decrypt settings.

```properties
# cas.standalone.configurationSecurity.alg=PBEWithMD5AndTripleDES
# cas.standalone.configurationSecurity.provider=SunJCE
# cas.standalone.configurationSecurity.iterations=1000
# cas.standalone.configurationSecurity.psw=ThisIsMyEncryptionKey
```

The above settings may be passed to CAS at runtime using either OS environment variables,
system properties or normal commandline arguments.

# More...

The shell also presents a few more Jasypt-related commands to list out algorithms, providers, etc. If you use the `help` command, you'd be presented with a list of available commands some of which are the following:

```bash
cas>help jasypt-list-algorithms
...
cas>help jasypt-list-providers
...
cas>help jasypt-test-algorithms
...
```

# So...

I hope this review was of some help to you and I am sure that both this post as well as the functionality it attempts to explain can be improved in any number of ways. Please know that all other use cases, scenarios, features, and theories certainly [are possible](https://apereo.github.io/2017/02/18/onthe-theoryof-possibility/) as well. Feel free to [engage and contribute](https://apereo.github.io/cas/developer/Contributor-Guidelines.html) as best as you can.

Happy Coding,

[Misagh Moayyed](https://twitter.com/misagh84)