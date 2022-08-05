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
# Should use version 9.x for the default version
lando ssh -s helper -c "curl defaults:8983/solr/admin/info/system?wt=json" | grep "solr-spec-version" | grep "9."

# Should use version 9.0 on patch version
lando ssh -s helper -c "curl patch:8983/solr/admin/info/system" | grep "solr-spec-version" | grep "9.0"

# Should have lando core by default
lando ssh -s helper -c "curl defaults:8983/solr/admin/cores?action=STATUS" | grep lando

# Should be able to set a record
lando post-record-defaults
lando post-record-patch

# Should be able to reload cores
lando ssh -s helper -c "curl http://defaults:8983/solr/admin/cores?action=RELOAD&core=lando"
lando ssh -s helper -c "curl http://patch:8983/solr/admin/cores?action=RELOAD&core=solo"

# Should have records persist a rebuild on version 4 plus
lando rebuild -y
lando ssh -s helper -c "curl http://defaults:8983/solr/lando/select?q=*:*" | grep "12"
lando ssh -s helper -c "curl http://patch:8983/solr/solo/select?q=*:*" | grep "12"

# Should load custom config
lando ssh -s defaults -c "cat /solrconf/conf/schema.xml" | grep "<luceneMatchVersion>9.0</luceneMatchVersion"
```

Destroy tests
-------------

Run the following commands to trash this app like nothing ever happened.

```bash
# Should be destroyed with success
lando destroy -y
lando poweroff
```

