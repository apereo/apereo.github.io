---
layout:     post
title:      Apereo CAS - SAML2 Metadata with MongoDb
summary:    CAS distributed SAML2 metadata management using MongoDB, where you learn how to store metadata documents inside MongoDB for CAS as a SAML2 identity provider and all other registered SAML2 service providers.
tags:       [CAS]
---

<div class="alert alert-success">
  <strong>Collaborate</strong><br/>The blog is managed and hosted on GitHub. If you wish to update the contents of this post or if you have found an inaccuracy and wish to make corrections, we recommend that you please submit a pull request to <a href="https://github.com/apereo/apereo.github.io">this repository</a>.
</div>

[MongoDB](https://www.mongodb.com) is a free and open-source cross-platform document-oriented database program. Classified as a NoSQL database program, MongoDB uses JSON-like documents with schemata and is supported in CAS in many different ways. In this walkthrough, we are going to take a pass at getting [CAS connected to MongoDB](https://apereo.github.io/cas/development/installation/Configuring-SAML2-DynamicMetadata.html#mongodb) to store SAML2 identity provider *and* service provider metadata documents.

Our starting position is based on the following:

- CAS `6.0.0-RC4`
- Java 11
- [CAS Overlay](https://github.com/apereo/cas-overlay-template) (The `master` branch specifically)
- [Docker](https://www.docker.com/get-started)

## MongoDB

To run MongoDB for development and testing, we can use the provided Docker image:

```bash
docker run -d -p 27017:27017 -e MONGO_INITDB_ROOT_USERNAME=root \
  -e MONGO_INITDB_ROOT_PASSWORD=secret --name="mongodb-server" mongo:4.0-xenial
docker ps
```

This runs a MongoDB database server which is useful for development but **SHOULD NOT** be used in production.

To access the MongoDB instance using a UI, run:

```bash
docker run --link mongodb-server -d -p 8081:8081 \
  -e 'ME_CONFIG_MONGODB_ADMINUSERNAME=root' \
  -e 'ME_CONFIG_MONGODB_ADMINPASSWORD=secret' \
  -e 'ME_CONFIG_MONGODB_SERVER=mongodb-server' mongo-express
```

The `ME_CONFIG_MONGODB_SERVER` is the address of the docker container that runs the MongoDB server. By default, Docker containers use the container as the DNS host name. So we can just specify the `mongodb-server` the name of the container that runs our MongoDB instance. 


Shell into the container:

```bash
CID=docker ps -aqf name=mongodb-server
docker exec -it $CID /bin/bash
```

When inside the container:

```bash
mongo --host mongodb://root:secret@localhost:27017
use database cas;

# Create a database user for authentication
db.createUser({user:"casuser", pwd:"Mellon", roles: ["readWrite", "dbAdmin"]})
```

Point your browser to `http://localhost:8081` and let's create a collection called `cas-saml-sp-metadata` with the following document:

![image](https://user-images.githubusercontent.com/1205228/47908722-10576a80-dea3-11e8-82e1-b812c085d1c0.png)

Note the `value` field which contains a base64-encoded version of the metadata for a SAML2 service provider which makes it easier to get the metadata added to the MongoDB document. I am also skipping over the metadata signature that would have been used to validate its integrity and that could have just as easily been added to the document using a `signature` field.

That should do for now. Let's get CAS running.

## CAS

### SAML2 Service Provider Metadata

So in order to enable a CAS integration with MongoDB *directly*, you want to start with the [CAS Overlay](https://github.com/apereo/cas-overlay-template), clone the project and follow [the notes here](https://apereo.github.io/cas/development/installation/Configuring-SAML2-Authentication.html) to get CAS acting as SAML2 identity provider. In its simplest form, it comes to down to the following settings:

```properties
cas.authn.samlIdp.entityId=https://sso.example.org/idp
cas.authn.samlIdp.scope=example.org
cas.authn.samlIdp.metadata.location=file:/etc/cas/config/saml
```

...and this module in the CAS build:

```gradle
compile "org.apereo.cas:cas-server-support-saml-idp:${project.'cas.version'}"
```

To keep things simple, we could use the [JSON service registry](https://apereo.github.io/cas/development/services/JSON-Service-Management.html) to manage our SAML2 service provider definitions. Here is what our service definition might look like for SAML2 service provider in a `SAML-1.json` file:

```json
{
  "@class" : "org.apereo.cas.support.saml.services.SamlRegisteredService",
  "serviceId" : "<your-sp-entity-id></your-sp-entity-id>",
  "name" : "SAML",
  "id" : 1,
  "description" : "This SP has its metadata in MongoDB somewhere.",
  "metadataLocation" : "mongodb://"
}
```

The metadata location in the registration record above simply needs to be specified as `mongodb://` to signal to CAS that SAML metadata for our service provider must be fetched from MongoDB data sources defined in CAS configuration. As the next step, let's [teach CAS]((https://apereo.github.io/cas/development/installation/Configuring-SAML2-DynamicMetadata.html#mongodb)) about our MongoDB setup. Just like before, you'd need this module in your CAS build:

```gradle
compile "org.apereo.cas:cas-server-support-saml-idp-metadata-mongo:${project.'cas.version'}"
```

...and CAS needs to know how to connect to MongoDB to fetch stuff:

```properties
cas.authn.samlIdp.metadata.mongo.host=localhost
cas.authn.samlIdp.metadata.mongo.port=27017
cas.authn.samlIdp.metadata.mongo.userId=casuser
cas.authn.samlIdp.metadata.mongo.password=Mellon
cas.authn.samlIdp.metadata.mongo.collection=cas-saml-sp-metadata
cas.authn.samlIdp.metadata.mongo.databaseName=cas
```

That's it. Build and run CAS. At this point, you should be able to log into service provider successfully whose metadata is fetched and processed by CAS from MongoDB.


### SAML2 Identity Provider Metadata

If you examine your CAS startup logs, you might notice the following statement:

```bash
[...FileSystemSamlIdPMetadataLocator] - <Metadata directory location is at [/etc/cas/config/saml]>
```

...which matches our setting above:

```properties
cas.authn.samlIdp.metadata.location=file:/etc/cas/config/saml
```

Metadata artifacts that belong to CAS as a SAML2 identity provider may also be managed and stored via MongoDb. This includes things such as the metadata XML document, signing and encryption keys, etc. While CAS has the ability to generate brand new metadata in MongoDB, let's instead figure out how our existing metadata might be relocated to MongoDB.

Let's create a MongoDB collection called `saml-idp-metadata` in our `cas` database to hold IdP artifacts with the following document in it:

```json
{
    "signingCertificate": "...",
    "signingKey": "...",
    "encryptionCertificate": "...",
    "encryptionKey": "...",
    "metadata": "..."
}
```

Here is the drill:

- The metadata, signing and encryption *certificates* may be base64-encoded.
- The signing and encryption *keys* **MUST** be signed and encrypted using CAS crypto settings and keys.

The signing key and the encryption key are both JWKs of size 512 and 256. We can use the [command-line shell](https://apereo.github.io/cas/development/installation/Configuring-Commandline-Shell.html) to create the two keys:

```bash
cas> generate-key key-size 512
$signingKey
cas> generate-key key-size 256
$encryptionKey
```

Once you have the keys, you can try to secure the metadata keys:

```bash
cas> cipher-text file /etc/cas/config/saml/idp-signing.key signing-key $signingKey encryption-key $encryptionKey
...
cas> cipher-text file /etc/cas/config/saml/idp-encryption.key signing-key $signingKey encryption-key $encryptionKey
...
```

The signing and encryption SAML2 metadata keys plus the base64-encoded versions of the signing and encryption certificates and the metadata XML can next be put into the MongoDB document.

![image](https://user-images.githubusercontent.com/1205228/47927581-f2a4f800-ded8-11e8-8180-5e299be02114.png)

CAS settings will then take on the following form:

```properties
# cas.authn.samlIdp.metadata.location=file:/etc/cas/config/saml
cas.authn.samlIdp.metadata.mongo.idpMetadataCollection=saml-idp-metadata
cas.authn.samlIdp.metadata.mongo.crypto.encryption.key=$encryptionKey
cas.authn.samlIdp.metadata.mongo.crypto.signing.key=$signingKey
```

Build and run CAS. At this point, you should be able to log into the service provider successfully with CAS using its own SAML2 metadata from MongoDB to produce a SAML2 response, etc.

## Finale

I hope this review was of some help to you and I am sure that both this post as well as the functionality it attempts to explain can be improved in any number of ways. Please feel free to [engage and contribute](https://apereo.github.io/cas/developer/Contributor-Guidelines.html) as best as you can.

[Misagh Moayyed](https://twitter.com/misagh84)