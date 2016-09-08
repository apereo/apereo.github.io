---
layout:     post
title:      CAS Vulnerability Disclosure
summary:    CAS vulnerability disclosure describing an issue with the Apache Commons Collections library usage.
categories: blog
date:       2016-04-08 12:32:18
---

# Remember

This post is **NOT** new. I am just collecting it here so it's publicly available.
This was originally published as a secret gist on Github in April 2016.


# Overview

This is an Apereo CAS project vulnerability disclosure, describing an issue in CAS's attempts to deserialize objects via the Apache Commons Collections library.

# Affected Deployments

The attack vector specifically applies to all deployments of CAS `v4.1.x` and `v4.2.x` deployments where the out-of-the-box default configuration of CAS is used for managing object serialization, encryption and signing of data.

You are **NOT** affected by this issue, if:

- You have deployed a different CAS version, lower than `v4.1.0`.
- You have deployed CAS `v4.1.x` or `v4.2.x`, **BUT** you have removed the default CAS configuration for encryption/signing and have regenerated the appropriate settings for your own deployment.

Exploiting the vulnerability hinges on getting the JVM to de-serialize Java objects from arbitrary serialized data. If the above conditions describe your deployment, we **STRONGLY** recommend that you take necessary action to patch your deployment based on the below instructions.

# Severity

This is a very serious issue where successfully exercising this vulnerability allows the adversary to inject arbitrary code. This disclosure is about a specific exploit path involving a bugged version of Apache Commons Collections. This exploit path is only an instance of a larger JVM Java object deserialization security concern.

# Patching

Patch releases are now available to address CAS `v4.1.x` and `v4.2.x` deployments. Upgrades to the next patch version for each release should be a drop-in replacement, with some effort to appropriately reconfigure CAS encryption/signing settings via the `cas.properties` file.

## CAS 4.1.x

### Overlay
Modify your CAS overlay to point to version `4.1.7`.

A snippet of a `pom.xml` for a CAS overlay follows:

```xml
...

<dependencies>
    <dependency>
        <groupId>org.jasig.cas</groupId>
        <artifactId>cas-server-webapp</artifactId>
        <version>${cas.version}</version>
        <type>war</type>
        <scope>runtime</scope>
    </dependency>
</dependencies>

<properties>
    <cas.version>4.1.7</cas.version>
</properties>
...
```

### TGC Settings

Locate your `cas.properties` file and find the `tgc.*` settings.

- If your CAS deployment is **NOT** using the default encryption/signing keys provided by CAS and you have regenerated new keys and have replaced the default, you can safely ignore this step and leave your key configuration of signing/encryption in place without any further changes.

- If your CAS deployment **IS** using the default encryption/signing keys provided by CAS and you have **NOT** regenerated new keys to replace the default, you **MUST** take action to regenerate the keys.

You can choose one of the two approaches described below to handle key regeneration.

#### 1) Let CAS Generate Keys

Blank/comment out the following `tgc` settings:

```properties
# tgc.encryption.key=
# tgc.signing.key=
```

Build and deploy your CAS deployment once. Upon startup, CAS will notice that no keys are defined, and it will appropriately generate keys for you automatically. Your CAS logs will then show the following snippet:

```bash
WARN [org.jasig.cas.util.BaseStringCipherExecutor] - <Secret key for encryption is not defined. CAS will attempt to auto-generate the encryption key>
WARN [org.jasig.cas.util.BaseStringCipherExecutor] - <Generated encryption key ABC of size ... . The generated key MUST be added to CAS settings.>
WARN [org.jasig.cas.util.BaseStringCipherExecutor] - <Secret key for signing is not defined. CAS will attempt to auto-generate the signing key>
WARN [org.jasig.cas.util.BaseStringCipherExecutor] - <Generated signing key XYZ of size ... . The generated key MUST be added to CAS settings.>
```

You should then grab each generated key for encryption and signing, and put them inside your `cas.properties` file for each now-enabled setting:

```properties
tgc.encryption.key=ABC
tgc.signing.key=XYZ
```

#### 2) Manually Generate Keys

Using a `git` client, clone and build the following project:

```bash
git clone https://github.com/mitreid-connect/json-web-key-generator.git
cd json-web-key-generator
mvn clean package
cd target

# Encryption Key
java -jar json-web-key-generator-0.3-SNAPSHOT-jar-with-dependencies.jar -t oct -s 256

#
# Full key:
# {
#   "kty": "oct",
#   "k": "ABC"
# }
#

# Signing Key
java -jar json-web-key-generator-0.3-SNAPSHOT-jar-with-dependencies.jar -t oct -s 512

# Full key:
# {
#   "kty": "oct",
#   "k": "XYZ"
# }

```
You should then grab each generated key for encryption and signing, and put them inside your `cas.properties` file for each now-enabled setting:

