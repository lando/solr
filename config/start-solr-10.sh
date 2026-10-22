#!/bin/bash

# Errors and logz
set -e
echo "Executing $0" "$@"

# Reporting
echo "Booting solr with..."
echo "CORE: $LANDO_SOLR_CORE"
echo "CONFIG CUSTOM: $LANDO_SOLR_CUSTOM"
echo "DATADIR: $LANDO_SOLR_DATADIR"
echo "INSTALL DIR": $LANDO_SOLR_INSTALL_DIR

# Make sure the conf dir is good if we have one
if [ "$LANDO_SOLR_CUSTOM" != "none" ]; then
  if [ -f "/solrconf/conf/solrcore.properties" ]; then
    if cat "/solrconf/conf/solrcore.properties" | grep "solr.install.dir"; then
      if cat "/solrconf/conf/solrcore.properties" | grep "solr.install.dir" | grep "$LANDO_SOLR_INSTALL_DIR"; then
        echo "solrcore.properties is good!"
      else
        cp -f "/solrconf/conf/solrcore.properties" "/solrconf/conf/solrcore.properties.old"
        echo "solr.install.dir=$LANDO_SOLR_INSTALL_DIR" >> "/solrconf/conf/solrcore.properties"
      fi
    fi
  fi
fi

# Chownage
mkdir -p /solrconf
mkdir -p /opt/solr
mkdir -p /var/solr
chown -R solr:solr /solrconf
chown -R solr:solr /opt/solr
chown -R solr:solr /var/solr

. /opt/solr/docker/scripts/run-initdb

# Later Solr 10 images drop gosu (SOLR-17353). 10.0.0 still ships it.
as_solr() {
  if command -v gosu >/dev/null 2>&1; then
    gosu solr:solr "$@"
  elif command -v setpriv >/dev/null 2>&1; then
    setpriv --reuid=solr --regid=solr --init-groups -- "$@"
  else
    echo "Cannot drop privileges to solr: gosu and setpriv are both missing" >&2
    exit 1
  fi
}

# Go down to solr and run
if [ "$LANDO_SOLR_CUSTOM" != "none" ]; then
  as_solr docker-entrypoint.sh precreate-core "$LANDO_SOLR_CORE" /solrconf
  as_solr cp -a "/solrconf/conf/." "$LANDO_SOLR_DATADIR/$LANDO_SOLR_CORE/conf/"
else
  as_solr docker-entrypoint.sh precreate-core "$LANDO_SOLR_CORE"
fi

as_solr solr start -f --user-managed
