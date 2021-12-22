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
# Should use version 3.6.x on legacy3 version
lando ssh -s helper -c "curl legacy3:8983/solr/admin/registry.jsp" | grep "solr-spec-version" | grep "3.6"

# Should have correct core permissions
lando ssh -s legacy3 -c "ls -lsa /opt/solr/example/solr" | grep "solr solr" | wc -l | grep 7

# Should load custom config
lando ssh -s legacy3 -c "cat /opt/solr/example/solr/conf/schema.xml" | grep "FOR REAAAAALLLL"
```

Destroy tests
-------------

Run the following commands to trash this app like nothing ever happened.

```bash
# Should be destroyed with success
lando destroy -y
lando poweroff
```

