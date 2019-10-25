---
layout:     post
title:      Apereo CAS - Password Management with JDBC
summary:    Learn use the Password Management features in Apereo CAS.
tags:       [CAS]
---

<div class="alert alert-success">
<strong>Collaborate</strong><br/>This blog is managed and hosted on GitHub. If you wish to update the contents of this post or if you have found an inaccuracy and wish to make corrections, we recommend that you please submit a pull request to <a href="https://github.com/apereo/apereo.github.io">this repository</a>.
</div>

# Overview

In this tutorial, we are going to pull back the covers on the Password Management (PM) module in CAS and see what features are available! How fun is that?!

I do want to state that the PM functionality included with CAS is rather modest and is not intended to be an all inclusive password management tool, but it does have some nice added functionality that can be taken advantage of when running CAS.

When reviewing the CAS documentation for Password Management (PM) support, you will notice it supports several different implementation methods from JSON to LDAP to REST.  Since I already have MySQL installed on my laptop, I am going to be using the JDBC implementation.  Also, rather than setup a new LDAP test instance for user authentication, I will take advantage of the MySQL instance I have on my laptop and use that as my user authentication source as well.

We will be taking advantage of the email support included with the PM module, as well as test the brand new feature Password History, woohoo! For the SMTP server, if you do not have access to one, please download the Fake SMTP Server from the link below.  It is a nice handy tool for testing.

Our starting position is based on:

