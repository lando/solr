#!/bin/bash
# Requires Docker. Override images with SOLR_TEST_IMAGES="solr:9.0 solr:10".
set -euo pipefail

root=$(cd "$(dirname "$0")/.." && pwd)
work=$(mktemp -d)
container="lando-solr-addons-$$"
cleanup() {
  docker rm -f "$container" >/dev/null 2>&1 || true
  rm -rf "$work"
}
trap cleanup EXIT

for image in ${SOLR_TEST_IMAGES:-solr:9.9 solr:10}; do
  case "$image" in
    solr:9*) start=start-solr-9.sh ;;
    solr:10*) start=start-solr-10.sh ;;
    *) echo "Unsupported test image: $image" >&2; exit 1 ;;
  esac
  mkdir -p "$work/plugins"
  docker create --name "$container" "$image" >/dev/null
  docker cp "$container:/opt/solr/modules/analysis-extras/lib/." "$work/plugins"
  docker rm "$container" >/dev/null

  for mode in modules plugins; do
    extra=()
    if [ "$mode" = modules ]; then
      extra+=(-e SOLR_MODULES=analysis-extras)
    else
      extra+=(-e LANDO_SOLR_PLUGINS_DIR=/lando-solr-plugins -v "$work/plugins:/lando-solr-plugins:ro")
    fi
    docker run -d --name "$container" --user root --entrypoint /bin/bash \
      -e LANDO_SOLR_CUSTOM=none -e LANDO_SOLR_CORE=lando \
      -e LANDO_SOLR_DATADIR=/var/solr/data -e LANDO_SOLR_INSTALL_DIR=/opt/solr \
      -v "$root/config/$start:/start-solr.sh:ro" \
      -v "$root/config/install-plugins.sh:/install-solr-plugins.sh:ro" \
      "${extra[@]}" "$image" /start-solr.sh >/dev/null

    ready=false
    for attempt in {1..120}; do
      if docker exec "$container" curl -fsS http://localhost:8983/solr/lando/admin/ping >/dev/null 2>&1; then
        ready=true
        break
      fi
      if [ "$(docker inspect -f '{{.State.Running}}' "$container")" != true ]; then break; fi
      sleep 1
    done
    if [ "$ready" != true ]; then
      docker logs "$container"
      exit 1
    fi

    # ICUCollationField must actually load, not merely appear in an environment variable.
    field='{"add-field-type":{"name":"test_icu","class":"solr.ICUCollationField","locale":"en"}}'
    # Solr 9.0 has an upstream ICUCollationField access error; test its ICU analyzer instead.
    if [ "$image" = solr:9.0 ]; then
      field='{"add-field-type":{"name":"test_icu","class":"solr.TextField","analyzer":{"tokenizer":{"class":"solr.KeywordTokenizerFactory"},"filters":[{"class":"solr.ICUFoldingFilterFactory"}]}}}'
    fi
    response=$(docker exec "$container" curl -sS http://localhost:8983/solr/lando/schema \
      -H 'Content-Type: application/json' \
      -d "$field")
    if ! grep -q '"status":0' <<< "$response" || grep -q '"errors"' <<< "$response"; then
      echo "$response"
      exit 1
    fi
    echo "PASS $image $mode: ICU field type loaded"
    docker rm -f "$container" >/dev/null
  done
  rm -rf "$work/plugins"
done
