---
layout: post
title: Apereo CAS - External Identity Providers
summary: An overview of Apereo CAS' ability to register identity providers for external and delegated authentication attempts.
tags: [CAS]
---

External identity providers registered with CAS, such as those that speak the OpenID Connect or SAML2 protocol largely remain static throughout the server lifecycle. Once built and available, their configuration remains in read-only mode and can only be modified with direct access to CAS configuration, server rebuilds and restarts.

Building on top of [Dynamic Configuration Management](https://apereo.github.io/2026/02/07/cas-dynamic-configuration-management/) features, newer CAS `8.x` releases now allow one to register and modify external identity providers that can be used for delegated authentication attempts. The registration of external identity providers is now handled and supported by the Palantir admin dashbord.

This post provides an overview of external identity providers can be registered with the CAS server dynamically, without having to restart the server. Please note that this work is supported by and executed as part of the CAS proposal to [NLnet](https://apereo.github.io/2026/02/01/cas-nlnet/).

# Overview

As discussed, the main objective here is to allow the Palantir admin dashbord to support registering external identity providers. Doing so requires one to use [Dynamic Configuration Management](https://apereo.github.io/2026/02/07/cas-dynamic-configuration-management/) features of CAS to allow on-the-fly registration of external providers and gain the ability to edit their configuration without having to rebuild or restart. 

Starting with most recent releases of CAS `8.x`, Palantir admin dashbord now provides a humble view of all available external identity providers, regardless of their method of registration and configuration:

<img src="{{ site.url }}/images/image-6.png" />

The most notable change here is the `NEW` button which allows one to register an identity provider. Available identity provider types are for now limited to the following set:

## CAS

<img src="{{ site.url }}/images/image-7.png" />

## OpenID Connect

<img src="{{ site.url }}/images/image-8.png" />

## OAUTH

<img src="{{ site.url }}/images/image-9.png" />

## Keycloak

<img src="{{ site.url }}/images/image-10.png" />

## SAML2

<img src="{{ site.url }}/images/image-11.png" />

## Modifications

The registration process requires [Dynamic Configuration Management](https://apereo.github.io/2026/02/07/cas-dynamic-configuration-management/) features of CAS. Once an identity provider is registered, its configuration can be modified and edited exactly as any other CAS setting, since all configuration constructs are eventually translated to CAS properties and ultimately become available to the CAS application context. 

## Roadmap

The admin dashboard today supports a limited set of external identity provider types and a narrowed populist view of what can be configured for each provider. Going forward, the intention is to customize and enhance the registration process to add more identity provider types and support additional settings as necessary.

On behalf of the CAS project,

[Misagh Moayyed](https://fawnoos.com/misagh)