```properties
tgc.encryption.key=ABC
tgc.signing.key=XYZ
```

### Webflow Settings

Locate your `cas.properties` file and find the `webflow.*` settings. If you do not see them in your configuration, go ahead and define them:

```properties
# webflow.encryption.key=
# webflow.signing.key=
```

You can choose one of the two approaches described below to handle key regeneration.

#### 1) Let CAS Generate Keys

Blank/comment out the following `webflow` settings:

```properties
# webflow.encryption.key=
# webflow.signing.key=
```

Build and deploy your CAS deployment once. Upon startup, CAS will notice that no keys are defined, and it will appropriately generate keys for you automatically. Your CAS logs will then show the following snippet:

```bash
WARN [org.jasig.cas.util.BinaryCipherExecutor] - <Secret key for encryption is not defined. CAS will attempt to auto-generate the encryption key>
WARN [org.jasig.cas.util.BinaryCipherExecutor] - <Generated encryption key ABC of size ... . The generated key MUST be added to CAS settings.>
WARN [org.jasig.cas.util.BinaryCipherExecutor] - <Secret key for signing is not defined. CAS will attempt to auto-generate the signing key>
WARN [org.jasig.cas.util.BinaryCipherExecutor] - <Generated signing key XYZ of size ... . The generated key MUST be added to CAS settings.>
```

You should then grab each generated key for encryption and signing, and put them inside your `cas.properties` file for each now-enabled setting:

```properties
webflow.encryption.key=ABC
webflow.signing.key=XYZ
```

#### 2) Manually Generate Keys

Using a `git` client, clone and build the following project:

```bash
git clone https://github.com/mitreid-connect/json-web-key-generator.git
cd json-web-key-generator
mvn clean package
cd target

# Encryption Key
java -jar json-web-key-generator-0.3-SNAPSHOT-jar-with-dependencies.jar -t oct -s 96

#
# Full key:
# {
#   "kty": "oct",
#   "k": "ABC"
# }
#

# Signing Key
java -jar json-web-key-generator-0.3-SNAPSHOT-jar-with-dependencies.jar -t oct -s 512

# Full key:
# {
#   "kty": "oct",
#   "k": "XYZ"
# }

```
You should then grab each generated key for encryption and signing, and put them inside your `cas.properties` file for each now-enabled setting:

```properties
webflow.encryption.key=ABC
webflow.signing.key=XYZ
```

### Finally
Rebuild and redeploy your CAS overlay.


## CAS 4.2.x

Modify your CAS overlay to point to version `4.2.1`.

A snippet of a `pom.xml` for a CAS overlay follows:

```xml
...

<dependencies>
    <dependency>
        <groupId>org.jasig.cas</groupId>
        <artifactId>cas-server-webapp</artifactId>
        <version>${cas.version}</version>
        <type>war</type>
        <scope>runtime</scope>
    </dependency>
</dependencies>

<properties>
    <cas.version>4.2.1</cas.version>
</properties>
...
```

### TGC Settings

Locate your `cas.properties` file and find the `tgc.*` settings.

- If your CAS deployment is **NOT** using the default encryption/signing keys provided by CAS and you have regenerated new keys and have replaced the default, you can safely ignore this step and leave your key configuration of signing/encryption in place without any further changes.

- If your CAS deployment **IS** using the default encryption/signing keys provided by CAS and you have **NOT** regenerated new keys to replace the default, you **MUST** take action to regenerate the keys.

You can choose one of the two approaches described below to handle key regeneration.

#### 1) Let CAS Generate Keys

Blank/comment out the following `tgc` settings:

```properties
# tgc.encryption.key=
# tgc.signing.key=
```

Build and deploy your CAS deployment. Upon startup, CAS will notice that no keys are defined, and it will appropriately generate keys for you automatically. Your CAS logs will then show the following snippet:

```bash
WARN [org.jasig.cas.util.BaseStringCipherExecutor] - <Secret key for encryption is not defined. CAS will attempt to auto-generate the encryption key>
WARN [org.jasig.cas.util.BaseStringCipherExecutor] - <Generated encryption key ABC of size ... . The generated key MUST be added to CAS settings.>
WARN [org.jasig.cas.util.BaseStringCipherExecutor] - <Secret key for signing is not defined. CAS will attempt to auto-generate the signing key>
WARN [org.jasig.cas.util.BaseStringCipherExecutor] - <Generated signing key XYZ of size ... . The generated key MUST be added to CAS settings.>
```

