---
layout:     post
title:      Apereo CAS - Custom Login Fields w/ Dynamic Bindings
summary:    Learn how to extend the Spring Webflow model to add custom fields to the CAS login form and the authentication process and take advantage of the additional user-provided data in customized authentication handlers.
tags:       [CAS]
---

<div class="alert alert-success">
  <strong>Collaborate</strong><br/>The blog is managed and hosted on GitHub. If you wish to update the contents of this post or if you have found an inaccuracy and wish to make corrections, we recommend that you please submit a pull request to <a href="https://github.com/apereo/apereo.github.io">this repository</a>.
</div>

Despite what you may have heard, I am here to put a stop to all rumors and clarify definitively that this blog post has nothing to do with Taylor Swift. Instead, this post deals with a pretty simple CAS use case, which is:

> How does one include additional fields into the login form and get access to field data in a custom CAS authentication handler?

Sounds quite legitimate. Let's start with the simpler answer, which is that any CAS authentication handler can always directly tap into the `HttpServletRequest` object to query and fetch parameters passed by the login form and other views. One could do this in *Spring Framework speech* using something like:

```java
...
HttpServletRequest request = ((ServletRequestAttributes)
  RequestContextHolder.currentRequestAttributes()).getRequest();
Object parameter = request.getParameter("whatever");
...
```

If this feels a bit uncomfortable, let's dig deeper to see how CAS might accommodate this use case in more *official* ways. 

Our starting position is based on:

- CAS `6.1.x`
- Java `11`
- [CAS WAR Overlay](https://github.com/apereo/cas-overlay-template)

## Overview

CAS presents the ability to augment the login form to include additional custom fields. These fields are taught to CAS using settings that describe modest behavior and tweaks for each and are then processed by the Spring Webflow engine to be *bound* to the object model that is ultimately in charge of handling and managing user input.

## Example

So imagine that in addition to the usual `username` and `password` fields you also wanted to ask the user for their `phone` as a mandatory field. To do this, you'd teach CAS about the new `phone` field:
 
```properties
cas.view.customLoginFormFields.phone.messageBundleKey=customLoginFormField.phone
cas.view.customLoginFormFields.phone.required=true
```

The CAS message/language bundle, typically `custom_messages.properties` file, should also contain the text for the new field:

```properties
customLoginFormField.phone=Telephone
customFields[phone].required=Telephone number must be specified.
```

If you build and bring up CAS, you might see something like this:

![image](https://user-images.githubusercontent.com/1205228/53297205-1a95cf80-37d8-11e9-9f82-aa1a2386aca3.png)

...and if you attempt to submit the form without the `phone` field:

![image](https://user-images.githubusercontent.com/1205228/53297209-35684400-37d8-11e9-996b-b173cf1c6040.png)

## Authentication Handling

Next, let's say you have registered the following authentication handler with CAS:

```java
public class MyAuthenticationHandler extends AbstractUsernamePasswordAuthenticationHandler {
    ...
    protected AuthenticationHandlerExecutionResult authenticateUsernamePasswordInternal(
        final UsernamePasswordCredential credential, final String originalPassword) {
        ...
    }
    ...
}
```


To receive and process the new `phone` field in your custom authentication handler, you would do something like:

```java
protected AuthenticationHandlerExecutionResult authenticateUsernamePasswordInternal(
    final UsernamePasswordCredential credential, final String originalPassword) {
    Object phone = credential.getCustomFields().get("phone");
    ...
}
```

## Finale

I hope this review was of some help to you and I am sure that both this post as well as the functionality it attempts to explain can be improved in any number of ways. Please feel free to [engage and contribute](https://apereo.github.io/cas/developer/Contributor-Guidelines.html) as best as you can.

[Misagh Moayyed](https://twitter.com/misagh84)
