---
layout:     post
title:      Link CAS OIDC user to existing Database user 
summary:    In which we show to link OIDC id to LDAP database user.
tags:       [CAS]
---


<div class="alert alert-info">
  <strong>Contributed Content</strong><br/>Francis Le Coq was kind enough to share this guide.
</div>

<div class="alert alert-success">
  <strong>Collaborate</strong><br/>This blog is managed and hosted on GitHub. If you wish to update the contents of this post or if you have found an inaccuracy and wish to make corrections, we recommend that you please submit a pull request to <a href="https://github.com/apereo/apereo.github.io">this repository</a>.
</div>

This example is here to show an example of our try to use CAS in order to authenticate users via France Connect, by registering them to our own database linked with an user that is already registered.

# What we want

The first thing is that the user register only internally via our own services, not via a public page but via our private system. That means that the user on first usage already has an account and can log into CAS via the Login Form. 

The second thing is that we want to give the possibility for the user to connect an OIDC, in our example it would be France Connect, but only if the user has already access to our website via Login Form.

In conclusion, on first connect via France Connect, the user will have to log onto France Connect and log onto Login Form in second in order to be recognized as the owner of the France Connect account used. On next France Connect login, the user will directly have access.

Form Login is the basic, login and password form from CAS.

# Our environment

