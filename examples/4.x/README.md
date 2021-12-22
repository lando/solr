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
# Should use version 4.10.x on legacy4 version
lando ssh -s helper -c "curl legacy4:8983/solr/admin/info/system" | grep "solr-spec-version" | grep "4.10"

# Should have correct core permissions
lando ssh -s legacy4 -c "ls -lsa /opt/solr-4.10.4/example/solr/collection1" | grep "solr solr" | wc -l | grep 6

# Should be able to set a record
lando post-record-legacy

# Should be able to reload cores
lando ssh -s helper -c "curl http://legacy4:8983/solr/admin/cores?action=RELOAD&core=collection1"

# Should have records persist a rebuild on version 4 plus
lando rebuild -y
lando ssh -s helper -c "curl http://legacy4:8983/solr/collection1/select?q=*:*" | grep "12"

# Should load custom config
lando ssh -s legacy4 -c "cat /opt/solr-4.10.4/example/solr/collection1/conf/schema.xml" | grep "filezzzz"
```

Destroy tests
-------------

Run the following commands to trash this app like nothing ever happened.

```bash
# Should be destroyed with success
lando destroy -y
lando poweroff
```

