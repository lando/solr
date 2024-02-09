---
title: Configuration
description: Learn how to configure the Lando Solr service.
---

# Configuration

Here are the configuration options, set to the default values, for this service. If you are unsure about where this goes or what this means, we *highly recommend* scanning the [services documentation](https://docs.lando.dev/core/v3/lando-service.html) to get a good handle on how the magicks work.

Also note that options, in addition to the [build steps](https://docs.lando.dev/core/v3/lando-service.html#build-steps) and [overrides](https://docs.lando.dev/core/v3/lando-service.html#overrides) that are available to every service, are shown below:

```yaml
services:
  myservice:
    type: solr:7
    portforward: false
    core: lando
    config:
      dir: SEE BELOW
```

## Port forwarding

`portforward` will allow you to access this service externally by assigning a port directly on your host's `localhost`. Note that `portforward` can be set to either `true` or a specific `port` but we *highly recommend* you set it to `true` unless you have pretty good knowledge of how port assignment works or you have a **very** compelling reason for needing a locked down port.

`portforward: true` will prevent inevitable port collisions and provide greater reliability and stability across Lando apps. That said, one downside of `portforward: true` is that Docker will assign a different port every time you restart your application. You can read more about accessing services externally [over here](https://docs.lando.dev/guides/external-access.html).

`tl;dr`

**Recommended**

```yaml
services:
  myservice:
    type: solr
    portforward: true
```

**Not recommended**

```yaml
services:
  myservice:
    type: solr
    portforward: 8983
```

## Using a custom core

You can easily set up a different core name with the `core` config value.

```yaml
services:
  myservice:
    type: solr
    core: my-core
```

::: warning Solr 5+ only!
The `core` config value does not work for Solr 3.x or 4.x.
:::

## Using custom solr config

You will almost certainly need to utilize your own custom Solr config. You can do that by telling Lando to inject solr config from a directory inside of your application.

Consider a Drupal 8 or 9 application injecting the Solr 7.x config directly from the `search_api_solr` module as shown in the example below:

**A hypothetical project**

Note that if using custom configuration you can put your configuration files anywhere inside your application directory. We use a `config` directory but you can call it whatever you want such as `.lando`. In this example we're using the ["jump-start" configuration](https://git.drupalcode.org/project/search_api_solr/-/tree/4.x/jump-start) from `search_api_solr`:

```bash
./
|-- web/modules/contrib/search_api_solr/jump-start/solr7/config-set
   |-- elevate.xml
   |-- mapping-ISOLatin1Accent.txt
   |-- protwords.txt
   |-- schema_extra_fields.xml
   |-- schema_extra_types.xml
   |-- schema.xml
   |-- solrconfig_extra.xml
   |-- solrconfig_index.xml
   |-- solrconfig_spellcheck.xml
   |-- solrconfig.xml
   |-- solrcore.properties
   |-- stopwords.txt
   |-- synonyms.txt
   |-- ... (and many more)
|-- .lando.yml
```

**Landofile's solr config**

```yaml
services:
  myservice:
    type: solr
    config:
      dir: web/modules/contrib/search_api_solr/jump-start/solr7/config-set
```

## Getting information

You can get connection and credential information about your solr instance by running [`lando info`](https://docs.lando.dev/cli/info.html). It may also be worth checking out our [accessing services externally guide](https://docs.lando.dev/guides/external-access.html).
