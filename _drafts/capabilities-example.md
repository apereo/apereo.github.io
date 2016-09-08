---
layout:     post
title:      Pixyll capabilities
summary:    Sample of the Pixyll styles

---

All links are easy to [locate and discern](https://www.google.com){:target="_blank"}, yet don't detract from the harmony
of a paragraph. The _same_ goes for italics and __bold__ elements. Even the the strikeout
works if <del>for some reason you need to update your post</del>. For consistency's sake,
<ins>The same goes for insertions</ins>, of course.



### Code, with syntax highlighting

### YAML
<pre class="prettyprint lang-yaml">
---
services:
  - !serviceWithAttributes
    id: 1
    name: ONE
    description: Google service
    serviceId: https://www.google.com/**
    evaluationOrder: 1
    theme: default
    enabled: false
    ssoEnabled: false
    anonymousAccess: true
    allowedToProxy: false
    allowedAttributes: [uid, mail]
    ignoreAttributes: false
    usernameAttribute: cn
    logoutType: FRONT_CHANNEL
    extraAttributes:
      authzAttributes:
        memberOf: [group1, group2]
        anotherAttr: val
      unauthorizedUrl: http://exammple.com


  - !serviceWithAttributes
    id: 2
    name: TWO
    serviceId: https://yahoo.com
    evaluationOrder: 2
    attributeFilter: !regexAttributeFilter ["https://.+"]

  - !regexServiceWithAttributes
    id: 3
    name: THREE
    serviceId: ^(https?|imaps?)://.*
    evaluationOrder: 3
    attributeFilter: !defaultAttributeFilter []
    requiredHandlers: [handler1, handler2]
</pre>


### XML
<pre class="prettyprint">
&lt;cas:accept-users-authentication-handler
        id=&quot;acceptUsersAuthnHandler&quot;&gt;
        &lt;cas:user name=&quot;user1&quot; password=&quot;pass1&quot;/&gt;
        &lt;cas:user name=&quot;user2&quot; password=&quot;pass2&quot;/&gt;
&lt;/cas:accept-users-authentication-handler&gt;
</pre>

### Java
<pre class="prettyprint lang-java">
  public class Person {
    private String name;

    public String greet(String otherPerson) {
      System.out.println("Hello world");
      return "Hello world";
    }
  }
</pre>

### Groovy
<pre class="prettyprint lang-java">
  (1..10).each {
    println it
    println 'String'
    println "GString"
    //Comment
    /* comment
       and comment
     */
  }
</pre>

# Headings!

They're responsive, and well-proportioned (in `padding`, `line-height`, `margin`, and `font-size`).
They also heavily rely on the awesome utility, [BASSCSS](http://www.basscss.com/).

##### They draw the perfect amount of attention

This allows your content to have the proper informational and contextual hierarchy. Yay.

### There are lists, too

  * Apples
  * Oranges
  * Potatoes
  * Milk

  1. Mow the lawn
  2. Feed the dog
  3. Dance

### Images look great, too

![desk](https://cloud.githubusercontent.com/assets/1424573/3378137/abac6d7c-fbe6-11e3-8e09-55745b6a8176.png)


### There are also pretty colors

Also the result of [BASSCSS](http://www.basscss.com/), you can <span class="bg-dark-gray white">highlight</span> certain components
of a <span class="red">post</span> <span class="mid-gray">with</span> <span class="green">CSS</span> <span class="orange">classes</span>.

I don't recommend using blue, though. It looks like a <span class="blue">link</span>.

### Stylish blockquotes included

You can use the markdown quote syntax, `>` for simple quotes.

> Lorem ipsum dolor sit amet, consectetur adipiscing elit. Suspendisse quis porta mauris.

However, you need to inject html if you'd like a citation footer. I will be working on a way to
hopefully sidestep this inconvenience.

<blockquote>
  <p>
    Perfection is achieved, not when there is nothing more to add, but when there is nothing left to take away.
  </p>
  <footer><cite title="Antoine de Saint-Exupéry">Antoine de Saint-Exupéry</cite></footer>
</blockquote>

### There's more being added all the time

Checkout the [Github repository](https://github.com/johnotander/pixyll) to request,
or add, features.

Happy writing.
