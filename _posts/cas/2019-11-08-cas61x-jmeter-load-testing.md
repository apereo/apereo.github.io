---
layout:     post
title:      Apereo CAS - JMeter Performance Testing
summary:    Learn to Performance Test Apereo CAS.
tags:       [CAS]
---

<div class="alert alert-success">
<strong>Collaborate</strong><br/>This blog is managed and hosted on GitHub. If you wish to update the contents of this post or if you have found an inaccuracy and wish to make corrections, we recommend that you please submit a pull request to <a href="https://github.com/apereo/apereo.github.io">this repository</a>.
</div>

# Overview

In this tutorial, we are going to be setting up the scenarios needed to performance test CAS. We will be using the JMeter test scripts that are included in the CAS source code repository! How fun is that?!

I hope by doing this, you will become more familiar with perf testing and can implement your own testing harness for future releases of CAS.

I do want to state that since perf testing can be highly subjective in what should be tested, we are going to be creating the minimal scenarios needed to successfully run the JMeter scripts. I hope you will then build off these scenarios to meet your testing needs.

Our starting position is:

- CAS `6.1.x`
- Java `11`
- [CAS WAR Overlay](https://github.com/apereo/cas-overlay-template)
- [CAS JMeter Scripts](https://github.com/apereo/cas/tree/master/etc/loadtests)
- [JMeter - Latest Version](http://jmeter.apache.org/download_jmeter.cgi)
- [CAS Online Manual - JMeter Performance Scripts](https://apereo.github.io/cas/6.1.x/high_availability/Performance-Testing-JMeter.html)

Note: I am assuming you already have a non-Prod working version of CAS running or at least have the knowledge of setting up a new CAS instance. Also, I will not be going over the process of getting CAS working with SAML2, since that has been covered in several other blog postings on the [Apereo CAS blog](https://apereo.github.io/) site. Finally, I will not be going over the installation of JMeter since there are a ton of online tutorials to install JMeter on any flavor of an operating system.

# CAS Performance Testing

### Modules

If you are brand new to performance testing and/or JMeter, please review this link [CAS Online Manual - JMeter Performance Scripts](https://apereo.github.io/cas/6.1.x/high_availability/Performance-Testing-JMeter.html) to get a better idea of how the included JMeter scripts work and how they can be customized.

There are currently 3 JMeter scripts in the CAS repository, each one focuses on a protocol currently supported by CAS. We will be building scenarios for the two most popular CAS and SAML2.

Below are the dependencies that will need to be added to the **build.gradle** file:

```gradle
dependencies {
    // Other CAS dependencies/modules may be listed here...
    compile "org.apereo.cas:cas-server-webapp-tomcat:${project.'cas.version'}"
    compile "org.apereo.cas:cas-server-support-json-service-registry:${casServerVersion}"
    compile "org.apereo.cas:cas-server-support-saml-idp:${project.'cas.version'}"
}
```

As you can see we will be using the Tomcat container module to support easy deployment of our CAS instance. We will also be using the JSON Service Registry module to support our JSON based Service Provider files. And lastly, we will add the module needed to support the SAML2 protocol. You will probably notice that we did not add a CAS protocol module, why? The CAS protocol is the native protocol used by the CAS application, therefore it is automatically available out of the box. CAS supports CAS! lol

So let's begin!

### CAS Protocol

File: **CAS_CAS.jmx**

Once you review the **CAS_CAS.jmx** file, you will notice that there are only 4 steps included with the script file for the CAS protocol. At a very basic level, the Service Provider (SP) requests authentication for a user, CAS then sends back a ticket to the SP after the users successful login, then the SP asks CAS to validate the ticket, and finally CAS validates the ticket and sends back the already negotiated parameters to the SP. This of course is an oversimplification of the protocol! We are just keeping it simple to make sure we can wrap our tiny brains around it! ;-)

Now that we know what is happening in the script, we now need to create the environment so we can run this JMeter script successfully!

#### Service Provider
To keep it simple, we will not be setting up a Service Provider instance for this perf test since it is not really needed.

#### CAS Settings
We have already added the **cas-server-support-json-service-registry** module, all we need to do is tell CAS where we will be storing the JSON based Service Provider files.

Add the following to the **cas.properties** file:
```properties
cas.serviceRegistry.json.location=file:/etc/cas/services
```

We will also need to create a new JSON Service file for a fictitious SP under the Service Registry location we just added:
**/etc/cas/services/castest-900.json**
```json
{
  "@class" : "org.apereo.cas.services.RegexRegisteredService",
  "serviceId" : "^https://castest.edu/.*",
  "name" : "casTest",
  "id" : 900
}
```

#### JMeter Settings
Update the User Defined Variables tab in the JMeter script to reflect the following:
```text
    IdPHost = https://casidp.edu:8443 (Same as cas.server.name in cas.properties)
    CasSP = castest.edu (Same as serviceId in JSON Service file)
``` 

Since we are keeping this simple, we will initially be testing with one user account. 

Verify in the **Cas-Users.csv** file that the user of **casuser** is in the file, if not add ```casuser,Mellon``` to the file. Then verify that script file is pointed to this .csv file under the "CSV Get Users/Passwords" tab of the script file.

Now run the JMeter script either from the command line or via the JMeter GUI and hopefully you should get a passing test!

### SAML Protocol

File: **CAS_SAML2.jmx**

Once you review the **CAS_SAML2.jmx** file, you will notice that the script has only 4 steps just like the CAS version, but a whole lot more is taking place in each of those steps! I am not planning on delving much deeper into the SAML2 protocol, since again this is a performance testing tutorial and not a SAML2 protocol tutorial. But I do want to point out that the script was purposely created so that it would support the majority of SAML2 calls with little to no tweaks needed within the HTTP requests sections. To me that is a life saver, whew!

#### CAS Settings - Part 1

Update the **cas.properties** file and add:
```properties
cas.authn.samlIdp.metadata.location=file:/etc/cas/saml
cas.authn.samlIdp.entityId=https://casidp.edu:8443/idp
```
Note: At this point you will need to run CAS to generate the appropriate certs and Idp metadata needed for the SAML2 metadata exchange with the SP.

#### Service Provider

Since we will need to generate metadata for the SP side of the equation, as well as the IdP side, it would behoove us to setup a SAML SP application to take care of generating the metadata for us. I know some of you consider yourselves to be SAML2 virtuoso's and think you can create a fictitious metadata file on the fly. Not me, I am a simple man with simple ways, so I will stand up a quick SAML2 SP instead. :-)
 
Rather than setup and configure a new SAML2 SP, I used a handy and also dandy Dockerized version of a Shibboleth SP contained in the [Dockerized Idp Testbed](https://github.com/UniconLabs/dockerized-idp-testbed) suite. This is an excellent learning tool that stands up two SAML2 SP's (Shibb and SimpleSAMLPHP), an Ldap instance and also an Idp via Docker. Nice!

Once I downloaded the Dockerized Testbed, I deactivated the Idp side of things and exchanged the metadata between the Shibboleth SP and my CAS instance. For those still learning, the SP metadata can be found in ```idp/shibboleth-idp/metadata/sp-metadata.xml```.

If you do not want to use the Testbed app, feel free to setup your SAML2 SP of choice! Some notable SP's are [Shibboleth SP](https://wiki.shibboleth.net/confluence/display/SP3) and [SimpleSAMLPHP](https://simplesamlphp.org/). Just remember that whatever choice you make, you may have to update the JMeter script to reflect the correct endpoints.

#### CAS Settings - Part 2

We will also need to create a new JSON Service file for the SAML2 SP in the same folder we added the castest JSON file. 

**/etc/cas/services/samltest-1000.json**
```json
{
  "@class" : "org.apereo.cas.support.saml.services.SamlRegisteredService",
  "serviceId" : "https://samltest.edu/shibboleth",
  "name" : "SamlTest",
  "id" : 1000,
  "metadataLocation": "/etc/cas/saml/metadata/sp.xml"
}
```

#### JMeter Settings

Now update the JMeter file to reflect the following:
```text
User Defined Variables:
    IdPHost = https://casidp.edu:8443 (Same as Saml Idp EntityId in cas.properties)
    CasSP = samltest.edu (Same as serviceId in JSON Service file)
    ProviderId = https://samltest.edu/shibboleth (EntityId of SP)
``` 

Now run the JMeter script and hopefully you should get a passing test!

# So...

I hope this has helped you in understanding how you can performance test CAS going forward and will help you in creating your own testing scenarios!

I hope you enjoyed it!

Finally, if you benefit from Apereo CAS as free and open-source software, we invite you to [join the Apereo Foundation](https://www.apereo.org/content/apereo-membership) and financially support the project at a capacity that best suits your deployment. If you consider your CAS deployment to be a critical part of the identity and access management ecosystem and care about its long-term success and sustainability, this is a viable option to consider.

As [Misagh Moayyed](https://twitter.com/misagh84) says 'Happy Coding'!

[Axel Stohn](https://github.com/astohn)