You should then grab each generated key for encryption and signing, and put them inside your `cas.properties` file for each now-enabled setting:

```properties
tgc.encryption.key=ABC
tgc.signing.key=XYZ
```
Rebuild and redeploy your CAS overlay.

#### 2) Manually Generate Keys

Using a `git` client, clone and build the following project:

```bash
git clone https://github.com/mitreid-connect/json-web-key-generator.git
cd json-web-key-generator
mvn clean package
cd target

# Encryption Key
java -jar json-web-key-generator-0.3-SNAPSHOT-jar-with-dependencies.jar -t oct -s 256

#
# Full key:
# {
#   "kty": "oct",
#   "k": "ABC"
# }
#

# Signing Key
java -jar json-web-key-generator-0.3-SNAPSHOT-jar-with-dependencies.jar -t oct -s 512

# Full key:
# {
#   "kty": "oct",
#   "k": "XYZ"
# }

```
You should then grab each generated key for encryption and signing, and put them inside your `cas.properties` file for each now-enabled setting:

```properties
tgc.encryption.key=ABC
tgc.signing.key=XYZ
```

### Webflow Settings

Locate your `cas.properties` file and find the `webflow.*` settings. If you do not see them in your configuration, go ahead and define them:

```properties
# webflow.encryption.key=
# webflow.signing.key=
```

You can choose one of the two approaches described below to handle key regeneration.

#### 1) Let CAS Generate Keys

Blank/comment out the following `webflow` settings:

```properties
# webflow.encryption.key=
# webflow.signing.key=
```

Build and deploy your CAS deployment once. Upon startup, CAS will notice that no keys are defined, and it will appropriately generate keys for you automatically. Your CAS logs will then show the following snippet:

```bash
WARN [org.jasig.cas.util.BinaryCipherExecutor] - <Secret key for encryption is not defined. CAS will attempt to auto-generate the encryption key>
WARN [org.jasig.cas.util.BinaryCipherExecutor] - <Generated encryption key ABC of size ... . The generated key MUST be added to CAS settings.>
WARN [org.jasig.cas.util.BinaryCipherExecutor] - <Secret key for signing is not defined. CAS will attempt to auto-generate the signing key>
WARN [org.jasig.cas.util.BinaryCipherExecutor] - <Generated signing key XYZ of size ... . The generated key MUST be added to CAS settings.>
```

You should then grab each generated key for encryption and signing, and put them inside your `cas.properties` file for each now-enabled setting:

```properties
webflow.encryption.key=ABC
webflow.signing.key=XYZ
```

#### 2) Manually Generate Keys

Using a `git` client, clone and build the following project:

```bash
git clone https://github.com/mitreid-connect/json-web-key-generator.git
cd json-web-key-generator
mvn clean package
cd target

# Encryption Key
java -jar json-web-key-generator-0.3-SNAPSHOT-jar-with-dependencies.jar -t oct -s 96

#
# Full key:
# {
#   "kty": "oct",
#   "k": "ABC"
# }
#

# Signing Key
java -jar json-web-key-generator-0.3-SNAPSHOT-jar-with-dependencies.jar -t oct -s 512

# Full key:
# {
#   "kty": "oct",
#   "k": "XYZ"
# }

```
You should then grab each generated key for encryption and signing, and put them inside your `cas.properties` file for each now-enabled setting:

```properties
webflow.encryption.key=ABC
webflow.signing.key=XYZ
```

### Finally
Rebuild and redeploy your CAS overlay.

# Clustered CAS Deployments

If you are running a cluster of CAS nodes, please be advised that the newly generated keys for all settings (regardless of the method of generation, whether CAS or you) **MUST** be shared with all CAS nodes in form of either a centralized or replicated/shared `cas.properties` file.

Failure to do so will completely break CAS functionality.

If you only have a single-node CAS deployment, there is nothing further for you to do.

# Support
If you have questions on the details this vulnerability and how it might be reproduced, please contact `security@apereo.org` or `cas-appsec-public@apereo.org`.

# Resources

* [Apache Commons statement to widespread Java object de-serialisation vulnerability](https://blogs.apache.org/foundation/entry/apache_commons_statement_to_widespread)
* [Apache Commons Collections security reports](https://commons.apache.org/proper/commons-collections/security-reports.html)
