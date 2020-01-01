---
layout:     post
title:      Introduction to CAS Commandline Shell
summary:    A short review of an interactive command-line shell provided by Apereo CAS.
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

Amongst the new features of CAS `5.2.x` is a [command-line tool](https://apereo.github.io/cas/development/installation/Configuring-Commandline-Shell.html) whose objective is to automate some of the more mundane deployment tasks by tapping into the CAS APIs to provide help on available settings/modules and various other utility functions. This shell engine that is based on [Spring Shell](https://projects.spring.io/spring-shell/) is presented as both a CLI utility and an interactive shell. 

In this post, I am going to provide an overview of the CAS Shell and enumerate a few utility functions that might prove useful during a CAS deployment.
 
# Environment

- CAS `5.2.0-SNAPSHOT`
- [CAS Maven WAR Overlay](https://github.com/apereo/cas-overlay-template)

# Spawn The Shell

While I am using the Maven WAR overlay, note that each CAS WAR Overlay deployment project should already be equipped with this functionality. You should not have to do anything *special* and extra to interact with the shell. See the relevant overlay documentation and `README` file for more info on how to invoke and work with the shell.

Specifically applicable to the Maven WAR Overlay, one may launch the CLI by simply executing the following command:

```bash
./build.sh cli
```

This should present you with the general welcome message as well as a list of command-line options accepted for various functions. 

# Command-line Options

One of the more useful utilities baked into CAS CLI tool is the ability to search for CAS settings and get better documentation and help on each. All individual CAS properties in most cases carry relevant Javadocs, examples, and links embedded right alongside the field in the housing component. The CAS build process upon every release attempts to collect all settings and their documentation into a JSON metadata file that can be queried by the CLI tool for more info. This of course not only includes CAS specific settings (i.e. `cas.authn.xyz=something`) but also all other Spring Boot settings and just about any other component that exposes its settings via a `@ConfigurationProperties`. 

If you want to learn more about how this is done, please [see this article](https://docs.spring.io/spring-boot/docs/current/reference/html/configuration-metadata.html).

## Examples

<div class="alert alert-info">
  <strong>Note</strong><br/>For the majority of the listed commands, I am going to skip the output. Feel free to try these yourself and observe the outcome.
</div>

### Configuration Metadata

Let's say we are looking for additional documentation on `duoApplicationKey`. To run the search, use:

```bash
# Skipping the CAS Banner via `-skb` 
./build.sh cli -skb -p duoApplicationKey
```

Cool, but maybe that's too limiting. How about notes on every setting in CAS that deals with `duo`? 

```bash
./build.sh cli -skb -p duo.+
```

The output seems too verbose. How about we compact it a little bit?

```bash
./build.sh cli -skb -p duo.+ --summary
```

Nice. What about some other non-CAS setting like, I don't know, `maxHttpPostSize`?

```bash
./build.sh cli -p maxHttpPostSize -skb
```

You see the above setting applies to Tomcat, Jetty and a few more. Here is a slightly fancier and more direct version:

```bash
./build.sh cli -p server.tomcat.max-http-post-size -skb
```

### Others

Other CLI options include the following:

- Generating JWTs: `./build.sh cli -gw -sub Misagh -skb`
- Generating keys for a CAS setting group that requires signing/encryption keys: `./build.sh cli -gk -p cas.tgc -skb`
- ...

As more options and commands are added to the CLI, you should always confirm new additions by simply running `./build.sh cli -h -skb` to get a listing of all options.

# Interactive Shell

There is also an interactive shell which essentially provides identical functionality to the CLI yet it is more flexible and powerful in many ways. Some of the key highlights include:

- A simple, annotation-driven, programming model to contribute custom commands
- Tab completion, colorization, and script execution
- Already built-in commands, such as clear screen, gorgeous help, exit

You can simply launch into the shell via `./build.sh cli -sh`. While in the shell, simply type `quit` to exit the shell.

## Shell Commands

In addition to a number built-in commands such as `help`, `version` and the most useful `cls` or `clear`, the following CAS-provided commands are available.

Remember:

- Use double-tab to take advantage of auto-completion and history.
- Use `help` to see a listing of all commands.
- Use `help <command-name>` to learn more about the command itself. 

### Find

Identical to its CLI equivalent, allows one to look up a CAS setting:

```bash
cas>find --name duo
```

### Undocumented Settings

Acts as a sanity check and lists undocumented properties for which allowing contributors to step up and contribute to the documentation:

```bash
cas>list-undocumented
```

### Generate JWTs

Identical to its CLI equivalent:

```bash
cas>generate-jwt --subject Misagh
```

### Generate Crypto Keys

Identical to its CLI equivalent:

```bash
cas>generate-key --group cas.tgc
```

### JSON To YAML

Convert a CAS service definition file in JSON to YAML and optionally save the file at path:

```bash
cas>generate-yaml /etc/cas/config/services/WSFED-400.json --destination /etc/cas/config/services/WSFED-400.yml
```

### Validate Service

Validate a service definition file in JSON or YAML to ensure correctness of syntax. Note that this command should and does support all service types (SAML2, OAuth, etc) provided by CAS:

```bash
cas>validate-service --file /etc/cas/config/services/WSFED-400.json
```

### Add Properties

All associated settings with a given property group are added to the properties file defined. Existing values should be preserved.

```bash
cas>add-properties --group cas.tgc --file /etc/cas/config/my.properties
```

# Extending Commands

When the shell is launched with the `-sh` option, all components under the `org.apereo.cas.shell` that are annotated with `org.springframework.stereotype.Service` are picked up as command implementations. 

The outline of a given command is as such:

```java
package org.apereo.cas.shell.commands;

@Service
public class DoesStuffCommand implements CommandMarker {
   
    @CliCommand(value = "do-stuff", help = "This does stuff")
    public void doStuff() {
       ...
    }
}
```
 
If you are interested in adding new and fancier commands, by all means create your own based on the above outline and contribute back.

# Summary

I hope this review was of some help to you. As you have been reading, I can guess that you have come up with a number of missing bits and pieces that would satisfy your use cases more comprehensively with CAS. In a way, that is exactly what this tutorial intends to inspire. Please feel free to [engage and contribute](https://apereo.github.io/cas/developer/Contributor-Guidelines.html) as best as you can.

[Misagh Moayyed](https://fawnoos.com)
