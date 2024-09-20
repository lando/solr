---
title: Solr Lando Plugin
description: Add a highly configurable Apache Solr service to Lando for local development with all the power of Docker and Docker Compose.
next: ./config.html
---

# Solr

[Solr](https://solr.apache.org/) is highly reliable, scalable and fault tolerant, providing distributed indexing, replication and load-balanced querying, automated failover and recovery, centralized configuration and more. Solr powers the search and navigation features of many of the world's largest internet sites.

You can easily add it to your Lando app by adding an entry to the [services](https://docs.lando.dev/core/v3/services/lando.html) top-level config in your [Landofile](https://docs.lando.dev/core/v3).

```yaml
services:
  myservice:
    type: solr
```

## Supported versions

*   [9.7](https://hub.docker.com/_/solr/) **(experimental)**
*   [9.6](https://hub.docker.com/_/solr/) **(experimental)**
*   [9.5](https://hub.docker.com/_/solr/) **(experimental)**
*   [9.4](https://hub.docker.com/_/solr/) **(experimental)**
*   [9.3](https://hub.docker.com/_/solr/) **(experimental)**
*   [9.2](https://hub.docker.com/_/solr/) **(experimental)**
*   [9.1](https://hub.docker.com/_/solr/) **(experimental)**
*   [9](https://hub.docker.com/_/solr/) **(experimental)**
*   [9.0](https://hub.docker.com/_/solr/) **(experimental)**
*   [8](https://hub.docker.com/_/solr/)
*   [8.11](https://hub.docker.com/_/solr/)
*   [8.10](https://hub.docker.com/_/solr/)
*   [8.9](https://hub.docker.com/_/solr/)
*   [8.8](https://hub.docker.com/_/solr/)
*   [8.7](https://hub.docker.com/_/solr/)
*   [8.6](https://hub.docker.com/_/solr/)
*   [8.5](https://hub.docker.com/_/solr/)
*   [8.4](https://hub.docker.com/_/solr/)
*   [8.3](https://hub.docker.com/_/solr/)
*   [8.2](https://hub.docker.com/_/solr/)
*   [8.1](https://hub.docker.com/_/solr/)
*   [8.0](https://hub.docker.com/_/solr/)
*   **[7](https://hub.docker.com/_/solr/)** **(default)**
*   [7.7](https://hub.docker.com/_/solr/)
*   [7.6](https://hub.docker.com/_/solr/)
*   [custom](https://docs.lando.dev/core/v3/services/lando.html#overrides)

## Legacy versions

You can still run these versions with Lando but for all intents and purposes they should be considered deprecated (e.g. YMMV and do not expect a ton of support if you have an issue).

*   [6.6](https://hub.docker.com/_/solr/)
*   [6](https://hub.docker.com/_/solr/)
*   [5.5](https://hub.docker.com/_/solr/)
*   [5](https://hub.docker.com/_/solr/)
*   [4](https://hub.docker.com/r/actency/docker-solr)
*   [4.10](https://hub.docker.com/r/actency/docker-solr)
*   [3](https://hub.docker.com/r/actency/docker-solr)
*   [3.6](https://hub.docker.com/r/actency/docker-solr)

## Patch versions

::: warning Not officially supported!
While we allow users to specify patch versions for this service, they are not *officially* supported, so if you use one, YMMV. Also note that patch versions are not available for Solr 3.x and 4.x.
:::

To use a patch version, you can do something as shown below:

```yaml
services:
  myservice:
    type: solr:5.5.5
```

But make sure you use one of the available [patch tags](https://hub.docker.com/_/solr/tags) for the underlying image we are using.

