#!/bin/bash
set -e
shopt -s nullglob dotglob

# Keep track of our own JARs so restarts remove deleted plugins, not bundled libraries.
lib="$LANDO_SOLR_DATADIR/lib"
managed="$LANDO_SOLR_DATADIR/.lando-plugins"
if [ -z "$LANDO_SOLR_PLUGINS_DIR" ] && [ ! -d "$managed" ]; then
  exit 0
fi
if [ -n "$LANDO_SOLR_PLUGINS_DIR" ] && [ ! -d "$LANDO_SOLR_PLUGINS_DIR" ]; then
  echo "Solr plugins directory is missing: $LANDO_SOLR_PLUGINS_DIR" >&2
  exit 1
fi
mkdir -p "$lib" "$managed"
for jar in "$managed"/*.jar; do
  rm -f "$lib/$(basename "$jar")" "$jar"
done

if [ -z "$LANDO_SOLR_PLUGINS_DIR" ]; then
  exit 0
fi
for jar in "$LANDO_SOLR_PLUGINS_DIR"/*.jar; do
  [ -f "$jar" ] || continue
  name=$(basename "$jar")
  if [ -e "$lib/$name" ] || [ -L "$lib/$name" ]; then
    echo "Solr plugin conflicts with an existing library: $name" >&2
    exit 1
  fi
  touch "$managed/$name"
  cp "$jar" "$lib/$name"
done
