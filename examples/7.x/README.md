Solr Example
============

This example exists primarily to test the following documentation:

* [Solr Service](https://docs.devwithlando.io/tutorials/solr.html)

Start up tests
--------------

Run the following commands to get up and running
with this example.

```bash
# Should start up successfully
lando poweroff
lando start

# Should reset old conf
cp -r 7.x-conf/solrcore.properties.old 7.x-conf/solrcore.properties
```

Verification commands
---------------------

Run the following commands to validate things are rolling as they should.

```bash
# Should use version 7.x for the default version
lando ssh -s helper -c "curl defaults:8983/solr/admin/info/system?wt=json" | grep "solr-spec-version" | grep "7."

# Should use version 7.7 on custom version
lando ssh -s helper -c "curl custom:8983/solr/admin/info/system" | grep "solr-spec-version" | grep "7.7"

# Should have lando core by default
lando ssh -s helper -c "curl defaults:8983/solr/admin/cores?action=STATUS" | grep lando

# Should have custom core if given by user
lando ssh -s helper -c "curl custom:8983/solr/admin/cores?action=STATUS" | grep freedom

# Should have correct core permissions
lando ssh -s defaults -c "ls -lsa /opt/solr/server/solr/mycores/lando" | grep "solr solr" | wc -l | grep 5
lando ssh -s custom -c "ls -lsa /opt/solr/server/solr/mycores/freedom" | grep "solr solr" | wc -l | grep 5

# Should be able to set a record
lando post-record-custom
lando post-record-defaults

# Should be able to reload cores
lando ssh -s helper -c "curl http://defaults:8983/solr/admin/cores?action=RELOAD&core=lando"
lando ssh -s helper -c "curl http://custom:8983/solr/admin/cores?action=RELOAD&core=freedom"

# Should have records persist a rebuild on version 4 plus
lando rebuild -y
lando ssh -s helper -c "curl http://custom:8983/solr/freedom/select?q=*:*" | grep "12"
lando ssh -s helper -c "curl http://defaults:8983/solr/lando/select?q=*:*" | grep "12"

# Should load custom config
lando ssh -s custom -c "cat /solrconf/conf/schema.xml" | grep "drupal-6.5-solr-7.x"
```

Destroy tests
-------------

Run the following commands to trash this app like nothing ever happened.

```bash
# Should be destroyed with success
lando destroy -y
lando poweroff
```