- CAS `5.2.2`
- [CAS Maven WAR Overlay](https://github.com/apereo/cas-overlay-template)

# What is our configuration

We use an LDAP server and an OIDC CAS configuration. Not more than that. The user has two choices when on the CAS interface, the Login Form and the France Connect button.

We will use "cas.authn.pac4j.oidc" for configuring our OIDC to authenticate our user using France Connect. 
We will use "cas.authn.ldap" to authenticate our user using LDAP database.
We will use "cas.authn.attributeRepository.ldap" to retrieve some attributes after user authentication.

# What do we need

We need to :
- Connect to France Connect on the behalf of the user (when the user click on the button) and get the OIDC ID
- Take this ID and store it
- Ask the user to identify via Login Form
- Link the UserId and OIDC ID and store into our LDAP database
- Send back the user to its final destination which is the asked service

Simple !

# How to do it

## Define our first service
We will use CAS services, by asking a "requiredAttributes"

Create a file into your [service folder](https://apereo.github.io/cas/5.2.x/installation/Configuration-Properties.html#json-service-registry) or equivalent, https-01.json :
```json
//On any service, it will ask for UID, if not redirect
{
  "@class" : "org.apereo.cas.services.RegexRegisteredService",
  "serviceId" : "^(https|imaps)://.*",
  "name" : "default",
  "id" : 9997,
  "description" : "Welcome in here",
  "evaluationOrder" : 9998,
  // The usernameAttribute is always uid attribute for this service
  "usernameAttributeProvider" : {
    "@class" : "org.apereo.cas.services.PrincipalAttributeRegisteredServiceUsernameProvider",
    "usernameAttribute" : "uid"
  },
  "accessStrategy": {
    // We created and changed the AccessStrategy, see below why
    "@class" : "org.esupportail.cas.services.ClaExternalIDRegisteredServiceAccessStrategy",
    // If doesn't find 'uid' it will redirect to URL that will link and store IDs
    "unauthorizedRedirectUrl" : "https://my-jetty-server/claExternalID/",
    "requiredAttributes" : {
	    "@class" : "java.util.HashMap",
	    "uid" : [ "java.util.HashSet", [ ".*" ] ]
	  }
  }
}
```
On first OIDC authentication, France Connect transmit some attributes, but none of them are named 'uid', so at this moment CAS redirect the user to `"unauthorizedRedirectUrl": "https://my-jetty-server/claExternalID/"`.

In this simple URL we are missing some information that we need in our use case, the OIDC Id and the service target. It is not implemented into CAS to add those parameters automatically to the URL.

The second service configuration is
```json
{
  "@class" : "org.apereo.cas.services.RegexRegisteredService",
  "serviceId" : "^https?://.*/claExternalID/associate/.*",
  "name" : "Votre identité FranceConnect n'est pas connu dans l'établissement",
  "id" : 55,
  "theme": "cla",
  "description" : "Veuillez vous authentifier auprès de l'université pour confirmer votre identité",
  "evaluationOrder" : 55,
  "usernameAttributeProvider" : {
    "@class" : "org.apereo.cas.services.PrincipalAttributeRegisteredServiceUsernameProvider",
    "usernameAttribute" : "uid"
  },
  "attributeReleasePolicy" : {
    "@class" : "org.apereo.cas.services.ReturnAllAttributeReleasePolicy",
    "principalAttributesRepository" : {
      "@class" : "org.apereo.cas.authentication.principal.cache.CachingPrincipalAttributesRepository",
      "mergingStrategy" : "ADD"
    }
  }
}
```
This is when your standalone server send back to the second login Form, you need to give the theme.

## Force CAS to give OIDC ID

When CAS check "requiredAttributes", if an attribute is missing it will throw an Exception and a handler will catch this exception in order to redirect to the URL we added inside our service configuration. 

So we will add a new Exception inside the StrategyAccess and the ExceptionHandler will customize the Url.

For that part we need to add our new `ClaExternalIDPrincipalException` that will store the attributes coming  from our `ClaExternalIDRegisteredServiceAccessStrategy`. Second part, we need to override the handler `AuthenticationExceptionHandlerAction` and replace it by our own `ClaExternalIDAuthenticationExceptionHandlerAction`. 

First our `ClaExternalIDRegisteredServiceAccessStrategy`, this class is used into service configuration. It allows us to throw the exception, it needs as well to store the attributes needed later on.
```java
public class ClaExternalIDRegisteredServiceAccessStrategy extends DefaultClaExternalIDRegisteredServiceAccessStrategy {

    private static final Logger LOGGER = LoggerFactory.getLogger(ClaExternalIDRegisteredServiceAccessStrategy.class);
    
    //this function is used to check "requiredAttributes"
    public boolean doPrincipalAttributesAllowServiceAccess(final String principal, final Map<String, Object> principalAttributes) {
        if (!enoughAttributesAvailableToProcess(principal, principalAttributes)) {
            LOGGER.debug("Access is denied. enoughAttributesAvailableToProcess");
            return false;
        }

        if (doRejectedAttributesRefusePrincipalAccess(principalAttributes)) {
            LOGGER.debug("Access is denied. doRejectedAttributesRefusePrincipalAccess");
            return false;
        }
        
        if (!doRequiredAttributesAllowPrincipalAccess(principalAttributes, this.requiredAttributes)) {
            LOGGER.debug("Access is denied. doRequiredAttributesAllowPrincipalAccess");
            principalAttributes.put("principal", principal);
            //We throw our exception, it will be intercepted by the Handler inside the Webflow
            throw new ClaExternalIDPrincipalException("ClaExternalIDPrincipalException", new HashMap<>(), new HashMap<>(), principalAttributes);
        }        
        LOGGER.debug("Access is authorized");        
        return true;
    }
}
```

As you saw above, a new class appear `ClaExternalIDPrincipalException`, the handler will need it to recognize the situation.
```java
public class ClaExternalIDPrincipalException extends PrincipalException {
    public ClaExternalIDPrincipalException(
            final String message,
            final Map<String, Class<? extends Throwable>> handlerErrors,
            final Map<String, HandlerResult> handlerSuccesses,
            final Map<String, Object> principalAttributes) {
        super(message, handlerErrors, handlerSuccesses);
        setPrincipalAttributes(principalAttributes);
    }
    
    public void setPrincipalAttributes(Map<String, Object> principalAttributes){
        this.principalAttributes = principalAttributes;
    }
    
    public Map<String, Object> getPrincipalAttributes(){
        return this.principalAttributes;
    }
}
```

To finish this part, the handler that will modify the Url
```java
public class ClaExternalIDAuthenticationExceptionHandlerAction extends AuthenticationExceptionHandlerAction {

    protected String handleAuthenticationException(final AuthenticationException e,
                                                   final RequestContext requestContext) {
                                                       
        final URI url = WebUtils.getUnauthorizedRedirectUrlIntoFlowScope(requestContext);
        if (e.getHandlerErrors().containsKey(UnauthorizedServiceForPrincipalException.class.getSimpleName())) {
            if (url != null) {
                LOGGER.warn("Unauthorized service access for principal; CAS will be redirecting to [{}]", url);
                return CasWebflowConstants.STATE_ID_SERVICE_UNAUTHZ_CHECK;
            }
        }
        //We add this part to catch the exception thrown and we customize the url, 
        // adding the attributes from OIDC and the url service asked
        if (e instanceof ClaExternalIDPrincipalException) {
            if (url != null) {
                final ClaExternalIDPrincipalException eClaExternalID = (ClaExternalIDPrincipalException) e;
                final URI url2 = getUrl(url, eClaExternalID.getPrincipalAttributes(), WebUtils.getService(requestContext).getOriginalUrl());
                WebUtils.putUnauthorizedRedirectUrlIntoFlowScope(requestContext, url2);
                
                LOGGER.warn("Unauthorized service access for principal; CAS will be redirecting to [{}]", url2);
                return CasWebflowConstants.STATE_ID_SERVICE_UNAUTHZ_CHECK;
            }
        }

        final String handlerErrorName = getErrors()
                .stream()
                .filter(e.getHandlerErrors().values()::contains)
                .map(Class::getSimpleName)
                .findFirst()
                .orElseGet(() -> {
                    LOGGER.debug("Unable to translate handler errors of the authentication exception [{}]. Returning [{}]", e, UNKNOWN);
                    return UNKNOWN;
                });

        final MessageContext messageContext = requestContext.getMessageContext();
        final String messageCode = DEFAULT_MESSAGE_BUNDLE_PREFIX + handlerErrorName;
        messageContext.addMessage(new MessageBuilder().error().code(messageCode).build());
        return handlerErrorName;
    }
    
    /**
     * Create an URI object with attributes as paramaters in it
     */
    protected URI getUrl(final URI uri, final Map<String, Object> principalAttributes, final String target){
        MultiValueMap<String, String> queryParams = new LinkedMultiValueMap<String, String>();
        
        principalAttributes.forEach((key, i) -> {
            if(i instanceof Iterable){
                for (Object y : (Iterable) i) {
                    queryParams.add(key, (String) y);
                }
            } else {
                queryParams.add(key, (String) i);
            }
        });
        queryParams.add("target", target);
        
        UriComponents uriComponents = UriComponentsBuilder.newInstance()
            .fromUri(uri).queryParams(queryParams).build();
            
        try {
            return uriComponents.toUri();
        } catch(Exception e) {
            LOGGER.debug(e.toString());
        }
        
        throw new RuntimeException("Failed to create the URL");
    }
}
```
At this moment, everything is good but our handler is not registered to be used by Spring.


## Register the newly created handler

It is pretty simple, we will override the Bean `authenticationExceptionHandler` by creating our own customized configuration class. 
```java
@Configuration("ClaExternalIDConfiguration")
@EnableConfigurationProperties(CasConfigurationProperties.class)
public class ClaExternalIDConfiguration {    
    @Autowired
    private CasConfigurationProperties casProperties;
    
    @RefreshScope
    @Bean
    /**
     * This bean has the same name that the CAS "CasCoreWebflowConfiguration", so it will
     *  overwrite that class, it will work only because it is implemeted inside 
     *  the gradle overlay in our example
     */
    public Action authenticationExceptionHandler() {
        return new ClaExternalIDAuthenticationExceptionHandlerAction(handledAuthenticationExceptions());
    }
    
    public Set<Class<? extends Exception>> handledAuthenticationExceptions() {
        /*
         * Order is important here; We want the account policy exceptions to be handled
         * first before moving onto more generic errors. In the event that multiple handlers
         * are defined, where one failed due to account policy restriction and one fails
         * due to a bad password, we want the error associated with the account policy
         * to be processed first, rather than presenting a more generic error associated
         */
        final Set<Class<? extends Exception>> errors = new LinkedHashSet<>();
        errors.add(javax.security.auth.login.AccountLockedException.class);
        errors.add(javax.security.auth.login.CredentialExpiredException.class);
        errors.add(javax.security.auth.login.AccountExpiredException.class);
        errors.add(AccountDisabledException.class);
        errors.add(InvalidLoginLocationException.class);
        errors.add(AccountPasswordMustChangeException.class);
        errors.add(InvalidLoginTimeException.class);

        errors.add(javax.security.auth.login.AccountNotFoundException.class);
        errors.add(javax.security.auth.login.FailedLoginException.class);
        errors.add(UnauthorizedServiceForPrincipalException.class);
        errors.add(PrincipalException.class);
        errors.add(UnsatisfiedAuthenticationPolicyException.class);
        errors.add(UnauthorizedAuthenticationException.class);

        errors.addAll(casProperties.getAuthn().getExceptions().getExceptions());

        return errors;
    }
}
```
A last file for the configuration is needed in order to declare the configuration file into Spring.
```properties
org.springframework.boot.autoconfigure.EnableAutoConfiguration=org.esupportail.cas.config.ClaExternalIDConfiguration
```

## Linking the OIDC Id and UID

This part can be manage by a simple jetty server. Or with some work a spring Webflow implemented yourself.

In our side we choose the first case. As explained above, the server will need to receive the first call with the url we constructed and store the OIDC id into the session for example.

Next it will send back to a new page implementing a CAS client, that will ask for a new login form authentication. When that authentication is done and granted, it will send back to this page and receive the UID. 

At this moment, the server link both OIDC id and UID together into the database.

And on next login, CAS will get automatically the UID based on the OIDC id received by the OIDC supplier and grant the access.

## Make disappear the button on second login

For that, a theme has to be used via the service configuration, in our code we just replaced the casLoginView.html by one that `<div th:replace="fragments/loginProviders" />` has been removed.

# Conclusion

This solution is not perfect and could be maybe improved by using the webflow in order to make the linking possible. As well it has been only tested via an java overlay and will need some improvements if that is transformed into a module.

I hope it was instructive and it helped you to do what you wanted to do :)

The source are available on Github of course !

Find here our [Example source code](https://github.com/EsupPortail/cas-server-support-claExternalID/tree/5.2.x)
Plus our simple [Standalone LDAP linking server](https://github.com/EsupPortail/claExternalID/tree/5.2.x)

[Francis Le Coq](https://github.com/cifren)