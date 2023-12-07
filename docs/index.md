---
title: Solr Lando Plugin
description: Add a highly configurable Apache Solr service to Lando for local development with all the power of Docker and Docker Compose.
next: ./config.html
---

# Solr

[Solr](http://lucene.apache.org/solr/) is highly reliable, scalable and fault tolerant, providing distributed indexing, replication and load-balanced querying, automated failover and recovery, centralized configuration and more. Solr powers the search and navigation features of many of the world's largest internet sites.

You can easily add it to your Lando app by adding an entry to the [services](https://docs.lando.dev/config/services.html) top-level config in your [Landofile](https://docs.lando.dev/config/lando.html).

```yaml
services:
  myservice:
    type: solr
```

## Supported versions

*   [9](https://hub.docker.com/r/_/solr/) **(experimental)**
*   [9.0](https://hub.docker.com/r/_/solr/) **(experimental)**
*   [8](https://hub.docker.com/r/_/solr/)
*   [8.11](https://hub.docker.com/r/_/solr/)
*   [8.10](https://hub.docker.com/r/_/solr/)
*   [8.9](https://hub.docker.com/r/_/solr/)
*   [8.8](https://hub.docker.com/r/_/solr/)
*   [8.7](https://hub.docker.com/r/_/solr/)
*   [8.6](https://hub.docker.com/r/_/solr/)
*   [8.5](https://hub.docker.com/r/_/solr/)
*   [8.4](https://hub.docker.com/r/_/solr/)
*   [8.3](https://hub.docker.com/r/_/solr/)
*   [8.2](https://hub.docker.com/r/_/solr/)
*   [8.1](https://hub.docker.com/r/_/solr/)
*   [8.0](https://hub.docker.com/r/_/solr/)
*   **[7](https://hub.docker.com/r/_/solr/)** **(default)**
*   [7.7](https://hub.docker.com/r/_/solr/)
*   [7.6](https://hub.docker.com/r/_/solr/)
*   [custom](https://docs.lando.dev/config/services.html#advanced)

## Legacy versions

You can still run these versions with Lando but for all intents and purposes they should be considered deprecated (e.g. YMMV and do not expect a ton of support if you have an issue).

*   [6.6](https://hub.docker.com/r/_/solr/)
*   [6](https://hub.docker.com/r/_/solr/)
*   [5.5](https://hub.docker.com/r/_/solr/)
*   [5](https://hub.docker.com/r/_/solr/)
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

But make sure you use one of the available [patch tags](https://hub.docker.com/r/library/solr/tags/) for the underlying image we are using.

## Custom Installation

This plugin is included with Lando by default. That means if you have Lando version `3.0.8` or higher then this plugin is already installed!

However if you would like to manually install the plugin, update it to the bleeding edge or install a particular version then use the below. Note that this installation method requires Lando `3.5.0+`.

:::: code-group
::: code-group-item DOCKER
```bash:no-line-numbers
# Ensure you have a global plugins directory
mkdir -p ~/.lando/plugins

# Install plugin
# NOTE: Modify the "yarn add @lando/solr" line to install a particular version eg
# yarn add @lando/solr@0.5.2
docker run --rm -it -v ${HOME}/.lando/plugins:/plugins -w /tmp node:14-alpine sh -c \
  "yarn init -y \
  && yarn add @lando/solr --production --flat --no-default-rc --no-lockfile --link-duplicates \
  && yarn install --production --cwd /tmp/node_modules/@lando/solr \
  && mkdir -p /plugins/@lando \
  && mv --force /tmp/node_modules/@lando/solr /plugins/@lando/solr"

# Rebuild the plugin cache
lando --clear
```
:::
::: code-group-item HYPERDRIVE
```bash:no-line-numbers
# @TODO
# @NOTE: This doesn't actaully work yet
hyperdrive install @lando/solr
```
::::

You should be able to verify the plugin is installed by running `lando config --path plugins` and checking for `@lando/solr`. This command will also show you _where_ the plugin is being loaded from.
