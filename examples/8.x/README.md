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
```

Verification commands
---------------------

Run the following commands to validate things are rolling as they should.

```bash
# Should use version 8.x for the default version
lando ssh -s helper -c "curl defaults:8983/solr/admin/info/system?wt=json" | grep "solr-spec-version" | grep "8."

# Should use version 8.11.1 on patch version
lando ssh -s helper -c "curl patch:8983/solr/admin/info/system" | grep "solr-spec-version" | grep "8.6.3"

# Should use version 8 on custom8 version
lando ssh -s helper -c "curl custom8:8983/solr/admin/info/system" | grep "solr-spec-version" | grep "8."

# Should have lando core by default
lando ssh -s helper -c "curl defaults:8983/solr/admin/cores?action=STATUS" | grep lando

# Should have custom core if given by user
lando ssh -s helper -c "curl custom:8983/solr/admin/cores?action=STATUS" | grep freedom
lando ssh -s helper -c "curl custom8:8983/solr/admin/cores?action=STATUS" | grep levon

# Should have correct core permissions
lando ssh -s defaults -c "ls -lsa /opt/solr/server/solr/mycores/lando" | grep "solr solr" | wc -l | grep 5
lando ssh -s patch -c "ls -lsa /opt/solr/server/solr/mycores/solo" | grep "solr solr" | wc -l | grep 5
lando ssh -s custom8 -c "ls -lsa /var/solr/data/levon" | grep "solr solr" | wc -l | grep 5

# Should be able to set a record
lando post-record-defaults
lando post-record-patch
lando post-record-custom8

# Should be able to reload cores
lando ssh -s helper -c "curl http://defaults:8983/solr/admin/cores?action=RELOAD&core=lando"
lando ssh -s helper -c "curl http://patch:8983/solr/admin/cores?action=RELOAD&core=solo"

# Should have records persist a rebuild on version 4 plus
lando rebuild -y
lando ssh -s helper -c "curl http://custom8:8983/solr/levon/select?q=*:*" | grep "12"
lando ssh -s helper -c "curl http://defaults:8983/solr/lando/select?q=*:*" | grep "Tom Brady"
lando ssh -s helper -c "curl http://patch:8983/solr/solo/select?q=*:*" | grep "Tom Brady"

# Should load custom config
lando ssh -s custom8 -c "cat /solrconf/conf/schema.xml" | grep "drupal-6.5-solr-7.x"
```

Destroy tests
-------------

Run the following commands to trash this app like nothing ever happened.

```bash
# Should be destroyed with success
lando destroy -y
lando poweroff
```

