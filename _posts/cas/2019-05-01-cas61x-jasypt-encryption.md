---
layout:     post
title:      Apereo CAS - Configuration Security w/ Jasypt
summary:    Learn how you may decorate the Apereo CAS login webflow to inject data pieces and objects into the processing engine for display purposes, peace on earth and prosperity of all mankind, etc. Mainly, etc.

tags:       [CAS]
---

<div class="alert alert-success">
<strong>Collaborate</strong><br/>This blog is managed and hosted on GitHub. If you wish to update the contents of this post or if you have found an inaccuracy and wish to make corrections, we recommend that you please submit a pull request to <a href="https://github.com/apereo/apereo.github.io">this repository</a>.
</div>

# Overview


Our starting position is based on:

- CAS `6.1.x`
- Java `11`
- [CAS WAR Overlay](https://github.com/apereo/cas-overlay-template)

# Configuration

```bash
help encrypt-value
...
help decrypt-value
```

Encryption/Decryption:

```bash
cas>encrypt-value value casuser::Misagh alg PBEWithMD5AndTripleDES \
    provider SunJCE password ThisIsMyEncryptionKey iterations 1000

==== Encrypted Value ====
{cas-cipher}mMcg02NysblAcwYI+bFRpEcHBQaVQ51J

cas>decrypt-value value {cas-cipher}mMcg02NysblAcwYI+bFRpEcHBQaVQ51J \
    alg PBEWithMD5AndTripleDES provider SunJCE \
    password ThisIsMyEncryptionKey iterations 1000

==== Decrypted Value ====
casuser::Misagh
```

# So...

I hope this review was of some help to you and I am sure that both this post as well as the functionality it attempts to explain can be improved in any number of ways. Please know that all other use cases, scenarios, features, and theories certainly [are possible](https://apereo.github.io/2017/02/18/onthe-theoryof-possibility/) as well. Feel free to [engage and contribute](https://apereo.github.io/cas/developer/Contributor-Guidelines.html) as best as you can.

Happy Coding,

[Misagh Moayyed](https://twitter.com/misagh84)