- CAS `6.1.x`
- Java `11`
- MySQL or another supported relational database
- [Fake SMTP Server](http://nilhcem.com/FakeSMTP/)
- [CAS WAR Overlay](https://github.com/apereo/cas-overlay-template)
- [Database User Authentication](https://apereo.github.io/cas/development/installation/Database-Authentication.html)
- [Password Management](https://apereo.github.io/cas/development/password_management/Password-Management.html)

# User Authentication

### Modules

We will begin by installing the modules needed to support Database User Authentication. Since there already is an excellent blog post named [Database Authentication Tutorial](https://apereo.github.io/2017/02/22/cas51-dbauthn-tutorial/) on the Apereo site, I will be summarizing my steps for User Authentication.

```gradle
dependencies {
    // Other CAS dependencies/modules may be listed here...
   compile "org.apereo.cas:cas-server-webapp-tomcat:${project.'cas.version'}"
   compile "org.apereo.cas:cas-server-support-jdbc:${project.'cas.version'}"
}
```
### Database Settings
For the database, we are going to be very creative and name it **cas_auth**.  Very original! ;-)

Here is the MySQL SQL needed to generate the tables and also the users we will be testing:

```mysql
CREATE TABLE `Users` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `userid` varchar(255) NOT NULL DEFAULT '',
  `password` varchar(255) NOT NULL DEFAULT '',
  `email` varchar(255) NOT NULL DEFAULT '',
  `phone` varchar(255) DEFAULT NULL,
  `firstName` varchar(255) DEFAULT NULL,
  `lastName` varchar(255) DEFAULT NULL,
  `expired` int(11) NOT NULL DEFAULT '0',
  `disabled` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
);

# Creating this table now, will be used for the PM section of the tutorial
CREATE TABLE `Questions` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `userid` varchar(255) NOT NULL DEFAULT '',
  `question` varchar(255) NOT NULL DEFAULT '',
  `answer` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`)
);

INSERT INTO 'Users'  ('userid', 'password', 'email', 'phone', 'firstName', 'lastName', 'expired', 'disabled')
VALUES 
('LegitUser', 'Password1', 'test1@test.net', '111-867-5309', 'Legit', 'User', 0, 0),
('ExpiredUser', 'Password2', 'test2@test.net', '111-867-5310', 'Expired', 'User', 1, 0);

# Adding these questions now, will be used for the PM section of the tutorial
INSERT INTO 'Questions'  ('userid', 'question', 'answer')
VALUES 
('TestTwo', 'What is your favorite food?', 'Meat'),
('TestTwo', 'What is your favorite video game?', 'Fallout4');
```

### CAS Settings

Now we need to update our **cas.properties** file:
```properties
cas.authn.jdbc.query[0].user=<MySQL Login UserId>
cas.authn.jdbc.query[0].password=<MySQL Login Password>
cas.authn.jdbc.query[0].driverClass=com.mysql.jdbc.Driver
cas.authn.jdbc.query[0].dialect=org.hibernate.dialect.MySQLDialect

cas.authn.jdbc.query[0].url=jdbc:mysql://localhost:3306/cas_auth
cas.authn.jdbc.query[0].passwordEncoder.type=NONE

cas.authn.jdbc.query[0].sql=SELECT * FROM Users WHERE userid=?
cas.authn.jdbc.query[0].fieldPassword=password
cas.authn.jdbc.query[0].fieldExpired=expired
cas.authn.jdbc.query[0].fieldDisabled=disabled
```
As you can see, most of the fields are named accordingly and are referenced in the already noted [blog post](https://apereo.github.io/2017/02/22/cas51-dbauthn-tutorial/) above.

### Test

Start your CAS instance and test!

Now try and test authentication for **LegitUser** user. You should receive a CAS success page with the heading of **"Log In Successful"**.

Restart your browser and now try **expiredUser**.  Since this user was added with a **"1"** in the expired field, CAS should display a page with the heading of **"You must change your password."** and shows a link to an external site.  This is the basic Authentication available with the JDBC support for an expired user account, you can update the url within your message.properties file.  

Taking a user to a link is not very helpful since we want to use a backend database to manage passwords. 

This is where we can use the functionality of the PM module!

# Password Management

### Modules
Let's update our build.gradle file by adding the new dependencies needed for PM support and PM JDBC support:

```
dependencies {
    ...
   compile "org.apereo.cas:cas-server-support-pm-webflow:${project.'cas.version'}"
   compile "org.apereo.cas:cas-server-support-pm-jdbc:${project.'cas.version'}"
}
```

### Database

As you can see in the CAS online documentation for [PM JDBC Support](https://apereo.github.io/cas/development/password_management/Password-Management-JDBC.html), there is a specific schema that needs to be followed for PM support. When we initially created our db tables, I incorporated those requirements, so no changes are needed.  You're Welcome!

### CAS Settings

Now let’s update our **cas.properties** file:

```properties
# Enable PM module and Password History
cas.authn.pm.enabled=true
cas.authn.pm.history.enabled=true

# SMTP Settings
spring.mail.host=localhost
spring.mail.port=25
spring.mail.username=
spring.mail.password=
spring.mail.properties.mail.smtp.auth=false

# Password Reset Email Info
cas.authn.pm.reset.mail.from=CAS@test.net
cas.authn.pm.reset.mail.subject=Password change
cas.authn.pm.reset.mail.replyTo=CAS@test.net
cas.authn.pm.reset.mail.html=false
cas.authn.pm.reset.mail.attributeName=mail
cas.authn.pm.reset.expirationMinutes=5

# Forgot Username Email Info
cas.authn.pm.forgotUsername.mail.from=CAS@test.net
cas.authn.pm.forgotUsername.mail.subject=Forgot User Name
cas.authn.pm.forgotUsername.mail.replyTo=CAS@test.net
cas.authn.pm.forgotUsername.mail.html=false
cas.authn.pm.forgotUsername.mail.attributeName=userid

# Password Management Database Connection Info
cas.authn.pm.jdbc.user=<MySQL Login UserId>
cas.authn.pm.jdbc.password=<MySQL Login Password>
cas.authn.pm.jdbc.driverClass=com.mysql.jdbc.Driver
cas.authn.pm.jdbc.dialect=org.hibernate.dialect.MySQLDialect
cas.authn.pm.jdbc.url=jdbc:mysql://localhost:3306/cas_auth
cas.authn.pm.jdbc.passwordEncoder.type=NONE

# Enable Questions and Answers for PM
cas.authn.pm.reset.securityQuestionsEnabled=true

# Queries Needed to Support PM functionality
cas.authn.pm.jdbc.sqlSecurityQuestions=SELECT question, answer FROM Questions WHERE userid=?
cas.authn.pm.jdbc.sqlFindEmail=SELECT email FROM Users WHERE userid=?
cas.authn.pm.jdbc.sqlFindPhone=SELECT phone FROM Users WHERE userid=?
cas.authn.pm.jdbc.sqlFindUser=SELECT userid FROM Users WHERE email=?
cas.authn.pm.jdbc.sqlChangePassword=UPDATE Users SET password=?, expired=0 WHERE userid=?

# Password Requirements Policy
# Minimum 8 and Maximum 10 characters at least 1 Uppercase Alphabet, 1 Lowercase Alphabet, 1 Number and 1 Special Character
cas.authn.pm.policyPattern=^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[$@$!%*?&])[A-Za-z\\d$@$!%*?&]{8,10}
```
Wow! That is a lot of settings!  Hopefully you find them to be self-explanatory. I did try to group and add headings to relevant sections for a better explanation.

### Test

Restart you CAS instance and test!

Verify you can still login with **legitUser**, then try **expiredUser**. For **expiredUser**, instead of a link, you should now get a password change screen!  Nice!

Now, turn on your Fake STMP Server and test the two links below the **Login** button, **"Reset your password"** and **"Forgot your username?"**. 

Did you get the emails??  

Pretty cool, huh?

# Password History

When we added the new PM settings to our **cas.properties** file, we added this setting ```cas.authn.pm.history.enabled=true```. This setting gave CAS the green light to create a new table in our **cas_auth** database on our last startup.  The table is named **Password_History_Table** and CAS will use it to store all password changes made by the CAS users. Do not worry, CAS will not store the password in the clear, but a hash of the password as well as the userId and date of the change.

We can test this by changing the password of one of the test accounts several times and then try reusing one of the previous password on the password change screen. You should receive an error message of **"Could not update the account password"** and it will not be accepted by CAS. Cool!

# So...

That wraps up our peek into the PM functionality of CAS!

I hope you enjoyed it!

Finally, if you benefit from Apereo CAS as free and open-source software, we invite you to [join the Apereo Foundation](https://www.apereo.org/content/apereo-membership) and financially support the project at a capacity that best suits your deployment. If you consider your CAS deployment to be a critical part of the identity and access management ecosystem and care about its long-term success and sustainability, this is a viable option to consider.

As [Misagh Moayyed](https://twitter.com/misagh84) says 'Happy Coding'!

[Axel Stohn](https://github.com/astohn)
